import 'package:flutter/material.dart';

/// What kind of substance is interacting.
enum InteractionType {
  food('Food', Icons.restaurant_rounded, Color(0xFFE8A317)),
  alcohol('Alcohol', Icons.local_bar_rounded, Color(0xFFDC2F2F)),
  drug('Medicine', Icons.medication_rounded, Color(0xFF2C6BED)),
  other('Other', Icons.info_rounded, Color(0xFF8A94A6));

  const InteractionType(this.label, this.icon, this.color);

  final String label;
  final IconData icon;
  final Color color;
}

/// How serious the interaction is.
enum InteractionSeverity {
  mild('Mild', Color(0xFF12A150)),
  moderate('Moderate', Color(0xFFE8A317)),
  severe('Severe', Color(0xFFDC2F2F));

  const InteractionSeverity(this.label, this.color);

  final String label;
  final Color color;
}

/// A single interaction rule: medicine X with food / alcohol / another medicine.
class DrugInteraction {
  const DrugInteraction({
    required this.type,
    required this.substance,
    required this.severity,
    required this.note,
  });

  final InteractionType type;

  /// What it interacts with, e.g. "Alcohol", "Warfarin", "Grapefruit".
  final String substance;
  final InteractionSeverity severity;
  final String note;

  /// Nutrition-relevant key used by the interaction checker.
  String get displayName => type == InteractionType.drug
      ? 'With $substance'
      : 'With $substance';
}
