# Jules Backlog — Scheduled Tasks

> Source of truth for autonomous work. The scheduled workflow (`.github/workflows/jules-scheduled.yml`) rotates through these tasks daily at 02:00 UTC by creating a `jules`-labeled GitHub Issue. Jules (jules.google.com) picks it up automatically if the repo is connected.

## How to connect (one-time, 2 min)

1. Go to **https://jules.google.com** → Sign in with GitHub
2. **Select repository:** `Faithmanex/ai-task-manager` → branch `master`
3. Allow access → Jules will now see any open issue with label `jules`
4. (Optional) In Jules → Settings → Enable **Autonomous mode** for this repo

Manual trigger: Actions → **Jules Scheduled Tasks** → **Run workflow** → enter custom prompt.

## Backlog (P3 → P4)

### P3 — Assistant
- [ ] **P3-01 Day Pilot streaming + action cards** — Wire `gateway.chat` streaming in `lib/ui/screens/chat_screen.dart`, render confirmation cards for create/move/complete, persist conversation.
- [ ] **P3-02 Daily review** — Build `DailyReview` UI from `gateway.dailyReview(DayLog)`, trigger at day end, persist last review.
- [ ] **P3-03 Subtask generation UI** — Call `gateway.generateSubtasks` from task detail, show accept/edit/regen flow, persist result.

### P4 — Polish
- [ ] **P4-01 Recurrence** — RRULE subset (daily/weekly/monthly), compute next-due on complete, tests for edge cases.
- [ ] **P4-02 Search & filters** — Search bar + priority/due/starred filters, debounce, empty states, tests.
- [ ] **P4-03 Theming & a11y** — Verify DESIGN.md contrast ≥4.5:1, add Semantics labels, dynamic type, reduce motion.
- [ ] **P4-04 Settings persistence hardening** — Encrypt `apiKey` at rest (flutter_secure_storage), migration tests, mask in UI.

### Chore — Always eligible
- [ ] **CH-01 Deps** — `flutter pub outdated` → bump, `dart fix --apply`, `flutter analyze` clean.
- [ ] **CH-02 Docs** — Keep README / BLUEPRINT / DESIGN in sync with code.

## Creating a task manually

```bash
gh issue create --title "Jules: <your prompt>" --body "Detailed prompt here" --label jules
```

Or comment `/jules <prompt>` on any issue if the Jules GitHub App is installed.

## Verification (every Jules PR must pass)

```bash
flutter pub get
flutter analyze
flutter test
flutter build web
```
