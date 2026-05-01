#!/usr/bin/env bash
set -euo pipefail

if ! command -v aarch64-linux-gnu-as >/dev/null 2>&1 || ! command -v aarch64-linux-gnu-ld >/dev/null 2>&1; then
  echo "SKIP: arm64 toolchain no disponible"
  exit 0
fi

WORK_DIR="$(mktemp -d)"
trap 'rm -rf "$WORK_DIR"' EXIT

AS_BIN="aarch64-linux-gnu-as"
LD_BIN="aarch64-linux-gnu-ld"
GEE_BIN="${GEE_BIN:-./gee}"

bash scripts/build-libcbang-shared.sh arm-64 ./libcbang_shared_arm64.so

GEE_TARGET=arm-64 "$GEE_BIN" examples/libcbang_shared_demo.cb "$WORK_DIR/demo_arm64.s" >/dev/null
"$AS_BIN" -o "$WORK_DIR/demo_arm64.o" "$WORK_DIR/demo_arm64.s"
"$AS_BIN" -o "$WORK_DIR/system_arm64.o" stdlib/system_arm64.s
"$LD_BIN" -e main -o "$WORK_DIR/demo_bin_arm64" "$WORK_DIR/demo_arm64.o" "$WORK_DIR/system_arm64.o" -L. -l:libcbang_shared_arm64.so

if command -v qemu-aarch64 >/dev/null 2>&1; then
  LD_LIBRARY_PATH=. qemu-aarch64 "$WORK_DIR/demo_bin_arm64"
else
  echo "SKIP: qemu-aarch64 no disponible (build/link ARM64 OK)"
fi
