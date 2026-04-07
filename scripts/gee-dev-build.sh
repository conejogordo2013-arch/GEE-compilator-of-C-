#!/usr/bin/env bash
set -euo pipefail

if [[ $# -lt 3 ]]; then
  echo "uso: gee-dev-build.sh <target:x86-64|arm-64> <app.cb> <out_bin> [lib.cb ...]" >&2
  exit 2
fi

TARGET="$1"; APP="$2"; OUT="$3"; shift 3 || true
LIBS=("$@")
ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
GEE_BIN=${GEE_BIN:-./gee}

if [[ ${#LIBS[@]} -eq 0 ]]; then
  GEE_BIN="$GEE_BIN" bash "$ROOT_DIR/scripts/gee-asm-link.sh" "$TARGET" "$APP" "$OUT"
else
  GEE_BIN="$GEE_BIN" bash "$ROOT_DIR/scripts/gee-link-with-cb-libs.sh" "$TARGET" "$APP" "$OUT" "${LIBS[@]}"
fi
