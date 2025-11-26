// Copyright 2025 ETH Zurich and University of Bologna.
// Solderpad Hardware License, Version 0.51, see LICENSE for details.
// SPDX-License-Identifier: SHL-0.51
//
// Danilo Cammarata <dcammarata@iis.ee.ethz.ch>

module opope_fpnew
  import fpnew_pkg::*;
  import opope_pkg::*;
#(
  parameter fpnew_pkg::fp_format_e   FpFormat    = fpnew_pkg::FP32              ,
  parameter int unsigned             NumPipeRegs = 4                            ,
  parameter fpnew_pkg::pipe_config_t PipeConfig  = fpnew_pkg::DISTRIBUTED       ,
  parameter type                     TagType     = logic                        ,
  parameter type                     AuxType     = logic                        ,
  parameter logic                    Stallable   = 1'b0                         ,
  localparam int unsigned            BITW        = fpnew_pkg::fp_width(FpFormat)
)(
  input  logic                               clk_i             ,
  input  logic                               rst_ni            ,
  input  logic                    [BITW-1:0] x_input_i         ,
  input  logic                    [BITW-1:0] w_input_i         ,
  input  logic                    [BITW-1:0] y_bias_i          ,
  input  fpnew_pkg::operation_e              op1_i             ,
  input  fpu_fmt_e                           memory_fmt_i      ,
  input  fpu_fmt_e                           computing_fmt_i   ,
  input  logic                               op_mod_i          ,
  input  TagType                             tag_i             ,
  input  logic                               in_valid_i        ,
  output logic                               in_ready_o        ,
  input  logic                               reg_enable_i      ,
  input  logic                               flush_i           ,
  output logic                    [BITW-1:0] z_output_o        ,
  output fpnew_pkg::status_t                 status_o          ,
  output TagType                             tag_o             ,
  output logic                               out_valid_o       ,
  input  logic                               out_ready_i       ,
  output logic                               busy_o
);

  logic clk;
  fpnew_pkg::fp_format_e  memory_fmt_fpnew; 
  fpnew_pkg::fp_format_e  computing_fmt_fpnew; 
  assign memory_fmt_fpnew = fpnew_pkg::fp_format_e'(memory_fmt_i);
  assign computing_fmt_fpnew = fpnew_pkg::fp_format_e'(computing_fmt_i);

  tc_clk_gating fma_clk_gating (
    .clk_i      ( clk_i        ),
    .en_i       ( reg_enable_i ),
    .test_en_i  ( '0           ),
    .clk_o      ( clk          )    
  );


  localparam fpu_features_t OPOPE_FPU = '{
    Width:         BITW,
    EnableVectors: 1'b0,
    EnableNanBox:  1'b0,
    FpFmtMask:     6'b101100,
    IntFmtMask:    4'b0000
  };
  localparam fpnew_pkg::fpu_implementation_t FPUImplementation32 = 
    '{
        PipeRegs: '{ //    FP32    FP64     FP16          FP8     FP16alt FP8alt
                    '{ NumPipeRegs, 0  ,      0     ,      0     ,   0,     0   },   // FMA
                    '{      0     , 0  ,      0     ,      0     ,   0,     0   },   // DIVSQRT
                    '{      0     , 0  ,      0     ,      0     ,   0,     0   },   // NONCOMP
                    '{      0     , 0  ,      0     ,      0     ,   0,     0   },   // CONV
                    '{ NumPipeRegs, 0  ,      0     ,      0     ,   0,     0   }    // DOTP
                    },
        UnitTypes: '{'{fpnew_pkg::PARALLEL,
                       fpnew_pkg::DISABLED,
                       fpnew_pkg::DISABLED,
                       fpnew_pkg::DISABLED,
                       fpnew_pkg::DISABLED,
                       fpnew_pkg::DISABLED},  // FMA
                    '{fpnew_pkg::DISABLED,
                        fpnew_pkg::DISABLED,
                        fpnew_pkg::DISABLED,
                        fpnew_pkg::DISABLED,
                        fpnew_pkg::DISABLED,
                        fpnew_pkg::DISABLED}, // DIVSQRT
                    '{fpnew_pkg::DISABLED,
                        fpnew_pkg::DISABLED,
                        fpnew_pkg::DISABLED,
                        fpnew_pkg::DISABLED,
                        fpnew_pkg::DISABLED,
                        fpnew_pkg::DISABLED}, // NONCOMP
                    '{fpnew_pkg::DISABLED,
                        fpnew_pkg::DISABLED,
                        fpnew_pkg::DISABLED,
                        fpnew_pkg::DISABLED,
                        fpnew_pkg::DISABLED,
                        fpnew_pkg::DISABLED},   // CONV
                    '{fpnew_pkg::MERGED,
                       fpnew_pkg::DISABLED,
                       fpnew_pkg::DISABLED,
                       fpnew_pkg::DISABLED,
                       fpnew_pkg::DISABLED,
                       fpnew_pkg::DISABLED}},  // DOTP
        PipeConfig: PipeConfig
    };
  localparam fpnew_pkg::fpu_implementation_t FPUImplementation16 = 
    '{
        PipeRegs: '{ //    FP32    FP64     FP16          FP8     FP16alt FP8alt
                    '{      0     , 0  , NumPipeRegs,      0     ,   0,     0   },   // FMA
                    '{      0     , 0  ,      0     ,      0     ,   0,     0   },   // DIVSQRT
                    '{      0     , 0  ,      0     ,      0     ,   0,     0   },   // NONCOMP
                    '{      0     , 0  ,      0     ,      0     ,   0,     0   },   // CONV
                    '{ NumPipeRegs, 0  ,      0     ,      0     ,   0,     0   }    // DOTP
                    },
        UnitTypes: '{'{fpnew_pkg::DISABLED,
                       fpnew_pkg::DISABLED,
                       fpnew_pkg::PARALLEL,
                       fpnew_pkg::DISABLED,
                       fpnew_pkg::DISABLED,
                       fpnew_pkg::DISABLED},  // FMA
                    '{fpnew_pkg::DISABLED,
                        fpnew_pkg::DISABLED,
                        fpnew_pkg::DISABLED,
                        fpnew_pkg::DISABLED,
                        fpnew_pkg::DISABLED,
                        fpnew_pkg::DISABLED}, // DIVSQRT
                    '{fpnew_pkg::DISABLED,
                        fpnew_pkg::DISABLED,
                        fpnew_pkg::DISABLED,
                        fpnew_pkg::DISABLED,
                        fpnew_pkg::DISABLED,
                        fpnew_pkg::DISABLED}, // NONCOMP
                    '{fpnew_pkg::DISABLED,
                        fpnew_pkg::DISABLED,
                        fpnew_pkg::DISABLED,
                        fpnew_pkg::DISABLED,
                        fpnew_pkg::DISABLED,
                        fpnew_pkg::DISABLED},   // CONV
                    '{fpnew_pkg::MERGED,
                       fpnew_pkg::DISABLED,
                       fpnew_pkg::MERGED,
                       fpnew_pkg::DISABLED,
                       fpnew_pkg::DISABLED,
                       fpnew_pkg::DISABLED}},  // DOTP
        PipeConfig: PipeConfig
    };
  localparam fpnew_pkg::fpu_implementation_t FPUImplementation   = (FpFormat==FP32) ? FPUImplementation32 : FPUImplementation16;
  fpnew_top #(
    .Features                   (OPOPE_FPU         ),
    .Implementation             (FPUImplementation )
  ) i_fpu (
    .clk_i          (clk                             ),
    .rst_ni         (rst_ni                          ),
    .hart_id_i      ('0                              ),
    .flush_i        (flush_i                         ),
    .busy_o         (busy_o                          ),
    .operands_i     ({y_bias_i, w_input_i, x_input_i}),
    .in_valid_i     (in_valid_i                      ),
    .in_ready_o     (in_ready_o                      ),
    .op_i           (op1_i                           ),
    .src_fmt_i      (computing_fmt_fpnew             ),
    .dst_fmt_i      (memory_fmt_fpnew                ),
    .int_fmt_i      (fpnew_pkg::int_format_e'(INT32) ),
    .vectorial_op_i ('0                              ),
    .op_mod_i       (op_mod_i                        ),
    .tag_i          (tag_i                           ),
    .simd_mask_i    ('0                              ),
    .rnd_mode_i     (roundmode_e'(fpnew_pkg::RNE)    ),
    .result_o       (z_output_o                      ),
    .out_valid_o    (out_valid_o                     ),
    .out_ready_i    (out_ready_i                     ),
    .status_o       (status_o                        ),
    .tag_o          (tag_o                           )
  );

endmodule: opope_fpnew

  
