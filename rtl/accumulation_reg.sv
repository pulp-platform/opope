// Copyright 2023 ETH Zurich and University of Bologna.
// Solderpad Hardware License, Version 0.51, see LICENSE for details.
// SPDX-License-Identifier: SHL-0.51
//
// George Pagonis  <gpagonis@student.ethz.ch>

module accumulation_reg
  import ope_pkg::*;
#(
  parameter int unsigned   DATA_WIDTH   = BITW,
  parameter int unsigned   DEPTH        = REG_PER_CE
)(
  input  logic                      clk_i               ,
  input  logic                      rst_ni              ,
  input  logic                      flush_i             ,
  input  logic                      iteration_change_i  ,
  input  logic [DATA_WIDTH-1:0]     input_i             ,
  input  logic                      write_en_i          ,
  input  logic [$clog2(DEPTH)-1:0]  write_index_i        ,
  input  logic                      read_en_i              ,
  input  logic [$clog2(DEPTH)-1:0]  read_index_i         ,

  output logic [DATA_WIDTH-1:0]     output_o            ,
  output logic                      out_valid_o     
);

  logic [DEPTH-1:0][DATA_WIDTH-1:0] internal_reg_d, internal_reg_q;

  always_comb begin 
    internal_reg_d = internal_reg_q;
    if (write_en_i) begin
      internal_reg_d[write_index_i] = input_i;
    end
  end

  always_comb begin
    output_o    = 'b0;
    out_valid_o = 1'b0;
    if (read_en_i) begin
      output_o    = internal_reg_q[read_index_i];
      out_valid_o = 1'b1;
    end
  end

  always_ff @(posedge clk_i or negedge rst_ni) begin
    if (~rst_ni) begin
      internal_reg_q  <= 'b0;
    end else begin
      if (flush_i || iteration_change_i) begin
        internal_reg_q <= 'b0;
      end else begin
        internal_reg_q <= internal_reg_d;
      end
    end
  end

endmodule : accumulation_reg