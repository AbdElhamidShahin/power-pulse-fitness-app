import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'app_colors.dart';
import 'app_text_styles.dart';
import '../constants/constants.dart';

/// Power Pulse — App Theme
/// Dark Mode فقط — Cairo Font
abstract class AppTheme {
  AppTheme._();

  static ThemeData get dark => ThemeData(
        useMaterial3: true,
        brightness: Brightness.dark,
        fontFamily: 'Cairo',

        // ─── Colors ──────────────────────────────────────────
        colorScheme: const ColorScheme.dark(
          brightness: Brightness.dark,
          primary: AppColors.accent,
          onPrimary: AppColors.textOnAccent,
          secondary: AppColors.accent,
          onSecondary: AppColors.textOnAccent,
          surface: AppColors.bgSurface,
          onSurface: AppColors.textPrimary,
          error: AppColors.danger,
          onError: AppColors.textPrimary,
        ),

        scaffoldBackgroundColor: AppColors.bgDeep,

        // ─── AppBar ──────────────────────────────────────────
        appBarTheme: const AppBarTheme(
          backgroundColor: AppColors.bgDeep,
          foregroundColor: AppColors.textPrimary,
          elevation: 0,
          scrolledUnderElevation: 0,
          centerTitle: false,
          titleTextStyle: AppTextStyles.headlineLarge,
          systemOverlayStyle: SystemUiOverlayStyle(
            statusBarColor: Colors.transparent,
            statusBarIconBrightness: Brightness.light,
            statusBarBrightness: Brightness.dark,
          ),
        ),

        // ─── BottomNavigationBar ─────────────────────────────
        bottomNavigationBarTheme: const BottomNavigationBarThemeData(
          backgroundColor: AppColors.bgSurface,
          selectedItemColor: AppColors.accent,
          unselectedItemColor: AppColors.textMuted,
          type: BottomNavigationBarType.fixed,
          elevation: 0,
          selectedLabelStyle: AppTextStyles.labelSmall,
          unselectedLabelStyle: AppTextStyles.labelSmall,
        ),

        // ─── ElevatedButton ──────────────────────────────────
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.accent,
            foregroundColor: AppColors.textOnAccent,
            minimumSize: const Size(double.infinity, UiConstants.buttonHeightLarge),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(UiConstants.radiusM),
            ),
            textStyle: AppTextStyles.labelLarge,
            elevation: 0,
          ),
        ),

        // ─── OutlinedButton ──────────────────────────────────
        outlinedButtonTheme: OutlinedButtonThemeData(
          style: OutlinedButton.styleFrom(
            foregroundColor: AppColors.accent,
            minimumSize: const Size(double.infinity, UiConstants.buttonHeightLarge),
            side: const BorderSide(color: AppColors.accent, width: 1.5),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(UiConstants.radiusM),
            ),
            textStyle: AppTextStyles.labelLarge,
          ),
        ),

        // ─── TextButton ──────────────────────────────────────
        textButtonTheme: TextButtonThemeData(
          style: TextButton.styleFrom(
            foregroundColor: AppColors.accent,
            textStyle: AppTextStyles.labelMedium,
          ),
        ),

        // ─── InputDecoration ─────────────────────────────────
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: AppColors.bgElevated,
          hintStyle: AppTextStyles.bodyMedium.copyWith(color: AppColors.textMuted),
          contentPadding: const EdgeInsets.symmetric(
            horizontal: UiConstants.spaceL,
            vertical: UiConstants.spaceM,
          ),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(UiConstants.radiusM),
            borderSide: const BorderSide(color: AppColors.borderSubtle),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(UiConstants.radiusM),
            borderSide: const BorderSide(color: AppColors.borderSubtle),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(UiConstants.radiusM),
            borderSide: const BorderSide(color: AppColors.accent, width: 1.5),
          ),
          errorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(UiConstants.radiusM),
            borderSide: const BorderSide(color: AppColors.danger),
          ),
        ),

        // ─── Card ────────────────────────────────────────────
        cardTheme: CardThemeData(
          color: AppColors.bgSurface,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(UiConstants.radiusL),
            side: const BorderSide(color: AppColors.borderSubtle),
          ),
          margin: EdgeInsets.zero,
        ),

        // ─── Chip ────────────────────────────────────────────
        chipTheme: ChipThemeData(
          backgroundColor: AppColors.bgElevated,
          labelStyle: AppTextStyles.labelMedium,
          selectedColor: AppColors.accentDim,
          side: const BorderSide(color: AppColors.borderSubtle),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(UiConstants.radiusPill),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
        ),

        // ─── Divider ─────────────────────────────────────────
        dividerTheme: const DividerThemeData(
          color: AppColors.borderSubtle,
          thickness: 0.5,
          space: 0,
        ),

        // ─── ProgressIndicator ───────────────────────────────
        progressIndicatorTheme: const ProgressIndicatorThemeData(
          color: AppColors.accent,
          linearTrackColor: AppColors.bgElevated,
        ),

        // ─── Slider ──────────────────────────────────────────
        sliderTheme: const SliderThemeData(
          activeTrackColor: AppColors.accent,
          inactiveTrackColor: AppColors.bgElevated,
          thumbColor: AppColors.accent,
        ),

        // ─── Switch ──────────────────────────────────────────
        switchTheme: SwitchThemeData(
          thumbColor: WidgetStateProperty.resolveWith(
            (s) => s.contains(WidgetState.selected) ? AppColors.textOnAccent : AppColors.textMuted,
          ),
          trackColor: WidgetStateProperty.resolveWith(
            (s) => s.contains(WidgetState.selected) ? AppColors.accent : AppColors.bgElevated,
          ),
        ),

        // ─── SnackBar ────────────────────────────────────────
        snackBarTheme: SnackBarThemeData(
          backgroundColor: AppColors.bgElevated,
          contentTextStyle: AppTextStyles.bodyMedium,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(UiConstants.radiusM),
          ),
          behavior: SnackBarBehavior.floating,
        ),

        // ─── Text ────────────────────────────────────────────
        textTheme: const TextTheme(
          displayLarge:   AppTextStyles.displayLarge,
          displayMedium:  AppTextStyles.displayMedium,
          headlineLarge:  AppTextStyles.headlineLarge,
          headlineMedium: AppTextStyles.headlineMedium,
          headlineSmall:  AppTextStyles.headlineSmall,
          titleLarge:     AppTextStyles.titleLarge,
          titleMedium:    AppTextStyles.titleMedium,
          titleSmall:     AppTextStyles.titleSmall,
          bodyLarge:      AppTextStyles.bodyLarge,
          bodyMedium:     AppTextStyles.bodyMedium,
          bodySmall:      AppTextStyles.bodySmall,
          labelLarge:     AppTextStyles.labelLarge,
          labelMedium:    AppTextStyles.labelMedium,
          labelSmall:     AppTextStyles.labelSmall,
        ),
      );
}
