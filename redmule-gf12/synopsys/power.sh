#!/usr/bin/env bash
set -u
set -o pipefail

TARGET=( "FP16" "FP8FP16" )
SHAPES=( 32 64 96)

TCP=2
REPDIR_BASE="reports/module_power_${TCP}ns"

source ../../scripts/setup-hwpe.sh
make hw-script-power
mkdir -p "$REPDIR_BASE"
for T in "${TARGET[@]}"; do
  for S in "${SHAPES[@]}"; do
    echo "Running: $T, M=$S N=$S K=$S"

    make -C ../.. golden OP=gemm M=$S N=$S K=$S fp_fmt=$T transpose=1 > /dev/null 2>&1
    make -C ../../ sw-clean sw-build target=vsim > /dev/null 2>&1

    make run-power-sim 
    make run-power-analysis 

    OUTDIR="${REPDIR_BASE}/module_power_${TCP}ns_M${S}_N${S}_K${S}_${T}"
    mkdir -p "$OUTDIR"
    cp reports/module_power_2ns/signoff_power_redmule_tb_opt.rpt "$OUTDIR/" || echo "Failed to save report for M=$S"
  done
done