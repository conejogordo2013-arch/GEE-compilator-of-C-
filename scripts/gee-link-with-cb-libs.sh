#!/usr/bin/env bash
set -euo pipefail

if [[ $# -lt 3 ]]; then
  echo "uso: gee-link-with-cb-libs.sh <target> <app.cb> <out_bin> [lib.cb ...]" >&2
  exit 2
fi

TARGET="$1"
APP="$2"
OUT_BIN="$3"
shift 3 || true
LIBS=("$@")

GEE_BIN=${GEE_BIN:-./gee}
TMP_DIR="$(mktemp -d)"
trap 'rm -rf "$TMP_DIR"' EXIT

EXTRA_ASM=()
for lib in "${LIBS[@]}"; do
  asm="$TMP_DIR/$(basename "${lib%.*}").s"
  GEE_TARGET="$TARGET" "$GEE_BIN" "$lib" "$asm" >/dev/null
  EXTRA_ASM+=("$asm")
done

GEE_BIN="$GEE_BIN" bash "$(dirname "$0")/gee-asm-link.sh" "$TARGET" "$APP" "$OUT_BIN" "${EXTRA_ASM[@]}"
