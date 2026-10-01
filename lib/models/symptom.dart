import 'package:flutter/material.dart';

import '../../core/ui/icon_registry.dart';

/// One question in the symptom checker flow.
class SymptomQuestion {
  const SymptomQuestion({
    required this.id,
    required this.prompt,
    required this.options,
    this.iconKey,
    this.isMultiSelect = false,
  });

  final String id;
  final String prompt;
  final List<String> options;

  /// Registry key — see [IconRegistry]. Stored as a string so it serialises.
  final String? iconKey;
  final bool isMultiSelect;

  IconData? get icon =>
      iconKey == null ? null : IconRegistry.resolve(iconKey!);

  Map<String, dynamic> toJson() => {
        'id': id,
        'prompt': prompt,
        'options': options,
        'iconKey': iconKey,
        'isMultiSelect': isMultiSelect,
      };

  factory SymptomQuestion.fromJson(Map<String, dynamic> json) => SymptomQuestion(
        id: json['id'] as String? ?? '',
        prompt: json['prompt'] as String? ?? '',
        options: (json['options'] as List<dynamic>? ?? const [])
            .map((e) => e.toString())
            .toList(),
        iconKey: json['iconKey'] as String?,
        isMultiSelect: json['isMultiSelect'] as bool? ?? false,
      );
}

/// A symptom a user can report, with a typical clinical weight.
class Symptom {
  const Symptom({
    required this.id,
    required this.name,
    required this.iconKey,
    required this.category,
  });

  final String id;
  final String name;

  /// Registry key — see [IconRegistry]. Stored as a string so it serialises.
  final String iconKey;

  /// e.g. "Respiratory", "Digestive" — used for grouping on the picker.
  final String category;

  IconData get icon => IconRegistry.resolve(iconKey);

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'iconKey': iconKey,
        'category': category,
      };

  factory Symptom.fromJson(Map<String, dynamic> json) => Symptom(
        id: json['id'] as String? ?? '',
        name: json['name'] as String? ?? '',
        iconKey: json['iconKey'] as String? ?? 'help',
        category: json['category'] as String? ?? 'General',
      );
}

/// A condition the symptom engine can suggest.
class Condition {
  const Condition({
    required this.id,
    required this.name,
    required this.description,
    required this.symptomIds,
    required this.recommendations,
    required this.selfCare,
    required this.overTheCounterCategories,
    this.seeDoctorWithinHours = 48,
  });

  final String id;
  final String name;
  final String description;

  /// Symptom ids that raise this condition's score.
  final List<String> symptomIds;
  final List<String> recommendations;
  final List<String> selfCare;

  /// Medicine categories that may help — used to suggest products.
  final List<String> overTheCounterCategories;
  final int seeDoctorWithinHours;

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'description': description,
        'symptomIds': symptomIds,
        'recommendations': recommendations,
        'selfCare': selfCare,
        'overTheCounterCategories': overTheCounterCategories,
        'seeDoctorWithinHours': seeDoctorWithinHours,
      };

  factory Condition.fromJson(Map<String, dynamic> json) => Condition(
        id: json['id'] as String? ?? '',
        name: json['name'] as String? ?? '',
        description: json['description'] as String? ?? '',
        symptomIds: (json['symptomIds'] as List<dynamic>? ?? const [])
            .map((e) => e.toString())
            .toList(),
        recommendations: (json['recommendations'] as List<dynamic>? ?? const [])
            .map((e) => e.toString())
            .toList(),
        selfCare: (json['selfCare'] as List<dynamic>? ?? const [])
            .map((e) => e.toString())
            .toList(),
        overTheCounterCategories:
            (json['overTheCounterCategories'] as List<dynamic>? ?? const [])
                .map((e) => e.toString())
                .toList(),
        seeDoctorWithinHours: (json['seeDoctorWithinHours'] as num?)?.toInt() ?? 48,
      );
}

/// How urgent the situation is.
enum TriageLevel {
  emergency('Emergency', 'Seek immediate medical help', 0xFFDC2F2F),
  urgent('Urgent', 'See a doctor within 24 hours', 0xFFF2721C),
  consultDoctor('Consult a doctor', 'Book a consultation soon', 0xFFE8A317),
  selfCare('Self care', 'Manage at home with care', 0xFF12A150);

  const TriageLevel(this.label, this.action, this.colorValue);

  final String label;
  final String action;

  /// Stored as an ARGB int so the enum serialises cleanly.
  final int colorValue;

  Color get color => IconRegistry.colorFromHex(colorValue);

  /// Resolves a wire value. Unknown values fall back to [selfCare], the least
  /// urgent level, so an unrecognised value never overstates severity.
  static TriageLevel fromName(String? name) => values.firstWhere(
        (l) => l.name == name,
        orElse: () => TriageLevel.selfCare,
      );
}

class ConditionMatch {
  const ConditionMatch({
    required this.condition,
    required this.probability,
    required this.matchedSymptoms,
  });

  final Condition condition;

  /// 0–100
  final int probability;
  final List<String> matchedSymptoms;

  Map<String, dynamic> toJson() => {
        'condition': condition.toJson(),
        'probability': probability,
        'matchedSymptoms': matchedSymptoms,
      };

  factory ConditionMatch.fromJson(Map<String, dynamic> json) => ConditionMatch(
        condition: Condition.fromJson(json['condition'] as Map<String, dynamic>),
        probability: (json['probability'] as num?)?.toInt() ?? 0,
        matchedSymptoms: (json['matchedSymptoms'] as List<dynamic>? ?? const [])
            .map((e) => e.toString())
            .toList(),
      );
}

/// Final output of the symptom checker.
class Assessment {
  const Assessment({
    required this.level,
    required this.score,
    required this.matches,
    required this.redFlags,
    required this.selfCare,
    required this.advice,
  });

  final TriageLevel level;

  /// 0–100 overall severity score.
  final int score;
  final List<ConditionMatch> matches;
  final List<String> redFlags;
  final List<String> selfCare;
  final String advice;

  Map<String, dynamic> toJson() => {
        'level': level.name,
        'score': score,
        'matches': matches.map((m) => m.toJson()).toList(),
        'redFlags': redFlags,
        'selfCare': selfCare,
        'advice': advice,
      };

  factory Assessment.fromJson(Map<String, dynamic> json) => Assessment(
        level: TriageLevel.fromName(json['level'] as String?),
        score: (json['score'] as num?)?.toInt() ?? 0,
        matches: (json['matches'] as List<dynamic>? ?? const [])
            .whereType<Map<String, dynamic>>()
            .map(ConditionMatch.fromJson)
            .toList(),
        redFlags: (json['redFlags'] as List<dynamic>? ?? const [])
            .map((e) => e.toString())
            .toList(),
        selfCare: (json['selfCare'] as List<dynamic>? ?? const [])
            .map((e) => e.toString())
            .toList(),
        advice: json['advice'] as String? ?? '',
      );
}
