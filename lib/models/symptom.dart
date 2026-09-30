import 'package:flutter/material.dart';

/// One question in the symptom checker flow.
class SymptomQuestion {
  const SymptomQuestion({
    required this.id,
    required this.prompt,
    required this.options,
    this.icon,
    this.isMultiSelect = false,
  });

  final String id;
  final String prompt;
  final List<String> options;
  final IconData? icon;
  final bool isMultiSelect;
}

/// A symptom a user can report, with a typical clinical weight.
class Symptom {
  const Symptom({
    required this.id,
    required this.name,
    required this.icon,
    required this.category,
  });

  final String id;
  final String name;
  final IconData icon;

  /// e.g. "Respiratory", "Digestive" — used for grouping on the picker.
  final String category;
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
}

/// How urgent the situation is.
enum TriageLevel {
  emergency('Emergency', 'Seek immediate medical help', Color(0xFFDC2F2F)),
  urgent('Urgent', 'See a doctor within 24 hours', Color(0xFFF2721C)),
  consultDoctor('Consult a doctor', 'Book a consultation soon', Color(0xFFE8A317)),
  selfCare('Self care', 'Manage at home with care', Color(0xFF12A150));

  const TriageLevel(this.label, this.action, this.color);

  final String label;
  final String action;
  final Color color;
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
}
