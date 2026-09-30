import 'package:flutter/material.dart';

/// How and where a medicine must be stored.
class StorageInfo {
  const StorageInfo({
    required this.temperatureRange,
    required this.light,
    required this.humidity,
    required this.instructions,
    required this.temperatureCelsius,
  });

  /// e.g. "Below 25°C"
  final String temperatureRange;
  final double temperatureCelsius;
  final String light;
  final String humidity;
  final String instructions;

  /// Generic storage buckets used by the storage-comparison UI.
  static const String cool = 'Cool & dry place';
  static const String room = 'Below 25°C, room temperature';
  static const String refrigerated = 'Refrigerated 2–8°C';
  static const String freezer = 'Deep frozen below -20°C';

  bool get isRefrigerated => temperatureCelsius <= 8;
  bool get isSensitive => temperatureCelsius <= 8 || light.contains('protect');

  IconData get icon => isRefrigerated
      ? Icons.ac_unit_rounded
      : isSensitive
          ? Icons.wb_sunny_outlined
          : Icons.inventory_2_outlined;
}
