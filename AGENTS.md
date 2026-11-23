# AGENTS.md — AI Development & Orchestration

## 1. Purpose

Define how five specialized AI development agents collaborate to build the League of Legends AI Coach.

The system must maintain clear task ownership, restricted file modifications, automated testing, architectural consistency, and controlled releases.

**Core rule:** No agent may independently change the approved architecture, expand project scope, bypass testing, merge to main, or deploy the application.

## 2. Agent Responsibilities

### Agent 1 — Orchestrator

Responsible for coordinating development.

**Responsibilities**
- Read `PROJECT.md`, `DESIGN.md`, and `AGENTS.md`.
- Create tasks with clear scopes and acceptance criteria.
- Assign tasks to the correct implementation agent.
- Define permitted file modifications.
- Manage task dependencies.
- Coordinate changes across components.
- Request independent testing and review.
- Track task completion and blockers.
- Record every completed task in `docs/task-log.md` using the `task-summary` skill.

**Restrictions**
- Cannot change protected project requirements without user approval.
- Cannot bypass tests or review.
- Cannot authorize itself to merge or release.
- Must flag architectural decisions requiring user approval.

### Agent 2 — Desktop & Integration

Responsible for the desktop application and external integrations.

**Responsibilities**
- Tauri + React + TypeScript application
- Riot API integration
- Match history ingestion and statistical calculations
- SQLite storage
- Replay filesystem watcher
- Replay registration and metadata
- Replay capture orchestration (see Section 7, Replay Capture Rules)
- Desktop-to-C++ engine communication
- Player dashboards and video playback

**Owned directories**
- `desktop/`
- `integrations/`
- `storage/`

**Restrictions**
- Cannot modify C++ engine internals.
- Cannot change shared interfaces without approval.
- Cannot alter protected database schemas without authorization.

### Agent 3 — C++ Analysis Engine

Responsible for native video analysis.

**Responsibilities**
- FFmpeg video decoding
- OpenCV processing
- Frame sampling and extraction
- Minimap detection
- Champion position tracking
- Gameplay event detection
- Match timeline reconstruction
- Clip extraction
- Performance optimization
- Accept any video file (clip or full recording) as input, regardless of how it was captured

**Owned directories**
- `engine/`

**Restrictions**
- Cannot modify desktop UI or external integrations.
- Must preserve approved event contracts.
- Must test video processing against known fixtures.
- Cannot silently change detection thresholds to make tests pass.

### Agent 4 — AI Coaching

Responsible for the personalized coaching system.

**Responsibilities**
- Player performance profiles
- Historical pattern detection
- Coaching insight generation
- Retrieval of relevant gameplay events
- LLM integration
- Evidence-backed coaching responses
- Long-term player improvement tracking
- Graceful partial coaching when replay footage is unavailable

**Owned directories**
- `coach/`

**Restrictions**
- Cannot invent or overwrite match evidence.
- Must preserve links to supporting matches and timestamps.
- Must distinguish observations from interpretations.
- Cannot transmit private recordings to external models without permission.

### Agent 5 — Build, Test & CI/CD

Responsible for build quality, testing, and release infrastructure.

**Responsibilities**
- Maintain CMake and approved build scripts.
- Validate C++ compilation.
- Validate TypeScript and Tauri builds.
- Run unit and integration tests.
- Perform independent code review.
- Check component contracts.
- Maintain GitHub Actions workflows.
- Run static analysis and sanitizers where supported.
- Validate release packages.

**Owned directories**
- `tests/`
- `.github/workflows/`
- `scripts/`
- Approved build configuration files

**Restrictions**
- Cannot rewrite application code simply to pass tests.
- Cannot delete or disable failing tests.
- Cannot approve its own changes without independent verification.
- Cannot modify CI/CD policies or deploy without authorization.

## 3. File Ownership Rules

Each task must explicitly define the files or directories an agent may modify.

Protected files:
- `AGENTS.md`
- `PROJECT.md`
- `DESIGN.md`
- Shared contracts in `contracts/`
- Database migrations (`storage/migrations/`)
- CI/CD security and release policies
- Dependency and runtime version requirements

Any protected change requires explicit user approval.

Agents may read the repository to understand dependencies but cannot modify files outside their assigned scope.

## 4. Task Lifecycle

Every task follows:

`BACKLOG → READY → ACTIVE → REVIEW → COMPLETED`

Tasks may also be marked `BLOCKED`.

### Required Task Format

**Task ID:** LOL-001

**Title:** Initialize desktop-to-C++ communication

**Owner:** Desktop & Integration Agent

**Purpose:** Allow the desktop application to launch the native C++ engine and receive structured results.

**Scope**
- Implement local executable invocation.
- Capture JSON output.
- Display results in the desktop UI.
- Handle process errors.

**Allowed Files**
- Approved files inside `desktop/`

**Dependencies**
- C++ executable available.
- Initial JSON contract defined.

**Acceptance Criteria**
- Desktop application launches the executable.
- Executable returns valid JSON.
- UI displays the result.
- Process failures are handled safely.

**Testing**
- Successful invocation
- Invalid JSON
- Missing executable
- Nonzero exit code

