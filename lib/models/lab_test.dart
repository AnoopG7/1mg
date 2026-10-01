import 'package:flutter/material.dart';

import '../../core/ui/icon_registry.dart';

/// A measured parameter with its reference interval.
class LabRange {
  const LabRange({
    required this.parameter,
    required this.value,
    required this.normalLow,
    required this.normalHigh,
    required this.unit,
  });

  final String parameter;
  final double value;
  final double normalLow;
  final double normalHigh;
  final String unit;

  double get span => normalHigh - normalLow;
  bool get isNormal => value >= normalLow && value <= normalHigh;
  bool get isLow => value < normalLow;
  bool get isHigh => value > normalHigh;

  /// Half a reference span beyond either limit — worth a doctor call.
  ///
  /// Measured against the span rather than the raw bounds, because bounds like
  /// `normalLow: 0` (urine protein, triglycerides) would otherwise collapse
  /// the low-side test to `value <= 0` and flag a perfectly normal zero.
  bool get isCritical {
    if (span <= 0) return !isNormal;
    return value <= normalLow - span * 0.5 ||
        value >= normalHigh + span * 0.5;
  }

  /// 0 = value at/below low limit, 1 = value at/above high limit.
  double get normalizedPosition {
    final lower = normalLow * 0.6;
    final upper = normalHigh * 1.4;
    if (upper <= lower) return 0.5;
    return ((value - lower) / (upper - lower)).clamp(0.0, 1.0);
  }

  /// 0–1 width of the green normal band, used to draw the bar.
  double get bandStart {
    final lower = normalLow * 0.6;
    final upper = normalHigh * 1.4;
    if (upper <= lower) return 0.5;
    return ((normalLow - lower) / (upper - lower)).clamp(0.0, 1.0);
  }

  double get bandEnd {
    final lower = normalLow * 0.6;
    final upper = normalHigh * 1.4;
    if (upper <= lower) return 0.5;
    return ((normalHigh - lower) / (upper - lower)).clamp(0.0, 1.0);
  }

  String get displayValue {
    final v = value == value.roundToDouble()
        ? value.toStringAsFixed(0)
        : value.toStringAsFixed(1);
    return '$v $unit';
  }

  Map<String, dynamic> toJson() => {
        'parameter': parameter,
        'value': value,
        'normalLow': normalLow,
        'normalHigh': normalHigh,
        'unit': unit,
      };

  factory LabRange.fromJson(Map<String, dynamic> json) => LabRange(
        parameter: json['parameter'] as String? ?? '',
        value: (json['value'] as num?)?.toDouble() ?? 0,
        normalLow: (json['normalLow'] as num?)?.toDouble() ?? 0,
        normalHigh: (json['normalHigh'] as num?)?.toDouble() ?? 0,
        unit: json['unit'] as String? ?? '',
      );

  String get displayRange {
    final lo = normalLow == normalLow.roundToDouble()
        ? normalLow.toStringAsFixed(0)
        : normalLow.toStringAsFixed(1);
    final hi = normalHigh == normalHigh.roundToDouble()
        ? normalHigh.toStringAsFixed(0)
        : normalHigh.toStringAsFixed(1);
    return '$lo – $hi $unit';
  }
}

/// Status chip text + colour for a lab value.
///
/// [iconKey] and [colorValue] are primitives so this serialises; the [icon] and
/// [color] getters resolve them at the UI edge.
class RangeStatus {
  const RangeStatus(this.label, this.colorValue, this.iconKey);

  static RangeStatus of(LabRange r) {
    if (r.isCritical) {
      return const RangeStatus('Critical', 0xFFDC2F2F, 'range_critical');
    }
    if (r.isLow) {
      return const RangeStatus('Low', 0xFF3B82F6, 'range_low');
    }
    if (r.isHigh) {
      return const RangeStatus('High', 0xFFE8A317, 'range_high');
    }
    return const RangeStatus('Normal', 0xFF12A150, 'range_normal');
  }

  final String label;
  final int colorValue;
  final String iconKey;

  Color get color => IconRegistry.colorFromHex(colorValue);
  IconData get icon => IconRegistry.resolve(iconKey);
}

