#!/usr/bin/env bash
set -euo pipefail

bash scripts/gee-frontend.sh examples/hola_mundo.cb -o gee_driver_demo >/dev/null
./gee_driver_demo >/dev/null
bash scripts/gee-frontend.sh examples/hola_mundo.cb gee_driver_demo.s >/dev/null

rm -f gee_driver_demo gee_driver_demo.s
echo "gee frontend driver mode OK"
