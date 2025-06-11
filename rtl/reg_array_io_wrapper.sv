// Copyright 2023 ETH Zurich and University of Bologna.
// Solderpad Hardware License, Version 0.51, see LICENSE for details.
// SPDX-License-Identifier: SHL-0.51
//
// George Pagonis  <gpagonis@student.ethz.ch>

module reg_array_io_wrapper  
  import ope_pkg::*;
#(
  parameter int unsigned READING_POLICY = ope_pkg::INTERLEAVED,
  parameter int unsigned DATA_WIDTH     = ope_pkg::DATAW,
  parameter int unsigned DEPTH          = 2
) (
  input  logic                         clk_i, 
  input  logic                         rst_ni,
  input  logic                         clear_i,
  input  logic                         ready_i, 
  input  logic [DATA_WIDTH-1:0]        data_i,
  input  logic                         valid_i,
  output logic                         ready_o,
  output logic [DATA_WIDTH/DEPTH-1:0]  data_o, 
  output logic                         valid_o
);

  logic [DEPTH-1:0][DATA_WIDTH/DEPTH-1:0] reg_d, reg_q;
  logic                                   reg_valid_d, reg_valid_q;
  logic [DEPTH-1:0]                       reading_counter_d, reading_counter_q;   // The counter that shows which register to be read from, depends on the reading policy
  logic change_data;

  always_comb begin : reg_values
    valid_o = reg_valid_q;
    reading_counter_d = (ready_i && reg_valid_q && reading_counter_q == DEPTH*DEPTH-1) ? '0 
                                                                                        : reading_counter_q + (ready_i && reg_valid_q);
    change_data  = (reading_counter_q == DEPTH*DEPTH-1) & (reading_counter_d == '0);
    reg_valid_d  = valid_i ? 1'b1 : change_data ? '0 : reg_valid_q;
    ready_o      = change_data | ~reg_valid_q;

    if (clear_i) reading_counter_d = 'b0;
    if (clear_i) reg_valid_d       = 'b0;
  end

  // **** READING ****
  if (READING_POLICY == ope_pkg::INTERLEAVED) assign data_o = reg_q[reading_counter_q[$clog2(DEPTH) - 1:0]];
  if (READING_POLICY == ope_pkg::SERIALLY   ) assign data_o = reg_q[reading_counter_q[DEPTH-1 : $clog2(DEPTH)]];

  // **** WRITING ****
  always_comb begin
    reg_d             = reg_q;
    if (valid_i && ready_o) begin
      for(int ii=0; ii< DATA_WIDTH/BITW; ii++) begin
        reg_d[ii%DEPTH][ii/DEPTH*BITW +: BITW]  = data_i[ii*BITW +: BITW];
      end
    end
    if (clear_i) reg_d = '0;
  end

  always_ff @(posedge clk_i or negedge rst_ni) begin 
    if (~rst_ni) begin
      reading_counter_q <= 'b0;
      reg_valid_q       <= 'b0;
      reg_q             <= 'b0;
    end else begin 
      reading_counter_q <= reading_counter_d;
      reg_valid_q       <= reg_valid_d;
      reg_q             <= reg_d;
    end
  end

endmodule: reg_array_io_wrapper