/// A single lab test that can be booked.
class LabTest {
  const LabTest({
    required this.id,
    required this.name,
    required this.shortName,
    required this.description,
    required this.price,
    required this.mrp,
    required this.preparation,
    required this.fastingRequired,
    required this.reportTimeHours,
    required this.parameters,
    required this.iconKey,
    required this.accentColorValue,
  });

  final String id;
  final String name;
  final String shortName;
  final String description;
  final double price;
  final double mrp;

  /// Preparation instructions shown before the test.
  final List<String> preparation;
  final bool fastingRequired;
  final int reportTimeHours;
  final List<LabRange> parameters;

  /// Registry key — see [IconRegistry]. Stored as a string so it serialises.
  final String iconKey;

  /// ARGB int so the accent tint serialises.
  final int accentColorValue;

  IconData get icon => IconRegistry.resolve(iconKey);
  Color get accentColor => IconRegistry.colorFromHex(accentColorValue);

  int get discountPercent =>
      mrp <= 0 ? 0 : (((mrp - price) / mrp) * 100).round().clamp(0, 90);

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'shortName': shortName,
        'description': description,
        'price': price,
        'mrp': mrp,
        'preparation': preparation,
        'fastingRequired': fastingRequired,
        'reportTimeHours': reportTimeHours,
        'parameters': parameters.map((p) => p.toJson()).toList(),
        'iconKey': iconKey,
        'accentColorValue': accentColorValue,
      };

  factory LabTest.fromJson(Map<String, dynamic> json) => LabTest(
        id: json['id'] as String? ?? '',
        name: json['name'] as String? ?? '',
        shortName: json['shortName'] as String? ?? '',
        description: json['description'] as String? ?? '',
        price: (json['price'] as num?)?.toDouble() ?? 0,
        mrp: (json['mrp'] as num?)?.toDouble() ?? 0,
        preparation: (json['preparation'] as List<dynamic>? ?? const [])
            .map((e) => e.toString())
            .toList(),
        fastingRequired: json['fastingRequired'] as bool? ?? false,
        reportTimeHours: (json['reportTimeHours'] as num?)?.toInt() ?? 24,
        parameters: (json['parameters'] as List<dynamic>? ?? const [])
            .whereType<Map<String, dynamic>>()
            .map(LabRange.fromJson)
            .toList(),
        iconKey: json['iconKey'] as String? ?? 'lab_cbc',
        accentColorValue: (json['accentColorValue'] as num?)?.toInt() ?? 0xFF2C6BED,
      );
}

/// A health package combining several tests with a big discount.
class LabBundle {
  const LabBundle({
    required this.id,
    required this.name,
    required this.tagline,
    required this.testIds,
    required this.offerPrice,
    required this.mrp,
    required this.badge,
    required this.accentColorValue,
    required this.recommendedFor,
  });

  final String id;
  final String name;
  final String tagline;
  final List<String> testIds;

  /// Price after the bundle discount.
  final double offerPrice;

  /// Sum of individual test prices — used for the price comparison UI.
  final double mrp;
  final String badge;

  /// ARGB int so the accent tint serialises.
  final int accentColorValue;
  final String recommendedFor;

  Color get accentColor => IconRegistry.colorFromHex(accentColorValue);

  double get savings => mrp - offerPrice;

  int get discountPercent =>
      mrp <= 0 ? 0 : ((savings / mrp) * 100).round().clamp(0, 50);

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'tagline': tagline,
        'testIds': testIds,
        'offerPrice': offerPrice,
        'mrp': mrp,
        'badge': badge,
        'accentColorValue': accentColorValue,
        'recommendedFor': recommendedFor,
      };

  factory LabBundle.fromJson(Map<String, dynamic> json) => LabBundle(
        id: json['id'] as String? ?? '',
        name: json['name'] as String? ?? '',
        tagline: json['tagline'] as String? ?? '',
        testIds: (json['testIds'] as List<dynamic>? ?? const [])
            .map((e) => e.toString())
            .toList(),
        offerPrice: (json['offerPrice'] as num?)?.toDouble() ?? 0,
        mrp: (json['mrp'] as num?)?.toDouble() ?? 0,
        badge: json['badge'] as String? ?? '',
        accentColorValue: (json['accentColorValue'] as num?)?.toInt() ?? 0xFF2C6BED,
        recommendedFor: json['recommendedFor'] as String? ?? '',
      );
}
