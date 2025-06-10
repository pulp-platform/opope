// Copyright 2023 ETH Zurich and University of Bologna.
// Solderpad Hardware License, Version 0.51, see LICENSE for details.
// SPDX-License-Identifier: SHL-0.51
//
// Yvan Tortorella <yvan.tortorella@unibo.it>
// Andrea Belano <andrea.belano2@unibo.it>
//


module ope_ctrl
  import ope_pkg::*;
  import hwpe_ctrl_package::*;
#(
  parameter  int unsigned N_CORES       = 8                      ,
  parameter  int unsigned IO_REGS       = REDMULE_REGS           ,
  parameter  int unsigned ID_WIDTH      = 8                      ,
  parameter  int unsigned SysDataWidth  = 32                     ,
  parameter  int unsigned N_CONTEXT     = 2                      ,
  parameter  int unsigned Height        = 4                      ,
  parameter  int unsigned Width         = 8                      ,
  parameter  int unsigned NumPipeRegs   = 3                      ,
  localparam int unsigned TILE          = (NumPipeRegs +1)*Height,
  parameter int unsigned   W    = ARRAY_WIDTH,
  parameter int unsigned   H    = ARRAY_HEIGHT,
  parameter int unsigned NSS            = NumStreamSources
)(
  input  logic                    clk_i             ,
  input  logic                    rst_ni            ,
  output logic                    busy_o            ,
  output logic                    clear_o           ,
  output logic [N_CORES-1:0][1:0] evt_o             ,
  input  logic                    start_cfg_i       ,
  output logic                    cfg_complete_o    ,
  // Control signals for the engine
  output logic                    priority_enforcer_enable_o,
  // Control signals for the state machine
  output cntrl_scheduler_t        cntrl_scheduler_o ,
  output cntrl_engine_t           cntrl_engine_o    ,
  
  // Priority enforcer
  input  logic                 x_granted_i,
  input  logic                 w_granted_i,
  input  logic                 y_granted_i,
  input  logic                 z_valid_i,
  input  logic                 last_iteration_i,
  output logic                 custom_priority_force_o,
  output logic                 mask_streamer_o,
  output logic                 mask_z_o,
  output logic [NSS-1:0][$clog2(NSS)-1: 0] custom_priority_o,
  
  // Memory Scheduler
  input  flgs_streamer_t        flgs_streamer_i  ,
  output cntrl_streamer_t       cntrl_streamer_o,

  // Peripheral slave port
  hwpe_ctrl_intf_periph.slave     periph
);
  
  // Main controller signals
  typedef enum logic [3:0] {
    OPE_LATCH_RST,
    OPE_IDLE,
    OPE_LOAD_X,
    OPE_LOAD_W,
    OPE_LOAD_Y,
    OPE_COMPUTING, 
    OPE_FINISHED
  } ope_ctrl_state_e;
  ope_ctrl_state_e current, next;
  
  logic clear, latch_clear;
  logic tiler_setback, tiler_valid;
  logic slave_start;
  logic change_state;
  
  hwpe_ctrl_package::ctrl_regfile_t reg_file_d, reg_file_q;
  hwpe_ctrl_package::ctrl_slave_t   cntrl_slave;
  hwpe_ctrl_package::flags_slave_t  flgs_slave;

  // Stremear controller signals
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

  ope_priority_level_e priority_level;
  ope_priority_state_e streamer_current,streamer_next;

  logic streamer_change_state;
  logic grant;
  logic done_d,done_q;
  logic start_computing,finished;

  logic[$clog2(LoadCycles)-1:0] y_counter_d,y_counter_q;
  logic[$clog2(LoadCycles)-1:0] extra_d,extra_q;
  logic[1:0] priority_counter_d,priority_counter_q;
  
  // Memory scheduler
  logic [31:0] total_len_x_w;
  logic [31:0] total_len_y_z;

  /*---------------------------------------------------------------------------------------------*/
  /*                                   Control slave interface                                   */
  /*---------------------------------------------------------------------------------------------*/

  hwpe_ctrl_slave  #(
    .REGFILE_SCM    ( 0            ),
    .N_CORES        ( N_CORES      ),
    .N_CONTEXT      ( N_CONTEXT    ),
    .N_IO_REGS      ( REDMULE_REGS ),
    .N_GENERIC_REGS ( 6            ),
    .ID_WIDTH       ( ID_WIDTH     )
  ) i_slave         (
    .clk_i          ( clk_i        ),
    .rst_ni         ( rst_ni       ),
    .clear_o        ( clear        ),
    .cfg            ( periph       ),
    .ctrl_i         ( cntrl_slave  ),
    .flags_o        ( flgs_slave   ),
    .reg_file       ( reg_file_d   )
  );

  ope_tiler  i_cfg_tiler (
    .clk_i       ( clk_i         ),
    .rst_ni      ( rst_ni        ),
    .clear_i     ( clear         ),
    .setback_i   ( tiler_setback ),
    .start_cfg_i ( start_cfg_i   ),
    .reg_file_i  ( reg_file_d    ),
    .valid_o     ( tiler_valid   ),
    .reg_file_o  ( reg_file_q    )
  );

  /*---------------------------------------------------------------------------------------------*/
  /*                                       Register island                                       */
  /*---------------------------------------------------------------------------------------------*/

  // State register
  always_ff @(posedge clk_i or negedge rst_ni) begin : state_register
    if(~rst_ni) begin
       current <= OPE_LATCH_RST;
    end else begin
      current <= next;
    end
  end

  always_ff @(posedge clk_i, negedge rst_ni) begin
    if (~rst_ni) begin
      slave_start <= 1'b0;
    end else begin
      if (clear || tiler_setback)
        slave_start <= 1'b0;
      else if (flgs_slave.start)
        slave_start <= 1'b1;
    end
  end

  /*---------------------------------------------------------------------------------------------*/
  /*                                   Register file assignment                                  */
  /*---------------------------------------------------------------------------------------------*/

  assign cntrl_engine_o.fma_is_boxed = 3'b111;
  assign cntrl_engine_o.noncomp_is_boxed = 2'b11;
  assign cntrl_engine_o.op_mod = 1'b0;
  assign cntrl_engine_o.stage1_rnd = fpnew_pkg::roundmode_e'(reg_file_q.hwpe_params[OP_SELECTION][31:29]);
  assign cntrl_engine_o.stage2_rnd = fpnew_pkg::roundmode_e'(reg_file_q.hwpe_params[OP_SELECTION][28:26]);
  assign cntrl_engine_o.op1 = fpnew_pkg::operation_e'(reg_file_q.hwpe_params[OP_SELECTION][25:21]);
  assign cntrl_engine_o.op2 = fpnew_pkg::operation_e'(reg_file_q.hwpe_params[OP_SELECTION][20:16]);
  assign cntrl_engine_o.memory_format = ope_pkg::fpu_fmt_e'(reg_file_q.hwpe_params[OP_SELECTION][15:13]);
  assign cntrl_engine_o.inner_loop_count = (reg_file_q.hwpe_params[N_SIZE][15:0]) * W_REGBUFFER_DEPTH * X_REGBUFFER_DEPTH;
  assign cntrl_engine_o.computing_format = ope_pkg::fpu_fmt_e'(reg_file_q.hwpe_params[OP_SELECTION][12:10]);
  // FIXME: because the store waits for the address gen to finish, the data that are read are 2 cycles more (power consumption)
  // Maybe find a better way to do this
  assign cntrl_engine_o.mode =  cntrl_engine_mode_e'(IDLE);
  assign cntrl_engine_o.iteration_change = 1'b0;
  
  /*---------------------------------------------------------------------------------------------*/
  /*                                        Controller FSM                                       */
  /*---------------------------------------------------------------------------------------------*/
  
  always_comb begin : controller_fsm
    next = current;

    case (current)
      OPE_LATCH_RST: next = OPE_IDLE;
      OPE_IDLE     : next = change_state  ? OPE_LOAD_W    : current;
      OPE_LOAD_W   : next = OPE_LOAD_X;
      OPE_LOAD_X   : next = OPE_LOAD_Y;
      OPE_LOAD_Y   : next = change_state  ? OPE_COMPUTING : current;
      OPE_COMPUTING: next = change_state  ? OPE_FINISHED  : current;
      OPE_FINISHED : next = OPE_IDLE;
    endcase
    
    if (clear)       next = OPE_IDLE;
  end

  always_comb begin : controller_values
    change_state                    = 1'b0;
    tiler_setback                   = 1'b0;
    latch_clear                     = 1'b0;
    cntrl_slave.done                = 1'b0;
    busy_o                          = 1'b1;
    priority_enforcer_enable_o      = 1'b0;
    cntrl_scheduler_o.rst           = 1'b0;
    cntrl_scheduler_o.finished      = 1'b0;
    cntrl_scheduler_o.start_load_w  = 1'b0;
    cntrl_scheduler_o.start_load_x  = 1'b0;
    cntrl_scheduler_o.start_store_z = 1'b0;
    cntrl_scheduler_o.start_load_y  = 1'b0;
    case (current)
      OPE_LATCH_RST: begin
        latch_clear = 1'b1;
        busy_o      = 1'b0;
      end
      OPE_IDLE     : begin
        change_state                   = slave_start & tiler_valid;
        tiler_setback                  = change_state;
        cntrl_scheduler_o.start_load_w = change_state;
        busy_o      = 1'b0;
      end
      OPE_LOAD_W   : begin
        cntrl_scheduler_o.start_load_x  = 1'b1;
      end
      OPE_LOAD_X   : begin
        cntrl_scheduler_o.start_store_z = 1'b1;
        cntrl_scheduler_o.start_load_y  = 1'b1;
      end
      OPE_LOAD_Y   : begin
        change_state = start_computing;
      end
      OPE_COMPUTING: begin
        change_state                = finished;
        priority_enforcer_enable_o  = 1'b1;
      end
      OPE_FINISHED : begin
        cntrl_slave.done           = 1'b1;
        cntrl_scheduler_o.rst      = 1'b1;
        cntrl_scheduler_o.finished = 1'b1;
        busy_o                     = 1'b0;
      end
    endcase
  end

  /*---------------------------------------------------------------------------------------------*/
  /*                                         Streamer FSM                                        */
  /*---------------------------------------------------------------------------------------------*/
  assign grant = x_granted_i | w_granted_i | y_granted_i;

  always_comb begin : streamer_fsm
    case (streamer_current)
    // -----------------------------------------------------------------------------------------------------------
      STREAMER_Y  : streamer_next = streamer_change_state                     ? STREAMER_XWY : streamer_current;
    // -----------------------------------------------------------------------------------------------------------
      STREAMER_XWY: streamer_next = streamer_change_state                     ? STREAMER_XWM : streamer_current;
    // -----------------------------------------------------------------------------------------------------------
      STREAMER_XWZ: streamer_next = streamer_change_state && last_iteration_i ? STREAMER_XWM :
                                    streamer_change_state                     ? STREAMER_XWY : streamer_current;
    // -----------------------------------------------------------------------------------------------------------
      STREAMER_Z  : streamer_next = streamer_change_state                     ? STREAMER_Y   : streamer_current;
    // -----------------------------------------------------------------------------------------------------------
      STREAMER_XWM: streamer_next = streamer_change_state && done_q           ? STREAMER_Z   : 
                                    streamer_change_state                     ? STREAMER_XWZ : streamer_current;
    // -----------------------------------------------------------------------------------------------------------
      default     : streamer_next = STREAMER_Y;
    // -----------------------------------------------------------------------------------------------------------
    endcase
  end
  
  always_comb begin : streamer_values
    y_counter_d        = y_counter_q       ;
    priority_counter_d = priority_counter_q;
    mask_streamer_o    = 1'b0;
    mask_z_o           = 1'b1;
    extra_d            = extra_q;
    done_d             = done_q ;
    finished           = 1'b0;
    start_computing    = 1'b0;
    
    case (streamer_current)
      STREAMER_Y  : begin
       y_counter_d           = y_counter_q + y_granted_i;
       streamer_change_state = (y_counter_q == LoadCycles-1) & (y_counter_d =='0);
       priority_counter_d    = 2'b11 + streamer_change_state;
       start_computing       = streamer_change_state;
      end
      STREAMER_XWY: begin
        extra_d               = 1'b0;
        y_counter_d           = y_counter_q + y_granted_i;
        streamer_change_state = (y_counter_q == LoadCycles-1) & (y_counter_d =='0);
        priority_counter_d    = priority_counter_q + grant;
      end
      STREAMER_XWM: begin
        extra_d               = extra_q + y_granted_i;
        priority_counter_d    = priority_counter_q + (grant | priority_counter_q[1]);
        mask_streamer_o       = priority_counter_q[1];
        streamer_change_state = (priority_counter_d == '0) & z_valid_i;
        mask_z_o              = ~(streamer_change_state & done_q);
      end
      STREAMER_XWZ: begin
        streamer_change_state = (y_counter_q == LoadCycles-1) & y_granted_i;
        y_counter_d           = streamer_change_state ? extra_q : y_counter_q + y_granted_i;
        priority_counter_d    = priority_counter_q + grant;
        // mask_z_o              = ^priority_counter_q;
        mask_streamer_o       = 1'b1;
        mask_z_o              = priority_counter_q[1];
        done_d                = last_iteration_i;
      end 
      STREAMER_Z  : begin
        y_counter_d           = y_counter_q + y_granted_i;
        streamer_change_state = (y_counter_q == LoadCycles-1) & (y_counter_d =='0);
        priority_counter_d    = 2'b11 + streamer_change_state;
        mask_z_o              = 1'b0;
        done_d                = 1'b0;
        finished              = streamer_change_state;
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
  
  always_ff @(posedge clk_i, negedge rst_ni) begin
    if (~rst_ni) begin
      y_counter_q        <= '0;
      priority_counter_q <= '0;
      streamer_current   <= STREAMER_Y;
      extra_q            <= '0;
      done_q             <= '0;
    end else begin
      y_counter_q        <= y_counter_d       ;
      priority_counter_q <= priority_counter_d;
      streamer_current   <= streamer_next     ;
      extra_q            <= extra_d           ;
      done_q             <= done_d            ;
    end
  end  

  /*---------------------------------------------------------------------------------------------*/
  /*                                       Memory Scheduler                                      */
  /*---------------------------------------------------------------------------------------------*/

  assign total_len_x_w = reg_file_q.hwpe_params[N_K_M] * X_REGBUFFER_DEPTH  / (W*W_REGBUFFER_DEPTH * H*X_REGBUFFER_DEPTH) / 2;
  assign total_len_y_z = W_REGBUFFER_DEPTH * X_REGBUFFER_DEPTH * H * reg_file_q.hwpe_params[K_M] / (W*W_REGBUFFER_DEPTH*H*X_REGBUFFER_DEPTH) / 2;

  always_comb begin : address_gen_signals
    // Here we initialize the streamer source signals
    // for the X stream source
    // X: M*N | W: N*K | Y: M*K | Z: M*K -> X is transposed
    cntrl_streamer_o.x_stream_source_ctrl.addressgen_ctrl.base_addr     = reg_file_q.hwpe_params[X_ADDR];
    cntrl_streamer_o.x_stream_source_ctrl.addressgen_ctrl.tot_len       = total_len_x_w;
    cntrl_streamer_o.x_stream_source_ctrl.addressgen_ctrl.d0_len        = reg_file_q.hwpe_params[N_SIZE];
    cntrl_streamer_o.x_stream_source_ctrl.addressgen_ctrl.d0_stride     = reg_file_q.hwpe_params[M_SIZE] * (BITW/8);
    cntrl_streamer_o.x_stream_source_ctrl.addressgen_ctrl.d1_len        = reg_file_q.hwpe_params[K_SIZE] / (W*W_REGBUFFER_DEPTH);
    cntrl_streamer_o.x_stream_source_ctrl.addressgen_ctrl.d1_stride     = 'b0;
    cntrl_streamer_o.x_stream_source_ctrl.addressgen_ctrl.d2_len        = reg_file_q.hwpe_params[M_SIZE] / (H*X_REGBUFFER_DEPTH);
    cntrl_streamer_o.x_stream_source_ctrl.addressgen_ctrl.d2_stride     = H * X_REGBUFFER_DEPTH * (BITW/8);
    cntrl_streamer_o.x_stream_source_ctrl.addressgen_ctrl.d3_stride     = 'b0;
    cntrl_streamer_o.x_stream_source_ctrl.addressgen_ctrl.dim_enable_1h = 3'b111;

    // Here we initialize the streamer source signals
    // for the W stream source
    cntrl_streamer_o.w_stream_source_ctrl.addressgen_ctrl.base_addr     = reg_file_q.hwpe_params[W_ADDR];
    cntrl_streamer_o.w_stream_source_ctrl.addressgen_ctrl.tot_len       = total_len_x_w;
    cntrl_streamer_o.w_stream_source_ctrl.addressgen_ctrl.d0_len        = reg_file_q.hwpe_params[N_SIZE];
    cntrl_streamer_o.w_stream_source_ctrl.addressgen_ctrl.d0_stride     = reg_file_q.hwpe_params[K_SIZE] * (BITW/8);
    cntrl_streamer_o.w_stream_source_ctrl.addressgen_ctrl.d1_len        = reg_file_q.hwpe_params[K_SIZE] / (W*W_REGBUFFER_DEPTH);
    cntrl_streamer_o.w_stream_source_ctrl.addressgen_ctrl.d1_stride     = W * W_REGBUFFER_DEPTH * (BITW/8);
    cntrl_streamer_o.w_stream_source_ctrl.addressgen_ctrl.d2_len        = reg_file_q.hwpe_params[M_SIZE] / (H*X_REGBUFFER_DEPTH);
    cntrl_streamer_o.w_stream_source_ctrl.addressgen_ctrl.d2_stride     = 'b0;
    cntrl_streamer_o.w_stream_source_ctrl.addressgen_ctrl.d3_stride     = 'b0;
    cntrl_streamer_o.w_stream_source_ctrl.addressgen_ctrl.dim_enable_1h = 3'b111;

    // Here we initialize the streamer source signals
    cntrl_streamer_o.y_stream_source_ctrl.addressgen_ctrl.base_addr     = reg_file_q.hwpe_params[Z_ADDR];
    cntrl_streamer_o.y_stream_source_ctrl.addressgen_ctrl.tot_len       = total_len_y_z;
    cntrl_streamer_o.y_stream_source_ctrl.addressgen_ctrl.d0_len        = 2 * H;
    cntrl_streamer_o.y_stream_source_ctrl.addressgen_ctrl.d0_stride     = reg_file_q.hwpe_params[K_SIZE] * (BITW/8);
    cntrl_streamer_o.y_stream_source_ctrl.addressgen_ctrl.d1_len        = reg_file_q.hwpe_params[K_SIZE] / (W*W_REGBUFFER_DEPTH);
    cntrl_streamer_o.y_stream_source_ctrl.addressgen_ctrl.d1_stride     = (BITW/8) * H * W_REGBUFFER_DEPTH;
    cntrl_streamer_o.y_stream_source_ctrl.addressgen_ctrl.d2_len        = reg_file_q.hwpe_params[M_SIZE] / (H*X_REGBUFFER_DEPTH);
    cntrl_streamer_o.y_stream_source_ctrl.addressgen_ctrl.d2_stride     = reg_file_q.hwpe_params[K_SIZE] * H*X_REGBUFFER_DEPTH * (BITW/8);
    cntrl_streamer_o.y_stream_source_ctrl.addressgen_ctrl.d3_stride     = 'b0;
    cntrl_streamer_o.y_stream_source_ctrl.addressgen_ctrl.dim_enable_1h = 3'b111;

    // Here we initialize the streamer sink signals for
    cntrl_streamer_o.z_stream_sink_ctrl.addressgen_ctrl.base_addr       = reg_file_q.hwpe_params[Z_ADDR];
    cntrl_streamer_o.z_stream_sink_ctrl.addressgen_ctrl.tot_len         = total_len_y_z;
    cntrl_streamer_o.z_stream_sink_ctrl.addressgen_ctrl.d0_len          = 2 * H;
    cntrl_streamer_o.z_stream_sink_ctrl.addressgen_ctrl.d0_stride       = reg_file_q.hwpe_params[K_SIZE] * (BITW/8);
    cntrl_streamer_o.z_stream_sink_ctrl.addressgen_ctrl.d1_len          = reg_file_q.hwpe_params[K_SIZE] / (W*W_REGBUFFER_DEPTH);
    cntrl_streamer_o.z_stream_sink_ctrl.addressgen_ctrl.d1_stride       = (BITW/8) * H * W_REGBUFFER_DEPTH;
    cntrl_streamer_o.z_stream_sink_ctrl.addressgen_ctrl.d2_len          = reg_file_q.hwpe_params[M_SIZE] / (H*X_REGBUFFER_DEPTH);
    cntrl_streamer_o.z_stream_sink_ctrl.addressgen_ctrl.d2_stride       = reg_file_q.hwpe_params[K_SIZE] * H*X_REGBUFFER_DEPTH * (BITW/8);
    cntrl_streamer_o.z_stream_sink_ctrl.addressgen_ctrl.d3_stride       = 'b0;
    cntrl_streamer_o.z_stream_sink_ctrl.addressgen_ctrl.dim_enable_1h   = 3'b111;
  end

  always_comb begin : req_start_assignment
    cntrl_streamer_o.x_stream_source_ctrl.req_start    = cntrl_scheduler_o.start_load_x  && flgs_streamer_i.x_stream_source_flags.ready_start;
    cntrl_streamer_o.w_stream_source_ctrl.req_start    = cntrl_scheduler_o.start_load_w  && flgs_streamer_i.w_stream_source_flags.ready_start;
    cntrl_streamer_o.y_stream_source_ctrl.req_start    = cntrl_scheduler_o.start_load_y  && flgs_streamer_i.y_stream_source_flags.ready_start;
    cntrl_streamer_o.z_stream_sink_ctrl.req_start      = cntrl_scheduler_o.start_store_z && flgs_streamer_i.z_stream_sink_flags.ready_start  ;
  end

  // NOTE: these are used for the casting, don't care for now
  assign cntrl_streamer_o.input_cast_src_fmt  = fpnew_pkg::fp_format_e'(reg_file_q.hwpe_params[OP_SELECTION][15:13]);
  assign cntrl_streamer_o.input_cast_dst_fmt  = fpnew_pkg::fp_format_e'(reg_file_q.hwpe_params[OP_SELECTION][12:10]);
  assign cntrl_streamer_o.output_cast_src_fmt = fpnew_pkg::fp_format_e'(reg_file_q.hwpe_params[OP_SELECTION][12:10]);
  assign cntrl_streamer_o.output_cast_dst_fmt = fpnew_pkg::fp_format_e'(reg_file_q.hwpe_params[OP_SELECTION][15:13]);


  /*---------------------------------------------------------------------------------------------*/
  /*                            Other combinational assigmnets                                   */
  /*---------------------------------------------------------------------------------------------*/
  assign evt_o          = flgs_slave.evt[N_CORES-1:0];
  assign clear_o        = clear || latch_clear;
  assign cfg_complete_o = tiler_valid;

  assign custom_priority_force_o = 1'b1;

endmodule : ope_ctrl
