#!/usr/bin/env bash
set -euo pipefail

GEE_BIN=${GEE_BIN:-./gee}
ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
WORK_DIR="${WORK_DIR:-$(mktemp -d)}"
KEEP_WORK_DIR=${KEEP_WORK_DIR:-0}
if [[ "$KEEP_WORK_DIR" != "1" ]]; then
  trap 'rm -rf "$WORK_DIR"' EXIT
fi

OS=$(uname -s | tr '[:upper:]' '[:lower:]')
ARCH=$(uname -m)
IS_ANDROID=0
if [[ -n "${PREFIX:-}" && "$PREFIX" == *"com.termux"* ]]; then
  IS_ANDROID=1
fi

backend_src=""
link_libs=()
bridge_srcs=()

if [[ "$OS" == mingw* || "$OS" == msys* || "$OS" == cygwin* ]]; then
  backend_src="$ROOT_DIR/libdrawg/backend_windows_gdi.cb"
  link_libs=(-lgdi32 -luser32)
  bridge_srcs=("$ROOT_DIR/libdrawg/backend_windows_gdi_bridge.c")
  platform_name="windows-gdi"
elif [[ "$OS" == "linux" ]]; then
  backend_src="$ROOT_DIR/libdrawg/backend_linux_x11.cb"
  link_libs=(-lX11)
  if [[ "$IS_ANDROID" == "1" ]]; then
    platform_name="termux-x11"
  else
    platform_name="linux-x11"
  fi
else
  backend_src="$ROOT_DIR/libdrawg/backend_stub.cb"
  platform_name="stub"
fi

echo "[INFO] platform=$platform_name arch=$ARCH"

mods=(
  "$ROOT_DIR/libdrawg/drawg.cb"
  "$ROOT_DIR/libgfx/gfx2d.cb"
  "$backend_src"
)

asms=()
for src in "${mods[@]}" "$ROOT_DIR/examples/gfx2d_window_demo.cb"; do
  out="$WORK_DIR/$(basename "${src%.cb}").s"
  "$GEE_BIN" "$src" "$out" >/dev/null
  asms+=("$out")
done

if [[ "$platform_name" == "windows-gdi" ]]; then
  std_system="$ROOT_DIR/stdlib/system_windows_x86_64.s"
  std_memory="$ROOT_DIR/stdlib/memory.s"
  std_net="$ROOT_DIR/stdlib/net.s"
elif [[ "$ARCH" == "aarch64" || "$ARCH" == "arm64" ]]; then
  std_system="$ROOT_DIR/stdlib/system_arm64.s"
  std_memory="$ROOT_DIR/stdlib/memory_arm64.s"
  std_net="$ROOT_DIR/stdlib/net_arm64.s"
else
  std_system="$ROOT_DIR/stdlib/system.s"
  std_memory="$ROOT_DIR/stdlib/memory.s"
  std_net="$ROOT_DIR/stdlib/net.s"
fi

bin="$WORK_DIR/gfx2d_demo"

gcc "${asms[@]}" "${bridge_srcs[@]}" "$std_system" "$std_memory" "$std_net" "${link_libs[@]}" -o "$bin"

echo "[INFO] Ejecutando demo 2D..."
"$bin"
