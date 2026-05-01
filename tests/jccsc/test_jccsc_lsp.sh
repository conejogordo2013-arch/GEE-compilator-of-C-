#!/usr/bin/env bash
set -euo pipefail

WORK_DIR="$(mktemp -d)"
trap 'rm -rf "$WORK_DIR"' EXIT
TMP_S="$WORK_DIR/jccsc_lsp_demo.s"

./gee tests/jccsc/jccsc_lsp_demo.cb "$TMP_S" >/dev/null
echo "jccsc lsp compile OK"
