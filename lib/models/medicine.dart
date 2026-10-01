import 'package:flutter/material.dart';

import '../../core/ui/icon_registry.dart';
import 'drug_interaction.dart';
import 'pregnancy_category.dart';
import 'storage_info.dart';

/// A single active ingredient in a formulation.
class Ingredient {
  const Ingredient({
    required this.name,
    required this.strengthPerDose,
    required this.role,
  });

  final String name;

  /// e.g. "500 mg"
  final String strengthPerDose;

  /// e.g. "Antibacterial"
  final String role;

  Map<String, dynamic> toJson() => {
        'name': name,
        'strengthPerDose': strengthPerDose,
        'role': role,
      };

  factory Ingredient.fromJson(Map<String, dynamic> json) => Ingredient(
        name: json['name'] as String? ?? '',
        strengthPerDose: json['strengthPerDose'] as String? ?? '',
        role: json['role'] as String? ?? '',
      );
}

/// A reported side effect with its frequency.
class SideEffect {
  const SideEffect({
    required this.name,
    required this.frequency,
    required this.severity,
  });

  final String name;

  /// e.g. "Very common (10%)"
  final String frequency;
  final InteractionSeverity severity;

  Map<String, dynamic> toJson() => {
        'name': name,
        'frequency': frequency,
        'severity': severity.name,
      };

  factory SideEffect.fromJson(Map<String, dynamic> json) => SideEffect(
        name: json['name'] as String? ?? '',
        frequency: json['frequency'] as String? ?? '',
        severity: InteractionSeverity.fromName(json['severity'] as String?),
      );
}

/// Therapeutic class shown as a chip.
class MedicineCategory {
  const MedicineCategory(this.name, this.iconKey);

  final String name;

  /// Registry key — see [IconRegistry].
  final String iconKey;

  IconData get icon => IconRegistry.resolve(iconKey);

  static const List<MedicineCategory> all = [
    MedicineCategory('Pain Relief', 'pain_relief'),
    MedicineCategory('Antibiotic', 'antibiotic'),
    MedicineCategory('Diabetes', 'diabetes'),
    MedicineCategory('Heart & BP', 'heart_bp'),
    MedicineCategory('Allergy', 'allergy'),
    MedicineCategory('Digestive', 'digestive'),
    MedicineCategory('Vitamins', 'vitamins'),
    MedicineCategory('Respiratory', 'respiratory'),
    MedicineCategory('Skin', 'skin'),
    MedicineCategory('Mental Health', 'mental_health'),
  ];

  static MedicineCategory? byName(String? name) {
    for (final c in all) {
      if (c.name == name) return c;
    }
    return null;
  }
}

class Medicine {
  const Medicine({
    required this.id,
    required this.name,
    required this.brandName,
    required this.genericName,
    required this.strength,
    required this.form,
    required this.category,
    required this.composition,
    required this.uses,
    required this.sideEffects,
    required this.interactions,
    required this.pregnancyCategory,
    required this.lactationSafe,
    required this.storage,
    required this.rx,
    required this.otc,
    required this.price,
    required this.mrp,
    required this.rating,
    required this.reviewCount,
    required this.description,
    required this.pillShape,
    required this.pillColor,
    required this.manufacturer,
    required this.prescriptionRequired,
  });

  final String id;
  final String name;
  final String brandName;
  final String genericName;
  final String strength;

  /// Tablet / Capsule / Syrup / Injection
  final String form;
  final String category;
  final List<Ingredient> composition;
  final List<String> uses;
  final List<SideEffect> sideEffects;
  final List<DrugInteraction> interactions;
  final PregnancyCategory pregnancyCategory;
  final bool lactationSafe;
  final StorageInfo storage;

  final bool rx;
  final bool otc;
  final double price;
  final double mrp;
  final double rating;
  final int reviewCount;
  final String description;
  final String pillShape;

  /// ARGB int so the pill tint serialises; see [pillColorValue].
  final int pillColor;
  final String manufacturer;
  final bool prescriptionRequired;

  int get discountPercent =>
      mrp <= 0 ? 0 : (((mrp - price) / mrp) * 100).round().clamp(0, 99);

  bool get isInStock => true;

  /// Searchable haystack used by the search bar.
  String get searchText =>
      '$name $brandName $genericName $strength $category ${uses.join(' ')}'
          .toLowerCase();

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'brandName': brandName,
        'genericName': genericName,
        'strength': strength,
        'form': form,
        'category': category,
        'composition': composition.map((c) => c.toJson()).toList(),
        'uses': uses,
        'sideEffects': sideEffects.map((s) => s.toJson()).toList(),
        'interactions': interactions.map((i) => i.toJson()).toList(),
        'pregnancyCategory': pregnancyCategory.label,
        'lactationSafe': lactationSafe,
        'storage': storage.toJson(),
        'rx': rx,
        'otc': otc,
        'price': price,
        'mrp': mrp,
        'rating': rating,
        'reviewCount': reviewCount,
        'description': description,
        'pillShape': pillShape,
        'pillColor': pillColor,
        'manufacturer': manufacturer,
        'prescriptionRequired': prescriptionRequired,
      };

  factory Medicine.fromJson(Map<String, dynamic> json) => Medicine(
        id: json['id'] as String? ?? '',
        name: json['name'] as String? ?? '',
        brandName: json['brandName'] as String? ?? '',
        genericName: json['genericName'] as String? ?? '',
        strength: json['strength'] as String? ?? '',
        form: json['form'] as String? ?? '',
        category: json['category'] as String? ?? '',
        composition: (json['composition'] as List<dynamic>? ?? const [])
            .whereType<Map<String, dynamic>>()
            .map(Ingredient.fromJson)
            .toList(),
        uses: (json['uses'] as List<dynamic>? ?? const [])
            .map((e) => e.toString())
            .toList(),
        sideEffects: (json['sideEffects'] as List<dynamic>? ?? const [])
            .whereType<Map<String, dynamic>>()
            .map(SideEffect.fromJson)
            .toList(),
        interactions: (json['interactions'] as List<dynamic>? ?? const [])
            .whereType<Map<String, dynamic>>()
            .map(DrugInteraction.fromJson)
            .toList(),
        pregnancyCategory:
            PregnancyCategory.fromLabel(json['pregnancyCategory'] as String?),
        lactationSafe: json['lactationSafe'] as bool? ?? false,
        storage: json['storage'] is Map<String, dynamic>
            ? StorageInfo.fromJson(json['storage'] as Map<String, dynamic>)
            : const StorageInfo(
                temperatureRange: '',
                light: '',
                humidity: '',
                instructions: '',
                temperatureCelsius: 25,
              ),
        rx: json['rx'] as bool? ?? false,
        otc: json['otc'] as bool? ?? false,
        price: (json['price'] as num?)?.toDouble() ?? 0,
        mrp: (json['mrp'] as num?)?.toDouble() ?? 0,
        rating: (json['rating'] as num?)?.toDouble() ?? 0,
        reviewCount: (json['reviewCount'] as num?)?.toInt() ?? 0,
        description: json['description'] as String? ?? '',
        pillShape: json['pillShape'] as String? ?? '',
        pillColor: (json['pillColor'] as num?)?.toInt() ?? 0xFFFFFFFF,
        manufacturer: json['manufacturer'] as String? ?? '',
        prescriptionRequired: json['prescriptionRequired'] as bool? ?? false,
      );
}
