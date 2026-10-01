
import '../models/symptom.dart';

class MockSymptoms {
  const MockSymptoms._();

  /// Symptoms the user can select, grouped by body system.
  static const List<Symptom> all = [
    Symptom(id: 's_fever', name: 'Fever', iconKey: 'fever', category: 'General'),
    Symptom(id: 's_chills', name: 'Chills', iconKey: 'chills', category: 'General'),
    Symptom(id: 's_fatigue', name: 'Fatigue / Weakness', iconKey: 'fatigue', category: 'General'),
    Symptom(id: 's_bodyache', name: 'Body Ache', iconKey: 'body_ache', category: 'General'),
    Symptom(id: 's_headache', name: 'Headache', iconKey: 'headache', category: 'Neurological'),
    Symptom(id: 's_dizziness', name: 'Dizziness', iconKey: 'dizziness', category: 'Neurological'),
    Symptom(id: 's_chestpain', name: 'Chest Pain', iconKey: 'chest_pain', category: 'Cardiac'),
    Symptom(id: 's_palpitations', name: 'Palpitations', iconKey: 'palpitations', category: 'Cardiac'),
    Symptom(id: 's_cough', name: 'Cough', iconKey: 'cough', category: 'Respiratory'),
    Symptom(id: 's_coldsoread', name: 'Sore Throat', iconKey: 'sore_throat', category: 'Respiratory'),
    Symptom(id: 's_runlynose', name: 'Runny / Blocked Nose', iconKey: 'runny_nose', category: 'Respiratory'),
    Symptom(id: 's_breathless', name: 'Breathlessness', iconKey: 'breathlessness', category: 'Respiratory'),
    Symptom(id: 's_wheeze', name: 'Wheezing', iconKey: 'wheezing', category: 'Respiratory'),
    Symptom(id: 's_headache2', name: 'Sinus Pain', iconKey: 'sinus_pain', category: 'Respiratory'),
    Symptom(id: 's_eyeitch', name: 'Itchy / Watery Eyes', iconKey: 'eye_itch', category: 'Eye'),
    Symptom(id: 's_earpain', name: 'Ear Pain', iconKey: 'ear_pain', category: 'Eye'),
    Symptom(id: 's_nausea', name: 'Nausea', iconKey: 'nausea', category: 'Digestive'),
    Symptom(id: 's_vomiting', name: 'Vomiting', iconKey: 'vomiting', category: 'Digestive'),
    Symptom(id: 's_diarrhoea', name: 'Diarrhoea', iconKey: 'diarrhoea', category: 'Digestive'),
    Symptom(id: 's_constipation', name: 'Constipation', iconKey: 'constipation', category: 'Digestive'),
    Symptom(id: 's_acidity', name: 'Acidity / Heartburn', iconKey: 'acidity', category: 'Digestive'),
    Symptom(id: 's_stomach', name: 'Stomach Pain', iconKey: 'stomach_pain', category: 'Digestive'),
    Symptom(id: 's_appetite', name: 'Loss of Appetite', iconKey: 'loss_of_appetite', category: 'Digestive'),
    Symptom(id: 's_jointpain', name: 'Joint Pain', iconKey: 'joint_pain', category: 'Musculoskeletal'),
    Symptom(id: 's_backpain', name: 'Back Pain', iconKey: 'back_pain', category: 'Musculoskeletal'),
    Symptom(id: 's_musclepain', name: 'Muscle Pain', iconKey: 'muscle_pain', category: 'Musculoskeletal'),
    Symptom(id: 's_rash', name: 'Skin Rash', iconKey: 'skin_rash', category: 'Skin'),
    Symptom(id: 's_itching', name: 'Itching', iconKey: 'itching', category: 'Skin'),
    Symptom(id: 's_sleep', name: 'Sleep Problems', iconKey: 'sleep_problems', category: 'Mental Health'),
    Symptom(id: 's_anxiety', name: 'Anxiety / Stress', iconKey: 'anxiety', category: 'Mental Health'),
    Symptom(id: 's_urination', name: 'Excess Urination', iconKey: 'excess_urination', category: 'Other'),
    Symptom(id: 's_numbness', name: 'Numbness / Tingling', iconKey: 'numbness', category: 'Neurological'),
    Symptom(id: 's_fainting', name: 'Fainting / Dizziness Spells', iconKey: 'fainting', category: 'Neurological'),
    Symptom(id: 's_stiffness', name: 'Joint Stiffness', iconKey: 'joint_stiffness', category: 'Musculoskeletal'),
    Symptom(id: 's_weightloss', name: 'Unexplained Weight Loss', iconKey: 'weight_loss', category: 'General'),
  ];

