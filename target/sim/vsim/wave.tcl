# Copyright 2021 ETH Zurich and University of Bologna.
# Solderpad Hardware License, Version 0.51, see LICENSE for details.
# SPDX-License-Identifier: SHL-0.51
#
# Yvan Tortorella <yvan.tortorella@unibo.it>

onerror {resume}
quietly WaveActivateNextPane {} 0

set Testbench redmule_tb_wrap/i_redmule_tb
if {$TbType == {redmule_tb}} {
  set TopLevelPath i_redmule_wrap/i_redmule_top
  set CorePath i_cv32e40p_core
} elseif {$TbType == {redmule_complex_tb}} {
  set DutPath i_dut
  set TopLevelPath $DutPath/i_redmule_top
  set CorePath $DutPath/gen_cv32e40x/i_core
}
set MinHeight 16
set MaxHeight 32
set WavesRadix hexadecimal


# add wave -noupdate -group Periph -group periph -color {} -height $MinHeight -max $MaxHeight -radix $WavesRadix $Testbench/$TopLevelPath/periph/*
# add wave -noupdate -group TCDM -group tcdm -color {} -height $MinHeight -max $MaxHeight -radix $WavesRadix $Testbench/$TopLevelPath/tcdm/*
# add wave -noupdate -group Streamer -group top -color {} -height $MinHeight -max $MaxHeight -radix $WavesRadix $Testbench/$TopLevelPath/i_streamer/*
# add wave -noupdate -group Streamer -group X-Stream -color {} -height $MinHeight -max $MaxHeight -radix $WavesRadix $Testbench/$TopLevelPath/i_streamer/gen_tcdm2stream[0]/i_load_tcdm_fifo/*
# add wave -noupdate -group Streamer -group W-Stream -color {} -height $MinHeight -max $MaxHeight -radix $WavesRadix $Testbench/$TopLevelPath/i_streamer/gen_tcdm2stream[1]/i_load_tcdm_fifo/*
# add wave -noupdate -group Streamer -group Y-Stream -color {} -height $MinHeight -max $MaxHeight -radix $WavesRadix $Testbench/$TopLevelPath/i_streamer/gen_tcdm2stream[2]/i_load_tcdm_fifo/*
# add wave -noupdate -group Streamer -group Z-Stream -color {} -height $MinHeight -max $MaxHeight -radix $WavesRadix $Testbench/$TopLevelPath/i_streamer/i_stream_sink/*
# add wave -noupdate -group X-channel -color {} -height $MinHeight -max $MaxHeight -radix $WavesRadix $Testbench/$TopLevelPath/i_x_reg_array_wrapper/*
# add wave -noupdate -group W-channel -color {} -height $MinHeight -max $MaxHeight -radix $WavesRadix $Testbench/$TopLevelPath/i_w_reg_array_wrapper/*
# add wave -noupdate -group Y-channel -color {} -height $MinHeight -max $MaxHeight -radix $WavesRadix $Testbench/$TopLevelPath/y_buffer_d/*
# add wave -noupdate -group Z-channel -color {} -height $MinHeight -max $MaxHeight -radix $WavesRadix $Testbench/$TopLevelPath/z_buffer_d/*
# # Engine
# set NumRows [examine -radix dec redmule_pkg::ARRAY_WIDTH]
# set NumCols [examine -radix dec redmule_pkg::ARRAY_HEIGHT]
# for {set row 0}  {$row < $NumRows} {incr row} {
#   for {set col 0}  {$col < $NumCols} {incr col} {
#     add wave -noupdate -group Engine -group row_$row -group CE_$col -color {} -height $MinHeight -max $MaxHeight -radix $WavesRadix $Testbench/$TopLevelPath/i_ope_engine/ce_row[$row]/ce_col[$col]/i_ce/*
#   }
# }

# # Accumulation Registers
# set NumRows [examine -radix dec redmule_pkg::ARRAY_WIDTH]
# set NumCols [examine -radix dec redmule_pkg::ARRAY_HEIGHT]
# for {set row 0}  {$row < $NumRows} {incr row} {
#   for {set col 0}  {$col < $NumCols} {incr col} {
#     add wave -noupdate -group Acc-reg -group row_$row -group CE_$col -color {} -height $MinHeight -max $MaxHeight -radix $WavesRadix $Testbench/$TopLevelPath/i_ope_engine/accumulation_reg_row[$row]/accumulation_reg_col[$col]/i_acc_reg/*
#   }
# }


