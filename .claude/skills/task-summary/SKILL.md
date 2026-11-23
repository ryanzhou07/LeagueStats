---
name: task-summary
description: Summarize a finished or blocked LOL-### task into docs/task-log.md so future sessions can resume without re-reading the repo. Use when a task reaches COMPLETED or BLOCKED, or at the start of a session to load context.
---

# task-summary

## Record (end of task)
1. Read the task's acceptance criteria and the actual diff or changed files.
2. Append one entry to `docs/task-log.md` using its template. Keep it under ~10 lines.
3. Include only what future work needs: files touched, decisions that constrain later tasks, test results (real output, including failures), open items.
4. Never mark COMPLETED unless AGENTS.md Definition of Done is met. Otherwise use BLOCKED and say why.

## Resume (start of session)
1. Read `docs/task-log.md`, newest entries first, plus `AGENTS.md` task order.
2. Report: last completed task, current ACTIVE/BLOCKED tasks, next READY task.
3. Do not re-read the whole repo unless an entry points to a specific file.

Owner: Orchestrator only. Do not edit protected files.