  static List<Symptom> byCategory(String c) =>
      all.where((s) => s.category == c).toList();

  /// The follow-up questions asked after symptom selection.
  static const List<SymptomQuestion> questions = [
    SymptomQuestion(
      id: 'q_duration',
      prompt: 'How long have you been experiencing this?',
      iconKey: 'duration',
      options: [
        'Less than 24 hours',
        '1 – 3 days',
        '4 – 7 days',
        '1 – 4 weeks',
        'More than a month',
      ],
    ),
    SymptomQuestion(
      id: 'q_severity',
      prompt: 'How severe are your symptoms right now?',
      iconKey: 'severity',
      options: [
        'Mild — noticeable but I can do my usual work',
        'Moderate — it is affecting my daily work',
        'Severe — I am struggling with basic tasks',
        'Very severe — I cannot manage at all',
      ],
    ),
    SymptomQuestion(
      id: 'q_fever',
      prompt: 'Have you measured your body temperature?',
      iconKey: 'fever',
      options: [
        'No fever / under 99°F',
        'Low grade — 99°F to 100.4°F',
        'Moderate — 100.5°F to 102°F',
        'High — above 102°F',
        'I have not measured it',
      ],
    ),
    SymptomQuestion(
      id: 'q_cough',
      prompt: 'What kind of cough do you have?',
      iconKey: 'cough',
      options: [
        'Dry cough, no phlegm',
        'Productive cough with clear phlegm',
        'Productive cough with yellow or green phlegm',
        'Cough with blood',
        'Night-time cough only',
      ],
    ),
    SymptomQuestion(
      id: 'q_stomach',
      prompt: 'Where is the abdominal discomfort?',
      iconKey: 'stomach_pain',
      options: [
        'Upper abdomen (above the belly button)',
        'Around the belly button',
        'Lower abdomen (below the belly button)',
        'Right side',
        'Left side',
      ],
    ),
    SymptomQuestion(
      id: 'q_breathing',
      prompt: 'Can you speak in full sentences?',
      iconKey: 'breathlessness',
      options: [
        'Yes, comfortably',
        'Yes, but I feel short of breath',
        'No, I can only manage a few words',
      ],
    ),
  ];

