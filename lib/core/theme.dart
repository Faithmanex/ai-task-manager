/// Canonical theme from DESIGN.md tokens.
library;

import 'package:flutter/material.dart';

const kVoid = Color(0xFF08090A);
const kCarbon = Color(0xFF0F1011);
const kObsidian = Color(0xFF161718);
const kGraphite = Color(0xFF23252A);
const kSmoke = Color(0xFF383B3F);
const kAsh = Color(0xFF62666D);
const kFog = Color(0xFF8A8F98);
const kMist = Color(0xFFD0D6E0);
const kBone = Color(0xFFE5E5E6);
const kPaper = Color(0xFFFFFFFF);
const kAcidLime = Color(0xFFE4F222);
const kPulseGreen = Color(0xFF27A644);
const kCoralRed = Color(0xFFEB5757);
const kSignalTeal = Color(0xFF02B8CC);
const kIrisViolet = Color(0xFF6366F1);
const kLavender = Color(0xFF8B5CF6);

ThemeData buildTheme() {
  final scheme = ColorScheme.dark(
    primary: kAcidLime,
    onPrimary: kVoid,
    secondary: kSignalTeal,
    surface: kCarbon,
    onSurface: kMist,
    surfaceContainerHighest: kObsidian,
    onSurfaceVariant: kFog,
    error: kCoralRed,
    outline: kGraphite,
  );

  return ThemeData(
    useMaterial3: true,
    colorScheme: scheme,
    scaffoldBackgroundColor: kVoid,
    fontFamily: 'Inter',
    splashFactory: InkSparkle.splashFactory,
    dividerColor: kGraphite,
    textTheme: const TextTheme(
      displayLarge: TextStyle(fontSize: 72, fontWeight: FontWeight.w500),
      headlineLarge: TextStyle(fontSize: 32, fontWeight: FontWeight.w400),
      headlineMedium: TextStyle(fontSize: 24, fontWeight: FontWeight.w400),
      titleLarge: TextStyle(fontSize: 20, fontWeight: FontWeight.w600),
      titleMedium: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
      bodyLarge: TextStyle(fontSize: 16, fontWeight: FontWeight.w400),
      bodyMedium: TextStyle(
        fontSize: 15,
        fontWeight: FontWeight.w400,
        color: kMist,
      ),
      bodySmall: TextStyle(
        fontSize: 13,
        fontWeight: FontWeight.w400,
        color: kFog,
      ),
      labelLarge: TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
      labelMedium: TextStyle(fontSize: 12, fontWeight: FontWeight.w400),
    ).apply(bodyColor: kMist, displayColor: kPaper),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: const Color(0x02FFFFFF),
      hintStyle: const TextStyle(color: kFog, fontSize: 14),
      contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      border: _hairline,
      enabledBorder: _hairline,
      focusedBorder: const OutlineInputBorder(
        borderSide: BorderSide(color: kMist),
        borderRadius: BorderRadius.all(Radius.circular(6)),
      ),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: kAcidLime,
        foregroundColor: kVoid,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(6)),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      ),
    ),
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        foregroundColor: kMist,
        side: const BorderSide(color: kGraphite),
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(6)),
        ),
      ),
    ),
    cardTheme: const CardThemeData(
      color: kCarbon,
      elevation: 0,
      margin: EdgeInsets.zero,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.all(Radius.circular(12)),
      ),
    ),
    listTileTheme: const ListTileThemeData(
      iconColor: kFog,
      textColor: kBone,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.all(Radius.circular(12)),
      ),
    ),
  );
}

const _hairline = OutlineInputBorder(
  borderSide: BorderSide(color: kGraphite),
  borderRadius: BorderRadius.all(Radius.circular(6)),
);
