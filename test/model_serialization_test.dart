import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:one_mg_health/core/services/symptom_engine.dart';
import 'package:one_mg_health/core/ui/icon_registry.dart';
import 'package:one_mg_health/data/mock_articles.dart';
import 'package:one_mg_health/data/mock_labs.dart';
import 'package:one_mg_health/data/mock_medicines.dart';
import 'package:one_mg_health/data/mock_symptoms.dart';
import 'package:one_mg_health/models/article.dart';
import 'package:one_mg_health/models/cart_item.dart';
import 'package:one_mg_health/models/drug_interaction.dart';
import 'package:one_mg_health/models/lab_test.dart';
import 'package:one_mg_health/models/medicine.dart';
import 'package:one_mg_health/models/pregnancy_category.dart';
import 'package:one_mg_health/models/storage_info.dart';
import 'package:one_mg_health/models/subscription.dart';
import 'package:one_mg_health/models/symptom.dart';

/// These tests exist because the backend migration requires every model to
/// survive a round trip through JSON. If a field is added to a model without
/// updating toJson/fromJson, one of these tests fails before Firestore is ever
/// wired up.
void main() {
  group('Catalogue round trips', () {
    test('every Medicine survives a JSON round trip', () {
      for (final m in MockMedicines.all) {
        final back = Medicine.fromJson(
          jsonDecode(jsonEncode(m.toJson())) as Map<String, dynamic>,
        );
        expect(back.id, m.id);
        expect(back.name, m.name);
        expect(back.genericName, m.genericName);
        expect(back.strength, m.strength);
        expect(back.category, m.category);
        expect(back.price, m.price);
        expect(back.mrp, m.mrp);
        expect(back.rating, m.rating);
        expect(back.reviewCount, m.reviewCount);
        expect(back.rx, m.rx);
        expect(back.otc, m.otc);
        expect(back.prescriptionRequired, m.prescriptionRequired);
        expect(back.manufacturer, m.manufacturer);
        expect(back.pillShape, m.pillShape);
        expect(back.pillColor, m.pillColor);
        expect(back.lactationSafe, m.lactationSafe);
        expect(back.uses, m.uses);
        expect(back.composition.length, m.composition.length);
        expect(back.sideEffects.length, m.sideEffects.length);
        expect(back.interactions.length, m.interactions.length);
        expect(back.pregnancyCategory, m.pregnancyCategory);
        expect(back.storage.temperatureRange, m.storage.temperatureRange);
        expect(back.storage.temperatureCelsius, m.storage.temperatureCelsius);
        expect(back.storage.instructions, m.storage.instructions);
      }
    });

    test('every LabTest survives a JSON round trip', () {
      for (final t in MockLabs.tests) {
        final back = LabTest.fromJson(
          jsonDecode(jsonEncode(t.toJson())) as Map<String, dynamic>,
        );
        expect(back.id, t.id);
        expect(back.name, t.name);
        expect(back.shortName, t.shortName);
        expect(back.price, t.price);
        expect(back.mrp, t.mrp);
        expect(back.fastingRequired, t.fastingRequired);
        expect(back.reportTimeHours, t.reportTimeHours);
        expect(back.preparation, t.preparation);
        expect(back.iconKey, t.iconKey);
        expect(back.accentColorValue, t.accentColorValue);
        expect(back.parameters.length, t.parameters.length);
      }
    });

    test('every LabBundle survives a JSON round trip', () {
      for (final b in MockLabs.bundles) {
        final back = LabBundle.fromJson(
          jsonDecode(jsonEncode(b.toJson())) as Map<String, dynamic>,
        );
        expect(back.id, b.id);
        expect(back.name, b.name);
        expect(back.offerPrice, b.offerPrice);
        expect(back.mrp, b.mrp);
        expect(back.testIds, b.testIds);
        expect(back.badge, b.badge);
        expect(back.accentColorValue, b.accentColorValue);
      }
    });

    test('every Article survives a JSON round trip', () {
      for (final a in MockArticles.all) {
        final back = Article.fromJson(
          jsonDecode(jsonEncode(a.toJson())) as Map<String, dynamic>,
        );
        expect(back.id, a.id);
        expect(back.title, a.title);
        expect(back.summary, a.summary);
        expect(back.body, a.body);
        expect(back.category, a.category);
        expect(back.readMinutes, a.readMinutes);
        expect(back.views, a.views);
        expect(back.likes, a.likes);
        expect(back.tags, a.tags);
        expect(back.accentColorValue, a.accentColorValue);
        expect(back.publishedOn, a.publishedOn);
        expect(back.doctor.name, a.doctor.name);
        expect(back.doctor.verified, a.doctor.verified);
        expect(back.doctor.experienceYears, a.doctor.experienceYears);
      }
    });

    test('every Symptom and Condition survives a JSON round trip', () {
      for (final s in MockSymptoms.all) {
        final back = Symptom.fromJson(
          jsonDecode(jsonEncode(s.toJson())) as Map<String, dynamic>,
        );
        expect(back.id, s.id);
        expect(back.name, s.name);
        expect(back.iconKey, s.iconKey);
        expect(back.category, s.category);
      }
      for (final c in MockSymptoms.conditions) {
        final back = Condition.fromJson(
          jsonDecode(jsonEncode(c.toJson())) as Map<String, dynamic>,
        );
        expect(back.id, c.id);
        expect(back.name, c.name);
        expect(back.symptomIds, c.symptomIds);
        expect(back.recommendations, c.recommendations);
        expect(back.selfCare, c.selfCare);
        expect(back.seeDoctorWithinHours, c.seeDoctorWithinHours);
      }
    });

    test('every SymptomQuestion survives a JSON round trip', () {
      for (final q in MockSymptoms.questions) {
        final back = SymptomQuestion.fromJson(
          jsonDecode(jsonEncode(q.toJson())) as Map<String, dynamic>,
        );
        expect(back.id, q.id);
        expect(back.prompt, q.prompt);
        expect(back.options, q.options);
        expect(back.isMultiSelect, q.isMultiSelect);
        expect(back.iconKey, q.iconKey);
      }
    });
  });

  group('User data round trips', () {
    test('CartItem keeps every field', () {
      const item = CartItem(
        id: 'm1',
        title: 'Paracetamol',
        subtitle: 'strip of 10',
        kind: CartItemKind.medicine,
        unitPrice: 32.5,
        mrp: 38,
        quantity: 3,
        medicineId: 'm1',
        isPrescription: true,
      );
      final back = CartItem.fromJson(
        jsonDecode(jsonEncode(item.toJson())) as Map<String, dynamic>,
      );
      expect(back.id, item.id);
      expect(back.kind, CartItemKind.medicine);
      expect(back.unitPrice, 32.5);
      expect(back.mrp, 38);
      expect(back.quantity, 3);
      expect(back.isPrescription, isTrue);
      expect(back.medicineId, 'm1');
      expect(back.lineTotal, item.lineTotal);
    });

    test('Order keeps items, totals and status', () {
      final order = Order(
        id: 'o1',
        placedAt: DateTime(2026, 3, 4, 11, 30),
        items: const [
          CartItem(
            id: 'm1',
            title: 'A',
            subtitle: '',
            kind: CartItemKind.medicine,
            unitPrice: 100,
            mrp: 120,
            quantity: 2,
          ),
        ],
        total: 200,
        status: OrderStatus.shipped,
        deliveryAddress: '12 MG Road, Mumbai 400001',
        estimatedDelivery: DateTime(2026, 3, 6),
      );
      final back = Order.fromJson(
        jsonDecode(jsonEncode(order.toJson())) as Map<String, dynamic>,
      );
      expect(back.id, 'o1');
      expect(back.total, 200);
      expect(back.status, OrderStatus.shipped);
      expect(back.items.single.quantity, 2);
      expect(back.placedAt, order.placedAt);
      expect(back.estimatedDelivery, order.estimatedDelivery);
      expect(back.itemCount, 2);
    });

    test('Address keeps every field', () {
      const a = Address(
        id: 'a1',
        name: 'Anoop',
        phone: '1234567890',
        line1: '12 MG Road',
        line2: 'Andheri East',
        city: 'Mumbai',
        pincode: '400001',
        label: 'Home',
        isDefault: true,
      );
      final back = Address.fromJson(
        jsonDecode(jsonEncode(a.toJson())) as Map<String, dynamic>,
      );
      expect(back.name, 'Anoop');
      expect(back.pincode, '400001');
      expect(back.isDefault, isTrue);
      expect(back.oneLine, a.oneLine);
    });

    test('ProPlan keeps active state and both dates', () {
      final plan = ProPlan(
        active: true,
        expiry: DateTime(2027, 1, 1),
        purchasedAt: DateTime(2026, 1, 1),
      );
      final back = ProPlan.fromJson(
        jsonDecode(jsonEncode(plan.toJson())) as Map<String, dynamic>,
      );
      expect(back.active, isTrue);
      expect(back.expiry, plan.expiry);
      expect(back.purchasedAt, plan.purchasedAt);
    });

    test('a null ProPlan expiry stays null rather than throwing', () {
      final back = ProPlan.fromJson(
        jsonDecode(jsonEncode(const ProPlan(active: false, expiry: null).toJson()))
            as Map<String, dynamic>,
      );
      expect(back.expiry, isNull);
      expect(back.purchasedAt, isNull);
      expect(back.isValid, isFalse);
    });

    test('ReferralWallet keeps credits and the referral list', () {
      final wallet = ReferralWallet(
        myCode: 'ANOO123',
        credits: 200,
        referrals: [
          Referral(
            code: 'ANOO123',
            name: 'Riya',
            joinedOn: DateTime(2026, 2, 1),
            credited: true,
            earnedAmount: 100,
          ),
        ],
      );
      final back = ReferralWallet.fromJson(
        jsonDecode(jsonEncode(wallet.toJson())) as Map<String, dynamic>,
      );
      expect(back.myCode, 'ANOO123');
      expect(back.credits, 200);
      expect(back.referrals.single.name, 'Riya');
      expect(back.referrals.single.credited, isTrue);
      expect(back.successfulCount, 1);
    });

    test('RefillSubscription keeps its delivery date', () {
      final sub = RefillSubscription(
        active: true,
        medicineId: 'm1',
        medicineName: 'Metformin',
        monthlyPrice: 199,
        nextDelivery: DateTime(2026, 4, 1),
      );
      final back = RefillSubscription.fromJson(
        jsonDecode(jsonEncode(sub.toJson())) as Map<String, dynamic>,
      );
      expect(back.medicineId, 'm1');
      expect(back.monthlyPrice, 199);
      expect(back.nextDelivery, sub.nextDelivery);
    });
  });

  group('Enum wire formats', () {
    test('every InteractionType round trips by name', () {
      for (final t in InteractionType.values) {
        expect(InteractionType.fromName(t.name), t);
      }
    });

    test('every InteractionSeverity round trips by name', () {
      for (final s in InteractionSeverity.values) {
        expect(InteractionSeverity.fromName(s.name), s);
      }
    });

    test('every PregnancyCategory round trips by label', () {
      for (final p in PregnancyCategory.values) {
        expect(PregnancyCategory.fromLabel(p.label), p);
      }
    });

    test('every TriageLevel round trips by name', () {
      for (final l in TriageLevel.values) {
        expect(TriageLevel.fromName(l.name), l);
      }
    });

    test('every OrderStatus round trips by name', () {
      for (final s in OrderStatus.values) {
        expect(OrderStatus.fromName(s.name), s);
      }
    });

    test('every CartItemKind round trips by name', () {
      for (final k in CartItemKind.values) {
        expect(CartItemKind.fromName(k.name), k);
      }
    });
  });

  group('Unknown and malformed data is tolerated', () {
    test('an unknown enum name falls back rather than throwing', () {
      expect(InteractionType.fromName('plasma'), InteractionType.other);
      expect(InteractionSeverity.fromName('mildish'),
          InteractionSeverity.moderate);
      expect(PregnancyCategory.fromLabel('Z'), PregnancyCategory.b);
      expect(TriageLevel.fromName('catastrophic'), TriageLevel.selfCare);
      expect(OrderStatus.fromName('teleported'), OrderStatus.placed);
      expect(CartItemKind.fromName('mystery'), CartItemKind.medicine);
    });

    test('an empty document decodes to safe defaults', () {
      final m = Medicine.fromJson(<String, dynamic>{});
      expect(m.name, '');
      expect(m.pillColor, 0xFFFFFFFF);
      expect(m.uses, isEmpty);
      expect(m.composition, isEmpty);
    });

    test('a null-filled document decodes to safe defaults', () {
      final t = LabTest.fromJson(<String, dynamic>{'name': null, 'price': null});
      expect(t.name, '');
      expect(t.price, 0);
      expect(t.preparation, isEmpty);
    });

    test('numeric strings still decode, so JSON with loose types is fine', () {
      final c = CartItem.fromJson(<String, dynamic>{
        'id': 'm1',
        'unitPrice': 10.5,
        'mrp': 12,
        'quantity': 2,
      });
      expect(c.unitPrice, 10.5);
      expect(c.mrp, 12.0);
      expect(c.quantity, 2);
    });
  });

  group('Serialised payloads carry no UI types', () {
    test('no model serialises an Icons.* name', () {
      final payloads = <Map<String, dynamic>>[
        MockMedicines.all.first.toJson(),
        MockLabs.tests.first.toJson(),
        MockLabs.bundles.first.toJson(),
        MockArticles.all.first.toJson(),
        MockSymptoms.all.first.toJson(),
        MockSymptoms.conditions.first.toJson(),
        MockSymptoms.questions.first.toJson(),
      ];
      for (final p in payloads) {
        final encoded = jsonEncode(p);
        expect(encoded.contains('Icons.'), isFalse, reason: encoded);
      }
    });

    test('every iconKey emitted by the catalogue is registered', () {
      for (final c in MedicineCategory.all) {
        expect(IconRegistry.hasIcon(c.iconKey), isTrue, reason: c.name);
      }
      for (final t in MockLabs.tests) {
        expect(IconRegistry.hasIcon(t.iconKey), isTrue, reason: t.name);
      }
      for (final s in MockSymptoms.all) {
        expect(IconRegistry.hasIcon(s.iconKey), isTrue, reason: s.name);
      }
      for (final q in MockSymptoms.questions) {
        final key = q.iconKey;
        if (key != null) {
          expect(IconRegistry.hasIcon(key), isTrue, reason: q.id);
        }
      }
    });
  });

  group('Interaction engine output serialises', () {
    test('a DrugInteraction survives a JSON round trip', () {
      final source = MockMedicines.all.firstWhere(
        (m) => m.interactions.isNotEmpty,
      );
      for (final r in source.interactions) {
        final back = DrugInteraction.fromJson(
          jsonDecode(jsonEncode(r.toJson())) as Map<String, dynamic>,
        );
        expect(back.substance, r.substance);
        expect(back.severity, r.severity);
        expect(back.type, r.type);
        expect(back.note, r.note);
        expect(back.displayName, r.displayName);
      }
    });
  });

  group('Symptom engine output serialises', () {
    test('a full Assessment round trips', () {
      final assessment = const SymptomEngine().analyse(
        symptomIds: const ['s_fever', 's_cough'],
        answers: const {
          'q_severity': 'moderate',
          'q_duration': '3',
        },
        ageBand: MockSymptoms.ageBands[2],
        gender: MockSymptoms.genders[0],
      );
      final back = Assessment.fromJson(
        jsonDecode(jsonEncode(assessment.toJson())) as Map<String, dynamic>,
      );
      expect(back.level, assessment.level);
      expect(back.score, assessment.score);
      expect(back.advice, assessment.advice);
      expect(back.matches.length, assessment.matches.length);
      expect(back.redFlags, assessment.redFlags);
      expect(back.selfCare, assessment.selfCare);
    });
  });

  group('StorageInfo icon derivation', () {
    test('a refrigerated medicine resolves to the cold icon key', () {
      const cold = StorageInfo(
        temperatureRange: 'Refrigerated 2–8°C',
        light: 'Keep protected from light',
        humidity: 'Sealed',
        instructions: 'Refrigerate',
        temperatureCelsius: 4,
      );
      expect(cold.iconKey, 'storage_cold');
      expect(cold.isRefrigerated, isTrue);
      expect(cold.icon, IconRegistry.resolve('storage_cold'));
    });

    test('a room-temperature medicine resolves to the general key', () {
      const room = StorageInfo(
        temperatureRange: 'Below 25°C',
        light: 'Store away from sunlight',
        humidity: 'Dry',
        instructions: 'Keep dry',
        temperatureCelsius: 22,
      );
      expect(room.iconKey, 'storage_general');
      expect(room.isRefrigerated, isFalse);
    });
  });
}
