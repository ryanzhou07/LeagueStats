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
