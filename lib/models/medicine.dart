import 'package:flutter/material.dart';

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
}

/// Therapeutic class shown as a chip.
class MedicineCategory {
  const MedicineCategory(this.name, this.icon);

  final String name;
  final IconData icon;

  static const List<MedicineCategory> all = [
    MedicineCategory('Pain Relief', Icons.healing_rounded),
    MedicineCategory('Antibiotic', Icons.coronavirus_rounded),
    MedicineCategory('Diabetes', Icons.bloodtype_rounded),
    MedicineCategory('Heart & BP', Icons.favorite_rounded),
    MedicineCategory('Allergy', Icons.air_rounded),
    MedicineCategory('Digestive', Icons.water_drop_rounded),
    MedicineCategory('Vitamins', Icons.eco_rounded),
    MedicineCategory('Respiratory', Icons.air_rounded),
    MedicineCategory('Skin', Icons.spa_rounded),
    MedicineCategory('Mental Health', Icons.psychology_rounded),
  ];
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
}
