# PROMPT.md — Master Development Prompt
# AI Task Manager (Flutter · AI Gateway · C++ FFI)

You are building **AI Task Manager**: a Google Tasks-inspired, mobile-first task
manager in Flutter with a pluggable AI gateway and a C++ FFI priority core.
Follow `BLUEPRINT.md` (architecture) and `DESIGN.md` (visual system) exactly.
This file is the canonical instruction set for any AI agent or developer
contributing to this repository.

---

## 1. Mission

Ship the phased roadmap in `BLUEPRINT.md §5`:

- **P0 Skeleton** — data models, local DB, CRUD UI, CI, Vercel web shell.
- **P1 AI Gateway** — provider abstraction + OpenAI-compatible adapter + NL task parsing.
- **P2 C++ Core** — FFI bindings + scoring engine + Dart fallback.
- **P3 Assistant** — Day Pilot chat with agentic action cards.
- **P4 Polish** — recurrence, search, theming, a11y, performance.

Always work inside one phase; do not silently start the next.

---

## 2. Non-Negotiables

1. **Local-first.** Every mutation works offline. AI features degrade gracefully.
2. **Provider-agnostic AI.** All model access goes through the `AiGateway`
   interface in `lib/services/ai/`. No provider SDK calls in UI code. Ever.
3. **C++ isolation.** FFI calls are wrapped in `PriorityCore` with a pure-Dart
   fallback scorer. A missing/broken native lib must never crash the app.
4. **Secrets stay out.** API keys live in the user's local settings
   (or `--dart-define`), never in the repo. No key ever in a commit.
5. **Design fidelity.** Every new screen/component must follow `DESIGN.md`
   tokens (colors, type scale, spacing, radii). No ad-hoc hex values.
6. **Test-verified.** New logic ships with unit tests; UI flows get widget
   tests for critical paths (create, complete, AI parse confirm).

---

## 3. AI Gateway Contract

```dart
abstract interface class AiGateway {
  Future<TaskDraft> parseTask(String input);
  Future<List<SubtaskDraft>> generateSubtasks(Task task);
  Future<PriorityRationale> explainPriority(Task task, TaskContext ctx);
  Stream<ChatChunk> chat(List<ChatMessage> history, TaskContext ctx);
  Future<DailyReview> dailyReview(DayLog log);
}
```

- Implementations: `OpenAiProvider`, `AnthropicProvider`, `GeminiProvider`.
- Router adds: fallback chain, retry/backoff, per-feature model routing,
  response cache, streaming, cost ledger.
- Prompts live in `lib/services/ai/prompts.dart` as versioned constants.
- All model responses are **validated** before mutating state; unparseable
  output is retried once, then surfaced as a gentle inline error.

---

## 4. C++ FFI Rules

- Public ABI is pure C (header `cpp/include/priority_core.h`).
- Build via `cpp/CMakeLists.txt`; bind with `ffigen` config in `pubspec.yaml`.
- Keep functions pure (no globals, no I/O, no exceptions across the boundary).
- Dart wrapper converts `int`/`double` only; structs use `dart:ffi` classes.
- If `DynamicLibrary.open` fails → log once, use `FallbackScorer`, hide C++-only UI hints.

---

## 5. UI Rules (from DESIGN.md — see for tokens)

- Dark-first "quiet precision" system: near-black canvas `#08090A`, single
  electric accent `#E4F222` for the one primary action per view.
- Inter type scale (400–590 weights only, never 700+), hairline borders over
  shadows, 12px card / 6px button radii, 8/12/24/96 spacing ladder.
- Material 3 components, Riverpod state, repository pattern.
- Every AI output appears as an **editable suggestion card** before commit —
  the user is always the final authority.

---

## 6. Definition of Done (per phase)

- `flutter analyze` clean; `dart format` applied.
- `flutter test` green (incl. new tests for the phase).
- `flutter build web` succeeds; deployed to Vercel preview.
- Phase section in `README.md` checked off with notes.

---

## 7. Commands

```powershell
flutter pub get
flutter analyze
flutter test
dart format lib test
flutter run -d windows          # desktop dev
flutter run -d chrome           # web dev
flutter build web               # Vercel artifact (build/web)
```

---

## 8. Current State

- **Phase:** P0 → P1 boundary. Skeleton scaffolded (Flutter 3.47, Dart 3.13).
- Repository: GitHub `Faithmanex/ai-task-manager` (public).
- Web deploy: Vercel project linked to the repo (auto-deploy on push).
