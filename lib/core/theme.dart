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
      // Type scale per DESIGN.md (Linear reference):
      // display 72/510 · heading-sm 32/400 · heading 24/400 ·
      // body-lg 20/590 · body 16/400 · body-sm 15/400 · caption 13/400
      displayLarge: TextStyle(
        fontSize: 72,
        fontWeight: FontWeight.w500,
        height: 1.0,
        letterSpacing: -1.584,
      ),
      displaySmall: TextStyle(
        fontSize: 48,
        fontWeight: FontWeight.w500,
        height: 1.0,
        letterSpacing: -1.056,
      ),
      headlineLarge: TextStyle(
        fontSize: 32,
        fontWeight: FontWeight.w400,
        height: 1.13,
        letterSpacing: -0.704,
      ),
      headlineMedium: TextStyle(
        fontSize: 24,
        fontWeight: FontWeight.w400,
        height: 1.33,
        letterSpacing: -0.288,
      ),
      titleLarge: TextStyle(
        fontSize: 20,
        fontWeight: FontWeight.w500,
        height: 1.33,
        letterSpacing: -0.24,
      ),
      titleMedium: TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.w500,
        height: 1.5,
        letterSpacing: -0.16,
      ),
      bodyLarge: TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.w400,
        height: 1.5,
      ),
      bodyMedium: TextStyle(
        fontSize: 15,
        fontWeight: FontWeight.w400,
        height: 1.6,
        letterSpacing: -0.165,
        color: kMist,
      ),
      bodySmall: TextStyle(
        fontSize: 13,
        fontWeight: FontWeight.w400,
        height: 1.2,
        color: kFog,
      ),
      labelLarge: TextStyle(
        fontSize: 14,
        fontWeight: FontWeight.w500,
        height: 1.4,
        letterSpacing: -0.14,
      ),
      labelMedium: TextStyle(
        fontSize: 12,
        fontWeight: FontWeight.w400,
        height: 1.4,
      ),
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
