# DESIGN.md — Architecture Decisions (DRAFT, user approval required)

Protected file. Changes require user approval. Derived from the tradeoff discussion; update as decisions are confirmed.

## Decisions

| Area | Decision | Notes |
|---|---|---|
| Desktop shell | Tauri + React + TypeScript | Rust kept thin: process spawn, file watcher, SQLite, secrets |
| Engine | C++20, OpenCV, FFmpeg, CMake | Dependencies via vcpkg or Conan. Open: prototype detectors in Python first? |
| Contracts | JSON Schema in `contracts/` | Generate TS types and C++ structs; versioned |
| Storage | SQLite, owned by the desktop side | Engine emits JSON; desktop ingests. Engine never touches the DB |
| Riot API | Called from Rust backend | API key never reaches the webview |
| Coach | TypeScript, Anthropic SDK | Retrieval via plain SQL; no vector DB for MVP |

## Directory layout

```
desktop/        Tauri app (src/ React, src-tauri/ Rust)    [Agent 2]
integrations/   Riot API client, replay watcher, capture   [Agent 2]
storage/        SQLite access, migrations/ (protected)     [Agent 2]
engine/         C++ analysis engine (src, include, fixtures) [Agent 3]
coach/          LLM coaching, retrieval, profiles          [Agent 4]
contracts/      Shared JSON schemas (protected)
tests/          Cross-component and contract tests         [Agent 5]
scripts/        Build and dev scripts                      [Agent 5]
.github/workflows/  CI                                     [Agent 5]
docs/           task-log.md and notes
.claude/skills/ Per-agent skills + task-summary
```

## Data flow

Engine contract: `engine <video> --out json` returns events with `schema_version`, timestamps, optional position, confidence, evidence source. The desktop validates against `contracts/` before storing.

## Replay capture design

- Source of truth for events: Match-V5 timeline. Video supplements it.
- Capture queue per game: launch replay once, seek to each Dragon/Baron window (~90 s before), record, close. State: `pending → captured | failed | unavailable`.
- Capture adapter sits behind an interface so it can be swapped for manual import without touching the engine.
- Unverified: replay launch/seek/record interfaces, timing (~3–5 min/game), Riot policy. Resolved by spike LOL-006A before any capture code is written.

## Confirmed by user (2026-11-22)

1. Engine is C++ from the start (no Python prototype).
2. Desktop shell is Tauri.

## Open

- Go/no-go on automated capture, decided after LOL-006A (pending; fallback is manual video import).
