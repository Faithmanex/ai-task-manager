/// Web/stub implementation — no native core on the web platform.
library;

import 'priority_core.dart';

/// Always uses the pure-Dart fallback scorer on the web.
PriorityScoreNative loadScoreNative() => PriorityCore.fallbackScore;
