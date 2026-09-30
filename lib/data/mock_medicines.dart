import '../models/drug_interaction.dart';
import '../models/medicine.dart';
import '../models/pregnancy_category.dart';
import '../models/storage_info.dart';

const _cool = StorageInfo(
  temperatureRange: 'Below 25°C, cool & dry place',
  temperatureCelsius: 25,
  light: 'Store away from direct sunlight',
  humidity: 'Keep in a dry place',
  instructions:
      'Keep in the original blister pack. Do not store above 25°C. Protect from '
      'moisture and direct sunlight. Keep out of reach of children.',
);

const _room = StorageInfo(
  temperatureRange: 'Below 25°C, room temperature',
  temperatureCelsius: 25,
  light: 'Protect from light',
  humidity: 'Avoid humid places like the bathroom',
  instructions:
      'Store below 25°C in a dry place. Protect from light. Do not freeze. Keep '
      'the container tightly closed to preserve potency.',
);

const _fridgeDoNotFreeze = StorageInfo(
  temperatureRange: 'Refrigerated 2–8°C, do not freeze',
  temperatureCelsius: 5,
  light: 'Keep in amber glass bottle',
  humidity: 'Do not freeze or shake',
  instructions:
      'Store in a refrigerator between 2°C and 8°C, in the original amber '
      'bottle. Do not freeze. Do not shake. Keep the cap tightly closed.',
);

class MockMedicines {
  const MockMedicines._();

