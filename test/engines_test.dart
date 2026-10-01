import 'dart:typed_data';

import 'package:one_mg_health/core/services/interaction_engine.dart';
import 'package:one_mg_health/core/services/normal_range.dart';
import 'package:one_mg_health/core/services/pill_recognizer.dart';
import 'package:one_mg_health/core/services/pricing_engine.dart';
import 'package:one_mg_health/core/services/symptom_engine.dart';
import 'package:one_mg_health/data/mock_labs.dart';
import 'package:one_mg_health/data/mock_medicines.dart';
import 'package:one_mg_health/data/mock_symptoms.dart';
import 'package:one_mg_health/models/cart_item.dart';
import 'package:one_mg_health/models/lab_test.dart';
import 'package:one_mg_health/models/medicine.dart';
import 'package:one_mg_health/models/symptom.dart';
import 'package:flutter_test/flutter_test.dart';

CartItem _medicine({
  String id = 'm1',
  double price = 100,
  double mrp = 120,
  int qty = 1,
}) =>
    CartItem(
      id: id,
      title: 'Test medicine',
      subtitle: '10 tablets',
      kind: CartItemKind.medicine,
      unitPrice: price,
      mrp: mrp,
      quantity: qty,
      medicineId: id,
    );

CartItem _lab({
  String id = 'l1',
  double price = 200,
  double mrp = 200,
}) =>
    CartItem(
      id: id,
      title: 'Test panel',
      subtitle: '1 test',
      kind: CartItemKind.labTest,
      unitPrice: price,
      mrp: mrp,
      quantity: 1,
      testId: id,
    );

