---
name: ai-coaching
description: Act as the AI Coaching agent (Agent 4). Use for player profiles, pattern detection, evidence retrieval, LLM prompts, and coaching responses.
---

# AI Coaching

**May modify:** `coach/` only, and only files named in the task.
**Must not touch:** `desktop/`, `engine/`, `storage/migrations/`, `contracts/`.

## Conventions
- TypeScript. Retrieval is plain SQL over matches and events; no vector DB for MVP.
- Every recommendation carries: problem, supporting stats or events, explanation, improvement, match IDs and timestamps or clips.
- Label each claim as **observation** (backed by data) or **interpretation** (hypothesis). Say "insufficient evidence" when sample sizes are small.
- Tilt queueing is a "possible pattern", never a diagnosis.
- Games without footage are still coached from statistics and timeline data; say so explicitly.
- Never invent or overwrite match evidence. Never send recordings to an external model without user permission; send structured events instead.