  static const List<Medicine> all = [
    Medicine(
      id: 'm001',
      name: 'Dolo 650',
      brandName: 'Dolo',
      genericName: 'Paracetamol',
      strength: '650 mg',
      form: 'Tablet',
      category: 'Pain Relief',
      manufacturer: 'BPL Pharma',
      description:
          'Paracetamol is a widely used analgesic and antipyretic. It relieves '
          'mild to moderate pain and reduces fever without causing gastric '
          'irritation. It is one of the safest first-line options for headache, '
          'body ache and fever.',
      composition: [
        Ingredient(name: 'Paracetamol', strengthPerDose: '650 mg', role: 'Analgesic / Antipyretic'),
      ],
      uses: [
        'Fever reduction (antipyretic)',
        'Headache and migraine relief',
        'Body ache during cold & flu',
        'Back pain and joint pain',
        'Dental pain relief',
        'Muscle cramps',
      ],
      sideEffects: [
        SideEffect(name: 'Nausea', frequency: 'Uncommon', severity: InteractionSeverity.mild),
        SideEffect(name: 'Skin rash or itching', frequency: 'Rare', severity: InteractionSeverity.mild),
        SideEffect(name: 'Liver damage on overdose', frequency: 'Rare', severity: InteractionSeverity.severe),
        SideEffect(name: 'Constipation', frequency: 'Uncommon', severity: InteractionSeverity.mild),
      ],
      interactions: [
        DrugInteraction(
          type: InteractionType.alcohol,
          substance: 'Alcohol',
          severity: InteractionSeverity.severe,
          note:
              'Daily alcohol use with paracetamol seriously increases the risk of '
              'liver damage. Avoid combining, especially if you take 4+ tablets a day.',
        ),
        DrugInteraction(
          type: InteractionType.food,
          substance: 'Alcohol-containing food',
          severity: InteractionSeverity.moderate,
          note: 'Avoid medicines or tonics containing alcohol or ethanol.',
        ),
        DrugInteraction(
          type: InteractionType.drug,
          substance: 'Warfarin',
          severity: InteractionSeverity.moderate,
          note:
              'Long-term paracetamol use can increase INR and bleeding risk. '
              'Monitor closely if you are on blood thinners.',
        ),
        DrugInteraction(
          type: InteractionType.drug,
          substance: 'Flucloxacillin / antibiotics',
          severity: InteractionSeverity.moderate,
          note:
              'Taking paracetamol with some antibiotics can increase liver '
              'toxicity. Consult your doctor if on a course of antibiotics.',
        ),
      ],
      pregnancyCategory: PregnancyCategory.b,
      lactationSafe: true,
      storage: _room,
      rx: false,
      otc: true,
      prescriptionRequired: false,
      price: 32,
      mrp: 38,
      rating: 4.6,
      reviewCount: 48200,
      pillShape: 'Round',
      pillColor: 0xFFFFFFFF,
    ),
    Medicine(
      id: 'm002',
      name: 'Crocin',
      brandName: 'Crocin',
      genericName: 'Paracetamol',
      strength: '500 mg',
      form: 'Tablet',
      category: 'Pain Relief',
      manufacturer: 'GlaxoSmithKline',
      description:
          'Crocin 500 is a paracetamol tablet used for quick relief from fever, '
          'headache and body ache. Suitable for adults and children above 12 years.',
      composition: [
        Ingredient(name: 'Paracetamol', strengthPerDose: '500 mg', role: 'Analgesic / Antipyretic'),
      ],
      uses: [
        'Fever and chills',
        'Headache',
        'Toothache',
        'Menstrual cramps',
        'Cold and flu body ache',
      ],
      sideEffects: [
        SideEffect(name: 'Drowsiness', frequency: 'Rare', severity: InteractionSeverity.mild),
        SideEffect(name: 'Nausea or vomiting', frequency: 'Uncommon', severity: InteractionSeverity.mild),
        SideEffect(name: 'Allergic reaction', frequency: 'Rare', severity: InteractionSeverity.moderate),
      ],
      interactions: [
        DrugInteraction(
          type: InteractionType.alcohol,
          substance: 'Alcohol',
          severity: InteractionSeverity.severe,
          note: 'Alcohol increases the risk of liver damage with paracetamol.',
        ),
        DrugInteraction(
          type: InteractionType.drug,
          substance: 'Carbamazepine / Phenytoin',
          severity: InteractionSeverity.moderate,
          note: 'May increase the risk of liver problems when taken long term.',
        ),
      ],
      pregnancyCategory: PregnancyCategory.b,
      lactationSafe: true,
      storage: _cool,
      rx: false,
      otc: true,
      prescriptionRequired: false,
      price: 12,
      mrp: 15,
      rating: 4.4,
      reviewCount: 62100,
      pillShape: 'Oval',
      pillColor: 0xFFFFFFFF,
    ),
    Medicine(
      id: 'm003',
      name: 'Augmentin 625 Duo',
      brandName: 'Augmentin',
      genericName: 'Amoxicillin + Clavulanic acid',
      strength: '625 mg',
      form: 'Tablet',
      category: 'Antibiotic',
      manufacturer: 'GSK Pharmaceuticals',
      description:
          'Augmentin is a broad-spectrum antibiotic combining amoxicillin with '
          'clavulanic acid. It is prescribed for bacterial infections of the '
          'respiratory tract, sinuses, ears, skin and urinary tract.',
      composition: [
        Ingredient(name: 'Amoxicillin trihydrate', strengthPerDose: '500 mg', role: 'Antibacterial'),
        Ingredient(name: 'Clavulanic acid', strengthPerDose: '125 mg', role: 'Beta-lactamase inhibitor'),
      ],
      uses: [
        'Bacterial throat and chest infection',
        'Sinusitis and ear infection',
        'Skin and soft tissue infection',
        'Urinary tract infection',
        'Dental infections',
        'Community-acquired pneumonia',
      ],
      sideEffects: [
        SideEffect(name: 'Diarrhoea', frequency: 'Very common', severity: InteractionSeverity.mild),
        SideEffect(name: 'Nausea', frequency: 'Common', severity: InteractionSeverity.mild),
        SideEffect(name: 'Rash', frequency: 'Uncommon', severity: InteractionSeverity.moderate),
        SideEffect(name: 'Penicillin allergy reaction', frequency: 'Rare', severity: InteractionSeverity.severe),
      ],
      interactions: [
        DrugInteraction(
          type: InteractionType.alcohol,
          substance: 'Alcohol',
          severity: InteractionSeverity.moderate,
          note:
              'Avoid alcohol completely during the course. It reduces antibiotic '
              'efficacy and can cause severe stomach upset.',
        ),
        DrugInteraction(
          type: InteractionType.drug,
          substance: 'Methotrexate',
          severity: InteractionSeverity.severe,
          note: 'Amoxicillin can reduce methotrexate clearance. Avoid combination.',
        ),
        DrugInteraction(
          type: InteractionType.drug,
          substance: 'Probenecid',
          severity: InteractionSeverity.moderate,
          note: 'Probenecid increases amoxicillin levels in the blood.',
        ),
        DrugInteraction(
          type: InteractionType.drug,
          substance: 'Warfarin',
          severity: InteractionSeverity.moderate,
          note: 'Antibiotics can alter INR and increase bleeding risk. Monitor.',
        ),
      ],
      pregnancyCategory: PregnancyCategory.b,
      lactationSafe: true,
      storage: _cool,
      rx: true,
      otc: false,
      prescriptionRequired: true,
      price: 168,
      mrp: 189,
      rating: 4.3,
      reviewCount: 12400,
      pillShape: 'Oval',
      pillColor: 0xFFD98C4A,
    ),
    Medicine(
      id: 'm004',
      name: 'Azithral 500',
      brandName: 'Azithral',
      genericName: 'Azithromycin',
      strength: '500 mg',
      form: 'Tablet',
      category: 'Antibiotic',
      manufacturer: 'Alembic Pharma',
      description:
          'Azithromycin is a macrolide antibiotic used for a wide range of '
          'bacterial infections including bronchitis, pneumonia, strep throat and '
          'skin infections. Often prescribed as a 3-day course.',
      composition: [
        Ingredient(name: 'Azithromycin dihydrate', strengthPerDose: '500 mg', role: 'Antibacterial'),
      ],
      uses: [
        'Chest infection and bronchitis',
        'Community-acquired pneumonia',
        'Sore throat and tonsillitis',
        'Sinusitis',
        'Skin and soft tissue infection',
        'Campylobacter diarrhoea',
      ],
      sideEffects: [
        SideEffect(name: 'Loose motions', frequency: 'Very common', severity: InteractionSeverity.mild),
        SideEffect(name: 'Stomach pain', frequency: 'Common', severity: InteractionSeverity.mild),
        SideEffect(name: 'Hearing changes (rare)', frequency: 'Rare', severity: InteractionSeverity.moderate),
        SideEffect(name: 'Liver enzyme elevation', frequency: 'Uncommon', severity: InteractionSeverity.moderate),
      ],
      interactions: [
        DrugInteraction(
          type: InteractionType.alcohol,
          substance: 'Alcohol',
          severity: InteractionSeverity.moderate,
          note: 'Avoid alcohol during and 72 hours after the last dose.',
        ),
        DrugInteraction(
          type: InteractionType.drug,
          substance: 'Digoxin',
          severity: InteractionSeverity.severe,
          note: 'Azithromycin can raise digoxin levels and cause heart rhythm problems.',
        ),
        DrugInteraction(
          type: InteractionType.drug,
          substance: 'Antacids (aluminium/magnesium)',
          severity: InteractionSeverity.moderate,
          note: 'Take azithromycin 2 hours before or after antacids.',
        ),
      ],
      pregnancyCategory: PregnancyCategory.b,
      lactationSafe: true,
      storage: _cool,
      rx: true,
      otc: false,
      prescriptionRequired: true,
      price: 122,
      mrp: 140,
      rating: 4.2,
      reviewCount: 9800,
      pillShape: 'Oval',
      pillColor: 0xFFF2F2F2,
    ),
    Medicine(
      id: 'm005',
      name: 'Gluconil 1',
      brandName: 'Gluconil',
      genericName: 'Metformin',
      strength: '500 mg',
      form: 'Tablet',
      category: 'Diabetes',
      manufacturer: 'Glenmark',
      description:
          'Metformin is the first-line medicine for type 2 diabetes. It lowers '
          'blood sugar by improving insulin sensitivity and reduces the risk of '
          'cardiovascular complications with long-term use.',
      composition: [
        Ingredient(name: 'Metformin HCl', strengthPerDose: '500 mg', role: 'Biguanide antihyperglycemic'),
      ],
      uses: [
        'Type 2 diabetes mellitus',
        'Blood sugar control',
        'Prediabetes management',
        'Polycystic ovary syndrome (PCOS)',
        'Weight management in diabetics',
      ],
      sideEffects: [
        SideEffect(name: 'Nausea', frequency: 'Very common', severity: InteractionSeverity.mild),
        SideEffect(name: 'Stomach upset', frequency: 'Very common', severity: InteractionSeverity.mild),
        SideEffect(name: 'Loss of appetite', frequency: 'Common', severity: InteractionSeverity.mild),
        SideEffect(name: 'Vitamin B12 deficiency', frequency: 'Common (long term)', severity: InteractionSeverity.moderate),
      ],
      interactions: [
        DrugInteraction(
          type: InteractionType.alcohol,
          substance: 'Alcohol',
          severity: InteractionSeverity.severe,
          note:
              'Alcohol with metformin greatly increases the risk of lactic '
              'acidosis, which can be life-threatening. Avoid completely.',
        ),
        DrugInteraction(
          type: InteractionType.food,
          substance: 'High-fat / heavy meals',
          severity: InteractionSeverity.mild,
          note: 'Taking with a large meal reduces stomach upset significantly.',
        ),
        DrugInteraction(
          type: InteractionType.drug,
          substance: 'Contrast dye (iodinated)',
          severity: InteractionSeverity.severe,
          note:
              'Do not take metformin for at least 48 hours before or after a CT '
              'scan with contrast dye.',
        ),
        DrugInteraction(
          type: InteractionType.drug,
          substance: 'Insulin / Sulfonylureas',
          severity: InteractionSeverity.moderate,
          note: 'Combining can cause low blood sugar. Monitor glucose closely.',
        ),
      ],
      pregnancyCategory: PregnancyCategory.c,
      lactationSafe: false,
      storage: _cool,
      rx: true,
      otc: false,
      prescriptionRequired: true,
      price: 42,
      mrp: 52,
      rating: 4.5,
      reviewCount: 15600,
      pillShape: 'Round',
      pillColor: 0xFFFFFFFF,
    ),
    Medicine(
      id: 'm006',
      name: 'Glycomet GP 1',
      brandName: 'Glycomet',
      genericName: 'Metformin + Glimepiride',
      strength: '500 mg / 1 mg',
      form: 'Tablet',
      category: 'Diabetes',
      manufacturer: 'USV',
      description:
          'A combination anti-diabetic containing metformin and glimepiride, used '
          'when metformin alone is not enough to control blood sugar.',
      composition: [
        Ingredient(name: 'Metformin HCl', strengthPerDose: '500 mg', role: 'Biguanide'),
        Ingredient(name: 'Glimepiride', strengthPerDose: '1 mg', role: 'Sulfonylurea'),
      ],
      uses: [
        'Type 2 diabetes mellitus',
        'Uncontrolled blood sugar on metformin',
        'Post-meal sugar control',
      ],
      sideEffects: [
        SideEffect(name: 'Hypoglycaemia (low sugar)', frequency: 'Common', severity: InteractionSeverity.severe),
        SideEffect(name: 'Nausea', frequency: 'Common', severity: InteractionSeverity.mild),
        SideEffect(name: 'Weight gain', frequency: 'Uncommon', severity: InteractionSeverity.mild),
        SideEffect(name: 'Dizziness', frequency: 'Uncommon', severity: InteractionSeverity.moderate),
      ],
      interactions: [
        DrugInteraction(
          type: InteractionType.alcohol,
          substance: 'Alcohol',
          severity: InteractionSeverity.severe,
          note:
              'Alcohol with glimepiride causes prolonged and dangerous low blood '
              'sugar. Strictly avoid.',
        ),
        DrugInteraction(
          type: InteractionType.food,
          substance: 'Skipped meals',
          severity: InteractionSeverity.severe,
          note: 'Never skip meals while on glimepiride — risk of hypoglycaemia.',
        ),
        DrugInteraction(
          type: InteractionType.drug,
          substance: 'Ciprofloxacin / Fluconazole',
          severity: InteractionSeverity.moderate,
          note: 'These can increase the blood-lowering effect of glimepiride.',
        ),
      ],
      pregnancyCategory: PregnancyCategory.c,
      lactationSafe: false,
      storage: _cool,
      rx: true,
      otc: false,
      prescriptionRequired: true,
      price: 68,
      mrp: 82,
      rating: 4.2,
      reviewCount: 7300,
      pillShape: 'Oval',
      pillColor: 0xFFE8E8E8,
    ),
    Medicine(
      id: 'm007',
      name: 'Ecosprin AV 75',
      brandName: 'Ecosprin',
      genericName: 'Aspirin',
      strength: '75 mg',
      form: 'Capsule',
      category: 'Heart & BP',
      manufacturer: 'USV',
      description:
          'Low-dose aspirin (75 mg) is prescribed for prevention of heart attack '
          'and stroke in people with cardiovascular risk. Also used for pain and '
          'fever in higher doses.',
      composition: [
        Ingredient(name: 'Acetylsalicylic acid', strengthPerDose: '75 mg', role: 'Antiplatelet'),
      ],
      uses: [
        'Prevention of heart attack',
        'Prevention of stroke',
        'Angina (chest pain) prevention',
        'Fever and mild pain relief',
        'Post-stent therapy',
      ],
      sideEffects: [
        SideEffect(name: 'Stomach irritation', frequency: 'Common', severity: InteractionSeverity.mild),
        SideEffect(name: 'Heartburn', frequency: 'Common', severity: InteractionSeverity.mild),
        SideEffect(name: 'Easy bruising', frequency: 'Uncommon', severity: InteractionSeverity.moderate),
        SideEffect(name: 'Stomach bleeding', frequency: 'Rare', severity: InteractionSeverity.severe),
      ],
      interactions: [
        DrugInteraction(
          type: InteractionType.alcohol,
          substance: 'Alcohol',
          severity: InteractionSeverity.severe,
          note:
              'Alcohol markedly increases the risk of stomach bleeding with '
              'aspirin. Avoid alcohol entirely.',
        ),
        DrugInteraction(
          type: InteractionType.food,
          substance: 'Spicy & oily food',
          severity: InteractionSeverity.mild,
          note: 'Avoid spicy food — it worsens gastric irritation and acidity.',
        ),
        DrugInteraction(
          type: InteractionType.drug,
          substance: 'Ibuprofen / Diclofenac',
          severity: InteractionSeverity.severe,
          note:
              'Taking NSAIDs with aspirin increases bleeding risk and reduces '
              'aspirin\'s heart protection. Avoid.',
        ),
        DrugInteraction(
          type: InteractionType.drug,
          substance: 'Warfarin',
          severity: InteractionSeverity.severe,
          note: 'Combined anticoagulant + antiplatelet therapy needs close monitoring.',
        ),
      ],
      pregnancyCategory: PregnancyCategory.d,
      lactationSafe: false,
      storage: _cool,
      rx: true,
      otc: false,
      prescriptionRequired: true,
      price: 26,
      mrp: 32,
      rating: 4.5,
      reviewCount: 18900,
      pillShape: 'Capsule',
      pillColor: 0xFFC75146,
    ),
    Medicine(
      id: 'm008',
      name: 'Telma 40',
      brandName: 'Telma',
      genericName: 'Telmisartan',
      strength: '40 mg',
      form: 'Tablet',
      category: 'Heart & BP',
      manufacturer: 'Glenmark',
      description:
          'Telmisartan is an angiotensin receptor blocker (ARB) used to treat '
          'hypertension, heart failure and diabetic nephropathy. It offers '
          '24-hour blood pressure control.',
      composition: [
        Ingredient(name: 'Telmisartan', strengthPerDose: '40 mg', role: 'ARB antihypertensive'),
      ],
      uses: [
        'High blood pressure (hypertension)',
        'Heart failure',
        'Diabetic kidney protection',
        'Stroke prevention',
      ],
      sideEffects: [
        SideEffect(name: 'Dizziness', frequency: 'Common', severity: InteractionSeverity.mild),
        SideEffect(name: 'Fatigue', frequency: 'Uncommon', severity: InteractionSeverity.mild),
        SideEffect(name: 'High potassium (hyperkalaemia)', frequency: 'Uncommon', severity: InteractionSeverity.moderate),
        SideEffect(name: 'Low blood pressure on standing', frequency: 'Uncommon', severity: InteractionSeverity.moderate),
      ],
      interactions: [
        DrugInteraction(
          type: InteractionType.food,
          substance: 'Potassium-rich food & supplements',
          severity: InteractionSeverity.moderate,
          note:
              'Bananas, oranges, salt substitutes and potassium supplements can '
              'raise blood potassium dangerously.',
        ),
        DrugInteraction(
          type: InteractionType.alcohol,
          substance: 'Alcohol',
          severity: InteractionSeverity.moderate,
          note: 'Alcohol further lowers blood pressure and causes dizziness.',
        ),
        DrugInteraction(
          type: InteractionType.drug,
          substance: 'ACE inhibitors (e.g. Enalapril)',
          severity: InteractionSeverity.severe,
          note: 'Dual ACEi + ARB therapy is not recommended — risk of kidney injury.',
        ),
        DrugInteraction(
          type: InteractionType.drug,
          substance: 'NSAIDs (Ibuprofen, Diclofenac)',
          severity: InteractionSeverity.moderate,
          note: 'NSAIDs may reduce the blood-pressure-lowering effect and harm kidneys.',
        ),
        DrugInteraction(
          type: InteractionType.drug,
          substance: 'Lithium',
          severity: InteractionSeverity.moderate,
          note: 'Telmisartan can increase lithium levels. Monitor closely.',
        ),
      ],
      pregnancyCategory: PregnancyCategory.d,
      lactationSafe: false,
      storage: _cool,
      rx: true,
      otc: false,
      prescriptionRequired: true,
      price: 38,
      mrp: 45,
      rating: 4.4,
      reviewCount: 14200,
      pillShape: 'Round',
      pillColor: 0xFFFFFFFF,
    ),
    Medicine(
      id: 'm009',
      name: 'Cetirizine 10',
      brandName: 'Zyrtec',
      genericName: 'Cetirizine',
      strength: '10 mg',
      form: 'Tablet',
      category: 'Allergy',
      manufacturer: 'UCB / Pfizer',
      description:
          'Cetirizine is a second-generation antihistamine that relieves sneezing, '
          'runny nose, itchy eyes and skin without significant drowsiness. Works '
          'within an hour of the first dose.',
      composition: [
        Ingredient(name: 'Cetirizine HCl', strengthPerDose: '10 mg', role: 'Antihistamine'),
      ],
      uses: [
        'Sneezing and runny nose',
        'Watery itchy eyes',
        'Urticaria (skin rash / hives)',
        'Seasonal allergic rhinitis',
        'Itchy skin allergies',
      ],
      sideEffects: [
        SideEffect(name: 'Drowsiness', frequency: 'Common', severity: InteractionSeverity.mild),
        SideEffect(name: 'Dry mouth', frequency: 'Uncommon', severity: InteractionSeverity.mild),
        SideEffect(name: 'Fatigue', frequency: 'Uncommon', severity: InteractionSeverity.mild),
        SideEffect(name: 'Difficulty passing urine', frequency: 'Rare', severity: InteractionSeverity.moderate),
      ],
      interactions: [
        DrugInteraction(
          type: InteractionType.alcohol,
          substance: 'Alcohol',
          severity: InteractionSeverity.moderate,
          note: 'Alcohol greatly increases drowsiness and impairs coordination. Avoid driving.',
        ),
        DrugInteraction(
          type: InteractionType.drug,
          substance: 'Sedatives / sleeping pills',
          severity: InteractionSeverity.moderate,
          note: 'Additive drowsiness. Do not combine without doctor advice.',
        ),
        DrugInteraction(
          type: InteractionType.drug,
          substance: 'Kidney disease medicines',
          severity: InteractionSeverity.moderate,
          note: 'Cetirizine is cleared by the kidneys — dose reduction may be needed.',
        ),
      ],
      pregnancyCategory: PregnancyCategory.c,
      lactationSafe: true,
      storage: _cool,
      rx: false,
      otc: true,
      prescriptionRequired: false,
      price: 9,
      mrp: 12,
      rating: 4.4,
      reviewCount: 22400,
      pillShape: 'Oval',
      pillColor: 0xFFFFFFFF,
    ),
    Medicine(
      id: 'm010',
      name: 'Pan 40',
      brandName: 'Pan',
      genericName: 'Pantoprazole',
      strength: '40 mg',
      form: 'Tablet',
      category: 'Digestive',
      manufacturer: 'Abbott',
      description:
          'Pantoprazole is a proton pump inhibitor (PPI) that reduces stomach acid '
          'production. Used for acidity, gastritis, GERD, ulcers and acid-induced '
          'heartburn.',
      composition: [
        Ingredient(name: 'Pantoprazole sodium', strengthPerDose: '40 mg', role: 'Proton pump inhibitor'),
      ],
      uses: [
        'Acidity and heartburn',
        'Gastroesophageal reflux disease (GERD)',
        'Gastritis and stomach ulcer',
        'Duodenal ulcer',
        'Zollinger-Ellison syndrome',
      ],
      sideEffects: [
        SideEffect(name: 'Headache', frequency: 'Common', severity: InteractionSeverity.mild),
        SideEffect(name: 'Diarrhoea', frequency: 'Uncommon', severity: InteractionSeverity.mild),
        SideEffect(name: 'Nausea', frequency: 'Uncommon', severity: InteractionSeverity.mild),
        SideEffect(name: 'Low magnesium (long term)', frequency: 'Rare', severity: InteractionSeverity.moderate),
      ],
      interactions: [
        DrugInteraction(
          type: InteractionType.alcohol,
          substance: 'Alcohol',
          severity: InteractionSeverity.moderate,
          note: 'Alcohol increases stomach acid production and worsens reflux.',
        ),
        DrugInteraction(
          type: InteractionType.food,
          substance: 'Heavy & spicy meals',
          severity: InteractionSeverity.mild,
          note: 'Take 30–60 minutes before a meal for best effect.',
        ),
        DrugInteraction(
          type: InteractionType.drug,
          substance: 'Clopidogrel / Methotrexate',
          severity: InteractionSeverity.moderate,
          note: 'PPIs can reduce the absorption and efficacy of these medicines.',
        ),
      ],
      pregnancyCategory: PregnancyCategory.b,
      lactationSafe: true,
      storage: _cool,
      rx: false,
      otc: true,
      prescriptionRequired: false,
      price: 58,
      mrp: 72,
      rating: 4.3,
      reviewCount: 16800,
      pillShape: 'Oval',
      pillColor: 0xFFF0E4C8,
    ),
    Medicine(
      id: 'm011',
      name: 'Shelcal 500',
      brandName: 'Shelcal',
      genericName: 'Calcium Carbonate + Vitamin D3',
      strength: '500 mg + 250 IU',
      form: 'Tablet',
      category: 'Vitamins',
      manufacturer: 'Torrent',
      description:
          'Calcium carbonate with vitamin D3 supplements the daily calcium '
          'requirement, strengthening bones and teeth and preventing '
          'osteoporosis and calcium deficiency.',
      composition: [
        Ingredient(name: 'Calcium Carbonate', strengthPerDose: '500 mg', role: 'Bone mineral'),
        Ingredient(name: 'Vitamin D3 (cholecalciferol)', strengthPerDose: '250 IU', role: 'Vitamin supplement'),
      ],
      uses: [
        'Calcium deficiency',
        'Bone density improvement',
        'Osteoporosis prevention',
        'Teeth and nail strengthening',
        'Pregnancy calcium supplementation',
      ],
      sideEffects: [
        SideEffect(name: 'Constipation', frequency: 'Common', severity: InteractionSeverity.mild),
        SideEffect(name: 'Bloating', frequency: 'Uncommon', severity: InteractionSeverity.mild),
        SideEffect(name: 'Acid reflux', frequency: 'Uncommon', severity: InteractionSeverity.mild),
      ],
      interactions: [
        DrugInteraction(
          type: InteractionType.food,
          substance: 'Oxalic acid food (spinach, beetroot)',
          severity: InteractionSeverity.mild,
          note: 'Oxalates bind calcium and reduce absorption. Avoid taking together.',
        ),
        DrugInteraction(
          type: InteractionType.drug,
          substance: 'Levothyroxine / Tetracycline / Iron',
          severity: InteractionSeverity.moderate,
          note: 'Calcium reduces their absorption. Space doses at least 4 hours apart.',
        ),
      ],
      pregnancyCategory: PregnancyCategory.c,
      lactationSafe: true,
      storage: _cool,
      rx: false,
      otc: true,
      prescriptionRequired: false,
      price: 74,
      mrp: 96,
      rating: 4.3,
      reviewCount: 11200,
      pillShape: 'Round',
      pillColor: 0xFFFFFFFF,
    ),
    Medicine(
      id: 'm012',
      name: 'Becosules',
      brandName: 'Becosules',
      genericName: 'Vitamin B-complex + Biotin',
      strength: 'Capsule',
      form: 'Capsule',
      category: 'Vitamins',
      manufacturer: 'Rusan Pharma',
      description:
          'A multivitamin B-complex capsule supporting energy metabolism, nerve '
          'health and red blood cell formation, commonly used for weakness and '
          'vitamin B deficiency.',
      composition: [
        Ingredient(name: 'Vitamin B1 (Thiamine)', strengthPerDose: '100 mg', role: 'Metabolism'),
        Ingredient(name: 'Vitamin B2 (Riboflavin)', strengthPerDose: '100 mg', role: 'Metabolism'),
        Ingredient(name: 'Vitamin B6 (Pyridoxine)', strengthPerDose: '100 mg', role: 'Nerve health'),
        Ingredient(name: 'Vitamin B12 (Cyanocobalamin)', strengthPerDose: '1000 mcg', role: 'Red blood cells'),
        Ingredient(name: 'Folic acid', strengthPerDose: '400 mcg', role: 'DNA synthesis'),
        Ingredient(name: 'Biotin', strengthPerDose: '200 mcg', role: 'Hair & skin'),
      ],
      uses: [
        'Vitamin B deficiency',
        'Anaemia and weakness',
        'Hair fall and brittle nails',
        'Nerve health support',
        'Convalescence recovery',
      ],
      sideEffects: [
        SideEffect(name: 'Nausea', frequency: 'Uncommon', severity: InteractionSeverity.mild),
        SideEffect(name: 'Dark yellow urine', frequency: 'Common (harmless)', severity: InteractionSeverity.mild),
        SideEffect(name: 'Acne-like rash', frequency: 'Rare', severity: InteractionSeverity.mild),
      ],
      interactions: [
        DrugInteraction(
          type: InteractionType.drug,
          substance: 'Levodopa',
          severity: InteractionSeverity.moderate,
          note: 'Vitamin B6 can reduce the effectiveness of levodopa therapy.',
        ),
        DrugInteraction(
          type: InteractionType.drug,
          substance: 'Methotrexate',
          severity: InteractionSeverity.moderate,
          note: 'Folic acid can reduce methotrexate side effects and efficacy.',
        ),
      ],
      pregnancyCategory: PregnancyCategory.a,
      lactationSafe: true,
      storage: _cool,
      rx: false,
      otc: true,
      prescriptionRequired: false,
      price: 96,
      mrp: 118,
      rating: 4.4,
      reviewCount: 9400,
      pillShape: 'Capsule',
      pillColor: 0xFF2E7D32,
    ),
    Medicine(
      id: 'm013',
      name: 'Montair-LC',
      brandName: 'Montair-LC',
      genericName: 'Montelukast + Levocetirizine',
      strength: '10 mg / 5 mg',
      form: 'Tablet',
      category: 'Respiratory',
      manufacturer: 'Sun Pharma',
      description:
          'A combination of montelukast (leukotriene receptor antagonist) and '
          'levocetirizine (antihistamine) used for asthma prevention and allergic '
          'rhinitis, especially when symptoms occur at night.',
      composition: [
        Ingredient(name: 'Montelukast sodium', strengthPerDose: '10 mg', role: 'Leukotriene antagonist'),
        Ingredient(name: 'Levocetirizine', strengthPerDose: '5 mg', role: 'Antihistamine'),
      ],
      uses: [
        'Asthma prevention',
        'Allergic rhinitis',
        'Night-time cough and wheeze',
        'Seasonal allergies',
        'Dust-mite allergy',
      ],
      sideEffects: [
        SideEffect(name: 'Headache', frequency: 'Common', severity: InteractionSeverity.mild),
        SideEffect(name: 'Sleep disturbance or vivid dreams', frequency: 'Uncommon', severity: InteractionSeverity.moderate),
        SideEffect(name: 'Abdominal pain', frequency: 'Uncommon', severity: InteractionSeverity.mild),
        SideEffect(name: 'Mood or behaviour changes', frequency: 'Rare', severity: InteractionSeverity.moderate),
      ],
      interactions: [
        DrugInteraction(
          type: InteractionType.drug,
          substance: 'Phenobarbital / Rifampicin',
          severity: InteractionSeverity.severe,
          note: 'These reduce montelukast levels by more than 50%. Avoid combination.',
        ),
        DrugInteraction(
          type: InteractionType.drug,
          substance: 'Warfarin',
          severity: InteractionSeverity.moderate,
          note: 'Montelukast can increase the anticoagulant effect of warfarin.',
        ),
        DrugInteraction(
          type: InteractionType.alcohol,
          substance: 'Alcohol',
          severity: InteractionSeverity.moderate,
          note: 'Alcohol can worsen nighttime symptoms and disrupt sleep.',
        ),
      ],
      pregnancyCategory: PregnancyCategory.b,
      lactationSafe: true,
      storage: _room,
      rx: false,
      otc: true,
      prescriptionRequired: false,
      price: 112,
      mrp: 135,
      rating: 4.2,
      reviewCount: 6700,
      pillShape: 'Oval',
      pillColor: 0xFFFFD966,
    ),
    Medicine(
      id: 'm014',
      name: 'Deriphyllin',
      brandName: 'Deriphyllin',
      genericName: 'Etophylline + Theophylline',
      strength: '77 mg / 23 mg',
      form: 'Tablet',
      category: 'Respiratory',
      manufacturer: 'Cipla',
      description:
          'A bronchodilator combination used to relieve breathlessness and chest '
          'congestion in asthma and chronic bronchitis by relaxing airway muscles.',
      composition: [
        Ingredient(name: 'Etophylline', strengthPerDose: '77 mg', role: 'Bronchodilator'),
        Ingredient(name: 'Theophylline', strengthPerDose: '23 mg', role: 'Bronchodilator'),
      ],
      uses: [
        'Asthma',
        'Chronic bronchitis',
        'Breathlessness',
        'Chest congestion',
        'COPD symptoms',
      ],
      sideEffects: [
        SideEffect(name: 'Nausea and vomiting', frequency: 'Common', severity: InteractionSeverity.moderate),
        SideEffect(name: 'Palpitations', frequency: 'Common', severity: InteractionSeverity.moderate),
        SideEffect(name: 'Tremors', frequency: 'Uncommon', severity: InteractionSeverity.moderate),
        SideEffect(name: 'Fast heart rate', frequency: 'Rare', severity: InteractionSeverity.severe),
      ],
      interactions: [
        DrugInteraction(
          type: InteractionType.food,
          substance: 'Tea & coffee (caffeine)',
          severity: InteractionSeverity.moderate,
          note: 'Caffeine adds to theophylline levels and increases heart rate and jitteriness.',
        ),
        DrugInteraction(
          type: InteractionType.alcohol,
          substance: 'Alcohol',
          severity: InteractionSeverity.severe,
          note: 'Alcohol with theophylline causes dangerous heart rhythm disturbances.',
        ),
        DrugInteraction(
          type: InteractionType.drug,
          substance: 'Ciprofloxacin / Clarithromycin',
          severity: InteractionSeverity.severe,
          note: 'These antibiotics raise theophylline to toxic levels. Avoid.',
        ),
        DrugInteraction(
          type: InteractionType.drug,
          substance: 'Carbamazepine / Phenytoin',
          severity: InteractionSeverity.moderate,
          note: 'These lower theophylline levels and reduce its effectiveness.',
        ),
      ],
      pregnancyCategory: PregnancyCategory.c,
      lactationSafe: true,
      storage: _cool,
      rx: true,
      otc: false,
      prescriptionRequired: true,
      price: 78,
      mrp: 92,
      rating: 4.0,
      reviewCount: 3900,
      pillShape: 'Round',
      pillColor: 0xFFF2E2A0,
    ),
    Medicine(
      id: 'm015',
      name: 'Clotrimazole 1%',
      brandName: 'Canesten',
      genericName: 'Clotrimazole',
      strength: '1% w/w',
      form: 'Cream',
      category: 'Skin',
      manufacturer: 'Bayer',
      description:
          'An antifungal cream used to treat fungal infections such as ringworm, '
          'athlete\'s foot, jock itch and yeast infections of the skin.',
      composition: [
        Ingredient(name: 'Clotrimazole', strengthPerDose: '1% w/w', role: 'Antifungal'),
      ],
      uses: [
        'Ringworm (tinea corporis)',
        'Athlete\'s foot (tinea pedis)',
        'Jock itch (tinea cruris)',
        'Fungal nail infection',
        'Candidal skin infection',
      ],
      sideEffects: [
        SideEffect(name: 'Local burning or stinging', frequency: 'Common', severity: InteractionSeverity.mild),
        SideEffect(name: 'Skin irritation', frequency: 'Uncommon', severity: InteractionSeverity.mild),
        SideEffect(name: 'Itching', frequency: 'Uncommon', severity: InteractionSeverity.mild),
      ],
      interactions: [
        DrugInteraction(
          type: InteractionType.drug,
          substance: 'Warfarin',
          severity: InteractionSeverity.moderate,
          note: 'Absorbed clotrimazole can increase the effect of warfarin.',
        ),
      ],
      pregnancyCategory: PregnancyCategory.b,
      lactationSafe: true,
      storage: _room,
      rx: false,
      otc: true,
      prescriptionRequired: false,
      price: 44,
      mrp: 58,
      rating: 4.3,
      reviewCount: 8100,
      pillShape: 'Tube',
      pillColor: 0xFFFFFFFF,
    ),
    Medicine(
      id: 'm016',
      name: 'Alprax 0.25',
      brandName: 'Alprax',
      genericName: 'Alprazolam',
      strength: '0.25 mg',
      form: 'Tablet',
      category: 'Mental Health',
      manufacturer: 'Torrent',
      description:
          'Alprazolam is a benzodiazepine used for short-term relief of anxiety, '
          'panic attacks and short-term insomnia. It should be used only under '
          'strict medical supervision due to dependency risk.',
      composition: [
        Ingredient(name: 'Alprazolam', strengthPerDose: '0.25 mg', role: 'Benzodiazepine'),
      ],
      uses: [
        'Anxiety disorders',
        'Panic attacks',
        'Short-term insomnia',
        'Short-term social anxiety',
      ],
      sideEffects: [
        SideEffect(name: 'Drowsiness and sedation', frequency: 'Very common', severity: InteractionSeverity.moderate),
        SideEffect(name: 'Muscle weakness', frequency: 'Common', severity: InteractionSeverity.mild),
        SideEffect(name: 'Memory problems', frequency: 'Common', severity: InteractionSeverity.moderate),
        SideEffect(name: 'Dependency', frequency: 'Common (long term)', severity: InteractionSeverity.severe),
        SideEffect(name: 'Breathing difficulty', frequency: 'Rare', severity: InteractionSeverity.severe),
      ],
      interactions: [
        DrugInteraction(
          type: InteractionType.alcohol,
          substance: 'Alcohol',
          severity: InteractionSeverity.severe,
          note:
              'ALCOHOL WITH ALPRAZOLAM CAN BE FATAL. It causes extreme sedation '
              'and respiratory depression. Absolutely avoid.',
        ),
        DrugInteraction(
          type: InteractionType.drug,
          substance: 'Opioids (codeine, tramadol) / sleeping pills',
          severity: InteractionSeverity.severe,
          note: 'Risk of profound sedation, respiratory depression and death.',
        ),
        DrugInteraction(
          type: InteractionType.drug,
          substance: 'Fluoxetine / Sertraline',
          severity: InteractionSeverity.moderate,
          note: 'Can increase alprazolam levels and sedation.',
        ),
      ],
      pregnancyCategory: PregnancyCategory.d,
      lactationSafe: false,
      storage: _cool,
      rx: true,
      otc: false,
      prescriptionRequired: true,
      price: 52,
      mrp: 65,
      rating: 3.9,
      reviewCount: 4200,
      pillShape: 'Round',
      pillColor: 0xFFEDE7F6,
    ),
    Medicine(
      id: 'm017',
      name: 'Levocetirizine 5',
      brandName: 'Xyzal',
      genericName: 'Levocetirizine',
      strength: '5 mg',
      form: 'Tablet',
      category: 'Allergy',
      manufacturer: 'UCB',
      description:
          'Levocetirizine is a non-sedating antihistamine used for allergic rhinitis '
          'and urticaria. It provides 24-hour relief with minimal drowsiness.',
      composition: [
        Ingredient(name: 'Levocetirizine dihydrochloride', strengthPerDose: '5 mg', role: 'Antihistamine'),
      ],
      uses: [
        'Allergic rhinitis',
        'Urticaria / hives',
        'Sneezing and blocked nose',
        'Itchy eyes and throat',
      ],
      sideEffects: [
        SideEffect(name: 'Drowsiness', frequency: 'Uncommon', severity: InteractionSeverity.mild),
        SideEffect(name: 'Dry mouth', frequency: 'Uncommon', severity: InteractionSeverity.mild),
        SideEffect(name: 'Fatigue', frequency: 'Rare', severity: InteractionSeverity.mild),
      ],
      interactions: [
        DrugInteraction(
          type: InteractionType.alcohol,
          substance: 'Alcohol',
          severity: InteractionSeverity.moderate,
          note: 'Increases drowsiness. Avoid driving after taking.',
        ),
        DrugInteraction(
          type: InteractionType.drug,
          substance: 'Ketoconazole / Erythromycin',
          severity: InteractionSeverity.moderate,
          note: 'Reduce levocetirizine clearance and increase its effect.',
        ),
      ],
      pregnancyCategory: PregnancyCategory.c,
      lactationSafe: true,
      storage: _cool,
      rx: false,
      otc: true,
      prescriptionRequired: false,
      price: 8,
      mrp: 11,
      rating: 4.4,
      reviewCount: 19600,
      pillShape: 'Oval',
      pillColor: 0xFFFFFFFF,
    ),
    Medicine(
      id: 'm018',
      name: 'Human Actrapid',
      brandName: 'Human Actrapid',
      genericName: 'Insulin (Regular)',
      strength: '100 IU/mL',
      form: 'Injection',
      category: 'Diabetes',
      manufacturer: 'Human Insulin',
      description:
          'Short-acting human insulin for subcutaneous injection, used to control '
          'blood sugar spikes around meals. Requires refrigeration and proper '
          'storage to remain effective.',
      composition: [
        Ingredient(name: 'Human insulin (regular)', strengthPerDose: '100 IU/mL', role: 'Rapid-acting insulin'),
      ],
      uses: [
        'Type 1 diabetes',
        'Type 2 diabetes (advanced)',
        'Pre and post-meal sugar control',
        'Diabetic ketoacidosis management',
      ],
      sideEffects: [
        SideEffect(name: 'Hypoglycaemia (low sugar)', frequency: 'Common', severity: InteractionSeverity.severe),
        SideEffect(name: 'Injection site reaction', frequency: 'Common', severity: InteractionSeverity.mild),
        SideEffect(name: 'Weight gain', frequency: 'Common', severity: InteractionSeverity.mild),
        SideEffect(name: 'Insulin allergy', frequency: 'Rare', severity: InteractionSeverity.severe),
      ],
      interactions: [
        DrugInteraction(
          type: InteractionType.food,
          substance: 'Skipped or irregular meals',
          severity: InteractionSeverity.severe,
          note: 'Skipping a meal after an insulin dose causes dangerous low blood sugar.',
        ),
        DrugInteraction(
          type: InteractionType.alcohol,
          substance: 'Alcohol',
          severity: InteractionSeverity.severe,
          note: 'Alcohol causes prolonged and unpredictable hypoglycaemia.',
        ),
        DrugInteraction(
          type: InteractionType.drug,
          substance: 'Beta-blockers (Metoprolol, Atenolol)',
          severity: InteractionSeverity.severe,
          note: 'Beta-blockers mask the warning signs of low blood sugar.',
        ),
      ],
      pregnancyCategory: PregnancyCategory.c,
      lactationSafe: true,
      storage: _fridgeDoNotFreeze,
      rx: true,
      otc: false,
      prescriptionRequired: true,
      price: 342,
      mrp: 420,
      rating: 4.5,
      reviewCount: 5600,
      pillShape: 'Vial',
      pillColor: 0xFFF5F5F5,
    ),
    Medicine(
      id: 'm019',
      name: 'Normal Saline 0.9%',
      brandName: 'Sodium Chloride',
      genericName: 'Sodium Chloride',
      strength: '500 mL',
      form: 'IV Fluid',
      category: 'Respiratory',
      manufacturer: 'Fresenius Kabi',
      description:
          'Isotonic saline for intravenous use to restore fluid and electrolyte '
          'balance, used in dehydration, shock and as a diluent for other '
          'injections.',
      composition: [
        Ingredient(name: 'Sodium chloride', strengthPerDose: '0.9% w/v', role: 'IV fluid'),
      ],
      uses: [
        'Severe dehydration',
        'Fluid replacement',
        'Hypotension / shock',
        'Diluent for IV medicines',
        'Sodium chloride deficiency',
      ],
      sideEffects: [
        SideEffect(name: 'Pain at infusion site', frequency: 'Common', severity: InteractionSeverity.mild),
        SideEffect(name: 'Nausea', frequency: 'Uncommon', severity: InteractionSeverity.mild),
        SideEffect(name: 'Fluid overload', frequency: 'Rare', severity: InteractionSeverity.severe),
      ],
      interactions: [
        DrugInteraction(
          type: InteractionType.drug,
          substance: 'Amlodipine / Diuretics',
          severity: InteractionSeverity.moderate,
          note: 'Sodium load can worsen fluid retention and blood pressure.',
        ),
      ],
      pregnancyCategory: PregnancyCategory.c,
      lactationSafe: true,
      storage: _room,
      rx: true,
      otc: false,
      prescriptionRequired: true,
      price: 68,
      mrp: 85,
      rating: 4.6,
      reviewCount: 3100,
      pillShape: 'Bottle',
      pillColor: 0xFFE3F2FD,
    ),
    Medicine(
      id: 'm020',
      name: 'Thyronorm 50',
      brandName: 'Thyronorm',
      genericName: 'Levothyroxine',
      strength: '50 mcg',
      form: 'Tablet',
      category: 'Vitamins',
      manufacturer: 'Abbott',
      description:
          'Levothyroxine is a thyroid hormone replacement used for hypothyroidism '
          'and goitre. Narrow therapeutic index — levels must be monitored closely.',
      composition: [
        Ingredient(name: 'Levothyroxine sodium', strengthPerDose: '50 mcg', role: 'Thyroid hormone'),
      ],
      uses: [
        'Hypothyroidism (underactive thyroid)',
        'Goitre',
        'Post thyroid surgery replacement',
        'Thyroid hormone deficiency in children',
      ],
      sideEffects: [
        SideEffect(name: 'Palpitations', frequency: 'Common (overdose)', severity: InteractionSeverity.moderate),
        SideEffect(name: 'Weight loss', frequency: 'Common (overdose)', severity: InteractionSeverity.mild),
        SideEffect(name: 'Insomnia and anxiety', frequency: 'Common (overdose)', severity: InteractionSeverity.moderate),
        SideEffect(name: 'Bone loss (long-term overdose)', frequency: 'Rare', severity: InteractionSeverity.severe),
      ],
      interactions: [
        DrugInteraction(
          type: InteractionType.food,
          substance: 'Coffee, soy, calcium & high-fibre food',
          severity: InteractionSeverity.moderate,
          note:
              'Take levothyroxine on an empty stomach with water, at least 30–60 '
              'minutes before breakfast, coffee or supplements.',
        ),
        DrugInteraction(
          type: InteractionType.drug,
          substance: 'Calcium / Iron / Antacids',
          severity: InteractionSeverity.severe,
          note: 'These block levothyroxine absorption. Space them 4 hours apart.',
        ),
        DrugInteraction(
          type: InteractionType.drug,
          substance: 'Amiodarone / Lithium',
          severity: InteractionSeverity.moderate,
          note: 'Can alter thyroid hormone requirements substantially.',
        ),
      ],
      pregnancyCategory: PregnancyCategory.a,
      lactationSafe: true,
      storage: _cool,
      rx: true,
      otc: false,
      prescriptionRequired: true,
      price: 92,
      mrp: 118,
      rating: 4.4,
      reviewCount: 7600,
      pillShape: 'Oval',
      pillColor: 0xFFFFFFFF,
    ),
  ];

  static Medicine? byId(String id) {
    for (final m in all) {
      if (m.id == id) return m;
    }
    return null;
  }

  static List<Medicine> byCategory(String category) =>
      all.where((m) => m.category == category).toList();
}
