import 'package:flutter/material.dart';
import 'package:mobile_app/helpdesk/design_system/app_tokens.dart';

class HelpdeskTheme {
  static TextTheme _textTheme(Color main, Color secondary) => TextTheme(
        headlineLarge: const TextStyle(fontSize: 28, height: 34 / 28, fontWeight: FontWeight.w600),
        headlineMedium: const TextStyle(fontSize: 22, height: 28 / 22, fontWeight: FontWeight.w600),
        titleLarge: const TextStyle(fontSize: 18, height: 24 / 18, fontWeight: FontWeight.w600),
        bodyMedium: const TextStyle(fontSize: 15, height: 22 / 15),
        bodySmall: const TextStyle(fontSize: 13, height: 18 / 13),
        labelLarge: const TextStyle(fontSize: 14, height: 20 / 14, fontWeight: FontWeight.w500),
      ).apply(bodyColor: main, displayColor: main).copyWith(
            bodySmall: TextStyle(fontSize: 13, height: 18 / 13, color: secondary),
          );

  static ThemeData get light {
    final colorScheme = ColorScheme.fromSeed(
      seedColor: AppPalette.primary,
      primary: AppPalette.primary,
      brightness: Brightness.light,
      surface: AppPalette.surface,
      error: AppPalette.danger,
    );
    return ThemeData(
      useMaterial3: true,
      colorScheme: colorScheme,
      scaffoldBackgroundColor: AppPalette.background,
      textTheme: _textTheme(AppPalette.textPrimary, AppPalette.textSecondary),
      snackBarTheme: const SnackBarThemeData(behavior: SnackBarBehavior.floating),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppPalette.surface,
        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppTokens.radiusInput),
          borderSide: const BorderSide(color: AppPalette.border),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppTokens.radiusInput),
          borderSide: const BorderSide(color: AppPalette.border),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppTokens.radiusInput),
          borderSide: const BorderSide(color: AppPalette.primary, width: 1.4),
        ),
      ),
    );
  }

  static ThemeData get dark {
    final colorScheme = ColorScheme.fromSeed(
      seedColor: AppPalette.primary,
      primary: AppPalette.primary,
      brightness: Brightness.dark,
      surface: AppPalette.darkSurface,
      error: AppPalette.danger,
    );
    return ThemeData(
      useMaterial3: true,
      colorScheme: colorScheme,
      scaffoldBackgroundColor: AppPalette.darkBackground,
      textTheme: _textTheme(AppPalette.darkText, AppPalette.darkText2),
      snackBarTheme: const SnackBarThemeData(behavior: SnackBarBehavior.floating),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppPalette.darkSurface,
        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppTokens.radiusInput),
          borderSide: const BorderSide(color: AppPalette.darkSurfaceAlt),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppTokens.radiusInput),
          borderSide: const BorderSide(color: AppPalette.darkSurfaceAlt),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppTokens.radiusInput),
          borderSide: const BorderSide(color: AppPalette.primary, width: 1.4),
        ),
      ),
    );
  }
}
