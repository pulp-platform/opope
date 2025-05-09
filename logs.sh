#!/usr/bin/env bash
set -u
set -o pipefail

# ─── Colours & symbols ──────────────────────────────────────────────────────────
Red="\e[31m"
Green="\e[32m"
Yellow="\e[33m"
EndColor="\e[0m"
CheckMark="✅"
CrossMark="❌"

# ─── Parameters ─────────────────────────────────────────────────────────────────
# TARGET=( "FP16" "FP8FP16" )
# Shape=( 32 64 96 128 256 )
TARGET=( "FP16" "FP8FP16" )
Shape=( 32 64 96 )

OUTDIR="save_logs"
TMPDIR="tmp_logs"
mkdir -p "${OUTDIR}" "${TMPDIR}"

# ─── Counters & storage ─────────────────────────────────────────────────────────
total_count=0
success_count=0
fail_count=0

declare -a SUMMARY_LINES
# Header: Target, M, N, K, Status, Time,   Cycles,    MemReq
SUMMARY_LINES+=(
  "Target      M    N    K    Status     Time     Cycles    MemReq"
)
SUMMARY_LINES+=(
  "────────────────────────────────────────────────────────────────────────────"
)

# ─── Helper: format seconds as MM:SS.SS ──────────────────────────────────────────
format_time() {
  local raw=$1
  local mins=$(echo "$raw/60" | bc)
  local secs=$(echo "$raw - ($mins * 60)" | bc -l)
  printf "%03d:%05.2f" "$mins" "$secs"
}

source scripts/setup-hwpe.sh

# ─── Main loop ───────────────────────────────────────────────────────────────────
for T in "${TARGET[@]}"; do
  echo -e "\n${Yellow}========= Target: ${T} =========${EndColor}\n"

  for S in "${Shape[@]}"; do
    (( total_count++ ))
    echo -e "${Yellow}→ Running ${T}, M=${S}, N=${S}, K=${S}…${EndColor}"

    start=$(date +%s.%N)
    tmp_log="${TMPDIR}/run_${T}_M${S}_N${S}_K${S}.log"
    outfile="${OUTDIR}/save_${T}_M${S}_N${S}_K${S}.txt"

    # golden (warn but continue)
    if ! make golden OP=gemm M="$S" N="$S" K="$S" fp_fmt="$T" transpose=1 \
         > /dev/null 2>&1; then
      echo -e "${Red}[WARN] golden build failed${EndColor}"
    fi

    # hw flow (capture all, don’t exit on fail)
    make hw-clean sw-clean synth-ips hw-script hw-build sw-build hw-run target=vsim \
      > "${tmp_log}" 2>&1 || true

    end=$(date +%s.%N)
    elapsed=$(echo "$end - $start" | bc -l)
    tstr=$(format_time "$elapsed")

    # extract only "# [SAVE] -" lines
    grep -E '^[[:space:]]*#[[:space:]]*\[SAVE\] -' "${tmp_log}" > "${outfile}" || true

    # parse the "[Data]" line
    data_line=$(grep -m1 -E '^\s*#\s*\[SAVE\] - \[Data\]:' "$outfile" || echo "")
    cycles=$(echo "$data_line" | sed -n 's/.*Cycles: \([0-9]\+\).*/\1/p')
    memreq=$(echo "$data_line" | sed -n 's/.*TCDM Request count: \([0-9]\+\).*/\1/p')

    # detect success/fail
    if grep -q '^\s*#\s*\[SAVE\] - \[TB\] - Success!' "${outfile}"; then
      (( success_count++ ))
      status="${Green}${CheckMark} SUCCESS${EndColor}"
    else
      (( fail_count++ ))
      status="${Red}${CrossMark} FAIL${EndColor}"
    fi

    # append a nicely‐aligned summary line
    SUMMARY_LINES+=(
      "$(printf "%-10s %3d %3d %3d   %-8s   %7s   %7s   %6s" \
        "$T" "$S" "$S" "$S" "$status" "$tstr" "${cycles:--}" "${memreq:--}")"
    )
  done
done

# ─── Cleanup ─────────────────────────────────────────────────────────────────────
rm -rf "${TMPDIR}"

# ─── Print summary ──────────────────────────────────────────────────────────────
echo -e "\n${Yellow}========= Final Report =========${EndColor}"
for line in "${SUMMARY_LINES[@]}"; do
  echo -e "$line"
done

echo -e "\nTotals:   runs=${total_count}, success=${success_count}, fail=${fail_count}"
echo -e "Error rate: $(printf "%.2f%%" "$(echo "100 * $fail_count / $total_count" | bc -l)")"