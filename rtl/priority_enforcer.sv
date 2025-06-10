// Copyright 2023 ETH Zurich and University of Bologna.
// Solderpad Hardware License, Version 0.51, see LICENSE for details.
// SPDX-License-Identifier: SHL-0.51
//
// George Pagonis  <gpagonis@student.ethz.ch>

module priority_enforcer
  import ope_pkg::*;
#(
  parameter int unsigned NSS            = NumStreamSources
)(
  input  logic                 clk_i,
  input  logic                 rst_ni,
  input  logic                 enable_i,
  input  logic                 x_granted_i,
  input  logic                 w_granted_i,
  input  logic                 y_granted_i,
  input  logic                 z_valid_i,
  input  logic                 last_iteration_i,
  output logic                 custom_priority_force_o,
  output logic                 start_computing_o,
  output logic                 mask_streamer_o,
  output logic                 mask_z_o,
  output logic                 finished_o,
  output logic [NSS-1:0][$clog2(NSS)-1: 0] custom_priority_o
);

  // NOTE: the register in the output are required to avoid changing the priority in the middle of the handshake
  // only re-evaluate WTA output after an output handshake or if any
  // in_req was 0, otherwise a more recent in_req could overtake an
  // older one causing a RQ3-STABILITY issue on the output side.

  // FIXME: Works but can this be improved by a cycle?


  localparam int unsigned LoadCycles = ARRAY_HEIGHT*ARRAY_WIDTH*REG_PER_CE*BITW/DATAW;
  
  typedef enum logic [1:0] {
    PRIORITY_X,
    PRIORITY_W,
    PRIORITY_YZ
  } ope_priority_level_e;

  typedef enum logic [2:0] {
    STREAMER_Y,
    STREAMER_XWY,
    STREAMER_XWM,
    STREAMER_XWZ,
    STREAMER_Z
  } ope_priority_state_e;

  logic change_state;
  logic grant;
  logic done_d,done_q;

  logic[$clog2(LoadCycles)-1:0] y_counter_d,y_counter_q;
  logic[$clog2(LoadCycles)-1:0] extra_d,extra_q;
  logic[1:0] priority_counter_d,priority_counter_q;

  ope_priority_level_e priority_level;
  ope_priority_state_e current,next;

  
  assign grant = x_granted_i | w_granted_i | y_granted_i;

  always_comb begin : streamer_fsm
    case (current)
    // ---------------------------------------------------------------------------------
      STREAMER_Y  : next = change_state                     ? STREAMER_XWY : current;
    // ---------------------------------------------------------------------------------
      STREAMER_XWY: next = change_state                     ? STREAMER_XWM : current;
    // ---------------------------------------------------------------------------------
      STREAMER_XWZ: next = change_state && last_iteration_i ? STREAMER_XWM :
                           change_state                     ? STREAMER_XWY : current;
    // ---------------------------------------------------------------------------------
      STREAMER_Z  : next = change_state                     ? STREAMER_Y   : current;
    // ---------------------------------------------------------------------------------
      STREAMER_XWM: next = change_state && done_q           ? STREAMER_Z   : 
                           change_state                     ? STREAMER_XWZ : current;
    // ---------------------------------------------------------------------------------
      default     : next = STREAMER_Y;
    // ---------------------------------------------------------------------------------
    endcase
  end
  
  always_comb begin : streamer_values
    y_counter_d        = y_counter_q       ;
    priority_counter_d = priority_counter_q;
    mask_streamer_o    = 1'b0;
    mask_z_o           = 1'b1;
    extra_d            = extra_q;
    done_d             = done_q ;
    finished_o         = 1'b0;
    
    case (current)
      STREAMER_Y  : begin
       y_counter_d        = y_counter_q + y_granted_i;
       change_state       = (y_counter_q == LoadCycles-1) & (y_counter_d =='0);
       priority_counter_d = 2'b11 + change_state;
      end
      STREAMER_XWY: begin
        extra_d            = 1'b0;
        y_counter_d        = y_counter_q + y_granted_i;
        change_state       = (y_counter_q == LoadCycles-1) & (y_counter_d =='0);
        priority_counter_d = priority_counter_q + grant;
      end
      STREAMER_XWM: begin
        extra_d            = extra_q + y_granted_i;
        priority_counter_d = priority_counter_q + (grant | priority_counter_q[1]);
        mask_streamer_o    = priority_counter_q[1];
        change_state       = (priority_counter_d == '0) & z_valid_i;
        mask_z_o           = ~(change_state & done_q);
      end
      STREAMER_XWZ: begin
        change_state       = (y_counter_q == LoadCycles-1) & y_granted_i;
        y_counter_d        = change_state ? extra_q : y_counter_q + y_granted_i;
        priority_counter_d = priority_counter_q + grant;
        // mask_z_o           = ^priority_counter_q;
        mask_streamer_o    = 1'b1;
        mask_z_o           = priority_counter_q[1];
        done_d             = last_iteration_i;
      end 
      STREAMER_Z  : begin
        y_counter_d        = y_counter_q + y_granted_i;
        change_state       = (y_counter_q == LoadCycles-1) & (y_counter_d =='0);
        priority_counter_d = 2'b11 + change_state;
        mask_z_o           = 1'b0;
        done_d             = 1'b0;
        finished_o         = change_state;
      end 
    endcase    
  end

  always_comb begin : priority_values
    case (priority_counter_q)
      2'b00  : priority_level = PRIORITY_X ;
      2'b01  : priority_level = PRIORITY_W ;
      2'b10  : priority_level = PRIORITY_YZ;
      default: priority_level = PRIORITY_YZ;
    endcase

    case (priority_level)
      PRIORITY_X   : begin
        custom_priority_o[0] = XsourceStreamId;
        custom_priority_o[1] = WsourceStreamId;
        custom_priority_o[2] = YsourceStreamId;
      end
      PRIORITY_W   : begin
        custom_priority_o[0] = WsourceStreamId;
        custom_priority_o[1] = YsourceStreamId;
        custom_priority_o[2] = XsourceStreamId;
      end
      PRIORITY_YZ  :begin
        custom_priority_o[0] = YsourceStreamId;
        custom_priority_o[1] = XsourceStreamId;
        custom_priority_o[2] = WsourceStreamId;
      end
    endcase
  end
  
  assign custom_priority_force_o = 1'b1;
  assign start_computing_o       = (current == STREAMER_Y) & change_state;

  always_ff @(posedge clk_i, negedge rst_ni) begin
    if (~rst_ni) begin
      y_counter_q        <= '0;
      priority_counter_q <= '0;
      current            <= STREAMER_Y;
      extra_q            <= '0;
      done_q             <= '0;
    end else begin
      y_counter_q        <= y_counter_d       ;
      priority_counter_q <= priority_counter_d;
      current            <= next              ;
      extra_q            <= extra_d           ;
      done_q             <= done_d            ;
    end
  end

endmodule : priority_enforcer