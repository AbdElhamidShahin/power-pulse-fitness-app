import 'package:flutter/material.dart';

abstract class AppColors {
  AppColors._();

  static const Color bgDeep     = Color(0xFFF5F5F0); // خلفية الشاشة الأساسية
  static const Color bgSurface  = Color(0xFFFFFFFF); // خلفية الـ cards
  static const Color bgElevated = Color(0xFFEFEFEF); // inputs - tabs - elevated
  static const Color bgHighest  = Color(0xFFE8E8E8); // progress bars - dividers

  // ─── Dark Surface (للـ cards الداكنة) ──────────────────────
  static const Color bgDark     = Color(0xFF1A1A1A); // card داكنة
  static const Color bgDarkAlt  = Color(0xFF2A2A2A); // card داكنة ثانوية

  // ─── Accent ────────────────────────────────────────────────
  static const Color accent        = Color(0xFFA8E063); // أخضر التصميم الجديد
  static const Color accentDim     = Color(0x26A8E063);
  static const Color accentPressed = Color(0xFF8CC844);

  // ─── Text ──────────────────────────────────────────────────
  static const Color textPrimary   = Color(0xFF1A1A1A);
  static const Color textSecondary = Color(0xFF4B5563);
  static const Color textMuted     = Color(0xFF8A8A8A);
  static const Color textOnAccent  = Color(0xFF1A1A1A);
  static const Color textOnDark    = Color(0xFFFFFFFF);

  // ─── Semantic ──────────────────────────────────────────────
  static const Color success    = Color(0xFF16A34A);
  static const Color successDim = Color(0x2016A34A);
  static const Color warning    = Color(0xFFFFD166);
  static const Color warningDim = Color(0x20FFD166);
  static const Color danger     = Color(0xFFFF4C6A);
  static const Color dangerDim  = Color(0x20FF4C6A);
  static const Color info       = Color(0xFF4CC9F0);
  static const Color infoDim    = Color(0x204CC9F0);

  // ─── Border ────────────────────────────────────────────────
  static const Color borderSubtle = Color(0xFFE8E8E8);
  static const Color borderMedium = Color(0xFFD1D5DB);
  static const Color borderAccent = Color(0x40A8E063);

  // ─── Muscle Group Colors ───────────────────────────────────
  static const Color muscleChest    = Color(0xFFFF4C6A);
  static const Color muscleBack     = Color(0xFF4CC9F0);
  static const Color muscleLegs     = Color(0xFFA8E063);
  static const Color muscleShoulder = Color(0xFFFFD166);
  static const Color muscleArms    = Color(0xFF8B5CF6);
  static const Color muscleCore    = Color(0xFFDB2777);
  static const Color muscleCardio  = Color(0xFFA8E063);

  // ─── Level Colors ──────────────────────────────────────────
  static const Color levelBeginner     = Color(0xFF16A34A);
  static const Color levelIntermediate = Color(0xFFFFD166);
  static const Color levelAdvanced     = Color(0xFFFF4C6A);

  // ─── Extra ─────────────────────────────────────────────────
  static const Color bghighest = Color(0xFFE8E8E8);
}
