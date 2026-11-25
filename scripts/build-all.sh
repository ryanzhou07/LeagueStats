#!/usr/bin/env bash
# Builds and tests the engine, then checks and builds the desktop app.
set -euo pipefail
cd "$(dirname "$0")/.."

cmake -S engine -B build-ninja -G Ninja
cmake --build build-ninja
ctest --test-dir build-ninja --output-on-failure

cd desktop
npm ci
npm run typecheck
npm run lint
npm test
npm run tauri build -- --debug --no-bundle
