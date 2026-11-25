#!/usr/bin/env bash
# Checks that required tools are installed. Installs nothing.
set -u
fail=0
need() { command -v "$1" >/dev/null 2>&1 || { echo "MISSING: $1 — $2"; fail=1; }; }

need node "install Node >= 22.12"
need npm "comes with Node"
need cargo "install Rust via https://rustup.rs"
need cmake "brew install cmake"
need ninja "brew install ninja"
need clang++ "install Xcode command line tools or a C++20 compiler"

if command -v node >/dev/null 2>&1; then
  node -e 'const [a,b]=process.versions.node.split(".").map(Number); process.exit(a>22||(a===22&&b>=12)?0:1)' \
    || { echo "Node $(node -v) is too old; need >= 22.12"; fail=1; }
fi
[ -n "${VCPKG_ROOT:-}" ] && [ -x "$VCPKG_ROOT/vcpkg" ] \
  || echo "WARNING: vcpkg not found (not needed until the engine links OpenCV/FFmpeg) — clone https://github.com/microsoft/vcpkg and set VCPKG_ROOT"

[ "$fail" -eq 0 ] && echo "All prerequisites found." || exit 1
