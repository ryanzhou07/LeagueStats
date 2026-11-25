# LOL Engine

C++20 analysis engine. Currently a scaffold: `--ping` and `--version` only.

## Build and test

    cmake -S engine -B build && cmake --build build && ctest --test-dir build --output-on-failure

Run from the repository root. Examples:

    build/lol_engine --ping      # {"schema_version":"0.0.1","status":"ok"}
    build/lol_engine --version   # {"schema_version":"0.0.1","engine_version":"0.0.1"}
    build/lol_engine --bogus     # JSON error on stdout, exit code 2

## Dependencies

`vcpkg.json` (vcpkg manifest mode, baseline pinned) declares `opencv` and `ffmpeg`.
They are not linked yet, so the plain build above needs no vcpkg. To use vcpkg later:

    export VCPKG_ROOT=$HOME/vcpkg
    cmake -S engine -B build -DCMAKE_TOOLCHAIN_FILE=$VCPKG_ROOT/scripts/buildsystems/vcpkg.cmake

Tests are CTest-only (no framework): they match the JSON output and exit codes.
