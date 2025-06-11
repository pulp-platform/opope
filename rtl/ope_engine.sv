// Copyright 2023 ETH Zurich and University of Bologna.
// Solderpad Hardware License, Version 0.51, see LICENSE for details.
// SPDX-License-Identifier: SHL-0.51
//
// George Pagonis  <gpagonis@student.ethz.ch>


module ope_engine
  import fpnew_pkg::*;
  import ope_pkg::*;
#(
 parameter  fp_format_e   FpFormat    = fpnew_pkg::FP32              ,
 parameter  int unsigned  Height      = 4                            , // Number of PEs per row
 parameter  int unsigned  Width       = 8                            , // Number of parallel index
 parameter  int unsigned  NumPipeRegs = 3                            ,
 parameter  pipe_config_t PipeConfig  = DISTRIBUTED                  ,
 parameter  type          TagType     = logic                        ,
 parameter  type          AuxType     = logic                        ,
 localparam int unsigned  BITW        = fpnew_pkg::fp_width(FpFormat), // Number of bits for the given format
 localparam int unsigned  H           = Height                       ,
 localparam int unsigned  W           = Width                        ,
 parameter logic          Stallable   = 1'b1                         
)(
  input  logic                                             clk_i              ,
  input  logic                                             rst_ni             ,
  input  logic                    [  H-1:0][BITW-1:0]      x_input_i          , // Column of inputs
  input  logic                    [  W-1:0][BITW-1:0]      w_input_i          , // Row of weights
  input  logic                    [2*W-1:0][BITW-1:0]      y_bias_i           , // Row of biases
  output logic                    [2*W-1:0][BITW-1:0]      z_output_o         , // Row of outputs

  input  logic                                             in_valid_i         ,
  input  logic                                             y_in_valid_i       ,
  output logic                                             in_ready_o         ,
  input  logic                                             reg_enable_i       ,

  output logic                                             out_valid_o        ,
  input  logic                                             out_ready_i        ,


  input logic                                              last_iteration_i,
  input logic                                              start_i,    
  output logic                                             accumulation_reg_y_ready_o,    

  input  cntrl_engine_t                                    cntrl_engine_i  // This include the mode (idle, load, compute, read) and the row_index
);


  typedef enum logic [2:0] {
    ACC_IDLE = 3'b000,
    ACC_Y_READ = 3'b001,
    ACC_LOAD_ENGINE = 3'b010,
    ACC_Y_READ_ENGINE_RUNNING = 3'b011,
    ACC_ENGINE_RUNNING = 3'b100,
    ACC_Z_RELOAD_Y_ENGINE = 3'b101,
    ACC_Z_RELOAD = 3'b110,
    ACC_Z_STORE = 3'b111
  } acc_state_e;


  // logic last_iteration_d, last_iteration_q;

  acc_state_e acc_state_current, acc_state_next;
  logic prefetched_d, prefetched_q;


  logic [31:0] inner_loop_counter_q, inner_loop_counter_d;

  logic [$clog2(REG_PER_CE)-1:0] y_write_reg_index_q, y_write_reg_index_d;
  logic [$clog2(Height)-1:0] y_write_row_index_q, y_write_row_index_d;

  logic [$clog2(REG_PER_CE)-1:0] z_read_reg_index_q, z_read_reg_index_d;
  logic [$clog2(Height)-1:0] z_read_row_index_q, z_read_row_index_d;

  logic [$clog2(REG_PER_CE)-1:0] reg_write_to_engine_q, reg_write_to_engine_d;

  logic [Height-1:0][Width-1:0][2*BITW-1:0] reg_out_data;
  logic [Height-1:0][Width-1:0]             reg_out_valid;

  logic [Height-1:0][Width-1:0][BITW-1:0] engine_to_reg_output;
  logic [Height-1:0][Width-1:0]           engine_to_reg_out_valid;
  logic [Height-1:0][Width-1:0]           engine_in_valid;
  logic change_state; 
  logic y_bias_selector; 
  logic acc_input_selector;
  logic external_loading;
  logic done_d,done_q;

  always_comb begin : acc_fsm
    acc_state_next = acc_state_current;

    case (acc_state_current)
    // -------------------------------------------------------------------------------------------------------------------------------------
      ACC_IDLE                  : acc_state_next = change_state                     ? ACC_Y_READ                : ACC_IDLE                 ;
    // -------------------------------------------------------------------------------------------------------------------------------------
      ACC_Y_READ                : acc_state_next = change_state                     ? ACC_LOAD_ENGINE           : ACC_Y_READ               ;
    // -------------------------------------------------------------------------------------------------------------------------------------
      ACC_LOAD_ENGINE           : acc_state_next = change_state                     ? ACC_Y_READ_ENGINE_RUNNING : ACC_LOAD_ENGINE          ;
    // -------------------------------------------------------------------------------------------------------------------------------------                                             
      ACC_Y_READ_ENGINE_RUNNING : acc_state_next = change_state                     ? ACC_Z_RELOAD_Y_ENGINE     : ACC_Y_READ_ENGINE_RUNNING;
    // -------------------------------------------------------------------------------------------------------------------------------------
      ACC_ENGINE_RUNNING        : acc_state_next = change_state                     ? ACC_Z_RELOAD              : ACC_ENGINE_RUNNING       ; 
    // -------------------------------------------------------------------------------------------------------------------------------------
      ACC_Z_RELOAD_Y_ENGINE     : acc_state_next = change_state                     ? ACC_Z_STORE               : ACC_Z_RELOAD_Y_ENGINE    ; 
    // -------------------------------------------------------------------------------------------------------------------------------------
      ACC_Z_RELOAD              : acc_state_next = change_state                     ? ACC_Z_STORE               : ACC_Z_RELOAD             ;
    // -------------------------------------------------------------------------------------------------------------------------------------
      ACC_Z_STORE               : acc_state_next = change_state && done_q           ? ACC_IDLE                  :
                                                   change_state && last_iteration_i ? ACC_ENGINE_RUNNING        : 
                                                   change_state                     ? ACC_Y_READ_ENGINE_RUNNING : ACC_Z_STORE              ; 
    // -------------------------------------------------------------------------------------------------------------------------------------
      default                   : acc_state_next = ACC_IDLE;
    // -------------------------------------------------------------------------------------------------------------------------------------
    endcase
  end

  always_comb begin : acc_values
    y_write_reg_index_d   = y_write_reg_index_q  ;
    y_write_row_index_d   = y_write_row_index_q  ;
    inner_loop_counter_d  = inner_loop_counter_q ;
    reg_write_to_engine_d = reg_write_to_engine_q;
    z_read_reg_index_d    = z_read_reg_index_q   ;
    z_read_row_index_d    = z_read_row_index_q   ;
    prefetched_d          = prefetched_q         ;
    done_d                = done_q               ;

    // last_iteration_d      = last_iteration_i | last_iteration_q;

    change_state                  = 1'b0;
    out_valid_o                   = 1'b0;
    accumulation_reg_y_ready_o    = 1'b0;
    y_bias_selector               = 1'b0;
    acc_input_selector            = 1'b0;
    external_loading              = 1'b0;
    in_ready_o                    = 1'b0;

    case (acc_state_current)
    // -------------------------------------------------------------------------------------------------------------------------------------
      ACC_IDLE: begin
        change_state               = start_i     ;
        accumulation_reg_y_ready_o = change_state;
        done_d                     = '0;
        y_write_reg_index_d        = '0;
        y_write_row_index_d        = '0;
        z_read_reg_index_d         = '0;
        inner_loop_counter_d       = '0;
        reg_write_to_engine_d      = '0;
        prefetched_d               = '0;
      end
    // -------------------------------------------------------------------------------------------------------------------------------------
      ACC_Y_READ: begin
        if (y_in_valid_i) begin
          y_write_reg_index_d = (y_write_reg_index_q == REG_PER_CE - 2) ? 'b0 : y_write_reg_index_q + 2;
          y_write_row_index_d = (y_write_reg_index_q == REG_PER_CE - 2) ? (y_write_row_index_q == Height-1) ? 'b0: y_write_row_index_q + 1 : y_write_row_index_q;
          change_state        = (y_write_row_index_q == Height - 1 && y_write_reg_index_q == REG_PER_CE - 2);
        end
        external_loading              = 1'b1        ;
        accumulation_reg_y_ready_o    = 1'b1        ;
      end
    // -------------------------------------------------------------------------------------------------------------------------------------
      ACC_LOAD_ENGINE: begin
        if (in_valid_i) begin
          inner_loop_counter_d = (inner_loop_counter_q == (cntrl_engine_i.inner_loop_count - 1)) ? 'b0 : inner_loop_counter_q + 1;
          z_read_reg_index_d = (z_read_reg_index_q == REG_PER_CE - 1) ? 'b0: z_read_reg_index_q + 1; // This can be used both ways
          change_state = (z_read_reg_index_q == REG_PER_CE - 1);
        end
        if (y_in_valid_i && prefetched_q == 1'b0) begin // Prefetch the y values
          y_write_reg_index_d = (y_write_reg_index_q == REG_PER_CE - 2) ? 'b0 : y_write_reg_index_q + 2;
          y_write_row_index_d = (y_write_reg_index_q == REG_PER_CE - 2) ? (y_write_row_index_q == Height-1) ? 'b0: y_write_row_index_q + 1 : y_write_row_index_q;
          prefetched_d        = (y_write_row_index_q == Height - 1 && y_write_reg_index_q == REG_PER_CE - 2) ?  1'b1 : prefetched_q;
        end
        accumulation_reg_y_ready_o = 1'b1;
        external_loading           = 1'b1;
        y_bias_selector            = 1'b1;
        in_ready_o                 = 1'b1;
      end
    // -------------------------------------------------------------------------------------------------------------------------------------
      ACC_Y_READ_ENGINE_RUNNING: begin
        if (y_in_valid_i && prefetched_q == 1'b0) begin // Prefetch the y values
          y_write_reg_index_d = (y_write_reg_index_q == REG_PER_CE - 2) ? 'b0 : y_write_reg_index_q + 2;
          y_write_row_index_d = (y_write_reg_index_q == REG_PER_CE - 2) ? (y_write_row_index_q == Height-1) ? 'b0: y_write_row_index_q + 1 : y_write_row_index_q;
          prefetched_d        = (y_write_row_index_q == Height - 1 && y_write_reg_index_q == REG_PER_CE - 2) ?  1'b1 : prefetched_q;
        end
        if (in_valid_i) begin // This has to happen after the prefetched y is loaded
          inner_loop_counter_d = (inner_loop_counter_q == (cntrl_engine_i.inner_loop_count - 1)) ? 'b0 : inner_loop_counter_q + 1;
          change_state = inner_loop_counter_q == (cntrl_engine_i.inner_loop_count - 1 );
        end
        if (prefetched_q == 1'b1 && acc_state_current == ACC_Y_READ_ENGINE_RUNNING && acc_state_next == ACC_Z_RELOAD_Y_ENGINE) prefetched_d = 1'b0; // Reloaded value completed
        accumulation_reg_y_ready_o = ~(prefetched_q ); //~change_state;
        in_ready_o                 = 1'b1;
        external_loading           = ~(prefetched_q );
      end
    // -------------------------------------------------------------------------------------------------------------------------------------
      ACC_ENGINE_RUNNING: begin
        if (in_valid_i) begin 
          inner_loop_counter_d = (inner_loop_counter_q == (cntrl_engine_i.inner_loop_count - 1)) ? 'b0 : inner_loop_counter_q + 1;
          change_state = inner_loop_counter_q == (cntrl_engine_i.inner_loop_count - 1 );
        end
        in_ready_o                 = 1'b1;
      end
    // -------------------------------------------------------------------------------------------------------------------------------------
      ACC_Z_RELOAD_Y_ENGINE: begin // Storing the z values to acc, reload the y values to the engine
        if (in_valid_i) inner_loop_counter_d = (inner_loop_counter_q == (cntrl_engine_i.inner_loop_count - 1)) ? 'b0 : inner_loop_counter_q + 1; // NOTE: should never 0 here
        if (engine_to_reg_out_valid[0][0]) begin
          z_read_reg_index_d    = (z_read_reg_index_q == REG_PER_CE - 1) ? 'b0: z_read_reg_index_q + 1;
          reg_write_to_engine_d = (reg_write_to_engine_q == REG_PER_CE - 1) ? 'b0: reg_write_to_engine_q + 1; 
          change_state = (z_read_reg_index_q == REG_PER_CE - 1);
        end
        acc_input_selector         = 1'b1;
        y_bias_selector            = 1'b1;
        in_ready_o                 = 1'b1;
      end
    // -------------------------------------------------------------------------------------------------------------------------------------
      ACC_Z_RELOAD: begin // Storing the z values to acc
        if (engine_to_reg_out_valid[0][0]) begin
          z_read_reg_index_d    = (z_read_reg_index_q == REG_PER_CE - 1) ? 'b0: z_read_reg_index_q + 1;
          reg_write_to_engine_d = (reg_write_to_engine_q == REG_PER_CE - 1) ? 'b0: reg_write_to_engine_q + 1; 
          change_state = (z_read_reg_index_q == REG_PER_CE - 1);
        end
        acc_input_selector         = 1'b1;
        done_d                     = 1'b1;
      end
    // -------------------------------------------------------------------------------------------------------------------------------------
      ACC_Z_STORE: begin // Stream out the z values to the memory
        out_valid_o = 1'b1;
        in_ready_o  = 1'b1;
        if (in_valid_i) inner_loop_counter_d = (inner_loop_counter_q == (cntrl_engine_i.inner_loop_count - 1)) ? 'b0 : inner_loop_counter_q + 1; // NOTE: should never 0 here
        if (out_ready_i) begin
          z_read_reg_index_d = (z_read_reg_index_q == REG_PER_CE - 2) ? 'b0: z_read_reg_index_q + 2;
          z_read_row_index_d = (z_read_reg_index_q == REG_PER_CE - 2) ? (z_read_row_index_q == Height - 1) ? 'b0: z_read_row_index_q + 1: z_read_row_index_q;
          change_state       = (z_read_row_index_q == Height - 1 && z_read_reg_index_q == REG_PER_CE - 2); // This need to change
        end
        // if (change_state && done_q) begin
        //   done_d                = '0;
        //   y_write_reg_index_d   = '0;
        //   y_write_row_index_d   = '0;
        //   z_read_reg_index_d    = '0;
        //   inner_loop_counter_d  = '0;
        //   reg_write_to_engine_d = '0;
        //   prefetched_d          = '0;
        // end
      end
    // -------------------------------------------------------------------------------------------------------------------------------------
    endcase
  end

  always_ff @(posedge clk_i or negedge rst_ni) begin : seq_block
    if (~rst_ni) begin
      acc_state_current     <= ACC_IDLE;
      y_write_reg_index_q   <= '0;
      y_write_row_index_q   <= '0;
      inner_loop_counter_q  <= '0;
      reg_write_to_engine_q <= '0;
      z_read_reg_index_q    <= '0;
      z_read_row_index_q    <= '0;
      prefetched_q          <= '0;
      // last_iteration_q      <= '0;
      done_q                <= '0;
    end else begin
      acc_state_current     <= acc_state_next       ;
      y_write_reg_index_q   <= y_write_reg_index_d  ;
      y_write_row_index_q   <= y_write_row_index_d  ;
      inner_loop_counter_q  <= inner_loop_counter_d ;
      reg_write_to_engine_q <= reg_write_to_engine_d;
      z_read_reg_index_q    <= z_read_reg_index_d   ;
      z_read_row_index_q    <= z_read_row_index_d   ;
      prefetched_q          <= prefetched_d         ;
      // last_iteration_q      <= last_iteration_d     ;
      done_q                <= done_d               ;
    end
  end

  /*---------------------------------------------------------------*/
  /* |                      Writing Mutliplexer                  | */
  /*---------------------------------------------------------------*/
  
  logic [Height-1:0][Width-1:0]             acc_in_valid;
  logic [Height-1:0][Width-1:0][2*BITW-1:0] acc_in_data;
  logic [$clog2(REG_PER_CE)-1:0]            acc_write_index;

  always_comb begin 
    for (int row_index = 0; row_index < Height; row_index++) begin
      for (int col_index = 0; col_index < Width; col_index++) begin
        if (acc_input_selector) begin // Load from the engine
          acc_in_valid[row_index][col_index] = engine_to_reg_out_valid[row_index][col_index];
          acc_in_data[row_index][col_index]  = {engine_to_reg_output[row_index][col_index],engine_to_reg_output[row_index][col_index]};
          acc_write_index                    = reg_write_to_engine_q;
        end else begin // Load from external
          acc_in_valid[row_index][col_index] = y_in_valid_i && (row_index == y_write_row_index_q) && external_loading;
          acc_in_data[row_index][col_index]  = {y_bias_i[2*col_index+1],y_bias_i[2*col_index]};
          acc_write_index                    = y_write_reg_index_q;
        end
      end
    end
  end

  /*---------------------------------------------------------------*/
  /* |                      Reading Mutliplexer                  | */
  /*---------------------------------------------------------------*/

  always_comb begin
    for (int col_index = 0; col_index < Width; col_index++) begin
      z_output_o[2*col_index  ] = reg_out_data[z_read_row_index_q][col_index][  BITW-1:0   ];
      z_output_o[2*col_index+1] = reg_out_data[z_read_row_index_q][col_index][2*BITW-1:BITW];
    end
  end

  /*---------------------------------------------------------------*/
  /* |                    Accumulation Registers                 | */
  /*---------------------------------------------------------------*/
  
  generate
    for (genvar row_index = 0; row_index < Height; row_index++) begin: accumulation_reg_row
      for (genvar col_index = 0; col_index < Width; col_index++) begin: accumulation_reg_col
        accumulation_reg #(
          .DATA_WIDTH ( BITW          ),
          .DEPTH      ( REG_PER_CE    )
        ) i_acc_reg (
          .clk_i              ( clk_i                                                ),
          .rst_ni             ( rst_ni                                               ),
          .flush_i            ( 1'b0                                                 ),
          .iteration_change_i ( 1'b0                                                 ),     
          .input_i            ( acc_in_data[row_index][col_index]                    ),         
          .write_en_i         ( acc_in_valid[row_index][col_index]                   ),
          .write_index_i      ( acc_write_index                                      ),
          .external_loading   ( external_loading                                     ),
          .read_index_i       ( z_read_reg_index_q                                   ),
          .output_o           ( reg_out_data[row_index][col_index]                   )        
        );
      end
    end
  endgenerate

  /*---------------------------------------------------------------*/
  /* |                      Computing Elements                   | */
  /*---------------------------------------------------------------*/

  // ******** Compute Engine 2D array ********

  logic ce_clk_en;
  logic ce_clk;
  logic [H-1:0][W-1:0] busy;
  always_comb begin : clock_gating_selector
    ce_clk_en            = 1'b0;
    if (in_valid_i || busy[0][0]) ce_clk_en = 1'b1;
  end : clock_gating_selector
  
  tc_clk_gating ce_clock_gating (
    .clk_i      ( clk_i     ),
    .en_i       ( ce_clk_en ),
    .test_en_i  ( '0        ),
    .clk_o      ( ce_clk    )    
  );

  logic [H-1:0][W-1:0][2:0][BITW-1:0] ce_operands;
  logic [H-1:0][W-1:0]                ce_in_ready;
  logic [H-1:0][W-1:0][BITW-1:0]      acc_operand;
  logic same_fmt;

  always_comb begin 
    same_fmt         = (cntrl_engine_i.memory_format == cntrl_engine_i.computing_format)? 1'b1 : 1'b0;
    for (int row_index = 0; row_index < Height; row_index++) begin 
      for (int col_index = 0; col_index < Width; col_index++) begin 
        acc_operand[row_index][col_index]    = reg_out_data[row_index][col_index][z_read_reg_index_q[0]*BITW +: BITW];
        ce_operands[row_index][col_index][0] = x_input_i[row_index];
        ce_operands[row_index][col_index][1] = w_input_i[col_index];
        ce_operands[row_index][col_index][2] = (y_bias_selector) ? acc_operand[row_index][col_index]: engine_to_reg_output[row_index][col_index] ;
      end
    end
  end
  generate
    for(genvar row_index = 0; row_index < Height; row_index++) begin: ce_row
      for (genvar col_index = 0; col_index < Width; col_index++) begin: ce_col
      ope_ce   #(
        .FpFormat    ( FpFormat    ),
        .NumPipeRegs ( NumPipeRegs ),
        .PipeConfig  ( PipeConfig  ),
        .Stallable   ( Stallable   )
      ) i_ce (
        .clk_i              ( ce_clk                                          ),
        .rst_ni             ( rst_ni                                          ),
        .x_input_i          ( ce_operands[row_index][col_index][0]            ),
        .w_input_i          ( ce_operands[row_index][col_index][1]            ),
        .y_bias_i           ( ce_operands[row_index][col_index][2]            ),
        .fma_is_boxed_i     ( cntrl_engine_i.fma_is_boxed                     ),
        .noncomp_is_boxed_i ( 2'b11                                           ),
        .stage1_rnd_i       ( cntrl_engine_i.stage1_rnd                       ),
        .stage2_rnd_i       ( cntrl_engine_i.stage2_rnd                       ),
        .op1_i              ( cntrl_engine_i.op1                              ),
        .op2_i              ( cntrl_engine_i.op2                              ),
        .memory_fmt_i       ( cntrl_engine_i.memory_format                    ),
        .computing_fmt_i    ( cntrl_engine_i.computing_format                 ),
        .same_fmt_i         ( same_fmt                                        ),
        .op_mod_i           ( cntrl_engine_i.op_mod                           ),
        .tag_i              ( 1'b0                                            ),
        .aux_i              ( 1'b0                                            ),
        .in_valid_i         ( in_valid_i  && in_ready_o                       ), 
        .in_ready_o         (                                                 ),
        .reg_enable_i       ( reg_enable_i                                    ),
        .flush_i            ( 1'b0                                            ),
        .z_output_o         ( engine_to_reg_output[row_index][col_index]      ),
        .status_o           (                                                 ), // Not used 
        .extension_bit_o    (                                                 ), // Not used
        .class_mask_o       (                                                 ), // Not used
        .is_class_o         (                                                 ), // Not used
        .tag_o              (                                                 ), // Not used
        .aux_o              (                                                 ), // Not used
        .out_valid_o        ( engine_to_reg_out_valid[row_index][col_index]   ),
        .out_ready_i        ( 1'b1                                            ),
        .busy_o             ( busy[row_index][col_index]                      )  // Not used
      );
      end
    end
  endgenerate


endmodule 