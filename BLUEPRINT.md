# AI Task Manager — Application Blueprint

> **Status:** Blueprint v1.0 · **Repo:** `ai-task-manager` · **Path:** `Documents\GitHub\ai-task-manager`
> **Stack:** Flutter (mobile-first) · Dart AI Gateway · C++ FFI priority core · GitHub · Vercel

---

## 1. Product Vision

A Google Tasks-inspired task manager where AI is a first-class citizen, not a bolt-on. Users capture tasks in natural language, and the system intelligently parses, prioritizes, decomposes, and schedules them. A chat-based assistant ("Day Pilot") helps plan and renegotiate daily goals.

**Design identity:** "quiet precision instrument" — calm, compact, low-contrast dark UI with a single electric accent. See [DESIGN.md](DESIGN.md) for the full design system.

### Core Differentiators
1. **Natural language capture** — "Email Dana the revised deck tomorrow before standup" becomes a structured task (title, due date, time hint, subtask hint, priority).
2. **Intelligent prioritization** — a hybrid engine: C++ scoring core (deterministic, offline, fast) + LLM reasoning (contextual, explainable).
3. **Dynamic subtask generation** — AI decomposes large tasks into ordered subtasks; user accepts/edits/rejects.
4. **Chat-based daily goal assistant** — plan the day, reshuffle when reality changes, end-of-day review.

---

## 2. System Architecture

```
┌─────────────────────────────────────────────────────────────────┐
│                        FLUTTER CLIENT                           │
│  ┌───────────────┐  ┌───────────────┐  ┌────────────────────┐  │
│  │  Presentation │  │  Controllers  │  │  AI Chat Assistant │  │
│  │  (Material 3) │  │  (Riverpod)   │  │  (Day Pilot panel) │  │
│  └───────┬───────┘  └───────┬───────┘  └─────────┬──────────┘  │
│          └──────────────┬───┴────────────────────┘             │
│                  ┌──────┴───────┐                              │
│                  │  Repositories │                              │
│                  └──┬───────┬───┘                              │
│           ┌─────────┴─┐   ┌─┴─────────────┐                    │
│           │ Local DB  │   │ AI Gateway    │◄──── (Dart)        │
│           │ (Isar /   │   │ (pluggable    │                     │
│           │  drift)   │   │  providers)   │                     │
│           └───────────┘   └──────┬────────┘                    │
│                                │ FFI                          │
│                   ┌────────────┴────────────┐                  │
│                   │  C++ Priority Core      │  ◄── native lib  │
│                   │  (urgency/aging/Eisen-   │      via CMake   │
│                   │  hower scoring engine)  │      + ffigen     │
│                   └────────────────────────┘                  │
└─────────────────────────────────────────────────────────────────┘
                     │ HTTPS (OpenAI-compatible)
              ┌──────┴──────┐
              │  Model API  │  GPT / Claude / Gemini / Ollama …
              └─────────────┘
```

### 2.1 AI Gateway (lib/services/ai/)
The gateway is **provider-agnostic**. All providers implement `AiGateway` and speak an internal canonical request/response shape (task parsing, subtask generation, chat, prioritization rationale). Provider adapters:
- `OpenAiProvider` — OpenAI & any OpenAI-compatible endpoint (incl. Ollama, LM Studio, vLLM).
- `AnthropicProvider` — Claude models.
- `GeminiProvider` — Google AI Studio / Vertex.
- Router features: fallback chain, retry with backoff, per-feature model routing (cheap model for parsing, strong model for chat), response caching, streaming for chat, token/cost ledger.

### 2.2 C++ Priority Core (cpp/)
Performance-critical deterministic scoring, compiled per-platform and bound via `dart:ffi` (ffigen):
- urgency decay curves, deadline pressure, Eisenhower quadrant mapping, streak/aging boosts, workload capacity heuristics.
- Pure C ABI: `priority_score(...)`, `reorder_suggestions(...)`, `capacity_estimate(...)`.
- Never crashes the app: all calls guarded, exceptions surface as `PriorityCoreUnavailable` and the Dart fallback scorer takes over.

### 2.3 Data Layer
- **Local-first:** Isar (or drift) database; optimistic UI; background sync when a cloud backend is later added.
- Entities: `Task`, `Subtask`, `TaskList`, `Tag`, `AiSuggestion`, `ChatMessage`, `Settings`.

