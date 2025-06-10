// Copyright 2023 ETH Zurich and University of Bologna.
// Solderpad Hardware License, Version 0.51, see LICENSE for details.
// SPDX-License-Identifier: SHL-0.51
//
// Yvan Tortorella <yvan.tortorella@unibo.it>
// George Pagonis  <gpagonis@student.ethz.ch>

`include "hci_helpers.svh"

module ope_top
  import fpnew_pkg::*;
  import ope_pkg::*;
  import hci_package::*;
  import hwpe_ctrl_package::*;
  import hwpe_stream_package::*;
#(
  parameter int unsigned  ID_WIDTH           = 8                 ,
  parameter int unsigned  N_CORES            = 8                 ,
  parameter int unsigned  DW                 = DATA_W            , // TCDM port dimension (in bits)
  parameter int unsigned  UW                 = 1                 ,
  parameter int unsigned  X_EXT              = 0                 ,
  parameter int unsigned  SysInstWidth       = 32                ,
  parameter int unsigned  SysDataWidth       = 32                ,
  parameter int unsigned  NumContext         = N_CONTEXT         , // Number of sequential jobs for the slave device
  parameter fp_format_e   FpFormat           = FPFORMAT          , // Data format (default is FP16)
  parameter int unsigned  Height             = ARRAY_HEIGHT      , // Number of PEs within a row
  parameter int unsigned  Width              = ARRAY_WIDTH       , // Number of parallel rows
  parameter int unsigned  NumPipeRegs        = PIPE_REGS         , // Number of pipeline registers within each PE
  parameter pipe_config_t PipeConfig         = DISTRIBUTED       ,
  parameter int unsigned  BITW               = fp_width(FpFormat),  // Number of bits for the given format
  parameter hci_size_parameter_t `HCI_SIZE_PARAM(tcdm) = '0
)(
  input  logic                    clk_i      ,
  input  logic                    rst_ni     ,
  input  logic                    test_mode_i,
  output logic                    busy_o     ,
  output logic [N_CORES-1:0][1:0] evt_o      ,
`ifdef TARGET_REDMULE_COMPLEX
  cv32e40x_if_xif.coproc_issue    xif_issue_if_i,
  cv32e40x_if_xif.coproc_result   xif_result_if_o,
  cv32e40x_if_xif.coproc_compressed xif_compressed_if_i,
  cv32e40x_if_xif.coproc_mem        xif_mem_if_o,
`elsif TARGET_REDMULE_HWPE
  // Periph slave port for the controller side
  hwpe_ctrl_intf_periph.slave periph,
`endif
  // output cntrl_scheduler_t        debug_cntrl_scheduler_o,
  // TCDM master ports for the memory side
  hci_core_intf.initiator tcdm
);

localparam int unsigned DATAW_ALIGN = DATAW;

logic                       enable, clear;
logic                       reg_enable;
logic                       start_cfg, cfg_complete;

`ifdef TARGET_REDMULE_HWPE
  /* If there is no Xif we directly plug the
     control port into the hwpe-slave device */
  assign start_cfg = ((periph.req) &&
                      (periph.add[7:0] == 'h54) &&
                      (!periph.wen) && (periph.gnt)) ? 1'b1 : 1'b0;

`elsif TARGET_REDMULE_COMPLEX
  hwpe_ctrl_intf_periph #( .ID_WIDTH  (ID_WIDTH) ) periph ( .clk(clk_i) );
  /* If there is the Xif, we pass through the
     instruction decoder and then enter into
     the hwpe slave device */
  logic [SysDataWidth-1:0] cfg_reg;
  logic [SysDataWidth-1:0] sizem, sizen, sizek;
  logic [SysDataWidth-1:0] x_addr, w_addr, y_addr, z_addr;

  ope_inst_decoder #(
    .SysInstWidth       ( SysInstWidth       ),
    .SysDataWidth       ( SysDataWidth       ),
    .NumRfReadPrts      ( 3                  ) // FIXME: parametric
  ) i_inst_decoder      (
    .clk_i               ( clk_i               ),
    .rst_ni              ( rst_ni              ),
    .clear_i             ( clear               ),
    .xif_issue_if_i      ( xif_issue_if_i      ),
    .xif_result_if_o     ( xif_result_if_o     ),
    .xif_compressed_if_i ( xif_compressed_if_i ),
    .xif_mem_if_o        ( xif_mem_if_o        ),
    .periph              ( periph              ),
    .cfg_complete_i      ( cfg_complete        ),
    .start_cfg_o         ( start_cfg           )
  );

`endif

// Streamer control signals and flags
cntrl_streamer_t cntrl_streamer;
flgs_streamer_t  flgs_streamer;
// flgs_streamer_t  flgs_streamer_x_w;
// flgs_streamer_t  flgs_streamer_y_z;

cntrl_engine_t   cntrl_engine;

// Wrapper control signals and flags
// Input feature map
x_buffer_ctrl_t x_buffer_ctrl;
x_buffer_flgs_t x_buffer_flgs;

// Weights
w_buffer_ctrl_t w_buffer_ctrl;
w_buffer_flgs_t w_buffer_flgs;

// Output feature map
z_buffer_ctrl_t z_buffer_ctrl;
z_buffer_flgs_t z_buffer_flgs;

// FSM control signals and flags
cntrl_scheduler_t cntrl_scheduler;
flgs_scheduler_t  flgs_scheduler;

// Register file binded from controller to FSM
ctrl_regfile_t reg_file;
flags_fifo_t   w_fifo_flgs;

x_regbuffer_ctrl_t x_regbuffer_ctrl;


logic memory_scheduler_done;
logic memory_scheduler_next_iteration;

logic mask_streamer, mask_z;
logic x_ready,w_ready,y_ready,z_valid;
logic last_iteration_d,last_iteration_q;

/*--------------------------------------------------------------*/
/* |                         Streamer                         | */
/*--------------------------------------------------------------*/

// Implementation of the incoming and outgoing streaming interfaces (one for each kind of data)

// X streaming interface + X FIFO interface
hwpe_stream_intf_stream #( .DATA_WIDTH ( DATAW_ALIGN ) ) x_buffer_d         ( .clk( clk_i ) );
hwpe_stream_intf_stream #( .DATA_WIDTH ( DATAW_ALIGN ) ) x_buffer_fifo      ( .clk( clk_i ) );

// W streaming interface + W FIFO interface
hwpe_stream_intf_stream #( .DATA_WIDTH ( DATAW_ALIGN ) ) w_buffer_d         ( .clk( clk_i ) );
hwpe_stream_intf_stream #( .DATA_WIDTH ( DATAW_ALIGN ) ) w_buffer_fifo      ( .clk( clk_i ) );

// Y streaming interface + Y FIFO interface
hwpe_stream_intf_stream #( .DATA_WIDTH ( DATAW_ALIGN ) ) y_buffer_d         ( .clk( clk_i ) );
hwpe_stream_intf_stream #( .DATA_WIDTH ( DATAW_ALIGN ) ) y_buffer_fifo      ( .clk( clk_i ) );

// Z streaming interface + Z FIFO interface
hwpe_stream_intf_stream #( .DATA_WIDTH ( DATAW_ALIGN ) ) z_buffer_q         ( .clk( clk_i ) );
hwpe_stream_intf_stream #( .DATA_WIDTH ( DATAW_ALIGN ) ) z_buffer_d         ( .clk( clk_i ) );
hwpe_stream_intf_stream #( .DATA_WIDTH ( DATAW_ALIGN ) ) z_buffer_fifo      ( .clk( clk_i ) );


logic w_granted, x_granted;
logic [NumStreamSources-1:0][$clog2(NumStreamSources)-1:0] custom_priority;
logic custom_priority_force;

// The streamer will present a single master TCDM port used to stream data to and from the memeory.
ope_streamer #(
  .DW             ( DW                           ),
  .`HCI_SIZE_PARAM(tcdm) ( `HCI_SIZE_PARAM(tcdm) )
) i_streamer      (
  .clk_i                    ( clk_i                 ),
  .rst_ni                   ( rst_ni                ),
  .test_mode_i              ( test_mode_i           ),
  // Controller generated signals
  .enable_i                 ( 1'b1                  ),
  .clear_i                  ( clear                 ),
  // Source interfaces for the incoming streams
  .x_stream_o               ( x_buffer_d            ),
  .w_stream_o               ( w_buffer_d            ),
  .y_stream_o               ( y_buffer_d            ),
  // Sink interface for the outgoing stream
  .z_stream_i               ( z_buffer_q),
  // Master TCDM interface ports for the memory side
  .tcdm                     ( tcdm                  ),
  .custom_priority_force_i  ( custom_priority_force ),
  .custom_priority_i        ( custom_priority       ),
  .x_granted_o              ( x_granted             ),
  .w_granted_o              ( w_granted             ),
  .y_granted_o              ( y_granted             ),
  .z_granted_o              ( z_granted             ),

  .ctrl_i                   ( cntrl_streamer        ),
  .flags_o                  ( flgs_streamer         )
);


/*---------------------------------------------------------------*/
/* |                      INPUT_REGISTERS                      | */
/*---------------------------------------------------------------*/

// NOTE: consider a out_ready_i signal to synchronize everything
// Right now, it is not needed

logic not_empty_x_reg, not_empty_w_reg;
logic start_register_reading_q, start_register_reading_d;

assign start_register_reading_d = not_empty_x_reg && not_empty_w_reg;

logic reg_to_engine_valid;
logic x_reg_to_engine_valid, w_reg_to_engine_valid;
logic [DATAW/2 - 1: 0] x_reg_to_engine_data, w_reg_to_engine_data;
logic [DATAW-1:0] x_buffer_additional_reg_d,x_buffer_additional_reg_q;
logic x_buffer_additional_reg_ready,x_buffer_additional_reg_valid_d,x_buffer_additional_reg_valid_q;


assign reg_to_engine_valid = x_reg_to_engine_valid && w_reg_to_engine_valid;

reg_array_io_wrapper #(
  .READING_POLICY   ( ope_pkg::SERIALLY ),
  .DATA_WIDTH       (DATAW),
  .DEPTH            (X_REGBUFFER_DEPTH)
) i_x_reg_array_wrapper(
  .clk_i              ( clk_i                       ),
  .rst_ni             ( rst_ni                      ),
  .clear_i            ( clear                       ),
  .iteration_change_i (memory_scheduler_next_iteration),
  .ready_i            (in_ready  ),
  .data_i             ( x_buffer_d.data          ),
  .valid_i            ( x_buffer_d.valid         ),
  .ready_o            ( x_ready                  ),
  .data_o             ( x_reg_to_engine_data),
  .valid_o            (x_reg_to_engine_valid),
  .not_empty_o        ( not_empty_x_reg)
);