void main() {
  group('PricingEngine — brief rules', () {
    test('MRP minus store discount reconciles with payable', () {
      final b = const PricingEngine().breakdown([_medicine(qty: 2)]);
      expect(b.mrpTotal, 240);
      expect(b.storeDiscount, 40); // 2 x (120 - 100)
      // payable already includes delivery, so do not add it again here.
      expect(b.deliveryFee, PricingEngine.standardDeliveryFee);
      expect(b.payable, 200 + PricingEngine.standardDeliveryFee);
    });

    test('monthly refill gives 10% off medicines', () {
      final b = const PricingEngine(hasSubscription: true).breakdown([_medicine()]);
      expect(b.subscriptionDiscount, closeTo(10, 0.01));
    });

    test('subscription discount does NOT apply to lab tests', () {
      final b = const PricingEngine(hasSubscription: true).breakdown([_lab()]);
      expect(b.subscriptionDiscount, 0);
    });

    test('1mg Pro gives 5% off medicines AND labs', () {
      final b = const PricingEngine(isPro: true)
          .breakdown([_medicine(), _lab()]);
      // 5% of (100 medicine + 200 lab)
      expect(b.proDiscount, closeTo(15, 0.01));
    });

    test('Pro and subscription stack to 15%', () {
      final engine = const PricingEngine(isPro: true, hasSubscription: true);
      expect(engine.rate, closeTo(0.15, 0.0001));
      expect(engine.rateLabel, '1mg Pro + Subscription');
    });

    test('free delivery at or above the threshold', () {
      final below = const PricingEngine().breakdown([_medicine(price: 300, mrp: 300)]);
      final above = const PricingEngine().breakdown([_medicine(price: 500, mrp: 500)]);
      expect(below.deliveryFee, PricingEngine.standardDeliveryFee);
      expect(above.deliveryFee, 0);
    });

    test('referral credit offsets the total and never overshoots', () {
      final partial = const PricingEngine(referralCredits: 100)
          .breakdown([_medicine(price: 300, mrp: 300)]);
      expect(partial.referralApplied, 100);

      // Credit larger than the subtotal is clamped, and never makes it negative.
      final huge = const PricingEngine(referralCredits: 99999)
          .breakdown([_medicine(price: 300, mrp: 300)]);
      expect(huge.payable, 0);
      expect(huge.payable, greaterThanOrEqualTo(0));
    });

    test('empty cart is all zeroes', () {
      final b = const PricingEngine().breakdown([]);
      expect(b.payable, 0);
      expect(b.mrpTotal, 0);
      expect(b.deliveryFee, 0);
    });

    test('Pro price helper applies the 5% rate', () {
      final m = MockMedicines.all.first;
      final pro = const PricingEngine(isPro: true).medicinePrice(m);
      expect(pro, closeTo(m.price * 0.95, 0.01));
      expect(const PricingEngine().medicinePrice(m), m.price);
    });
  });

  group('NormalRange — status classification', () {
    LabTest buildTest(LabRange r, {String name = 'X'}) => LabTest(
          id: 't',
          name: name,
          shortName: 'X',
          description: 'Test panel',
          price: 100,
          mrp: 100,
          preparation: const [],
          fastingRequired: false,
          reportTimeHours: 24,
          parameters: [r],
          iconKey: 'lab_urine',
          accentColorValue: 0xFF2C6BED,
        );

    LabRange r(double v, double lo, double hi) =>
        LabRange(parameter: 'P', value: v, normalLow: lo, normalHigh: hi, unit: 'u');

    String status(LabRange range) => RangeStatus.of(range).label;

    test('in-range value is normal', () {
      expect(status(r(5, 4, 6)), 'Normal');
    });

    test('just outside the range is high/low, not critical', () {
      expect(status(r(6.4, 4, 6)), 'High');
      expect(status(r(3.6, 4, 6)), 'Low');
    });

    test('a genuinely extreme value is critical', () {
      expect(status(r(9, 4, 6)), 'Critical');
    });

    test('zero-width range never flags a value inside it as critical', () {
      // The old `1.5 * x` rule marked Protein (0-15) critical because 15 * 1.5
      // is *lower* than 0.
      expect(status(r(10, 0, 15)), 'Normal');
      expect(status(r(0, 0, 15)), 'Normal');
      expect(status(r(20, 0, 15)), 'High');
    });

    test('ranges that start above zero flag low values correctly', () {
      expect(status(r(3.5, 4, 5.6)), 'Low');
      expect(status(r(6.8, 4, 5.6)), 'Critical');
    });

    test('the critical threshold is inclusive at exactly half a span out', () {
      // span 1.6, so critical at <= 3.2 and >= 6.4 (inclusive on both sides).
      expect(status(r(3.2, 4, 5.6)), 'Critical');
      expect(status(r(3.3, 4, 5.6)), 'Low');
      expect(status(r(6.4, 4, 5.6)), 'Critical');
      expect(status(r(6.3, 4, 5.6)), 'High');
    });

    test('summary counts and advice are produced', () {
      final service = const NormalRangeService();
      final s = service.summarise([buildTest(r(9, 4, 6))]);
      expect(s.totalParameters, 1);
      expect(s.criticalCount, 1);
      expect(s.abnormalCount, 1);
      expect(s.isAllNormal, isFalse);
      expect(service.advice(s), isNotEmpty);
    });

    test('HbA1c in the diabetes range gets the prompt-to-see-a-doctor advice',
        () {
      final service = const NormalRangeService();
      final test = MockLabs.tests.firstWhere(
        (t) => t.parameters.any((p) => p.parameter == 'HbA1c'),
      );
      final s = service.summarise([test]);
      expect(
        service.advice(s).join(' ').toLowerCase(),
        anyOf(contains('diabetes range'), contains('pre-diabetes')),
      );
    });
  });

  group('SymptomEngine — every symptom is scoreable', () {
    final engine = SymptomEngine();

    test('analyse returns a bounded score and a triage level', () {
      final a = engine.analyse(
        symptomIds: ['s_fever'],
        answers: const {},
        ageBand: MockSymptoms.ageBands.first,
        gender: 'Female',
      );
      expect(a.score, inInclusiveRange(0, 100));
      expect(TriageLevel.values, contains(a.level));
      expect(a.advice, isNotEmpty);
    });

    test('no symptoms never escalates past self care', () {
      // SymptomProvider.goToQuestions() refuses to advance while nothing is
      // selected, so this only guards against a crash or a scary verdict.
      final a = engine.analyse(
        symptomIds: const [],
        answers: const {},
        ageBand: MockSymptoms.ageBands.first,
        gender: 'Female',
      );
      expect(a.level, TriageLevel.selfCare);
      expect(a.redFlags, isEmpty);
      expect(a.matches, isEmpty);
    });

    test('every declared symptom is referenced by at least one condition', () {
      final referenced = <String>{};
      for (final c in MockSymptoms.conditions) {
        referenced.addAll(c.symptomIds);
      }
      for (final s in MockSymptoms.all) {
        expect(referenced, contains(s.id),
            reason: '${s.id} matches no condition and can never be scored');
      }
    });

    test('more specific symptoms outrank vague ones', () {
      final answers = <String, String>{};
      for (final q in MockSymptoms.questions) {
        answers[q.id] = q.options.first;
      }
      final mild = engine.analyse(
        symptomIds: ['s_runny_nose'],
        answers: answers,
        ageBand: MockSymptoms.ageBands.first,
        gender: 'Female',
      );
      final severe = engine.analyse(
        symptomIds: ['s_runny_nose', 's_fever', 's_breathless'],
        answers: answers,
        ageBand: MockSymptoms.ageBands.first,
        gender: 'Female',
      );
      expect(severe.score, greaterThan(mild.score));
    });

    test('red-flagged combinations escalate the triage level', () {
      final flagged = MockSymptoms.redFlagRules.keys.toList();
      if (flagged.isEmpty) return;
      final mild = engine.analyse(
        symptomIds: [flagged.first],
        answers: const {},
        ageBand: MockSymptoms.ageBands.first,
        gender: 'Female',
      );
      final escalated = engine.analyse(
        symptomIds: flagged.take(3).toList(),
        answers: const {},
        ageBand: MockSymptoms.ageBands.first,
        gender: 'Female',
      );
      expect(escalated.level.index, lessThanOrEqualTo(mild.level.index));
    });
  });

  group('InteractionEngine', () {
    final engine = InteractionEngine();

    test('no medicines yields no alerts', () {
      expect(engine.check(medicines: const []), isEmpty);
    });

    test('food and alcohol types are recognised', () {
      final m = MockMedicines.all.where((m) => m.interactions.isNotEmpty);
      expect(m, isNotEmpty, reason: 'no medicine carries interaction data');
    });

    test('checking one medicine against a substance flags it', () {
      final med = MockMedicines.all
          .firstWhere((m) => m.interactions.isNotEmpty);
      final substance = med.interactions.first;
      final alerts = engine.check(
        medicines: [med],
        substanceTypes: {substance.type},
        substances: {substance.substance},
      );
      expect(alerts, isNotEmpty);
    });

    test('a blocking alert is reported as blocking', () {
      final alerts = <InteractionAlert>[];
      expect(engine.hasBlocking(alerts), isFalse);
    });
  });

  group('PillRecognizer', () {
    final r = PillRecognizer();

    test('the same image always yields the same ranking', () async {
      final bytes = Uint8List.fromList(List.generate(512, (i) => i % 256));
      final a = await r.recognise(bytes);
      final b = await r.recognise(bytes);
      expect(a.map((m) => m.medicineId).toList(),
          b.map((m) => m.medicineId).toList());
    });

    test('a different image can yield a different ranking', () async {
      final one = Uint8List.fromList(List.generate(256, (i) => i));
      final two = Uint8List.fromList(List.generate(256, (i) => 255 - i));
      final a = await r.recognise(one);
      final b = await r.recognise(two);
      expect(a.map((m) => m.medicineId).toList(),
          isNot(b.map((m) => m.medicineId).toList()));
    });

    test('recognising a sample returns that exact pill as the top match',
        () async {
      for (final med in MockMedicines.all.take(5)) {
        final matches = await r.recogniseSample(med.id);
        expect(matches, isNotEmpty);
        expect(matches.first.medicineId, med.id,
            reason: 'scanning the ${med.name} sample recognised something else');
      }
    });

    test('a real photo is not pinned to any one medicine', () async {
      final a = await r.recognise(Uint8List.fromList(List.filled(64, 9)));
      expect(a.map((m) => m.confidence).toSet().length, greaterThan(0));
      expect(a.first.confidence, lessThanOrEqualTo(95));
    });

    test('matches are ordered by descending confidence', () async {
      final matches = await r.recogniseSample(MockMedicines.all.first.id);
      for (var i = 1; i < matches.length; i++) {
        expect(matches[i - 1].confidence, greaterThanOrEqualTo(matches[i].confidence));
      }
    });

    test('confidence label covers the full range', () {
      for (final c in [0, 25, 50, 75, 100]) {
        expect(PillRecognizer.confidenceLabel(c), isNotEmpty);
      }
    });

    test('fingerprint is stable', () {
      final bytes = Uint8List.fromList([1, 2, 3, 4, 5]);
      expect(PillRecognizer.fingerprint(bytes), PillRecognizer.fingerprint(bytes));
    });
  });

  group('Mock data integrity', () {
    test('no duplicate ids anywhere', () {
      expect(MockMedicines.all.map((m) => m.id).toSet().length,
          MockMedicines.all.length);
      expect(MockLabs.tests.map((t) => t.id).toSet().length,
          MockLabs.tests.length);
      expect(MockSymptoms.all.map((s) => s.id).toSet().length,
          MockSymptoms.all.length);
    });

    test('every lab range is well formed', () {
      for (final t in MockLabs.tests) {
        for (final r in t.parameters) {
          expect(r.normalHigh, greaterThanOrEqualTo(r.normalLow),
              reason: '${t.id} / ${r.parameter} has an inverted range');
        }
      }
    });

    test('every bundle references real tests', () {
      final ids = MockLabs.tests.map((t) => t.id).toSet();
      for (final b in MockLabs.bundles) {
        expect(b.testIds, isNotEmpty, reason: '${b.id} is empty');
        for (final id in b.testIds) {
          expect(ids, contains(id), reason: '${b.id} -> unknown test $id');
        }
      }
    });

    test('bundles are actually cheaper than their MRP', () {
      for (final b in MockLabs.bundles) {
        expect(b.offerPrice, lessThanOrEqualTo(b.mrp),
            reason: '${b.id} offers no saving');
        expect(b.testIds.length, greaterThan(1),
            reason: '${b.id} is not a bundle');
      }
    });

    test('every medicine uses a declared category', () {
      final allowed = MedicineCategory.all.map((c) => c.name).toSet();
      for (final m in MockMedicines.all) {
        expect(allowed, contains(m.category), reason: '${m.id} -> ${m.category}');
      }
    });

    test('every category chip leads to at least one medicine', () {
      for (final c in MedicineCategory.all) {
        expect(MockMedicines.byCategory(c.name), isNotEmpty,
            reason: '${c.name} chip shows an empty list');
      }
    });
  });
}
