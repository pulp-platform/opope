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
  input  logic                     clk_i, 
  input  logic                     rst_ni,
  input  logic                     clear_i,
  input  logic                     iteration_change_i,
  input  logic                     reading_reg_i, 
  input  logic [DATA_WIDTH-1:0]    data_i,
  input  logic                     valid_i,
  output logic                     ready_o,
  output logic [DATA_WIDTH-1:0]    data_o, 
  output logic                     valid_o,
  output logic                     not_empty_o
);

  logic [DEPTH-1:0][DATA_WIDTH-1:0]       reg_d, reg_q;
  logic [DEPTH-1:0]                       reg_valid_d, reg_valid_q;
  logic [DEPTH-1:0][$clog2(DEPTH) - 1:0]  accessed_counter_d, accessed_counter_q; // Set up to DEPTH-1 when the loading, 0 when the register is free to be written to
  logic [$clog2(DEPTH) - 1:0]             reading_counter_d, reading_counter_q;   // The counter that shows which register to be read from, depends on the reading policy
  logic [$clog2(DEPTH) - 1:0]             storing_counter_d, storing_counter_q;   // The counter that register is being written to. If accessed_counter_q[storing_counter_q] == 0, then the register is free to be written to
  logic [$clog2(DEPTH) - 1:0]             serial_counter_d, serial_counter_q;     // If serially, each register is accessed DEPTH times before moving to the next one

  // **** READING ****
  always_comb begin
    reading_counter_d     = reading_counter_q;
    serial_counter_d      = serial_counter_q;
    data_o                = 'b0;
    valid_o               = 1'b0;

    if (reading_reg_i && reg_valid_q[reading_counter_q]) begin
      data_o                            = reg_q[reading_counter_q];
      valid_o                           = 1'b1;
      if (READING_POLICY == ope_pkg::INTERLEAVED) begin // Read from different registers all the time, rotating back
        reading_counter_d               = reading_counter_q + 1;
      end else if (READING_POLICY == ope_pkg::SERIALLY) begin // Read from the same register DEPTH times
        serial_counter_d                = (serial_counter_q == DEPTH-1)? 'b0: serial_counter_q + 1;
        reading_counter_d               = (serial_counter_q == DEPTH-1) ? reading_counter_q + 1: reading_counter_q;
      end
    end
  end

  // **** ACCESSED COUNTER ****

  always_comb begin 
    accessed_counter_d = accessed_counter_q;
    reg_valid_d        = reg_valid_q;
    if (reading_reg_i && reg_valid_q[reading_counter_q] && valid_i) begin // both read and write
      if (reading_counter_q != storing_counter_q) begin
        accessed_counter_d[reading_counter_q] = (accessed_counter_q[reading_counter_q] == 0) ? 'b0: accessed_counter_q[reading_counter_q] - 1;
        reg_valid_d[reading_counter_q]        = (accessed_counter_q[reading_counter_q] == 0) ? 1'b0: reg_valid_q[reading_counter_q];
        accessed_counter_d[storing_counter_q] = DEPTH-1;
        reg_valid_d[storing_counter_q]        = 1'b1;
      end else begin
        accessed_counter_d[storing_counter_q] = DEPTH-1;
        reg_valid_d[storing_counter_q]        = 1'b1;
      end
    end else if (reading_reg_i && reg_valid_q[reading_counter_q]) begin // read only
      accessed_counter_d[reading_counter_q] = (accessed_counter_q[reading_counter_q] == 0) ? 'b0: accessed_counter_q[reading_counter_q] - 1;
      reg_valid_d[reading_counter_q]        = (accessed_counter_q[reading_counter_q] == 0) ? 1'b0: reg_valid_q[reading_counter_q];
    end else if (valid_i) begin // write only
      accessed_counter_d[storing_counter_q] = DEPTH-1;
      reg_valid_d[storing_counter_q]        = 1'b1;
    end else begin
        accessed_counter_d = accessed_counter_q; 
        reg_valid_d         = reg_valid_q;
    end
  end

  // **** READY SIGNAL ****
  always_comb begin
    ready_o = 1'b1;
    if (accessed_counter_q[storing_counter_q] != 0) ready_o = 1'b0;
  end

  // **** WRITING ****
  always_comb begin
    reg_d             = reg_q;
    storing_counter_d = storing_counter_q;
    if (valid_i) begin
      reg_d[storing_counter_q]  = data_i;
      storing_counter_d         = storing_counter_q + 1;
    end
  end

  always_comb begin
    not_empty_o = 1'b0;
    for (int i = 0; i < DEPTH; i++) begin
      if (reg_valid_q[i] || valid_i) begin // Have something already or writing right now
        not_empty_o = 1'b1;
      end
    end
  end

  always_ff @(posedge clk_i or negedge rst_ni) begin 
    if (~rst_ni) begin
      reading_counter_q     <= 'b0;
      serial_counter_q      <= 'b0;
      accessed_counter_q    <= 'b0;
      reg_valid_q           <= 'b0;
      reg_q                 <= 'b0;
      storing_counter_q     <= 'b0;
    end else begin 
      if (clear_i || iteration_change_i) begin
        reading_counter_q     <= 'b0;
        serial_counter_q      <= 'b0;
        accessed_counter_q    <= 'b0;
        reg_valid_q           <= 'b0;
        reg_q                 <= 'b0;
        storing_counter_q     <= 'b0;
      end else begin 
        reading_counter_q     <= reading_counter_d;
        serial_counter_q      <= serial_counter_d;
        accessed_counter_q    <= accessed_counter_d;
        reg_valid_q           <= reg_valid_d;
        reg_q                 <= reg_d;
        storing_counter_q     <= storing_counter_d;
      end
    end
  end

endmodule: reg_array_io_wrapper