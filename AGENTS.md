# AGENTS.md — Conventions for AI coding agents

Read `PROMPT.md` first — it is the master instruction set. This file adds
repo-specific mechanics.

## Commands

```powershell
flutter pub get          # install deps
flutter analyze          # must be clean before commit
flutter test             # must be green
dart format lib test     # apply before commit
flutter run -d windows   # desktop dev loop
flutter build web        # Vercel artifact → build/web
```

## Layout map

- `lib/models/` — plain data classes. No Flutter imports here.
- `lib/services/ai/` — the AI gateway. Providers implement `AiGateway`;
  prompts live in `prompts.dart` as versioned constants. No UI code calls
  a provider directly; route through `TaskController` or future repositories.
- `lib/services/priority/` — FFI bindings + Dart fallback. The fallback
  scorer must stay numerically in sync with `cpp/src/priority_core.cpp`.
- `lib/controllers/` — `ChangeNotifier` state; simple, no DI framework yet.
- `lib/ui/screens/` — Material 3 widgets. Style tokens come from
  `lib/core/theme.dart` only; never hardcode hex values in UI files.
- `cpp/` — pure C ABI. No globals, no I/O, exceptions never cross the
  boundary. Changes require a matching fallback-scorer update + test.

## Rules

1. Secrets: never in repo. API keys via user settings or `--dart-define`.
2. Every AI mutation is proposed as an editable suggestion card first.
3. FFI failure = fallback path, never a crash.
4. New logic ships with tests; critical flows get widget tests.
5. Design tokens from `DESIGN.md` via `theme.dart` — no ad-hoc values.

## Definition of Done

- `flutter analyze` clean, `flutter test` green, `dart format` applied.
- `flutter build web` succeeds.
- Phase checklist in `README.md` updated.
