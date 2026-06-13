// Copyright 2026 ETH Zurich and University of Bologna.
// Solderpad Hardware License, Version 0.51, see LICENSE_HW for details.
// SPDX-License-Identifier: SHL-0.51
//

`include "hci_helpers.svh"

module opope_outstanding_streamer
  import fpnew_pkg::*;
  import opope_pkg::*; 
  import hci_package::*;
  import hwpe_stream_package::*;
#(
  localparam int unsigned REALIGN = 0     ,
  parameter hci_size_parameter_t `HCI_SIZE_PARAM(tcdm) = '0
)(
  input logic                    clk_i,
  input logic                    rst_ni,
  input logic                    test_mode_i,
  input logic                    enable_i,
  input logic                    clear_i,
  input logic                    mask_y_i,
  // Engine X input + HS signals (output for the streamer)
  hwpe_stream_intf_stream.source x_stream_o,
  // Engine W input + HS signals (output for the streamer)
  hwpe_stream_intf_stream.source w_stream_o,
  // Engine Y input + HS signals (output for the streamer)
  hwpe_stream_intf_stream.source y_stream_o,
  // Engine Z output + HS signals (intput for the streamer)
  hwpe_stream_intf_stream.sink   z_stream_i,
  // TCDM interface between the streamer and the memory
  hci_outstanding_intf.initiator        tcdm,
  // Control signals
  input  cntrl_streamer_t        ctrl_i,
  output flgs_streamer_t         flags_o
);

localparam int unsigned DW  = `HCI_SIZE_GET_DW(tcdm);
localparam int unsigned UW  = `HCI_SIZE_GET_UW(tcdm);
localparam int unsigned IW  = `HCI_SIZE_GET_IW(tcdm);
localparam int unsigned EW  = `HCI_SIZE_GET_EW(tcdm);
localparam int unsigned EHW  = `HCI_SIZE_GET_EHW(tcdm);

// this localparam is reused for all internal, non-ecc HCI interfaces
localparam hci_size_parameter_t `HCI_SIZE_PARAM(ldst_tcdm) = '{
  DW:  DW,
  AW:  DEFAULT_AW,
  BW:  DEFAULT_BW,
  UW:  UW,
  IW:  IW,
  EW:  EW,
  EHW: EHW
};

// Virtual internal TCDM interface splitting the upstream TCDM
// X   -> virt_tcdm[0]
// W   -> virt_tcdm[1]
// Y   -> virt_tcdm[2]
// Z   -> virt_tcdm[3]
hci_outstanding_intf #(
  .DW ( DW ),
  .UW ( UW ),
  .IW ( IW ) ) virt_tcdm [0:NumStreamSources] ( .clk ( clk_i ) );
hci_outstanding_intf #(
  .DW ( DW ),
  .UW ( UW ),
  .IW ( IW ) ) virt_tcdm_rob [0:NumStreamSources] ( .clk ( clk_i ) );

localparam int unsigned ROB_NW = 1 << UW;

hci_outstanding_rob #(
	.ROB_NW ( ROB_NW ),
	.`HCI_SIZE_PARAM(out) ( `HCI_SIZE_PARAM(ldst_tcdm) )
) i_streamer_rob_x (
	.clk_i 	( clk_i 	),
	.rst_ni ( rst_ni 	),
	.in 	( virt_tcdm[0] ),
	.out 	( virt_tcdm_rob[0] )
);
hci_outstanding_rob #(
	.ROB_NW ( ROB_NW ),
	.`HCI_SIZE_PARAM(out) ( `HCI_SIZE_PARAM(ldst_tcdm) )
) i_streamer_rob_w (
	.clk_i 	( clk_i 	),
	.rst_ni ( rst_ni 	),
	.in 	( virt_tcdm[1] ),
	.out 	( virt_tcdm_rob[1] )
);
hci_outstanding_rob #(
	.ROB_NW ( ROB_NW ),
	.`HCI_SIZE_PARAM(out) ( `HCI_SIZE_PARAM(ldst_tcdm) )
) i_streamer_rob_y (
	.clk_i 	( clk_i 	),
	.rst_ni ( rst_ni 	),
	.in 	( virt_tcdm[2] ),
	.out 	( virt_tcdm_rob[2] )
);

