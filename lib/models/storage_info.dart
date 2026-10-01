import 'package:flutter/material.dart';

import '../../core/ui/icon_registry.dart';

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

  /// Registry key for the icon that matches this storage condition.
  String get iconKey => isRefrigerated
      ? 'storage_cold'
      : isSensitive
          ? 'storage_light'
          : 'storage_general';

  IconData get icon => IconRegistry.resolve(iconKey);

  Map<String, dynamic> toJson() => {
        'temperatureRange': temperatureRange,
        'temperatureCelsius': temperatureCelsius,
        'light': light,
        'humidity': humidity,
        'instructions': instructions,
      };

  factory StorageInfo.fromJson(Map<String, dynamic> json) => StorageInfo(
        temperatureRange: json['temperatureRange'] as String? ?? '',
        temperatureCelsius: (json['temperatureCelsius'] as num?)?.toDouble() ?? 25,
        light: json['light'] as String? ?? '',
        humidity: json['humidity'] as String? ?? '',
        instructions: json['instructions'] as String? ?? '',
      );
}
