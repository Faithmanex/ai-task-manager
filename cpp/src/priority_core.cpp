// Deterministic scoring engine — see BLUEPRINT.md §2.2.
// Pure functions only: no globals, no I/O, no exceptions across ABI.
#include "priority_core.h"
#include <cmath>

static double clamp01(double v) {
    return v < 0.0 ? 0.0 : (v > 1.0 ? 1.0 : v);
}

static const double kMaxAgeDays = 14.0;

double priority_score(double urgency_norm,
                      double importance,
                      double age_days,
                      double effort_hours,
                      int flags) {
    double urgency = clamp01(urgency_norm);
    double imp     = clamp01(importance);
    double age     = age_days < 0.0 ? 0.0 : age_days;
    double effort  = effort_hours < 0.0 ? 0.0 : effort_hours;

    // Eisenhower-style weighting: urgency x importance dominates.
    double score = 40.0 * urgency * imp
                 + 25.0 * urgency
                 + 20.0 * imp;

    // Aging boost: stale tasks creep upward, capped.
    double age_boost = 10.0 * (age / kMaxAgeDays);
    score += age_boost;

    // Large-effort tasks should surface earlier (start-early heuristic).
    double effort_boost = 5.0 * (effort / 8.0);
    if (effort_boost > 5.0) effort_boost = 5.0;
    score += effort_boost;

    if (flags & 0x1) score += 10.0;  // overdue
    if (flags & 0x2) score -= 2.0;    // decomposed tasks feel lighter
    if (flags & 0x4) score -= 1.0;    // AI-suggested items defer slightly

    if (score < 0.0) return 0.0;
    if (score > 100.0) return 100.0;
    return score;
}

double capacity_estimate(double available_hours,
                         double avg_effort_hours) {
    if (available_hours <= 0.0) return 0.0;
    if (avg_effort_hours <= 0.0) avg_effort_hours = 0.5;

    // Assume ~80% of raw time is truly productive.
    double productive = available_hours * 0.8;
    return std::floor(productive / avg_effort_hours);
}
