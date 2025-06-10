// Copyright 2023 ETH Zurich and University of Bologna.
// Solderpad Hardware License, Version 0.51, see LICENSE for details.
// SPDX-License-Identifier: SHL-0.51
//
// George Pagonis  <gpagonis@student.ethz.ch>

module ope_memory_scheduler
  import ope_pkg::*;
  import hwpe_ctrl_package::*;
#(
  parameter int unsigned   W    = ARRAY_WIDTH,
  parameter int unsigned   H    = ARRAY_HEIGHT
) (
  input  logic                  clk_i            ,
  input  logic                  rst_ni           ,
  input  logic                  clear_i          ,
  input  ctrl_regfile_t         reg_file_i       ,
  input  flgs_streamer_t        flgs_streamer_i  ,
  input  cntrl_scheduler_t      cntrl_scheduler_i,
  output logic                  next_iteration_o,        
  output logic                  done_o,  
  output logic                  single_iteration_o,  
  output cntrl_streamer_t       cntrl_streamer_o
);

  assign done_o = flgs_streamer_i.z_stream_sink_flags.done;
  assign next_iteration_o = 1'b0;
  always_comb begin
    single_iteration_o = 1'b0;
    if (reg_file_i.hwpe_params[M_SIZE] / (H*X_REGBUFFER_DEPTH) == 1 && reg_file_i.hwpe_params[K_SIZE] / (W*W_REGBUFFER_DEPTH) == 1) begin
      single_iteration_o = 1'b1;
    end
  end

  logic [31:0] total_len_x_w;
  assign total_len_x_w = reg_file_i.hwpe_params[N_K_M] * X_REGBUFFER_DEPTH  / (W*W_REGBUFFER_DEPTH * H*X_REGBUFFER_DEPTH) / 2;
  logic [31:0] total_len_y_z;
  assign total_len_y_z = W_REGBUFFER_DEPTH * X_REGBUFFER_DEPTH * H * reg_file_i.hwpe_params[K_M] / (W*W_REGBUFFER_DEPTH*H*X_REGBUFFER_DEPTH) / 2;

  always_comb begin : address_gen_signals
    // Here we initialize the streamer source signals
    // for the X stream source
    // X: M*N | W: N*K | Y: M*K | Z: M*K -> X is transposed
    cntrl_streamer_o.x_stream_source_ctrl.addressgen_ctrl.base_addr     = reg_file_i.hwpe_params[X_ADDR];
    cntrl_streamer_o.x_stream_source_ctrl.addressgen_ctrl.tot_len       = total_len_x_w;
    cntrl_streamer_o.x_stream_source_ctrl.addressgen_ctrl.d0_len        = reg_file_i.hwpe_params[N_SIZE];
    cntrl_streamer_o.x_stream_source_ctrl.addressgen_ctrl.d0_stride     = reg_file_i.hwpe_params[M_SIZE] * (BITW/8);
    cntrl_streamer_o.x_stream_source_ctrl.addressgen_ctrl.d1_len        = reg_file_i.hwpe_params[K_SIZE] / (W*W_REGBUFFER_DEPTH);
    cntrl_streamer_o.x_stream_source_ctrl.addressgen_ctrl.d1_stride     = 'b0;
    cntrl_streamer_o.x_stream_source_ctrl.addressgen_ctrl.d2_len        = reg_file_i.hwpe_params[M_SIZE] / (H*X_REGBUFFER_DEPTH);
    cntrl_streamer_o.x_stream_source_ctrl.addressgen_ctrl.d2_stride     = H * X_REGBUFFER_DEPTH * (BITW/8);
    cntrl_streamer_o.x_stream_source_ctrl.addressgen_ctrl.d3_stride     = 'b0;
    cntrl_streamer_o.x_stream_source_ctrl.addressgen_ctrl.dim_enable_1h = 3'b111;

    // Here we initialize the streamer source signals
    // for the W stream source
    cntrl_streamer_o.w_stream_source_ctrl.addressgen_ctrl.base_addr     = reg_file_i.hwpe_params[W_ADDR];
    cntrl_streamer_o.w_stream_source_ctrl.addressgen_ctrl.tot_len       = total_len_x_w;
    cntrl_streamer_o.w_stream_source_ctrl.addressgen_ctrl.d0_len        = reg_file_i.hwpe_params[N_SIZE];
    cntrl_streamer_o.w_stream_source_ctrl.addressgen_ctrl.d0_stride     = reg_file_i.hwpe_params[K_SIZE] * (BITW/8);
    cntrl_streamer_o.w_stream_source_ctrl.addressgen_ctrl.d1_len        = reg_file_i.hwpe_params[K_SIZE] / (W*W_REGBUFFER_DEPTH);
    cntrl_streamer_o.w_stream_source_ctrl.addressgen_ctrl.d1_stride     = W * W_REGBUFFER_DEPTH * (BITW/8);
    cntrl_streamer_o.w_stream_source_ctrl.addressgen_ctrl.d2_len        = reg_file_i.hwpe_params[M_SIZE] / (H*X_REGBUFFER_DEPTH);
    cntrl_streamer_o.w_stream_source_ctrl.addressgen_ctrl.d2_stride     = 'b0;
    cntrl_streamer_o.w_stream_source_ctrl.addressgen_ctrl.d3_stride     = 'b0;
    cntrl_streamer_o.w_stream_source_ctrl.addressgen_ctrl.dim_enable_1h = 3'b111;

    // Here we initialize the streamer source signals
    cntrl_streamer_o.y_stream_source_ctrl.addressgen_ctrl.base_addr     = reg_file_i.hwpe_params[Z_ADDR];
    cntrl_streamer_o.y_stream_source_ctrl.addressgen_ctrl.tot_len       = total_len_y_z;
    cntrl_streamer_o.y_stream_source_ctrl.addressgen_ctrl.d0_len        = 2 * H;
    cntrl_streamer_o.y_stream_source_ctrl.addressgen_ctrl.d0_stride     = reg_file_i.hwpe_params[K_SIZE] * (BITW/8);
    cntrl_streamer_o.y_stream_source_ctrl.addressgen_ctrl.d1_len        = reg_file_i.hwpe_params[K_SIZE] / (W*W_REGBUFFER_DEPTH);
    cntrl_streamer_o.y_stream_source_ctrl.addressgen_ctrl.d1_stride     = (BITW/8) * H * W_REGBUFFER_DEPTH;
    cntrl_streamer_o.y_stream_source_ctrl.addressgen_ctrl.d2_len        = reg_file_i.hwpe_params[M_SIZE] / (H*X_REGBUFFER_DEPTH);
    cntrl_streamer_o.y_stream_source_ctrl.addressgen_ctrl.d2_stride     = reg_file_i.hwpe_params[K_SIZE] * H*X_REGBUFFER_DEPTH * (BITW/8);
    cntrl_streamer_o.y_stream_source_ctrl.addressgen_ctrl.d3_stride     = 'b0;
    cntrl_streamer_o.y_stream_source_ctrl.addressgen_ctrl.dim_enable_1h = 3'b111;

    // Here we initialize the streamer sink signals for
    cntrl_streamer_o.z_stream_sink_ctrl.addressgen_ctrl.base_addr       = reg_file_i.hwpe_params[Z_ADDR];
    cntrl_streamer_o.z_stream_sink_ctrl.addressgen_ctrl.tot_len         = total_len_y_z;
    cntrl_streamer_o.z_stream_sink_ctrl.addressgen_ctrl.d0_len          = 2 * H;
    cntrl_streamer_o.z_stream_sink_ctrl.addressgen_ctrl.d0_stride       = reg_file_i.hwpe_params[K_SIZE] * (BITW/8);
    cntrl_streamer_o.z_stream_sink_ctrl.addressgen_ctrl.d1_len          = reg_file_i.hwpe_params[K_SIZE] / (W*W_REGBUFFER_DEPTH);
    cntrl_streamer_o.z_stream_sink_ctrl.addressgen_ctrl.d1_stride       = (BITW/8) * H * W_REGBUFFER_DEPTH;
    cntrl_streamer_o.z_stream_sink_ctrl.addressgen_ctrl.d2_len          = reg_file_i.hwpe_params[M_SIZE] / (H*X_REGBUFFER_DEPTH);
    cntrl_streamer_o.z_stream_sink_ctrl.addressgen_ctrl.d2_stride       = reg_file_i.hwpe_params[K_SIZE] * H*X_REGBUFFER_DEPTH * (BITW/8);
    cntrl_streamer_o.z_stream_sink_ctrl.addressgen_ctrl.d3_stride       = 'b0;
    cntrl_streamer_o.z_stream_sink_ctrl.addressgen_ctrl.dim_enable_1h   = 3'b111;
  end

  always_comb begin : req_start_assignment
    cntrl_streamer_o.x_stream_source_ctrl.req_start    = cntrl_scheduler_i.start_load_x  && flgs_streamer_i.x_stream_source_flags.ready_start;
    cntrl_streamer_o.w_stream_source_ctrl.req_start    = cntrl_scheduler_i.start_load_w  && flgs_streamer_i.w_stream_source_flags.ready_start;
    cntrl_streamer_o.y_stream_source_ctrl.req_start    = cntrl_scheduler_i.start_load_y  && flgs_streamer_i.y_stream_source_flags.ready_start;
    cntrl_streamer_o.z_stream_sink_ctrl.req_start      = cntrl_scheduler_i.start_store_z && flgs_streamer_i.z_stream_sink_flags.ready_start  ;
  end

  // NOTE: these are used for the casting, don't care for now
  assign cntrl_streamer_o.input_cast_src_fmt  = fpnew_pkg::fp_format_e'(reg_file_i.hwpe_params[OP_SELECTION][15:13]);
  assign cntrl_streamer_o.input_cast_dst_fmt  = fpnew_pkg::fp_format_e'(reg_file_i.hwpe_params[OP_SELECTION][12:10]);
  assign cntrl_streamer_o.output_cast_src_fmt = fpnew_pkg::fp_format_e'(reg_file_i.hwpe_params[OP_SELECTION][12:10]);
  assign cntrl_streamer_o.output_cast_dst_fmt = fpnew_pkg::fp_format_e'(reg_file_i.hwpe_params[OP_SELECTION][15:13]);

endmodule : ope_memory_scheduler