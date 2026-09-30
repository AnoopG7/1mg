import 'package:flutter/foundation.dart';

import '../core/services/interaction_engine.dart';
import '../data/mock_medicines.dart';
import '../models/drug_interaction.dart';
import '../models/medicine.dart';

/// State for the medicine interaction checker (food / alcohol / other medicines).
class InteractionProvider extends ChangeNotifier {
  InteractionProvider({InteractionEngine? engine})
      : _engine = engine ?? const InteractionEngine();

  final InteractionEngine _engine;

  final List<Medicine> _selected = [];
  List<Medicine> get selected => List.unmodifiable(_selected);

  final Set<InteractionType> _types = {InteractionType.food, InteractionType.alcohol};
  Set<InteractionType> get types => Set.unmodifiable(_types);

  final Set<String> _substances = {};
  Set<String> get substances => Set.unmodifiable(_substances);

  List<InteractionAlert> _alerts = [];
  List<InteractionAlert> get alerts => List.unmodifiable(_alerts);

  /// Substances available given the enabled categories.
  List<String> get availableSubstances {
    final all = <String>[];
    for (final type in _types) {
      all.addAll(InteractionEngine.commonSubstances[type] ?? const []);
    }
    return all;
  }

  bool isSelected(String medicineId) =>
      _selected.any((m) => m.id == medicineId);

  void toggleMedicine(String medicineId) {
    final index = _selected.indexWhere((m) => m.id == medicineId);
    if (index >= 0) {
      _selected.removeAt(index);
    } else {
      final med = MockMedicines.byId(medicineId);
      if (med != null) _selected.add(med);
    }
    _recompute();
  }

  void toggleType(InteractionType type) {
    if (_types.contains(type)) {
      _types.remove(type);
      // Drop substances belonging to the disabled category.
      _substances.removeAll(
          InteractionEngine.commonSubstances[type] ?? const <String>[]);
    } else {
      _types.add(type);
    }
    _recompute();
  }

  void toggleSubstance(String substance) {
    if (_substances.contains(substance)) {
      _substances.remove(substance);
    } else {
      _substances.add(substance);
    }
    _recompute();
  }

  void clear() {
    _selected.clear();
    _substances.clear();
    _types
      ..clear()
      ..add(InteractionType.food)
      ..add(InteractionType.alcohol);
    _alerts = [];
    notifyListeners();
  }

  void _recompute() {
    _alerts = _engine.check(
      medicines: _selected,
      substanceTypes: _types,
      substances: _substances,
    );
    notifyListeners();
  }

  // ---- quick checks used by the medicine detail screen --------------------

  List<DrugInteraction> interactionsFor(Medicine med) => med.interactions;

  /// Interactions of [med] against a specific substance.
  List<DrugInteraction> interactionsWith(Medicine med, String substance) =>
      med.interactions.where((i) => i.substance == substance).toList();
}
