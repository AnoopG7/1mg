
import '../models/article.dart';

class MockArticles {
  const MockArticles._();

  static const Doctor drSharma = Doctor(
    name: 'Dr. Anjali Sharma',
    speciality: 'Consultant Physician',
    qualification: 'MBBS, MD (General Medicine)',
    experienceYears: 12,
    verified: true,
  );

  static const Doctor drMehta = Doctor(
    name: 'Dr. Rohan Mehta',
    speciality: 'Consultant Cardiologist',
    qualification: 'MBBS, DM (Cardiology), FACC',
    experienceYears: 16,
    verified: true,
  );

  static const Doctor drIyer = Doctor(
    name: 'Dr. Kavya Iyer',
    speciality: 'Endocrinologist & Diabetologist',
    qualification: 'MBBS, MD, DNB (Endocrinology)',
    experienceYears: 10,
    verified: true,
  );

  static const Doctor drKapoor = Doctor(
    name: 'Dr. Sanjay Kapoor',
    speciality: 'Clinical Nutritionist',
    qualification: 'MD (Nutrition), MSc Dietetics',
    experienceYears: 14,
    verified: true,
  );

  static List<Article> get all => [
    Article(
      id: 'a001',
      title: 'Early Signs of Type 2 Diabetes You Should Never Ignore',
      summary:
          'Type 2 diabetes can stay silent for years. These early warning signs '
          'often appear months before a diagnosis.',
      category: 'Diabetes',
      doctor: drIyer,
      readMinutes: 6,
      publishedOn: DateTime(2026, 8, 24),
      views: 48200,
      likes: 1240,
      tags: ['Diabetes', 'HbA1c', 'Insulin', 'Pre-diabetes'],
      accentColorValue: 0xFFE8A317,
      body: [
        'Type 2 diabetes rarely arrives suddenly. Long before a doctor confirms '
            'a diagnosis, your body has usually been sending warning signals for '
            'months or even years. Learning to spot them early can prevent '
            'years of complications.',
        '## The 5 early warning signs',
        '1. Constant fatigue — feeling tired even after a full night\'s sleep is '
            'one of the earliest signs. When cells cannot use glucose efficiently, '
            'the body falls back on fat for energy, which is far less efficient.',
        '2. Frequent hunger — because glucose stays in the bloodstream instead of '
            'entering cells, your brain keeps signalling hunger even shortly after '
            'a full meal.',
        '3. Frequent urination and excessive thirst — the kidneys work harder to '
            'filter excess sugar, which pulls water out with it, leading to '
            'dehydration and constant thirst.',
        '4. Slow-healing cuts and infections — high blood sugar impairs white blood '
            'cell function, so even small wounds take much longer to heal.',
        '5. Tingling or numbness in the hands and feet — nerve damage caused by '
            'persistent high glucose, often the earliest neurological sign.',
        '## What should you do?',
        'Get an HbA1c test if you notice two or more of these signs, or if you '
            'have a family history, are overweight, or are above 35 years old. '
            'HbA1c reflects your average blood sugar over the past three months '
            'and is the single most reliable screening test.',
        '## The good news',
        'Pre-diabetes is almost always reversible. Studies consistently show that '
            'losing just 5–7% of your body weight through a balanced diet and '
            '150 minutes of activity per week can reduce progression to type 2 '
            'diabetes by 58%.',
      ],
    ),
    Article(
      id: 'a002',
      title: 'Cholesterol Numbers Explained: What Matters Most',
      summary:
          'LDL, HDL, triglycerides — which number should you worry about, and '
          'what is a healthy range?',
      category: 'Heart Health',
      doctor: drMehta,
      readMinutes: 7,
      publishedOn: DateTime(2026, 8, 18),
      views: 39600,
      likes: 980,
      tags: ['Cholesterol', 'LDL', 'HDL', 'Lipids'],
      accentColorValue: 0xFFDC2F2F,
      body: [
        'Ask ten people what cholesterol is and you will get ten different '
            'answers. Cholesterol is not simply "bad" or "good" — it is an '
            'essential building block your body uses to make hormones and cell '
            'membranes. The real question is which type and how much.',
        '## LDL — the "bad" cholesterol',
        'Low-density lipoprotein carries cholesterol from your liver to your '
            'arteries. When there is too much, it sticks to artery walls and '
            'builds up as plaque. A healthy LDL is below 100 mg/dL. For people '
            'with existing heart disease or diabetes, your doctor may aim for '
            'below 70 mg/dL.',
        '## HDL — the "good" cholesterol',
        'High-density lipoprotein acts like a cleanup crew, carrying cholesterol '
            'back to the liver. Above 60 mg/dL is protective. But here is the '
            'myth buster: exercise reliably raises HDL far more effectively than '
            'dietary changes or alcohol.',
        '## Triglycerides — the overlooked one',
        'Triglycerides above 150 mg/dL are considered high. They are strongly '
            'linked to obesity, diabetes and heavy alcohol use. Levels above 500 '
            'mg/dL significantly raise the risk of pancreatitis.',
        '## Lifestyle changes that actually work',
        'Replace saturated fats with unsaturated ones — cooking with mustard, '
            'olive or groundnut oil instead of butter and ghee. Add soluble '
            'fibre from oats, beans and psyllium husk. Do at least 150 minutes of '
            'aerobic activity weekly. These three changes together can lower LDL '
            'by 25–30%, often as much as a low-dose statin.',
      ],
    ),
    Article(
      id: 'a003',
      title: 'Vitamin D Deficiency: Why India Is Facing an Epidemic',
      summary:
          'Despite abundant sunlight, a large majority of Indians are low in '
          'vitamin D. Here is why, and how to fix it.',
      category: 'Nutrition',
      doctor: drKapoor,
      readMinutes: 5,
      publishedOn: DateTime(2026, 8, 11),
      views: 52400,
      likes: 1620,
      tags: ['Vitamin D', 'Calcium', 'Bone health', 'Sunlight'],
      accentColorValue: 0xFFE8A317,
      body: [
        'India has roughly 300 sunny days a year, yet studies suggest 70–90% of '
            'Indians are deficient in vitamin D. The reason is not a lack of '
            'sunshine but a combination of lifestyle, pollution and skin tone.',
        '## Why deficiency is so common here',
        'Melanin in darker skin reduces cutaneous vitamin D synthesis — people '
            'with darker skin need 2–3 times more sun exposure to produce the same '
            'amount. This is compounded by staying indoors, spending long hours in '
            'vehicles with tinted glass, pollution blocking UVB rays, and wearing '
            'covered clothing for cultural reasons.',
        '## Symptoms people miss',
        'Fatigue that sleep does not fix, bone and joint pain, muscle weakness, '
            'mood swings, frequent infections and slow wound healing. Many people '
            'attribute all of these to stress and never get tested.',
        '## The correct levels',
        'Deficiency is below 30 ng/mL. The optimal range is 30 to 100 ng/mL, and '
            'levels above 150 ng/mL risk calcium build-up in the kidneys.',
        '## Correcting deficiency safely',
        'Take vitamin D3 supplements with a doctor\'s guidance — 60,000 IU weekly '
            'for 8 weeks is a common correction dose, followed by maintenance. '
            'Always take it with a fat-containing meal because vitamin D is '
            'fat-soluble and needs dietary fat for absorption. Ten minutes of '
            'mid-morning sunlight on exposed skin, most days, helps maintain levels.',
      ],
    ),
    Article(
      id: 'a004',
      title: 'Recognising Stress: When Worry Becomes a Health Problem',
      summary:
          'Chronic stress silently damages your heart, immunity and digestion. '
          'Learn to spot the warning signs early.',
      category: 'Mental Health',
      doctor: drSharma,
      readMinutes: 6,
      publishedOn: DateTime(2026, 8, 5),
      views: 31500,
      likes: 890,
      tags: ['Stress', 'Anxiety', 'Sleep', 'Mental health'],
      accentColorValue: 0xFF7B4DFF,
      body: [
        'Stress is your body\'s alarm system. Short-term stress is useful — it '
            'sharpens focus and helps you perform. But when the alarm stays on '
            'for weeks, it stops protecting you and starts damaging you.',
        '## What chronic stress does to your body',
        'It keeps cortisol elevated, which raises blood sugar and blood pressure. '
            'It suppresses immune function, making you catch colds more often. '
            'It disrupts sleep architecture, so even eight hours in bed leave you '
            'unrefreshed. Over months it increases visceral fat and raises '
            'inflammation, which accelerates heart disease.',
        '## Signs that have gone beyond normal',
        'Difficulty falling or staying asleep even when tired, a persistent sense '
            'of dread, irritability over small things, loss of interest in things '
            'you used to enjoy, and physical symptoms like chest tightness or '
            'frequent headaches with no clear cause.',
        '## What genuinely helps',
        'Deep breathing — 4 seconds in, 7 seconds hold, 8 seconds out, for 3 '
            'minutes — activates the parasympathetic nervous system directly. '
            'Regular aerobic exercise, even 20 minutes of brisk walking, burns '
            'cortisol. Keeping a consistent sleep and wake time matters more than '
            'total hours. Limiting news and social media reduces background stress '
            'load considerably.',
        '## When to see a professional',
        'If anxiety or low mood persists for more than two weeks, interferes with '
            'work or studies, or comes with sleep changes, panic attacks or loss '
            'of interest in everything, speak to a doctor. Therapy works, and '
            'medications for anxiety are highly effective when needed.',
      ],
    ),
    Article(
      id: 'a005',
      title: 'The Acid Reflux Guide: Triggers, Tests and Treatment',
      summary:
          'Burning acidity is common but not normal. Understand what triggers it '
          'and when you need a doctor.',
      category: 'Common Ailments',
      doctor: drSharma,
      readMinutes: 5,
      publishedOn: DateTime(2026, 7, 28),
      views: 27800,
      likes: 640,
      tags: ['Acidity', 'GERD', 'Digestion', 'PPI'],
      accentColorValue: 0xFFF2721C,
      body: [
        'Occasional acidity after a heavy meal is normal. Heartburn happening '
            'twice a week, waking you at night, or needing antacids constantly '
            'suggests GERD — a condition where stomach acid regularly flows back '
            'into the food pipe.',
        '## Common triggers',
        'Overeating and lying down soon after meals, carbonated drinks, coffee, '
            'chocolate, mint, very spicy food, tomato and citrus, fatty fried '
            'foods, smoking, and alcohol. Notice the pattern: most triggers either '
            'relax the muscle between stomach and oesophagus, or add acid.',
        '## Simple lifestyle fixes that work',
        'Eat smaller meals. Do not lie down for at least 2–3 hours after eating. '
            'Raise the head end of your bed by 10–15 cm. Avoid tight belts around '
            'the waist. If you are overweight, losing weight reduces reflux '
            'noticeably. Keep a food and symptom diary for two weeks to identify '
            'your personal triggers.',
        '## When to see a doctor',
        'See a doctor if you have difficulty swallowing, unintended weight loss, '
            'vomiting of blood, black stools, or chest pain that could be confused '
            'with a heart attack. An upper GI endoscopy may be recommended.',
      ],
    ),
    Article(
      id: 'a006',
      title: 'A Beginner\'s Guide to Strength Training at Home',
      summary:
          'No gym membership needed. Six simple exercises you can do at home to '
          'build strength and bone density.',
      category: 'Fitness',
      doctor: drKapoor,
      readMinutes: 8,
      publishedOn: DateTime(2026, 7, 20),
      views: 44200,
      likes: 1750,
      tags: ['Exercise', 'Strength training', 'Home workout', 'Bone health'],
      accentColorValue: 0xFF12A150,
      body: [
        'Strength training is not about bulking up — for people over 30 it is '
            'about preserving muscle and bone, improving posture, and keeping '
            'independence for decades.',
        '## Why resistance training matters more with age',
        'From your mid-30s, adults lose roughly 3–8% of muscle mass per decade, '
            'and the rate accelerates after 60. Bone density also declines. '
            'Resistance loading is the only form of exercise that reliably '
            'counteracts both, and it improves insulin sensitivity and blood '
            'pressure too.',
        '## Six exercises to start with',
        '1. Squats — body weight, 3 sets of 12. Sit back as if onto a chair, '
            'knees tracking over toes.',
        '2. Push-ups — incline against a wall or counter to start, 3 sets of 8–12.',
        '3. Bent-over rows — with a water bottle or backpack, 3 sets of 12. '
            'Targets the upper back and fixes posture.',
        '4. Glute bridges — lie on your back, lift hips, 3 sets of 15. Excellent '
            'for lower back pain.',
        '5. Wall planks — 3 sets of 20–30 seconds each, building core strength '
            'safely.',
        '6. Overhead press — with a light weight, 3 sets of 10. Strengthens the '
            'shoulders.',
        '## How often and how much',
        'Two to three sessions per week on non-consecutive days, 8–12 reps per '
            'set, with 60–90 seconds of rest. Progress gradually by adding reps '
            'before adding weight. Stop if you feel sharp pain — muscle soreness '
            'two days later is normal and expected.',
      ],
    ),
    Article(
      id: 'a007',
      title: 'PMS vs Endometriosis: How to Tell the Difference',
      summary:
          'Severe period pain is often dismissed as normal. Here is when it '
          'deserves a closer look.',
      category: 'Women\'s Health',
      doctor: drIyer,
      readMinutes: 6,
      publishedOn: DateTime(2026, 7, 14),
      views: 22300,
      likes: 720,
      tags: ['Endometriosis', 'PMS', 'Period pain', 'Women\'s health'],
      accentColorValue: 0xFFDC2F2F,
      body: [
        'Premenstrual syndrome can cause mood swings, bloating and breast '
            'tenderness in the week before your period. Endometriosis is a '
            'different thing entirely — tissue similar to the uterine lining grows '
            'outside the uterus, causing severe, often progressively worsening '
            'pain.',
        '## Key differences',
        'PMS symptoms are predictable, appearing in a consistent pattern in the '
            'luteal phase and resolving when bleeding starts. Endometriosis pain '
            'is severe, often starts 2–3 days before bleeding, lasts through the '
            'flow and can persist for days after it ends. Pain that gets steadily '
            'worse cycle after cycle is a major red flag.',
        '## Other signs that suggest endometriosis',
        'Deep pain during intercourse, painful bowel movements or urination during '
            'your period, heavy or prolonged bleeding, infertility, and fatigue. '
            'It often runs in families.',
        '## Diagnosis and treatment',
        'There is no simple blood test — diagnosis is clinical, and often confirmed '
            'with a laparoscopy. Treatment ranges from NSAIDs and hormonal '
            'medicines like combined oral contraceptives to GnRH agonists in '
            'severe cases, and surgery for refractory pain. Because it often takes '
            'years to be diagnosed, if your period pain stops you from doing normal '
            'activities, speak up.',
      ],
    ),
    Article(
      id: 'a008',
      title: 'Hypertension: The Silent Killer and How to Outsmart It',
      summary:
          'High blood pressure has no symptoms until it causes damage. Here is '
          'how to measure, monitor and control it.',
      category: 'Heart Health',
      doctor: drMehta,
      readMinutes: 7,
      publishedOn: DateTime(2026, 7, 8),
      views: 35800,
      likes: 1100,
      tags: ['Blood pressure', 'Hypertension', 'ARB', 'Salt'],
      accentColorValue: 0xFF2C6BED,
      body: [
        'High blood pressure is often called the silent killer because it causes '
            'no symptoms. By the time someone feels unwell, the damage to blood '
            'vessels, kidneys, eyes and heart may already be significant.',
        '## Numbers that matter',
        'Normal is below 120/80 mmHg. Stage 1 hypertension is 130–139 systolic or '
            '80–89 diastolic. Stage 2 is 140/90 or above. A single high reading '
            'is not a diagnosis — you need repeated measurements, ideally on '
            'different days.',
        '## Measuring correctly at home',
        'Sit quietly for five minutes first. Feet flat on the floor, back '
            'supported, arm resting at heart level. Use a validated upper-arm '
            'cuff — wrist devices are far less accurate. Take two readings one '
            'minute apart, in the morning and evening, and record them.',
        '## The lifestyle levers that genuinely move the number',
        'Cutting salt from roughly 10 g a day to under 5 g lowers systolic '
            'pressure by 5–6 mmHg — this is the single most effective dietary '
            'change. The DASH pattern of fruits, vegetables and low-fat dairy adds '
            'a further 8–14 mmHg. Losing 5% of body weight gives about 5–7 mmHg. '
            'Brisk walking 30 minutes daily, most days, works. Limiting alcohol to '
            'one drink for women and two for men is advised.',
        '## About medicines',
        'If lifestyle changes are not enough, medicines are not optional — they '
            'reduce stroke risk substantially. ARBs such as telmisartan are '
            'first-line. Never stop a blood pressure medicine on your own, and be '
            'careful with NSAIDs like ibuprofen, which raise blood pressure and '
            'harm kidney function.',
      ],
    ),
  ];

  /// The article with this id, or null.
  static Article? byId(String id) {
    for (final a in all) {
      if (a.id == id) return a;
    }
    return null;
  }
}
