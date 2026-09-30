import '../../models/symptom.dart';
import '../../data/mock_symptoms.dart';

/// Rule-based symptom triage engine.
///
/// Scores every [Condition] against the selected symptoms, applies red-flag
/// overrides, and returns a ranked [Assessment]. This is the "AI" layer of the
/// symptom checker — swap [analyse] for an API call to move to a real model.
class SymptomEngine {
  const SymptomEngine();

  /// Weight of each follow-up answer option, per question.
  static const Map<String, int> _durationWeight = {
    'Less than 24 hours': 12,
    '1 – 3 days': 20,
    '4 – 7 days': 28,
    '1 – 4 weeks': 36,
    'More than a month': 40,
  };

  static const Map<String, int> _severityWeight = {
    'Mild — noticeable but I can do my usual work': 8,
    'Moderate — it is affecting my daily work': 20,
    'Severe — I am struggling with basic tasks': 34,
    'Very severe — I cannot manage at all': 45,
  };

  static const Map<String, int> _feverWeight = {
    'No fever / under 99°F': 0,
    'Low grade — 99°F to 100.4°F': 14,
    'Moderate — 100.5°F to 102°F': 26,
    'High — above 102°F': 40,
    'I have not measured it': 10,
  };

  static const Map<String, int> _coughWeight = {
    'Dry cough, no phlegm': 8,
    'Productive cough with clear phlegm': 12,
    'Productive cough with yellow or green phlegm': 24,
    'Cough with blood': 45,
    'Night-time cough only': 14,
  };

  static const Map<String, int> _breathingWeight = {
    'Yes, comfortably': 0,
    'Yes, but I feel short of breath': 22,
    'No, I can only manage a few words': 48,
  };

  static const Map<String, int> _stomachWeight = {
    'Upper abdomen (above the belly button)': 16,
    'Around the belly button': 18,
    'Lower abdomen (below the belly button)': 16,
    'Right side': 22,
    'Left side': 20,
  };

  /// Multiplier applied when the user is in a higher-risk age band.
  static const Map<String, double> _ageRisk = {
    'Child (0–12 years)': 1.15,
    'Teen (13–17 years)': 1.0,
    'Adult (18–44 years)': 1.0,
    'Middle age (45–59 years)': 1.12,
    'Senior (60+ years)': 1.28,
  };

  Assessment analyse({
    required List<String> symptomIds,
    required Map<String, String> answers,
    required String ageBand,
    required String gender,
  }) {
    final selected = symptomIds.toSet();

    // Nothing reported: say so plainly rather than falling through to the
    // scoring path, which would otherwise default the question weights and
    // invent a "consult a doctor" verdict out of an empty symptom list.
    if (selected.isEmpty) {
      return const Assessment(
        level: TriageLevel.selfCare,
        score: 0,
        matches: [],
        redFlags: [],
        selfCare: [
          'No symptoms were selected, so there is nothing to assess here',
          'If symptoms are mild and clear up on their own, rest, keep hydrated and monitor them',
          'Book a consultation if symptoms persist beyond a few days or get worse',
        ],
        advice:
            'Add at least one symptom to get a preliminary assessment. This tool '
            'is for guidance only and is not a diagnosis.',
      );
    }

    // ---- 1. Red flags short-circuit everything -----------------------------
    final redFlags = <String>[];
    for (final id in selected) {
      final rules = MockSymptoms.redFlagRules[id];
      if (rules != null) {
        // A red flag only fires when paired with another symptom or a high
        // severity answer, so a lone "headache" does not trigger an ambulance.
        final paired = selected.length > 1;
        final highSeverity = (_severityWeight[answers['q_severity']] ?? 0) >= 34;
        if (paired || highSeverity) redFlags.addAll(rules);
      }
    }
    if (redFlags.isNotEmpty) {
      return Assessment(
        level: TriageLevel.emergency,
        score: 100,
        matches: const [],
        redFlags: redFlags,
        selfCare: const [
          'Call emergency services or go to the nearest emergency department right now',
          'Do not drive yourself — ask someone to take you',
          'Do not take any new medicine until a doctor has examined you',
          'Keep a list of the medicines you are currently taking to show the doctor',
        ],
        advice:
            'Your answers include warning signs that need immediate medical '
            'attention. Please do not wait for this to settle on its own.',
      );
    }

    // ---- 2. Score every condition ------------------------------------------
    final matches = <ConditionMatch>[];
    for (final condition in MockSymptoms.conditions) {
      final hits = condition.symptomIds.where(selected.contains).toList();
      if (hits.isEmpty) continue;

      // Base score: how much of the condition's symptom set is present,
      // weighted by how central each hit is.
      final coverage = hits.length / condition.symptomIds.length;
      var score = coverage * 55;

      // Bonus when the user reports many of the condition's key symptoms.
      if (hits.length >= 3) score += 18;
      if (hits.length >= 4) score += 10;

      // Follow-up answers push severity in a condition-aware direction.
      for (final entry in answers.entries) {
        final weight = _weightFor(entry.key, entry.value);
        if (weight == 0) continue;
        final relevance = _relevance(condition.id, entry.key);
        score += weight * relevance;
      }

      // Age and gender adjust the urgency.
      score *= _ageRisk[ageBand] ?? 1.0;
      if (condition.id == 'c_uti' && gender == 'Male') score *= 0.75;
      if (condition.id == 'c_allergy' && gender == 'Female') score *= 1.05;

      final probability = (score / 1.35).round().clamp(8, 96);
      matches.add(ConditionMatch(
        condition: condition,
        probability: probability,
        matchedSymptoms: _namesOf(hits),
      ));
    }

    matches.sort((a, b) => b.probability.compareTo(a.probability));
    final top = matches.take(4).toList();

    // ---- 3. Overall severity ----------------------------------------------
    final durationW = _durationWeight[answers['q_duration']] ?? 20;
    final severityW = _severityWeight[answers['q_severity']] ?? 20;
    final feverW = _feverWeight[answers['q_fever']] ?? 10;
    final symptomLoad = (selected.length * 7).clamp(0, 35);
    final topProb = top.isEmpty ? 10 : top.first.probability;

    var severityScore = durationW * 0.25 +
        severityW * 0.30 +
        feverW * 0.20 +
        symptomLoad * 0.10 +
        topProb * 0.15;
    severityScore *= _ageRisk[ageBand] ?? 1.0;
    final score = severityScore.round().clamp(5, 99);

    // ---- 4. Triage level ----------------------------------------------------
    final TriageLevel level;
    if (feverW >= 40 || severityW >= 45 || (breathingWeightFor(answers)) >= 48) {
      level = TriageLevel.emergency;
    } else if (score >= 72 || feverW >= 26 || severityW >= 34) {
      level = TriageLevel.urgent;
    } else if (score >= 46 || feverW >= 14 || severityW >= 20) {
      level = TriageLevel.consultDoctor;
    } else {
      level = TriageLevel.selfCare;
    }

    // Emergency needs its own red-flag copy so the UI shows the alert card.
    final effectiveRedFlags = <String>[
      if (level == TriageLevel.emergency)
        'Your symptoms include combination(s) that can be serious. Seek '
            'immediate medical attention — do not wait for home remedies to work.',
    ];

    final selfCare = <String>[
      if (top.isNotEmpty) ...top.first.condition.selfCare,
      ..._genericSelfCare(level),
    ];

    return Assessment(
      level: level,
      score: score,
      matches: top,
      redFlags: effectiveRedFlags,
      selfCare: selfCare,
      advice: _adviceFor(level, top),
    );
  }

