import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'app_colors.dart';

class AppTheme {
  static ThemeData get lightTheme {
    final base = ThemeData.light();
    return base.copyWith(
      scaffoldBackgroundColor: AppColors.lightBgMain,
      primaryColor: AppColors.lightPrimary,
      colorScheme: const ColorScheme.light(
        primary: AppColors.lightPrimary,
        secondary: AppColors.lightSecondary,
        surface: AppColors.lightBgSurface,
        error: AppColors.accentRed,
        onPrimary: Colors.white,
        onSecondary: Colors.white,
        onSurface: AppColors.lightTextMain,
        onError: Colors.white,
      ),
      textTheme: GoogleFonts.interTextTheme(base.textTheme).copyWith(
        displayLarge: GoogleFonts.inter(color: AppColors.lightTextMain, fontWeight: FontWeight.w600, letterSpacing: -0.02),
        displayMedium: GoogleFonts.inter(color: AppColors.lightTextMain, fontWeight: FontWeight.w600, letterSpacing: -0.02),
        displaySmall: GoogleFonts.inter(color: AppColors.lightTextMain, fontWeight: FontWeight.w600, letterSpacing: -0.02),
        headlineMedium: GoogleFonts.inter(color: AppColors.lightTextMain, fontWeight: FontWeight.w600, letterSpacing: -0.02),
        headlineSmall: GoogleFonts.inter(color: AppColors.lightTextMain, fontWeight: FontWeight.w600, letterSpacing: -0.02),
        titleLarge: GoogleFonts.inter(color: AppColors.lightTextMain, fontWeight: FontWeight.w600, letterSpacing: -0.01),
        bodyLarge: GoogleFonts.inter(color: AppColors.lightTextMain, fontWeight: FontWeight.w400),
        bodyMedium: GoogleFonts.inter(color: AppColors.lightTextMain, fontWeight: FontWeight.w400),
        labelLarge: GoogleFonts.inter(color: AppColors.lightTextMain, fontWeight: FontWeight.w500),
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: AppColors.lightBgSurface,
        foregroundColor: AppColors.lightTextMain,
        elevation: 0,
        centerTitle: false,
      ),
      cardTheme: CardThemeData(
        color: AppColors.lightBgSurface,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: const BorderSide(color: AppColors.lightBorderColor),
        ),
        margin: EdgeInsets.zero,
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.lightPrimary,
          foregroundColor: Colors.white,
          elevation: 0,
          textStyle: GoogleFonts.inter(fontWeight: FontWeight.w500, fontSize: 14),
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: AppColors.lightTextMain,
          side: const BorderSide(color: AppColors.lightBorderColor),
          textStyle: GoogleFonts.inter(fontWeight: FontWeight.w500, fontSize: 14),
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppColors.lightBgMain,
        contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: AppColors.lightBorderColor),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: AppColors.lightBorderColor),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: AppColors.lightPrimary),
        ),
        labelStyle: GoogleFonts.inter(color: AppColors.lightTextMuted, fontSize: 13, fontWeight: FontWeight.w600),
        hintStyle: GoogleFonts.inter(color: AppColors.lightTextMuted, fontSize: 14),
      ),
      dividerColor: AppColors.lightBorderColor,
      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        backgroundColor: AppColors.lightBgSurface,
        selectedItemColor: AppColors.lightPrimary,
        unselectedItemColor: AppColors.lightTextMuted,
        elevation: 8,
        type: BottomNavigationBarType.fixed,
      ),
    );
  }

  static ThemeData get darkTheme {
    final base = ThemeData.dark();
    return base.copyWith(
      scaffoldBackgroundColor: AppColors.darkBgMain,
      primaryColor: AppColors.darkPrimary,
      colorScheme: const ColorScheme.dark(
        primary: AppColors.darkPrimary,
        secondary: AppColors.darkSecondary,
        surface: AppColors.darkBgSurface,
        error: AppColors.accentRed,
        onPrimary: Colors.white,
        onSecondary: Colors.white,
        onSurface: AppColors.darkTextMain,
        onError: Colors.white,
      ),
      textTheme: GoogleFonts.interTextTheme(base.textTheme).copyWith(
        displayLarge: GoogleFonts.inter(color: AppColors.darkTextMain, fontWeight: FontWeight.w600, letterSpacing: -0.02),
        displayMedium: GoogleFonts.inter(color: AppColors.darkTextMain, fontWeight: FontWeight.w600, letterSpacing: -0.02),
        displaySmall: GoogleFonts.inter(color: AppColors.darkTextMain, fontWeight: FontWeight.w600, letterSpacing: -0.02),
        headlineMedium: GoogleFonts.inter(color: AppColors.darkTextMain, fontWeight: FontWeight.w600, letterSpacing: -0.02),
        headlineSmall: GoogleFonts.inter(color: AppColors.darkTextMain, fontWeight: FontWeight.w600, letterSpacing: -0.02),
        titleLarge: GoogleFonts.inter(color: AppColors.darkTextMain, fontWeight: FontWeight.w600, letterSpacing: -0.01),
        bodyLarge: GoogleFonts.inter(color: AppColors.darkTextMain, fontWeight: FontWeight.w400),
        bodyMedium: GoogleFonts.inter(color: AppColors.darkTextMain, fontWeight: FontWeight.w400),
        labelLarge: GoogleFonts.inter(color: AppColors.darkTextMain, fontWeight: FontWeight.w500),
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: AppColors.darkBgSurface,
        foregroundColor: AppColors.darkTextMain,
        elevation: 0,
        centerTitle: false,
      ),
      cardTheme: CardThemeData(
        color: AppColors.darkBgSurface,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: const BorderSide(color: AppColors.darkBorderColor),
        ),
        margin: EdgeInsets.zero,
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.darkPrimary,
          foregroundColor: Colors.white,
          elevation: 0,
          textStyle: GoogleFonts.inter(fontWeight: FontWeight.w500, fontSize: 14),
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: AppColors.darkTextMain,
          side: const BorderSide(color: AppColors.darkBorderColor),
          textStyle: GoogleFonts.inter(fontWeight: FontWeight.w500, fontSize: 14),
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppColors.darkBgMain,
        contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: AppColors.darkBorderColor),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: AppColors.darkBorderColor),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: AppColors.darkPrimary),
        ),
        labelStyle: GoogleFonts.inter(color: AppColors.darkTextMuted, fontSize: 13, fontWeight: FontWeight.w600),
        hintStyle: GoogleFonts.inter(color: AppColors.darkTextMuted, fontSize: 14),
      ),
      dividerColor: AppColors.darkBorderColor,
      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        backgroundColor: AppColors.darkBgSurface,
        selectedItemColor: AppColors.darkPrimary,
        unselectedItemColor: AppColors.darkTextMuted,
        elevation: 8,
        type: BottomNavigationBarType.fixed,
      ),
    );
  }
}
