#!/usr/bin/env bash
set -euo pipefail

if [[ $# -lt 1 ]]; then
  echo "uso: geecc <input.cb> [-o output_bin] [--target host|x86-64|arm-64|all]" >&2
  exit 2
fi

INPUT=""
OUT=""
TARGET="host"

while [[ $# -gt 0 ]]; do
  case "$1" in
    -o)
      OUT="${2:-}"
      shift 2
      ;;
    --target)
      TARGET="${2:-host}"
      shift 2
      ;;
    --)
      shift
      break
      ;;
    -*)
      echo "argumento no soportado: $1" >&2
      exit 2
      ;;
    *)
      if [[ -z "$INPUT" ]]; then
        INPUT="$1"
      else
        echo "solo se soporta un archivo de entrada .cb" >&2
        exit 2
      fi
      shift
      ;;
  esac
done

if [[ -z "$INPUT" ]]; then
  echo "falta input .cb" >&2
  exit 2
fi
if [[ -z "$OUT" ]]; then
  base="$(basename "${INPUT%.cb}")"
  OUT="$base"
fi

if [[ "$TARGET" == "all" ]]; then
  base="$OUT"
  GEE_TARGET="x86-64" "${GEE_BIN:-./gee}" "$INPUT" "${base}_x86_64.s"
  GEE_TARGET="arm-64" "${GEE_BIN:-./gee}" "$INPUT" "${base}_arm_64.s"
  HOST_ARCH="$(uname -m 2>/dev/null || echo unknown)"
  if [[ "$HOST_ARCH" == "aarch64" || "$HOST_ARCH" == "arm64" ]]; then
    GEE_TARGET="arm-64" bash scripts/gee-run.sh "$INPUT" --mode host --out "${base}_arm_64"
  else
    GEE_TARGET="x86-64" bash scripts/gee-run.sh "$INPUT" --mode host --out "${base}_x86_64"
  fi
  echo "multi-target: generado ${base}_x86_64.s y ${base}_arm_64.s"
elif [[ "$TARGET" == "host" ]]; then
  GEE_TARGET="" bash scripts/gee-run.sh "$INPUT" --mode host --out "$OUT"
else
  GEE_TARGET="$TARGET" bash scripts/gee-run.sh "$INPUT" --mode host --out "$OUT"
fi