reg_array_io_wrapper #(
  .READING_POLICY   ( ope_pkg::INTERLEAVED ),
  .DATA_WIDTH       (DATAW),
  .DEPTH            (W_REGBUFFER_DEPTH)
) i_w_reg_array_wrapper(
  .clk_i              ( clk_i                       ),
  .rst_ni             ( rst_ni                      ),
  .clear_i            ( clear                       ),
  .iteration_change_i (memory_scheduler_next_iteration),
  .ready_i            ( in_ready                   ), // When both the x and w buffer are not empty
  .data_i             ( w_buffer_d.data          ),
  .valid_i            ( w_buffer_d.valid         ),
  .ready_o            ( w_ready         ),
  .data_o             (w_reg_to_engine_data                ),
  .valid_o            (w_reg_to_engine_valid),
  .not_empty_o        ( not_empty_w_reg       )     
);
assign w_buffer_d.ready = w_ready; //&~ mask_streamer;
assign x_buffer_d.ready = x_ready; // &~ mask_streamer;



  always_ff @(posedge clk_i or negedge rst_ni) begin
    if (!rst_ni) begin
      last_iteration_q <= '0;
    end else begin
      last_iteration_q <= last_iteration_d;
    end
  end

  assign last_iteration_d = cntrl_scheduler.finished ? '0 : flgs_streamer.y_stream_source_flags.done | last_iteration_q;

