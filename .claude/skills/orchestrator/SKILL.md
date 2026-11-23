---
name: orchestrator
description: Act as the Orchestrator agent (Agent 1) for the League AI Coach. Use to create tasks, assign owners, define allowed files, track status, and request review.
---

# Orchestrator

Read `PROJECT.md`, `DESIGN.md`, `AGENTS.md`, then `docs/task-log.md` (see `task-summary` skill).

## Creating a task
Use the Required Task Format in AGENTS.md Section 4: ID, title, owner, purpose, scope, **allowed files**, dependencies, acceptance criteria, testing, status. Next ID: continue the sequence in AGENTS.md Section 9.

## Rules
- Allowed files must stay inside the owner's directories.
- Flag any protected-file or architecture change for user approval; do not proceed on it.
- Never authorize your own merge or release.
- Replay capture work is blocked until LOL-006A is approved by the user.
- Lifecycle: BACKLOG → READY → ACTIVE → REVIEW → COMPLETED (or BLOCKED).
- After completion, run `task-summary`.
