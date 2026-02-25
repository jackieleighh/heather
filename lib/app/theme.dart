import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../core/constants/app_colors.dart';

class HeatherTheme {
  HeatherTheme._();

  static ThemeData light({Color accentColor = const Color.fromARGB(255, 199, 14, 137)}) => ThemeData(
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

  static const _subtleShadow = [
    Shadow(color: Color(0x28000000), blurRadius: 6),
  ];

  static TextTheme get _textTheme => TextTheme(
    // Temperature
    displayLarge: GoogleFonts.poppins(
      fontSize: 160,
      fontWeight: FontWeight.w700,
      color: AppColors.cream,
      height: 1.0,
      shadows: _subtleShadow,
    ),
    // Loading title
    displayMedium: GoogleFonts.poppins(
      fontSize: 48,
      fontWeight: FontWeight.w600,
      color: AppColors.cream,
      shadows: _subtleShadow,
    ),
    // °F suffix
    headlineLarge: GoogleFonts.poppins(
      fontSize: 42,
      fontWeight: FontWeight.w500,
      color: AppColors.cream,
      shadows: _subtleShadow,
    ),
    // City name
    headlineMedium: GoogleFonts.poppins(
      fontSize: 18,
      fontWeight: FontWeight.w500,
      color: AppColors.cream,
      shadows: _subtleShadow,
    ),
    // Loading tagline
    headlineSmall: GoogleFonts.poppins(
      fontSize: 14,
      fontWeight: FontWeight.w500,
      color: AppColors.cream,
      shadows: _subtleShadow,
    ),
    // Body
    bodyLarge: GoogleFonts.inter(
      fontSize: 20,
      fontWeight: FontWeight.w400,
      color: AppColors.cream,
      shadows: _subtleShadow,
    ),
    bodyMedium: GoogleFonts.inter(
      fontSize: 18,
      fontWeight: FontWeight.w400,
      color: AppColors.cream,
      shadows: _subtleShadow,
    ),
    // Meta details
    bodySmall: GoogleFonts.inter(
      fontSize: 18,
      fontWeight: FontWeight.w400,
      color: AppColors.cream,
      shadows: _subtleShadow,
    ),
    // Quip — no italics, slightly spaced
    labelLarge: GoogleFonts.poppins(
      fontSize: 30,
      fontWeight: FontWeight.w700,
      letterSpacing: 0.3,
      color: AppColors.cream,
      shadows: _subtleShadow,
    ),
  );
}