# add wave -noupdate -group Engine_shortcut  -color {} -height $MinHeight -max $MaxHeight -radix $WavesRadix $Testbench/$TopLevelPath/i_ope_engine/clk_i
# add wave -noupdate -group Engine_shortcut  -color {} -height $MinHeight -max $MaxHeight -radix $WavesRadix $Testbench/$TopLevelPath/i_ope_engine/rst_ni
# add wave -noupdate -group Engine_shortcut  -color {} -height $MinHeight -max $MaxHeight -radix $WavesRadix $Testbench/$TopLevelPath/i_ope_engine/iteration_change_i
# # Engine
# set NumRows [examine -radix dec redmule_pkg::ARRAY_WIDTH]
# set NumCols [examine -radix dec redmule_pkg::ARRAY_HEIGHT]
# for {set row 0}  {$row < $NumRows} {incr row} {
#   for {set col 0}  {$col < $NumCols} {incr col} {
#     add wave -noupdate -group Engine_shortcut -group row_$row -group col_$col -group CE -color {} -height $MinHeight -max $MaxHeight -radix $WavesRadix $Testbench/$TopLevelPath/i_ope_engine/ce_row[$row]/ce_col[$col]/i_ce/x_input_i
#     add wave -noupdate -group Engine_shortcut -group row_$row -group col_$col -group CE -color {} -height $MinHeight -max $MaxHeight -radix $WavesRadix $Testbench/$TopLevelPath/i_ope_engine/ce_row[$row]/ce_col[$col]/i_ce/w_input_i
#     add wave -noupdate -group Engine_shortcut -group row_$row -group col_$col -group CE -color {} -height $MinHeight -max $MaxHeight -radix $WavesRadix $Testbench/$TopLevelPath/i_ope_engine/ce_row[$row]/ce_col[$col]/i_ce/y_bias_i
#     add wave -noupdate -group Engine_shortcut -group row_$row -group col_$col -group CE -color {} -height $MinHeight -max $MaxHeight -radix $WavesRadix $Testbench/$TopLevelPath/i_ope_engine/ce_row[$row]/ce_col[$col]/i_ce/in_valid_i
#     add wave -noupdate -group Engine_shortcut -group row_$row -group col_$col -group CE -color {} -height $MinHeight -max $MaxHeight -radix $WavesRadix $Testbench/$TopLevelPath/i_ope_engine/ce_row[$row]/ce_col[$col]/i_ce/z_output_o
#     add wave -noupdate -group Engine_shortcut -group row_$row -group col_$col -group CE -color {} -height $MinHeight -max $MaxHeight -radix $WavesRadix $Testbench/$TopLevelPath/i_ope_engine/ce_row[$row]/ce_col[$col]/i_ce/out_valid_o
#     add wave -noupdate -group Engine_shortcut -group row_$row -group col_$col -group ACC -color {} -height $MinHeight -max $MaxHeight -radix $WavesRadix $Testbench/$TopLevelPath/i_ope_engine/accumulation_reg_row[$row]/accumulation_reg_col[$col]/i_acc_reg/input_i
#     add wave -noupdate -group Engine_shortcut -group row_$row -group col_$col -group ACC -color {} -height $MinHeight -max $MaxHeight -radix $WavesRadix $Testbench/$TopLevelPath/i_ope_engine/accumulation_reg_row[$row]/accumulation_reg_col[$col]/i_acc_reg/in_valid_i
#     add wave -noupdate -group Engine_shortcut -group row_$row -group col_$col -group ACC -color {} -height $MinHeight -max $MaxHeight -radix $WavesRadix $Testbench/$TopLevelPath/i_ope_engine/accumulation_reg_row[$row]/accumulation_reg_col[$col]/i_acc_reg/read_i
#     add wave -noupdate -group Engine_shortcut -group row_$row -group col_$col -group ACC -color {} -height $MinHeight -max $MaxHeight -radix $WavesRadix $Testbench/$TopLevelPath/i_ope_engine/accumulation_reg_row[$row]/accumulation_reg_col[$col]/i_acc_reg/output_o
#     add wave -noupdate -group Engine_shortcut -group row_$row -group col_$col -group ACC -color {} -height $MinHeight -max $MaxHeight -radix $WavesRadix $Testbench/$TopLevelPath/i_ope_engine/accumulation_reg_row[$row]/accumulation_reg_col[$col]/i_acc_reg/out_valid_o
#     add wave -noupdate -group Engine_shortcut -group row_$row -group col_$col -group ACC -color {} -height $MinHeight -max $MaxHeight -radix $WavesRadix $Testbench/$TopLevelPath/i_ope_engine/accumulation_reg_row[$row]/accumulation_reg_col[$col]/i_acc_reg/internal_reg_q
#   }
# }

# # Memory scheduler
# add wave -noupdate -group Scheduler -color {} -height $MinHeight -max $MaxHeight -radix $WavesRadix $Testbench/$TopLevelPath/i_memory_scheduler/*
# # Controller
# add wave -noupdate -group Controller -color {} -height $MinHeight -max $MaxHeight -radix $WavesRadix $Testbench/$TopLevelPath/i_control/*
# add wave -noupdate -group PriorityEnforcer -color {} -height $MinHeight -max $MaxHeight -radix $WavesRadix $Testbench/$TopLevelPath/i_priority_enforcer/*

config wave -signalnamewidth 1
