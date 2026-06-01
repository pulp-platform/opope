// Copyright 2025 ETH Zurich and University of Bologna.
// Solderpad Hardware License, Version 0.51, see LICENSE_HW for details.
// SPDX-License-Identifier: SHL-0.51
//
// Danilo Cammarata <dcammarata@iis.ee.ethz.ch>

module opope_ce #(
  parameter fpnew_pkg::fp_format_e   FpFormat    = fpnew_pkg::FP32        ,
  parameter int unsigned             NumPipeRegs = 4                      ,
  parameter fpnew_pkg::pipe_config_t PipeConfig  = fpnew_pkg::DISTRIBUTED ,
  parameter logic                    Stallable   = 1'b0                   ,
  localparam int unsigned            BITW        = fpnew_pkg::fp_width(FpFormat),
  // Do not change
  localparam int unsigned  FMA_ACTIVE    = 1,
  localparam int unsigned  SDOTP_ACTIVE  = 1,
  localparam fpnew_pkg::fmt_logic_t  FpFmtConfigSdotp  = (FpFormat==fpnew_pkg::FP32) ? 6'b101000 : 6'b001100
)(
  input  logic                 clk_i       ,
  input  logic                 rst_ni      ,
  input  logic [2:0][BITW-1:0] operands_i  ,
  input  logic                 same_fmt_i  ,
  input  logic                 reg_enable_i,
  output logic [BITW-1:0]      z_output_o       
);

  logic [BITW-1:0] fma_res  ;
  logic [BITW-1:0] sdotp_res;
  assign z_output_o = same_fmt_i ? fma_res : sdotp_res;

  /*******************************************************************************/
  /* Instantiation of FMA                                                        */
  /*******************************************************************************/
  if(FMA_ACTIVE) begin: gen_opope_fma
    logic fma_clk;
    tc_clk_gating fma_clk_gating (
      .clk_i      ( clk_i      ),
      .en_i       ( same_fmt_i ),
      .test_en_i  ( '0         ),
      .clk_o      ( fma_clk    )    
    );
    
    opope_fma   #(
      .FpFormat     ( FpFormat     ),
      .NumPipeRegs  ( NumPipeRegs  ),
      .PipeConfig   ( PipeConfig   ),
      .Stallable    ( Stallable    )
    ) i_fma    (
      .clk_i        ( fma_clk      ),
      .rst_ni       ( rst_ni       ),
      .operands_i   ( operands_i   ),
      .reg_enable_i ( reg_enable_i ),
      .result_o     ( fma_res      )
    );
  end else begin : no_gen_opope_fma
    assign fma_res = '0;
  end

  /*******************************************************************************/
  /* Instantiation SDOTP                                                         */
  /*******************************************************************************/
  if(SDOTP_ACTIVE) begin: gen_opope_sdotp
    logic sdotp_clk;
    tc_clk_gating sdotp_clk_gating (
      .clk_i      ( clk_i       ),
      .en_i       ( ~same_fmt_i ),
      .test_en_i  ( '0          ),
      .clk_o      ( sdotp_clk   )   
    );

    opope_sdotp_wrapper #(
      .LaneWidth    ( BITW             ),
      .FpFmtConfig  ( FpFmtConfigSdotp ),
      .NumPipeRegs  ( NumPipeRegs      ),
      .PipeConfig   ( PipeConfig       ),
      .Stallable    ( Stallable        )  
    ) i_sdotp (
      .clk_i        ( sdotp_clk        ), 
      .rst_ni       ( rst_ni           ),
      .operands_i   ( operands_i       ),
      .reg_enable_i ( reg_enable_i     ),
      .result_o     ( sdotp_res        )
    );
  end else begin: no_gen_opope_sdotp
    assign sdotp_res = '0;
  end

endmodule: opope_ce
