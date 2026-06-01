# Copyright 2025 ETH Zurich and University of Bologna.
# Licensed under the Apache License, Version 2.0, see LICENSE_SW for details.
# SPDX-License-Identifier: Apache-2.0
#
# Danilo Cammarata <dcammarata@iis.ee.ethz.ch>
#

#!/bin/bash

# === Setup ===
FIFOS=(0)
READOUT=(0) # Mux = 1, Sys = 0; You can choose among (0),(1),(0 1)
FPU=(0) # Mux = 1, Sys = 0; You can choose among (0),(1),(0 1)
HEIGHTS=(4 8 16)
ACCS=(16 32)
TARGET=$1

# Active flags
FIFO_0__H_04__ACC_16_active=1
FIFO_0__H_08__ACC_16_active=1
FIFO_0__H_16__ACC_16_active=1
FIFO_4__H_04__ACC_16_active=0
FIFO_4__H_08__ACC_16_active=0
FIFO_4__H_16__ACC_16_active=0
FIFO_0__H_04__ACC_32_active=1
FIFO_0__H_08__ACC_32_active=1
FIFO_0__H_16__ACC_32_active=1
FIFO_4__H_04__ACC_32_active=0
FIFO_4__H_08__ACC_32_active=0
FIFO_4__H_16__ACC_32_active=0

# === Functions ===
extract_info(){
  local transcript=$1
  tmp_log="logs/tmp.log"
  
  # Accept both "# [SAVE]" and "[SAVE]"
  grep -E '^[[:space:]]*(#[[:space:]]*)?\[SAVE\] -' "${transcript}" > "${tmp_log}" || true

  # parse the "[Data]" line
  data_line=$(grep -m1 -E '^[[:space:]]*(#[[:space:]]*)?\[SAVE\] - \[Data\]:' "$tmp_log" || echo "")
  cycles=$(echo "$data_line" | sed -n 's/.*Cycles: \([0-9]\+\).*/\1/p')
  memreq=$(echo "$data_line" | sed -n 's/.*TCDM Request count: \([0-9]\+\).*/\1/p')

  # detect success/fail
  if grep -qE '^[[:space:]]*#?[[:space:]]*\[SAVE\] - \[TB\] - Success!' "${tmp_log}"; then
    (( success_count++ ))
    status="${CheckMark} SUCCESS"
  else
    (( fail_count++ ))
    status="${CrossMark} FAILURE"
  fi 

  rm -rf "$tmp_log"
}

run_config() {
  local FIFO=$1
  local HEIGHT=$2
  local ACC=$3
  local FPFORMAT=$4
  local LOGFILE="$MAKE_PATH/logs/sim.log"
  local fp_combos
  local sizes_M
  local sizes_N
  local sizes_K

  sizes_M=(3 6 8 13 16 32 37 45 64 71 96)
  sizes_N=(1 2 3 4 5 6 7 8 9 10 11 12 16 30 32 41 46 53 64 82 87 96)
  sizes_K=(3 6 8 16 19 32 41 53 64 96 97)

  if   [ "$ACC" -eq 16 ]; then fp_combos=("FP8FP16" "FP16")
  elif [ "$ACC" -eq 32 ]; then fp_combos=("FP16FP32" "FP32")
  fi

  date '+%Y-%m-%d %H:%M:%S'
  echo "=== Running config: FIFO=$FIFO, HEIGHT=$HEIGHT, ACC=$ACC ==="
  echo -e  " Engine    Target     M   N   K   FIFO   MUX   FPU   Status       Cycles   MemReq   Util "
  echo -e  "──────────────────────────────────────────────────────────────────────────────────────────"

  # Update RTL files
  sed -i "14s|.*|  parameter int unsigned            ARRAY_HEIGHT = $HEIGHT;|" "$MAKE_PATH/rtl/opope_pkg.sv"
  sed -i "15s|.*|  parameter fpnew_pkg::fp_format_e  FPFORMAT     = fpnew_pkg::$FPFORMAT;|" "$MAKE_PATH/rtl/opope_pkg.sv"
  sed -i "42s|.*|  localparam int unsigned X_FIFO_DEPTH = $FIFO;|" "$MAKE_PATH/rtl/opope_buffers.sv"
  sed -i "43s|.*|  localparam int unsigned W_FIFO_DEPTH = $FIFO;|" "$MAKE_PATH/rtl/opope_buffers.sv"
  sed -i "44s|.*|  localparam int unsigned Y_FIFO_DEPTH = $FIFO;|" "$MAKE_PATH/rtl/opope_buffers.sv"
  sed -i "45s|.*|  localparam int unsigned Z_FIFO_DEPTH = $FIFO;|" "$MAKE_PATH/rtl/opope_buffers.sv"

  for fpu in "${FPU[@]}"; do
    if [ "$fpu" -eq 1 ]; then sed -i '21s/.*/ localparam int unsigned  CUSTOM_FPU  = 1                            ,/' "$MAKE_PATH/rtl/opope_engine.sv"
    else                      sed -i '21s/.*/ localparam int unsigned  CUSTOM_FPU  = 0                            ,/' "$MAKE_PATH/rtl/opope_engine.sv"
    fi
    for mux in "${READOUT[@]}"; do
      if [ "$mux" -eq 1 ]; then sed -i "22s|.*| localparam int unsigned  MUX_SH_n    = 1|" "$MAKE_PATH/rtl/opope_engine.sv"
      else                      sed -i "22s|.*| localparam int unsigned  MUX_SH_n    = 0|" "$MAKE_PATH/rtl/opope_engine.sv"
      fi

      for fp in "${fp_combos[@]}"; do
        make hw-clean target=$TARGET &> /dev/null
        make hw-script target=$TARGET &> /dev/null
        make hw-build target=$TARGET &> /dev/null
        for sizeM in "${sizes_M[@]}"; do
          for sizeN in "${sizes_N[@]}"; do
            for sizeK in "${sizes_K[@]}"; do
              make golden OP=gemm M=$sizeM N=$sizeN K=$sizeK fp_fmt=$fp &> /dev/null
              make sw-all &> /dev/null
              make hw-run target=$TARGET gui=0 &> "$LOGFILE"
              extract_info "$LOGFILE"
              ((total_count++))
              if   [ -n "$cycles" ] && [ "$cycles" -ne 0 ] && { [ "$fp" = "FP8FP16" ] || [ "$fp" = "FP16FP32" ]; }; then
                eff=$(echo "scale=2; $sizeM * $sizeN * $sizeK * 50 / ($HEIGHT * $HEIGHT * $cycles)" | bc -l)
              elif [ -n "$cycles" ] && [ "$cycles" -ne 0 ] && { [ "$fp" = "FP16" ] || [ "$fp" = "FP32" ]; }; then
                eff=$(echo "scale=2; $sizeM * $sizeN * $sizeK * 100 / ($HEIGHT * $HEIGHT * $cycles)" | bc -l)
              else
                eff="NA"
              fi
              echo -e "$(printf "%2s x %2s   %-10s %3d %3d %3d   %2d     %d     %d   %-8s  %7s  %6s   %7s" \
                "$HEIGHT" "$HEIGHT" "$fp" "$sizeM" "$sizeN" "$sizeK" "$FIFO" "$mux" "$fpu" "$status" "${cycles:--}" "${memreq:--}" "$eff")"
            done
          done
        done
      done
    done
  done
}

