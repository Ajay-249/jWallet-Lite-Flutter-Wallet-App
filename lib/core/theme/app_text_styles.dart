import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'app_colors.dart';

class AppTextStyles {
  // Editorial Serif Headlines (EB Garamond)
  static TextStyle headlineSerif({
    double fontSize = 28,
    FontWeight fontWeight = FontWeight.w600,
    Color color = AppColors.onSurface,
    double? height,
  }) {
    return GoogleFonts.ebGaramond(
      fontSize: fontSize,
      fontWeight: fontWeight,
      color: color,
      height: height,
    );
  }

  // Modern Clean Body & UI text (Manrope)
  static TextStyle bodySans({
    double fontSize = 14,
    FontWeight fontWeight = FontWeight.normal,
    Color color = AppColors.onSurface,
    double? height,
    double? letterSpacing,
    TextDecoration? decoration,
  }) {
    return GoogleFonts.manrope(
      fontSize: fontSize,
      fontWeight: fontWeight,
      color: color,
      height: height,
      letterSpacing: letterSpacing,
      decoration: decoration,
    );
  }

  // Currency / Numerical Balance font (EB Garamond or Manrope with high readability)
  static TextStyle balanceSerif({
    double fontSize = 34,
    FontWeight fontWeight = FontWeight.bold,
    Color color = AppColors.onSurface,
  }) {
    return GoogleFonts.ebGaramond(
      fontSize: fontSize,
      fontWeight: fontWeight,
      color: color,
      letterSpacing: -0.5,
    );
  }

  // Subtitle / Label text
  static TextStyle label({
    double fontSize = 12,
    FontWeight fontWeight = FontWeight.w600,
    Color color = AppColors.onSurfaceVariant,
    double? letterSpacing = 0.5,
  }) {
    return GoogleFonts.manrope(
      fontSize: fontSize,
      fontWeight: fontWeight,
      color: color,
      letterSpacing: letterSpacing,
    );
  }

  // Button text
  static TextStyle button({
    double fontSize = 15,
    FontWeight fontWeight = FontWeight.w600,
    Color color = Colors.white,
  }) {
    return GoogleFonts.manrope(
      fontSize: fontSize,
      fontWeight: fontWeight,
      color: color,
      letterSpacing: 0.3,
    );
  }
}
