import 'package:flutter/material.dart';

/// 4pt spacing scale + corner radii, so padding/gaps stay consistent.
class AppSpacing {
  const AppSpacing._();

  static const double xxs = 2;
  static const double xs = 4;
  static const double sm = 8;
  static const double md = 12;
  static const double lg = 16;
  static const double xl = 20;
  static const double xxl = 24;
  static const double xxxl = 32;

  /// Horizontal page padding.
  static const double pageH = 16;

  static const double sectionGap = 24;
}

class AppRadius {
  const AppRadius._();

  static const double sm = 8;
  static const double md = 12;
  static const double lg = 16;
  static const double xl = 20;
  static const double pill = 999;

  static const BorderRadius cardRadius = BorderRadius.all(Radius.circular(lg));
  static const BorderRadius cardRadiusLg = BorderRadius.all(Radius.circular(xl));
  static const BorderRadius pillRadius = BorderRadius.all(Radius.circular(pill));
}

class AppShadows {
  const AppShadows._();

  static const List<BoxShadow> card = [
    BoxShadow(
      color: Color(0x0F101828),
      blurRadius: 12,
      offset: Offset(0, 4),
    ),
  ];

  static const List<BoxShadow> raised = [
    BoxShadow(
      color: Color(0x1A101828),
      blurRadius: 20,
      offset: Offset(0, 8),
    ),
  ];
}