  /// Conditions the engine can match against.
  static const List<Condition> conditions = [
    Condition(
      id: 'c_viral_fever',
      name: 'Viral Fever (Influenza-like illness)',
      description:
          'A self-limiting viral infection. The body\'s immune system is fighting '
          'off the virus, which is why fever, body ache and fatigue appear together.',
      symptomIds: ['s_fever', 's_chills', 's_bodyache', 's_headache', 's_fatigue', 's_runlynose', 's_cough'],
      recommendations: [
        'Take paracetamol 650 mg every 6–8 hours if temperature is above 100°F',
        'Drink at least 3 litres of warm fluids daily',
        'Rest as much as possible — most viral fevers resolve in 3–5 days',
        'See a doctor if fever persists beyond 4 days or crosses 103°F',
      ],
      selfCare: [
        'Complete bed rest for 2 days',
        'Warm sponging if temperature exceeds 102°F',
        'Steam inhalation twice daily for congestion',
        'Lightweight, easily digestible meals',
        'Avoid strong tea, coffee and oily food',
      ],
      overTheCounterCategories: ['Pain Relief', 'Allergy'],
      seeDoctorWithinHours: 48,
    ),
    Condition(
      id: 'c_common_cold',
      name: 'Common Cold (Viral Upper Respiratory Infection)',
      description:
          'A mild viral infection of the nose and throat. Sneezing, a runny nose '
          'and sore throat are typical and usually clear within a week.',
      symptomIds: ['s_runlynose', 's_coldsoread', 's_cough', 's_fatigue', 's_headache', 's_eyeitch'],
      recommendations: [
        'An antihistamine such as cetirizine 10 mg once daily for sneezing',
        'Steam inhalation and saline nasal drops for congestion',
        'Warm honey and lemon water twice a day for sore throat',
        'Consult a doctor if symptoms last beyond 7 days or fever develops',
      ],
      selfCare: [
        'Steam inhalation 2–3 times a day',
        'Saline nasal spray for a blocked nose',
        'Gargle with warm salt water twice daily',
        'Warm fluids such as herbal tea with honey',
        'Rest and avoid going to work or school if you have fever',
        'Wash hands frequently to avoid spreading the infection',
      ],
      overTheCounterCategories: ['Allergy', 'Pain Relief'],
      seeDoctorWithinHours: 72,
    ),
    Condition(
      id: 'c_dengue',
      name: 'Dengue Fever (suspected — needs confirmation)',
      description:
          'A mosquito-borne viral fever. It begins like a normal fever but can '
          'develop into dengue hemorrhagic fever. High fever with severe body pain, '
          'nausea and very low platelet counts needs urgent attention.',
      symptomIds: ['s_fever', 's_bodyache', 's_headache', 's_nausea', 's_vomiting', 's_musclepain', 's_jointpain', 's_appetite'],
      recommendations: [
        'Get a dengue NS1 antigen test and CBC platelet count urgently',
        'Do NOT take aspirin, ibuprofen or diclofenac — they worsen bleeding',
        'Only paracetamol is recommended for fever in dengue',
        'Drink oral rehydration solution frequently',
        'Go to hospital immediately if you notice bleeding, severe abdominal pain or restlessness',
      ],
      selfCare: [
        'Complete bed rest — do not travel or work',
        'Oral rehydration solution after every episode of vomiting',
        'Monitor platelet count every 24–48 hours',
        'Avoid paracetamol overdose — never exceed 4 g per day',
        'Use a mosquito repellent to prevent others catching it',
        'Watch for warning signs: bleeding gums, severe stomach pain, cold clammy skin',
      ],
      overTheCounterCategories: ['Pain Relief'],
      seeDoctorWithinHours: 12,
    ),
    Condition(
      id: 'c_pneumonia',
      name: 'Lower Respiratory Tract Infection',
      description:
          'Infection of the lungs or lower airways. Productive cough with coloured '
          'phlegm, breathlessness and chest pain suggest the infection has spread '
          'beyond the upper throat.',
      symptomIds: ['s_cough', 's_breathless', 's_chestpain', 's_fever', 's_fatigue', 's_wheeze', 's_chills'],
      recommendations: [
        'See a doctor today — you may need a chest X-ray and antibiotics',
        'Book a CBC and chest X-ray',
        'Take paracetamol for fever and pain',
        'Use a mucolytic to loosen chest congestion',
        'Antibiotics are often needed — do not self-medicate',
      ],
      selfCare: [
        'Steam inhalation 2–3 times a day',
        'Warm fluids to loosen mucus',
        'Complete bed rest until fever is gone for 48 hours',
        'Maintain a humid room to ease breathing',
        'Sleep propped up with extra pillows',
        'Avoid going out in cold or dusty air',
      ],
      overTheCounterCategories: ['Pain Relief', 'Respiratory'],
      seeDoctorWithinHours: 24,
    ),
    Condition(
      id: 'c_gastritis',
      name: 'Acute Gastritis / Acidity',
      description:
          'Inflammation of the stomach lining, usually from irritating food, alcohol, '
          'NSAIDs or an infection. Causes burning in the upper abdomen, nausea and '
          'early fullness.',
      symptomIds: ['s_acidity', 's_stomach', 's_nausea', 's_appetite', 's_vomiting'],
      recommendations: [
        'Take pantoprazole 40 mg once daily on an empty stomach for 7 days',
        'Antacid gel as needed for immediate relief',
        'Avoid ibuprofen, diclofenac and aspirin — they worsen the lining',
        'Consult a doctor if symptoms persist beyond 2 weeks',
      ],
      selfCare: [
        'Small frequent meals instead of large heavy meals',
        'Avoid spicy, oily, fried and very acidic food',
        'Do not lie down for 3 hours after eating',
        'Cut down on tea, coffee, alcohol and carbonated drinks',
        'Drink plenty of water through the day',
        'Elevate the head end of the bed by 15 cm for night-time reflux',
      ],
      overTheCounterCategories: ['Digestive'],
      seeDoctorWithinHours: 48,
    ),
    Condition(
      id: 'c_food_poisoning',
      name: 'Acute Gastroenteritis (Food Poisoning)',
      description:
          'Stomach and intestinal infection from contaminated food or water. Comes '
          'on abruptly with vomiting, watery diarrhoea and cramps.',
      symptomIds: ['s_vomiting', 's_diarrhoea', 's_stomach', 's_nausea', 's_fever'],
      recommendations: [
        'Take ORS after every loose stool to prevent dehydration',
        'Oral rehydration is the priority, not anti-diarrhoeal tablets',
        'A probiotic helps restore gut flora',
        'See a doctor if there is blood in stool, or it lasts more than 3 days',
      ],
      selfCare: [
        'Sip ORS or buttermilk frequently, in small sips',
        'Rest the stomach for the first 6–8 hours — avoid solid food',
        'Introduce bland food like khichdi, banana and curd gradually',
        'Avoid milk, spicy food and fried items for 3–4 days',
        'Maintain strict hand hygiene to protect family members',
        'Drink only boiled or packaged water',
      ],
      overTheCounterCategories: ['Digestive'],
      seeDoctorWithinHours: 24,
    ),
    Condition(
      id: 'c_uti',
      name: 'Urinary Tract Infection',
      description:
          'Bacterial infection of the urinary tract. Burning while passing urine, '
          'frequent urges to urinate and lower abdominal discomfort are typical, more '
          'common in women.',
      symptomIds: ['s_urination', 's_stomach', 's_fever', 's_backpain'],
      recommendations: [
        'Get a urine routine and microscopy test done',
        'Drink at least 3 litres of water daily',
        'Antibiotics are usually required — complete the full course',
        'See a doctor urgently if you have fever with back pain',
      ],
      selfCare: [
        'Cranberry juice and plenty of water',
        'Do not hold urine — urinate frequently',
        'Wipe front to back after using the toilet',
        'Avoid caffeine and alcohol until symptoms settle',
        'Wear loose cotton underwear',
        'Do not use bubble baths or vaginal deodorants',
      ],
      overTheCounterCategories: ['Digestive'],
      seeDoctorWithinHours: 24,
    ),
    Condition(
      id: 'c_allergy',
      name: 'Allergic Reaction (Rhinitis / Urticaria)',
      description:
          'An immune reaction to pollen, dust mites, animal dander or a specific food. '
          'Sneezing, watery eyes, itchy skin and hives without fever point here.',
      symptomIds: ['s_runlynose', 's_eyeitch', 's_itching', 's_rash', 's_cough', 's_coldsoread'],
      recommendations: [
        'Cetirizine 10 mg once daily, or levocetirizine 5 mg at night',
        'A steroid nasal spray such as mometasone for persistent symptoms',
        'Identify and avoid the trigger — dust, pollen, pet dander or a food',
        'See a doctor if you develop swelling of lips or tongue',
      ],
      selfCare: [
        'Antihistamine once daily during the allergy season',
        'Wash bedding weekly in hot water to kill dust mites',
        'Use a mosquito net and keep windows closed during pollen season',
        'Keep pets out of the bedroom',
        'Saline nasal spray to rinse pollen from the nose',
        'Cold compress for itchy skin patches',
      ],
      overTheCounterCategories: ['Allergy', 'Skin'],
      seeDoctorWithinHours: 72,
    ),
    Condition(
      id: 'c_migraine',
      name: 'Migraine / Tension Headache',
      description:
          'A primary headache disorder causing throbbing pain, often with nausea, '
          'sensitivity to light and a preference to lie in a dark room.',
      symptomIds: ['s_headache', 's_nausea', 's_dizziness', 's_eyeitch', 's_fatigue'],
      recommendations: [
        'Paracetamol 650 mg, or a combination analgesic for pain',
        'Take the dose early — the earlier you take it, the better it works',
        'Maintain a fixed sleep schedule',
        'Consult a neurologist if headaches occur more than twice a week',
      ],
      selfCare: [
        'Rest in a dark, quiet, cool room',
        'Apply a cold compress to the forehead',
        'Stay hydrated — dehydration is the most common trigger',
        'Reduce screen time and bright light',
        'Track triggers in a diary — food, sleep and stress all matter',
        'Regular sleep and meals prevent most attacks',
      ],
      overTheCounterCategories: ['Pain Relief'],
      seeDoctorWithinHours: 72,
    ),
    Condition(
      id: 'c_dengue_warn',
      name: 'Dengue Warning Signs Detected',
      description:
          'Your answers include a combination associated with dengue haemorrhagic '
          'fever. This needs urgent medical evaluation, not home care.',
      symptomIds: ['s_vomiting', 's_stomach', 's_musclepain', 's_chills', 's_fatigue'],
      recommendations: [
        'Go to a hospital today — do not wait for this to resolve on its own',
        'Get CBC platelets, NS1 antigen and liver function tests',
        'Never take aspirin, ibuprofen or diclofenac',
        'Only paracetamol is safe for fever in suspected dengue',
      ],
      selfCare: [
        'Immediate medical evaluation is required',
        'Start ORS immediately to prevent dehydration',
        'Monitor for bleeding gums or nose',
        'Watch for restlessness, cold clammy skin or severe stomach pain',
        'Keep a close eye on urine output',
        'Do not use mosquito repellent sprays on a feverish patient',
      ],
      overTheCounterCategories: ['Pain Relief'],
      seeDoctorWithinHours: 6,
    ),
    Condition(
      id: 'c_anxiety',
      name: 'Anxiety / Stress Response',
      description:
          'Persistent worry, restlessness, difficulty sleeping and physical tension '
          'without an infection-related cause.',
      symptomIds: ['s_anxiety', 's_sleep', 's_fatigue', 's_chestpain', 's_dizziness', 's_headache', 's_palpitations'],
      recommendations: [
        'Practice 4-7-8 breathing, 5 minutes twice daily',
        'Regular aerobic exercise — 30 minutes on at least 5 days a week',
        'Maintain a fixed sleep and wake time',
        'Speak to a doctor if symptoms persist beyond 2 weeks',
      ],
      selfCare: [
        '4-7-8 breathing: inhale 4s, hold 7s, exhale 8s',
        'Limit caffeine after 2 pm',
        'Keep a consistent sleep schedule even on weekends',
        'Reduce doomscrolling and news exposure',
        'Talk to someone you trust daily',
        'Practise gratitude — write three good things daily',
      ],
      overTheCounterCategories: ['Mental Health'],
      seeDoctorWithinHours: 96,
    ),
    Condition(
      id: 'c_arthritis',
      name: 'Musculoskeletal Pain / Arthritis',
      description:
          'Joint stiffness, swelling and pain, often worse after activity or in the '
          'morning, suggestive of degenerative or inflammatory joint disease.',
      symptomIds: ['s_jointpain', 's_backpain', 's_musclepain', 's_stiffness'],
      recommendations: [
        'Topical diclofenac gel for localised joint pain',
        'Paracetamol for pain relief',
        'Consult an orthopaedic doctor if pain lasts beyond 2 weeks',
        'An X-ray or arthritis profile may be advised',
      ],
      selfCare: [
        'Warm compress or hot water bag on stiff joints for 15 minutes',
        'Low-impact exercise such as swimming or cycling',
        'Maintain a healthy weight to reduce joint load',
        'Avoid prolonged sitting in one position',
        'Gentle stretching twice daily',
        'Calcium and vitamin D supplementation if advised',
      ],
      overTheCounterCategories: ['Pain Relief', 'Vitamins'],
      seeDoctorWithinHours: 96,
    ),
    Condition(
      id: 'c_diabetes_sym',
      name: 'Possible Blood Sugar Dysregulation',
      description:
          'Fatigue with excessive urination, increased thirst and unexplained weight '
          'loss is the classic triad of abnormal blood sugar control.',
      symptomIds: ['s_fatigue', 's_urination', 's_weightloss', 's_dizziness', 's_fainting', 's_headache'],
      recommendations: [
        'Get fasting blood sugar and HbA1c tested within a day or two',
        'Drink water frequently to compensate for fluid loss',
        'See a doctor promptly — untreated high sugar affects kidneys and eyes',
        'If you already have diabetes, check for infection causing the rise',
      ],
      selfCare: [
        'Book HbA1c and fasting glucose tests',
        'Keep a log of what you eat and your energy levels',
        'Stay hydrated throughout the day',
        'Avoid sugary drinks and refined carbohydrates',
        'Walk 20–30 minutes daily',
        'Take prescribed medicines on time',
      ],
      overTheCounterCategories: ['Diabetes'],
      seeDoctorWithinHours: 24,
    ),
    Condition(
      id: 'c_sinusitis',
      name: 'Sinusitis (Sinus Infection)',
      description:
          'Inflammation of the sinus cavities. Facial pain over the cheeks, eyes or '
          'forehead with a blocked nose and facial pressure is the typical pattern.',
      symptomIds: ['s_headache2', 's_runlynose', 's_coldsoread', 's_eyeitch', 's_headache'],
      recommendations: [
        'Saline nasal rinse or a steroid nasal spray to reduce swelling',
        'Paracetamol for facial pain and pressure',
        'Steam inhalation twice a day to loosen mucus',
        'See a doctor if symptoms persist beyond 10 days or worsen after improving',
      ],
      selfCare: [
        'Warm compress over the cheeks and forehead for 10 minutes',
        'Humidify the room you sleep in',
        'Drink plenty of fluids to thin the mucus',
        'Sleep with the head slightly elevated',
        'Avoid known allergens, dust and cigarette smoke',
      ],
      overTheCounterCategories: ['Allergy', 'Pain Relief'],
      seeDoctorWithinHours: 72,
    ),
    Condition(
      id: 'c_otitis_media',
      name: 'Otitis Media (Middle Ear Infection)',
      description:
          'Infection of the middle ear, usually following a cold. Ear pain with '
          'fever, reduced hearing and pressure in the ear are common.',
      symptomIds: ['s_earpain', 's_fever', 's_headache'],
      recommendations: [
        'Paracetamol or ibuprofen for pain and fever',
        'Do not insert oil, drops or cotton buds into the ear canal',
        'See a doctor within a day — children with ear pain and fever need an ear examination',
        'Antibiotics are usually needed for confirmed bacterial middle ear infection',
      ],
      selfCare: [
        'Apply a warm compress over the ear to ease the pain',
        'Keep the affected ear dry while bathing',
        'Rest and drink warm fluids',
        'Avoid swimming until the infection has cleared',
      ],
      overTheCounterCategories: ['Pain Relief'],
      seeDoctorWithinHours: 24,
    ),
    Condition(
      id: 'c_functional_constipation',
      name: 'Functional Constipation / Irritable Bowel',
      description:
          'Infrequent or difficult bowel movements with bloating and acidity. Often '
          'related to low fibre, low fluid intake, stress and inactivity.',
      symptomIds: ['s_constipation', 's_stomach', 's_acidity', 's_appetite'],
      recommendations: [
        'A fibre supplement such as isabgol or lactulose for short-term relief',
        'An antacid such as pantoprazole if there is accompanying reflux',
        'See a doctor if constipation lasts beyond 3 weeks or comes with blood in the stool',
        'Blood in the stool, unexplained weight loss or a change in bowel habit needs urgent review',
      ],
      selfCare: [
        'Aim for 25–30 g of fibre a day — vegetables, fruit, whole grains and legumes',
        'Drink at least 2 litres of water daily',
        'Walk or exercise for 20–30 minutes a day',
        'Go to the toilet at the same time each morning, ideally after breakfast',
        'Cut back on excess tea, coffee and oily food',
      ],
      overTheCounterCategories: ['Digestive'],
      seeDoctorWithinHours: 168,
    ),
    Condition(
      id: 'c_peripheral_neuropathy',
      name: 'Possible Peripheral Neuropathy / Nerve Compression',
      description:
          'Tingling, numbness or burning in the hands and feet. This can follow '
          'prolonged pressure on a nerve, or point to vitamin B12 or sugar control issues.',
      symptomIds: ['s_numbness', 's_jointpain', 's_musclepain', 's_backpain'],
      recommendations: [
        'Get vitamin B12, HbA1c and thyroid tests checked — these are the usual causes',
        'A doctor may prescribe pregabalin or a vitamin B12 supplement once confirmed',
        'Report numbness around the groin or weakness in the legs immediately',
        'Untreated neuropathy can cause permanent nerve damage, so do not delay the tests',
      ],
      selfCare: [
        'Avoid sitting cross-legged or in one position for long stretches',
        'Stretch gently and take short walking breaks every hour',
        'Wear loose footwear and avoid tight laces',
        'Keep your spine neutral when working at a desk or laptop',
        'Limit alcohol, which aggravates nerve damage',
      ],
      overTheCounterCategories: ['Vitamins', 'Pain Relief'],
      seeDoctorWithinHours: 72,
    ),
  ];

  /// Danger-sign combinations — if any of these are present, the user must be
  /// told to seek emergency care regardless of the score.
  static const Map<String, List<String>> redFlagRules = {
    's_chestpain': [
      'Chest pain with breathlessness or sweating can be a heart attack. Call emergency services immediately.',
    ],
    's_breathless': [
      'Severe breathlessness or breathlessness at rest needs emergency evaluation.',
    ],
    's_numbness': [
      'Sudden numbness or weakness on one side of the body is a stroke warning sign. Call an ambulance now.',
    ],
    's_vomiting': [
      'Repeated vomiting with blood or black vomit is a medical emergency.',
    ],
    's_headache2': [
      'Severe sinus pain with high fever may indicate a serious sinus infection.',
    ],
  };

  /// Age / gender inputs.
  static const List<String> ageBands = [
    'Child (0–12 years)',
    'Teen (13–17 years)',
    'Adult (18–44 years)',
    'Middle age (45–59 years)',
    'Senior (60+ years)',
  ];

  static const List<String> genders = ['Female', 'Male', 'Other'];

  /// Flow steps shown as a progress header.
  static const List<String> stepTitles = [
    'About you',
    'Your symptoms',
    'Symptom details',
    'Analysis',
  ];
}
