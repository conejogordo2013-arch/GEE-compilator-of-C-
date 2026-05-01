#!/usr/bin/env bash
set -euo pipefail

PREFIX_DEFAULT="/data/data/com.termux/files/usr"
if [[ -z "${PREFIX:-}" ]]; then
  SELF_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
  PREFIX="$(cd "$SELF_DIR/.." && pwd)"
else
  PREFIX="${PREFIX}"
fi
if [[ ! -d "$PREFIX/bin" && ! -x "$PREFIX/gee" ]]; then
  PREFIX="$PREFIX_DEFAULT"
fi
CFG_DIR="${GEE_CFG_DIR:-$PREFIX/etc/gee}"
CFG_FILE="$CFG_DIR/target"
CORE_BIN="${GEE_CORE_BIN:-$PREFIX/bin/gee-core}"
if [[ ! -x "$CORE_BIN" && -n "${SELF_DIR:-}" && -x "$PREFIX/gee" ]]; then
  CORE_BIN="$PREFIX/gee"
fi
RUN_HELPER="${GEE_RUN_BIN:-$PREFIX/bin/gee-run}"
if [[ ! -x "$RUN_HELPER" && -n "${SELF_DIR:-}" && -x "$SELF_DIR/gee-run.sh" ]]; then
  RUN_HELPER="$SELF_DIR/gee-run.sh"
fi

TARGET="${GEE_TARGET:-}"
if [[ -z "$TARGET" && -f "$CFG_FILE" ]]; then
  TARGET="$(tr -d ' \t\r\n' < "$CFG_FILE")"
fi
if [[ -z "$TARGET" ]]; then
  HOST_ARCH="$(uname -m 2>/dev/null || echo unknown)"
  if [[ "$HOST_ARCH" == "aarch64" || "$HOST_ARCH" == "arm64" ]]; then
    TARGET="arm-64"
  else
    TARGET="x86-64"
  fi
fi

case "$TARGET" in
  x86|x86-64|x86_64|amd64)
    TARGET="x86-64"
    ;;
  arm-64|arm64|aarch64)
    TARGET="arm-64"
    ;;
  arm-v7|armv7)
    echo "error: target '$TARGET' no está soportado todavía." >&2
    echo "valid: x86-64, arm-64" >&2
    exit 2
    ;;
  *)
    echo "error: unknown GEE_TARGET '$TARGET'" >&2
    echo "valid: x86-64, arm-64" >&2
    exit 2
    ;;
esac

if [[ ! -x "$CORE_BIN" ]]; then
  echo "error: missing gee-core at $CORE_BIN" >&2
  echo "run: make install PREFIX=$PREFIX" >&2
  exit 2
fi

if [[ $# -ge 1 ]]; then
  INPUT="$1"
  case "$INPUT" in
    *.cs)
      TMP_CB="$(mktemp -t jccsc_XXXXXX.cb)"
      cleanup() {
        rm -f "$TMP_CB"
      }
      trap cleanup EXIT

      JCCSC_BIN="${JCCSC_BIN:-$PREFIX/bin/jccsc-cbang}"
      if [[ ! -x "$JCCSC_BIN" ]]; then
        echo "error: missing JCCSC frontend binary at $JCCSC_BIN" >&2
        echo "hint: build/install a C!-based jccsc-cbang tool and set JCCSC_BIN" >&2
        exit 2
      fi
      "$JCCSC_BIN" "$INPUT" "$TMP_CB"

      shift
      if [[ $# -ge 1 ]]; then
        exec env GEE_TARGET="$TARGET" "$CORE_BIN" "$TMP_CB" "$@"
      fi
      exec env GEE_TARGET="$TARGET" "$CORE_BIN" "$TMP_CB"
      ;;
    *.cb)
      # Plug-and-play mode (gcc-like):
      #   gee program.cb -o program
      # Legacy asm mode still works with explicit output .s:
      #   gee program.cb program.s
      OUT_BIN=""
      ASM_OUT=""
      shift
      while [[ $# -gt 0 ]]; do
        case "$1" in
          -o)
            OUT_BIN="${2:-}"
            shift 2
            ;;
          *.s)
            ASM_OUT="$1"
            shift
            ;;
          *)
            echo "argumento no soportado: $1" >&2
            echo "uso: gee <input.cb> [-o output_bin]  |  gee <input.cb> <output.s>" >&2
            exit 2
            ;;
        esac
      done

      if [[ -n "$ASM_OUT" ]]; then
        exec env GEE_TARGET="$TARGET" "$CORE_BIN" "$INPUT" "$ASM_OUT"
      fi

      if [[ -z "$OUT_BIN" ]]; then
        OUT_BIN="$(basename "${INPUT%.cb}")"
      fi
      exec env GEE_TARGET="$TARGET" bash "$RUN_HELPER" "$INPUT" --mode host --out "$OUT_BIN"
      ;;
  esac
fi

exec env GEE_TARGET="$TARGET" "$CORE_BIN" "$@"
