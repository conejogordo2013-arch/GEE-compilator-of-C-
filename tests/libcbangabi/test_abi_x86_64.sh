#!/usr/bin/env bash
set -euo pipefail

WORK_DIR="$(mktemp -d)"
trap 'rm -rf "$WORK_DIR"' EXIT

GEE_BIN="${GEE_BIN:-./gee}"

bash scripts/build-libcbangabi-shared.sh x86-64 ./libcbangabi.so

"$GEE_BIN" tests/libcbangabi/program_a.cb "$WORK_DIR/program_a.s" >/dev/null
"$GEE_BIN" tests/libcbangabi/program_b.cb "$WORK_DIR/program_b.s" >/dev/null
cc -no-pie -o "$WORK_DIR/program_bin" "$WORK_DIR/program_a.s" "$WORK_DIR/program_b.s" stdlib/system.s -L. -lcbangabi
LD_LIBRARY_PATH=. "$WORK_DIR/program_bin"

echo "cbangabi x86 OK"
