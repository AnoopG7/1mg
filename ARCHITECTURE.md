# ARCHITECTURE — 1mg Health Store & Medicine Info

> Flutter college project. Medicine information, symptom checker, lab test booking,
> health articles, medicine ordering, AI health assistant, medicine reminders.

---

## 1. Tech Stack

| Layer | Choice | Reason |
|---|---|---|
| Framework | Flutter 3.47 (Dart 3.13) | Cross-platform, single codebase |
| State management | `provider` + `ChangeNotifier` | Simple, college-friendly, no codegen |
| Typography | `google_fonts` | Consistent look on Android + iOS |
| Local DB | `shared_preferences` (JSON blobs) | Cart, reminders, Pro plan, credits persist offline |
| Charts | `fl_chart` | Lab normal-range indicator bars |
| Imaging | `image_picker` | Pill image recognition |
| Sharing | `share_plus` | Referral code sharing |
| Notifications | `flutter_local_notifications` | Medicine reminder alerts |
| Misc | `intl`, `uuid` | Currency/date formatting, order IDs |

**No backend / no API keys.** All data ships as realistic mock data in
`lib/data/mock_data.dart`, so the app runs fully offline and always demos well.

---

## 2. Layered Architecture

```
┌──────────────────────────────────────────────────────────────┐
│  PRESENTATION          lib/features/*/screens + widgets      │
│  Widgets, navigation, no business logic                     │
├──────────────────────────────────────────────────────────────┤
│  STATE                 lib/providers/                        │
│  ChangeNotifiers: cart, orders, reminders, pro, symptom,    │
│  interaction, saved, labs                                   │
├──────────────────────────────────────────────────────────────┤
│  DOMAIN / LOGIC        lib/core/  (services + engines)       │
│  SymptomEngine, InteractionEngine, PillRecognizer,          │
│  PricingEngine, Formatters                                 │
├──────────────────────────────────────────────────────────────┤
│  DATA                  lib/models/ + lib/data/              │
│  Plain Dart models, MockData repositories                    │
└──────────────────────────────────────────────────────────────┘
```

**Rule of dependency:** `presentation → state → domain ← data`. Models are pure
Dart (no Flutter imports) so they are unit-testable and portable to a real API later.

---

## 3. Directory Structure

```
lib/
├── main.dart                      # App entry, MultiProvider, routing
│
├── core/
│   ├── theme/
│   │   ├── app_theme.dart         # Material 3 theme, colors, text styles
│   │   ├── app_colors.dart        # Brand palette + semantic colors
│   │   └── app_spacing.dart       # 4pt spacing scale + radii
│   ├── services/
│   │   ├── symptom_engine.dart    # AI-style triage & condition matching
│   │   ├── interaction_engine.dart # food / alcohol / drug interaction matrix
│   │   ├── pill_recognizer.dart    # pill image → medicine matching
│   │   ├── pricing_engine.dart     # 1mg Pro, subscription, referral math
│   │   └── normal_range.dart      # lab value vs range evaluation
│   └── utils/
│       ├── formatters.dart        # ₹ currency, dates, relative time
│       └── result.dart            # Result<T> type for service returns
│
├── models/                        # Pure Dart data classes
│   ├── medicine.dart              # composition, uses, side effects,
│   │                              # interactions, pregnancy, storage, OTC flags
│   ├── drug_interaction.dart      # type + severity + evidence note
│   ├── pregnancy_category.dart    # A/B/C/D/X with colours + descriptions
│   ├── storage_info.dart          # temperature, light, humidity
│   ├── symptom.dart               # symptom question + options
│   ├── condition.dart             # possible condition + probability
│   ├── assessment.dart            # triage level + score + recommendations
│   ├── article.dart               # doctor-verified health article
│   ├── doctor.dart                # verifying doctor profile
│   ├── lab_test.dart              # single test, price, prep instructions
│   ├── lab_range.dart             # parameter + normal range + unit
│   ├── lab_result.dart            # value vs range → indicator
│   ├── lab_bundle.dart            # package: tests, MRP, offer, savings
│   ├── reminder.dart              # medicine reminder schedule
│   ├── pill_recognition.dart      # recognition result + confidence
│   ├── cart_item.dart
│   ├── order.dart
│   ├── address.dart
│   └── subscription.dart          # 1mg Pro / monthly refill plan
│
├── data/
│   ├── mock_data.dart             # ⭐ all seed data lives here
│   └── repositories/
│       ├── medicine_repository.dart
│       ├── article_repository.dart
│       ├── lab_repository.dart
│       └── symptom_repository.dart
│
├── providers/
│   ├── cart_provider.dart
│   ├── order_provider.dart
│   ├── reminder_provider.dart
│   ├── pro_provider.dart          # 1mg Pro + referral credits
│   ├── symptom_provider.dart      # drives the checker flow
│   ├── interaction_provider.dart  # interaction checker state
│   ├── saved_provider.dart        # saved medicines / articles
│   └── lab_provider.dart
│
├── shared/
│   ├── widgets/
│   │   ├── app_button.dart
│   │   ├── app_card.dart
│   │   ├── section_header.dart
│   │   ├── rating_stars.dart
│   │   ├── verified_badge.dart    # 👨‍⚕️ doctor verification
│   │   ├── pro_badge.dart         # ⭐ 1mg Pro
│   │   ├── discount_badge.dart
│   │   ├── normal_range_bar.dart  # fl_chart indicator
│   │   ├── pregnancy_badge.dart
│   │   ├── empty_state.dart
│   │   ├── loading_shimmer.dart
│   │   └── search_field.dart
│   └── extensions/
│       └── context_extensions.dart # theme, colors, text shortcuts
│
└── features/
    ├── shell/
    │   └── app_shell.dart         # BottomNavigationBar, IndexedStack
    ├── home/
    │   └── home_screen.dart
    ├── medicines/
    │   ├── medicine_list_screen.dart
    │   ├── medicine_detail_screen.dart
    │   └── widgets/ (composition, uses, side_effects,
    │                 interactions, pregnancy, storage sections)
    ├── interactions/
    │   └── interaction_checker_screen.dart
    ├── symptom_checker/
    │   ├── symptom_checker_screen.dart
    │   ├── symptom_result_screen.dart
    │   └── widgets/question_card.dart
    ├── reminders/
    │   ├── reminders_screen.dart
    │   ├── add_reminder_screen.dart
    │   └── pill_scan_screen.dart   # image → recognition
    ├── articles/
    │   ├── articles_screen.dart
    │   └── article_detail_screen.dart
    ├── labs/
    │   ├── labs_screen.dart
    │   ├── lab_test_detail_screen.dart
    │   ├── lab_booking_screen.dart
    │   ├── lab_result_screen.dart
    │   └── widgets/ bundle_card.dart, price_comparison.dart
    ├── cart/
    │   ├── cart_screen.dart
    │   └── checkout_screen.dart
    ├── pro/
    │   ├── pro_screen.dart         # ₹499/yr, benefits, referral wallet
    │   └── pro_success_screen.dart
    └── profile/
        ├── profile_screen.dart
        ├── orders_screen.dart
        └── order_detail_screen.dart
```

