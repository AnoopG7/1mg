import 'package:flutter/material.dart';

/// FDA-style pregnancy safety categories: A, B, C, D, X.
enum PregnancyCategory {
  a('A', 'Well established safe', Color(0xFF12A150)),
  b('B', 'Animal studies show no risk', Color(0xFF00A9A5)),
  c('C', 'Risk not ruled out, benefit may outweigh', Color(0xFFE8A317)),
  d('D', 'Positive evidence of human risk', Color(0xFFF2721C)),
  x('X', 'Contraindicated in pregnancy', Color(0xFFDC2F2F));

  const PregnancyCategory(this.label, this.description, this.color);

  final String label;
  final String description;
  final Color color;

  bool get isSafe => this == PregnancyCategory.a || this == PregnancyCategory.b;
  bool get isAvoid => this == PregnancyCategory.d || this == PregnancyCategory.x;
}
