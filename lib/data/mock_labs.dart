import 'package:flutter/material.dart';

import '../models/lab_test.dart';

class MockLabs {
  const MockLabs._();

  static const List<LabTest> tests = [
    LabTest(
      id: 't001',
      name: 'Complete Blood Count (CBC)',
      shortName: 'CBC',
      description:
          'Measures all major blood cell types — red cells, white cells and '
          'platelets. Helps detect anaemia, infections, blood disorders and '
          'monitoring overall health.',
      price: 349,
      mrp: 600,
      fastingRequired: false,
      reportTimeHours: 24,
      icon: Icons.bloodtype_rounded,
      accentColor: Color(0xFFDC2F2F),
      preparation: [
        'No fasting required — eat normally before the test',
        'Drink a glass of water to keep veins easy to find',
        'Avoid strenuous exercise for 12 hours before the test',
        'Tell the technician if you are on blood thinners',
      ],
      parameters: [
        LabRange(parameter: 'Haemoglobin', value: 13.8, normalLow: 13.0, normalHigh: 17.0, unit: 'g/dL'),
        LabRange(parameter: 'WBC Count', value: 11400, normalLow: 4000, normalHigh: 11000, unit: '/µL'),
        LabRange(parameter: 'Platelet Count', value: 252000, normalLow: 150000, normalHigh: 410000, unit: '/µL'),
        LabRange(parameter: 'RBC Count', value: 4.9, normalLow: 4.5, normalHigh: 5.9, unit: 'million/µL'),
        LabRange(parameter: 'Haematocrit', value: 44.2, normalLow: 40, normalHigh: 50, unit: '%'),
      ],
    ),
    LabTest(
      id: 't002',
      name: 'Fasting Blood Sugar (FBS)',
      shortName: 'Fasting Sugar',
      description:
          'Measures glucose after an overnight fast — the primary screening test '
          'for diabetes and pre-diabetes.',
      price: 99,
      mrp: 200,
      fastingRequired: true,
      reportTimeHours: 12,
      icon: Icons.bloodtype_rounded,
      accentColor: Color(0xFFE8A317),
      preparation: [
        'Fast for at least 8–10 hours before the test',
        'Only plain water is allowed during the fast',
        'Do not eat or drink tea, coffee or juice before the test',
        'Continue medicines unless your doctor advises otherwise',
      ],
      parameters: [
        LabRange(parameter: 'Fasting Glucose', value: 104, normalLow: 70, normalHigh: 100, unit: 'mg/dL'),
      ],
    ),
    LabTest(
      id: 't003',
      name: 'HbA1c (Glycosylated Haemoglobin)',
      shortName: 'HbA1c',
      description:
          'Reflects your average blood sugar over the last 3 months. The gold '
          'standard for long-term diabetes monitoring and control.',
      price: 449,
      mrp: 750,
      fastingRequired: false,
      reportTimeHours: 24,
      icon: Icons.monitor_heart_rounded,
      accentColor: Color(0xFF7B4DFF),
      preparation: [
        'No fasting required',
        'Continue your regular diabetes medicines',
        'Avoid a very high-sugar meal the previous day',
      ],
      parameters: [
        LabRange(parameter: 'HbA1c', value: 6.8, normalLow: 4.0, normalHigh: 5.6, unit: '%'),
        LabRange(parameter: 'Estimated Avg Glucose', value: 148, normalLow: 70, normalHigh: 114, unit: 'mg/dL'),
      ],
    ),
    LabTest(
      id: 't004',
      name: 'Lipid Profile',
      shortName: 'Lipids',
      description:
          'Measures cholesterol and triglycerides to assess cardiovascular risk. '
          'Essential screening for heart disease and obesity.',
      price: 399,
      mrp: 700,
      fastingRequired: true,
      reportTimeHours: 24,
      icon: Icons.favorite_rounded,
      accentColor: Color(0xFFDC2F2F),
      preparation: [
        'Fast for 9–12 hours before the test',
        'Avoid heavy, oily and fatty meals the night before',
        'Do not consume alcohol for 48 hours prior',
        'Water is allowed during the fast',
      ],
      parameters: [
        LabRange(parameter: 'Total Cholesterol', value: 198, normalLow: 0, normalHigh: 200, unit: 'mg/dL'),
        LabRange(parameter: 'LDL Cholesterol', value: 118, normalLow: 0, normalHigh: 100, unit: 'mg/dL'),
        LabRange(parameter: 'HDL Cholesterol', value: 44, normalLow: 40, normalHigh: 60, unit: 'mg/dL'),
        LabRange(parameter: 'Triglycerides', value: 142, normalLow: 0, normalHigh: 150, unit: 'mg/dL'),
        LabRange(parameter: 'VLDL', value: 28, normalLow: 5, normalHigh: 40, unit: 'mg/dL'),
      ],
    ),
    LabTest(
      id: 't005',
      name: 'Thyroid Profile (T3, T4, TSH)',
      shortName: 'Thyroid',
      description:
          'Screens for hypo and hyperthyroidism. Covers TSH, Free T3 and Free T4 '
          '— commonly ordered for weight changes, fatigue and hair fall.',
      price: 399,
      mrp: 700,
      fastingRequired: false,
      reportTimeHours: 24,
      icon: Icons.thermostat_rounded,
      accentColor: Color(0xFF00A9A5),
      preparation: [
        'No fasting required for most cases',
        'Inform the lab if you are on biotin supplements (stop 48 hours prior)',
        'Thyroid medicines should be continued as prescribed',
      ],
      parameters: [
        LabRange(parameter: 'TSH (Ultrasensitive)', value: 4.2, normalLow: 0.55, normalHigh: 4.05, unit: 'µIU/mL'),
        LabRange(parameter: 'Free T3', value: 3.1, normalLow: 2.3, normalHigh: 4.2, unit: 'pg/mL'),
        LabRange(parameter: 'Free T4', value: 1.02, normalLow: 0.8, normalHigh: 1.8, unit: 'ng/dL'),
      ],
    ),
    LabTest(
      id: 't006',
      name: 'Liver Function Test (LFT)',
      shortName: 'LFT',
      description:
          'Assesses liver health by measuring enzymes, bilirubin and proteins. '
          'Screens for fatty liver, hepatitis and drug-induced liver damage.',
      price: 549,
      mrp: 950,
      fastingRequired: true,
      reportTimeHours: 24,
      icon: Icons.liquor_rounded,
      accentColor: Color(0xFFF2721C),
      preparation: [
        'Fast for 8–10 hours before the test',
        'Avoid alcohol for at least 48 hours before the test',
        'Avoid fatty and fried food the previous night',
        'Report any recent medicines, including herbal supplements',
      ],
      parameters: [
        LabRange(parameter: 'SGPT (ALT)', value: 62, normalLow: 7, normalHigh: 56, unit: 'U/L'),
        LabRange(parameter: 'SGOT (AST)', value: 38, normalLow: 0, normalHigh: 45, unit: 'U/L'),
        LabRange(parameter: 'Total Bilirubin', value: 0.8, normalLow: 0.2, normalHigh: 1.2, unit: 'mg/dL'),
        LabRange(parameter: 'Alkaline Phosphatase', value: 88, normalLow: 40, normalHigh: 130, unit: 'U/L'),
      ],
    ),
    LabTest(
      id: 't007',
      name: 'Kidney Function Test (KFT)',
      shortName: 'KFT',
      description:
          'Checks how well your kidneys filter waste from the blood — urea, '
          'creatinine and uric acid levels.',
      price: 549,
      mrp: 950,
      fastingRequired: true,
      reportTimeHours: 24,
      icon: Icons.water_drop_rounded,
      accentColor: Color(0xFF2C6BED),
      preparation: [
        'Fast for 8–10 hours before the test',
        'Drink plenty of water the day before and on the morning of the test',
        'Avoid heavy protein meals the night before',
        'Inform the lab if you are pregnant',
      ],
      parameters: [
        LabRange(parameter: 'Urea', value: 28, normalLow: 15, normalHigh: 40, unit: 'mg/dL'),
        LabRange(parameter: 'Creatinine', value: 0.9, normalLow: 0.7, normalHigh: 1.3, unit: 'mg/dL'),
        LabRange(parameter: 'Uric Acid', value: 6.2, normalLow: 3.5, normalHigh: 7.2, unit: 'mg/dL'),
      ],
    ),
    LabTest(
      id: 't008',
      name: 'Vitamin D (25-Hydroxy)',
      shortName: 'Vitamin D',
      description:
          'The most commonly deficient vitamin in India. Essential for bone health, '
          'immunity and mood.',
      price: 599,
      mrp: 1100,
      fastingRequired: false,
      reportTimeHours: 48,
      icon: Icons.wb_sunny_rounded,
      accentColor: Color(0xFFE8A317),
      preparation: [
        'No fasting required',
        'Avoid taking vitamin D supplements for 48 hours before the sample',
        'Sunlight exposure before the test does not affect the result',
      ],
      parameters: [
        LabRange(parameter: '25-Hydroxy Vitamin D', value: 18.5, normalLow: 30, normalHigh: 100, unit: 'ng/mL'),
      ],
    ),
    LabTest(
      id: 't009',
      name: 'Vitamin B12',
      shortName: 'B12',
      description:
          'Detects vitamin B12 deficiency, common in strict vegetarians and people '
          'on long-term metformin.',
      price: 549,
      mrp: 950,
      fastingRequired: false,
      reportTimeHours: 48,
      icon: Icons.egg_alt_rounded,
      accentColor: Color(0xFF12A150),
      preparation: [
        'No fasting required',
        'Avoid taking B12 supplements for 48 hours before the test',
        'Inform the lab if you are on metformin (affects B12 levels)',
      ],
      parameters: [
        LabRange(parameter: 'Vitamin B12', value: 226, normalLow: 197, normalHigh: 771, unit: 'pg/mL'),
      ],
    ),
    LabTest(
      id: 't010',
      name: 'Urine Routine & Microscopy (URM)',
      shortName: 'Urine Routine',
      description:
          'A basic urine test that detects infection, kidney disease, diabetes and '
          'liver problems.',
      price: 249,
      mrp: 400,
      fastingRequired: false,
      reportTimeHours: 12,
      icon: Icons.science_rounded,
      accentColor: Color(0xFF7B4DFF),
      preparation: [
        'Collect a clean-catch, midstream urine sample',
        'Use a sterile, wide-mouth container supplied by the lab',
        'Avoid collecting urine during menstruation',
        'The sample should be delivered within 2 hours or refrigerated',
      ],
      parameters: [
        LabRange(parameter: 'Urine pH', value: 6.0, normalLow: 5.0, normalHigh: 8.0, unit: 'pH'),
        LabRange(parameter: 'Specific Gravity', value: 1.02, normalLow: 1.003, normalHigh: 1.030, unit: ''),
        LabRange(parameter: 'Protein', value: 0, normalLow: 0, normalHigh: 15, unit: 'mg/dL'),
        LabRange(parameter: 'Pus Cells', value: 2, normalLow: 0, normalHigh: 5, unit: '/hpf'),
      ],
    ),
  ];

