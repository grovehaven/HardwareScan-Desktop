import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'app_colors.dart';

class AppTheme {
  static ThemeData get darkTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      scaffoldBackgroundColor: AppColors.darkBackground,
      colorScheme: const ColorScheme.dark(
        surface: AppColors.surfaceDark,
        primary: AppColors.cyanAccent,
        secondary: AppColors.blueAccent,
        onSurface: AppColors.textPrimary,
      ),
      textTheme: GoogleFonts.interTextTheme(
        ThemeData.dark().textTheme,
      ).apply(
        bodyColor: AppColors.textPrimary,
        displayColor: AppColors.textPrimary,
      ),
      cardTheme: CardThemeData(
        color: AppColors.cardBackground,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: const BorderSide(color: AppColors.cardBorder, width: 1),
        ),
      ),
      dividerTheme: const DividerThemeData(
        color: AppColors.cardBorder,
        thickness: 1,
      ),
      navigationRailTheme: NavigationRailThemeData(
        backgroundColor: AppColors.surfaceDark,
        selectedIconTheme: const IconThemeData(color: AppColors.cyanAccent),
        selectedLabelTextStyle: GoogleFonts.inter(
          color: AppColors.cyanAccent,
          fontSize: 11,
          fontWeight: FontWeight.w600,
        ),
        unselectedIconTheme: const IconThemeData(color: AppColors.textSecondary),
        unselectedLabelTextStyle: GoogleFonts.inter(
          color: AppColors.textSecondary,
          fontSize: 11,
          fontWeight: FontWeight.w500,
        ),
      ),
      bottomNavigationBarTheme: BottomNavigationBarThemeData(
        backgroundColor: AppColors.surfaceDark,
        selectedItemColor: AppColors.cyanAccent,
        unselectedItemColor: AppColors.textSecondary,
        selectedLabelStyle: GoogleFonts.inter(fontSize: 11, fontWeight: FontWeight.w600),
        unselectedLabelStyle: GoogleFonts.inter(fontSize: 11, fontWeight: FontWeight.w500),
        type: BottomNavigationBarType.fixed,
      ),
    );
  }
}
