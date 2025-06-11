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

logic                       clear;
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

cntrl_engine_t   cntrl_engine;

// FSM control signals and flags
cntrl_scheduler_t cntrl_scheduler;
flgs_scheduler_t  flgs_scheduler;

// Register file binded from controller to FSM


logic mask_streamer, mask_z;
logic x_ready,w_ready,y_ready,z_valid;
logic last_iteration_d,last_iteration_q;

logic w_granted, x_granted;
logic [NumStreamSources-1:0][$clog2(NumStreamSources)-1:0] custom_priority;
logic custom_priority_force;

/*--------------------------------------------------------------*/
/* |                         Streamer                         | */
/*--------------------------------------------------------------*/

// Implementation of the incoming and outgoing streaming interfaces (one for each kind of data)

// X streaming interface
hwpe_stream_intf_stream #( .DATA_WIDTH ( DATAW_ALIGN ) ) x_buffer_d         ( .clk( clk_i ) );

// W streaming interface
hwpe_stream_intf_stream #( .DATA_WIDTH ( DATAW_ALIGN ) ) w_buffer_d         ( .clk( clk_i ) );

// Y streaming interface
hwpe_stream_intf_stream #( .DATA_WIDTH ( DATAW_ALIGN ) ) y_buffer_d         ( .clk( clk_i ) );

// Z streaming interface
hwpe_stream_intf_stream #( .DATA_WIDTH ( DATAW_ALIGN ) ) z_buffer_q         ( .clk( clk_i ) );


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


logic reg_to_engine_valid;
logic x_reg_to_engine_valid, w_reg_to_engine_valid;
logic [DATAW/2 - 1: 0] x_reg_to_engine_data, w_reg_to_engine_data;


assign reg_to_engine_valid = x_reg_to_engine_valid && w_reg_to_engine_valid;

