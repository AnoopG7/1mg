# 1mg Health Store & Medicine Info

A Flutter application for medicine information, health articles, lab test booking and medicine
ordering, with a symptom checker, medicine reminders with pill recognition, an interaction
checker, and the full 1mg pricing strategy (Pro, monthly refill, referral credits).

It runs **entirely offline on mock data** — no backend, no API keys — so it boots instantly and
behaves identically on every machine, which makes it safe to demo, submit and test.

| | |
|---|---|
| Flutter | 3.47.1 stable · Dart |
| State | `provider` (`ChangeNotifier`) · 9 providers |
| Domain | 5 pure engines (pricing, triage, interactions, lab ranges, pill recognition) |
| UI | 26 screens across 11 feature areas |
| Data | 20 medicines · 10 lab tests · 6 bundles · 8 articles · 17 conditions |
| Tests | 100 automated tests · `flutter analyze` clean |
| Architecture | [ARCHITECTURE.md](ARCHITECTURE.md) |
| Requirement coverage | 24 problem-statement clauses → 20 fully built, 4 built with a documented simulation (§6) |

---

## 1. The problem statement

> **122. 1mg Health Store & Medicine Info** — *Industry: Health Information & Pharmacy*
>
> 1mg requires a trusted Flutter application for medicine information, health articles, lab test
> booking, and medicine ordering with AI-powered health assistant for symptom checking and
> medicine reminders.
>
> **Technical Implementation**
> - Medicine information database with composition, uses, side effects
> - Symptom checker with AI-powered preliminary assessment
> - Medicine reminder with pill image recognition
> - Health articles with doctor-verified content
> - Lab test booking with preparation instructions and normal ranges
>
> **Product Building**
> - Show medicine interactions (with food, alcohol, other medicines), pregnancy safety rating, and
>   storage instructions.
>
> **Pricing Strategy**
> - Lab test bundles: Up to 50% off on complete health packages
> - Medicine subscription: 10% off on monthly refills
> - 1mg Pro: ₹499/year for additional 5% off and priority delivery
> - Referral: ₹100 credit per successful referral
>
> **Product Features to be Visible**
> - Medicine information: composition, uses, side effects, interactions
> - Symptom checker with AI assessment and recommendations
> - Medicine reminder with pill image recognition
> - Health articles with doctor verification badge
> - Lab test booking with preparation instructions
> - Normal range indicators for lab results
> - Medicine interaction checker with food, alcohol, other medicines
> - Pregnancy safety rating with category (A, B, C, D, X)
> - Storage instructions for different medicines
> - Lab test bundles with price comparison
> - 1mg Pro badge with discount and priority delivery
> - Referral credit balance with share option

### 1.1 What it actually asks for, in plain English

The statement is written as a feature list, so it is worth reading as four separate demands:

1. **Be a trustworthy medicine reference.** Not a shop with a search bar — a database. For every
   medicine: what is *in* it (composition), what it is *for* (uses), what can go *wrong*
   (side effects), what it must not be combined with (interactions), whether it is safe in
   pregnancy, and how to store it. Trust is the product; the storefront is secondary.
2. **Turn a vague feeling into a next step.** "I have a fever and a cough" is useless input. The
   symptom checker must ask structured follow-ups, rank plausible conditions with a confidence,
   say how urgent it is, and recommend what to do — including what to take.
3. **Close the loop on treatment.** Prescriptions fail when doses are missed, and users cannot
   read a pill they are holding. Hence reminders (with the ability to identify an unknown pill
   from a photo) and an interaction checker that covers the three things people actually get
   wrong: food, alcohol, and their other medicines.
4. **Be a working commerce app with a real pricing strategy.** Lab booking (with preparation
   instructions, because a fasting test collected at the wrong time is worthless) and result
   interpretation (normal ranges, so a number means something). The pricing rules are specific
   and must be *visible and arithmetically correct*: bundles up to 50% off, 10% off refills,
   Pro at ₹499/year for +5% and priority delivery, ₹100 referral credit, and they must stack
   without ever producing a wrong total.

Two things the statement implies that are easy to miss: "doctor-verified" and "trusted" mean
**provenance must be visible in the UI** (badges, authors, preparation notes), and
"preliminary assessment" means the symptom checker must present itself as guidance, not
diagnosis. Both are built in.

---

## 2. The solution

One app, five subsystems, all reachable from a five-tab shell.

