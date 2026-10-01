import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';

import '../../data/mock_articles.dart';
import '../../data/mock_labs.dart';
import '../../data/mock_medicines.dart';
import '../../data/mock_symptoms.dart';

class FirestoreService {
  const FirestoreService._();

  static bool get isAvailable =>
      Firebase.apps.isNotEmpty && FirebaseAuth.instance.currentUser != null;

  static FirebaseFirestore get _db => FirebaseFirestore.instance;

  static DocumentReference<Map<String, dynamic>> _userData(String key) {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) throw StateError('A signed-in user is required.');
    return _db.collection('users').doc(user.uid).collection('data').doc(key);
  }

  static Future<void> writeUserData(String key, dynamic value) async {
    if (!isAvailable) return;
    try {
      await _userData(key)
          .set({'value': value, 'updatedAt': FieldValue.serverTimestamp()});
    } catch (_) {
      // Local SharedPreferences remains the fallback when Firestore is offline.
    }
  }

  static Future<void> deleteUserData(String key) async {
    if (!isAvailable) return;
    try {
      await _userData(key).delete();
    } catch (_) {
      // Local data is intentionally retained when the remote delete fails.
    }
  }

  static Future<Map<String, dynamic>> readUserData() async {
    if (!isAvailable) return <String, dynamic>{};
    try {
      final snapshot = await _db
          .collection('users')
          .doc(FirebaseAuth.instance.currentUser!.uid)
          .collection('data')
          .get();
      return {
        for (final document in snapshot.docs)
          document.id: document.data()['value'],
      };
    } catch (_) {
      return <String, dynamic>{};
    }
  }

  static Future<bool> seedCatalogue() async {
    if (!isAvailable) return false;
    final batch = _db.batch();

    void add(String collection, String id, Map<String, dynamic> data) {
      final reference = _db.collection(collection).doc(id);
      batch.set(reference, {
        ...data,
        'updatedAt': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));
    }

    for (final medicine in MockMedicines.all) {
      add('medicines', medicine.id, medicine.toJson());
    }
    for (final test in MockLabs.tests) {
      add('lab_tests', test.id, test.toJson());
    }
    for (final bundle in MockLabs.bundles) {
      add('lab_bundles', bundle.id, bundle.toJson());
    }
    for (final article in MockArticles.all) {
      add('articles', article.id, article.toJson());
    }
    for (final symptom in MockSymptoms.all) {
      add('symptoms', symptom.id, symptom.toJson());
    }
    for (final question in MockSymptoms.questions) {
      add('questions', question.id, question.toJson());
    }
    for (final condition in MockSymptoms.conditions) {
      add('conditions', condition.id, condition.toJson());
    }

    add('meta', 'demographics', {
      'ageBands': MockSymptoms.ageBands,
      'genders': MockSymptoms.genders,
    });
    add('meta', 'red_flag_rules', {'rules': MockSymptoms.redFlagRules});
    add('meta', 'schema', {
      'version': 1,
      'collections': {
        'medicines': [
          'id',
          'composition',
          'uses',
          'sideEffects',
          'interactions',
          'pregnancyCategory',
          'storage',
          'price',
          'mrp',
        ],
        'lab_tests': [
          'id',
          'preparation',
          'fastingRequired',
          'parameters',
          'price',
          'mrp',
        ],
        'lab_bundles': ['id', 'testIds', 'offerPrice', 'mrp', 'badge'],
        'articles': ['id', 'body', 'doctor', 'verified', 'publishedOn', 'tags'],
        'symptoms': ['id', 'name', 'category', 'iconKey'],
        'questions': ['id', 'prompt', 'options', 'isMultiSelect'],
        'conditions': ['id', 'symptomIds', 'recommendations', 'selfCare'],
        'users/{uid}/data': ['value', 'updatedAt'],
      },
    });
    add('meta', 'pricing_rules', {
      'currency': 'INR',
      'standardDelivery': 49,
      'freeDeliveryAbove': 399,
      'refillDiscountPercent': 10,
      'proDiscountPercent': 5,
      'referralCredit': 100,
      'proAnnualPrice': 499,
      'paymentMode': 'mock',
      'deliveryEtaMode': 'mock',
    });
    add('meta', 'plans_and_programs', {
      'pro': {
        'name': '1mg Pro',
        'annualPrice': 499,
        'discountPercent': 5,
        'priorityDelivery': true,
      },
      'medicineRefill': {'discountPercent': 10},
      'referral': {'creditPerReferral': 100},
    });
    add('meta', 'app_capabilities', {
      'authentication': 'email_password',
      'catalogueSource': 'seeded_mock_catalogue',
      'payment': 'mock_only',
      'deliveryEta': 'mock_only',
      'voiceAndDocuments': 'local_only',
    });

    try {
      await batch.commit();
      return true;
    } catch (_) {
      // The app remains usable from its local mock catalogue if seeding fails.
      debugPrint(
        'Firestore catalogue seed failed. Check Firestore rules and database status.',
      );
      return false;
    }
  }
}
