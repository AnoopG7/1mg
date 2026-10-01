import 'package:flutter/material.dart';

import '../../core/ui/icon_registry.dart';

/// FDA-style pregnancy safety categories: A, B, C, D, X.
///
/// [label] doubles as the wire format — these are the literal strings stored in
/// Firestore, so they are intentionally single characters.
enum PregnancyCategory {
  a('A', 'Well established safe', 0xFF12A150),
  b('B', 'Animal studies show no risk', 0xFF00A9A5),
  c('C', 'Risk not ruled out, benefit may outweigh', 0xFFE8A317),
  d('D', 'Positive evidence of human risk', 0xFFF2721C),
  x('X', 'Contraindicated in pregnancy', 0xFFDC2F2F);

  const PregnancyCategory(this.label, this.description, this.colorValue);

  final String label;
  final String description;

  /// Stored as an ARGB int so the enum serialises cleanly.
  final int colorValue;

  Color get color => IconRegistry.colorFromHex(colorValue);

  bool get isSafe => this == PregnancyCategory.a || this == PregnancyCategory.b;
  bool get isAvoid => this == PregnancyCategory.d || this == PregnancyCategory.x;

  /// Resolves a wire value, defaulting to [PregnancyCategory.b] (the most
  /// common category) when the stored label is unknown.
  static PregnancyCategory fromLabel(String? label) =>
      values.firstWhere(
        (c) => c.label == label,
        orElse: () => PregnancyCategory.b,
      );
}
