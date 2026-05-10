#!/usr/bin/env bash
set -euo pipefail

GEE_BIN=${GEE_BIN:-./gee}
ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
WORK_DIR="$(mktemp -d)"
trap 'rm -rf "$WORK_DIR"' EXIT

mods=(
  "$ROOT_DIR/libgfx/backend_interface.cb"
  "$ROOT_DIR/libgfx/api.cb"
)

mod_asms=()
for m in "${mods[@]}"; do
  out="$WORK_DIR/$(basename "${m%.cb}").s"
  "$GEE_BIN" "$m" "$out" >/dev/null
  mod_asms+=("$out")
done

bin="$WORK_DIR/test_gfx_bootstrap"
GEE_BIN="$GEE_BIN" bash "$ROOT_DIR/scripts/gee-asm-link.sh" host "$ROOT_DIR/examples/gfx_bootstrap_demo.cb" "$bin" "${mod_asms[@]}" >/dev/null

set +e
"$bin" >/dev/null 2>&1
rc=$?
set -e

echo "[INFO] test_gfx_bootstrap actual_exit=$rc"
if [[ "$rc" -lt 0 || "$rc" -gt 126 ]]; then
  echo "[FAIL] invalid checksum exit code"
  exit 1
fi

echo "[PASS] gfx bootstrap"
