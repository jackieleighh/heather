import 'package:flutter/material.dart';

import '../core/constants/app_colors.dart';

class HeatherTheme {
  HeatherTheme._();

  static ThemeData light({
    Color accentColor = const Color.fromARGB(255, 199, 14, 137),
  }) => ThemeData(
    useMaterial3: true,
    colorScheme: ColorScheme.fromSeed(
      seedColor: accentColor,
      brightness: Brightness.light,
      primary: accentColor,
      secondary: accentColor,
      surface: AppColors.cream,
    ),
    textTheme: _textTheme,
    scaffoldBackgroundColor: Colors.transparent,
  );

  static const _textTheme = TextTheme(
    // Temperature
    displayLarge: TextStyle(fontFamily: 'Poppins',
      fontSize: 160,
      fontWeight: FontWeight.w700,
      color: AppColors.cream,
      height: 1.0,
    ),
    // Loading title
    displayMedium: TextStyle(fontFamily: 'Poppins',
      fontSize: 48,
      fontWeight: FontWeight.w600,
      color: AppColors.cream,
    ),
    // °F suffix
    headlineLarge: TextStyle(fontFamily: 'Poppins',
      fontSize: 42,
      fontWeight: FontWeight.w500,
      color: AppColors.cream,
    ),
    // City name
    headlineMedium: TextStyle(fontFamily: 'Poppins',
      fontSize: 18,
      fontWeight: FontWeight.w500,
      color: AppColors.cream,
    ),
    // Loading tagline
    headlineSmall: TextStyle(fontFamily: 'Poppins',
      fontSize: 14,
      fontWeight: FontWeight.w500,
      color: AppColors.cream,
    ),
    // Body
    bodyLarge: TextStyle(fontFamily: 'Figtree',
      fontSize: 20,
      fontWeight: FontWeight.w400,
      color: AppColors.cream,
    ),
    bodyMedium: TextStyle(fontFamily: 'Figtree',
      fontSize: 18,
      fontWeight: FontWeight.w400,
      color: AppColors.cream,
    ),
    // Meta details
    bodySmall: TextStyle(fontFamily: 'Figtree',
      fontSize: 18,
      fontWeight: FontWeight.w400,
      color: AppColors.cream,
    ),
    // Quip — no italics, slightly spaced
    labelLarge: TextStyle(fontFamily: 'Poppins',
      fontSize: 30,
      fontWeight: FontWeight.w700,
      letterSpacing: 0.3,
      color: AppColors.cream,
    ),
  );
}
