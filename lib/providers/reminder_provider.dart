import 'package:flutter/foundation.dart';
import 'package:uuid/uuid.dart';

import '../core/services/storage_service.dart';
import '../models/reminder.dart';

class ReminderProvider extends ChangeNotifier {
  ReminderProvider(this._storage) {
    _reminders = _storage.readList('reminders', Reminder.fromJson);
  }

  final StorageService _storage;
  late List<Reminder> _reminders;

  static const _uuid = Uuid();

  List<Reminder> get reminders => List.unmodifiable(_reminders);
  List<Reminder> get active =>
      _reminders.where((r) => r.isActive).toList(growable: false);
  List<Reminder> get today =>
      _reminders.where((r) => r.isActive && r.isDueOn(DateTime.now())).toList();

  int get totalActive => _reminders.where((r) => r.isActive).length;

  /// Doses due today across all active reminders.
  int get dosesDueToday => today.fold(0, (s, r) => s + r.dosesToday);

  /// Doses already logged today.
  int get dosesTakenToday => _reminders.fold(
    0,
    (s, r) => s + (r.isActive ? r.dosesTakenOn(DateTime.now()) : 0),
  );

  double get todayAdherence {
    final due = dosesDueToday;
    if (due == 0) return 1;
    return (dosesTakenToday / due).clamp(0.0, 1.0);
  }

  /// Consecutive days with a perfect adherence record.
  int get streak {
    var count = 0;
    for (var i = 0; i < 90; i++) {
      final day = DateTime.now().subtract(Duration(days: i));
      final due = _reminders
          .where((r) => r.isActive && r.isDueOn(day))
          .fold(0, (s, r) => s + r.dosesToday);
      if (due == 0) continue;
      final taken = _reminders.fold(0, (s, r) => s + r.dosesTakenOn(day));
      if (taken >= due) {
        count++;
      } else if (i == 0) {
        // Today is still in progress — don't break the streak yet.
        continue;
      } else {
        break;
      }
    }
    return count;
  }

  /// Adherence for the last [days] days, for the weekly chart.
  List<double> weeklyAdherence() {
    return List.generate(7, (i) {
      final day = DateTime.now().subtract(Duration(days: 6 - i));
      final due = _reminders
          .where((r) => r.isActive && r.isDueOn(day))
          .fold(0, (s, r) => s + r.dosesToday);
      if (due == 0) return 1;
      final taken = _reminders.fold(0, (s, r) => s + r.dosesTakenOn(day));
      return (taken / due).clamp(0.0, 1.0);
    });
  }

  void add({
    required String medicineId,
    required String medicineName,
    required String dosage,
    required List<String> times,
    required int durationDays,
    String notes = '',
    bool withFood = false,
    bool scannedFromImage = false,
    DateTime? startDate,
  }) {
    final reminder = Reminder(
      id: _uuid.v4().substring(0, 8),
      medicineId: medicineId,
      medicineName: medicineName,
      dosage: dosage,
      times: times,
      startDate: startDate ?? DateTime.now(),
      durationDays: durationDays,
      notes: notes,
      withFood: withFood,
      scannedFromImage: scannedFromImage,
    );
    _reminders.add(reminder);
    _persist();
    notifyListeners();
  }

  void toggle(String id) {
    final index = _reminders.indexWhere((r) => r.id == id);
    if (index < 0) return;
    _reminders[index] = _reminders[index].copyWith(
      isActive: !_reminders[index].isActive,
    );
    _persist();
    notifyListeners();
  }

  /// Marks one dose of a reminder as taken for the given time slot.
  void markDose(String id, String time, DateTime date) {
    final index = _reminders.indexWhere((r) => r.id == id);
    if (index < 0) return;
    final key = '${_dateKey(date)}|$time';
    final taken = {..._reminders[index].takenDates};
    if (!taken.add(key)) taken.remove(key);
    _reminders[index] = _reminders[index].copyWith(takenDates: taken);
    _persist();
    notifyListeners();
  }

  bool isDoseTaken(String id, String time, DateTime date) => _reminders.any(
    (r) => r.id == id && r.takenDates.contains('${_dateKey(date)}|$time'),
  );

  void remove(String id) {
    _reminders.removeWhere((r) => r.id == id);
    _persist();
    notifyListeners();
  }

  /// Removes every reminder. Used by the data-management dialog.
  void clearAll() {
    if (_reminders.isEmpty) return;
    _reminders.clear();
    _persist();
    notifyListeners();
  }

  /// Puts a removed reminder back, keeping its id and logged doses, so the
  /// undo action in the delete snackbar restores the exact same reminder.
  void restore(Reminder reminder) {
    if (_reminders.any((r) => r.id == reminder.id)) return;
    _reminders.add(reminder);
    _persist();
    notifyListeners();
  }

  /// The reminder with this id, or null.
  Reminder? byId(String id) {
    for (final r in _reminders) {
      if (r.id == id) return r;
    }
    return null;
  }

  void _persist() {
    _storage.writeList('reminders', _reminders, (r) => r.toJson());
  }

  static String _dateKey(DateTime d) =>
      '${d.year}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}';
}
