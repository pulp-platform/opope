#! /bin/tcsh -f

set VER=2023.4
set LIB=gate

if (-e ${LIB}) then
  rm -rf ${LIB}
endif

questa-$VER vlib ${LIB}
# compile gate-level netlist
questa-$VER vmap /scratch2/pagonis/ope-highperf/redmule-gf12/modelsim/gate

questa-$VER vsim -work ${LIB} -c -do ../synopsys/compile_power.vsim.tcl
# questa-$VER vlog -work ${LIB} /scratch2/pagonis/ope-highperf/redmule-gf12/small/netlist_ope.v
questa-$VER vopt -work ${LIB}  \
                -L sc7p5mcpp84_12lpplus_base_lvt_c16 \
                -L sc7p5mcpp84_12lpplus_base_lvt_c14 \
                -L io_gppr_12lpplus_t18_mv08_mv18_fs18_rvt_dr \
                +acc=np -suppress vopt-2732  -suppress vopt-2912 -suppress vopt-7061 +notimingchecks -o redmule_tb_wrap_opt redmule_tb_wrap
