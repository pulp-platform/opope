// Copyright 2023 ETH Zurich and University of Bologna.
// Solderpad Hardware License, Version 0.51, see LICENSE for details.
// SPDX-License-Identifier: SHL-0.51
//
// George Pagonis  <gpagonis@student.ethz.ch>

module ope_buffers  
  import ope_pkg::*;
  import hwpe_stream_package::*;
#(
  parameter int unsigned READING_POLICY = ope_pkg::INTERLEAVED,
  parameter int unsigned DATA_WIDTH     = ope_pkg::DATAW,
  parameter int unsigned DEPTH          = 2
) (
  input  logic                         clk_i, 
  input  logic                         rst_ni,
  input  logic                         clear_i,
  
  // From/To Streamer 
  hwpe_stream_intf_stream.sink   x_stream_i,
  hwpe_stream_intf_stream.sink   w_stream_i,
  hwpe_stream_intf_stream.sink   y_stream_i,
  hwpe_stream_intf_stream.source z_stream_o,

  // Engine
  input  logic                         in_ready_i,
  output logic                         in_valid_o,
  output logic [DATA_WIDTH/DEPTH-1:0]  x_data_o  , 
  output logic [DATA_WIDTH/DEPTH-1:0]  w_data_o  ,

  input  logic                         y_ready_i,
  input  logic                         mask_y_i ,
  output logic                         y_valid_o,
  output logic [DATA_WIDTH      -1:0]  y_data_o , 

  output logic                         z_ready_o,
  input  logic                         mask_z_i ,
  input  logic                         z_valid_i,
  input  logic [DATA_WIDTH      -1:0]  z_data_i  
);

logic x_valid,w_valid;

// Y stream
assign y_stream_i.ready = y_ready_i &~ mask_y_i;
assign y_valid_o        = y_stream_i.valid & y_stream_i.ready;
assign y_data_o         = y_stream_i.data      ;

// Z stream
assign z_stream_o.strb  = {{DATAW/8{1'b1}}}     ;
assign z_stream_o.valid = z_valid_i &~ mask_z_i       ;
assign z_stream_o.data  = z_data_i                    ;
assign z_ready_o        = z_stream_o.ready &~ mask_z_i;

// X and W stream
assign in_valid_o = x_valid && w_valid;

reg_array_io_wrapper #(
  .READING_POLICY   ( ope_pkg::SERIALLY ),
  .DATA_WIDTH       (DATAW),
  .DEPTH            (X_REGBUFFER_DEPTH)
) i_x_reg_array_wrapper(
  .clk_i              ( clk_i            ),
  .rst_ni             ( rst_ni           ),
  .clear_i            ( clear_i          ),
  
  // Streamer
  .data_i             ( x_stream_i.data  ),
  .valid_i            ( x_stream_i.valid ),
  .ready_o            ( x_stream_i.ready ),

  // Engine
  .ready_i            ( in_ready_i       ),
  .data_o             ( x_data_o         ),
  .valid_o            ( x_valid          )
);

reg_array_io_wrapper #(
  .READING_POLICY   ( ope_pkg::INTERLEAVED ),
  .DATA_WIDTH       (DATAW),
  .DEPTH            (W_REGBUFFER_DEPTH)
) i_w_reg_array_wrapper(
  .clk_i              ( clk_i            ),
  .rst_ni             ( rst_ni           ),
  .clear_i            ( clear_i          ),

  // Streamer
  .data_i             ( w_stream_i.data  ),
  .valid_i            ( w_stream_i.valid ),
  .ready_o            ( w_stream_i.ready ),

  // Engine
  .ready_i            ( in_ready_i       ),
  .data_o             ( w_data_o         ),
  .valid_o            ( w_valid          )
);

endmodule: ope_buffers