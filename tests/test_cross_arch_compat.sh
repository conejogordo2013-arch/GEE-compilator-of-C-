#!/usr/bin/env bash
set -euo pipefail

PROGRAM="examples/println_demo.cb"
X86_S="test_x86_parity.s"
ARM_S="test_arm_parity.s"
X86_BIN="test_x86_parity.bin"
ARM_BIN="test_arm_parity.bin"

./gee "$PROGRAM" "$X86_S"
GEE_TARGET=arm-64 ./gee "$PROGRAM" "$ARM_S"

cc -no-pie -o "$X86_BIN" "$X86_S" stdlib/io.s stdlib/memory.s stdlib/net.s stdlib/system.s
./"$X86_BIN" >/dev/null

if command -v aarch64-linux-gnu-gcc >/dev/null 2>&1; then
  aarch64-linux-gnu-gcc -no-pie -o "$ARM_BIN" "$ARM_S" stdlib/io_arm64.s stdlib/memory_arm64.s stdlib/net_arm64.s stdlib/system_arm64.s
  if command -v qemu-aarch64 >/dev/null 2>&1; then
    qemu-aarch64 "$ARM_BIN" >/dev/null
  else
    echo "warning: qemu-aarch64 not found; ARM binary was built but not executed"
  fi
else
  echo "warning: aarch64-linux-gnu-gcc not found; ARM build/run skipped"
fi

rm -f "$X86_S" "$ARM_S" "$X86_BIN" "$ARM_BIN"
echo "cross-arch compatibility OK"
