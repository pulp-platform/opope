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
  hci_variablelatency_intf.initiator   tcdm,
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

// hci-core interface within the streamer (mux output side)
hci_core_intf #(
  .WAIVE_RQ3_ASSERT  ( 1'b1 ),
  .DW  ( DW  ),
  .AW  ( DEFAULT_AW  ),
  .BW  ( DEFAULT_BW  ),
  .UW  ( UW  ),
  .IW  ( IW  ),
  .EW  ( EW  ),
  .EHW ( EHW )
) tcdm_core ( .clk ( clk_i ) );

// Convert the internal hci-core stream to the external variable-latency TCDM.
hci_variablelatency_tocore #(
) i_convert2core (
  .in  ( tcdm_core ),
  .out ( tcdm      )
);

// Virtual internal TCDM interface splitting the upstream TCDM
// X   -> virt_tcdm[0]
// W   -> virt_tcdm[1]
// Y   -> virt_tcdm[2]
// Z   -> virt_tcdm[3]
hci_core_intf #(
  .WAIVE_RQ3_ASSERT  ( 1'b1 ),
  .WAIVE_RQ4_ASSERT  ( 1'b1 ),
  .WAIVE_RSP3_ASSERT ( 1'b1 ),
  .DW ( DW ),
  .AW ( DEFAULT_AW ),
  .BW ( DEFAULT_BW ),
  .UW ( UW ),
  .IW ( IW ),
  .EW ( EW ),
  .EHW ( EHW ) ) virt_tcdm [0:NumStreamSources] ( .clk ( clk_i ) );
hci_core_intf #(
  .WAIVE_RQ3_ASSERT  ( 1'b1 ),
  .WAIVE_RQ4_ASSERT  ( 1'b1 ),
  .WAIVE_RSP3_ASSERT ( 1'b1 ),
  .DW ( DW ),
  .AW ( DEFAULT_AW ),
  .BW ( DEFAULT_BW ),
  .UW ( UW ),
  .IW ( IW ),
  .EW ( EW ),
  .EHW ( EHW ) ) virt_tcdm_rob [0:NumStreamSources] ( .clk ( clk_i ) );

localparam int unsigned ROB_NW = 1 << UW;

hci_core_rob #(
	.ROB_NW ( ROB_NW ),
	.`HCI_SIZE_PARAM(out) ( `HCI_SIZE_PARAM(ldst_tcdm) )
) i_streamer_rob_x (
	.clk_i 	( clk_i 	),
	.rst_ni ( rst_ni 	),
	.in 	( virt_tcdm[0] ),
	.out 	( virt_tcdm_rob[0] )
);
hci_core_rob #(
	.ROB_NW ( ROB_NW ),
	.`HCI_SIZE_PARAM(out) ( `HCI_SIZE_PARAM(ldst_tcdm) )
) i_streamer_rob_w (
	.clk_i 	( clk_i 	),
	.rst_ni ( rst_ni 	),
	.in 	( virt_tcdm[1] ),
	.out 	( virt_tcdm_rob[1] )
);
hci_core_rob #(
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
hci_core_fifo #(
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
hci_core_mux_ooo #(
  .NB_CHAN              ( NumStreamSources+1         ),
  .`HCI_SIZE_PARAM(out) ( `HCI_SIZE_PARAM(ldst_tcdm) )
) i_ldst_mux          (
  .clk_i              ( clk_i                ),
  .rst_ni             ( rst_ni               ),
  .clear_i            ( clear_i              ),
  .priority_force_i   ( 1'b1                 ),
  .priority_i         ( priority_encoding    ),
  .in                 ( virt_tcdm_rob        ),
  .out                ( tcdm_core            )
);

/************************************ Store Channel *************************************/
/* The store channel of the streamer connects the incoming stream interface (Z stream)  *
 * to an HCI core sink module that translates the stream into a TCDM protocol. This     *
 * sink module then connects to a cast unit to cast data from one FP format to another. *
 * The result of the cast unit enters a TCDM FIFO that eventually connects to the store *
 * side (virt_tcdm[NumStreamSources]) of the LD/ST multiplexer.                         */

// Store interface.
hci_core_intf #(
  .WAIVE_RQ4_ASSERT  ( 1'b1 ),
  .WAIVE_RSP3_ASSERT ( 1'b1 ),
  .DW  ( DW ),
  .AW  ( DEFAULT_AW ),
  .BW  ( DEFAULT_BW ),
  .UW  ( UW ),
  .IW  ( IW ),
  .EW  ( EW ),
  .EHW ( EHW )
) z_store ( .clk ( clk_i ) );

// Sink module that turns the incoming Z stream into TCDM.
hci_core_sink #(
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
hci_core_assign i_store_assign ( .tcdm_target (z_store), .tcdm_initiator (virt_tcdm[3]) );

/**************************************** Load Channel ****************************************/
/* The load channel of the streamer connects the incoming TCDM interface to three different   *
 * stream interfaces: X stream (ID: 0), W stream (ID: 1), and Y stream (ID: 2). The load side *
 * (virt_tcdm[0]) of the LD/ST multiplexer connects to another multiplexer that splits the    *
 * icoming TCDM bus into three TCDM interfaces (X, W, and Y). Each interface connects to its  *
 * own FIFO, and then to a cas unit that casts the data from one FP format to another. Then,  *
 * the output of the cast connects to a dedicated HCI core source unit used to translate the  *
 * incoming TCDM protocls into stream.                                                        */

hci_core_intf #(
  .WAIVE_RQ4_ASSERT  ( 1'b1 ),
  .WAIVE_RSP3_ASSERT ( 1'b1 ),
  .DW ( DW ),
  .AW ( DEFAULT_AW ),
  .BW ( DEFAULT_BW ),
  .UW ( UW ),
  .IW ( IW ),
  .EW ( EW ),
  .EHW ( EHW ) ) tcdm_load [0:NumStreamSources-1] ( .clk ( clk_i ) );

hwpe_stream_intf_stream #( .DATA_WIDTH ( DATAW ) ) out_stream [NumStreamSources-1:0] ( .clk( clk_i ) );
hci_package::hci_streamer_ctrl_t  [NumStreamSources-1:0] source_ctrl;
hci_package::hci_streamer_flags_t [NumStreamSources-1:0] source_flags;

// Assign input control buses to the relative ID in the vector.
assign source_ctrl[XsourceStreamId]      = ctrl_i.x_stream_source_ctrl;
assign source_ctrl[WsourceStreamId]      = ctrl_i.w_stream_source_ctrl;
assign source_ctrl[YsourceStreamId]      = ctrl_i.y_stream_source_ctrl;

for (genvar i = 0; i < NumStreamSources; i++) begin: gen_tcdm2stream

  hci_core_source #(
    .ADDR_MIS_DEPTH        ( ROB_NW                     ),
    .MISALIGNED_ACCESSES   ( REALIGN                    ),
    .RESP_FIFO_DEPTH       ( ROB_NW                     ),
    .`HCI_SIZE_PARAM(tcdm) ( `HCI_SIZE_PARAM(ldst_tcdm) )
  ) i_stream_source      (
    .clk_i               ( clk_i           ),
    .rst_ni              ( rst_ni          ),
    .test_mode_i         ( test_mode_i     ),
    .clear_i             ( clear_i         ),
    .enable_i            ( enable_i        ),
    .tcdm                ( tcdm_load[i]    ),
    .stream              ( out_stream[i]   ),
    .ctrl_i              ( source_ctrl[i]  ),
    .flags_o             ( source_flags[i] )
  );

  if (i == YsourceStreamId) begin : gen_y_masked
    // Y request-gate: replicate hci_core_assign (tcdm_load[i] -> virt_tcdm[i])
    // but force req/gnt low while mask_y_i is asserted, so Y issues no loads
    // during a Z store (native hci_core_source has no mask port).
    assign virt_tcdm[i].req      = tcdm_load[i].req & ~mask_y_i;
    assign tcdm_load[i].gnt      = virt_tcdm[i].gnt & ~mask_y_i;
    assign virt_tcdm[i].add      = tcdm_load[i].add;
    assign virt_tcdm[i].wen      = tcdm_load[i].wen;
    assign virt_tcdm[i].data     = tcdm_load[i].data;
    assign virt_tcdm[i].be       = tcdm_load[i].be;
    assign virt_tcdm[i].user     = tcdm_load[i].user;
    assign virt_tcdm[i].id       = tcdm_load[i].id;
    assign virt_tcdm[i].ecc      = tcdm_load[i].ecc;
    assign virt_tcdm[i].ereq     = tcdm_load[i].ereq;
    assign virt_tcdm[i].r_ready  = tcdm_load[i].r_ready;
    assign virt_tcdm[i].r_eready = tcdm_load[i].r_eready;
    assign tcdm_load[i].egnt     = virt_tcdm[i].egnt;
    assign tcdm_load[i].r_data   = virt_tcdm[i].r_data;
    assign tcdm_load[i].r_valid  = virt_tcdm[i].r_valid;
    assign tcdm_load[i].r_user   = virt_tcdm[i].r_user;
    assign tcdm_load[i].r_id     = virt_tcdm[i].r_id;
    assign tcdm_load[i].r_opc    = virt_tcdm[i].r_opc;
    assign tcdm_load[i].r_ecc    = virt_tcdm[i].r_ecc;
    assign tcdm_load[i].r_evalid = virt_tcdm[i].r_evalid;
  end else begin : gen_passthrough
    hci_core_assign i_load_assign ( .tcdm_target (tcdm_load[i]), .tcdm_initiator (virt_tcdm[i]) );
  end
end

// Assign flags in the vector to the relative output buses.
assign flags_o.x_stream_source_flags = source_flags[XsourceStreamId];
assign flags_o.w_stream_source_flags = source_flags[WsourceStreamId];
assign flags_o.y_stream_source_flags = source_flags[YsourceStreamId];

assign flags_o.x_granted = virt_tcdm[XsourceStreamId].req & virt_tcdm[XsourceStreamId].gnt;
assign flags_o.w_granted = virt_tcdm[WsourceStreamId].req & virt_tcdm[WsourceStreamId].gnt;
assign flags_o.y_granted = ( virt_tcdm[YsourceStreamId].req & virt_tcdm[YsourceStreamId].gnt ) |
                           ( z_store.req & z_store.gnt );

// Assign resulting streams.
hwpe_stream_assign i_xstream_assign ( .push_i( out_stream[XsourceStreamId] ) ,
                                      .pop_o ( x_stream_o                  ) );

hwpe_stream_assign i_wstream_assign ( .push_i( out_stream[WsourceStreamId] ) ,
                                      .pop_o ( w_stream_o                  ) );

hwpe_stream_assign i_ystream_assign ( .push_i( out_stream[YsourceStreamId] ) ,
                                      .pop_o ( y_stream_o                  ) );

endmodule : opope_outstanding_streamer
