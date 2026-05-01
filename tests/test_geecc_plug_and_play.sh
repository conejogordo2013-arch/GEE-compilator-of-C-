#!/usr/bin/env bash
set -euo pipefail

./scripts/geecc.sh examples/hola_mundo.cb -o geecc_hola >/dev/null
./geecc_hola >/dev/null

# compile same code to arm asm for compatibility smoke
GEE_TARGET=arm-64 ./gee examples/hola_mundo.cb geecc_hola_arm64.s
./scripts/geecc.sh examples/hola_mundo.cb -o geecc_multi --target all >/dev/null

test -f geecc_multi_x86_64.s
test -f geecc_multi_arm_64.s

rm -f geecc_hola geecc_hola.s geecc_hola_arm64.s geecc_multi_x86_64.s geecc_multi_arm_64.s geecc_multi_x86_64 geecc_multi_arm_64
echo "geecc plug-and-play OK"
