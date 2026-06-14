import 'package:flutter/material.dart';

class AppColors {
  AppColors._();

  // ── Canvas — tonal depth (Level 0 → 3) ────────────────────────────────────
  static const Color background    = Color(0xFF0B0F1A);
  static const Color surface       = Color(0xFF13182A);
  static const Color surfaceCard   = Color(0xFF13182A);
  static const Color surfaceHigh   = Color(0xFF1A2035);
  static const Color surfaceBright = Color(0xFF212840);

  // ── Primary ────────────────────────────────────────────────────────────────
  static const Color primary             = Color(0xFF7B6EFF);
  static const Color primaryContainer    = Color(0xFF4A3FBF);
  static const Color onPrimary           = Color(0xFFFFFFFF);
  static const Color onPrimaryContainer  = Color(0xFFECE9FF);
  static const Color primaryAmbient      = Color(0x1A7B6EFF);

  // ── Text ───────────────────────────────────────────────────────────────────
  static const Color textPrimary      = Color(0xFFF0F2FF);
  static const Color textSecondary    = Color(0xFF8A93B0);
  static const Color textTertiary     = Color(0xFF555E7A);
  static const Color onSurface        = Color(0xFFF0F2FF);
  static const Color onSurfaceVariant = Color(0xFF8A93B0);

  // ── Semantic ───────────────────────────────────────────────────────────────
  static const Color success = Color(0xFF34DCA0);
  static const Color warning = Color(0xFFFFAB2E);
  static const Color error   = Color(0xFFFF5C5C);

  // ── Borders / separators ───────────────────────────────────────────────────
  static const Color separator    = Color(0x14FFFFFF);
  static const Color borderSubtle = Color(0x1FFFFFFF);
  static const Color borderActive = Color(0xFF7B6EFF);
  static const Color cardBorder   = Color(0x0DFFFFFF);
  static const Color divider      = Color(0x0DFFFFFF);

  // ── Outline ────────────────────────────────────────────────────────────────
  static const Color outline        = Color(0xFF4A5270);
  static const Color outlineVariant = Color(0xFF252C45);

  // ── Gradients ─────────────────────────────────────────────────────────────
  static const List<Color> primaryGradient = [Color(0xFF9B8FFF), Color(0xFF5B50D9)];
  static const List<Color> actionGlow      = [Color(0xFF9B8FFF), Color(0xFF5B50D9)];
  static const List<Color> successGradient = [Color(0xFF34DCA0), Color(0xFF00B87A)];
  static const List<Color> warnGradient    = [Color(0xFFFFAB2E), Color(0xFFE8900A)];

  // ── Progress rings ─────────────────────────────────────────────────────────
  static const List<Color> progressRingCalories = [Color(0xFF7B6EFF), Color(0xFF34DCA0)];
  static const List<Color> progressRingWorkouts = [Color(0xFF34DCA0), Color(0xFF00B87A)];
  static const List<Color> progressRingSteps    = [Color(0xFFFFAB2E), Color(0xFF7B6EFF)];

  // ── BMI scale ──────────────────────────────────────────────────────────────
  static const Color bmiUnderweight = Color(0xFF7B6EFF);
  static const Color bmiNormal      = Color(0xFF34DCA0);
  static const Color bmiOverweight  = Color(0xFFFFAB2E);
  static const Color bmiObese       = Color(0xFFFF8C42);
  static const Color bmiMorbidObese = Color(0xFFFF5C5C);

  // ── Theme palette helpers (used by AppTheme / MaterialApp) ─────────────────
  static const Color inversePrimary      = Color(0xFFBDAEFF);
  static const Color secondary           = success;
  static const Color secondaryContainer  = Color(0xFF1A3D32);
  static const Color onSecondary         = Color(0xFF003828);
  static const Color onSecondaryContainer = success;
  static const Color tertiary            = warning;
  static const Color tertiaryContainer   = Color(0xFF3D2E00);
  static const Color onTertiary          = Color(0xFF2A1C00);
  static const Color onError             = Color(0xFFFFFFFF);
  static const Color errorContainer      = Color(0xFF4D0A0A);
  static const Color surfaceVariant      = surfaceBright;

  static const Color overlayDark = Color(0xCC000000);

  static const Color cardBackground = surfaceHigh;
  static const Color primaryGlow = primaryAmbient;
}
