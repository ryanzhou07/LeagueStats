cmake_minimum_required(VERSION 3.25)
project(lol_engine VERSION 0.0.1 LANGUAGES CXX)

set(CMAKE_CXX_STANDARD 20)
set(CMAKE_CXX_STANDARD_REQUIRED ON)
set(CMAKE_CXX_EXTENSIONS OFF)

# OpenCV and FFmpeg are declared in vcpkg.json but intentionally not linked yet (LOL-007).
add_executable(lol_engine src/main.cpp)
target_include_directories(lol_engine PRIVATE include)
target_compile_definitions(lol_engine PRIVATE
  LOL_ENGINE_VERSION="${PROJECT_VERSION}")
target_compile_options(lol_engine PRIVATE -Wall -Wextra -Wpedantic)

enable_testing()
# Dependency-free tests: CTest matches the JSON stdout/exit code directly.
add_test(NAME ping COMMAND lol_engine --ping)
set_tests_properties(ping PROPERTIES PASS_REGULAR_EXPRESSION
  "^\\{\"schema_version\":\"0\\.0\\.1\",\"status\":\"ok\"\\}\n$")
add_test(NAME version COMMAND lol_engine --version)
set_tests_properties(version PROPERTIES PASS_REGULAR_EXPRESSION
  "^\\{\"schema_version\":\"0\\.0\\.1\",\"engine_version\":\"0\\.0\\.1\"\\}\n$")
# Bad args: one test checks nonzero exit, one the JSON error (a regex ignores the exit code).
add_test(NAME bad_args COMMAND lol_engine --bogus)
set_tests_properties(bad_args PROPERTIES WILL_FAIL TRUE)
add_test(NAME bad_args_json COMMAND lol_engine --bogus)
set_tests_properties(bad_args_json PROPERTIES PASS_REGULAR_EXPRESSION
  "\"status\":\"error\"")
