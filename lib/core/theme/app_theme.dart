import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'app_colors.dart';
import 'app_spacing.dart';

class AppTheme {
  const AppTheme._();

  static ThemeData get light {
    final base = ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      colorScheme: ColorScheme.fromSeed(
        seedColor: AppColors.primary,
        primary: AppColors.primary,
        secondary: AppColors.secondary,
        surface: AppColors.surface,
      ),
    );

    return base.copyWith(
      scaffoldBackgroundColor: AppColors.background,
      splashFactory: InkSparkle.splashFactory,
      textTheme: _textTheme(base.textTheme),
      appBarTheme: AppBarTheme(
        backgroundColor: AppColors.surface,
        foregroundColor: AppColors.textPrimary,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        scrolledUnderElevation: 0.5,
        centerTitle: false,
        titleTextStyle: GoogleFonts.poppins(
          fontSize: 18,
          fontWeight: FontWeight.w600,
          color: AppColors.textPrimary,
        ),
        iconTheme: const IconThemeData(color: AppColors.textPrimary),
      ),
      cardTheme: CardThemeData(
        color: AppColors.surface,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        margin: EdgeInsets.zero,
        shape: RoundedRectangleBorder(
          borderRadius: AppRadius.cardRadius,
          side: const BorderSide(color: AppColors.border),
        ),
      ),
      dividerTheme: const DividerThemeData(
        color: AppColors.border,
        thickness: 1,
        space: 1,
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppColors.surfaceAlt,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.lg,
          vertical: AppSpacing.md,
        ),
        hintStyle: GoogleFonts.poppins(
          color: AppColors.textTertiary,
          fontSize: 14,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppRadius.md),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppRadius.md),
          borderSide: const BorderSide(color: AppColors.border),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppRadius.md),
          borderSide: const BorderSide(color: AppColors.primary, width: 1.5),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppRadius.md),
          borderSide: const BorderSide(color: AppColors.danger),
        ),
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          backgroundColor: AppColors.primary,
          foregroundColor: Colors.white,
          minimumSize: const Size(0, 48),
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xxl),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppRadius.md),
          ),
          textStyle: GoogleFonts.poppins(
            fontSize: 15,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: AppColors.primary,
          minimumSize: const Size(0, 48),
          side: const BorderSide(color: AppColors.primary),
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xxl),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppRadius.md),
          ),
          textStyle: GoogleFonts.poppins(
            fontSize: 15,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: AppColors.primary,
          textStyle: GoogleFonts.poppins(
            fontSize: 14,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      chipTheme: ChipThemeData(
        backgroundColor: AppColors.surfaceAlt,
        side: const BorderSide(color: AppColors.border),
        labelStyle: GoogleFonts.poppins(
          fontSize: 12,
          fontWeight: FontWeight.w500,
          color: AppColors.textSecondary,
        ),
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.sm,
          vertical: AppSpacing.xs,
        ),
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(AppRadius.pill)),
        ),
      ),
      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: AppColors.surface,
        surfaceTintColor: Colors.transparent,
        indicatorColor: AppColors.primarySurface,
        elevation: 8,
        height: 64,
        labelBehavior: NavigationDestinationLabelBehavior.alwaysShow,
        labelTextStyle: WidgetStateProperty.resolveWith(
          (states) => GoogleFonts.poppins(
            fontSize: 11,
            fontWeight: states.contains(WidgetState.selected)
                ? FontWeight.w600
                : FontWeight.w500,
            color: states.contains(WidgetState.selected)
                ? AppColors.primary
                : AppColors.textTertiary,
          ),
        ),
        iconTheme: WidgetStateProperty.resolveWith(
          (states) => IconThemeData(
            size: 24,
            color: states.contains(WidgetState.selected)
                ? AppColors.primary
                : AppColors.textTertiary,
          ),
        ),
      ),
      bottomSheetTheme: const BottomSheetThemeData(
        backgroundColor: AppColors.surface,
        surfaceTintColor: Colors.transparent,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(AppRadius.xl)),
        ),
      ),
      snackBarTheme: SnackBarThemeData(
        behavior: SnackBarBehavior.floating,
        backgroundColor: AppColors.textPrimary,
        contentTextStyle: GoogleFonts.poppins(
          fontSize: 14,
          color: Colors.white,
          fontWeight: FontWeight.w500,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadius.md),
        ),
      ),
      progressIndicatorTheme: const ProgressIndicatorThemeData(
        color: AppColors.primary,
      ),
      switchTheme: SwitchThemeData(
        thumbColor: WidgetStateProperty.resolveWith(
          (s) => s.contains(WidgetState.selected)
              ? Colors.white
              : AppColors.textTertiary,
        ),
        trackColor: WidgetStateProperty.resolveWith(
          (s) => s.contains(WidgetState.selected)
              ? AppColors.primary
              : AppColors.surfaceAlt,
        ),
      ),
    );
  }

  static TextTheme _textTheme(TextTheme base) {
    TextStyle s(double size, FontWeight w, {Color c = AppColors.textPrimary,
        double h = 1.4, double ls = 0}) {
      return GoogleFonts.poppins(
        fontSize: size,
        fontWeight: w,
        color: c,
        height: h,
        letterSpacing: ls,
      );
    }

    return base.copyWith(
      displaySmall: s(28, FontWeight.w700, h: 1.25),
      headlineMedium: s(24, FontWeight.w700, h: 1.3),
      headlineSmall: s(20, FontWeight.w700, h: 1.3),
      titleLarge: s(18, FontWeight.w600, h: 1.35),
      titleMedium: s(16, FontWeight.w600, h: 1.35),
      titleSmall: s(14, FontWeight.w600, h: 1.35),
      bodyLarge: s(16, FontWeight.w400, c: AppColors.textSecondary, h: 1.5),
      bodyMedium: s(14, FontWeight.w400, c: AppColors.textSecondary, h: 1.5),
      bodySmall: s(12, FontWeight.w400, c: AppColors.textTertiary, h: 1.4),
      labelLarge: s(14, FontWeight.w600),
      labelMedium: s(12, FontWeight.w500, c: AppColors.textSecondary),
      labelSmall: s(11, FontWeight.w500, c: AppColors.textTertiary),
    );
  }
}