---

## 3. Feature Blueprint

### 3.1 Tasks (Google Tasks parity)
- Lists with colors, task CRUD, subtasks (one level, expand/collapse), due dates + recurring rules (RRULE subset), notes, drag-to-reorder, completed section, search.

### 3.2 AI Features (the moat)
| Feature | Input | Output | Engine |
|---|---|---|---|
| NL task creation | Free text | Structured `TaskDraft` (title/date/priority/tags/subtasks) | Gateway → `parseTask` |
| Smart prioritize | Task set | Ranked order + per-task rationale | C++ core + Gateway rationale |
| Subtask generation | A task | 3–7 ordered subtasks (accept/edit/regen) | Gateway → `generateSubtasks` |
| Day Pilot chat | Conversation | Actions (create/move/complete) + advice | Gateway → `chat`, tool-calling |
| Daily review | Day's data | Wins, misses, tomorrow's top 3 | Gateway → `dailyReview` |

### 3.3 Day Pilot Assistant
Chat panel with **agentic actions**: the assistant can propose mutations (create, reschedule, reprioritize, split) that render as confirmation cards; one tap applies. Conversation history persisted. System prompt carries a compact schedule/task context window.

### 3.4 Non-functional
- Offline-first; AI features degrade gracefully (C++ scorer + local heuristics).
- Privacy: model calls only with user's own API key; no middleman server by default.
- Accessibility: full semantics, 4.5:1 contrast minimum, dynamic type.

---

## 4. Repository Layout

```
ai-task-manager/
├── BLUEPRINT.md            ← this file (architecture & scope)
├── PROMPT.md               ← master development prompt
├── DESIGN.md               ← design system (Refero template style)
├── AGENTS.md               ← coding conventions for AI agents
├── vercel.json             ← web deploy config (Flutter WASM build)
├── pubspec.yaml
├── lib/
│   ├── main.dart
│   ├── core/               ← constants, result types, extensions
│   ├── models/             ← Task, Subtask, TaskList, ChatMessage …
│   ├── services/
│   │   ├── ai/             ← AI GATEWAY: providers, router, prompts
│   │   ├── database/       ← local DB
│   │   └── priority/       ← FFI bindings + Dart fallback scorer
│   ├── controllers/        ← state (Riverpod)
│   └── ui/                 ← screens & widgets (Material 3)
├── cpp/
│   ├── CMakeLists.txt
│   ├── include/priority_core.h   ← C ABI header
│   └── src/priority_core.cpp
├── ffi/                    ← generated ffigen bindings (optional gen step)
├── test/                   ← unit + widget tests
└── web/                    ← Flutter web assets (Vercel target)
```

---

## 5. Development Phases

| Phase | Scope | Exit criteria |
|---|---|---|
| **P0 — Skeleton** | Repo, CI, Vercel web shell, data models, CRUD UI | App runs on Windows/web; tasks CRUD works |
| **P1 — AI Gateway** | Provider abstraction, OpenAI-compatible adapter, NL parse | "Tomorrow 5pm" NL input creates structured task |
| **P2 — C++ core** | FFI bindings, scoring engine, fallback | Tasks ranked identically by C++ & Dart fallback |
| **P3 — Assistant** | Day Pilot chat, action cards, daily review | Chat can create/move/complete tasks via confirmations |
| **P4 — Polish** | Recurrence, search, theming, a11y, perf | Store-ready polish pass |

---

## 6. CI/CD Pipeline

- **GitHub Actions:** on push → `flutter analyze` + `flutter test` (+ optional `flutter build web`).
- **Vercel:** GitHub-linked project; `main` → production, PRs → preview. `vercel.json` drives the build (Flutter web/WASM output in `build/web`).
- **Native C++:** CMake + bundled prebuilt libs per platform (started in P2; CI artifact job later).

---

## 7. Constraints & Decisions

- **Mobile-first Flutter**; desktop/web targets supported by the same codebase.
- **AI gateway lives in Dart** inside the Flutter app (no mandatory backend). A serverless proxy (Vercel functions) is optional for key protection later.
- **C++ via FFI** only for the deterministic priority math — not for UI, storage, or model calls.
- **Local-first data** with a future sync path (no vendor lock).
- **Model-agnostic:** works with any OpenAI-compatible endpoint; Claude/Gemini adapters included.
