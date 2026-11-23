#!/usr/bin/env bash
# Builds and tests the engine, then checks and builds the desktop app.
set -euo pipefail
cd "$(dirname "$0")/.."

cmake -S engine -B build -G Ninja
cmake --build build
ctest --test-dir build --output-on-failure

cd desktop
npm ci
npm run typecheck
npm run lint
npm test
npm run tauri build -- --debug --no-bundle