flags_fifo_t z_fifo_flags;
logic [NumStreamSources:0][$clog2(NumStreamSources+1)-1:0] priority_encoding;
assign priority_encoding[0] = 0;
assign priority_encoding[1] = 1;
assign priority_encoding[2] = 2;
assign priority_encoding[3] = 3;
hci_outstanding_fifo #(
  .FIFO_DEPTH ( ARRAY_WIDTH ),
  .`HCI_SIZE_PARAM(tcdm_initiator) ( `HCI_SIZE_PARAM(ldst_tcdm) )
) i_z_fifo (
  .clk_i  ( clk_i   ),
  .rst_ni ( rst_ni  ),
  .clear_i         ( clear_i          ),
  .flags_o         ( z_fifo_flags     ),
  .tcdm_target     ( virt_tcdm[3]     ),
  .tcdm_initiator  ( virt_tcdm_rob[3] )
);

// XWYZ-MUX A single TCDM port is used to load XW and to store Z / load Y
hci_outstanding_mux #(
  .NB_CHAN              ( NumStreamSources+1         ),
  .`HCI_SIZE_PARAM(out) ( `HCI_SIZE_PARAM(ldst_tcdm) )
) i_ldst_mux          (
  .clk_i              ( clk_i                ),
  .rst_ni             ( rst_ni               ),
  .clear_i            ( clear_i              ),
  .priority_force_i   ( 1'b1                 ),
  .priority_i         ( priority_encoding    ),
  .in                 ( virt_tcdm_rob        ),
  .out                ( tcdm                 )
);

/************************************ Store Channel *************************************/
/* The store channel of the streamer connects the incoming stream interface (Z stream)  *
 * to an HCI core sink module that translates the stream into a TCDM protocol. This     *
 * sink module then connects to a cast unit to cast data from one FP format to another. *
 * The result of the cast unit enters a TCDM FIFO that eventually connects to the store *
 * side (virt_tcdm[NumStreamSources]) of the LD/ST multiplexer.                         */

// Store interface.
hci_outstanding_intf #(
  .DW ( DW ),
  .UW ( UW ),
  .IW ( IW ) ) z_store ( .clk ( clk_i ) );

// Sink module that turns the incoming Z stream into TCDM.
hci_outstanding_sink #(
  .MISALIGNED_ACCESSES ( REALIGN                      ),
  .`HCI_SIZE_PARAM(tcdm) ( `HCI_SIZE_PARAM(ldst_tcdm) )
) i_stream_sink        (
  .clk_i               ( clk_i                       ),
  .rst_ni              ( rst_ni                      ),
  .test_mode_i         ( test_mode_i                 ),
  .clear_i             ( clear_i                     ),
  .enable_i            ( enable_i                    ),
  .tcdm                ( z_store                     ),
  .stream              ( z_stream_i                  ),
  .ctrl_i              ( ctrl_i.z_stream_sink_ctrl   ),
  .flags_o             ( flags_o.z_stream_sink_flags )
);

// Assigning the store output to the store side of the y/z multiplexer.
hci_outstanding_assign i_store_assign ( .tcdm_target (z_store), .tcdm_initiator (virt_tcdm[3]) );

/**************************************** Load Channel ****************************************/
/* The load channel of the streamer connects the incoming TCDM interface to three different   *
 * stream interfaces: X stream (ID: 0), W stream (ID: 1), and Y stream (ID: 2). The load side *
 * (virt_tcdm[0]) of the LD/ST multiplexer connects to another multiplexer that splits the    *
 * icoming TCDM bus into three TCDM interfaces (X, W, and Y). Each interface connects to its  *
 * own FIFO, and then to a cas unit that casts the data from one FP format to another. Then,  *
 * the output of the cast connects to a dedicated HCI core source unit used to translate the  *
 * incoming TCDM protocls into stream.                                                        */

