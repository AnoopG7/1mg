import 'dart:convert';
import 'dart:typed_data';

import 'package:crypto/crypto.dart';

import '../../data/mock_medicines.dart';
import '../../models/reminder.dart';

/// Simulated pill image recognition.
///
/// A real build would run a TFLite classifier here. For the college demo this
/// derives a stable pseudo-random score from the image bytes, so picking the
/// same photo twice always returns the same ranked matches — which looks and
/// behaves like real recognition.
class PillRecognizer {
  const PillRecognizer();

  /// Milliseconds of "analysing" delay, so the UI shows a scanning state.
  static const Duration analysisDelay = Duration(milliseconds: 1800);

  /// Matches against a real picked image.
  Future<List<PillMatch>> recognise(Uint8List imageBytes) async {
    await Future<void>.delayed(analysisDelay);
    final seed = _seedOf(imageBytes);
    return _rank(seed);
  }

  /// Matches without an image — used by the "try a sample pill" buttons.
  ///
  /// The caller has picked a specific medicine, so that pill is pinned to the
  /// top of the ranking. Without the pin the pseudo-random score would usually
  /// surface a different tablet, which reads as a recognition failure.
  Future<List<PillMatch>> recogniseSample(String medicineId) async {
    await Future<void>.delayed(analysisDelay);
    final seed = medicineId.codeUnits.fold<int>(7, (a, b) => (a * 31 + b) & 0x7fffffff);
    return _rank(seed, pinnedId: medicineId);
  }

  /// Deterministic 31-bit seed from the image bytes.
  int _seedOf(Uint8List bytes) {
    if (bytes.isEmpty) return 12345;
    final digest = md5.convert(bytes);
    final raw = digest.bytes.take(4).toList();
    return raw.fold<int>(17, (a, b) => (a * 131 + b) & 0x7fffffff);
  }

  /// Produces a ranked, confidence-sorted match list.
  ///
  /// When [pinnedId] is given, that medicine always ranks first with a
  /// confidence above anything the pseudo-random path can produce (max 95).
  List<PillMatch> _rank(int seed, {String? pinnedId}) {
    final pool = List.of(MockMedicines.all);
    final matches = <PillMatch>[];

    for (final med in pool) {
      // Stable per-medicine score derived from the seed.
      final h = _mix(seed ^ med.id.hashCode);
      final pinned = pinnedId != null && med.id == pinnedId;
      final confidence = pinned ? 96 : 18 + (h % 78);
      matches.add(PillMatch(
        medicineId: med.id,
        medicineName: med.name,
        genericName: med.genericName,
        strength: med.strength,
        form: med.form,
        confidence: confidence,
        shape: med.pillShape,
        colorName: _colorName(med.pillColor),
        manufacturer: med.manufacturer,
      ));
    }

    matches.sort((a, b) {
      final byConfidence = b.confidence.compareTo(a.confidence);
      // Keep the order stable for the (unlikely) equal-confidence tie so the
      // ranking never changes between builds.
      return byConfidence != 0 ? byConfidence : a.medicineId.compareTo(b.medicineId);
    });
    return matches.take(5).toList(growable: false);
  }

  int _mix(int value) {
    var x = value & 0x7fffffff;
    x = (x ^ 61) ^ (x >> 16);
    x = (x + (x << 3)) & 0x7fffffff;
    x = x ^ (x >> 4);
    x = (x * 0x27d4eb2d) & 0x7fffffff;
    x = x ^ (x >> 15);
    return x;
  }

  String _colorName(int argb) {
    final hex = argb.toRadixString(16).padLeft(8, '0').substring(2).toUpperCase();
    final r = int.parse(hex.substring(0, 2), radix: 16);
    final g = int.parse(hex.substring(2, 4), radix: 16);
    final b = int.parse(hex.substring(4, 6), radix: 16);
    final max = [r, g, b].reduce((a, b) => a > b ? a : b);
    final min = [r, g, b].reduce((a, b) => a < b ? a : b);

    if (max - min < 18) {
      if (max > 235) return 'White';
      if (max > 200) return 'Off-white';
      if (max < 70) return 'Black';
      return 'Grey';
    }
    if (max == r) return (g > b) ? 'Orange' : 'Red';
    if (max == g) return 'Green';
    return (r > g) ? 'Purple' : 'Blue';
  }

  /// Human-readable description of what a confidence score means.
  static String confidenceLabel(int confidence) {
    if (confidence >= 80) return 'Strong match';
    if (confidence >= 60) return 'Likely match';
    if (confidence >= 40) return 'Possible match';
    return 'Low confidence';
  }

  /// A debug fingerprint of the image, shown as a "scan id".
  static String fingerprint(Uint8List bytes) {
    if (bytes.isEmpty) return 'SCAN-DEMO';
    final d = md5.convert(bytes).toString();
    return d.substring(0, 8).toUpperCase();
  }

  /// Pretty-prints a byte count for the scanning overlay.
  static String describeBytes(int bytes) {
    if (bytes < 1024) return '$bytes B';
    if (bytes < 1024 * 1024) return '${(bytes / 1024).toStringAsFixed(0)} KB';
    return '${(bytes / (1024 * 1024)).toStringAsFixed(1)} MB';
  }

  static String base64Preview(Uint8List bytes, {int maxChars = 24}) {
    if (bytes.isEmpty) return '';
    final b64 = base64Encode(bytes.take(maxChars).toList());
    return b64;
  }
}
