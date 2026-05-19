import 'package:flutter/material.dart';

/// Central color constants extracted from across the codebase.
/// Previously colors were inlined as Color(0xFF...) literals everywhere.
class AppColors {
  AppColors._();

  // ── Brand / Primary ─────────────────────────────────────────────────────────
  static const Color primary = Colors.amber;
  static const Color primaryDark = Color(0xFFFFA000);

  // ── Backgrounds ─────────────────────────────────────────────────────────────
  /// Main scaffold background (was Color(0xFF3C3F41) in main.dart & Gim_view)
  static const Color scaffoldBackground = Color(0xFF3C3F41);

  /// ExerciseDetailPage dark background
  static const Color darkBackground = Color(0xFF212121);

  /// Details card background used in ExerciseDetailPage
  static const Color cardBackground = Color(0xFF424242);

  // ── Tools screen cards (ToolsScreen) ────────────────────────────────────────
  static const Color toolCardBackground = Color(0xFFE6F4F1);
  static const Color toolCardShadow = Color(0xFFD1E8E4);
  static const Color toolCardText = Color(0xFF333333);

  // ── Input / Form borders (Continar widget, IdelWeight, CulcolateCounting) ───
  static const Color inputBorder = Color(0xFFC8E6C9);

  // ── Text ────────────────────────────────────────────────────────────────────
  static const Color textWhite = Colors.white;
  static const Color textAmber = Colors.amber;
  static const Color textGreenAccent = Colors.greenAccent;
  static const Color textGrey = Colors.grey;

  // ── Misc ────────────────────────────────────────────────────────────────────
  static const Color divider = Colors.grey;
  static const Color overlayDark = Color(0x99000000); // black 60%
  static const Color overlayLight = Color(0x33000000); // black 20%

  // ── BMI gauge range colors (CustomBmi widget) ────────────────────────────────
  static const Color bmiUnderweight = Color(0xFFB2DFDB);
  static const Color bmiNormal = Color(0xFF8CC9FF);
  static const Color bmiOverweight = Color(0xFF4CAF50);
  static const Color bmiObese = Color(0xFFFFEB3B);
  static const Color bmiMorbidObese = Colors.red;

  // ── Button ───────────────────────────────────────────────────────────────────
  static const Color buttonBackground = Color(0xFFB2DFDB); // green[100]
}
