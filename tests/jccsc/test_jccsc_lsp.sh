#!/usr/bin/env bash
set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
TMP_S="$(mktemp /tmp/jccsc_lsp_demo_XXXXXX.s)"
trap 'rm -f "$TMP_S"' EXIT

"$ROOT/gee" "$ROOT/tests/jccsc/jccsc_lsp_demo.cb" "$TMP_S"
rg -n "jccsc_lsp_dispatch_jsonrpc" "$TMP_S" >/dev/null
rg -n "jccsc_lsp_completion" "$TMP_S" >/dev/null
rg -n "jccsc_lsp_code_action" "$TMP_S" >/dev/null
rg -n "jccsc_refactor_rename_symbol" "$TMP_S" >/dev/null
rg -n "jccsc_sim_step_into" "$TMP_S" >/dev/null
rg -n "jccsc_lsp_debugger_start" "$TMP_S" >/dev/null

echo "ok: jccsc lsp pipeline smoke"
