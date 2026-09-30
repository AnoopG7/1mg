import '../../models/drug_interaction.dart';
import '../../models/medicine.dart';

/// A single alert produced by the interaction checker.
class InteractionAlert {
  const InteractionAlert({
    required this.severity,
    required this.title,
    required this.detail,
    required this.type,
    required this.participants,
  });

  final InteractionSeverity severity;
  final String title;
  final String detail;
  final InteractionType type;

  /// Medicines involved — empty for food / alcohol checks.
  final List<String> participants;

  int get weight => switch (severity) {
        InteractionSeverity.severe => 3,
        InteractionSeverity.moderate => 2,
        InteractionSeverity.mild => 1,
      };
}

/// Cross-references medicines against each other and against substances.
class InteractionEngine {
  const InteractionEngine();

  /// Substances the user can toggle in the checker UI.
  static const Map<InteractionType, List<String>> commonSubstances = {
    InteractionType.food: [
      'Grapefruit',
      'Milk and dairy',
      'Leafy greens (Vitamin K)',
      'Alcohol',
      'Spicy food',
      'High-fat meal',
      'Caffeine (tea/coffee)',
      'Tyramine-rich food',
    ],
    InteractionType.alcohol: [
      'Alcohol',
    ],
    InteractionType.other: [
      'St. John\'s Wort',
      'Antacids',
      'Iron supplements',
      'Calcium supplements',
    ],
  };

  /// Keys used by the mock data for food/alcohol rules.
  static const Map<String, String> substanceKey = {
    'Grapefruit': 'Grapefruit',
    'Milk and dairy': 'Milk and dairy',
    'Leafy greens (Vitamin K)': 'Leafy greens (Vitamin K)',
    'Alcohol': 'Alcohol',
    'Spicy food': 'Spicy food',
    'High-fat meal': 'High-fat meal',
    'Caffeine (tea/coffee)': 'Caffeine (tea/coffee)',
    'Tyramine-rich food': 'Tyramine-rich food',
    'St. John\'s Wort': "St. John's Wort",
    'Antacids': 'Antacids',
    'Iron supplements': 'Iron supplements',
    'Calcium supplements': 'Calcium supplements',
  };

  /// Pairwise medicine–medicine checks plus substance checks.
  List<InteractionAlert> check({
    required List<Medicine> medicines,
    Set<InteractionType> substanceTypes = const {},
    Set<String> substances = const {},
  }) {
    final alerts = <InteractionAlert>[];

    // 1. Medicine ↔ medicine
    for (var i = 0; i < medicines.length; i++) {
      for (var j = i + 1; j < medicines.length; j++) {
        alerts.addAll(_pairAlerts(medicines[i], medicines[j]));
      }
    }

    // 2. Medicine ↔ food / alcohol / other
    for (final med in medicines) {
      for (final inter in med.interactions) {
        if (inter.type == InteractionType.drug) continue;
        final selected = substances.contains(inter.substance);
        final typeSelected = substanceTypes.contains(inter.type);
        if (!selected && !typeSelected) continue;

        alerts.add(InteractionAlert(
          severity: inter.severity,
          title: '${med.name} ${inter.displayName.toLowerCase()}',
          detail: inter.note,
          type: inter.type,
          participants: [med.name],
        ));
      }
    }

    alerts.sort((a, b) => b.weight.compareTo(a.weight));
    return alerts;
  }

  List<InteractionAlert> _pairAlerts(Medicine a, Medicine b) {
    final found = <InteractionAlert>[];

    // Check a's rules against b, and b's rules against a.
    found.addAll(_rulesAgainst(a, b, aName: a.name, bName: b.name));
    found.addAll(_rulesAgainst(b, a, aName: b.name, bName: a.name));

    // Duplicate symmetric pairs (both medicines list the other) collapse to one.
    final seen = <String>{};
    return found.where((alert) => seen.add(alert.title)).toList();
  }

  List<InteractionAlert> _rulesAgainst(
    Medicine source,
    Medicine target, {
    required String aName,
    required String bName,
  }) {
    final generic = target.genericName.toLowerCase();
    final brand = target.brandName.toLowerCase();

    return source.interactions
        .where((i) => i.type == InteractionType.drug)
        .where((i) {
          final sub = i.substance.toLowerCase();
          return generic.contains(sub) ||
              brand.contains(sub) ||
              sub.contains(generic.split(' ').first) ||
              sub.contains(brand);
        })
        .map((i) => InteractionAlert(
              severity: i.severity,
              title: '$aName + $bName',
              detail: i.note,
              type: InteractionType.drug,
              participants: [aName, bName],
            ))
        .toList();
  }

  /// Highest severity present, or null when nothing was found.
  InteractionSeverity? highest(List<InteractionAlert> alerts) {
    if (alerts.isEmpty) return null;
    return alerts.first.severity;
  }

  /// True when at least one alert is severe enough to block a purchase.
  bool hasBlocking(List<InteractionAlert> alerts) =>
      alerts.any((a) => a.severity == InteractionSeverity.severe);
}
