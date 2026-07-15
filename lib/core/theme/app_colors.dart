import 'package:flutter/material.dart';

/// Power Pulse — App Colors
/// Light Theme: White + Lime Green
abstract class AppColors {
  AppColors._();

  // ─── Backgrounds ───────────────────────────────────────────
  static const Color bgDeep     = Color(0xFFF8F9FA); // خلفية الشاشة الأساسية
  static const Color bgSurface  = Color(0xFFFFFFFF); // خلفية الـ cards
  static const Color bgElevated = Color(0xFFF1F3F5); // inputs - tabs - elevated
  static const Color bgHighest  = Color(0xFFE5E7EB); // progress bars - dividers

  // ─── Accent ────────────────────────────────────────────────
  static const Color accent        = Color(0xFF8CCF00); // أخضر ليموني مناسب للـ light
  static const Color accentDim     = Color(0x268CCF00); // accent transparent
  static const Color accentPressed = Color(0xFF76B000); // pressed state

  // ─── Text ──────────────────────────────────────────────────
  static const Color textPrimary   = Color(0xFF111827); // النص الأساسي
  static const Color textSecondary = Color(0xFF4B5563); // النص الثانوي
  static const Color textMuted     = Color(0xFF9CA3AF); // النص الخافت
  static const Color textOnAccent  = Color(0xFFFFFFFF); // نص فوق الأخضر

  // ─── Semantic ──────────────────────────────────────────────
  static const Color success     = Color(0xFF16A34A);
  static const Color successDim  = Color(0x2016A34A);

  static const Color warning     = Color(0xFFD97706);
  static const Color warningDim  = Color(0x20D97706);

  static const Color danger      = Color(0xFFDC2626);
  static const Color dangerDim   = Color(0x20DC2626);

  static const Color info        = Color(0xFF2563EB);

  // ─── Border ────────────────────────────────────────────────
  static const Color borderSubtle = Color(0xFFE5E7EB);
  static const Color borderMedium = Color(0xFFD1D5DB);
  static const Color borderAccent = Color(0x408CCF00);

  // ─── Muscle Group Colors ───────────────────────────────────
  static const Color muscleChest    = Color(0xFFEF4444);
  static const Color muscleBack     = Color(0xFF2563EB);
  static const Color muscleLegs     = Color(0xFF16A34A);
  static const Color muscleShoulder = Color(0xFFD97706);
  static const Color muscleArms     = Color(0xFF8B5CF6);
  static const Color muscleCore     = Color(0xFFDB2777);
  static const Color muscleCardio   = Color(0xFF8CCF00);

  // ─── Level Colors ──────────────────────────────────────────
  static const Color levelBeginner     = Color(0xFF16A34A);
  static const Color levelIntermediate = Color(0xFFD97706);
  static const Color levelAdvanced     = Color(0xFFDC2626);

  // ─── Extra — Home UI + Workout Logger ──────────────────────
  static const Color infoDim      = Color(0x202563EB);
  static const Color bghighest    = Color(0xFFE5E7EB);
}