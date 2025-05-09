// Copyright 2023 ETH Zurich and University of Bologna.
// Solderpad Hardware License, Version 0.51, see LICENSE for details.
// SPDX-License-Identifier: SHL-0.51
//
// George Pagonis  <gpagonis@student.ethz.ch>

module priority_enforcer
  import ope_pkg::*;
#(
  parameter int unsigned CHANGE_DEGREE  = X_REGBUFFER_DEPTH,
  parameter int unsigned NSS            = NumStreamSources
)(
  input  logic                                clk_i,
  input  logic                                rst_ni,
  input  logic                                enable_i,
  input  logic                                x_granted_i,
  input  logic                                w_granted_i,
  output logic                                custom_priority_force_o,
  output logic [NSS-1:0][$clog2(NSS) - 1: 0]  custom_priority_o
);

  // NOTE: the register in the output are required to avoid changing the priority in the middle of the handshake
  // only re-evaluate WTA output after an output handshake or if any
  // in_req was 0, otherwise a more recent in_req could overtake an
  // older one causing a RQ3-STABILITY issue on the output side.

  // FIXME: Works but can this be improved by a cycle?

  logic [$clog2(CHANGE_DEGREE-1):0]   x_counter_d, x_counter_q;
  logic [$clog2(CHANGE_DEGREE-1):0]   w_counter_d, w_counter_q;
  logic [NSS-1:0][$clog2(NSS) - 1: 0] custom_priority_q, custom_priority_d;
  logic                               custom_priority_force_q, custom_priority_force_d;


  always_comb begin
    x_counter_d = x_counter_q;
    w_counter_d = w_counter_q;
    if (enable_i) begin
      if (x_granted_i) begin
        x_counter_d = (x_counter_q == CHANGE_DEGREE-1) ? '0 : x_counter_q + 1;
      end else if (w_granted_i) begin
        w_counter_d = (w_counter_q == CHANGE_DEGREE-1) ? '0 : w_counter_q + 1;
      end
    end
  end

  always_comb begin
    custom_priority_d       = custom_priority_q;
    custom_priority_force_d = custom_priority_force_q;
    if (enable_i) begin
      custom_priority_force_d = 1'b1;
      if (x_counter_q == 0 && x_counter_d == 1) begin // x_granted == 1 -> give priority to W
        custom_priority_d[XsourceStreamId] = 1;
        custom_priority_d[WsourceStreamId] = 0;
      end else if (w_counter_q == CHANGE_DEGREE - 1 && w_counter_d == 0) begin // w_granted == 1 -> give priority to X
        custom_priority_d[XsourceStreamId] = 0;
        custom_priority_d[WsourceStreamId] = 1;
      end else begin
        custom_priority_d  = custom_priority_q;
      end
    end else begin
      custom_priority_force_d = 1'b0;
      custom_priority_d[XsourceStreamId] = 0;
      custom_priority_d[WsourceStreamId] = 1;
    end
  end


  always_ff @(posedge clk_i, negedge rst_ni) begin
    if (~rst_ni) begin
      x_counter_q             <= '0;
      w_counter_q             <= '0;
      custom_priority_q       <= '0;
      custom_priority_force_q <= 1'b0;
    end else begin
      x_counter_q             <= x_counter_d;
      custom_priority_q       <= custom_priority_d;
      w_counter_q             <= w_counter_d;
      custom_priority_force_q <= custom_priority_force_d;
    end
  end

  assign custom_priority_force_o = custom_priority_force_q;
  assign custom_priority_o       = custom_priority_q;

endmodule : priority_enforcer