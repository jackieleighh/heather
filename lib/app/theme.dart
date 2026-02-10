import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../core/constants/app_colors.dart';

class HeatherTheme {
  HeatherTheme._();

  static ThemeData get light => ThemeData(
    useMaterial3: true,
    colorScheme: ColorScheme.fromSeed(
      seedColor: AppColors.vibrantPurple,
      brightness: Brightness.light,
      primary: AppColors.vibrantPurple,
      secondary: AppColors.magenta,
      surface: AppColors.cream,
    ),
    textTheme: _textTheme,
    scaffoldBackgroundColor: Colors.transparent,
  );

  static TextTheme get _textTheme => TextTheme(
    // Temperature
    displayLarge: GoogleFonts.poppins(
      fontSize: 160,
      fontWeight: FontWeight.w700,
      color: Colors.black,
      height: 1.0,
    ),
    // Loading title
    displayMedium: GoogleFonts.poppins(
      fontSize: 48,
      fontWeight: FontWeight.w600,
      color: Colors.black,
    ),
    // °F suffix
    headlineLarge: GoogleFonts.poppins(
      fontSize: 42,
      fontWeight: FontWeight.w500,
      color: Colors.black,
    ),
    // City name
    headlineMedium: GoogleFonts.poppins(
      fontSize: 18,
      fontWeight: FontWeight.w500,
      color: Colors.black,
    ),
    // Body
    bodyLarge: GoogleFonts.inter(
      fontSize: 20,
      fontWeight: FontWeight.w400,
      color: Colors.black,
    ),
    bodyMedium: GoogleFonts.inter(
      fontSize: 18,
      fontWeight: FontWeight.w400,
      color: Colors.black,
    ),
    // Meta details
    bodySmall: GoogleFonts.inter(
      fontSize: 18,
      fontWeight: FontWeight.w400,
      color: Colors.black,
    ),
    // Quip — no italics, slightly spaced
    labelLarge: GoogleFonts.poppins(
      fontSize: 40,
      fontWeight: FontWeight.w700,
      letterSpacing: 0.3,
      color: Colors.black,
    ),
  );
}
