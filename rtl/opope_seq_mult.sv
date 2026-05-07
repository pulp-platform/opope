// Copyright 2025 ETH Zurich and University of Bologna.
// Solderpad Hardware License, Version 0.51, see LICENSE for details.
// SPDX-License-Identifier: SHL-0.51
//
// Danilo Cammarata <dcammarata@iis.ee.ethz.ch>

// Radix-2 Booth Multiplier

module opope_seq_mult #(
  parameter int unsigned DW = 32
)(
  input  logic            clk_i  ,
  input  logic            rst_ni ,
  input  logic            start_i,
  input  logic [DW-1:0]   a_i    ,
  input  logic [DW-1:0]   b_i    ,
  output logic            done_o ,
  output logic [2*DW-1:0] prod_o
);
  typedef enum logic {
    IDLE_STATE,
    COMPUTE_STATE
  } state_e;
  state_e current_state, next_state;

  logic [$clog2(DW)-2:0]  cnt_q, cnt_d;
  logic [2*DW+1:0]        acc_d, acc_q, prod;
  logic [2*DW+1:0]        acc_booth;
  logic [DW:0]            sum;
  logic                   cnt_tc;
  logic                   cnt_en;

  always_comb begin
    cnt_en = (current_state == COMPUTE_STATE);
    cnt_tc = (cnt_q == 0);
    cnt_d  = cnt_tc ? DW/2 - 1 : cnt_q - cnt_en;

    // Forward the initialized accumulator on start_i so the first
    // Booth step is computed combinatorially in the same cycle
    acc_booth = start_i ? {1'b0, {DW{1'b0}}, b_i, 1'b0} : acc_q;

    case (acc_booth[2:0])
      3'b001, 3'b010: begin
        sum  = acc_booth[2*DW+1:DW+1] + {1'b0, a_i};
        prod = {{2{sum[DW]}}, sum, acc_booth[DW:2]};
      end
      3'b101, 3'b110: begin
        sum  = acc_booth[2*DW+1:DW+1] - {1'b0, a_i};
        prod = {{2{sum[DW]}}, sum, acc_booth[DW:2]};
      end
      3'b011: begin
        sum  = acc_booth[2*DW+1:DW+1] + {a_i, 1'b0};
        prod = {{2{sum[DW]}}, sum, acc_booth[DW:2]};
      end
      3'b100: begin
        sum  = acc_booth[2*DW+1:DW+1] - {a_i, 1'b0};
        prod = {{2{sum[DW]}}, sum, acc_booth[DW:2]};
      end
      default: begin
        sum  = '0; // unused
        prod = {{2{acc_booth[2*DW+1]}}, acc_booth[2*DW+1:2]};
      end
    endcase

    acc_d = prod; // prod already uses acc_booth which muxes start_i

    next_state = start_i    ? COMPUTE_STATE :
                 cnt_tc     ? IDLE_STATE    :
                              current_state ;
  end

  always_ff @(posedge clk_i or negedge rst_ni) begin
    if (!rst_ni) begin
      current_state <= IDLE_STATE;
      cnt_q         <= DW/2 - 1;
      acc_q         <= '0;
    end else begin
      current_state <= next_state;
      cnt_q         <= cnt_d;
      acc_q         <= acc_d;
    end
  end

  // done_o fires when cnt_q==0 (COMPUTE_STATE), at that point
  // acc_q already holds the fully accumulated result from the flop
  assign done_o = cnt_tc && (current_state == COMPUTE_STATE);

  // Read result from the registered accumulator, not from combinatorial prod
  assign prod_o = acc_q[2*DW:1];

  // Assertions
  if (DW < 4) $error("[opope_seq_mult] DW must be at least 4.\n");
  
endmodule
