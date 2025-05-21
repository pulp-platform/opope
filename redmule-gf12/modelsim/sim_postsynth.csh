#!/bin/tcsh -f

set VER=2023.4
set LIB=gate

questa-$VER vsim -gui -t 1ps -lib ${LIB} \
  -L sc7p5mcpp84_12lpplus_base_lvt_c16 \
  -L sc7p5mcpp84_12lpplus_base_lvt_c14 \
  -v2k_int_delays +no_glitch_msg \
  +bus_conflict_off \
  -suppress 3009 \
  -suppress 3438 \
  -suppress 16066 \
  -suppress 16107 \
  +nospecify \
  +notimingchecks \
  # -do "run -all; quit" \
  -do "run -all; quit" \
  redmule_tb_wrap_opt
