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
  localparam int unsigned TILE          = (NumPipeRegs +1)*Height
)(
  input  logic                    clk_i             ,
  input  logic                    rst_ni            ,
  input  logic                    test_mode_i       ,
  output logic                    busy_o            ,
  output logic                    clear_o           ,
  output logic [N_CORES-1:0][1:0] evt_o             ,
  output ctrl_regfile_t           reg_file_o        ,
  input  logic                    reg_enable_i      ,
  input  logic                    start_cfg_i       ,
  input  flgs_streamer_t          flgs_streamer_i   ,
  input logic system_busy_i,
  // input  flags_fifo_t             x_fifo_flgs_i     ,
  output logic                    cfg_complete_o    ,
  // Flags coming from the state machine
  input  logic                    w_loaded_i        ,
  input logic               memory_scheduler_done_i,
  input logic               memory_scheduler_next_iteration_i        , 
  input logic               accumulation_reg_full_first_i,
  // Control signals for the engine
  output logic                    flush_o           ,
  output logic                    priority_enforcer_enable_o,
  // Control signals for the state machine
  output cntrl_scheduler_t        cntrl_scheduler_o ,
  output x_regbuffer_ctrl_t       x_regbuffer_ctrl_o,
  output cntrl_engine_t           cntrl_engine_o    ,

  // Peripheral slave port
  hwpe_ctrl_intf_periph.slave     periph
);

  logic        clear, latch_clear;
  logic        tiler_setback, tiler_valid;

  typedef enum logic [3:0] {
    OPE_LATCH_RST,
    OPE_IDLE,
    OPE_STARTING,
    OPE_LOAD_Y,
    OPE_COMPUTING, 
    OPE_FINISHED
  } ope_ctrl_state_e;

  ope_ctrl_state_e current, next;

  hwpe_ctrl_package::ctrl_regfile_t reg_file_d, reg_file_q;
  hwpe_ctrl_package::ctrl_slave_t   cntrl_slave;
  hwpe_ctrl_package::flags_slave_t  flgs_slave;

  // Control slave interface
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

  assign cfg_complete_o = tiler_valid;
  /*---------------------------------------------------------------------------------------------*/
  /*                                       Register island                                       */
  /*---------------------------------------------------------------------------------------------*/

  // State register
  always_ff @(posedge clk_i or negedge rst_ni) begin : state_register
    if(~rst_ni) begin
       current <= OPE_LATCH_RST;
    end else begin
      if (clear)
        current <= OPE_IDLE;
      else
        current <= next;
    end
  end

  logic slave_start;
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
  assign reg_file_o = reg_file_q;

  assign cntrl_engine_o.fma_is_boxed = 3'b111;
  assign cntrl_engine_o.noncomp_is_boxed = 2'b11;
  assign cntrl_engine_o.op_mod = 1'b0;
  assign cntrl_engine_o.stage1_rnd = fpnew_pkg::roundmode_e'(reg_file_q.hwpe_params[OP_SELECTION][31:29]);
  assign cntrl_engine_o.stage2_rnd = fpnew_pkg::roundmode_e'(reg_file_q.hwpe_params[OP_SELECTION][28:26]);
  assign cntrl_engine_o.op1 = fpnew_pkg::operation_e'(reg_file_q.hwpe_params[OP_SELECTION][25:21]);
  assign cntrl_engine_o.op2 = fpnew_pkg::operation_e'(reg_file_q.hwpe_params[OP_SELECTION][20:16]);
  assign cntrl_engine_o.memory_format = ope_pkg::fpu_fmt_e'(reg_file_q.hwpe_params[OP_SELECTION][15:13]);
  assign cntrl_engine_o.inner_loop_count = (reg_file_o.hwpe_params[N_SIZE][15:0]) * W_REGBUFFER_DEPTH * X_REGBUFFER_DEPTH;

  assign cntrl_engine_o.computing_format = ope_pkg::fpu_fmt_e'(reg_file_q.hwpe_params[OP_SELECTION][12:10]);
  /*---------------------------------------------------------------------------------------------*/
  /*                                        Controller FSM                                       */
  /*---------------------------------------------------------------------------------------------*/




  assign tiler_setback                  = current == OPE_IDLE && next == OPE_STARTING;
  assign cntrl_slave.done               = current == OPE_FINISHED;
  assign busy_o                         = current != OPE_LATCH_RST || current != OPE_IDLE || current != OPE_FINISHED;
  assign flush_o                        = 'b0;
  // assign flush_o                        = current == OPE_FINISHED;
  assign cntrl_scheduler_o.rst          = current == OPE_FINISHED;
  assign cntrl_scheduler_o.finished     = current == OPE_FINISHED;
  assign latch_clear                    = current == OPE_LATCH_RST;

  logic [$clog2(Height) - 1: 0] y_row_index_q, y_row_index_d;
  // FIXME: because the store waits for the address gen to finish, the data that are read are 2 cycles more (power consumption)
  // Maybe find a better way to do this
  assign cntrl_engine_o.mode =  cntrl_engine_mode_e'(IDLE);

  assign cntrl_engine_o.iteration_change = 1'b0;
  

  assign cntrl_scheduler_o.start_load_x  = current == OPE_LOAD_Y && next == OPE_COMPUTING;
  assign cntrl_scheduler_o.start_load_w  = current == OPE_LOAD_Y && next == OPE_COMPUTING;
  assign cntrl_scheduler_o.start_store_z = current == OPE_LOAD_Y &&  next == OPE_COMPUTING;
  assign cntrl_scheduler_o.start_load_y  = current == OPE_STARTING && next == OPE_LOAD_Y;
  assign priority_enforcer_enable_o = current == OPE_COMPUTING;

  always_comb begin : controller_fsm
    next = current;

    case (current)
      OPE_LATCH_RST: begin
        next = OPE_IDLE;
      end

      OPE_IDLE: begin
        if (slave_start & tiler_valid) begin
          next = OPE_STARTING;
        end
      end

      OPE_STARTING: begin
        next = OPE_LOAD_Y;
      end

      OPE_LOAD_Y: begin
        if (accumulation_reg_full_first_i) begin
          next = OPE_COMPUTING;
        end
      end

      OPE_COMPUTING: begin
        if (memory_scheduler_done_i) begin
          next = OPE_FINISHED;
        end
      end
      
      OPE_FINISHED: begin
        next = OPE_IDLE;
      end
    endcase
  end

  /*---------------------------------------------------------------------------------------------*/
  /*                            Other combinational assigmnets                                   */
  /*---------------------------------------------------------------------------------------------*/
  assign evt_o   = flgs_slave.evt[N_CORES-1:0];
  assign clear_o = clear || latch_clear;

endmodule : ope_ctrl
