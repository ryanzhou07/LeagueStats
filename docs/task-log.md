# Task Log

Append-only. One entry per completed or blocked task, written by the Orchestrator via the `task-summary` skill. Read this first in a new session instead of re-reading the repo.

## Template

```
### LOL-### — Title  [COMPLETED | BLOCKED]  YYYY-MM-DD
- Owner:
- What changed: (files/dirs, 1–3 bullets)
- Decisions: (anything future work must respect)
- Tests: (what ran, result)
- Open items / next:
```

## Entries

### LOL-000 — Repository scaffold  [COMPLETED]  2026-11-22
- Owner: Orchestrator (manual)
- What changed: Created directory layout, `AGENTS.md`, `PROJECT.md`, `DESIGN.md`, per-agent skills.
- Decisions: Replay capture is clip-based, timeline-first, one client session per game, gated by spike LOL-006A. Partial analysis without footage is valid.
- Tests: none (no code yet).
- Open items / next: LOL-001 Project Foundation. Review `DESIGN.md` open questions.

### LOL-001 / LOL-002 — Foundation scaffolds and CI  [REVIEW]  2026-11-22
- Owner: Desktop agent (001a), Engine agent (001b), Orchestrator-written scripts and CI (001c, 002; need second-agent review)
- What changed: `desktop/` Tauri+React+TS scaffold; `engine/` CMake `lol_engine` (`--ping`, `--version`, JSON) with vcpkg manifest (opencv, ffmpeg declared, not linked); `scripts/dev-setup.sh`, `build-all.sh`; root `.gitignore`, `.editorconfig`, `.clang-format`; `.github/workflows/ci.yml`. PR #1 (draft), branch `lol-001-foundation`.
- Decisions: vcpkg; latest stable versions (all pinned, see desktop/package.json, engine/vcpkg.json). **Node >= 22.12 required.** TypeScript 6.0.3 (typescript-eslint doesn't support 7 yet). Tauri bundle target `app` only (dmg step fails headless). Engine tests are CTest-only, no GoogleTest. clang-format style: Google, 2-space, 100 cols.
- Tests: locally verified typecheck, lint, vitest, ctest. CI on PR #1: all 6 jobs green (desktop, tauri build, engine on ubuntu and macOS, format, ASan/UBSan).
- Open items / next: window launch not visually confirmed; vcpkg manifest not yet exercised; independent review of scripts and ci.yml; user merge. Then LOL-003.
