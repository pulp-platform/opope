# Copyright 2025 ETH Zurich and University of Bologna.
# Licensed under the Apache License, Version 2.0, see LICENSE_SW for details.
# SPDX-License-Identifier: Apache-2.0
#
# Danilo Cammarata <dcammarata@iis.ee.ethz.ch>
#
# Top-level Makefile

SHELL      := /bin/bash
# Directories
RootDir    := $(dir $(abspath $(firstword $(MAKEFILE_LIST))))
TargetDir  := $(RootDir)/target
SimDir     := $(TargetDir)/sim
ScriptsDir := $(RootDir)/scripts
SW         ?= $(RootDir)/sw
# Install tools
VendorDir 					 ?= $(RootDir)vendor
InstallDir 					 ?= $(VendorDir)/install
# Verilator
VerilatorVersion 		 ?= v5.034
VerilatorInstallDir  := $(InstallDir)/verilator
VerilatorCC  				 := gcc-11.2.0
VerilatorCXX 				 := g++-11.2.0
# GCC
GccInstallDir 			 := $(InstallDir)/riscv
Gcc           			 ?= $(GccInstallDir)/bin/
# Bender
RustupInit 					 := $(ScriptsDir)/rustup-init.sh
CargoInstallDir 		 := $(InstallDir)/cargo
RustupInstallDir 		 := $(InstallDir)/rustup
Cargo 							 := $(CargoInstallDir)/bin/cargo
Bender     					 ?= $(CargoInstallDir)/bin/bender
# HW
compile_script_synth ?= $(RootDir)scripts/synth_compile.tcl
# SW
BUILD_DIR  ?= $(SW)/build
ISA        ?= riscv
ARCH       ?= rv
XLEN       ?= 32
XTEN       ?= imc
PYTHON     ?= python3

# Configuration Parameters
target 	 			?= verilator
gui      			?= 0
verbose 			?= 0
P_STALL  			?= 0.0
DEBUG    			?= 1
OPOPE_COMPLEX ?= 0

# Included makefrags
include $(SimDir)/$(target)/$(target).mk
include bender_common.mk
include bender_sim.mk
include bender_synth.mk

ifeq ($(OPOPE_COMPLEX),1)
	TEST_SRCS := $(SW)/opope_complex.c
else
	TEST_SRCS := $(SW)/opope.c
endif


ifeq ($(verbose),1)
	FLAGS += -DVERBOSE
endif

ifeq ($(debug),1)
	FLAGS += -DDEBUG
endif


# Include directories

# Build implicit rules

#################
#   Init Repo   #
#################

init: riscv32-gcc bender verilator
	source scripts/setup-py.sh

####################
#   Golden Model   #
####################

OP     		?= gemm
fp_fmt 		?= FP16
M      		?= 4
N      		?= 4
K      		?= 4
transpose ?= 1

golden: golden-clean
	$(MAKE) -C golden-model $(OP) SW=$(SW)/inc M=$(M) N=$(N) K=$(K) fp_fmt=$(fp_fmt) transpose=$(transpose)

golden-clean:
	$(MAKE) -C golden-model golden-clean

##########
#   SW   #
##########

INC += -I$(SW)
INC += -I$(SW)/inc
INC += -I$(SW)/utils

BOOTSCRIPT := $(SW)/kernel/crt0.S
LINKSCRIPT := $(SW)/kernel/link.ld

CC=$(Gcc)$(ISA)$(XLEN)-unknown-elf-gcc
LD=$(CC)
OBJDUMP=$(Gcc)$(ISA)$(XLEN)-unknown-elf-objdump
CC_OPTS=-march=$(ARCH)$(XLEN)$(XTEN) -mabi=ilp32 -D__$(ISA)__ -O2 -g -Wextra -Wall -Wno-unused-parameter -Wno-unused-variable -Wno-unused-function -Wundef -fdata-sections -ffunction-sections -MMD -MP -Wincompatible-pointer-types -Wimplicit-fallthrough
LD_OPTS=-march=$(ARCH)$(XLEN)$(XTEN) -mabi=ilp32 -D__$(ISA)__ -MMD -MP -nostartfiles -nostdlib -Wl,--gc-sections

# Setup build object dirs
CRT=$(BUILD_DIR)/crt0.o
OBJ=$(BUILD_DIR)/verif.o
BIN=$(BUILD_DIR)/verif
DUMP=$(BUILD_DIR)/verif.dump
STIM_INSTR=$(BUILD_DIR)/stim_instr.txt
STIM_DATA=$(BUILD_DIR)/stim_data.txt

dis:
	$(OBJDUMP) -d $(BIN) > $(DUMP)

