// Copyright 2026 ETH Zurich and University of Bologna.
// Solderpad Hardware License, Version 0.51, see LICENSE_HW for details.
// SPDX-License-Identifier: SHL-0.51
//
// O-POPE on MP 32-bit TCDM lanes for the outstanding streamer, as integrated in MemPool:
// every lane carries the request's stream id and ROB entry as one id ({req_id, req_user}),
// which the memory returns with the response. The response's id is taken from lane 0, so
// the lanes of a request must answer in the same cycle with the same id.

`include "hci_helpers.svh"

module opope_outstanding_wrap
  import fpnew_pkg::*;
  import hci_package::*;
  import opope_pkg::*;
  import hwpe_ctrl_package::*;
  import hwpe_stream_package::*;
#(
  parameter  int unsigned ID_WIDTH      = 10                          ,
  parameter  int unsigned N_CORES       = 1                           ,
  parameter  int unsigned DW            = opope_pkg::DATA_W           , // TCDM port width (bits)
  parameter  int unsigned MP            = DW/opope_pkg::MemDw         ,
  parameter  int unsigned EW            = DEFAULT_EW                  , // ECC signals width
  parameter  int unsigned N_OUTSTANDING = 16                          , // ROB entries per stream
  localparam int unsigned IW            = $clog2(NumStreamSources + 1), // Stream id
  localparam int unsigned UW            = $clog2(N_OUTSTANDING)       , // ROB entry
  localparam int unsigned TcdmIdW       = IW + UW
)(
  input  logic                              clk_i           ,
  input  logic                              rst_ni          ,
  input  logic                              test_mode_i     ,
  output logic [ N_CORES-1:0][         1:0] evt_o           ,
  output logic                              busy_o          ,
  output logic [      MP-1:0]               tcdm_req_o      ,
  input  logic [      MP-1:0]               tcdm_gnt_i      ,
  output logic [      MP-1:0][        31:0] tcdm_add_o      ,
  output logic [      MP-1:0]               tcdm_wen_o      ,
  output logic [      MP-1:0][         3:0] tcdm_be_o       ,
  output logic [      MP-1:0][        31:0] tcdm_data_o     ,
  output logic [      MP-1:0][ TcdmIdW-1:0] tcdm_id_o       ,
  output logic [      EW-1:0]               tcdm_ecc_o      ,
  input  logic [      MP-1:0][        31:0] tcdm_r_data_i   ,
  input  logic [      MP-1:0]               tcdm_r_valid_i  ,
  input  logic                              tcdm_r_opc_i    ,
  input  logic                              tcdm_r_user_i   ,
  input  logic [      MP-1:0][ TcdmIdW-1:0] tcdm_r_id_i     ,
  input  logic [      EW-1:0]               tcdm_r_ecc_i    ,
  input  logic                              periph_req_i    ,
  output logic                              periph_gnt_o    ,
  input  logic [        31:0]               periph_add_i    ,
  input  logic                              periph_wen_i    ,
  input  logic [         3:0]               periph_be_i     ,
  input  logic [        31:0]               periph_data_i   ,
  input  logic [ID_WIDTH-1:0]               periph_id_i     ,
  output logic [        31:0]               periph_r_data_o ,
  output logic                              periph_r_valid_o,
  output logic [ID_WIDTH-1:0]               periph_r_id_o
);

localparam hci_size_parameter_t `HCI_SIZE_PARAM(tcdm) = '{
  DW:  DW,
  AW:  DEFAULT_AW,
  BW:  DEFAULT_BW,
  UW:  UW,
  IW:  IW,
  EW:  EW,
  EHW: DEFAULT_EHW
};

hci_variablelatency_intf #(
  .DW ( DW ),
  .UW ( UW ),
  .IW ( IW )
) tcdm (
  .clk ( clk_i )
);

hwpe_ctrl_intf_periph #(.ID_WIDTH(ID_WIDTH)) periph (.clk(clk_i));

for (genvar ii = 0; ii < MP; ii++) begin : gen_tcdm_binding
  assign tcdm_req_o  [ii] = tcdm.req_valid;
  assign tcdm_add_o  [ii] = tcdm.req_add + ii*NumByte;
  assign tcdm_wen_o  [ii] = tcdm.req_wen;
  assign tcdm_be_o   [ii] = tcdm.req_be[(ii+1)*NumByte-1:ii*NumByte];
  assign tcdm_data_o [ii] = tcdm.req_data[(ii+1)*MemDw-1:ii*MemDw];
  assign tcdm_id_o   [ii] = {tcdm.req_id, tcdm.req_user};
end
assign tcdm_ecc_o      = '0;
assign tcdm.req_ready  = &(tcdm_gnt_i);
assign tcdm.resp_valid = &(tcdm_r_valid_i);
assign tcdm.resp_data  = { >> {tcdm_r_data_i} };
assign tcdm.resp_opc   = tcdm_r_opc_i;
assign tcdm.resp_id    = tcdm_r_id_i[0][TcdmIdW-1:UW];
assign tcdm.resp_user  = tcdm_r_id_i[0][UW-1:0];

assign periph.req       = periph_req_i;
assign periph.add       = periph_add_i;
assign periph.wen       = periph_wen_i;
assign periph.be        = periph_be_i;
assign periph.data      = periph_data_i;
assign periph.id        = periph_id_i;
assign periph_gnt_o     = periph.gnt;
assign periph_r_data_o  = periph.r_data;
assign periph_r_valid_o = periph.r_valid;
assign periph_r_id_o    = periph.r_id;

opope_top #(
  .ID_WIDTH              ( ID_WIDTH              ),
  .N_CORES               ( N_CORES               ),
  .DW                    ( DW                    ),
  .`HCI_SIZE_PARAM(tcdm) ( `HCI_SIZE_PARAM(tcdm) )
) i_opope_top (
  .clk_i       ( clk_i       ),
  .rst_ni      ( rst_ni      ),
  .test_mode_i ( test_mode_i ),
  .evt_o       ( evt_o       ),
  .busy_o      ( busy_o      ),
  .tcdm        ( tcdm        ),
  .periph      ( periph      )
);

endmodule : opope_outstanding_wrap