hci_outstanding_intf #(
  .DW ( DW ),
  .UW ( UW ),
  .IW ( IW ) ) tcdm_load [0:NumStreamSources-1] ( .clk ( clk_i ) );

hwpe_stream_intf_stream #( .DATA_WIDTH ( DATAW ) ) out_stream [NumStreamSources-1:0] ( .clk( clk_i ) );
hci_package::hci_streamer_ctrl_t  [NumStreamSources-1:0] source_ctrl;
hci_package::hci_streamer_flags_t [NumStreamSources-1:0] source_flags;

// Assign input control buses to the relative ID in the vector.
assign source_ctrl[XsourceStreamId]      = ctrl_i.x_stream_source_ctrl;
assign source_ctrl[WsourceStreamId]      = ctrl_i.w_stream_source_ctrl;
assign source_ctrl[YsourceStreamId]      = ctrl_i.y_stream_source_ctrl;

logic [NumStreamSources-1:0] mask_source;

for (genvar i = 0; i < NumStreamSources; i++) begin: gen_tcdm2stream

  hci_outstanding_assign i_load_assign ( .tcdm_target (tcdm_load[i]), .tcdm_initiator (virt_tcdm[i]) );

  assign mask_source[i] = (i == YsourceStreamId) & (mask_y_i);

  // Load unit
  // This unit uses only the data bus of the TCDM interface. The other buses
  // are assigned manually.

  hci_outstanding_source #(
    .ADDR_MIS_DEPTH        ( ROB_NW                     ),
    .MISALIGNED_ACCESSES   ( REALIGN                    ),
    .`HCI_SIZE_PARAM(tcdm) ( `HCI_SIZE_PARAM(ldst_tcdm) )
  ) i_stream_source      (
    .clk_i               ( clk_i           ),
    .rst_ni              ( rst_ni          ),
    .test_mode_i         ( test_mode_i     ),
    .clear_i             ( clear_i         ),
    .enable_i            ( enable_i        ),
    .mask_y_i            ( mask_source[i]  ),
    .tcdm                ( tcdm_load[i]    ),
    .stream              ( out_stream[i]   ),
    .ctrl_i              ( source_ctrl[i]  ),
    .flags_o             ( source_flags[i] )
  );
end

// Assign flags in the vector to the relative output buses.
assign flags_o.x_stream_source_flags = source_flags[XsourceStreamId];
assign flags_o.w_stream_source_flags = source_flags[WsourceStreamId];
assign flags_o.y_stream_source_flags = source_flags[YsourceStreamId];

assign flags_o.x_granted = virt_tcdm[XsourceStreamId].req_valid & virt_tcdm[XsourceStreamId].req_ready;
assign flags_o.w_granted = virt_tcdm[WsourceStreamId].req_valid & virt_tcdm[WsourceStreamId].req_ready;
assign flags_o.y_granted = ( virt_tcdm[YsourceStreamId].req_valid & virt_tcdm[YsourceStreamId].req_ready ) |
                           ( z_store.req_valid & z_store.req_ready );

// Assign resulting streams.
hwpe_stream_assign i_xstream_assign ( .push_i( out_stream[XsourceStreamId] ) ,
                                      .pop_o ( x_stream_o                  ) );

hwpe_stream_assign i_wstream_assign ( .push_i( out_stream[WsourceStreamId] ) ,
                                      .pop_o ( w_stream_o                  ) );

hwpe_stream_assign i_ystream_assign ( .push_i( out_stream[YsourceStreamId] ) ,
                                      .pop_o ( y_stream_o                  ) );

endmodule : opope_outstanding_streamer
