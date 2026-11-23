# PROJECT.md — League of Legends AI Coach

## 1. Project Overview

Build a local-first League of Legends desktop application that collects player statistics, processes gameplay replays, identifies recurring weaknesses, and provides personalized feedback through an AI coaching agent.

The system should combine three sources of information:

1. **Riot API:** Historical match statistics and game timelines.
2. **Replay analysis:** Gameplay footage processed through a native C++ computer vision engine.
3. **AI coaching:** Reasoning over the player's historical statistics and extracted gameplay events.

### Core Objective

Help players understand **what they are doing wrong, why they are doing it wrong, and how they can improve** without manually reviewing hours of gameplay footage.

The initial application targets individual players, with future support for amateur teams, coaches, and competitive scouting.

---

## 2. Core Application Features

### A. Player Statistics

Users enter their Riot ID and retrieve up to their 50 most recent available matches through Riot's API.

**Player Dashboard**
- Rank and win rate
- Most-played champions
- Champion win rates and KDA
- Average CS, damage, and vision score
- Performance by role
- Match history and trends

**Matchup Analysis**
- Best and worst champion matchups
- Win rates against specific champions
- Lane performance when sufficient data exists
- Matchup sample sizes

**Behavioral Analysis**
- Win streaks and loss streaks
- Performance following consecutive losses
- Number of games per session
- Time between games
- Performance changes during long sessions
- Possible tilt-queueing patterns

Tilt queueing must be described as a possible pattern, not a confirmed psychological state.

### B. Automatic Replay Detection

The desktop application monitors the user's configured League replay directory.

**Workflow**

1. User downloads a `.rofl` replay through the League client.
2. The desktop application detects the new file using a filesystem watcher.
3. The system waits until the download has completed.
4. The replay is identified and matched to the corresponding game.
5. Duplicate replays are ignored.
6. The replay is registered in the local database.
7. The application queues it for processing.

**Important:** A `.rofl` file is not a standard video. It requires a compatible League client for playback. Replay detection and video rendering are separate operations.

The system must support manual imports and recover previously downloaded files when the desktop application restarts.

### B.1 Replay Capture Constraint

Full-match recording is not feasible, and `.rofl` files cannot be parsed directly. Capture is therefore designed around these constraints:

- **Timeline first.** The Match-V5 timeline already provides kills, objectives, wards, and per-minute positions. Video only adds finer detail, such as movement in the ~90 s before Dragon/Baron.
- **Clips, not matches.** Record only short objective windows, never entire games.
- **One client session per game.** Launch each replay once, seek to each objective window, record, then close. Estimated 3–5 minutes per game (unverified).
- **Unattended background queue.** Resumable; each game ends `captured`, `failed`, or `unavailable`. The client occupies the GPU, so the user cannot play while it runs.
- **Bounded batches.** Start with the most recent 5–10 games; process others on request; afterwards process incrementally as new replays appear. Prioritize losses and the user's most-played champions.
- **Partial analysis.** If footage is unavailable (old patch, load failure), the game is still analyzed from statistics and timeline data.
- **Manual import is first-class.** The engine accepts any video file, e.g., a user's own OBS recording. Automated capture is an enhancement.
- **No unsupported methods.** No memory reading, injection, or client modification. Only supported client interfaces, and only after reviewing Riot's third-party policy.
- **Spike required.** Automated capture must be validated by spike task LOL-006A (real machine, current patch) and approved by the user before implementation.

### C. Gameplay Analysis Engine

Develop a native C++ engine that processes recorded footage or rendered replay frames.

**Core responsibilities**
- Video decoding
- Frame sampling
- Minimap extraction
- HUD and event detection
- Champion position tracking
- Timestamp reconstruction
- Gameplay event detection
- Relevant clip identification
- Structured event generation

**Initial focus: Objective Analysis**

Analyze the period before Dragon and Baron objectives.

Identify:
- Player movement toward objectives
- Recall timing
- Team positioning
- Deaths before objectives
- Objective participation
- Major events influencing objective outcomes

Start with events that can be measured reliably. Do not assume the engine understands all gameplay decisions.

### D. Footage Condensing

The system must avoid submitting entire match recordings to the AI model.

**Processing pipeline**

Raw video  
→ Sample frames  
→ Identify relevant screen regions  
→ Detect events  
→ Construct structured timeline  
→ Save clips and evidence  
→ Generate AI-readable context

Use lower sampling frequencies for normal gameplay and more detailed sampling around detected events.

The original video should remain accessible locally so users can review the evidence.

### E. Personalized AI Coach

The AI coach uses information from both the statistical engine and the gameplay analysis engine.

**Automatic Coaching**
- Identify three recurring weaknesses
- Highlight strengths
- Detect patterns across games
- Recommend specific improvements
- Track improvement over time

**Interactive Questions**

Examples:
- Why am I losing on Jinx?
- What are my worst matchups?
- Why do I keep losing Dragon?
- Am I performing worse during loss streaks?
- What should I focus on in my next five games?
- Was my recall at 14:20 a mistake?

**Evidence-Based Responses**

Each coaching recommendation should ideally contain:

1. The identified problem.
2. Supporting match statistics or gameplay events.
3. An explanation.
4. A recommended improvement.
5. Relevant match timestamps or clips.

The coach must distinguish actual observations from hypotheses and should acknowledge insufficient evidence.

---

## 3. Technical Architecture

### Desktop Application
- Tauri + React + TypeScript
- Local SQLite database
- Native filesystem monitoring
- Video playback and analysis dashboard

