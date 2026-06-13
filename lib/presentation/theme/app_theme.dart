import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'app_colors.dart';
import 'app_typography.dart';

abstract final class AppTheme {
  static ThemeData get light => ThemeData(
        useMaterial3: true,
        colorScheme: const ColorScheme(
          brightness: Brightness.light,
          primary: AppColors.sageDeep,
          onPrimary: AppColors.creamWarm,
          secondary: AppColors.sageMid,
          onSecondary: AppColors.creamWarm,
          tertiary: AppColors.amberAccent,
          onTertiary: Colors.white,
          surface: AppColors.creamWarm,
          onSurface: AppColors.ink,
          error: Color(0xFFE53935),
          onError: Colors.white,
          outline: AppColors.mist,
        ),
        scaffoldBackgroundColor: AppColors.creamWarm,
        textTheme: GoogleFonts.dmSansTextTheme().copyWith(
          displayLarge: AppTypography.display,
          titleLarge: AppTypography.sectionHeader,
          bodyLarge: AppTypography.bodyLarge,
          bodyMedium: AppTypography.bodyMedium,
          bodySmall: AppTypography.micro,
          labelMedium: AppTypography.dataMono,
        ),
        appBarTheme: AppBarTheme(
          backgroundColor: AppColors.sageDeep,
          foregroundColor: AppColors.creamWarm,
          elevation: 0,
          titleTextStyle: AppTypography.sectionHeader.copyWith(
            color: AppColors.creamWarm,
          ),
        ),
        cardTheme: CardThemeData(
          color: AppColors.blushSoft,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
            side: const BorderSide(color: AppColors.mist),
          ),
        ),
        floatingActionButtonTheme: const FloatingActionButtonThemeData(
          backgroundColor: AppColors.amberAccent,
          foregroundColor: Colors.white,
        ),
        dividerColor: AppColors.mist,
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: AppColors.blushSoft,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: const BorderSide(color: AppColors.mist),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: const BorderSide(color: AppColors.mist),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: const BorderSide(color: AppColors.sageMid, width: 2),
          ),
        ),
      );
}
