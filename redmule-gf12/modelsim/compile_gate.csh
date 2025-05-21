#! /bin/tcsh -f

set VER=2023.4
set LIB=gate
set DESIGN=ope_sspg_0p495v_125c_1ns_3_1_20250514_1151
if (-e ${LIB}) then
  rm -rf ${LIB}
endif

questa-$VER vlib ${LIB}
# compile gate-level netlist
questa-$VER vmap ${LIB} ../modelsim/${LIB}

questa-$VER vsim -work ${LIB} -c -do " source ../synopsys/compile_power.vsim.tcl; quit -f"
questa-$VER vlog -work ${LIB} ../synopsys/out/${DESIGN}/netlist_ope.v
questa-$VER vopt -work ${LIB}  \
                -L sc7p5mcpp84_12lpplus_base_lvt_c16 \
                -L sc7p5mcpp84_12lpplus_base_lvt_c14 \
                -L io_gppr_12lpplus_t18_mv08_mv18_fs18_rvt_dr \
                +acc=np -suppress vopt-2732  -suppress vopt-2912 -suppress vopt-7061 +notimingchecks -o redmule_tb_wrap_opt redmule_tb_wrap
