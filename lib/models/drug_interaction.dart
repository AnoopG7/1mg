import 'package:flutter/material.dart';

import '../../core/ui/icon_registry.dart';

/// What kind of substance is interacting.
enum InteractionType {
  food('Food', 'interaction_food', 0xFFE8A317),
  alcohol('Alcohol', 'interaction_alcohol', 0xFFDC2F2F),
  drug('Medicine', 'interaction_medicine', 0xFF2C6BED),
  other('Other', 'interaction_other', 0xFF8A94A6);

  const InteractionType(this.label, this.iconKey, this.colorValue);

  final String label;

  /// Registry key — see [IconRegistry]. Stored as a string so it serialises.
  final String iconKey;
  final int colorValue;

  IconData get icon => IconRegistry.resolve(iconKey);
  Color get color => IconRegistry.colorFromHex(colorValue);

  /// Resolves a wire value, defaulting to [InteractionType.other] so an
  /// unrecognised type renders as a neutral entry rather than throwing.
  static InteractionType fromName(String? name) => values.firstWhere(
        (t) => t.name == name,
        orElse: () => InteractionType.other,
      );
}

/// How serious the interaction is.
enum InteractionSeverity {
  mild('Mild', 0xFF12A150),
  moderate('Moderate', 0xFFE8A317),
  severe('Severe', 0xFFDC2F2F);

  const InteractionSeverity(this.label, this.colorValue);

  final String label;
  final int colorValue;

  Color get color => IconRegistry.colorFromHex(colorValue);

  /// Resolves a wire value. Unknown severities fall back to [moderate], the
  /// middle rung, so a missing value never understates risk on screen.
  static InteractionSeverity fromName(String? name) => values.firstWhere(
        (s) => s.name == name,
        orElse: () => InteractionSeverity.moderate,
      );
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

  Map<String, dynamic> toJson() => {
        'type': type.name,
        'substance': substance,
        'severity': severity.name,
        'note': note,
      };

  factory DrugInteraction.fromJson(Map<String, dynamic> json) => DrugInteraction(
        type: InteractionType.fromName(json['type'] as String?),
        substance: json['substance'] as String? ?? '',
        severity: InteractionSeverity.fromName(json['severity'] as String?),
        note: json['note'] as String? ?? '',
      );
}