/*---------------------------------------------------------------*/
/* |                          Engine                           | */
/*---------------------------------------------------------------*/
cntrl_engine_t ctrl_engine;
flgs_engine_t  flgs_engine;

// Engine signals
// Control signal for successive accumulations
logic                               accumulate;
// fpnew_fma Input Signals
logic                         [2:0] fma_is_boxed;
logic                         [1:0] noncomp_is_boxed;
roundmode_e                         stage1_rnd,
                                    stage2_rnd;
operation_e                         op1, op2;
fpu_fmt_e                           memory_fmt, computing_fmt;
logic                               same_fmt;
logic                               op_mod;
logic                               in_tag;
logic                               in_aux;
// fpnew_fma Input Handshake
logic                               in_valid;
logic       [Width-1:0][Height-1:0] in_ready;

logic                               flush;
// fpnew_fma Output signals
status_t    [Width-1:0][Height-1:0] status;
logic       [Width-1:0][Height-1:0] extension_bit;
classmask_e [Width-1:0][Height-1:0] class_mask;
logic       [Width-1:0][Height-1:0] is_class;
logic       [Width-1:0][Height-1:0] out_tag;
logic       [Width-1:0][Height-1:0] out_aux;
// fpnew_fma Output handshake
logic       [Width-1:0][Height-1:0] out_valid;
logic                               out_ready;
// fpnew_fma Indication of valid data in flight
logic        busy;