  /// Health packages. Discounts go up to 50% off the sum of individual tests.
  static const List<LabBundle> bundles = [
    LabBundle(
      id: 'b001',
      name: 'Complete Health Checkup Package',
      tagline: '62 parameters covering every major organ system',
      testIds: ['t001', 't004', 't005', 't006', 't007', 't002'],
      offerPrice: 1899,
      mrp: 4398,
      badge: 'Up to 50% off',
      accentColor: Color(0xFF7B4DFF),
      recommendedFor: 'Annual full-body screening for adults above 30',
    ),
    LabBundle(
      id: 'b002',
      name: 'Diabetes Care Plus',
      tagline: 'HbA1c, fasting sugar, lipid & kidney monitoring',
      testIds: ['t003', 't002', 't004', 't007'],
      offerPrice: 1099,
      mrp: 2198,
      badge: '50% off',
      accentColor: Color(0xFFE8A317),
      recommendedFor: 'Diabetics and people with a family history of diabetes',
    ),
    LabBundle(
      id: 'b003',
      name: 'Women\'s Health Screening',
      tagline: 'Iron, thyroid, vitamin D, B12 and calcium assessment',
      testIds: ['t001', 't005', 't008', 't009', 't010'],
      offerPrice: 1249,
      mrp: 2396,
      badge: '48% off',
      accentColor: Color(0xFFDC2F2F),
      recommendedFor: 'Women — detects anaemia, thyroid and vitamin deficiencies',
    ),
    LabBundle(
      id: 'b004',
      name: 'Heart Health Check',
      tagline: 'Complete lipid profile with liver and kidney markers',
      testIds: ['t004', 't001', 't006'],
      offerPrice: 799,
      mrp: 1599,
      badge: '50% off',
      accentColor: Color(0xFFDC2F2F),
      recommendedFor: 'Cholesterol, obesity and heart-risk screening',
    ),
    LabBundle(
      id: 'b005',
      name: 'Vitamin Deficiency Panel',
      tagline: 'Vitamin D, B12 and iron assessment in one go',
      testIds: ['t008', 't009', 't001'],
      offerPrice: 899,
      mrp: 1749,
      badge: '49% off',
      accentColor: Color(0xFF12A150),
      recommendedFor: 'Fatigue, hair fall, weakness and poor diet',
    ),
    LabBundle(
      id: 'b006',
      name: 'Senior Citizen Health Package',
      tagline: '62+ parameters with doctor consultation',
      testIds: ['t001', 't004', 't005', 't006', 't007', 't003'],
      offerPrice: 2199,
      mrp: 4395,
      badge: '50% off',
      accentColor: Color(0xFF00A9A5),
      recommendedFor: 'Complete monitoring for people above 60 years',
    ),
  ];

  static LabTest? testById(String id) {
    for (final t in tests) {
      if (t.id == id) return t;
    }
    return null;
  }

  static LabBundle? bundleById(String id) {
    for (final b in bundles) {
      if (b.id == id) return b;
    }
    return null;
  }

  static List<LabTest> testsIn(LabBundle bundle) => bundle.testIds
      .map(testById)
      .whereType<LabTest>()
      .toList(growable: false);
}
