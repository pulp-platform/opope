# Copyright 2023 ETH Zurich and University of Bologna.
# Licensed under the Apache License, Version 2.0, see LICENSE_SW for details.
# SPDX-License-Identifier: Apache-2.0
#
# Danilo Cammarata <dcammarata@iis.ee.ethz.ch>
#
# Makefragment for Verilator simulation.

Verilator ?= $(VerilatorInstallDir)/bin/verilator
GtkWave ?= gtkwave
Module := opope
ObjDirName := obj_dir
Vmodule := V$(Module)
VerilatorDir := $(SimDir)/$(target)
VerilatorSrc := $(SimDir)/src
VerilatorAbsObjDir := $(VerilatorDir)/$(ObjDirName)
VerilatorCompileScript := $(VerilatorDir)/compile.$(target).tcl
VerilatorWaves := $(VerilatorDir)/opope.vcd

ifeq ($(gui),1)
TRACE_FLAGS := --trace
TRACE_DEFINE := -DTRACE_ENABLE
else
TRACE_FLAGS := --no-trace
TRACE_DEFINE :=
endif

hw-clean:
	rm -rf $(VerilatorAbsObjDir) $(VerilatorCompileScript) $(VerilatorWaves) $(VerilatorDir)/transcript

hw-script:
	$(Bender) update
	$(Bender) script $(target)     \
	$(common_targs) $(common_defs) \
	$(sim_targs)                   \
	> $(VerilatorCompileScript)

hw-build: hw-script
	$(Verilator) $(TRACE_FLAGS) --timing --bbox-unsup \
	-Wall -Wno-fatal --Wno-lint --Wno-UNOPTFLAT --Wno-MODDUP -Wno-BLKANDNBLK \
	--x-assign unique --x-initial unique --top-module $(Module)_tb --Mdir $(VerilatorAbsObjDir) \
	-CFLAGS "-DTbName=$(Vmodule)_tb -DWafeformPath=$(VerilatorWaves) $(TRACE_DEFINE)" \
	-sv -cc -f $(VerilatorCompileScript) --exe $(VerilatorSrc)/$(Module)_tb.cpp
	make -C $(VerilatorAbsObjDir) -f $(Vmodule)_tb.mk $(Vmodule)_tb

hw-run:
	cd $(VerilatorDir);           \
	./$(ObjDirName)/$(Vmodule)_tb
ifeq ($(gui),1)
	$(GtkWave) $(VerilatorWaves)
endif

hw-all: hw-clean hw-script hw-build hw-run