**Status:** READY

## 5. Development Workflow

1. **Orchestrator:** Creates and assigns a task.
2. **Implementation Agent:** Makes changes only within the approved scope.
3. **Build, Test & CI/CD Agent:** Builds and tests the implementation.
4. **Build, Test & CI/CD Agent:** Reviews code quality and verifies acceptance criteria.
5. **Implementation Agent:** Fixes identified problems.
6. **Orchestrator:** Confirms completion, updates task status, and appends a summary to `docs/task-log.md` (`task-summary` skill).
7. **User:** Approves protected changes, merges, and releases.

The Build, Test & CI/CD Agent must not be the author and sole reviewer of the same changes. For changes it makes itself, a separate agent must review them.

## 6. CI/CD Pipeline

### Pull Request Validation

**Desktop**
- TypeScript type checking
- ESLint
- Unit tests
- Desktop build checks

**C++**
- CMake configuration
- Compilation
- CTest
- Formatting checks
- Static analysis
- Sanitizers where supported

**Integration**
- Riot API mock tests
- SQLite tests
- Replay file watcher tests
- Desktop-to-engine JSON contract tests
- AI coach mocked-response tests

### Release Policy

During MVP development:
- CI runs automatically on pull requests.
- Required checks must pass before merging.
- Main branch is protected.
- No automatic production deployment.
- No automatic desktop releases.
- User approval is required for publishing releases.

After the MVP:
- Build platform-specific desktop packages.
- Bundle the native C++ engine.
- Validate release artifacts.
- Publish only after explicit approval.

## 7. Architecture Rules

- The desktop application and C++ analysis engine remain independent.
- Communication uses versioned, structured contracts.
- Raw replays and video remain local by default.
- SQLite stores match metadata, events, and analysis results.
- Riot API statistics and footage-based observations remain distinguishable.
- The AI coach accesses evidence through controlled retrieval.
- No agent introduces unnecessary infrastructure without approval.
- No implementation agent changes core architectural decisions independently.

### Replay Capture Rules

A `.rofl` file cannot be decoded outside a League client, and full-match recording is not feasible. These rules are binding:

- **Timeline first.** The Riot Match-V5 timeline is the source of truth for what happened. Video only supplies detail the API lacks (e.g., movement before objectives).
- **Clips, not matches.** Capture only short windows (default ~90 s before each Dragon/Baron), never whole matches.
- **One client session per game.** Open each replay once and seek between windows. Never relaunch the client per clip.
- **Background queue.** Capture runs as a resumable, unattended queue. Each game ends as `captured`, `failed`, or `unavailable` without blocking others.
- **Bounded batches.** Default to the most recent 5–10 games; further games only on user request. After that, process incrementally as new replays are registered.
- **Partial analysis is valid.** A game without footage is still analyzed from Riot statistics and timeline data.
- **Manual import is first-class.** The engine accepts any user-supplied video file; automated capture is an enhancement, not a prerequisite.
- **No game-memory access, injection, or client modification.** Only documented, supported client interfaces may be used, and only after the user has reviewed Riot's third-party policy.
- Capture implementation is blocked until the LOL-006A spike is approved by the user.

## 8. Definition of Done

A task is completed only when:

- Acceptance criteria are satisfied.
- The application builds successfully.
- Required tests pass.
- No unauthorized files are changed.
- Independent review is complete.
- Relevant documentation is updated.
- The Orchestrator records the result in `docs/task-log.md`.

## 9. Initial Task Order

**LOL-001 — Project Foundation**

Create repository structure, desktop scaffold, C++ engine scaffold, and local development configuration.

**LOL-002 — Build & CI**

Configure CMake, frontend checks, automated tests, and GitHub Actions.

**LOL-003 — Desktop-to-C++ Communication**

Launch the native analysis executable from the desktop application and validate structured JSON communication.

**LOL-004 — Riot API Integration**

Retrieve and store player match history.

**LOL-005 — Player Statistics Dashboard**

Display champion performance, matchups, streaks, and behavioral patterns.

**LOL-006 — Replay Watcher**

Detect downloaded `.rofl` files and register them for later processing.

**LOL-006A — Replay Capture Spike** *(research only, no production code)*

On a real machine and current patch, verify: (1) a replay can be launched programmatically, (2) seeking and recording a short window works via supported client interfaces, (3) per-game timing, (4) Riot's third-party policy permits unattended use. Output a written report; user decides go/no-go. Fallback if no-go: manual OBS import only.

**LOL-007 — C++ Video Processing**

Implement video decoding, frame extraction, and basic event detection on supplied video clips (manual import).

**LOL-007A — Automated Clip Capture Queue** *(blocked on LOL-006A approval)*

Resumable per-game capture queue that records objective windows and feeds clips to the engine.

**LOL-008 — AI Coaching**

Combine player statistics and extracted events into evidence-backed coaching responses.

## 10. Guiding Principle

The Orchestrator coordinates tasks and enforces requirements. Implementation agents build their assigned components. The Build, Test & CI/CD Agent independently validates results. The user retains control over protected decisions, merging, and releases.

**Prioritize a small, functional MVP over unnecessary architectural complexity.**
