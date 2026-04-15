#!/usr/bin/env bash
set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
TMP_S="$(mktemp /tmp/jccsc_demo_XXXXXX.s)"
trap 'rm -f "$TMP_S"' EXIT

"$ROOT/gee" "$ROOT/tests/jccsc/jccsc_demo.cb" "$TMP_S"
rg -n "jccsc_compile_to_cbang" "$TMP_S" >/dev/null
rg -n "main" "$TMP_S" >/dev/null

echo "ok: jccsc extended (C!) pipeline smoke"
