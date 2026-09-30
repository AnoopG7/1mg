import 'package:flutter/material.dart';

/// 1mg-inspired brand palette.
class AppColors {
  const AppColors._();

  // Brand
  static const Color primary = Color(0xFFFF5A47);
  static const Color primaryDark = Color(0xFFE03A26);
  static const Color primaryLight = Color(0xFFFF8A78);
  static const Color primarySurface = Color(0xFFFFF1EE);

  static const Color secondary = Color(0xFF00A9A5);
  static const Color secondarySurface = Color(0xFFE6F7F6);

  // Neutrals
  static const Color background = Color(0xFFF7F8FA);
  static const Color surface = Color(0xFFFFFFFF);
  static const Color surfaceAlt = Color(0xFFF1F3F6);
  static const Color border = Color(0xFFE4E7EC);
  static const Color borderStrong = Color(0xFFCDD3DC);

  static const Color textPrimary = Color(0xFF14181F);
  static const Color textSecondary = Color(0xFF5A6472);
  static const Color textTertiary = Color(0xFF8A94A6);
  static const Color textOnDark = Color(0xFFFFFFFF);

  // Semantic
  static const Color success = Color(0xFF12A150);
  static const Color successSurface = Color(0xFFE8F7EE);
  static const Color warning = Color(0xFFE8A317);
  static const Color warningSurface = Color(0xFFFFF6E5);
  static const Color danger = Color(0xFFDC2F2F);
  static const Color dangerSurface = Color(0xFFFDEBEB);
  static const Color info = Color(0xFF2C6BED);
  static const Color infoSurface = Color(0xFFEAF1FE);
  static const Color purple = Color(0xFF7B4DFF);
  static const Color purpleSurface = Color(0xFFF0EBFF);

  // Pro / premium
  static const Color proGold = Color(0xFFC9922E);
  static const Color proGoldLight = Color(0xFFFFE9B8);
  static const Color proSurface = Color(0xFFFFF8E7);
  static const Color proDark = Color(0xFF2A2114);
  static const Color proDarkAlt = Color(0xFF6B4E1C);
  static const Color proText = Color(0xFFD9C79B);
  static const Color proTextOnDark = Color(0xFF3D2E12);

  // Verified doctor
  static const Color verified = Color(0xFF2C6BED);
  static const Color verifiedSurface = Color(0xFFEAF1FE);

  // Lab range colours
  static const Color rangeLow = Color(0xFF3B82F6);
  static const Color rangeNormal = Color(0xFF12A150);
  static const Color rangeHigh = Color(0xFFE8A317);
  static const Color rangeCritical = Color(0xFFDC2F2F);

  /// Brand gradient used on hero headers.
  static const LinearGradient brandGradient = LinearGradient(
    colors: [Color(0xFFFF5A47), Color(0xFFFF8A3D)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient proGradient = LinearGradient(
    colors: [Color(0xFF3D2E12), Color(0xFF7A5A20)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
}
