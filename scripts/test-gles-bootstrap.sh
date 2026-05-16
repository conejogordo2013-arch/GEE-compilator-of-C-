#!/usr/bin/env bash
set -euo pipefail

GEE_BIN=${GEE_BIN:-./gee}
ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
WORK_DIR="$(mktemp -d)"
trap 'rm -rf "$WORK_DIR"' EXIT

mods=(
  "$ROOT_DIR/libgfx/backend_gles.cb"
  "$ROOT_DIR/libgfx/backend_gles_stub.cb"
  "$ROOT_DIR/libdrawg/drawg.cb"
  "$ROOT_DIR/libdrawg/backend_stub.cb"
)

mod_asms=()
for m in "${mods[@]}"; do
  out="$WORK_DIR/$(basename "${m%.cb}").s"
  "$GEE_BIN" "$m" "$out" >/dev/null
  mod_asms+=("$out")
done

bin="$WORK_DIR/test_gles_bootstrap"
GEE_BIN="$GEE_BIN" bash "$ROOT_DIR/scripts/gee-asm-link.sh" host "$ROOT_DIR/examples/gfx_gles_clear_demo.cb" "$bin" "${mod_asms[@]}" >/dev/null

echo "[INFO] Compilación/link GLES bootstrap OK."
echo "[WARN] Ejecución visual no se valida aquí; este test usa backend_gles_stub.cb sin EGL real."
