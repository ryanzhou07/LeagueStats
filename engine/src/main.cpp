#include <cstdio>
#include <string_view>

#include "json_out.hpp"

int main(int argc, char** argv) {
  if (argc == 2) {
    const std::string_view arg = argv[1];
    if (arg == "--ping") {
      std::puts("{\"schema_version\":\"" LOL_SCHEMA_VERSION "\",\"status\":\"ok\"}");
      return 0;
    }
    if (arg == "--version") {
      std::puts("{\"schema_version\":\"" LOL_SCHEMA_VERSION
                "\",\"engine_version\":\"" LOL_ENGINE_VERSION "\"}");
      return 0;
    }
  }
  // Fixed message: never echo user input, so no JSON escaping is needed.
  std::puts("{\"schema_version\":\"" LOL_SCHEMA_VERSION
            "\",\"status\":\"error\",\"message\":\"usage: lol_engine --ping | --version\"}");
  return 2;
}