// Binding from engine interface types to cntrl_engine_t and
assign fma_is_boxed     = cntrl_engine.fma_is_boxed;
assign noncomp_is_boxed = cntrl_engine.noncomp_is_boxed;
assign stage1_rnd       = cntrl_engine.stage1_rnd;
assign stage2_rnd       = cntrl_engine.stage2_rnd;
assign op1              = cntrl_engine.op1;
assign op2              = cntrl_engine.op2;

assign memory_fmt       = cntrl_engine.memory_format;
assign computing_fmt    = cntrl_engine.computing_format;
assign same_fmt         = (cntrl_engine.memory_format == cntrl_engine.computing_format)? 1'b1 : 1'b0;

assign op_mod           = cntrl_engine.op_mod;
assign in_tag           = 1'b0;
assign in_aux           = 1'b0;
assign in_valid         = cntrl_engine.in_valid;
assign flush            = cntrl_engine.flush | clear;
assign out_ready        = cntrl_engine.out_ready;
always_comb begin
  for (int w = 0; w < Width; w++) begin
    for (int h = 0; h < Height; h++) begin
      flgs_engine.in_ready      [w][h] = in_ready      [w][h];
      flgs_engine.status        [w][h] = status        [w][h];
      flgs_engine.extension_bit [w][h] = extension_bit [w][h];
      flgs_engine.out_valid     [w][h] = out_valid     [w][h];
    end
  end
end

logic priority_enforcer_enable;
assign reg_enable = priority_enforcer_enable;
logic engine_out_valid;
logic [2*Width-1:0][BITW-1:0] engine_out_data;
logic accumulation_reg_full_first;
logic single_iteration;
// Engine instance
ope_engine     #(
  .FpFormat        ( FpFormat),
  .Height          ( Height        ),
  .Width           ( Width         ),
  .NumPipeRegs     ( NumPipeRegs   ),
  .PipeConfig      ( PipeConfig    )
) i_ope_engine (
  .clk_i              ( clk_i            ),
  .rst_ni             ( rst_ni           ),
  .x_input_i          ( x_reg_to_engine_data       ),
  .w_input_i          ( w_reg_to_engine_data       ),
  .y_bias_i           ( y_buffer_d.data),
  .z_output_o         (z_buffer_q.data),
   
   // From controller
  .fma_is_boxed_i     ( fma_is_boxed     ),
  .noncomp_is_boxed_i ( noncomp_is_boxed ),
  .stage1_rnd_i       ( stage1_rnd       ),
  .stage2_rnd_i       ( stage2_rnd       ),
  .op1_i              ( op1              ),
  .op2_i              ( op2              ),
  .memory_fmt_i       ( memory_fmt       ),
  .computing_fmt_i    ( computing_fmt    ),
  .same_fmt_i         ( same_fmt         ),
  .op_mod_i           ( op_mod           ),
  .tag_i              ( in_tag           ),
  .aux_i              ( in_aux           ),
  .reg_enable_i       ( reg_enable       ),

  // From reg_io_wrapper
  .in_valid_i         ( reg_to_engine_valid         ),
  .y_in_valid_i       ( y_buffer_d.valid & y_buffer_d.ready),
  .in_ready_o         ( in_ready         ),

  // Memory Scheduler
  .iteration_change_i (memory_scheduler_next_iteration),
  .single_iteration_i ( single_iteration   ),
  .status_o           ( status           ),
  .extension_bit_o    ( extension_bit    ),
  .class_mask_o       ( class_mask       ),
  .is_class_o         ( is_class         ),
  .tag_o              ( out_tag          ),
  .aux_o              ( out_aux          ),
  .out_valid_o        ( z_valid),
  .out_ready_i        ( z_buffer_q.ready &~ mask_z),
  .accumulation_reg_y_ready_o (y_ready),
  .accumulation_reg_full_first_o (accumulation_reg_full_first),
  .last_iteration_i   ( last_iteration_q ),
  .start_i             (cntrl_scheduler.start_load_x),
  .busy_o             ( busy             ),
  .cntrl_engine_i     ( cntrl_engine     ) // Only inner loop count is used from this!
);
assign y_buffer_d.ready = y_ready &~ mask_streamer;
assign engine_out_valid = z_buffer_d.valid;
/*---------------------------------------------------------------*/
/* |                    Memory Controller                      | */
/*---------------------------------------------------------------*/

