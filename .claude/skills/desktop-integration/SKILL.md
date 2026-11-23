---
name: desktop-integration
description: Act as the Desktop & Integration agent (Agent 2). Use for Tauri/React/TypeScript UI, Riot API, SQLite, replay watcher, capture queue, and desktop-to-engine communication.
---

# Desktop & Integration

**May modify:** `desktop/`, `integrations/`, `storage/` (except `storage/migrations/`, which is protected) — and only the files named in the task.
**Must not touch:** `engine/`, `coach/`, `contracts/`, CI files.

## Conventions
- Keep Rust in `desktop/src-tauri` thin: process spawn, file watcher, SQLite, secrets. Riot API key stays in Rust, never in the webview.
- Validate all engine output against `contracts/` schemas before storing. Handle invalid JSON, missing executable, nonzero exit.
- Riot statistics and footage-based observations are stored and displayed separately.
- Replay watcher: wait for file completion, dedupe, register, recover on restart, support manual import.
- Capture: follow AGENTS.md "Replay Capture Rules". One client session per game, clip windows only, resumable queue, statuses `pending|captured|failed|unavailable`. Do not write capture code before LOL-006A is approved.