reg_array_io_wrapper #(
  .READING_POLICY   ( ope_pkg::SERIALLY ),
  .DATA_WIDTH       (DATAW),
  .DEPTH            (X_REGBUFFER_DEPTH)
) i_x_reg_array_wrapper(
  .clk_i              ( clk_i                       ),
  .rst_ni             ( rst_ni                      ),
  .clear_i            ( clear                       ),
  .iteration_change_i (1'b0),
  .ready_i            (in_ready  ),
  .data_i             ( x_buffer_d.data          ),
  .valid_i            ( x_buffer_d.valid         ),
  .ready_o            ( x_ready                  ),
  .data_o             ( x_reg_to_engine_data),
  .valid_o            (x_reg_to_engine_valid),
  .not_empty_o        ( )
);

reg_array_io_wrapper #(
  .READING_POLICY   ( ope_pkg::INTERLEAVED ),
  .DATA_WIDTH       (DATAW),
  .DEPTH            (W_REGBUFFER_DEPTH)
) i_w_reg_array_wrapper(
  .clk_i              ( clk_i                       ),
  .rst_ni             ( rst_ni                      ),
  .clear_i            ( clear                       ),
  .iteration_change_i (1'b0),
  .ready_i            ( in_ready                   ), // When both the x and w buffer are not empty
  .data_i             ( w_buffer_d.data          ),
  .valid_i            ( w_buffer_d.valid         ),
  .ready_o            ( w_ready         ),
  .data_o             (w_reg_to_engine_data                ),
  .valid_o            (w_reg_to_engine_valid),
  .not_empty_o        (        )     
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

// Engine signals
// Control signal for successive accumulations

logic [Width-1:0][Height-1:0]   in_ready;
logic [$clog2(REG_PER_CE)-1:0]  y_write_reg_index;
logic [$clog2(Height)-1:0]      y_write_row_index;
logic [$clog2(REG_PER_CE)-1:0]  z_read_reg_index;
logic [$clog2(Height)-1:0]      z_read_row_index;
logic [$clog2(REG_PER_CE)-1:0]  reg_write_to_engine;
logic y_bias_selector; 
logic acc_input_selector;
logic external_loading;

logic priority_enforcer_enable;



// logic ce_clk_en;
// logic ce_clk  ;
// tc_clk_gating ce_clock_gating (
//   .clk_i      ( clk_i     ),
//   .en_i       ( ce_clk_en ),
//   .test_en_i  ( '0        ),
//   .clk_o      ( ce_clk    )    
// );

// Engine instance
ope_engine     #(
  .FpFormat        ( FpFormat),
  .Height          ( Height        ),
  .Width           ( Width         ),
  .NumPipeRegs     ( NumPipeRegs   ),
  .PipeConfig      ( PipeConfig    )
) i_ope_engine (
  .clk_i              ( clk_i           ),
  .rst_ni             ( rst_ni           ),
  .x_input_i          ( x_reg_to_engine_data       ),
  .w_input_i          ( w_reg_to_engine_data       ),
  .y_bias_i           ( y_buffer_d.data),
  .z_output_o         (z_buffer_q.data),
   
   // From controller
  .reg_enable_i       ( priority_enforcer_enable ),
  .y_write_reg_index_i(y_write_reg_index),
  .y_write_row_index_i(y_write_row_index),
  .z_read_reg_index_i(z_read_reg_index),
  .z_read_row_index_i(z_read_row_index),
  .reg_write_to_engine_i(reg_write_to_engine),
  .y_bias_selector_i     (y_bias_selector),
  .acc_input_selector_i  (acc_input_selector),
  .external_loading_i    (external_loading),

  // From reg_io_wrapper
  .in_valid_i         ( reg_to_engine_valid         ),
  .y_in_valid_i       ( y_buffer_d.valid & y_buffer_d.ready),
  .in_ready_i         ( in_ready         ),

  // Memory Scheduler
  .cntrl_engine_i     ( cntrl_engine     ) // Only inner loop count is used from this!
);
assign y_buffer_d.ready = y_ready &~ mask_streamer;

/*---------------------------------------------------------------*/
/* |                        Controller                         | */
/*---------------------------------------------------------------*/

ope_ctrl        #(
  .N_CORES            ( N_CORES                 ),
  .IO_REGS            ( REDMULE_REGS            ),
  .ID_WIDTH           ( ID_WIDTH                ),
  .N_CONTEXT          ( NumContext              ),
  .SysDataWidth       ( SysDataWidth            ),
  .Height             ( Height                  ),
  .Width              ( Width                   ),
  .W  (Width),
  .H  (Height),
  .NumPipeRegs        ( NumPipeRegs             )
) i_control           (
  .clk_i              ( clk_i                   ),
  .rst_ni             ( rst_ni                  ),
  .busy_o             ( busy_o                  ),
  .clear_o            ( clear                   ),
  .evt_o              ( evt_o                   ),
  .start_cfg_i        ( start_cfg               ),
  .cfg_complete_o     ( cfg_complete            ),
  .priority_enforcer_enable_o (priority_enforcer_enable),
  .cntrl_scheduler_o  ( cntrl_scheduler         ),
  .cntrl_engine_o     ( cntrl_engine            ),
  .x_granted_i             ( x_granted                ),
  .w_granted_i             ( w_granted                ),
  .y_granted_i             ( y_granted                ),
  .z_valid_i               ( z_valid         ),
  .last_iteration_i        ( last_iteration_q ),
  .custom_priority_force_o ( custom_priority_force    ),
  .mask_streamer_o         ( mask_streamer            ),
  .mask_z_o                ( mask_z                   ),
  .custom_priority_o       ( custom_priority          ),
  .flgs_streamer_i   ( flgs_streamer       ),
  .cntrl_streamer_o  ( cntrl_streamer      ),

  .in_valid_i         ( reg_to_engine_valid         ),
  .y_in_valid_i       ( y_buffer_d.valid & y_buffer_d.ready),
  .out_ready_i        ( z_buffer_q.ready &~ mask_z),
  .accumulation_reg_y_ready_o (y_ready),
  .out_valid_o        ( z_valid),
  .in_ready_o         ( in_ready         ),
  .y_write_reg_index_o(y_write_reg_index),
  .y_write_row_index_o(y_write_row_index),
  .z_read_reg_index_o(z_read_reg_index),
  .z_read_row_index_o(z_read_row_index),
  .reg_write_to_engine_o(reg_write_to_engine),
  .y_bias_selector_o     (y_bias_selector),
  .acc_input_selector_o  (acc_input_selector),
  .external_loading_o    (external_loading),
  .ce_clk_en_o          (ce_clk_en),
  .periph             ( periph                  )
);

  assign z_buffer_q.strb = {{DATAW_ALIGN/8{1'b1}}};
  assign z_buffer_q.valid = z_valid &~ mask_z;

endmodule : ope_top
