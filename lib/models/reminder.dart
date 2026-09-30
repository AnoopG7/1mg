import 'package:flutter/material.dart';


/// A scheduled medicine reminder.
class Reminder {
  const Reminder({
    required this.id,
    required this.medicineId,
    required this.medicineName,
    required this.dosage,
    required this.times,
    required this.startDate,
    required this.durationDays,
    this.notes = '',
    this.withFood = false,
    this.isActive = true,
    this.takenDates = const <String>{},
    this.scannedFromImage = false,
  });

  final String id;
  final String medicineId;
  final String medicineName;
  final String dosage;

  /// Times of day, e.g. ["08:00", "20:00"]
  final List<String> times;
  final DateTime startDate;
  final int durationDays;
  final String notes;
  final bool withFood;
  final bool isActive;

  /// ISO dates (yyyy-MM-dd) on which the user marked a dose as taken.
  final Set<String> takenDates;
  final bool scannedFromImage;

  /// Total expected doses over the whole course.
  int get totalDoses => durationDays * times.length;

  int get dosesTaken => takenDates.length;

  double get adherence =>
      totalDoses == 0 ? 0 : (dosesTaken / totalDoses).clamp(0.0, 1.0);

  bool isDueOn(DateTime date) {
    final d = DateTime(date.year, date.month, date.day);
    final start = DateTime(startDate.year, startDate.month, startDate.day);
    final end = start.add(Duration(days: durationDays));
    return !d.isBefore(start) && d.isBefore(end);
  }

  bool isTakenOn(DateTime date) => takenDates.contains(_key(date));

  /// Number of doses logged for a given day.
  int dosesTakenOn(DateTime date) => takenDates
      .where((k) => k.startsWith(_key(date)))
      .length;

  static String _key(DateTime d) =>
      '${d.year}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}';

  /// Doses due today for this reminder.
  int get dosesToday => times.length;

  String get nextDoseLabel {
    final now = TimeOfDay.now();
    final nowMins = now.hour * 60 + now.minute;
    for (final t in times) {
      final parts = t.split(':');
      final mins = int.parse(parts[0]) * 60 + int.parse(parts[1]);
      if (mins >= nowMins) {
        final hh = parts[0].padLeft(2, '0');
        return '$hh:${parts[1]}';
      }
    }
    return 'Tomorrow';
  }

  Reminder copyWith({
    String? medicineId,
    String? medicineName,
    String? dosage,
    List<String>? times,
    DateTime? startDate,
    int? durationDays,
    String? notes,
    bool? withFood,
    bool? isActive,
    Set<String>? takenDates,
    bool? scannedFromImage,
  }) {
    return Reminder(
      id: id,
      medicineId: medicineId ?? this.medicineId,
      medicineName: medicineName ?? this.medicineName,
      dosage: dosage ?? this.dosage,
      times: times ?? this.times,
      startDate: startDate ?? this.startDate,
      durationDays: durationDays ?? this.durationDays,
      notes: notes ?? this.notes,
      withFood: withFood ?? this.withFood,
      isActive: isActive ?? this.isActive,
      takenDates: takenDates ?? this.takenDates,
      scannedFromImage: scannedFromImage ?? this.scannedFromImage,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'medicineId': medicineId,
        'medicineName': medicineName,
        'dosage': dosage,
        'times': times,
        'startDate': startDate.toIso8601String(),
        'durationDays': durationDays,
        'notes': notes,
        'withFood': withFood,
        'isActive': isActive,
        'takenDates': takenDates.toList(),
        'scannedFromImage': scannedFromImage,
      };

  factory Reminder.fromJson(Map<String, dynamic> json) => Reminder(
        id: json['id'] as String,
        medicineId: json['medicineId'] as String? ?? '',
        medicineName: json['medicineName'] as String? ?? '',
        dosage: json['dosage'] as String? ?? '',
        times: (json['times'] as List<dynamic>? ?? []).cast<String>(),
        startDate: DateTime.tryParse(json['startDate'] as String? ?? '') ??
            DateTime.now(),
        durationDays: (json['durationDays'] as num?)?.toInt() ?? 7,
        notes: json['notes'] as String? ?? '',
        withFood: json['withFood'] as bool? ?? false,
        isActive: json['isActive'] as bool? ?? true,
        takenDates: (json['takenDates'] as List<dynamic>? ?? [])
            .cast<String>()
            .toSet(),
        scannedFromImage: json['scannedFromImage'] as bool? ?? false,
      );
}

/// Result of scanning a pill photo.
class PillMatch {
  const PillMatch({
    required this.medicineId,
    required this.medicineName,
    required this.genericName,
    required this.strength,
    required this.form,
    required this.confidence,
    required this.shape,
    required this.colorName,
    required this.manufacturer,
  });

  final String medicineId;
  final String medicineName;
  final String genericName;
  final String strength;
  final String form;

  /// 0–100
  final int confidence;
  final String shape;
  final String colorName;
  final String manufacturer;
}
