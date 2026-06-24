import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'app_colors.dart';

abstract final class AppTypography {
  static TextStyle get display => GoogleFonts.fraunces(
        fontSize: 36,
        fontWeight: FontWeight.w700,
        color: AppColors.ink,
      ).copyWith(fontVariations: const [FontVariation('opsz', 144)]);

  static TextStyle get sectionHeader => GoogleFonts.fraunces(
        fontSize: 22,
        fontWeight: FontWeight.w600,
        color: AppColors.ink,
      );

  static TextStyle get bodyLarge => GoogleFonts.dmSans(
        fontSize: 16,
        fontWeight: FontWeight.w400,
        color: AppColors.ink,
      );

  static TextStyle get bodyMedium => GoogleFonts.dmSans(
        fontSize: 14,
        fontWeight: FontWeight.w500,
        color: AppColors.ink,
      );

  static TextStyle get dataMono => GoogleFonts.dmMono(
        fontSize: 13,
        fontWeight: FontWeight.w500,
        color: AppColors.ink,
      );

  static TextStyle get micro => GoogleFonts.dmSans(
        fontSize: 11,
        fontWeight: FontWeight.w400,
        color: AppColors.mist,
      );
}