  static int _weightFor(String questionId, String answer) {
    switch (questionId) {
      case 'q_duration':
        return _durationWeight[answer] ?? 20;
      case 'q_severity':
        return _severityWeight[answer] ?? 20;
      case 'q_fever':
        return _feverWeight[answer] ?? 10;
      case 'q_cough':
        return _coughWeight[answer] ?? 10;
      case 'q_breathing':
        return _breathingWeight[answer] ?? 0;
      case 'q_stomach':
        return _stomachWeight[answer] ?? 10;
      default:
        return 0;
    }
  }

  /// How much a given answer influences a given condition (0–1).
  static double _relevance(String conditionId, String questionId) {
    switch (conditionId) {
      case 'c_viral_fever':
      case 'c_dengue':
      case 'c_pneumonia':
        return questionId == 'q_fever' ? 1.0 : (questionId == 'q_cough' ? 0.8 : 0.35);
      case 'c_common_cold':
      case 'c_allergy':
        return questionId == 'q_cough' ? 0.9 : 0.3;
      case 'c_gastritis':
      case 'c_food_poisoning':
        return questionId == 'q_stomach' ? 1.0 : 0.35;
      case 'c_uti':
        return questionId == 'q_stomach' ? 0.5 : 0.3;
      case 'c_dengue_warn':
        return questionId == 'q_fever' ? 1.0 : 0.6;
      case 'c_diabetes_sym':
        return questionId == 'q_duration' ? 0.6 : 0.3;
      case 'c_sinusitis':
      case 'c_otitis_media':
        return questionId == 'q_duration' ? 0.9 : 0.4;
      case 'c_functional_constipation':
        return questionId == 'q_stomach' ? 0.9 : 0.3;
      case 'c_peripheral_neuropathy':
        return questionId == 'q_duration' ? 0.8 : 0.4;
      default:
        return 0.4;
    }
  }

  static int breathingWeightFor(Map<String, String> answers) =>
      _breathingWeight[answers['q_breathing']] ?? 0;

  static List<String> _namesOf(List<String> ids) => ids
      .map((id) => MockSymptoms.all.firstWhere(
            (s) => s.id == id,
            orElse: () => MockSymptoms.all.first,
          ).name)
      .toList();

  static List<String> _genericSelfCare(TriageLevel level) {
    switch (level) {
      case TriageLevel.emergency:
        return [
          'Do not self-medicate — get medical help now',
        ];
      case TriageLevel.urgent:
        return [
          'Book a doctor appointment today',
          'Do not ignore warning signs such as chest pain or high fever',
          'Keep a note of when the symptoms started and what makes them worse',
        ];
      case TriageLevel.consultDoctor:
        return [
          'Track your temperature twice daily',
          'Drink plenty of warm fluids through the day',
          'Complete bed rest until symptoms settle',
        ];
      case TriageLevel.selfCare:
        return [
          'Rest, hydrate and monitor your symptoms for the next 2 days',
        ];
    }
  }

  static String _adviceFor(TriageLevel level, List<ConditionMatch> top) {
    final name = top.isEmpty ? 'your symptoms' : top.first.condition.name;
    switch (level) {
      case TriageLevel.emergency:
        return 'This needs immediate medical attention. Please reach a hospital '
            'or call emergency services.';
      case TriageLevel.urgent:
        return 'Your symptoms suggest $name. Please see a doctor today — early '
            'treatment prevents most complications.';
      case TriageLevel.consultDoctor:
        return 'Your symptoms are most consistent with $name. Home care will help, '
            'but a doctor should confirm the diagnosis.';
      case TriageLevel.selfCare:
        return 'Your symptoms are mild and can be managed at home with rest, fluids '
            'and simple remedies. Monitor for any worsening.';
    }
  }
}
