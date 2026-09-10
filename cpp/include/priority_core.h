// Pure C ABI for the AI Task Manager priority core.
// Bound to Dart via ffigen; see BLUEPRINT.md §2.2.
#ifndef PRIORITY_CORE_H
#define PRIORITY_CORE_H

#include <stddef.h>

#ifdef __cplusplus
extern "C" {
#endif

// Computes a priority score in [0, 100] for one task.
// urgency_norm   [0..1] normalized deadline pressure
// importance     [0..1] user-assigned importance
// age_days       days since creation (aging boost)
// effort_hours   estimated effort; higher effort starts earlier
// flags          bit 0: overdue, bit 1: has subtasks, bit 2: ai_suggested
double priority_score(double urgency_norm,
                      double importance,
                      double age_days,
                      double effort_hours,
                      int flags);

// Suggests a capacity estimate for a day: how many hours of task work
// fit given available_hours and average task effort.
double capacity_estimate(double available_hours,
                         double avg_effort_hours);

#ifdef __cplusplus
}
#endif

#endif // PRIORITY_CORE_H
