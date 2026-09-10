/// FFI bindings for the C++ priority core with pure-Dart fallback.
/// If the native library is missing, [FallbackScorer] takes over —
/// the app never crashes (PROMPT.md §4).
///
/// This file selects the native or web implementation via conditional
/// imports: `dart:ffi` is unavailable on the web platform.
library;

import '../../models/task.dart';
import 'priority_core_stub.dart'
    if (dart.library.io) 'priority_core_native.dart';

/// Native loader contract, satisfied per platform.
typedef PriorityScoreNative = double Function(
  double,
  double,
  double,
  double,
  int,
);

/// Result of a scoring call.
class ScoreResult {
  ScoreResult({required this.score, required this.fromNative});

  final double score;
  final bool fromNative;
}

/// Scoring engine facade: native C++ first, Dart fallback second.
class PriorityCore {
  PriorityCore._(this._scoreNative);

  final double Function(double, double, double, double, int) _scoreNative;

  static PriorityCore? _instance;

  /// Attempts to load the native core once; falls back to Dart silently.
  static PriorityCore get instance {
    if (_instance != null) return _instance!;
    late double Function(double, double, double, double, int) score;
    try {
      score = loadScoreNative();
    } catch (_) {
      score = fallbackScore;
    }
    _instance = PriorityCore._(score);
    return _instance!;
  }

  static const int kFlagOverdue = 0x1;
  static const int kFlagHasSubtasks = 0x2;
  static const int kFlagAiSuggested = 0x4;

  /// Score a task in [0, 100].
  ScoreResult score(Task task, {DateTime? now}) {
    final at = now ?? DateTime.now();
    final due = task.dueDate;

    double urgency = 0;
    if (due != null) {
      final hoursLeft = due.difference(at).inMinutes / 60.0;
      urgency = (1 - (hoursLeft / 72)).clamp(0.0, 1.0);
      if (task.isOverdue) urgency = 1;
    }

    final importance = switch (task.priority) {
      Priority.low => 0.2,
      Priority.medium => 0.6,
      Priority.high => 1.0,
    };

    final ageDays = task.createdAt == null
        ? 0.0
        : at.difference(task.createdAt!).inMinutes / 1440.0;

    var flags = 0;
    if (task.isOverdue) flags |= kFlagOverdue;
    if (task.subtasks.isNotEmpty) flags |= kFlagHasSubtasks;
    if (task.aiSuggested) flags |= kFlagAiSuggested;

    return ScoreResult(
      score: _scoreNative(urgency, importance, ageDays, 1.5, flags),
      fromNative: !identical(_scoreNative, fallbackScore),
    );
  }

  /// Pure-Dart mirror of cpp/src/priority_core.cpp — keep in sync!
  static double fallbackScore(
    double urgencyNorm,
    double importance,
    double ageDays,
    double effortHours,
    int flags,
  ) {
    double clamp01(double v) => v < 0 ? 0 : (v > 1 ? 1 : v);
    final urgency = clamp01(urgencyNorm);
    final imp = clamp01(importance);
    final age = ageDays < 0 ? 0.0 : ageDays;
    double score = 40 * urgency * imp + 25 * urgency + 20 * imp;
    score += 10 * (age / 14);
    var effortBoost = 5 * (effortHours / 8);
    if (effortBoost > 5) effortBoost = 5;
    score += effortBoost;
    if ((flags & kFlagOverdue) != 0) score += 10;
    if ((flags & kFlagHasSubtasks) != 0) score -= 2;
    if ((flags & kFlagAiSuggested) != 0) score -= 1;
    return score.clamp(0.0, 100.0);
  }
}
