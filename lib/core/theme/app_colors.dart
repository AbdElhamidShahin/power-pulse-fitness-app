import 'package:flutter/material.dart';

/// Power Pulse — App Colors
/// Dark Theme: أسود + أخضر ليموني
abstract class AppColors {
  AppColors._();

  // ─── Backgrounds ───────────────────────────────────────────
  static const Color bgDeep     = Color(0xFF111113); // خلفية الشاشة الأساسية
  static const Color bgSurface  = Color(0xFF1C1C1E); // خلفية الـ cards
  static const Color bgElevated = Color(0xFF2C2C2E); // عناصر مرتفعة - inputs - tabs
  static const Color bgHighest  = Color(0xFF3A3A3C); // progress bars - dividers

  // ─── Accent ────────────────────────────────────────────────
  static const Color accent        = Color(0xFFBFFF00); // أخضر ليموني — اللون الأساسي
  static const Color accentDim     = Color(0x26BFFF00); // accent شفاف 15%
  static const Color accentPressed = Color(0xFFAAE600); // عند الضغط

  // ─── Text ──────────────────────────────────────────────────
  static const Color textPrimary   = Color(0xFFF5F5F5); // نصوص رئيسية
  static const Color textSecondary = Color(0xFFAAAAAA); // نصوص ثانوية
  static const Color textMuted     = Color(0xFF666666); // نصوص خافتة
  static const Color textOnAccent  = Color(0xFF111113); // نص فوق اللون الأخضر

  // ─── Semantic ──────────────────────────────────────────────
  static const Color success     = Color(0xFF10B981); // نجاح
  static const Color successDim  = Color(0x2010B981);
  static const Color warning     = Color(0xFFF59E0B); // تحذير - مستوى متوسط
  static const Color warningDim  = Color(0x20F59E0B);
  static const Color danger      = Color(0xFFEF4444); // خطر - مستوى متقدم
  static const Color dangerDim   = Color(0x20EF4444);
  static const Color info        = Color(0xFF3B82F6); // معلومة

  // ─── Border ────────────────────────────────────────────────
  static const Color borderSubtle = Color(0xFF2C2C2E);
  static const Color borderMedium = Color(0xFF3A3A3C);
  static const Color borderAccent = Color(0x40BFFF00); // border أخضر شفاف

  // ─── Muscle Group Colors ───────────────────────────────────
  static const Color muscleChest    = Color(0xFFEF4444);
  static const Color muscleBack     = Color(0xFF3B82F6);
  static const Color muscleLegs     = Color(0xFF10B981);
  static const Color muscleShoulder = Color(0xFFF59E0B);
  static const Color muscleArms     = Color(0xFFA78BFA);
  static const Color muscleCore     = Color(0xFFEC4899);
  static const Color muscleCardio   = Color(0xFFBFFF00);

  // ─── Level Colors ──────────────────────────────────────────
  static const Color levelBeginner     = Color(0xFF10B981);
  static const Color levelIntermediate = Color(0xFFF59E0B);
  static const Color levelAdvanced     = Color(0xFFEF4444);

  // ─── Extra — Home UI + Workout Logger ──────────────────────
  static const Color infoDim      = Color(0x203B82F6);
  static const Color bghighest    = Color(0xFF3A3A3C);
}