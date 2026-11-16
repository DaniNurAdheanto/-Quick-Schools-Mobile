import 'package:flutter/material.dart';
import '../constants/app_colors.dart';

class AppTheme {
  static const String fontFamily = 'Geist';

  static ThemeData get lightTheme {
    const textTheme = TextTheme(
      displayLarge: TextStyle(
        fontFamily: fontFamily,
        color: AppColors.textPrimaryLight,
        fontWeight: FontWeight.w800,
        letterSpacing: -0.5,
      ),
      titleLarge: TextStyle(
        fontFamily: fontFamily,
        color: AppColors.textPrimaryLight,
        fontWeight: FontWeight.w700,
        fontSize: 20,
      ),
      titleMedium: TextStyle(
        fontFamily: fontFamily,
        color: AppColors.textPrimaryLight,
        fontWeight: FontWeight.w600,
        fontSize: 16,
      ),
      bodyLarge: TextStyle(
        fontFamily: fontFamily,
        color: AppColors.textPrimaryLight,
        fontSize: 16,
      ),
      bodyMedium: TextStyle(
        fontFamily: fontFamily,
        color: AppColors.textSecondaryLight,
        fontSize: 14,
      ),
      bodySmall: TextStyle(
        fontFamily: fontFamily,
        color: AppColors.textMutedLight,
        fontSize: 12,
      ),
    );

    return ThemeData(
      useMaterial3: true,
      fontFamily: fontFamily,
      brightness: Brightness.light,
      primaryColor: AppColors.primary,
      scaffoldBackgroundColor: AppColors.backgroundLight,
      colorScheme: const ColorScheme.light(
        primary: AppColors.primary,
        onPrimary: Colors.white,
        secondary: AppColors.primaryLight,
        onSecondary: Colors.white,
        surface: AppColors.surfaceLight,
        onSurface: AppColors.textPrimaryLight,
        error: AppColors.danger,
        onError: Colors.white,
      ),
      textTheme: textTheme,
      appBarTheme: const AppBarTheme(
        elevation: 0,
        centerTitle: false,
        backgroundColor: AppColors.surfaceLight,
        foregroundColor: AppColors.textPrimaryLight,
        titleTextStyle: TextStyle(
          fontFamily: fontFamily,
          fontSize: 18,
          fontWeight: FontWeight.w700,
          color: AppColors.textPrimaryLight,
        ),
      ),
      cardTheme: CardThemeData(
        elevation: 0,
        color: AppColors.surfaceLight,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: const BorderSide(color: AppColors.borderLight, width: 1),
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primary,
          foregroundColor: Colors.white,
          elevation: 0,
          minimumSize: const Size.fromHeight(50),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          textStyle: const TextStyle(
            fontFamily: fontFamily,
            fontSize: 15,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: Colors.white,
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.borderLight),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.borderLight),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.primary, width: 2),
        ),
        hintStyle: const TextStyle(
          fontFamily: fontFamily,
          color: AppColors.textMutedLight,
          fontSize: 14,
        ),
      ),
    );
  }

  static ThemeData get darkTheme {
    return ThemeData(
      useMaterial3: true,
      fontFamily: fontFamily,
      brightness: Brightness.dark,
      primaryColor: AppColors.primary,
      scaffoldBackgroundColor: AppColors.backgroundDark,
      colorScheme: const ColorScheme.dark(
        primary: AppColors.primaryLight,
        onPrimary: Colors.white,
        surface: AppColors.surfaceDark,
        onSurface: AppColors.textPrimaryDark,
      ),
      cardTheme: CardThemeData(
        elevation: 0,
        color: AppColors.surfaceDark,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: const BorderSide(color: AppColors.borderDark, width: 1),
        ),
      ),
    );
  }
}