### C++ Analysis Engine
- C++20
- OpenCV
- FFmpeg
- CMake
- Native executable launched by the desktop application

### Riot Integration
- Riot Account API
- Match-V5 API
- Match timeline API
- League replay directory monitoring

### AI Coaching
- LLM API initially
- Structured player profiles
- Match and event retrieval
- Evidence-backed coaching responses

### Application Flow

**Statistics Pipeline**

Riot ID  
→ Riot API  
→ Last 50 Matches  
→ Statistical Analysis  
→ Player Profile

**Replay Pipeline**

League Client  
→ Downloaded `.rofl`  
→ Desktop File Watcher  
→ Replay Registration  
→ Timeline-derived objective windows  
→ Capture queue (one client session per game, short clips) *or* manual video import  
→ C++ Analysis Engine  
→ Structured Game Events  
→ Local Database

**Coaching Pipeline**

Player Statistics + Gameplay Events  
→ Evidence Retrieval  
→ AI Coach  
→ Personalized Feedback  
→ Relevant Clips

---

## 4. Data Storage

SQLite stores:

**Players**
- Riot identifiers
- Player profile
- Match history synchronization state

**Matches**
- Match ID
- Champion
- Role
- Result
- Statistics
- Match timeline references

**Replays**
- Match ID
- Original file location
- Replay patch
- Processing status
- Capture status (`pending`, `captured`, `failed`, `unavailable`)
- Video archive location
- Errors

**Clips**
- Match ID
- Objective type and timestamp window
- File location
- Source (`auto_capture`, `manual_import`)

**Gameplay Events**
- Match ID
- Timestamp
- Event type
- Position when available
- Detection confidence
- Evidence source

**Coaching Insights**
- Player ID
- Related matches
- Identified pattern
- Supporting evidence
- Recommendation
- Analysis version

Large video files remain on the local filesystem rather than inside SQLite.

---

## 5. Development Phases

### Phase 0 — Project Foundation

- Create repository structure.
- Initialize Tauri desktop application.
- Initialize C++ project with CMake.
- Configure local SQLite storage.
- Establish development conventions.
- Configure CI build and test checks.
- Validate that the desktop application can launch the C++ executable.

**Acceptance:** The desktop app successfully launches a small C++ test executable and receives structured output.

### Phase 1 — Statistics Engine

- Integrate Riot API.
- Retrieve up to 50 matches.
- Store match data locally.
- Calculate champion statistics.
- Calculate win/loss streaks.
- Analyze matchup performance.
- Detect possible tilt-queueing patterns.
- Display statistics in the desktop UI.

**Acceptance:** A player can enter a Riot ID and view an accurate historical performance report.

### Phase 2 — Replay Ingestion

- Detect League replay directory.
- Monitor new `.rofl` downloads.
- Wait for file completion.
- Handle duplicate detection.
- Register replays in SQLite.
- Add manual replay import.
- Validate replay compatibility.
- Run the replay capture spike (LOL-006A) and record a go/no-go decision.

**Acceptance:** Downloading a supported replay causes the application to detect and register it automatically.

Rendering is a separate acceptance requirement and must be validated with an actual League client.

### Phase 3 — C++ Video Analysis

- Implement FFmpeg decoding.
- Implement frame extraction.
- Detect minimap and important HUD elements.
- Extract objective-related events.
- Build structured game timelines.
- Associate events with timestamps and clips.
- Validate detection quality against manually labeled examples.
- Develop and test against manually supplied clips first; add automated capture queue (LOL-007A) only if the spike is approved.

**Acceptance:** The engine analyzes a recorded game and produces a structured objective-related event timeline with measurable accuracy.

### Phase 4 — AI Coaching

- Create a unified player profile.
- Combine Riot statistics and extracted replay events.
- Implement evidence retrieval.
- Generate personalized recommendations.
- Implement interactive coaching questions.
- Link responses to matches and clips.
- Track recurring weaknesses across multiple games.

**Acceptance:** The AI can answer player-specific questions with accurate supporting evidence and avoid unsupported claims.

### Phase 5 — Future Expansion

- Team analysis and scouting
- Champion-specific coaching
- Automated replay capture improvements
- Historical performance comparisons
- Cloud synchronization
- Optional local AI inference
- Additional game support

---

## 6. MVP Scope

The first complete MVP consists of:

1. Desktop application.
2. Riot ID lookup.
3. Last 50 matches statistical dashboard.
4. Champion and matchup analytics.
5. Win/loss streak and session-pattern analysis.
6. Local replay file detection.
7. Basic C++ video-processing integration (manual clip import is sufficient).
8. One reliable gameplay event analysis workflow.
9. Basic personalized AI feedback.

Automated clip capture is not required for MVP unless approved after the LOL-006A spike.

Do not implement advanced coaching, complex teamfight recognition, or large-scale cloud infrastructure before the core pipeline works.

## 7. Product Principles

- Local-first architecture.
- Prioritize correct analysis over feature quantity.
- Separate statistics from footage-based observations.
- Preserve original evidence.
- Keep C++ analysis independent of the UI.
- Avoid unnecessary cloud costs.
- Follow Riot's current third-party application and game-integrity policies.
- Support partial analysis when replay footage is unavailable.
- Never invent gameplay events or confidence metrics.
- Use measurable benchmarks and representative test footage.

## 8. Long-Term Vision

Create an AI coaching platform capable of understanding a player's performance over time, identifying recurring issues, and providing actionable, evidence-backed recommendations.

The primary technical differentiator is the ability to transform raw gameplay into structured, searchable information suitable for personalized AI reasoning.
