// Copyright 2025 ETH Zurich and University of Bologna.
// Solderpad Hardware License, Version 0.51, see LICENSE_HW for details.
// SPDX-License-Identifier: SHL-0.51
//
// Danilo Cammarata <dcammarata@iis.ee.ethz.ch>
// Francesco Conti <f.conti@unibo.it>

module opope_tiler
  import opope_pkg::*;
  import hwpe_ctrl_package::*;
(
  input  logic              clk_i      ,
  input  logic              rst_ni     ,
  input  logic              clear_i    ,
  input  logic              setback_i  ,
  input  logic              start_cfg_i,
  input  ctrl_regfile_t     reg_file_i ,
  output logic              valid_o    ,
  output ctrl_regfile_t     reg_file_o
);

logic clk_en;
logic clk_int;

always_ff @(posedge clk_i, negedge rst_ni) begin: clock_gate_enabler
  if (~rst_ni) begin
    clk_en <= 1'b0;
  end else begin
    if (clear_i || setback_i) begin
      clk_en <= 1'b0;
    end else if (start_cfg_i) begin
      clk_en <= 1'b1;
    end
  end
end

tc_clk_gating i_tiler_clockg (
  .clk_i      ( clk_i   ),
  .en_i       ( clk_en  ),
  .test_en_i  ( '0      ),
  .clk_o      ( clk_int )
);

logic km_valid;
logic nkm_valid;
logic valid_d,valid_q;
logic [31:0] nkm,nkm_d,nkm_q;
logic [31:0] km,km_d,km_q;
logic shift;
logic sel_d,sel_q;
logic mult_done, mult_start;
logic[15:0] operand_a,operand_b;
logic[31:0] mult_prod;

assign sel_d      = mult_done  ? ~sel_q : sel_q  ;
assign mult_start = km_valid | start_cfg_i;
assign operand_a  = sel_d ? (reg_file_i.hwpe_params[MCFIG1][15: 0] +  ARRAY_HEIGHT*W_REGBUFFER_DEPTH -1) &~ 16'(ARRAY_HEIGHT*W_REGBUFFER_DEPTH -1) 
                          : (reg_file_i.hwpe_params[MCFIG0][15: 0] +  ARRAY_HEIGHT*W_REGBUFFER_DEPTH -1) &~ 16'(ARRAY_HEIGHT*W_REGBUFFER_DEPTH -1);
assign operand_b  = sel_d ? mult_prod[15:0]                        
                          : (reg_file_i.hwpe_params[MCFIG0][31:16] +  ARRAY_HEIGHT*W_REGBUFFER_DEPTH -1) &~ 16'(ARRAY_HEIGHT*W_REGBUFFER_DEPTH -1);
assign km_valid   = mult_done & ~sel_q;
assign nkm_valid  = mult_done &  sel_q;
assign nkm        = sel_q ? mult_prod :        '0;
assign km         = sel_q ? '0        : mult_prod;

opope_seq_mult #(
  .DW ( 16 )
) i_n_m_k (
  .clk_i    ( clk_i      ),
  .rst_ni   ( rst_ni     ),
  .start_i  ( mult_start ),
  .a_i      ( operand_a  ),
  .b_i      ( operand_b  ),
  .done_o   ( mult_done  ),
  .prod_o   ( mult_prod  )
);

assign km_d    = clear_i               ? '0   : km_valid  ? km   : km_q   ;
assign nkm_d   = clear_i               ? '0   : nkm_valid ? nkm  : nkm_q  ;
assign valid_d = (clear_i | setback_i) ? 1'b0 : nkm_valid ? 1'b1 : valid_q;
assign valid_o = valid_q;

assign shift   = (BITW==32 & reg_file_i.hwpe_params[MACFG][ 19: 17]==Float16) |
                 (BITW==16 & reg_file_i.hwpe_params[MACFG][ 19: 17]==Float8 );
                 
always_ff @(posedge clk_int or negedge rst_ni) begin
  if(~rst_ni) begin
    nkm_q   <= '0;
    km_q    <= '0;
    valid_q <= '0;
    sel_q   <= '0;
  end else begin
    nkm_q   <= nkm_d  ;
    km_q    <= km_d   ;
    valid_q <= valid_d;
    sel_q   <= sel_d  ;
  end
end

assign reg_file_o.generic_params = '0;
assign reg_file_o.ext_data = '0;
assign reg_file_o.hwpe_params[REGFILE_N_MAX_IO_REGS-1:OPOPE_REGS] = '0;
assign reg_file_o.hwpe_params[      X_ADDR]        = reg_file_i.hwpe_params[X_ADDR];
assign reg_file_o.hwpe_params[      W_ADDR]        = reg_file_i.hwpe_params[W_ADDR];
assign reg_file_o.hwpe_params[      Z_ADDR]        = reg_file_i.hwpe_params[Z_ADDR];
assign reg_file_o.hwpe_params[OP_SELECTION][31:1 ] = '0;
assign reg_file_o.hwpe_params[OP_SELECTION][0]     = !shift;

assign reg_file_o.hwpe_params[M_SIZE][15:0]        = reg_file_i.hwpe_params[MCFIG0][15: 0];
assign reg_file_o.hwpe_params[N_SIZE][15:0]        = reg_file_i.hwpe_params[MCFIG1][15: 0];
assign reg_file_o.hwpe_params[K_SIZE][15:0]        = reg_file_i.hwpe_params[MCFIG0][31:16];
assign reg_file_o.hwpe_params[N_K_M ][31:0]        = nkm_q;
assign reg_file_o.hwpe_params[K_M   ][31:0]        = km_q;
assign reg_file_o.hwpe_params[M_SIZE][31:16]       = 'b0;
assign reg_file_o.hwpe_params[N_SIZE][31:16]       = 'b0;
assign reg_file_o.hwpe_params[K_SIZE][31:16]       = 'b0;

endmodule: opope_tiler
