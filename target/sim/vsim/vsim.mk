# Copyright 2025 ETH Zurich and University of Bologna.
# Licensed under the Apache License, Version 2.0, see LICENSE_SW for details.
# SPDX-License-Identifier: Apache-2.0
#
# Danilo Cammarata <dcammarata@iis.ee.ethz.ch>
#
# Makefragment for Questasim simulation.

Questa ?= questa-2023.4
Module := opope
VsimDir := $(SimDir)/$(target)
VsimCompileScript := $(VsimDir)/compile.$(target).tcl
VsimWaves := $(VsimDir)/wave.do
Tb := opope_tb_wrap
CompileFlags := +acc -permissive -suppress 2583 -suppress 13314

module_vcd ?= 0
tck       := 2

DEFS := -DCLKPERIOD=$(tck)ns
ifeq ($(module_vcd), 1)
vcd_file ?= "vcd/ope_highperf.vcd"
DEFS += -DVCD_DUMP
DEFS += -DVCD_DUMP_FILE=\"$(vcd_file)\"
endif


ifeq ($(OPOPE_COMPLEX),1)
	TbType := opope_complex_tb
else
	TbType := opope_tb
endif

ifeq ($(gui),1)
	VsimFlags += -do "set TbType $(TbType)" \
               -do "log -r /*"            \
               -do "source $(VsimWaves)"
else
	VsimFlags += -c
endif

VsimFlags += -suppress 3009 -suppress 8315

hw-clean:
	rm -rf $(VsimCompileScript) $(VsimDir)/transcript $(VsimDir)/modelsim.ini $(VsimDir)/*.wlf $(VsimDir)/work

hw-script:
	$(Bender) update
	$(Bender) script $(target)		 \
	--vlog-arg="$(CompileFlags)"   \
	--vcom-arg="-pedanticerrors"   \
	$(common_targs) $(common_defs) \
	$(sim_targs)                   \
	> $(VsimCompileScript)
	echo 'vopt $(CompileFlags) $(Tb) -o $(Tb)_opt' >> $(VsimCompileScript)

hw-build: hw-script
	cd $(VsimDir); \
	$(Questa) $(target) -c    \
	-do 'quit -code [source $(VsimCompileScript)]'

hw-run:
	cd $(VsimDir);                \
	$(Questa) $(target) $(Tb)_opt \
	$(VsimFlags)                  \
	+STIM_INSTR=$(STIM_INSTR) \
	+STIM_DATA=$(STIM_DATA)  \
	+PROB_STALL=$(P_STALL)    \
  -do "run -a;"

hw-all: hw-clean hw-script hw-build hw-run