| Subsystem | What it does | Where it lives |
|---|---|---|
| **Medicine intelligence** | Catalogue with live search, category and pregnancy filters; per-medicine composition, uses, side effects graded by severity, interactions, pregnancy category, storage instructions, wishlist | `features/medicines/`, `features/profile/saved_medicines_screen.dart` |
| **Lab tests** | Tests and bundles with MRP-vs-offer comparison, preparation instructions, date + slot booking, and result interpretation with normal-range bars and plain-English advice | `features/labs/` |
| **Symptom checker** | 4-step questionnaire → ranked conditions with match %, triage level, self-care advice, recommended medicines | `features/symptom_checker/` |
| **Reminders** | Multiple daily dose times, weekday and duration selection, adherence log, daily progress, delete with undo, badge counting reminders (not doses) | `features/reminders/` |
| **Pill recognition** | Photo or sample pill → ranked matches with confidence, straight into a detail page or a new reminder | `core/services/pill_recognizer.dart`, `features/reminders/pill_scan_screen.dart` |
| **Interaction checker** | Select medicines + food/alcohol/other substances → severity-graded alerts; the same engine warns inside the cart before payment | `features/interactions/` |
| **Commerce** | Cart with steppers and per-line remove, address, mock payment, order history with a status timeline, and a single pricing engine that owns every discount | `features/cart/`, `features/profile/orders_screen.dart` |
| **Pro & referrals** | ₹499/year plan (+5%, priority delivery), monthly refill subscription (+10% on medicines), referral code with share sheet and ₹100 credits | `features/pro/` |
| **Profile** | Editable personal details, saved medicines and articles, addresses, orders, reminders, working settings actions | `features/profile/` |

### 2.1 The pricing engine (the part worth reviewing)

One function owns the money, so no screen can invent a total:

```
MRP  →  store discount  →  monthly refill 10% (medicines only)
     →  1mg Pro +5%      →  referral credit  →  delivery (free above ₹399 / free on Pro)
     →  payable
```

Guaranteed by tests: MRP minus store discount always reconciles with the payable; the refill
discount never touches lab tests; Pro and refill stack to 15%; credits are clamped so the payable
is never negative and the wallet is never over-consumed; an empty cart is all zeroes.

### 2.2 The safety layer

Because this is health content, safety is a feature, not a disclaimer footer: pregnancy category
with letter + description (never colour alone), severity chips with labels, "not a diagnosis"
framing on the triage result, and educational-use notices on medicine and article content.

---

## 3. Feature walkthrough (what a user can actually do)

| Area | Flow |
|---|---|
| **Home** | Search, location chip, pill scan, Pro banner, 4 quick actions (symptom checker, interaction checker, lab tests, articles), then the strips: Shop by concern · Top medicines · Health packages (up to 50% off) · Doctor-verified articles · Saved by you (only when non-empty) |
| **Order a medicine** | Browse/search → detail → add to cart → cart → checkout (address, payment, savings breakdown) → instant order success → order history with status timeline |
| **Understand a medicine** | Composition with strength and role, uses, side effects by frequency, interactions, pregnancy rating, storage instructions, Rx flag, ratings, manufacturer |
| **Diagnose a feeling** | Age/gender → symptoms → duration/severity/follow-ups → ranked conditions with match %, triage, advice, recommended medicines → one tap to buy |
| **Never miss a dose** | Add reminder (medicine, dose, multiple times, weekdays, duration, note) → mark taken/skipped → adherence ring → delete with undo |
| **Identify a pill** | Pick a photo or a sample pill → ranked recognition with confidence → open the medicine or create a reminder |
| **Book a lab test** | Test or bundle → parameters and reference ranges → preparation instructions → date + slot + address → confirm → report with normal-range bars, status chips and advice |
| **Check interactions** | Select 2+ medicines → toggle food/alcohol/medicine/other → severity-graded alerts; the cart shows the same warning before payment |
| **Save money** | Join Pro (₹499/yr) or monthly refills (10%), share a referral code, spend ₹100 credits at checkout |
| **Manage the account** | Edit name/email/phone/city, review saved medicines and articles, addresses, orders, reminders, clear cart, delete all reminders |

Every screen, every entry point, and all eight complete flows are documented in
[ARCHITECTURE.md §7](ARCHITECTURE.md).

---

## 4. Running it

```bash
flutter pub get

flutter run -d chrome                                   # fastest loop
flutter run -d web-server --web-port 8080               # headless, open http://127.0.0.1:8080
flutter run                                             # Android (needs JDK 17) / iOS
```

Quality gates:

