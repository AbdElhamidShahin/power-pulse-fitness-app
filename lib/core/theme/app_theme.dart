import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'app_colors.dart';
import 'app_text_styles.dart';
import '../constants/app_constants.dart';

abstract class AppTheme {
  AppTheme._();

  static ThemeData get light => ThemeData(
    useMaterial3: true,
    brightness: Brightness.light,
    fontFamily: 'Cairo',
    colorScheme: const ColorScheme.light(
      brightness: Brightness.light,
      primary: AppColors.accent,
      onPrimary: AppColors.textOnAccent,
      secondary: AppColors.accent,
      onSecondary: AppColors.textOnAccent,
      surface: AppColors.bgSurface,
      onSurface: AppColors.textPrimary,
      error: AppColors.danger,
      onError: AppColors.textOnDark,
    ),
    scaffoldBackgroundColor: AppColors.bgDeep,
    appBarTheme: const AppBarTheme(
      backgroundColor: AppColors.bgDeep,
      foregroundColor: AppColors.textPrimary,
      elevation: 0,
      scrolledUnderElevation: 0,
      centerTitle: false,
      titleTextStyle: AppTextStyles.headlineLarge,
      systemOverlayStyle: SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.dark,
        statusBarBrightness: Brightness.light,
      ),
    ),
    bottomNavigationBarTheme: const BottomNavigationBarThemeData(
      backgroundColor: AppColors.bgSurface,
      selectedItemColor: AppColors.textPrimary,
      unselectedItemColor: AppColors.textMuted,
      type: BottomNavigationBarType.fixed,
      elevation: 0,
      selectedLabelStyle: AppTextStyles.labelSmall,
      unselectedLabelStyle: AppTextStyles.labelSmall,
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: AppColors.bgDark,
        foregroundColor: AppColors.textOnDark,
        minimumSize:
        const Size(double.infinity, AppConstants.buttonHeightLarge),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppConstants.radiusM),
        ),
        textStyle: AppTextStyles.labelLarge,
        elevation: 0,
      ),
    ),
    // ─── Input Decoration Theme (Light) ───────────────────────────────
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: AppColors.bgElevated,
      contentPadding: const EdgeInsets.symmetric(
        horizontal: AppConstants.spaceL,
        vertical: AppConstants.spaceM,
      ),
      hintStyle: AppTextStyles.bodyMedium.copyWith(
        color: AppColors.textMuted,
      ),
      // Suffix/Prefix text style
      suffixStyle: AppTextStyles.bodyMedium.copyWith(
        color: AppColors.textMuted,
      ),
      prefixStyle: AppTextStyles.bodyMedium.copyWith(
        color: AppColors.textMuted,
      ),
      // Borders
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(AppConstants.radiusM),
        borderSide: const BorderSide(color: AppColors.borderSubtle, width: 1),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(AppConstants.radiusM),
        borderSide: const BorderSide(color: AppColors.borderSubtle, width: 1),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(AppConstants.radiusM),
        borderSide: const BorderSide(color: AppColors.accent, width: 1.5),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(AppConstants.radiusM),
        borderSide: const BorderSide(color: AppColors.danger, width: 1),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(AppConstants.radiusM),
        borderSide: const BorderSide(color: AppColors.danger, width: 1.5),
      ),
      disabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(AppConstants.radiusM),
        borderSide: const BorderSide(color: AppColors.borderSubtle, width: 1),
      ),
    ),
  );

  // ─── Dark Theme ───────────────────────────────────────────────────
  static ThemeData get dark => ThemeData(
    useMaterial3: true,
    brightness: Brightness.dark,
    fontFamily: 'Cairo',
    colorScheme: const ColorScheme.dark(
      brightness: Brightness.dark,
      primary: AppColors.accent,
      onPrimary: AppColors.textOnAccent,
      secondary: AppColors.accent,
      onSecondary: AppColors.textOnAccent,
      surface: AppColorsDark.bgSurface,
      onSurface: AppColorsDark.textPrimary,
      error: AppColors.danger,
      onError: AppColors.textOnDark,
    ),
    scaffoldBackgroundColor: AppColorsDark.bgDeep,
    cardColor: AppColorsDark.bgSurface,
    dividerColor: AppColorsDark.borderSubtle,
    appBarTheme: const AppBarTheme(
      backgroundColor: AppColorsDark.bgDeep,
      foregroundColor: AppColorsDark.textPrimary,
      elevation: 0,
      scrolledUnderElevation: 0,
      centerTitle: false,
      systemOverlayStyle: SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.light,
        statusBarBrightness: Brightness.dark,
      ),
    ),
    bottomNavigationBarTheme: const BottomNavigationBarThemeData(
      backgroundColor: AppColorsDark.bgSurface,
      selectedItemColor: AppColors.accent,
      unselectedItemColor: AppColorsDark.textMuted,
      type: BottomNavigationBarType.fixed,
      elevation: 0,
      selectedLabelStyle: AppTextStyles.labelSmall,
      unselectedLabelStyle: AppTextStyles.labelSmall,
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: AppColors.accent,
        foregroundColor: AppColors.textOnAccent,
        minimumSize:
        const Size(double.infinity, AppConstants.buttonHeightLarge),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppConstants.radiusM),
        ),
        textStyle: AppTextStyles.labelLarge,
        elevation: 0,
      ),
    ),
    // ─── Input Decoration Theme (Dark) ───────────────────────────────
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: AppColorsDark.bgElevated,
      contentPadding: const EdgeInsets.symmetric(
        horizontal: AppConstants.spaceL,
        vertical: AppConstants.spaceM,
      ),
      hintStyle: AppTextStyles.bodyMedium.copyWith(
        color: AppColorsDark.textMuted,
      ),
      suffixStyle: AppTextStyles.bodyMedium.copyWith(
        color: AppColorsDark.textMuted,
      ),
      prefixStyle: AppTextStyles.bodyMedium.copyWith(
        color: AppColorsDark.textMuted,
      ),
      // Borders
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(AppConstants.radiusM),
        borderSide: const BorderSide(color: AppColorsDark.borderSubtle, width: 1),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(AppConstants.radiusM),
        borderSide: const BorderSide(color: AppColorsDark.borderSubtle, width: 1),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(AppConstants.radiusM),
        borderSide: const BorderSide(color: AppColors.accent, width: 1.5),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(AppConstants.radiusM),
        borderSide: const BorderSide(color: AppColors.danger, width: 1),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(AppConstants.radiusM),
        borderSide: const BorderSide(color: AppColors.danger, width: 1.5),
      ),
      disabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(AppConstants.radiusM),
        borderSide: const BorderSide(color: AppColorsDark.borderSubtle, width: 1),
      ),
    ),
  );
}

// ─── Dark Mode Colors ──────────────────────────────────────────────
abstract class AppColorsDark {
  AppColorsDark._();

  static const Color bgDeep     = Color(0xFF0D0D0D);
  static const Color bgSurface  = Color(0xFF1A1A1A);
  static const Color bgElevated = Color(0xFF242424);
  static const Color bgHighest  = Color(0xFF2E2E2E);

  static const Color textPrimary   = Color(0xFFF5F5F0);
  static const Color textSecondary = Color(0xFFB0B0B0);
  static const Color textMuted     = Color(0xFF6B6B6B);

  static const Color borderSubtle = Color(0xFF2A2A2A);
  static const Color borderMedium = Color(0xFF3A3A3A);
}
