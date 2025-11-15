import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:taba_app/core/constants/app_colors.dart';

class AppTheme {
  const AppTheme._();

  static ThemeData get light {
    final base = ThemeData.dark(useMaterial3: true);
    final displayFont = GoogleFonts.pixelifySans();
    final bodyFont = GoogleFonts.spaceGrotesk();

    final textTheme = TextTheme(
      displayLarge: displayFont.copyWith(
        color: AppColors.textPrimary,
        fontSize: 40,
        letterSpacing: 2,
        fontWeight: FontWeight.w600,
      ),
      displayMedium: displayFont.copyWith(
        color: AppColors.textPrimary,
        fontWeight: FontWeight.w600,
      ),
      headlineMedium: displayFont.copyWith(
        color: AppColors.textPrimary,
        fontSize: 32,
      ),
      headlineSmall: displayFont.copyWith(
        color: AppColors.textPrimary,
        fontSize: 26,
      ),
      titleLarge: bodyFont.copyWith(
        color: AppColors.textPrimary,
        fontWeight: FontWeight.w600,
        letterSpacing: 0.5,
      ),
      titleMedium: bodyFont.copyWith(
        color: AppColors.textPrimary,
        fontWeight: FontWeight.w600,
      ),
      titleSmall: bodyFont.copyWith(
        color: AppColors.textSecondary,
        fontWeight: FontWeight.w500,
      ),
      bodyLarge: bodyFont.copyWith(color: AppColors.textPrimary, fontSize: 16),
      bodyMedium: bodyFont.copyWith(color: AppColors.textSecondary),
      bodySmall: bodyFont.copyWith(
        color: AppColors.textSecondary,
        fontSize: 12,
      ),
      labelLarge: bodyFont.copyWith(
        fontWeight: FontWeight.w700,
        color: AppColors.textPrimary,
        letterSpacing: 0.6,
      ),
      labelMedium: bodyFont.copyWith(
        color: AppColors.textSecondary,
        letterSpacing: 0.8,
      ),
    );

    final scheme = ColorScheme.fromSeed(
      seedColor: AppColors.neonPink,
      brightness: Brightness.dark,
      primary: AppColors.neonPink,
      secondary: AppColors.neonBlue,
      surface: AppColors.midnightSoft,
      onPrimary: Colors.white,
      onSecondary: Colors.white,
      onSurface: AppColors.textPrimary,
    ).copyWith(
      surface: AppColors.midnightSoft,
    );

    return base.copyWith(
      colorScheme: scheme,
      scaffoldBackgroundColor: AppColors.midnight,
      textTheme: textTheme,
      appBarTheme: base.appBarTheme.copyWith(
        elevation: 0,
        backgroundColor: Colors.transparent,
        foregroundColor: AppColors.textPrimary,
        titleTextStyle: textTheme.titleLarge,
      ),
      cardTheme: CardThemeData(
        color: AppColors.midnightGlass,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(24),
          side: const BorderSide(color: AppColors.outline),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppColors.midnightGlass,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(18),
          borderSide: const BorderSide(color: AppColors.outline),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(18),
          borderSide: const BorderSide(color: AppColors.neonPink, width: 2),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(18),
          borderSide: const BorderSide(color: AppColors.outline),
        ),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 20,
          vertical: 16,
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.neonPink,
          foregroundColor: Colors.white,
          minimumSize: const Size.fromHeight(52),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          textStyle: textTheme.labelLarge,
        ),
      ),
      chipTheme: base.chipTheme.copyWith(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        showCheckmark: false,
        labelStyle: bodyFont.copyWith(
          fontWeight: FontWeight.w600,
          color: AppColors.textPrimary,
        ),
        backgroundColor: AppColors.midnightSoft,
        selectedColor: AppColors.neonPink.withAlpha(80),
        side: const BorderSide(color: AppColors.outline),
      ),
      bottomNavigationBarTheme: base.bottomNavigationBarTheme.copyWith(
        backgroundColor: Colors.transparent,
        selectedItemColor: AppColors.neonPink,
        unselectedItemColor: AppColors.textSecondary,
        showUnselectedLabels: true,
        type: BottomNavigationBarType.fixed,
      ),
      floatingActionButtonTheme: base.floatingActionButtonTheme.copyWith(
        backgroundColor: AppColors.neonPink,
        foregroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
      ),
      dividerTheme: const DividerThemeData(color: AppColors.outline),
      visualDensity: VisualDensity.adaptivePlatformDensity,
    );
  }
}
