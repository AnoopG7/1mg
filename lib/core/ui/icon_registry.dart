import 'package:flutter/material.dart';

import '../theme/app_colors.dart';

/// Maps serialisable icon keys and colour integers back to Flutter UI types.
///
/// Domain models must never hold an [IconData] or a [Color] directly, because
/// neither can be transmitted to a server. Models store a `String iconKey` or an
/// `int` ARGB value instead and expose `IconData get icon` / `Color get color`
/// getters, so widgets keep reading `.icon` and `.color` unchanged while the
/// underlying data stays JSON-safe.
class IconRegistry {
  const IconRegistry._();

  static const String fallbackIconKey = 'help';

  static const Map<String, IconData> _icons = <String, IconData>{
    // ---- Medicine categories -------------------------------------------
    'pain_relief': Icons.healing_rounded,
    'antibiotic': Icons.coronavirus_rounded,
    'diabetes': Icons.bloodtype_rounded,
    'heart_bp': Icons.favorite_rounded,
    'allergy': Icons.air_rounded,
    'digestive': Icons.water_drop_rounded,
    'vitamins': Icons.eco_rounded,
    'respiratory': Icons.air_rounded,
    'skin': Icons.spa_rounded,
    'mental_health': Icons.psychology_rounded,

    // ---- Lab tests ------------------------------------------------------
    'lab_cbc': Icons.bloodtype_rounded,
    'lab_sugar': Icons.bloodtype_rounded,
    'lab_hba1c': Icons.monitor_heart_rounded,
    'lab_lipids': Icons.favorite_rounded,
    'lab_thyroid': Icons.thermostat_rounded,
    'lab_lft': Icons.liquor_rounded,
    'lab_kft': Icons.water_drop_rounded,
    'lab_vitamin_d': Icons.wb_sunny_rounded,
    'lab_b12': Icons.egg_alt_rounded,
    'lab_urine': Icons.science_rounded,

    // ---- Symptoms -------------------------------------------------------
    'fever': Icons.thermostat_rounded,
    'chills': Icons.ac_unit_rounded,
    'fatigue': Icons.battery_3_bar_rounded,
    'body_ache': Icons.accessibility_new_rounded,
    'headache': Icons.psychology_rounded,
    'dizziness': Icons.blur_on_rounded,
    'chest_pain': Icons.favorite_rounded,
    'palpitations': Icons.monitor_heart_rounded,
    'cough': Icons.air_rounded,
    'sore_throat': Icons.sms_rounded,
    'runny_nose': Icons.water_drop_rounded,
    'breathlessness': Icons.air_rounded,
    'wheezing': Icons.airline_seat_flat_rounded,
    'sinus_pain': Icons.sentiment_very_dissatisfied_rounded,
    'eye_itch': Icons.visibility_rounded,
    'ear_pain': Icons.hearing_rounded,
    'nausea': Icons.sick_rounded,
    'vomiting': Icons.emergency_rounded,
    'diarrhoea': Icons.water_drop_outlined,
    'constipation': Icons.block_rounded,
    'acidity': Icons.local_fire_department_rounded,
    'stomach_pain': Icons.cruelty_free_rounded,
    'loss_of_appetite': Icons.no_food_rounded,
    'joint_pain': Icons.accessibility_new_rounded,
    'back_pain': Icons.airline_seat_recline_normal_rounded,
    'muscle_pain': Icons.fitness_center_rounded,
    'skin_rash': Icons.spa_rounded,
    'itching': Icons.back_hand_rounded,
    'sleep_problems': Icons.bedtime_rounded,
    'anxiety': Icons.psychology_alt_rounded,
    'excess_urination': Icons.water_rounded,
    'numbness': Icons.electric_bolt_rounded,
    'fainting': Icons.blur_circular_rounded,
    'joint_stiffness': Icons.lock_clock_rounded,
    'weight_loss': Icons.monitor_weight_outlined,

    // ---- Symptom questions ----------------------------------------------
    'duration': Icons.schedule_rounded,
    'severity': Icons.speed_rounded,

    // ---- Interaction types ----------------------------------------------
    'interaction_food': Icons.restaurant_rounded,
    'interaction_alcohol': Icons.local_bar_rounded,
    'interaction_medicine': Icons.medication_rounded,
    'interaction_other': Icons.info_rounded,

    // ---- Lab range status ------------------------------------------------
    'range_critical': Icons.crisis_alert_rounded,
    'range_low': Icons.south_rounded,
    'range_high': Icons.north_rounded,
    'range_normal': Icons.check_circle_rounded,

    // ---- Order status ----------------------------------------------------
    'order_placed': Icons.receipt_long_rounded,
    'order_confirmed': Icons.check_circle_rounded,
    'order_packed': Icons.inventory_2_rounded,
    'order_shipped': Icons.local_shipping_rounded,
    'order_delivered': Icons.done_all_rounded,
    'sample_collected': Icons.biotech_rounded,
    'report_ready': Icons.description_rounded,

    // ---- Storage buckets -------------------------------------------------
    'storage_cold': Icons.ac_unit_rounded,
    'storage_light': Icons.wb_sunny_outlined,
    'storage_general': Icons.inventory_2_outlined,

    'help': Icons.help_outline_rounded,
  };

  /// Resolves [key] to an icon, falling back to a neutral question mark so a
  /// missing registry entry degrades visually instead of crashing a screen.
  static IconData resolve(String key) =>
      _icons[key] ?? _icons[fallbackIconKey]!;

  /// Every key that resolves to a registered icon. Used by the registry test to
  /// guarantee the map has no unreachable or malformed entries.
  static Iterable<String> get keys => _icons.keys;

  /// Decodes a stored ARGB integer back into a [Color].
  ///
  /// A null [value] yields [AppColors.surfaceAlt] so a document that predates a
  /// colour field still renders.
  static Color colorFromHex(int? value) =>
      value == null ? AppColors.surfaceAlt : Color(value);

  /// Whether [key] is registered. Callers use this to validate incoming data.
  static bool hasIcon(String key) => _icons.containsKey(key);
}