$(STIM_INSTR) $(STIM_DATA): $(BIN)
	objcopy --srec-len 1 --output-target=srec $(BIN) $(BIN).s19
	$(PYTHON) scripts/parse_s19.py < $(BIN).s19 > $(BIN).txt
	$(PYTHON) scripts/s19tomem.py $(BIN).txt $(STIM_INSTR) $(STIM_DATA)

$(BIN): $(CRT) $(OBJ)
	$(LD) $(LD_OPTS) -o $(BIN) $(CRT) $(OBJ) -T$(LINKSCRIPT)

$(CRT): $(BUILD_DIR)
	$(CC) $(CC_OPTS) -c $(BOOTSCRIPT) -o $(CRT)

$(OBJ): $(TEST_SRCS)
	$(CC) $(CC_OPTS) -c $(TEST_SRCS) $(FLAGS) $(INC) -o $(OBJ)

$(BUILD_DIR):
	mkdir -p $(BUILD_DIR)

sw-build: $(STIM_INSTR) $(STIM_DATA_X_W) $(STIM_DATA_Y_Z) dis

sw-clean:
	rm -rf $(BUILD_DIR)

sw-all: sw-clean sw-build

######################
#   RTL Simulation   #
######################

synth-ips:
	$(Bender) update
	$(Bender) script synopsys      \
	$(common_targs) $(common_defs) \
	$(synth_targs) $(synth_defs)   \
	> ${compile_script_synth}

sim: hw-clean sw-clean synth-ips hw-script hw-build sw-build hw-run

sim-all:
	mkdir -p logs
	rm -rf logs/*
	source scripts/run_all.sh $(target) &> logs/sim_all.log

#############
#   Clean   #
#############

clean-all: sw-clean
	rm -rf $(RootDir).bender
	rm -rf $(compile_script)

###########
#   GCC   #
###########

target/sim/toolchain/riscv-gnu-toolchain:
	mkdir -p target/sim/toolchain/
	cd target/sim/toolchain/ && git clone https://github.com/pulp-platform/pulp-riscv-gnu-toolchain.git riscv-gnu-toolchain
	cd target/sim/toolchain/riscv-gnu-toolchain &&           \
		git checkout 70acebe256fc49114b5f068fa79f03eb9affed09 && \
		git submodule update --init --recursive --jobs=8 .

riscv32-gcc: target/sim/toolchain/riscv-gnu-toolchain
	rm -rf $(GccInstallDir)
	mkdir -p $(GccInstallDir)
	cd target/sim/toolchain/riscv-gnu-toolchain && rm -rf build && mkdir -p build && cd build && \
	export PATH=$$(echo $$PATH | tr ':' '\n' | grep -v '$(GccInstallDir)' | tr '\n' ':') && \
	CC=$(VerilatorCC) CXX=$(VerilatorCXX) \
	../configure --prefix=$(GccInstallDir) --with-arch=rv32imafd --with-abi=ilp32d --with-cmodel=medlow --enable-multilib \
	&& make MAKEINFO=true -j4

##############
#   Bender   #
##############

bender: $(CargoInstallDir)/bin/bender
$(CargoInstallDir)/bin/bender:
	rm -rf $(CargoInstallDir) $(RustupInstallDir)
	curl --proto '=https' --tlsv1.2 https://sh.rustup.rs -sSf > $(RustupInit)
	mkdir -p $(InstallDir)
	export CARGO_HOME=$(CargoInstallDir) && export RUSTUP_HOME=$(RustupInstallDir) && \
	chmod +x $(RustupInit); source $(RustupInit) -y && \
	$(Cargo) install bender
	rm -rf $(RustupInit)

###############
#  Verilator  #
###############

target/sim/toolchain/verilator:
	mkdir -p target/sim/toolchain
	cd target/sim/toolchain && git clone https://github.com/verilator/verilator.git
	cd target/sim/toolchain/verilator &&                     \
		git checkout $(VerilatorVersion) && \
		git submodule update --init --recursive --jobs=8 .

target/sim/toolchain/help2man:
	mkdir -p target/sim/toolchain/help2man
	cd target/sim/toolchain/help2man && wget -c https://ftp.gnu.org/gnu/help2man/help2man-1.49.3.tar.xz
	cd target/sim/toolchain/help2man && tar xf help2man-1.49.3.tar.xz

verilator: $(VerilatorInstallDir)/bin/verilator
$(VerilatorInstallDir)/bin/verilator: target/sim/toolchain/verilator target/sim/toolchain/help2man
	rm -rf $(VerilatorInstallDir)
	cd target/sim/toolchain/help2man/help2man-1.49.3 && ./configure --prefix=$(VerilatorInstallDir) && make && make install
	cd $<; unset VERILATOR_ROOT; \
	autoconf && CC=$(VerilatorCC) CXX=$(VerilatorCXX) ./configure --prefix=$(VerilatorInstallDir) $(VERILATOR_CI) && \
	PATH=$(PATH):$(VerilatorInstallDir)/bin make -j4 && make install
