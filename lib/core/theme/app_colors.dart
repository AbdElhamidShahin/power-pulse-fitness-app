import 'package:flutter/material.dart';

/// Power Pulse — App Colors (Updated Design v2)
/// Light Theme: Cream White + Lime Green + Dark Cards
abstract class AppColors {
  AppColors._();

  // ─── Backgrounds ───────────────────────────────────────────
  static const Color bgDeep     = Color(0xFFF5F5F0); // خلفية الشاشة — كريمي دافئ
  static const Color bgSurface  = Color(0xFFFFFFFF); // cards بيضاء
  static const Color bgElevated = Color(0xFFEFEFEF); // inputs - tabs
  static const Color bgHighest  = Color(0xFFE5E7EB); // dividers

  // ─── Dark Surfaces (للـ streak card و active time) ────────
  static const Color bgDark    = Color(0xFF1A1A1A);
  static const Color bgDarkSub = Color(0xFF2A2A2A);

  // ─── Accent — Lime Green ───────────────────────────────────
  static const Color accent        = Color(0xFFA8E063);
  static const Color accentDim     = Color(0x26A8E063);
  static const Color accentPressed = Color(0xFF8CC84E);

  // ─── Text ──────────────────────────────────────────────────
  static const Color textPrimary   = Color(0xFF1A1A1A);
  static const Color textSecondary = Color(0xFF4B5563);
  static const Color textMuted     = Color(0xFF8A8A8A);
  static const Color textOnAccent  = Color(0xFF1A1A1A); // نص داكن فوق الأخضر الفاتح
  static const Color textOnDark    = Color(0xFFFFFFFF); // نص أبيض فوق الداكن

  // ─── Semantic ──────────────────────────────────────────────
  static const Color success     = Color(0xFF16A34A);
  static const Color successDim  = Color(0x2016A34A);
  static const Color warning     = Color(0xFFFFD166);
  static const Color warningDim  = Color(0x20FFD166);
  static const Color danger      = Color(0xFFFF4C6A);
  static const Color dangerDim   = Color(0x20FF4C6A);
  static const Color info        = Color(0xFF4CC9F0);
  static const Color infoDim     = Color(0x204CC9F0);

  // ─── Border ────────────────────────────────────────────────
  static const Color borderSubtle = Color(0xFFEFEFEF);
  static const Color borderMedium = Color(0xFFD1D5DB);
  static const Color borderAccent = Color(0x40A8E063);

  // ─── Quick Access Cards ────────────────────────────────────
  static const Color cardNutritionBg = Color(0xFFE8F5E9);
  static const Color cardProgressBg  = Color(0xFFE3F2FD);
  static const Color cardProfileBg   = Color(0xFFFFF3E0);
  static const Color cardWorkoutBg   = Color(0xFFFCE4EC);

  // ─── Daily Goals Rings ─────────────────────────────────────
  static const Color ringMove     = Color(0xFFA8E063); // أخضر - حركة
  static const Color ringExercise = Color(0xFFFF4C6A); // أحمر - تمرين
  static const Color ringStand    = Color(0xFF4CC9F0); // أزرق - وقوف

  // ─── Muscle Groups ─────────────────────────────────────────
  static const Color muscleChest    = Color(0xFFEF4444);
  static const Color muscleBack     = Color(0xFF2563EB);
  static const Color muscleLegs     = Color(0xFF16A34A);
  static const Color muscleShoulder = Color(0xFFD97706);
  static const Color muscleArms     = Color(0xFF8B5CF6);
  static const Color muscleCore     = Color(0xFFDB2777);
  static const Color muscleCardio   = Color(0xFFA8E063);

  // ─── Levels ────────────────────────────────────────────────
  static const Color levelBeginner     = Color(0xFF16A34A);
  static const Color levelIntermediate = Color(0xFFD97706);
  static const Color levelAdvanced     = Color(0xFFDC2626);

  // ─── Legacy aliases (لا تكسر الكود القديم) ────────────────
  static const Color bghighest = Color(0xFFE5E7EB);
}
