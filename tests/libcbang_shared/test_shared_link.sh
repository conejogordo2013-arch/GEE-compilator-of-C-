#!/usr/bin/env bash
set -euo pipefail

WORK_DIR="$(mktemp -d)"
trap 'rm -rf "$WORK_DIR"' EXIT

AS_BIN="${AS_BIN:-as}"
LD_BIN="${LD_BIN:-ld}"
GEE_BIN="${GEE_BIN:-./gee}"

bash scripts/build-libcbang-shared.sh x86-64 ./libcbang_shared.so

"$GEE_BIN" examples/libcbang_shared_demo.cb "$WORK_DIR/demo.s" >/dev/null
"$AS_BIN" --64 -o "$WORK_DIR/demo.o" "$WORK_DIR/demo.s"
"$AS_BIN" --64 -o "$WORK_DIR/system.o" stdlib/system.s

"$LD_BIN" -e main -o "$WORK_DIR/demo_bin" "$WORK_DIR/demo.o" "$WORK_DIR/system.o" -L. -lcbang_shared
LD_LIBRARY_PATH=. "$WORK_DIR/demo_bin"

echo "libcbang shared x86 OK"