# === Run ===
set -u
set -o pipefail
# ─── Set directories ────────────────────────────────────────────────────────────
CURRENT_DIR=$(pwd)
SCRIPT_PATH="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
MAKE_PATH=$SCRIPT_PATH/..
cd $MAKE_PATH

# ─── Colours & symbols ──────────────────────────────────────────────────────────
CheckMark="✅"
CrossMark="❌"

# ─── Counters & storage ─────────────────────────────────────────────────────────
total_count=0
success_count=0
fail_count=0

# Header: Target, M, N, K, FIFO, MUX, FPU, Status,   Cycles,    MemReq
# ─── Simulations ────────────────────────────────────────────────────────────────
sed -i '528s/.*/    ENABLE_ENGINE_OUTPUT = 0;/' "$MAKE_PATH/target/sim/src/opope_tb.sv"
sed -i '21s/.*/ localparam int unsigned  CUSTOM_FPU  = 1                            ,/' "$MAKE_PATH/rtl/opope_engine.sv"
sed -i '22s/.*/ localparam int unsigned  MUX_SH_n    = 1/' "$MAKE_PATH/rtl/opope_engine.sv"
for FIFO in "${FIFOS[@]}"; do
  for HEIGHT in "${HEIGHTS[@]}"; do
    for ACC in "${ACCS[@]}"; do
      flag="FIFO_${FIFO}__H_$(printf '%02d' $HEIGHT)__ACC_${ACC}_active"

      if [ "$ACC" -eq 16 ]; then
        FPFORMAT="FP16"
      elif [ "$ACC" -eq 32 ]; then
        FPFORMAT="FP32"
      fi

      if [ "${!flag}" -eq 1 ]; then
        run_config "$FIFO" "$HEIGHT" "$ACC" "$FPFORMAT" 
      fi
    done
  done
done
# ─── Print summary ──────────────────────────────────────────────────────────────
echo -e "\n========= End Report ========="
echo -e "\nTotals:   runs=${total_count}, success=${success_count}, fail=${fail_count}"
echo -e "Error rate: $(printf "%.2f%%" "$(echo "100 * $fail_count / $total_count" | bc -l)")"

### DEFAULT CONFIGURATION
sed -i '528s/.*/    ENABLE_ENGINE_OUTPUT = 0;/' "$MAKE_PATH/target/sim/src/opope_tb.sv"
sed -i '14s/.*/  parameter int unsigned            ARRAY_HEIGHT = 8;/' "$MAKE_PATH/rtl/opope_pkg.sv"
sed -i '15s/.*/  parameter fpnew_pkg::fp_format_e  FPFORMAT     = fpnew_pkg::FP16;/' "$MAKE_PATH/rtl/opope_pkg.sv"
sed -i '42s/.*/  localparam int unsigned X_FIFO_DEPTH = 0;/' "$MAKE_PATH/rtl/opope_buffers.sv"
sed -i '43s/.*/  localparam int unsigned W_FIFO_DEPTH = 0;/' "$MAKE_PATH/rtl/opope_buffers.sv"
sed -i '44s/.*/  localparam int unsigned Y_FIFO_DEPTH = 0;/' "$MAKE_PATH/rtl/opope_buffers.sv"
sed -i '45s/.*/  localparam int unsigned Z_FIFO_DEPTH = 0;/' "$MAKE_PATH/rtl/opope_buffers.sv"
sed -i '21s/.*/ localparam int unsigned  CUSTOM_FPU  = 1                            ,/' "$MAKE_PATH/rtl/opope_engine.sv"
sed -i '22s/.*/ localparam int unsigned  MUX_SH_n    = 1/' "$MAKE_PATH/rtl/opope_engine.sv"
cd $CURRENT_DIR
echo "=== All done ==="