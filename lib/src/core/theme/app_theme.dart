import 'package:flutter/material.dart';
import 'app_colors.dart';
import 'app_dimens.dart';

class AppTheme {
  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      fontFamily: 'Nunito',
      scaffoldBackgroundColor: AppColors.background,

      // Map our colors to Material Scheme
      colorScheme: ColorScheme.fromSeed(
        seedColor: AppColors.primaryBrand,
        primary: AppColors.primaryBrand,
        secondary: AppColors.accentFun,
        surface: AppColors.surface,
      ),

      // Default Card Style
      cardTheme: const CardThemeData(
        elevation: 0, // Flat look is modern
        color: AppColors.surface,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(AppRadius.card)),
        ),
      ),

      // Default Text Style overrides
      textTheme: const TextTheme(
        headlineLarge: TextStyle(
          fontFamily: 'Fredoka',
          fontSize: 32,
          fontWeight: FontWeight.bold,
          color: AppColors.textMain,
        ),
        titleLarge: TextStyle(
          fontFamily: 'Fredoka',
          fontSize: 22,
          fontWeight: FontWeight.bold,
          color: AppColors.textMain,
        ),
        titleMedium: TextStyle(
          fontFamily: 'Fredoka',
          fontSize: 18,
          fontWeight: FontWeight.w600,
          color: AppColors.textMain,
        ),
        bodyMedium: TextStyle(fontSize: 16, color: AppColors.textMain),
      ),
    );
  }
}
