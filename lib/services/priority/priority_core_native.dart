/// Native (C++ FFI) implementation — loaded only on IO platforms.
library;

import 'dart:ffi' as ffi;
import 'dart:io' show Platform;

import 'priority_core.dart';

/// Attempts to load the shared library; throws if unavailable,
/// in which case the caller falls back to Dart scoring.
PriorityScoreNative loadScoreNative() {
  final lib = _openLibrary();
  return lib
      .lookupFunction<
        ffi.Double Function(
          ffi.Double,
          ffi.Double,
          ffi.Double,
          ffi.Double,
          ffi.Int32,
        ),
        double Function(double, double, double, double, int)
      >('priority_score');
}

ffi.DynamicLibrary _openLibrary() {
  if (Platform.isWindows) return ffi.DynamicLibrary.open('priority_core.dll');
  if (Platform.isMacOS) {
    return ffi.DynamicLibrary.open('libpriority_core.dylib');
  }
  return ffi.DynamicLibrary.open('libpriority_core.so');
}