ope_memory_scheduler #(
  .W  (Width),
  .H  (Height)
) i_memory_scheduler (
  .clk_i             ( clk_i               ),
  .rst_ni            ( rst_ni              ),
  .clear_i           ( clear               ),
  .reg_file_i        ( reg_file            ),
  .flgs_streamer_i   ( flgs_streamer       ),
  .cntrl_scheduler_i ( cntrl_scheduler     ),
  .done_o            ( memory_scheduler_done ),
  .next_iteration_o   ( memory_scheduler_next_iteration ),
  .single_iteration_o ( single_iteration   ),
  .cntrl_streamer_o  ( cntrl_streamer      )
);



logic system_busy; 

assign system_busy = busy || not_empty_x_reg || not_empty_w_reg;

/*---------------------------------------------------------------*/
/* |                        Controller                         | */
/*---------------------------------------------------------------*/

logic start_computing;
ope_ctrl        #(
  .N_CORES            ( N_CORES                 ),
  .IO_REGS            ( REDMULE_REGS            ),
  .ID_WIDTH           ( ID_WIDTH                ),
  .N_CONTEXT          ( NumContext              ),
  .SysDataWidth       ( SysDataWidth            ),
  .Height             ( Height                  ),
  .Width              ( Width                   ),
  .NumPipeRegs        ( NumPipeRegs             )
) i_control           (
  .clk_i              ( clk_i                   ),
  .rst_ni             ( rst_ni                  ),
  .test_mode_i        ( test_mode_i             ),
  .flgs_streamer_i    ( flgs_streamer           ),
  .system_busy_i      ( system_busy             ),
  .busy_o             ( busy_o                  ),
  .clear_o            ( clear                   ),
  .evt_o              ( evt_o                   ),
  .reg_file_o         ( reg_file                ),
  .start_cfg_i        ( start_cfg               ),
  .cfg_complete_o     ( cfg_complete            ),
  .w_loaded_i         ( flgs_scheduler.w_loaded ),
  .memory_scheduler_done_i ( memory_scheduler_done   ),
  .memory_scheduler_next_iteration_i ( memory_scheduler_next_iteration ),
  .accumulation_reg_full_first_i (start_computing),
  .priority_enforcer_enable_o (priority_enforcer_enable),
  .cntrl_scheduler_o  ( cntrl_scheduler         ),
  .x_regbuffer_ctrl_o ( x_regbuffer_ctrl        ),
  .cntrl_engine_o     ( cntrl_engine            ),
  .periph             ( periph                  )
);

priority_enforcer i_priority_enforcer (
  .clk_i                   ( clk_i                    ),
  .rst_ni                  ( rst_ni                   ),
  .enable_i                ( priority_enforcer_enable ),
  .x_granted_i             ( x_granted                ),
  .w_granted_i             ( w_granted                ),
  .y_granted_i             ( y_granted                ),
  .z_valid_i               ( z_valid         ),
  .last_iteration_i        ( last_iteration_q ),
  .custom_priority_force_o ( custom_priority_force    ),
  .start_computing_o       ( start_computing          ),
  .mask_streamer_o         ( mask_streamer            ),
  .mask_z_o                ( mask_z                   ),
  .custom_priority_o       ( custom_priority          )
);


  assign z_buffer_d.data = engine_out_data;
  assign z_buffer_q.strb = {{DATAW_ALIGN/8{1'b1}}};

  assign z_buffer_q.valid = z_valid &~ mask_z;

endmodule : ope_top
