// Copyright 2025 ETH Zurich and University of Bologna.
// Solderpad Hardware License, Version 0.51, see LICENSE_HW for details.
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
  input  logic                 clk_i             ,
  input  logic                 rst_ni            ,
  input  logic [2:0][BITW-1:0] operands_i        ,
  input  logic                 same_fmt_i        ,
  input  logic                 in_valid_i        ,
  input  logic                 reg_enable_i      ,
  output logic      [BITW-1:0] z_output_o        
);

  logic clk;
  fpnew_pkg::fp_format_e  src_fmt; 
  fpnew_pkg::fp_format_e  dst_fmt;
  fpnew_pkg::operation_e  op     ;
  assign src_fmt = FpFormat==FP32 && same_fmt_i ? fpnew_pkg::FP32 :
                   FpFormat==FP32 &~ same_fmt_i ? fpnew_pkg::FP16 :
                   FpFormat==FP16 && same_fmt_i ? fpnew_pkg::FP16 : fpnew_pkg::FP8;

  assign dst_fmt = FpFormat;

  assign op = same_fmt_i ? fpnew_pkg::FMADD : fpnew_pkg::SDOTP;

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
    .Features       (OPOPE_FPU        ),
    .Implementation (FPUImplementation)
  ) i_fpu (
    .clk_i          (clk              ),
    .rst_ni         (rst_ni           ),
    .hart_id_i      ('0               ),
    .flush_i        (1'b0             ),
    .busy_o         (                 ),
    .operands_i     (operands_i       ),
    .in_valid_i     (in_valid_i       ),
    .in_ready_o     (                 ),
    .op_i           (op               ),
    .src_fmt_i      (src_fmt          ),
    .dst_fmt_i      (dst_fmt          ),
    .int_fmt_i      (fpnew_pkg::INT32 ),
    .vectorial_op_i ('0               ),
    .op_mod_i       (1'b0             ),
    .tag_i          (1'b0             ),
    .simd_mask_i    ('0               ),
    .rnd_mode_i     (fpnew_pkg::RNE   ),
    .result_o       (z_output_o       ),
    .out_valid_o    (                 ),
    .out_ready_i    (1'b1             ),
    .status_o       (                 ),
    .tag_o          (                 )
  );

endmodule: opope_fpnew

  
