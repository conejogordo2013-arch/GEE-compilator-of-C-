#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "$0")/.." && pwd)"
OUT_DIR="$ROOT_DIR/.tmp_dual"
mkdir -p "$OUT_DIR"

mapfile -t files < <(find "$ROOT_DIR" -name '*.cb' -type f | sort)

for f in "${files[@]}"; do
  rel="${f#$ROOT_DIR/}"
  safe="${rel//\//_}"
  GEE_TARGET=x86-64 "$ROOT_DIR/gee" "$f" "$OUT_DIR/${safe}.x86-64.s" >/dev/null
  GEE_TARGET=arm-64 "$ROOT_DIR/gee" "$f" "$OUT_DIR/${safe}.arm-64.s" >/dev/null
done

echo "dual-target compile OK: ${#files[@]} .cb files"
