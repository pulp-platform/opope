// Copyright 2025 ETH Zurich and University of Bologna.
// Solderpad Hardware License, Version 0.51, see LICENSE_HW for details.
// SPDX-License-Identifier: SHL-0.51
//
// Danilo Cammarata <dcammarata@iis.ee.ethz.ch>

`include "hci_helpers.svh"

module opope_top
  import fpnew_pkg::*;
  import opope_pkg::*;
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
  // Periph slave port for the controller side
  hwpe_ctrl_intf_periph.slave periph,
  // TCDM master ports for the memory side
  hci_outstanding_intf.initiator tcdm
);

localparam int unsigned DATAW_ALIGN = DATAW;

logic                       clear;
logic                       start_cfg, cfg_complete;

// Declaring the local periph
hwpe_ctrl_intf_periph #( .ID_WIDTH  (ID_WIDTH) ) local_periph ( .clk(clk_i) );

// Streamer control signals and flags
cntrl_streamer_t cntrl_streamer;
flgs_streamer_t  flgs_streamer;

cntrl_engine_t   cntrl_engine;

// FSM control signals and flags
flgs_scheduler_t  flgs_scheduler;

// Register file binded from controller to FSM


logic mask_y, mask_z, mask_y_source;
logic y_ready,z_valid;
logic z_ready;
logic ce_clk_en;

logic in_ready;
logic y_valid;
logic [DATAW/8    -1:0] z_be;
logic in_valid;
logic [DATAW/2 - 1: 0] x_data, w_data;
logic [DATAW   - 1: 0] y_data, z_data;

hwpe_stream_intf_stream #( .DATA_WIDTH ( DATAW_ALIGN ) ) x_buffer         ( .clk( clk_i ) );
hwpe_stream_intf_stream #( .DATA_WIDTH ( DATAW_ALIGN ) ) w_buffer         ( .clk( clk_i ) );
hwpe_stream_intf_stream #( .DATA_WIDTH ( DATAW_ALIGN ) ) y_buffer         ( .clk( clk_i ) );
hwpe_stream_intf_stream #( .DATA_WIDTH ( DATAW_ALIGN ) ) z_buffer         ( .clk( clk_i ) );

/*--------------------------------------------------------------*/
/* |                   Start Configuration                    | */
/*--------------------------------------------------------------*/

/* If there is no Xif we directly plug the
    control port into the hwpe-slave device */
assign start_cfg = ((periph.req) &&
                    (periph.add[7:0] == 'h54) &&
                    (!periph.wen) && (periph.gnt)) ? 1'b1 : 1'b0;

// Bind periph port to local one
assign local_periph.req  = periph.req;
assign local_periph.add  = periph.add;
assign local_periph.wen  = periph.wen;
assign local_periph.be   = periph.be;
assign local_periph.data = periph.data;
assign local_periph.id   = periph.id;
assign periph.gnt     = local_periph.gnt;
assign periph.r_data  = local_periph.r_data;
assign periph.r_valid = local_periph.r_valid;
assign periph.r_id    = local_periph.r_id;                    



/*--------------------------------------------------------------*/
/* |                         Streamer                         | */
/*--------------------------------------------------------------*/
/* The streamer will present a single master TCDM port used to  */
/* stream data to and from the memory.                          */

opope_outstanding_streamer #(
  .`HCI_SIZE_PARAM(tcdm) ( `HCI_SIZE_PARAM(tcdm) )
) i_streamer      (
  .clk_i           ( clk_i               ),
  .rst_ni          ( rst_ni              ),
  .test_mode_i     ( test_mode_i         ),
  // Controller generated signals
  .enable_i        ( 1'b1                ),
  .clear_i         ( clear               ),
  .mask_y_i        ( mask_y_source       ),
  // Source interfaces for the incoming streams
  .x_stream_o      ( x_buffer            ),
  .w_stream_o      ( w_buffer            ),
  .y_stream_o      ( y_buffer            ),
  // Sink interface for the outgoing stream
  .z_stream_i      ( z_buffer            ),
  // Master TCDM interface ports for the memory side
  .tcdm            ( tcdm                ),  
  .ctrl_i          ( cntrl_streamer      ),
  .flags_o         ( flgs_streamer       )
);


/*---------------------------------------------------------------*/
/* |                       Input Buffers                       | */
/*---------------------------------------------------------------*/

opope_buffers #(
  .DATA_WIDTH       (DATAW),
  .DEPTH            (W_REGBUFFER_DEPTH)
) i_buffers (
  .clk_i       ( clk_i         ),
  .rst_ni      ( rst_ni        ),
  .clear_i     ( clear         ),
  
  // From/To Streamer 
  .x_stream_i  ( x_buffer      ),
  .w_stream_i  ( w_buffer      ),
  .y_stream_i  ( y_buffer      ),
  .z_stream_o  ( z_buffer      ),

  // Engine
  .in_ready_i  ( in_ready      ),
  .in_valid_o  ( in_valid      ),
  .x_data_o    ( x_data        ),
  .w_data_o    ( w_data        ),

  .y_ready_i   ( y_ready       ),
  .mask_y_i    ( mask_y        ),
  .y_valid_o   ( y_valid       ),
  .y_data_o    ( y_data        ),

  .z_be_i      ( z_be          ),
  .z_ready_o   ( z_ready       ),
  .mask_z_i    ( mask_z        ),
  .z_valid_i   ( z_valid       ),
  .z_data_i    ( z_data        ) 
);

/*---------------------------------------------------------------*/
/* |                          Engine                           | */
/*---------------------------------------------------------------*/

// Engine instance
opope_engine     #(
  .FpFormat        ( FpFormat),
  .Height          ( Height        ),
  .Width           ( Width         ),
  .NumPipeRegs     ( NumPipeRegs   ),
  .PipeConfig      ( PipeConfig    )
) i_engine (
  .clk_i              ( clk_i        ),
  .rst_ni             ( rst_ni       ),
  .clk_en_i           (ce_clk_en     ),
  .x_input_i          ( x_data       ),
  .w_input_i          ( w_data       ),
  .y_bias_i           ( y_data       ),
  .z_output_o         ( z_data       ),
  .cntrl_engine_i     ( cntrl_engine ) 
);

/*---------------------------------------------------------------*/
/* |                        Controller                         | */
/*---------------------------------------------------------------*/

opope_ctrl        #(
  .N_CORES            ( N_CORES        ),
  .IO_REGS            ( OPOPE_REGS     ),
  .ID_WIDTH           ( ID_WIDTH       ),
  .N_CONTEXT          ( NumContext     ),
  .Height             ( Height         ),
  .Width              ( Width          )
) i_control           (
  .clk_i              ( clk_i          ),
  .rst_ni             ( rst_ni         ),
  .busy_o             ( busy_o         ),
  .clear_o            ( clear          ),
  .evt_o              ( evt_o          ),
  .start_cfg_i        ( start_cfg      ),
  .cfg_complete_o     ( cfg_complete   ),
  .periph             ( local_periph   ),

  // Buffers
  .mask_y_o           ( mask_y         ),
  .mask_z_o           ( mask_z         ),
  .in_valid_i         ( in_valid       ),
  .in_ready_o         ( in_ready       ),
  .y_in_valid_i       ( y_valid        ),
  .y_ready_o          ( y_ready        ),
  .out_valid_o        ( z_valid        ),
  .out_ready_i        ( z_ready        ),
  .z_be_o             ( z_be           ),
  
  // Engine
  .cntrl_engine_o     ( cntrl_engine   ),
  .ce_clk_en_o        ( ce_clk_en      ),
  
  // Streamer
  .flgs_streamer_i    ( flgs_streamer  ),
  .cntrl_streamer_o   ( cntrl_streamer ),
  .mask_y_source_o    ( mask_y_source  )
);


endmodule : opope_top
