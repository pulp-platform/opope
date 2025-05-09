// Copyright 2023 ETH Zurich and University of Bologna.
// Solderpad Hardware License, Version 0.51, see LICENSE for details.
// SPDX-License-Identifier: SHL-0.51
//
// Yvan Tortorella <yvan.tortorella@unibo.it>
//

timeunit 1ps; timeprecision 1ps;

import hci_package::*;

module redmule_tb
  import ope_pkg::*;
#(
  parameter TCP = 2.0ns, // clock period, 1 GHz clock
  parameter TA  = 0.4ns, // application time
  parameter TT  = 1.6ns  // test time
)(
  input logic clk_i,
  input logic rst_ni,
  input logic fetch_enable_i
);

  localparam int unsigned DW = ope_pkg::DATA_W;
  ope_pkg::cntrl_scheduler_t debug_cntrl_scheduler;

  // parameters
  localparam int unsigned PROB_STALL = 0;
  localparam int unsigned NC = 1;
  localparam int unsigned ID = 10;

  localparam int unsigned MP     = DW/32;
  
  localparam int unsigned MEMORY_SIZE = 192*1024;
  localparam int unsigned STACK_MEMORY_SIZE = 192*1024;
  localparam int unsigned PULP_XPULP = 1;
  localparam int unsigned FPU = 0;
  localparam int unsigned PULP_ZFINX = 0;
  localparam logic [31:0] BASE_ADDR = 32'h1c000000;
  localparam logic [31:0] HWPE_ADDR_BASE_BIT = 20;
  localparam bit          USE_ECC = 0;
  localparam int unsigned EW = (USE_ECC) ? 72 : DEFAULT_EW;

  // global signals
  string stim_instr, stim_data_x_w, stim_data_y_z;
  logic test_mode;
  logic [31:0] core_boot_addr;
  logic redmule_busy;

  hwpe_stream_intf_tcdm instr[0:0]  (.clk(clk_i));
  hwpe_stream_intf_tcdm stack[0:0]  (.clk(clk_i));
  hwpe_stream_intf_tcdm tcdm_x_w [MP:0] (.clk(clk_i));
  hwpe_stream_intf_tcdm tcdm_y_z [MP:0] (.clk(clk_i));

  logic [NC-1:0][1:0] evt;

  logic [MP-1:0]       tcdm_req_x_w;
  logic [MP-1:0]       tcdm_gnt_x_w;
  logic [MP-1:0][31:0] tcdm_add_x_w;
  logic [MP-1:0]       tcdm_wen_x_w;
  logic [MP-1:0][3:0]  tcdm_be_x_w;
  logic [MP-1:0][31:0] tcdm_data_x_w;
  logic [EW-1:0]       tcdm_ecc_x_w;
  logic [MP-1:0][31:0] tcdm_r_data_x_w;
  logic [MP-1:0]       tcdm_r_valid_x_w;
  logic                tcdm_r_opc_x_w;
  logic                tcdm_r_user_x_w;
  logic [EW-1:0]       tcdm_r_ecc_x_w;

  logic [MP-1:0]       tcdm_req_y_z;
  logic [MP-1:0]       tcdm_gnt_y_z;
  logic [MP-1:0][31:0] tcdm_add_y_z;
  logic [MP-1:0]       tcdm_wen_y_z;
  logic [MP-1:0][3:0]  tcdm_be_y_z;
  logic [MP-1:0][31:0] tcdm_data_y_z;
  logic [EW-1:0]       tcdm_ecc_y_z;
  logic [MP-1:0][31:0] tcdm_r_data_y_z;
  logic [MP-1:0]       tcdm_r_valid_y_z;
  logic                tcdm_r_opc_y_z;
  logic                tcdm_r_user_y_z;
  logic [EW-1:0]       tcdm_r_ecc_y_z;

  logic          periph_req;
  logic          periph_gnt;
  logic [31:0]   periph_add;
  logic          periph_wen;
  logic [3:0]    periph_be;
  logic [31:0]   periph_data;
  logic [ID-1:0] periph_id;
  logic [31:0]   periph_r_data;
  logic          periph_r_valid;
  logic [ID-1:0] periph_r_id;

  logic          instr_req;
  logic          instr_gnt;
  logic          instr_rvalid;
  logic [31:0]   instr_addr;
  logic [31:0]   instr_rdata;

  logic          data_req;
  logic          data_gnt;
  logic          data_rvalid;
  logic          data_we;
  logic [3:0]    data_be;
  logic [31:0]   data_addr;
  logic [31:0]   data_wdata;
  logic [31:0]   data_rdata;
  logic          data_err;
  logic          core_sleep;

  // bindings
  always_comb begin : bind_periph
    periph_req  = data_req & data_addr[HWPE_ADDR_BASE_BIT];
    periph_add  = data_addr;
    periph_wen  = ~data_we;
    periph_be   = data_be;
    periph_data = data_wdata;
    periph_id   = '0;
  end

  always_comb begin : bind_instrs
    instr[0].req  = instr_req;
    instr[0].add  = instr_addr;
    instr[0].wen  = 1'b1;
    instr[0].be   = '0;
    instr[0].data = '0;
    instr_gnt    = instr[0].gnt;
    instr_rdata  = instr[0].r_data;
    instr_rvalid = instr[0].r_valid;
  end

  always_comb begin : bind_stack
    stack[0].req  = data_req & (data_addr[31:24] == '0) & ~data_addr[HWPE_ADDR_BASE_BIT];
    stack[0].add  = data_addr;
    stack[0].wen  = ~data_we;
    stack[0].be   = data_be;
    stack[0].data = data_wdata;
  end

  logic other_r_valid;
  always_ff @(posedge clk_i or negedge rst_ni) begin
    if (~rst_ni)
      other_r_valid <= '0;
    else
      other_r_valid <= data_req & (data_addr[31:24] == 8'h80);
  end

  for(genvar ii=0; ii<MP; ii++) begin : tcdm_binding
    assign tcdm_x_w[ii].req  = tcdm_req_x_w  [ii];
    assign tcdm_x_w[ii].add  = tcdm_add_x_w  [ii];
    assign tcdm_x_w[ii].wen  = tcdm_wen_x_w  [ii];
    assign tcdm_x_w[ii].be   = tcdm_be_x_w   [ii];

    assign tcdm_y_z[ii].req  = tcdm_req_y_z  [ii];
    assign tcdm_y_z[ii].add  = tcdm_add_y_z  [ii];
    assign tcdm_y_z[ii].wen  = tcdm_wen_y_z  [ii];
    assign tcdm_y_z[ii].be   = tcdm_be_y_z   [ii];

    if (~USE_ECC) begin
      assign tcdm_x_w[ii].data = tcdm_data_x_w [ii];
      assign tcdm_y_z[ii].data = tcdm_data_y_z [ii];
    end
    assign tcdm_gnt_x_w     [ii] = tcdm_x_w[ii].gnt;
    assign tcdm_r_data_x_w  [ii] = tcdm_x_w[ii].r_data;
    assign tcdm_r_valid_x_w [ii] = tcdm_x_w[ii].r_valid;

    assign tcdm_gnt_y_z     [ii] = tcdm_y_z[ii].gnt;
    assign tcdm_r_data_y_z  [ii] = tcdm_y_z[ii].r_data;
    assign tcdm_r_valid_y_z [ii] = tcdm_y_z[ii].r_valid;
  end

  // Fixme: check if this writes the data
  assign tcdm_x_w[MP].req  = data_req & (data_addr[31:24] != '0) & (data_addr[31:24] != 8'h80) & ~data_addr[HWPE_ADDR_BASE_BIT];
  // assign tcdm_x_w[MP].req  = data_req & (data_addr[31:24] != '0) & (data_addr[31:24] != 8'h80) & ~data_addr[HWPE_ADDR_BASE_BIT] & (data_addr >= 32'h1c010000 & data_addr < (32'h1c010000 + MEMORY_SIZE));
  assign tcdm_x_w[MP].add  = data_addr;
  assign tcdm_x_w[MP].wen  = ~data_we;
  assign tcdm_x_w[MP].be   = data_be;
  assign tcdm_x_w[MP].data = data_wdata;
  assign tcdm_r_opc_x_w   = 0;
  assign tcdm_r_user_x_w  = 0;

  logic        data_gnt_x_w, data_gnt_y_z;
  logic [31:0] data_rdata_x_w, data_rdata_y_z;
  logic        data_rvalid_x_w, data_rvalid_y_z;

  assign data_gnt_x_w    = periph_req ?
                       periph_gnt : stack[0].req ?
                                    stack[0].gnt : tcdm_x_w[MP].req ?
                                                   tcdm_x_w[MP].gnt : '1;
  assign data_rdata_x_w  = periph_r_valid ? periph_r_data  :
                                        stack[0].r_valid ? stack[0].r_data  :
                                                           tcdm_x_w[MP].r_valid ? tcdm_x_w[MP].r_data : '0;
  assign data_rvalid_x_w = periph_r_valid   |
                       stack[0].r_valid |
                       tcdm_x_w[MP].r_valid |
                       other_r_valid    ;

  assign tcdm_y_z[MP].req  = data_req & (data_addr[31:24] != '0) & (data_addr[31:24] != 8'h80) & ~data_addr[HWPE_ADDR_BASE_BIT] & (data_addr >= 32'h1c080000 & data_addr < (32'h1c080000 + 128*1024));
  assign tcdm_y_z[MP].add  = data_addr;
  assign tcdm_y_z[MP].wen  = ~data_we;
  assign tcdm_y_z[MP].be   = data_be;
  assign tcdm_y_z[MP].data = data_wdata;
  assign tcdm_r_opc_y_z   = 0;
  assign tcdm_r_user_y_z  = 0;

  assign data_gnt_y_z    = periph_req ?
                       periph_gnt : stack[0].req ?
                                    stack[0].gnt : tcdm_y_z[MP].req ?
                                                   tcdm_y_z[MP].gnt : '1;
  assign data_rdata_y_z  = periph_r_valid ? periph_r_data  :
                                        stack[0].r_valid ? stack[0].r_data  :
                                                           tcdm_y_z[MP].r_valid ? tcdm_y_z[MP].r_data : '0;
  assign data_rvalid_y_z = periph_r_valid   |
                       stack[0].r_valid |
                       tcdm_y_z[MP].r_valid |
                       other_r_valid    ;


  assign data_gnt = data_gnt_x_w | data_gnt_y_z;
  assign data_rdata = data_rdata_x_w | data_rdata_y_z; // FIXME: this should work, they should happen at the same time 
  assign data_rvalid = data_rvalid_x_w | data_rvalid_y_z;

  // assign data_rdata = data_gnt_x_w ? data_rdata_x_w : data_rdata_y_z;
  // assign data_rvalid = data_gnt_x_w ? data_rvalid_x_w : data_rvalid_y_z;
  assign tcdm_r_ecc_x_w = '0;
  assign tcdm_r_ecc_y_z = '0;
  assign tcdm_r_data_enc_x_w = '0;
  assign tcdm_r_data_enc_y_z = '0;
  /* if (USE_ECC) begin : gen_r_ecc
    // RESPONSE PHASE ENCODING
    logic [MP-1:0][38:0] tcdm_r_data_enc;
    for(genvar ii=0; ii<MP; ii++) begin : r_data_encoding
      hsiao_ecc_enc #(
        .DataWidth ( 32 )
      ) i_r_data_enc (
        .in  (tcdm[ii].r_data),
        .out (tcdm_r_data_enc[ii])
      );
      assign tcdm_r_ecc[(ii+1)*7-1:ii*7] = tcdm_r_data_enc[ii][38:32];
    end
    assign tcdm_r_ecc[EW-1:(7*MP)] = '0;
  end else begin : gen_no_r_ecc
    assign tcdm_r_ecc = '0;
  end

  if (USE_ECC) begin : gen_ecc_dec
    // REQUEST PHASE DECODING
    for(genvar ii=0; ii<MP; ii++) begin : data_decoding
      hsiao_ecc_dec #(
        .DataWidth ( 32 )
      ) i_data_dec (
        .in         ( { tcdm_ecc[(ii+1)*7-1+9:ii*7+9], tcdm_data[ii] } ),
        .out        ( tcdm[ii].data ),
        .syndrome_o ( ),
        .err_o      ( )
      );
    end

    hsiao_ecc_dec #(
      .DataWidth ( 32+36+1 )
    ) i_meta_dec (
      .in         ( { tcdm_ecc[8:0], tcdm_add[0], tcdm_wen[0], tcdm_be } ),
      .out        (  ),
      .syndrome_o (  ),
      .err_o      (  )
    );
  end */




  ope_wrap #(
    .ID_WIDTH           ( ID                 ),
    .N_CORES            ( NC                 ),
    .DW                 ( DW                 ),
    .MP                 ( DW/32              ),
    .EW                 ( EW                 )
  ) i_redmule_wrap      (
    .clk_i              ( clk_i              ),
    .rst_ni             ( rst_ni             ),
    .test_mode_i        ( test_mode          ),
    .evt_o              ( evt                ),
    .busy_o             ( redmule_busy       ),

    .tcdm_req_x_w_o         ( tcdm_req_x_w           ),
    .tcdm_add_x_w_o         ( tcdm_add_x_w           ),
    .tcdm_wen_x_w_o         ( tcdm_wen_x_w           ),
    .tcdm_be_x_w_o          ( tcdm_be_x_w            ),
    .tcdm_data_x_w_o        ( tcdm_data_x_w          ),
    .tcdm_ecc_x_w_o         ( tcdm_ecc_x_w           ),
    .tcdm_gnt_x_w_i         ( tcdm_gnt_x_w           ),
    .tcdm_r_data_x_w_i      ( tcdm_r_data_x_w        ),
    .tcdm_r_valid_x_w_i     ( tcdm_r_valid_x_w       ),
    .tcdm_r_opc_x_w_i       ( tcdm_r_opc_x_w         ),
    .tcdm_r_user_x_w_i      ( tcdm_r_user_x_w        ),
    .tcdm_r_ecc_x_w_i       ( tcdm_r_ecc_x_w         ),

    .tcdm_req_y_z_o         ( tcdm_req_y_z           ),
    .tcdm_add_y_z_o         ( tcdm_add_y_z           ),
    .tcdm_wen_y_z_o         ( tcdm_wen_y_z           ),
    .tcdm_be_y_z_o          ( tcdm_be_y_z            ),
    .tcdm_data_y_z_o        ( tcdm_data_y_z          ),
    .tcdm_ecc_y_z_o         ( tcdm_ecc_y_z           ),
    .tcdm_gnt_y_z_i         ( tcdm_gnt_y_z           ),
    .tcdm_r_data_y_z_i      ( tcdm_r_data_y_z        ),
    .tcdm_r_valid_y_z_i     ( tcdm_r_valid_y_z       ),
    .tcdm_r_opc_y_z_i       ( tcdm_r_opc_y_z         ),
    .tcdm_r_user_y_z_i      ( tcdm_r_user_y_z        ),
    .tcdm_r_ecc_y_z_i       ( tcdm_r_ecc_y_z         ),

    .debug_cntrl_scheduler_o(debug_cntrl_scheduler),
    .periph_req_i       ( periph_req         ),
    .periph_gnt_o       ( periph_gnt         ),
    .periph_add_i       ( periph_add         ),
    .periph_wen_i       ( periph_wen         ),
    .periph_be_i        ( periph_be          ),
    .periph_data_i      ( periph_data        ),
    .periph_id_i        ( periph_id          ),
    .periph_r_data_o    ( periph_r_data      ),
    .periph_r_valid_o   ( periph_r_valid     ),
    .periph_r_id_o      ( periph_r_id        )
  );



  tb_dummy_memory  #(
    .MP             ( MP + 1        ),
    .MEMORY_SIZE    ( 458752        ),
    .BASE_ADDR      ( 32'h1c010000  ),
    .PROB_STALL     ( PROB_STALL    ),
    .TCP            ( TCP           ),
    .TA             ( TA            ),
    .TT             ( TT            )
  ) i_dummy_dmemory_x_w (
    .clk_i          ( clk_i         ),
    .rst_ni         ( rst_ni        ),
    .clk_delayed_i  ( '0            ),
    .randomize_i    ( 1'b0          ),
    .enable_i       ( 1'b1          ),
    .stallable_i    ( 1'b1          ),
    .tcdm           ( tcdm_x_w          )
  );

  tb_dummy_memory  #(
    .MP             ( MP + 1        ),
    .MEMORY_SIZE    ( 128*1024      ),
    .BASE_ADDR      ( 32'h1c080000  ), // FIXME: finalize the required address
    .PROB_STALL     ( PROB_STALL    ),
    .TCP            ( TCP           ),
    .TA             ( TA            ),
    .TT             ( TT            )
  ) i_dummy_dmemory_y_z (
    .clk_i          ( clk_i         ),
    .rst_ni         ( rst_ni        ),
    .clk_delayed_i  ( '0            ),
    .randomize_i    ( 1'b0          ),
    .enable_i       ( 1'b1          ),
    .stallable_i    ( 1'b1          ),
    .tcdm           ( tcdm_y_z          )
  );

  tb_dummy_memory  #(
    .MP             ( 1           ),
    .MEMORY_SIZE    ( MEMORY_SIZE ),
    .BASE_ADDR      ( BASE_ADDR   ),
    .PROB_STALL     ( 0           ),
    .TCP            ( TCP         ),
    .TA             ( TA          ),
    .TT             ( TT          )
  ) i_dummy_imemory (
    .clk_i          ( clk_i       ),
    .rst_ni         ( rst_ni      ),
    .clk_delayed_i  ( '0          ),
    .randomize_i    ( 1'b0        ),
    .enable_i       ( 1'b1        ),
    .stallable_i    ( 1'b0        ),
    .tcdm           ( instr       )
  );

  tb_dummy_memory       #(
    .MP                  ( 1                 ),
    .MEMORY_SIZE         ( STACK_MEMORY_SIZE ),
    .BASE_ADDR           ( BASE_ADDR         ),
    .PROB_STALL          ( 0                 ),
    .TCP                 ( TCP               ),
    .TA                  ( TA                ),
    .TT                  ( TT                )
  ) i_dummy_stack_memory (
    .clk_i               ( clk_i             ),
    .rst_ni              ( rst_ni            ),
    .clk_delayed_i       ( '0                ),
    .randomize_i         ( 1'b0              ),
    .enable_i            ( 1'b1              ),
    .stallable_i         ( 1'b0              ),
    .tcdm                ( stack             )
  );

  cv32e40p_core #(
    .PULP_XPULP     ( PULP_XPULP ),
    .FPU            ( FPU        ),
    .PULP_ZFINX     ( PULP_ZFINX )
  ) i_cv32e40p_core (
    // Clock and Reset
    .clk_i               ( clk_i          ),
    .rst_ni              ( rst_ni         ),
    .pulp_clock_en_i     ( 1'b1           ),  // PULP clock enable (only used if PULP_CLUSTER = 1)
    .scan_cg_en_i        ( 1'b0           ),  // Enable all clock gates for testing
    // Core ID, Cluster ID, debug mode halt address and boot address are considered more or less static
    .boot_addr_i         ( core_boot_addr ),
    .mtvec_addr_i        ( '0             ),
    .dm_halt_addr_i      ( '0             ),
    .hart_id_i           ( '0             ),
    .dm_exception_addr_i ( '0             ),
    // Instruction memory interface
    .instr_req_o         ( instr_req    ),
    .instr_gnt_i         ( instr_gnt    ),
    .instr_rvalid_i      ( instr_rvalid ),
    .instr_addr_o        ( instr_addr   ),
    .instr_rdata_i       ( instr_rdata  ),
    // Data memory interface
    .data_req_o          ( data_req     ),
    .data_gnt_i          ( data_gnt     ),
    .data_rvalid_i       ( data_rvalid  ),
    .data_we_o           ( data_we      ),
    .data_be_o           ( data_be      ),
    .data_addr_o         ( data_addr    ),
    .data_wdata_o        ( data_wdata   ),
    .data_rdata_i        ( data_rdata   ),
    // apu-interconnect
    // handshake signals
    .apu_req_o           (              ),
    .apu_gnt_i           ( '0           ),
    // request channel
    .apu_operands_o      (              ),
    .apu_op_o            (              ),
    .apu_flags_o         (              ),
    // response channel
    .apu_rvalid_i        ( '0           ),
    .apu_result_i        ( '0           ),
    .apu_flags_i         ( '0           ),
    // Interrupt inputs
    .irq_i               ({28'd0, evt[0][0], 3'd0}),  // CLINT interrupts + CLINT extension interrupts
    .irq_ack_o           (              ),
    .irq_id_o            (              ),
    // Debug Interface
    .debug_req_i         ( '0           ),
    .debug_havereset_o   (              ),
    .debug_running_o     (              ),
    .debug_halted_o      (              ),
    // CPU Control Signals
    .fetch_enable_i      ( fetch_enable_i ),
    .core_sleep_o        ( core_sleep     )
  );

  integer f_x, f_W, f_y, f_tau;
  logic start;
  int cnt_rd, cnt_wr;

  int errors = -1;
  always_ff @(posedge clk_i)
  begin
    if((data_addr == 32'h80000000 ) && (data_we & data_req == 1'b1)) begin
      errors = data_wdata;
    end
    if((data_addr == 32'h80000004 ) && (data_we & data_req == 1'b1)) begin
      $write("%c", data_wdata);
    end
  end

  int counter = 0;
  int measured_count = 0;
  bit counting = 0;
  parameter int EXPECTED_VALID_COUNT = 64; //NOTE: this has an issue when the TCDM DATA_W is too large, the code returns empty data

  logic [MP-1:0][31:0] prev_tcdm_r_data;
  logic [MP-1:0][31:0] prev_tcdm_data;
  int start_counter = 0;
  int end_counter = 0;
  int global_counter = 0;
  int channel_valid_count;
  always_ff @(posedge clk_i) begin
    global_counter <= global_counter + 1;
    if (global_counter % 200 == 0) $display("[%0t] Cycle: %0d", $time, global_counter);
  end
  always_ff @(posedge clk_i) begin 
    if (!counting && (prev_tcdm_r_data == 'b0) && (tcdm_r_data_y_z != 'b0)) begin // FIXME: this needs rethinking
      counting <= 1;
      start_counter <= global_counter;
    end
    if (counting) begin 
      channel_valid_count = 0;
      for (int i = 0; i < MP; i++) begin if (tcdm_data_y_z[i] != 'b0) channel_valid_count++;end
      counter <= counter + channel_valid_count;
      if (counter >= EXPECTED_VALID_COUNT) begin
        counting <= 0;
        end_counter <= global_counter;
        measured_count <= global_counter - start_counter;
      end
    end

    prev_tcdm_r_data <= tcdm_r_data_y_z;
    prev_tcdm_data <= tcdm_data_y_z;
  end

  int periphery_start_counter = 0;
  int periphery_end_counter = 0;
  bit periphery_counting = 0;
  
  logic check_start_config, prev_check_start_config;
  logic prev_finished_redmule, finished_redmule;
  
  assign check_start_config = (periph_req && (periph_add[7:0] == 'h54) && (!periph_wen) && (periph_gnt)) ? 1'b1: 1'b0;
  assign finished_redmule = debug_cntrl_scheduler.finished;
  // assign finished_redmule = i_redmule_wrap.debug_cntrl_scheduler_o_finished_;

  always_ff @(posedge clk_i) begin 
    if (!periphery_counting && (prev_check_start_config == 1'b0) && (check_start_config == 1'b1)) begin 
      periphery_counting <= 1;
      periphery_start_counter <= global_counter;
    end
    if (periphery_counting &&(prev_finished_redmule == 1'b0) && (finished_redmule)) begin 
      periphery_counting <= 0;
      periphery_end_counter <= global_counter;
    end

  prev_check_start_config <= check_start_config;
  prev_finished_redmule <= finished_redmule;
  end


    // Metrics
   // TCDM access counters
   int start_tcdm_counter_x_w = 0;
   int end_tcdm_counter_x_w = 0;
   int tcdm_read_counter_x_w = 0;
   int tcdm_write_counter_x_w = 0;
 
   always_ff @(posedge clk_i) begin
     if (tcdm_req_x_w && start_tcdm_counter_x_w == 0) start_tcdm_counter_x_w <= global_counter;
     if (tcdm_req_x_w) end_tcdm_counter_x_w <= global_counter;
     if (tcdm_req_x_w && tcdm_wen_x_w) tcdm_read_counter_x_w++; 
     if (tcdm_req_x_w && !tcdm_wen_x_w) tcdm_write_counter_x_w++;
   end 

   int start_tcdm_counter_y_z = 0;
   int end_tcdm_counter_y_z = 0;
   int tcdm_read_counter_y_z = 0;
   int tcdm_write_counter_y_z = 0;
 
   always_ff @(posedge clk_i) begin
     if (tcdm_req_y_z && start_tcdm_counter_y_z == 0) start_tcdm_counter_y_z <= global_counter;
     if (tcdm_req_y_z) end_tcdm_counter_y_z <= global_counter;
     if (tcdm_req_y_z && tcdm_wen_y_z) tcdm_read_counter_y_z++; 
     if (tcdm_req_y_z && !tcdm_wen_y_z) tcdm_write_counter_y_z++;
   end 

/**************
 *  VCD Dump  *
 **************/

`ifdef VCD_DUMP
  initial begin: vcd_dump
    wait (rst_ni);
    while (!(check_start_config)) begin
      @(posedge clk_i);
    end
    $display("[TB] %d - VCD dump started", global_counter);

    // $dumpfile(`VCD_DUMP_FILE);
    $dumpfile("/scratch2/pagonis/ope-highperf/redmule-gf12/modelsim/vcd/ope_highperf.vcd");
    $dumpvars(0, i_redmule_wrap);
    $dumpon;

    while (!(finished_redmule)) begin
      @(posedge clk_i);
    end
    $display("[TB] %d - VCD dump finished", global_counter);

    $dumpoff;
    $finish(0);
  end: vcd_dump
`endif

  initial begin

    if (!$value$plusargs("STIM_INSTR=%s", stim_instr)) stim_instr = "/scratch2/pagonis/ope-highperf/sw/build/stim_instr.txt";
    if (!$value$plusargs("STIM_DATA_X_W=%s", stim_data_x_w)) stim_data_x_w = "/scratch2/pagonis/ope-highperf/sw/build/stim_data_x_w.txt";
    if (!$value$plusargs("STIM_DATA_Y_Z=%s", stim_data_y_z)) stim_data_y_z = "/scratch2/pagonis/ope-highperf/sw/build/stim_data_y_z.txt";

    test_mode = 1'b0;
    core_boot_addr = 32'h1C000084;

    // Load instruction and data memory
    $readmemh(stim_instr, redmule_tb.i_dummy_imemory.memory);
    $readmemh(stim_data_x_w,  redmule_tb.i_dummy_dmemory_x_w.memory);
    $readmemh(stim_data_y_z,  redmule_tb.i_dummy_dmemory_y_z.memory);

    // End: WFI + returned != -1 signals end-of-computation
    while(~core_sleep || errors==-1) @(posedge clk_i);
    cnt_rd = redmule_tb.i_dummy_dmemory_x_w.cnt_rd[0] +
             redmule_tb.i_dummy_dmemory_x_w.cnt_rd[1] +
             redmule_tb.i_dummy_dmemory_x_w.cnt_rd[2] +
             redmule_tb.i_dummy_dmemory_x_w.cnt_rd[3] +
             redmule_tb.i_dummy_dmemory_x_w.cnt_rd[4] +
             redmule_tb.i_dummy_dmemory_x_w.cnt_rd[5] +
             redmule_tb.i_dummy_dmemory_x_w.cnt_rd[6] +
             redmule_tb.i_dummy_dmemory_x_w.cnt_rd[7] +
             redmule_tb.i_dummy_dmemory_x_w.cnt_rd[8];
    cnt_wr = redmule_tb.i_dummy_dmemory_x_w.cnt_wr[0] +
             redmule_tb.i_dummy_dmemory_x_w.cnt_wr[1] +
             redmule_tb.i_dummy_dmemory_x_w.cnt_wr[2] +
             redmule_tb.i_dummy_dmemory_x_w.cnt_wr[3] +
             redmule_tb.i_dummy_dmemory_x_w.cnt_wr[4] +
             redmule_tb.i_dummy_dmemory_x_w.cnt_wr[5] +
             redmule_tb.i_dummy_dmemory_x_w.cnt_wr[6] +
             redmule_tb.i_dummy_dmemory_x_w.cnt_wr[7] +
             redmule_tb.i_dummy_dmemory_x_w.cnt_wr[8];
    $display("[TB] - cnt_rd= %-8d", cnt_rd);
    $display("[TB] - cnt_wr= %-8d", cnt_wr);
    if(errors != 0) begin
      $display("[SAVE] - [TB] - Fail!");
      $error("[SAVE] - [TB] - errors=%08x", errors);
    end else begin
      $display("[SAVE] - [TB] - Success!");
      $display("[SAVE] - [TB] - errors=%08x", errors);
    end
    $display("[SAVE] - Measured count: %0d, Start counter: %0d, End counter: %0d", measured_count, start_counter, end_counter);
    $display("[SAVE] - Periphery Measured count: %0d, Start counter: %0d, End counter: %0d", periphery_end_counter - periphery_start_counter, periphery_start_counter, periphery_end_counter);

    $display("[SAVE] - ");
    $display("[SAVE] - X_W tcdm");
    $display("[SAVE] - ");
    $display("[SAVE] - TCDM Measured count: %0d, Start counter: %0d, End counter: %0d", end_tcdm_counter_x_w - start_tcdm_counter_x_w+1, start_tcdm_counter_x_w, end_tcdm_counter_x_w);
    $display("[SAVE] - TCDM Request Read count: %0d | Write count: %0d | Element read: %0d | Element write: %0d", tcdm_read_counter_x_w, tcdm_write_counter_x_w, tcdm_read_counter_x_w*8, tcdm_write_counter_x_w*8);
    $display("[SAVE] - TCDM Request count: %0d", tcdm_read_counter_x_w + tcdm_write_counter_x_w);

    $display("[SAVE] - ");
    $display("[SAVE] - [Data]: Cycles: %0d | TCDM Request count: %0d | TCDM Start - Finish: %0d", periphery_end_counter - periphery_start_counter, tcdm_read_counter_x_w + tcdm_write_counter_x_w, end_tcdm_counter_x_w - start_tcdm_counter_x_w+1);
    $display("[SAVE] - ");

    $display("[SAVE] - ");
    $display("[SAVE] - Y_Z tcdm");
    $display("[SAVE] - ");

    $display("[SAVE] - TCDM Measured count: %0d, Start counter: %0d, End counter: %0d", end_tcdm_counter_y_z - start_tcdm_counter_y_z+1, start_tcdm_counter_y_z, end_tcdm_counter_y_z);
    $display("[SAVE] - TCDM Request Read count: %0d | Write count: %0d | Element read: %0d | Element write: %0d", tcdm_read_counter_y_z, tcdm_write_counter_y_z, tcdm_read_counter_y_z*8, tcdm_write_counter_y_z*8);
    $display("[SAVE] - TCDM Request count: %0d", tcdm_read_counter_y_z + tcdm_write_counter_y_z);

    $display("[SAVE] - ");
    $display("[SAVE] - [Data]: Cycles: %0d | TCDM Request count: %0d | TCDM Start - Finish: %0d", periphery_end_counter - periphery_start_counter, tcdm_read_counter_y_z + tcdm_write_counter_y_z + tcdm_read_counter_x_w + tcdm_write_counter_x_w, end_tcdm_counter_y_z - start_tcdm_counter_y_z+1);
    $display("[SAVE] - ");
    $finish;
  end

endmodule // redmule_tb