---

## 4. Navigation Map

```
AppShell (5 tabs, IndexedStack preserves state)
├── Home ─────────► Medicine Detail ─► Cart ─► Checkout ─► Order Success
│     │            └─► Add to Reminder
│     ├─► Medicines (search/filter) ─► Medicine Detail
│     ├─► Symptom Checker (flow) ─► Result ─► Recommended meds
│     ├─► Articles ─► Article Detail
│     ├─► Labs ─► Test Detail ─► Booking ─► Results
│     └─► Pro / Referral
├── Orders ────────► Order Detail
├── Reminders ─────► Add Reminder ─► Pill Scanner
├── Cart ──────────► Checkout
└── Profile ───────► Pro, Saved, Addresses
```

5 tabs: **Home · Orders · Reminders · Cart · Profile**

---

## 5. Domain Engines (the "AI" part)

### 5.1 `SymptomEngine` — `lib/core/services/symptom_engine.dart`
1. Reads age band, gender, body temperature, symptom set + severity.
2. Scores each `Condition` in `MockData.conditions` by weighted keyword overlap
   with selected symptoms + vital red-flag rules.
3. Returns `Assessment`:
   - **Triage level** — `emergency` / `urgent` / `consultDoctor` / `selfCare`
   - **Match confidence %** per condition
   - **Red flags** (e.g. chest pain + breathlessness → call ambulance)
   - **Recommendations** — self-care steps + suggested medicine categories
4. Emergency red-flag rules short-circuit everything else.

### 5.2 `InteractionEngine` — `lib/core/services/interaction_engine.dart`
Cross-references the selected medicines pairwise and merges each medicine's
predefined `DrugInteraction` list with:
- **food** interactions (e.g. Warfarin + leafy greens)
- **alcohol** interactions
- **other medicine** interactions
Returns list of `InteractionAlert` with severity `mild / moderate / severe`
and a plain-English explanation.

### 5.3 `PillRecognizer` — `lib/core/services/pill_recognizer.dart`
Simulated recognition: hashes the picked image bytes + a short analysis delay,
then returns ranked `PillMatch` list (medicine, strength, shape, colour,
confidence %) with a "no match found" fallback path. Realistic for a demo,
swappable with a TFLite / Vision API model later.

### 5.4 `PricingEngine` — `lib/core/services/pricing_engine.dart`
Single source of truth for the pricing strategy:

