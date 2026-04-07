#!/usr/bin/env bash
set -euo pipefail
ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
REPORT_DIR="$ROOT_DIR/.gee_reports"
mkdir -p "$REPORT_DIR"
REPORT="$REPORT_DIR/latest.txt"

pass=0
fail=0
run_cmd() {
  local cmd="$1"
  if eval "$cmd"; then
    echo "PASS | $cmd" | tee -a "$REPORT"
    pass=$((pass+1))
  else
    echo "FAIL | $cmd" | tee -a "$REPORT"
    fail=$((fail+1))
  fi
}

: > "$REPORT"
run_cmd "make stage0"
run_cmd "make quality-gate"
run_cmd "make abi-interop"

echo "summary: pass=$pass fail=$fail" | tee -a "$REPORT"
[[ $fail -eq 0 ]]
