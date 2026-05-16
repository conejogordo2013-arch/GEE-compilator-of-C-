#!/usr/bin/env bash
set -euo pipefail

GEE_BIN=${GEE_BIN:-./gee}
ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
WORK_DIR="$(mktemp -d)"
trap 'rm -rf "$WORK_DIR"' EXIT

mods=(
  "$ROOT_DIR/libdrawg/drawg.cb"
  "$ROOT_DIR/libgfx/gfx2d.cb"
  "$ROOT_DIR/libdrawg/backend_linux_x11.cb"
  "$ROOT_DIR/examples/gfx2d_window_demo.cb"
)

asms=()
for src in "${mods[@]}"; do
  out="$WORK_DIR/$(basename "${src%.cb}").s"
  "$GEE_BIN" "$src" "$out" >/dev/null
  asms+=("$out")
done

gcc "${asms[@]}" "$ROOT_DIR/stdlib/system.s" "$ROOT_DIR/stdlib/memory.s" "$ROOT_DIR/stdlib/net.s" -lX11 -o "$WORK_DIR/gfx2d_x11_demo"

echo "[PASS] build x11 demo: $WORK_DIR/gfx2d_x11_demo"
