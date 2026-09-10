# AI Task Manager

Google Tasks-inspired, mobile-first task manager in **Flutter**, with a
pluggable **AI gateway** (OpenAI-compatible, Claude, Gemini) and a **C++ FFI
priority core**. Natural-language capture, hybrid AI/deterministic
prioritization, AI subtask generation, and a chat-based daily planning
assistant ("Day Pilot").

| Doc | Purpose |
|---|---|
| [BLUEPRINT.md](BLUEPRINT.md) | Architecture, features, phases |
| [PROMPT.md](PROMPT.md) | Master development prompt / rules |
| [DESIGN.md](DESIGN.md) | Design system (tokens, components) |
| [AGENTS.md](AGENTS.md) | Agent/developer conventions |

## Quick start

```powershell
flutter pub get
flutter run -d windows     # desktop
flutter run -d chrome      # web
flutter test               # run test suite
flutter build web          # production web build → build/web
```

## AI gateway

Bring your own model: set Base URL + API key in Settings (stored locally).
Any OpenAI-compatible endpoint works (OpenAI, Ollama, LM Studio, vLLM).
Claude and Gemini adapters stub the same `AiGateway` interface.

## C++ priority core

Deterministic scoring (urgency × importance, aging, effort, overdue flags)
implemented in `cpp/`, exposed via a pure C ABI, bound with `ffigen`. If the
native library is absent, a numerically identical Dart fallback takes over.

```powershell
cd cpp
cmake -B build && cmake --build build   # produces priority_core shared lib
```

## Roadmap

- [x] **P0 Skeleton** — models, controller, themed UI, tests, CI, Vercel config
- [x] **P1 AI Gateway** — provider abstraction, OpenAI adapter, NL parsing, suggestion cards
- [x] **P2 C++ core** — FFI bindings + fallback scorer, scores in task tiles
- [ ] **P3 Assistant** — Day Pilot chat streaming, action cards
- [ ] **P4 Polish** — recurrence, search, persistence (Isar), a11y pass

## Deployment

Web build auto-deploys to Vercel from `main` (preview per PR).

## License

MIT
