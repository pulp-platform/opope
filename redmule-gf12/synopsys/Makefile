# Copyright (C) 2022-2023 ETH Zurich and University of Bologna
# 
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
# 
#     http://www.apache.org/licenses/LICENSE-2.0
# 
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
# SPDX-License-Identifier: Apache-2.0

SYNPT    ?= primetime-2022.03 pt_shell
NAME     ?= redmule_tb_opt
VCD			 ?= ../modelsim/vcd/ope_highperf.vcd
VendorDir ?= /scratch/dcammarata/ope-engine/vendor
InstallDir ?= $(VendorDir)/install
CargoInstallDir := $(InstallDir)/cargo
Bender     ?= $(CargoInstallDir)/bin/bender

Tb := redmule_tb_wrap
# CompileFlags := +acc -permissive -suppress 2583 -suppress 13314
CompileFlags := +notimingchecks 
CompileFlags += +nospecify 
CompileFlags += -suppress vlog-2583 
CompileFlags += -suppress vlog-13314 
CompileFlags += -suppress vlog-13233

VsimCompileScript := compile_power.vsim.tcl

TCP   ?= 2
PARAM += set TCP ${TCP}

module_vcd ?= 0
tck       := 2

DEFS := -DCLKPERIOD=$(tck)ns
ifeq ($(module_vcd), 1)
	vcd_file ?= "vcd/ope_highperf.vcd"
	DEFS += -DVCD_DUMP
endif

common_targs += -t cv32e40p_exclude_tracer
common_targs += -t redmule_hwpe
common_targs += -e cv32e40x
common_targs += -t DEBUG
common_targs += -t redmule_test_hwpe 
# common_targs += -t redmule_test_hwpe_gate 

common_defs  += -D COREV_ASSERT_OFF

sim_targs += -t rtl
sim_targs += -t redmule_test_hwpe
sim_targs += -t DEBUG

DESIGN ?= redmule_hwpe
library 	?= gate

clean:
	rm -f *.log
	rm -rf WORK/*

run:
	synopsys-2020.09 dc_shell -64 -f scripts/$(DESIGN).tcl >& run.log &

MODELSIM := "../modelsim"
clean-power:
	@echo "Cleaning Gate and VCD ..."
	@if [ -d "$(MODELSIM)" ]; then \
		cd $(MODELSIM) && pwd && \
		rm -rf gate/* compile_power.vsim.tcl vcd/*; \
	else \
		echo "$(MODELSIM) does not exist. Skipping."; \
	fi

hw-script-power:
	$(Bender) update
	$(Bender) script vsim				 \
	${DEFS} 											 \
	--vlog-arg="$(CompileFlags) -work $(library) "   \
	--vcom-arg="-pedanticerrors"   \
	$(common_targs) $(common_defs) \
	$(sim_targs)                   \
	> $(VsimCompileScript)
	echo "exit" >> $(VsimCompileScript)
	# echo 'vopt $(CompileFlags) $(Tb) -o $(Tb)_opt' >> $(VsimCompileScript)



run-power-sim:
	@echo "Running Gate Compile and Post-Synthesis Simulation ..."
	# @source ../../scripts/setup-hwpe.sh; \
	# $(MAKE) -C ../../ golden OP=gemm M=32 N=32 K=32 fp_fmt=FP16 transpose=1; \
	# $(MAKE) -C ../../ sw-clean sw-build target=vsim; \
	cd $(MODELSIM); \
	csh compile_gate.csh; \
	csh sim_postsynth.csh

run-power-analysis:
	@echo "Running Power Analysis ..."
	$(SYNPT) -x "${PARAM}; set NAME ${NAME}; set VCD ${VCD}; source scripts/power_lib.tcl; source scripts/power.tcl"


all:
	clean run

power:
	clean-power run-power