```bash
flutter analyze        # No issues found!
flutter test           # All tests passed!  (100 tests, 7 suites)
flutter build web      # release bundle
```

There is no login and no server to start. First launch seeds the mock catalogue, a default
delivery address and the profile (Anoop Gupta, +91 1234567890, Mumbai) into local storage.

---

## 5. How it is built

Four layers, one direction of dependency: `features → providers → core/services → models+data`.
All business rules are pure Dart functions in five engines (pricing, triage, interactions, lab
ranges, pill matching), so they are unit-tested without widgets and are the exact seams a real
backend or model replaces. State lives only in 9 `ChangeNotifier`s; persistence is
`shared_preferences` behind one facade; the design system is four shared widget files.

Full detail — layering rules, the target feature-first production topology, provider invariants,
unidirectional data flow, engine contracts, data model, design system, edge-case handling,
performance, accessibility, security, testing architecture and the backend migration plan — is in
[ARCHITECTURE.md](ARCHITECTURE.md).

**Layout at a glance**

| Directory | Contents |
|---|---|
| `lib/features/` | 11 feature areas, 26 screens |
| `lib/providers/` | 9 ChangeNotifiers (cart, orders, reminders, pro, saved, labs, profile, symptom, interaction) |
| `lib/core/services/` | 5 domain engines + `StorageService` |
| `lib/core/theme/` | Material 3 theme, colour palette, spacing scale |
| `lib/models/` | 10 aggregate model files, JSON in / out |
| `lib/data/` | 4 mock repositories |
| `lib/shared/widgets/` | design system: cards, buttons, badges, range bars |
| `test/` | 7 suites, 100 tests |

---

## 6. Testing

| Suite | Tests | Focus |
|---|---|---|
| `engines_test.dart` | 39 | Pricing maths, triage ranking, range edge cases, interaction rules, catalogue integrity |
| `providers_test.dart` | 38 | State machines and persistence round-trips |
| `flows_test.dart` | 11 | Checkout → order → detail, back navigation, reminder deletion |
| `bugfix_regression_test.dart` | 5 | One named guard per reported bug, plus "no dead taps" on the profile page |
| `cart_flows_test.dart` | 3 | Steppers, per-line remove, clear cart |
| `widget_test.dart` | 3 | Boot, tabs, empty states |
| `screens_sweep_test.dart` | 1 | All 26 screens render at 390×844 with no overflow |

**Measured coverage: 70.1% of 5,491 instrumented lines in `lib/`** (3,850 hit), with the engines
that own money and triage covered 60–98% and the weakest areas being the symptom-checker result
UI (22%) and the Pro/referral UI (31%). The full breakdown, including what is *not* covered and
the four cheapest tests to add, is in [ARCHITECTURE.md §8](ARCHITECTURE.md).

```bash
flutter test
flutter test test/engines_test.dart      # one suite
flutter test --coverage                  # coverage/lcov.info
```

Each of the six bugs that were reported has a named regression test, so a reintroduced bug fails
by name rather than silently.

---

## 7. What is real and what is simulated

Stated plainly, because it is the first question an examiner asks.

| Area | Reality |
|---|---|
| Medicine / lab / article content | **Real structure, mock content** — 20 medicines, 10 tests, 6 bundles, 8 articles. Model and rendering are production-shaped; the dataset is demo data. |
| Pricing, triage, lab ranges, interaction rules | **Real logic.** Pure engines with 39 unit tests, including the edge cases. |
| Cart, orders, reminders, Pro, referrals, profile | **Real and persisted** per device via `shared_preferences`. |
| Payments | **Simulated** — the mock payment sheet completes instantly; no payment SDK. |
| Pill recognition | **Simulated** — image bytes are hashed into a deterministic seed that ranks the catalogue. Same photo, same result; a TFLite model drops into the same interface. |
| Symptom "AI" | **Rule-based** — weighted scoring with red-flag overrides, not a trained model. `SymptomEngine.analyse()` is the swap point. |
| OS notifications | **Not wired** — `flutter_local_notifications` is a declared dependency but reminders are in-app only today. |

The three remaining production tasks, in priority order: wire OS notifications for reminders,
replace the simulated pill recognition and triage with real services, and move persistence to a
backend behind the existing `StorageService` seam. All three are specified in
[ARCHITECTURE.md §9](ARCHITECTURE.md).

---

## 8. Safety

Educational project. Medicine information, lab reference ranges, pregnancy categories and
symptom guidance are demo content and are not medical advice; the app says so where it matters.
Nothing here should be used to make a real clinical decision.
