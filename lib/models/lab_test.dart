import 'package:flutter/material.dart';

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
class RangeStatus {
  const RangeStatus(this.label, this.color, this.icon);

  static RangeStatus of(LabRange r) {
    if (r.isCritical) {
      return const RangeStatus('Critical', Color(0xFFDC2F2F),
          Icons.crisis_alert_rounded);
    }
    if (r.isLow) {
      return const RangeStatus('Low', Color(0xFF3B82F6), Icons.south_rounded);
    }
    if (r.isHigh) {
      return const RangeStatus('High', Color(0xFFE8A317), Icons.north_rounded);
    }
    return const RangeStatus(
        'Normal', Color(0xFF12A150), Icons.check_circle_rounded);
  }

  final String label;
  final Color color;
  final IconData icon;
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
    required this.icon,
    required this.accentColor,
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
  final IconData icon;
  final Color accentColor;

  int get discountPercent =>
      mrp <= 0 ? 0 : (((mrp - price) / mrp) * 100).round().clamp(0, 90);
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
    required this.accentColor,
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
  final Color accentColor;
  final String recommendedFor;

  double get savings => mrp - offerPrice;

  int get discountPercent =>
      mrp <= 0 ? 0 : ((savings / mrp) * 100).round().clamp(0, 50);
}
