# Copyright 2025 ETH Zurich and University of Bologna.
# Licensed under the Apache License, Version 2.0, see LICENSE_SW for details.
# SPDX-License-Identifier: Apache-2.0
#
# Danilo Cammarata <dcammarata@iis.ee.ethz.ch>
#
# O-POPE Golden Model Makefile

SHELL   := /bin/bash
CUR_DIR := $(shell pwd)
SW      ?=
PYTHON  ?= python3 

## Perform Matrix-Matrix Operations of the kins _Z = Y (op2) (X (op1) W)_
## We assume X is _MxN_, W is _NxK_, while Y and Z are _MxK_

# Tensors Dimensions
M ?= 3
N ?= 3
K ?= 3
transpose ?= 1

# FP format
fp_fmt ?= FP16

check_sw:
	mkdir -p $(SW)

# The current Makefile can be used as follows:
# make $(operation)      -> execute any of the supported GEMM-Ops operation (Z = (X op1 W) op2 Y)
# Set the tensor dimensions while launching the Makefile. For example, in order to run a GEMM
# between three 64x64 matrices, run:
# `make clean gemm M=64 N=64 K=64`

addmax: check_sw
	mkdir -p $@/txt;                          \
	cd $(CUR_DIR)/$(fp_fmt);                  \
	$(PYTHON) ./scripts/$@.py                   \
	--m_size $(M) --n_size $(N) --k_size $(K) \
	--inc_dir $(SW)                           \
	--txt_dir $(CUR_DIR)/$@/txt;

addmin: check_sw
	mkdir -p $@/txt;                          \
	cd $(CUR_DIR)/$(fp_fmt);                  \
	$(PYTHON) ./scripts/$@.py                   \
	--m_size $(M) --n_size $(N) --k_size $(K) \
	--inc_dir $(SW)                           \
	--txt_dir $(CUR_DIR)/$@/txt;
	
gemm: check_sw
	mkdir -p $@/txt;                          							\
	cd $(CUR_DIR)/$(fp_fmt);                  							\
	$(PYTHON) ./scripts/$@.py                   							\
	--m_size $(M) --n_size $(N) --k_size $(K) 							\
	--inc_dir $(SW)                           							\
	--txt_dir $(CUR_DIR)/$@/txt --transpose $(transpose);

matmul: check_sw
	mkdir -p $@/txt;                          \
	cd $(CUR_DIR)/$(fp_fmt);                  \
	$(PYTHON) ./scripts/$@.py                   \
	--m_size $(M) --n_size $(N) --k_size $(K) \
	--inc_dir $(SW)                           \
	--txt_dir $(CUR_DIR)/$@/txt;

maxmin: check_sw
	mkdir -p $@/txt;                          \
	cd $(CUR_DIR)/$(fp_fmt);                  \
	$(PYTHON) ./scripts/$@.py                   \
	--m_size $(M) --n_size $(N) --k_size $(K) \
	--inc_dir $(SW)/inc                       \
	--txt_dir $(CUR_DIR)/$@/txt;

minmax: check_sw
	mkdir -p $@/txt;                          \
	cd $(CUR_DIR)/$(fp_fmt);                  \
	$(PYTHON) ./scripts/$@.py                   \
	--m_size $(M) --n_size $(N) --k_size $(K) \
	--inc_dir $(SW)                           \
	--txt_dir $(CUR_DIR)/$@/txt;

mulmax: check_sw
	mkdir -p $@/txt;                          \
	cd $(CUR_DIR)/$(fp_fmt);                  \
	$(PYTHON) ./scripts/$@.py                   \
	--m_size $(M) --n_size $(N) --k_size $(K) \
	--inc_dir $(SW)                           \
	--txt_dir $(CUR_DIR)/$@/txt;

mulmin: check_sw
	mkdir -p $@/txt;                          \
	cd $(CUR_DIR)/$(fp_fmt);                  \
	$(PYTHON) ./scripts/$@.py                   \
	--m_size $(M) --n_size $(N) --k_size $(K) \
	--inc_dir $(SW)                           \
	--txt_dir $(CUR_DIR)/$@/txt;

golden-clean:
	rm -rf FP16/net_parameters.h
	rm -rf FP8/net_parameters.h
	rm -rf FP16/scripts/__pycache__
	rm -rf FP8/scripts/__pycache__
	rm -rf addmax addmin gemm maxmin minmax mulmax mulmin