| Rule | Implementation |
|---|---|
| Lab bundles up to 50% off | Bundle stores `mrp` + `offerPrice`; savings computed |
| Medicine subscription 10% off | `Subscription.monthlyRefill` applies 10% on refills |
| 1mg Pro ₹499/year → extra 5% off | `ProProvider.isPro` → 5% off + free priority delivery |
| Referral ₹100 credit per successful referral | `ProProvider.referralCredits` wallet, applied at checkout |

Stack order at checkout: `mrp → bundle offer → subscription 10% → Pro 5% → referral credits → delivery`.

---

## 6. Data Model Highlights

### `Medicine`
```dart
name, brandName, genericName, strength, form, category
composition: List<Ingredient{ name, strengthPerDose }>
uses: List<String>
sideEffects: List<SideEffect{ name, frequency, severity }>
interactions: List<DrugInteraction{ type(food|alcohol|drug), with, severity, note }>
pregnancyCategory: PregnancyCategory  // A B C D X
lactationSafe: bool
storage: StorageInfo                     // temperature, light, humidity
rx: bool, otc: bool, habitForming: bool
price, mrp, rating, reviewCount
```

### `PregnancyCategory` (requirement: A, B, C, D, X)
| Cat | Meaning | Colour |
|---|---|---|
| A | Well established safe | green |
| B | Animal studies show no risk | teal |
| C | Risk not ruled out, benefit may outweigh | amber |
| D | Positive evidence of human risk | orange |
| X | Contraindicated | red |

### `LabResult` + `NormalRangeBar`
Each parameter stores `value`, `normalLow`, `normalHigh`, `unit`.
A `fl_chart` bar shows the value position, green band for the normal range,
and a status chip: **Low / Normal / High / Critical**.

---

## 7. Feature → Requirement Traceability

| # | Problem-statement requirement | Implementation |
|---|---|---|
| 1 | Medicine information: composition, uses, side effects, interactions | `features/medicines` — list, search, category filter, detail tabs |
| 2 | Symptom checker with AI assessment + recommendations | `features/symptom_checker` + `SymptomEngine` |
| 3 | Medicine reminder with pill image recognition | `features/reminders` + `PillRecognizer` + `image_picker` |
| 4 | Health articles with doctor verification badge | `features/articles` + `VerifiedBadge` |
| 5 | Lab test booking with preparation instructions | `features/labs` → `LabBookingScreen` |
| 6 | Normal range indicators for lab results | `NormalRangeBar` (fl_chart) in `LabResultScreen` |
| 7 | Interaction checker: food, alcohol, other medicines | `features/interactions` + `InteractionEngine` |
| 8 | Pregnancy safety rating (A, B, C, D, X) | `PregnancyBadge` in `MedicineDetail` + pregnancy filter |
| 9 | Storage instructions | `StorageInfoSection` in `MedicineDetail` |
| 10 | Lab bundles with price comparison | `BundleCard` + `PriceComparison` (MRP vs offer vs savings) |
| 11 | 1mg Pro badge, discount, priority delivery | `ProBadge` across app + `features/pro` |
| 12 | Referral credit balance with share option | `ProScreen` wallet + `share_plus` |

---

## 8. State Management Detail

All providers are `ChangeNotifier`s registered in `main.dart` via `MultiProvider`.

| Provider | Responsibility | Persisted |
|---|---|---|
| `CartProvider` | add/remove/qty, live totals via `PricingEngine` | ✅ |
| `OrderProvider` | place order, order history, status timeline | ✅ |
| `ReminderProvider` | CRUD reminders, adherence log, daily stats | ✅ |
| `ProProvider` | Pro plan state, referral code + credits, expiry | ✅ |
| `SymptomProvider` | multi-step checker state machine | ❌ |
| `InteractionProvider` | selected medicines, computed alerts | ❌ |
| `SavedProvider` | saved medicines, articles, addresses | ✅ |
| `LabProvider` | bookings, slot selection, result interpretation | ✅ |

Persistence layer: a tiny `StorageService` wrapping `SharedPreferences`
(`getJson` / `setJson`) so providers stay storage-agnostic.

---

## 9. How to Extend to a Real Backend

1. Keep every model as-is (they are plain Dart, JSON-serialisable).
2. Add `lib/data/remote/*_api.dart` using `http`.
3. In each repository, swap `MockData.x` for `(await api.fetchX())` behind the
   same method signature — providers and UI need zero changes.
4. `SymptomEngine` inputs/outputs are already structured; POST them to a
   symptom-checker endpoint to replace the local rule engine.
5. `PillRecognizer.recognise()` is a single async seam — replace the body with
   a TFLite model call or Google Lens call.

---

## 10. Running

```bash
flutter pub get
flutter run                 # Android / iOS / connected device
flutter analyze             # static analysis
flutter test                # unit tests
```
