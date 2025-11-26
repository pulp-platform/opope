// Copyright 2025 ETH Zurich and University of Bologna.
// Solderpad Hardware License, Version 0.51, see LICENSE for details.
// SPDX-License-Identifier: SHL-0.51
//
// Danilo Cammarata <dcammarata@iis.ee.ethz.ch>
//

import fpnew_pkg::*;
import hci_package::*;
import hwpe_stream_package::*;

package opope_pkg;

  parameter int unsigned            ARRAY_HEIGHT      = 8;
  parameter fpnew_pkg::fp_format_e  FPFORMAT          = fpnew_pkg::FP16;
  parameter int unsigned            BITW              = fpnew_pkg::fp_width(FPFORMAT);
  parameter int unsigned            ARRAY_WIDTH       = ARRAY_HEIGHT;
  parameter int unsigned            DATA_W            = 2*BITW*ARRAY_HEIGHT + 32;                                  
  parameter int unsigned            MemDw             = 32;
  parameter int unsigned            DATAW             = DATA_W - MemDw;
  parameter int unsigned            OPOPE_REGS        = 22;
  parameter int unsigned            N_CONTEXT         = 2;
  parameter int unsigned            PIPE_REGS         = 4;
  parameter int unsigned            ECC_CHUNK_SIZE    = 32;
  parameter int unsigned            ECC_N_CHUNK       = DATA_W / ECC_CHUNK_SIZE;
  parameter int unsigned            X_REGBUFFER_DEPTH = 2;
  parameter int unsigned            W_REGBUFFER_DEPTH = 2;
  parameter int unsigned            REG_PER_CE        = X_REGBUFFER_DEPTH * W_REGBUFFER_DEPTH;
  parameter int unsigned            ACC_RD_PORTS      = 2;
  parameter int unsigned            ACC_WR_PORTS      = 2;
  parameter int unsigned            NumStreamSources  = 3;
  parameter int unsigned            XsourceStreamId   = 0;
  parameter int unsigned            WsourceStreamId   = 1;
  parameter int unsigned            YsourceStreamId   = 2;
  localparam int unsigned           ID                = 10;
  
  // Register File mapping
  /**********************
  ** Slave RF indexing **
  **********************/
  parameter int unsigned X_ADDR = 0; // 0x00 /* These do not change between slave and final */
  parameter int unsigned W_ADDR = 1; // 0x04 /* These do not change between slave and final */
  parameter int unsigned Z_ADDR = 2; // 0x08 /* These do not change between slave and final */
  parameter int unsigned MCFIG0 = 3; // 0x0C --> [31:16] -> K size, [15: 0] -> M size
  parameter int unsigned MCFIG1 = 4; // 0x10 --> [31: 0] -> N Size
  parameter int unsigned MACFG  = 5; // 0x14 --> [12:10] -> Operation selection, [ 9: 7] -> Input/Output format
  
  /**********************
  ** Final RF indexing **
  **********************/
  // Number of iterations on X and W matrices
  // (15 bits for number of rows iterations, 15 bits for number of columns iterations)
  parameter int unsigned X_ITERS   = 3; // 0x0C --> [31:16] -> ROWS ITERATIONS, [15:0] -> COLUMNS ITERATIONS
  parameter int unsigned W_ITERS   = 4; // 0x10 --> [31:16] -> ROWS ITERATIONS, [15:0] -> COLUMNS ITERATIONS
  // Number of rows and columns leftovers (8 bits for each)
  // [31:24] -> X/Y ROWS LEFTOVERS
  // [23:16] -> X COLUMNS LEFTOVERS
  // [15:8]  -> W ROWS LEFTOVERS
  // [7:0]   -> W/Y COLUMNS LEFTOVERS
  parameter int unsigned LEFTOVERS = 5; // 0x14
  // We keep a register for the remaining params
  // [31:16] -> TOT_NUMBER_OF_STORES
  // [14]    -> 1'b0: X cols/W rows >= ARRAY_HEIGHT; 1'b1: X cols/W rows < ARRAY_HEIGHT
  // [13]    -> 1'b0: W cols >= TILE ( TILE = (PIPE_REGS + 1)*ARRAY_HEIGHT ); 1'b1: W cols < TILE ( TILE = (PIPE_REGS + 1)*ARRAY_HEIGHT )
  parameter int unsigned LEFT_PARAMS = 6;  // 0x18
  parameter int unsigned X_D1_STRIDE = 7;  // 0x1C
  parameter int unsigned W_TOT_LEN   = 8;  // 0x20
  parameter int unsigned TOT_X_READ  = 9;  // 0x24
  parameter int unsigned W_D0_STRIDE = 10; // 0x20
  parameter int unsigned Z_TOT_LEN   = 11; // 0x2C
  parameter int unsigned Z_D0_STRIDE = 12; // 0x30
  parameter int unsigned Z_D2_STRIDE = 13; // 0x34
  parameter int unsigned X_ROWS_OFFS = 14; // 0x38
  // parameter int unsigned X_SLOTS     = 15; // 0x3C
  // parameter int unsigned IN_TOT_LEN  = 16; // 0x40
  parameter int unsigned N_K_M  = 15; // 0x40
  parameter int unsigned K_M  = 16; // 0x40
  // One resgister is used for the round modes and operations of the Computing Elements.
  // [31:29] -> roundmode of the stage 1
  // [28:26] -> roundmode of the stage 2
  // [25:21] -> operation of the stage 1
  // [20:16] -> operation of the stage 2
  // [15:13] -> input/output format
  // [12:10] -> computing format
  // [0:0]   -> GEMM selection
  parameter int unsigned OP_SELECTION = 17; // 0x44
  parameter int unsigned M_SIZE = 18; 
  parameter int unsigned N_SIZE = 19; 
  parameter int unsigned K_SIZE = 20; 

  parameter bit[6:0] MCNFIG = 7'b0001011; // 0x0B
  parameter bit[6:0] MARITH = 7'b0101011; // 0x2B
  parameter bit[6:0] RVCSR  = 7'b1110011; // 0x73 -> RISC-V CSR instruction opcode

  /* The CSRs below are not really present in the current O-POPE version. The following
     enum is here to allow future development where it might be useful to write the
     configuration registers through standard `csrw` instructions coming from the core.
     The CSRs values are chosen following the custom read/write already available in the
     RISC-V specifications. */
  typedef enum logic[11:0] {
    CSR_OPOPE_X_ADDR = 12'h800,
    CSR_OPOPE_W_ADDR = 12'h801,
    CSR_OPOPE_Z_ADDR = 12'h802,
    CSR_OPOPE_MCFIG0 = 12'h803,
    CSR_OPOPE_MCFIG1 = 12'h804,
    CSR_OPOPE_MACFG  = 12'h805
  } opope_csr_num_e;

  typedef enum logic[1:0] {
    IDLE,
    Y_LOAD, 
    COMPUTE, 
    Z_READ
  } cntrl_engine_mode_e;

  typedef struct packed {
    hci_package::hci_streamer_ctrl_t x_stream_source_ctrl;
    hci_package::hci_streamer_ctrl_t w_stream_source_ctrl;
    hci_package::hci_streamer_ctrl_t y_stream_source_ctrl;
    hci_package::hci_streamer_ctrl_t z_stream_sink_ctrl;
    fpnew_pkg::fp_format_e           input_cast_src_fmt;
    fpnew_pkg::fp_format_e           input_cast_dst_fmt;
    fpnew_pkg::fp_format_e           output_cast_src_fmt;
    fpnew_pkg::fp_format_e           output_cast_dst_fmt;
    logic                                                      custom_priority_force;  
    logic [NumStreamSources-1:0][$clog2(NumStreamSources)-1:0] custom_priority      ;
  } cntrl_streamer_t;

  typedef struct packed {
    hci_package::hci_streamer_flags_t x_stream_source_flags;
    hci_package::hci_streamer_flags_t w_stream_source_flags;
    hci_package::hci_streamer_flags_t y_stream_source_flags;
    hci_package::hci_streamer_flags_t z_stream_sink_flags  ;
    logic                             x_granted            ; 
    logic                             w_granted            ; 
    logic                             y_granted            ;  
  } flgs_streamer_t;

  typedef struct packed {
    logic start_load_x;
    logic start_load_w;
    logic start_load_y;
    logic start_store_z;
    logic rst;
    logic finished;
  } cntrl_scheduler_t;

  typedef struct packed {
    logic            w_loaded;
  } flgs_scheduler_t;

  typedef enum logic [2:0] { MATMUL=3'h0, GEMM=3'h1, ADDMAX=3'h2, ADDMIN=3'h3, MULMAX=3'h4, MULMIN=3'h5, MAXMIN=3'h6, MINMAX=3'h7} gemm_op_e;
  typedef enum logic [2:0] { Float8=3'h0, Float16=3'h1, Float8Alt=3'h2, Float16Alt=3'h3, Float32=3'h4 } gemm_fmt_e;
  typedef enum logic       { RNE=1'h0, RTZ=1'h1 } rnd_mode_e;
  typedef enum logic [2:0] { FPU_FMADD=3'h0, FPU_ADD=3'h2, FPU_MUL=3'h3, FPU_MINMAX=3'h7 }    fpu_op_e;
  typedef enum logic [2:0] { FPU_FP32=3'h0, FPU_FP16=3'h2, FPU_FP8=3'h3, FPU_FP16ALT=3'h4, FPU_FP8ALT=3'h5  } fpu_fmt_e;

  typedef struct packed {
    logic [31:0] x_addr;
    logic [31:0] w_addr;
    logic [31:0] z_addr;
    logic [15:0] m_size;
    logic [15:0] n_size;
    logic [15:0] k_size;
    gemm_op_e gemm_ops;
    gemm_fmt_e gemm_memory_fmt;
    gemm_fmt_e gemm_computing_fmt;

    logic [15:0] x_cols_iter;
    logic [15:0] x_rows_iter;
    logic [15:0] w_cols_iter;
    logic [15:0] w_rows_iter;
    logic [ 7:0] x_cols_lftovr;
    logic [ 7:0] x_rows_lftovr;
    logic [ 7:0] w_cols_lftovr;
    logic [ 7:0] w_rows_lftovr;
    logic [15:0] tot_stores;
    logic [31:0] x_d1_stride;
    logic [31:0] w_tot_len;
    logic [31:0] tot_x_read;
    logic [31:0] w_d0_stride;
    logic [31:0] yz_tot_len;
    logic [31:0] yz_d0_stride;
    logic [31:0] yz_d2_stride;
    logic [31:0] x_rows_offs;
    logic [31:0] x_buffer_slots;
    logic [31:0] x_tot_len;
    rnd_mode_e stage_1_rnd_mode;
    rnd_mode_e stage_2_rnd_mode;
    fpu_op_e stage_1_op;
    fpu_op_e stage_2_op;
    fpu_fmt_e memory_format;
    fpu_fmt_e computing_format;
    logic        gemm_selection;
    logic [31:0] n_k_m;
    logic [31:0] k_m;
  } opope_config_t;

  typedef struct packed {
    logic                   [2:0] fma_is_boxed;
    logic                   [1:0] noncomp_is_boxed;
    fpnew_pkg::roundmode_e        stage1_rnd;
    fpnew_pkg::roundmode_e        stage2_rnd;
    fpnew_pkg::operation_e        op1;
    fpnew_pkg::operation_e        op2;
    fpu_fmt_e                     memory_format;
    fpu_fmt_e                     computing_format;
    logic                         op_mod;
    cntrl_engine_mode_e           mode;
    logic      iteration_change;
    logic      [31:0] inner_loop_count;
    logic       in_valid         ;
    logic       y_in_valid       ;
    logic       in_ready         ;
    logic       reg_enable       ;
    logic [$clog2(REG_PER_CE)-1:0] y_write_reg_index;
    logic [$clog2(ARRAY_HEIGHT)-1:0]     y_write_row_index;
    logic [$clog2(REG_PER_CE)-1:0] z_read_reg_index ;
    logic [$clog2(ARRAY_HEIGHT)-1:0]     z_read_row_index ;
    logic [$clog2(REG_PER_CE)-1:0] reg_write_to_engine;
    logic y_bias_selector     ;
    logic acc_input_selector  ;
    logic external_loading    ;
    logic shift_acc           ;
  } cntrl_engine_t;
  
endpackage
