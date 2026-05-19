import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'app_colors.dart';
import 'app_text_styles.dart';

/// Centralises the ThemeData that was previously inlined inside main.dart's
/// MaterialApp builder.
class AppTheme {
  AppTheme._();

  static ThemeData get light {
    return ThemeData(
      scaffoldBackgroundColor: AppColors.scaffoldBackground,

      textTheme: GoogleFonts.changaTextTheme(
        ThemeData.light().textTheme.apply(
              bodyColor: AppColors.textWhite,
              displayColor: AppColors.textWhite,
            ),
      ),

      appBarTheme: const AppBarTheme(
        backgroundColor: AppColors.scaffoldBackground,
        iconTheme: IconThemeData(color: Colors.black),
        elevation: 0.0,
        titleTextStyle: AppTextStyles.appBarThemeTitle,
      ),

      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        backgroundColor: AppColors.scaffoldBackground,
        unselectedItemColor: AppColors.textWhite,
        selectedItemColor: AppColors.primary,
        type: BottomNavigationBarType.fixed,
      ),
    );
  }
}
