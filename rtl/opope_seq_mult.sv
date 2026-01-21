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

  // /*-------------------- State Machine --------------------*/
  // typedef enum logic [1:0] {
  //   IDLE_STATE,
  //   SUM_STATE,
  //   SHIFT_STATE
  // } state_e;

  // state_e current_state, next_state;

  // /*-------------------- Internal Signals --------------------*/
  // logic        [  DW  :0] opa_d,opa_q;
  // logic        [2*DW-1:0] acc_d,acc_q;
  // logic        [  DW+1:0] sum;
  // logic signed [  DW+1:0] acc ;
  // logic signed [  DW+1:0] mult;

  // logic cnt_tc ;
  // logic sh_opb;
  // logic cnt_en;

  // logic sh_opa, lshopa_rshopa_n, flipflop_q, flipflop_d;

  // /*-------------------- Control Unit --------------------*/

  // // Next-state logic
  // always_comb begin
  //   next_state = current_state;
  //   case (current_state)
  //     IDLE_STATE  : next_state = (start_i && b_i[1:0] == 2'b00)                ? SHIFT_STATE :
  //                                (start_i && b_i[1:0] != 2'b00)                ? SUM_STATE   : IDLE_STATE;

  //     SUM_STATE   : next_state = (start_i && b_i[1:0] == 2'b00)                ? SHIFT_STATE :
  //                                (start_i && b_i[1:0] != 2'b00)                ? SUM_STATE   :
  //                                cnt_tc                                        ? IDLE_STATE  :
  //                               (acc_q[3:1] == 3'b000 || acc_q[3:1] == 3'b111) ? SHIFT_STATE : SUM_STATE ;

  //     SHIFT_STATE : next_state = (start_i && b_i[1:0] == 2'b00)                ? SHIFT_STATE :
  //                                (start_i && b_i[1:0] != 2'b00)                ? SUM_STATE   :
  //                                cnt_tc                                        ? IDLE_STATE  :
  //                               (acc_q[3:1] == 3'b000 || acc_q[3:1] == 3'b111) ? SHIFT_STATE : SUM_STATE ;
      

  //   endcase
  // end

  // // Output decode
  // always_comb begin
  //   sh_opb = 1'b1;
  //   cnt_en = 1'b1;
  //   prod_o = acc_q;
  //   acc_d  = acc_q;

  //   case (current_state)
  //     SUM_STATE: begin
  //       prod_o[2*DW-1:DW-2] = sum;
  //       acc_d = start_i ? {DW*{1'b0},b_i} : prod_o;
  //     end

  //     SHIFT_STATE: begin
  //       prod_o[DW-3  :0   ] = acc_q[DW-1:2]   ;
  //       prod_o[2*DW-3:DW-2] = acc_q[2*DW-1:DW];
  //       acc_d = start_i ? {DW*{1'b0},b_i} : prod_o;
  //     end

  //     default: begin
  //       sh_opb  = 1'b0;
  //       cnt_en  = 1'b0;
  //       acc_d[2*DW-1:0   ] = {DW*{1'b0},b_i};
  //     end
  //   endcase
  // end

  /*-------------------- Datapath --------------------*/

  // Down Counter
  // logic [$clog2(DW)-2:0]  cnt_q,cnt_d;
  // always_comb begin

  //   cnt_tc = (cnt_q == 0);
  //   cnt_d  = cnt_tc ? DW/2 - 1 : cnt_q - cnt_en;

  //   lshopa_rshopa_n = flipflop_q ^ acc_q[0];
  //   sh_opa          = lshopa_rshopa_n ^ (acc_q[1] ^ acc_q[2]);
  //   flipflop_d      = (start_i) ? 1'b0 : sh_opb ? acc_q[1] : flipflop_q;

  //   opa_d = start_i && b_i[0]          ? {a_i[DW-1]    ,         a_i} :
  //           start_i &! b_i[0]          ? {a_i          ,        1'b0} :
  //           sh_opa  && lshopa_rshopa_n ? {opa_q[DW-1:0],        1'b0} :
  //           sh_opa  &! lshopa_rshopa_n ? {opa_q[DW]    , opa_q[DW:1]} : opa_q;

  //   acc  = $signed({acc_q[2*DW-1], acc_q[2*DW-1], acc_q[2*DW-1:DW]});
  //   mult = $signed({opa_q[DW], opa_q});
  //   if (!acc_q[1]) sum = acc + mult;
  //   else           sum = acc - mult;

  // end

  // always_ff @(posedge clk_i or negedge rst_ni) begin
  //   if (!rst_ni) begin
  //     current_state <= IDLE_STATE;
  //     cnt_q         <= DW/2 - 1  ;
  //     flipflop_q    <= 1'b0      ;
  //     acc_q         <= '0        ;
  //     opa_q         <= '0        ;
  //   end else begin
  //     current_state <= next_state;
  //     cnt_q         <= cnt_d     ;
  //     flipflop_q    <= flipflop_d;
  //     acc_q         <= acc_d     ;
  //     opa_q         <= opa_d     ;
  //   end
  // end

  // assign done_o = cnt_tc;

  typedef enum logic {
    IDLE_STATE,
    COMPUTE_STATE
  } state_e;  
  state_e current_state, next_state;

  logic [$clog2(DW)-2:0]  cnt_q,cnt_d;
  logic [2*DW+1:0] acc_d,acc_q, prod;
  logic [DW:0] sum;
  logic cnt_tc ;
  logic cnt_en;

  always_comb begin
    cnt_en = current_state == COMPUTE_STATE;
    cnt_tc = (cnt_q == 0);
    cnt_d  = cnt_tc ? DW/2 - 1 : cnt_q - cnt_en;
    case(acc_q[2:0])
      3'b001,3'b010  : begin
        sum = acc_q[2*DW+1:DW+1] + {1'b0, a_i};
        prod = {{2{sum[DW]}},sum,acc_q[DW:2]};
      end
      3'b101,3'b110  : begin
        sum = acc_q[2*DW+1:DW+1] - {1'b0, a_i};
        prod = {{2{sum[DW]}},sum,acc_q[DW:2]};
      end
      3'b011: begin
        sum = acc_q[2*DW+1:DW+1] + {a_i,1'b0};
        prod = {{2{sum[DW]}},sum,acc_q[DW:2]};
      end
      3'b100: begin
        sum = acc_q[2*DW+1:DW+1] - {a_i,1'b0};
        prod = {{2{sum[DW]}},sum,acc_q[DW:2]};
      end
      default: begin
        sum = acc_q[2*DW+1:DW+1] + {1'b0, a_i};
        prod = {{2{acc_q[2*DW+1]}},acc_q[2*DW+1:2]};
      end
    endcase
    acc_d = start_i ? {1'b0,{DW{1'b0}},b_i,1'b0} : prod;

    next_state = start_i ? COMPUTE_STATE : cnt_tc ? IDLE_STATE : current_state;
  end
  always_ff @(posedge clk_i or negedge rst_ni) begin
    if (!rst_ni) begin
      current_state <= IDLE_STATE;
      cnt_q         <= DW/2 - 1  ;
      acc_q         <= '0        ;
    end else begin
      current_state <= next_state;
      cnt_q         <= cnt_d     ;
      acc_q         <= acc_d     ;
    end
  end

  assign done_o = cnt_tc;
  assign prod_o = prod[2*DW:1];

  // Assertions
  if (DW < 4) $error("[opope_seq_mult] DW must be at least 4.\n");
  
endmodule
