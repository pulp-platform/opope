// Copyright 2025 ETH Zurich and University of Bologna.
// Solderpad Hardware License, Version 0.51, see LICENSE for details.
// SPDX-License-Identifier: SHL-0.51
//
// Danilo Cammarata <dcammarata@iis.ee.ethz.ch>


module opope_engine
  import fpnew_pkg::*;
  import opope_pkg::*;
#(
 parameter  fp_format_e   FpFormat    = fpnew_pkg::FP32              ,
 parameter  int unsigned  Height      = 4                            , // Number of PEs per row
 parameter  int unsigned  Width       = 8                            , // Number of parallel index
 parameter  int unsigned  NumPipeRegs = 3                            ,
 parameter  pipe_config_t PipeConfig  = DISTRIBUTED                  ,
 parameter  type          TagType     = logic                        ,
 parameter  type          AuxType     = logic                        ,
 localparam int unsigned  BITW        = fpnew_pkg::fp_width(FpFormat), // Number of bits for the given format
 parameter logic          Stallable   = 1'b1                         ,
 localparam int unsigned  CUSTOM_FPU  = 1                            ,
 localparam int unsigned  MUX_SH_n    = 1
)(
  input  logic                          clk_i              ,
  input  logic                          rst_ni             ,
  input  logic                          clk_en_i           ,
  input  logic [ Height-1:0][BITW-1:0]  x_input_i          , // Column of inputs
  input  logic [  Width-1:0][BITW-1:0]  w_input_i          , // Row of weights
  input  logic [2*Width-1:0][BITW-1:0]  y_bias_i           , // Row of biases
  output logic [2*Width-1:0][BITW-1:0]  z_output_o         , // Row of outputs

  input  cntrl_engine_t                 cntrl_engine_i  // This include the mode (idle, load, compute, read) and the row_index
);


  logic [Height-1:0][Width-1:0][2*BITW-1:0] reg_out_data;

  logic [Height-1:0][Width-1:0][BITW-1:0] engine_to_reg_output;

  logic ce_clk;
  logic [Height-1:0][Width-1:0]             acc_in_valid;
  logic [Height-1:0][Width-1:0][2*BITW-1:0] acc_in_data;
  logic [$clog2(REG_PER_CE)-1:0]            acc_write_index;
  logic [$clog2(REG_PER_CE)-1:0]            acc_read_index ;

  logic [Height-1:0][Width-1:0][2:0][BITW-1:0] ce_operands;
  logic [Height-1:0][Width-1:0][BITW-1:0]      acc_operand;
  
  /*---------------------------------------------------------------*/
  /* |                  Accumulator Read and Write               | */
  /*---------------------------------------------------------------*/
  tc_clk_gating ce_clock_gating (
    .clk_i      ( clk_i     ),
    .en_i       ( clk_en_i  ),
    .test_en_i  ( '0        ),
    .clk_o      ( ce_clk    )    
  );

  if(MUX_SH_n) begin
    assign acc_read_index  = cntrl_engine_i.z_read_reg_index;
    assign acc_write_index = cntrl_engine_i.acc_input_selector ? cntrl_engine_i.reg_write_to_engine
                                                               : cntrl_engine_i.y_write_reg_index;
  end else begin
    assign acc_read_index = cntrl_engine_i.acc_input_selector                    ? cntrl_engine_i.z_read_reg_index :
                            cntrl_engine_i.shift_acc & cntrl_engine_i.y_in_valid ? cntrl_engine_i.y_write_reg_index 
                                                                                 : cntrl_engine_i.z_read_reg_index ;

    assign acc_write_index = cntrl_engine_i.acc_input_selector                     ? cntrl_engine_i.reg_write_to_engine :
                             cntrl_engine_i.shift_acc &~ cntrl_engine_i.y_in_valid ? cntrl_engine_i.z_read_reg_index  
                                                                                   : cntrl_engine_i.y_write_reg_index;
  end

        
  // Write logic
  for (genvar col_index = 0; col_index < Width; col_index++) begin
    for (genvar row_index = 0; row_index < Height; row_index++) begin
      if(MUX_SH_n) begin
        assign acc_in_valid[row_index][col_index] = cntrl_engine_i.acc_input_selector ? 1'b1 
                                                                                      : cntrl_engine_i.y_in_valid && (row_index == cntrl_engine_i.y_write_row_index) && cntrl_engine_i.external_loading;
        assign acc_in_data [row_index][col_index] = cntrl_engine_i.acc_input_selector ? {engine_to_reg_output[row_index][col_index],engine_to_reg_output[row_index][col_index]} 
                                                                                      : {y_bias_i[2*col_index+1],y_bias_i[2*col_index]};
      end else begin
        assign acc_in_valid[row_index][col_index] = cntrl_engine_i.acc_input_selector ? 1'b1
                                                                                      : (cntrl_engine_i.y_in_valid && cntrl_engine_i.external_loading) | cntrl_engine_i.shift_acc;
        assign acc_in_data [row_index][col_index] = cntrl_engine_i.acc_input_selector ? {engine_to_reg_output[row_index][col_index],engine_to_reg_output[row_index][col_index]} :
                                                    row_index != Height-1             ? reg_out_data[row_index + 1][col_index]
                                                                                      : {y_bias_i[2*col_index+1],y_bias_i[2*col_index]};
      end
    end
  end

  // Read logic
  for (genvar col_index = 0; col_index < Width; col_index++) begin
    if(MUX_SH_n) begin
      assign z_output_o[2*col_index  ] = reg_out_data[cntrl_engine_i.z_read_row_index][col_index][  BITW-1:0   ];
      assign z_output_o[2*col_index+1] = reg_out_data[cntrl_engine_i.z_read_row_index][col_index][2*BITW-1:BITW];
    end else begin
      assign z_output_o[2*col_index  ] = reg_out_data[0][col_index][  BITW-1:0   ];
      assign z_output_o[2*col_index+1] = reg_out_data[0][col_index][2*BITW-1:BITW];
    end
  end

  /*---------------------------------------------------------------*/
  /* |                      Computing Elements                   | */
  /*---------------------------------------------------------------*/

  generate
    for(genvar row_index = 0; row_index < Height; row_index++) begin: array_row
      for (genvar col_index = 0; col_index < Width; col_index++) begin: array_col
        assign acc_operand[row_index][col_index]    = reg_out_data[row_index][col_index][cntrl_engine_i.z_read_reg_index[0]*BITW +: BITW];
        assign ce_operands[row_index][col_index][0] = x_input_i[row_index];
        assign ce_operands[row_index][col_index][1] = w_input_i[col_index];
        assign ce_operands[row_index][col_index][2] = (cntrl_engine_i.y_bias_selector) ? acc_operand[row_index][col_index]: engine_to_reg_output[row_index][col_index] ;
        opope_accumulator #(
          .DATA_WIDTH ( BITW          ),
          .DEPTH      ( REG_PER_CE    )
        ) i_accumulator (
          .clk_i              ( clk_i                                                ),
          .rst_ni             ( rst_ni                                               ),
          .flush_i            ( 1'b0                                                 ),
          .iteration_change_i ( 1'b0                                                 ),     
          .wdata_i            ( acc_in_data[row_index][col_index]                    ),         
          .wen_i              ( acc_in_valid[row_index][col_index]                   ),
          .waddr_i            ( acc_write_index                                      ),
          .ext_ld_i           ( cntrl_engine_i.external_loading                      ),
          .raddr_i            ( acc_read_index                                       ),
          .rdata_o            ( reg_out_data[row_index][col_index]                   )   
        );
        if(CUSTOM_FPU) begin
          opope_ce #(
            .FpFormat     ( FpFormat    ),
            .NumPipeRegs  ( NumPipeRegs ),
            .PipeConfig   ( PipeConfig  ),
            .Stallable    ( Stallable   )
          ) i_ce (
            .clk_i        ( ce_clk                                          ),
            .rst_ni       ( rst_ni                                          ),
            .operands_i   ( ce_operands[row_index][col_index]               ),
            .same_fmt_i   ( cntrl_engine_i.same_fmt                         ),
            .reg_enable_i ( cntrl_engine_i.reg_enable                       ),
            .z_output_o   ( engine_to_reg_output[row_index][col_index]      )
          );
        end else begin
          opope_fpnew #(
            .FpFormat     ( FpFormat    ),
            .NumPipeRegs  ( NumPipeRegs ),
            .PipeConfig   ( PipeConfig  ),
            .Stallable    ( Stallable   )
          ) i_ce (
            .clk_i        ( ce_clk                                          ),
            .rst_ni       ( rst_ni                                          ),
            .operands_i   ( ce_operands[row_index][col_index]               ),
            .same_fmt_i   ( cntrl_engine_i.same_fmt                         ),
            .in_valid_i   ( cntrl_engine_i.in_valid & cntrl_engine_i.in_ready), 
            .reg_enable_i ( cntrl_engine_i.reg_enable                       ),
            .z_output_o   ( engine_to_reg_output[row_index][col_index]      )
          );
        end
      end
    end
  endgenerate


endmodule 
