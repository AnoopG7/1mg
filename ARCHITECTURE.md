# Architecture — 1mg Health Store & Medicine Info

Flutter 3.47 · `provider` · Firebase Auth · Cloud Firestore · Web-first.

**1. Decisions that shape everything**  2. Layers  3. State  4. Data flow  5. Engines
6. Data  7. Pages & flows  8. Testing  9. Production roadmap  10. Run & limitations

---

## 1. Decisions

| Decision | Consequence |
|---|---|
| Dependencies flow one way: `features → providers → core/services → models+data` | A screen can never reach into another screen; a provider can never import a widget. All 26 screens are independently testable. |
| Business logic lives only in pure engines (no widgets, no storage, no clock) | Pricing/triage/range/interaction maths is unit-testable in isolation (39 tests) and is exactly what a real API replaces. |
| `widget → provider → engine → persist → notifyListeners → rebuild` | No state mutated in `build()`, no widget-to-widget state passing, nothing to keep in sync manually. |
| One owner per fact | The payable is only ever computed by `PricingEngine`; the cart badge only reads `CartProvider.itemCount`; the reminder badge only reads `ReminderProvider.totalActive`. Two owners of one number is how the six reported bugs happened. |
| Local cache plus Firebase service facades | Local writes update the UI immediately, then mirror authenticated user data to Firestore. Platform and network details stay out of widgets. |

No code generation (`build_runner`/Freezed) is required. Firebase Web initialization, auth and
Firestore access are isolated in core services and providers.

---

## 2. Layers

```
features/     26 screens, 11 areas. Layout, navigation, local UI state only.
              No arithmetic, no persistence, no business rules.
providers/    9 ChangeNotifiers. The only mutable state. Calls an engine, persists, notifies.
core/services/ 5 engines + StorageService + FirestoreService. Rules and data access.
models/ + data/  10 aggregate model files and seeded catalogue data. JSON in / JSON out.
shared/widgets/ Design system: AppCard, AppButton, SectionHeader, EmptyState, NoticeBanner,
              SearchField, RatingStars, Shimmer, ProBadge, VerifiedBadge, PregnancyBadge,
              DiscountBadge, NormalRangeBar, PriceComparison, BrandMark.
```

| Layer | May import | Must never import |
|---|---|---|
| `features/` | `providers/`, `core/`, `models/`, `shared/` | another `features/*/` folder |
| `providers/` | `core/`, `models/` | `features/`, `shared/` |
| `core/services/` | `models/`, `data/` | `features/`, `providers/`, `shared/` |
| `models/` | Flutter `material` only, for `IconData`/`Color` | `features/`, `providers/`, `core/` |

Firebase services are consumed by providers, never by feature widgets. Catalogue data is seeded
after authentication into Firestore collections; user data is mirrored under
`users/{uid}/data/`.

### Target production topology (feature-first)

Layering by type is fine at 26 screens but degrades as features multiply — a cart change touches
three top-level folders. The production target, and the mechanical mapping to it:

```
lib/
├── core/{di, router, error}   # service locator, named routes with typed args, Failure union
├── features/<area>/
│   ├── data/        # e.g. CartRepository interface + REST impl
│   ├── domain/      # entities + use-cases (AddToCart, RemoveLine, ClearCart)
│   └── presentation/# screen + view-model
└── shared/{domain, engines, widgets}
```

The dependency rules above already guarantee this is possible: engines take data and return data
(injectable), providers take `StorageService` by constructor (mockable), and no screen imports
another screen. The remaining enabler is DI — today a `MultiProvider` block in `main.dart`.

---

## 3. State

| Provider | Owns | Persisted under | Sole owner of |
|---|---|---|---|
| `CartProvider` | lines, quantities | `cart_items` | `itemCount` (cart badge); qty 0 removes the line; quantities merge per id |
| `OrderProvider` | history, status, ETA | `orders` | unique ids; `advance()` walks placed→packed→shipped→delivered; newest first |
| `ReminderProvider` | reminders, dose times, adherence | `reminders` | `totalActive` (nav badge — reminders, **not** dose times); only active reminders are due |
| `ProProvider` | Pro plan, refill subscription, referral wallet | `pro_*`, `sub_*`, `referrals`, `referral_credits` | Pro ⇒ +5%; subscription ⇒ +10% medicines only; a referral credits ₹100 once; credits never over-consumed |
| `SavedProvider` | saved medicines, saved articles, addresses | `saved_*`, `addresses_v2` | `toggle*` is idempotent; a default address always exists |
| `LabProvider` | bookings, slot, result values | `lab_bookings`, `lab_slot_time` | slots come from `defaultSlotTimes`; values interpreted by `NormalRangeService` |
| `ProfileProvider` | name, email, phone, city | `user_profile` + Firebase account | `initials`, derived — never stored |
| `SymptomProvider` | checker state machine | — (session) | the step can only advance; `restart()` clears every answer |
| `InteractionProvider` | selected medicines, alerts | — (session) | alerts recomputed on every change; ≥2 medicines to compare |

Rebuild scoping: the shell badges use `context.select` on a single value, so a cart quantity
change does not rebuild the reminders tab. Screens `watch` only the provider they render.

---

## 4. Data flow

```
onTap/onPressed → Provider method → Engine (pure rules) → local cache → Firestore mirror → notifyListeners → rebuild
```

Worked example, checkout: `CartScreen` calls `OrderProvider.place(items, address, breakdown)`; the
provider builds an `Order` with a `uuid`, appends, persists, notifies. The `PriceBreakdown` was
produced by `PricingEngine` and is passed in rather than re-derived, so the number shown is the
number stored. The cart badge drops to zero and the Orders tab shows the new order because both
are derived — no manual refresh.

Widgets never write a provider field, never compute a total, never touch `StorageService`.

---

## 5. Engines

| Engine | Input → Output | Used by | Cov. |
|---|---|---|---|
| `PricingEngine` | cart lines + entitlement flags → `PriceBreakdown` | cart, checkout, lab booking, pro | 84% |
| `SymptomEngine` | symptoms + follow-ups + age/gender → ranked conditions, match %, triage | symptom checker | 62% |
| `InteractionEngine` | medicines + substance types → severity-graded alerts | interaction checker, checkout banner | 40% |
| `NormalRangeService` | parameters with values → status counts + advice | lab report | 57% |
| `PillRecognizer` | image bytes or medicine id → ranked `PillMatch`es | pill scan | 89% |
| `StorageService` | key + codec → local value + remote mirror | every persisted provider | 79% |
| `FirestoreService` | catalogue seed + authenticated CRUD mirror | auth bootstrap and `StorageService` | — |

Rules worth knowing because they are non-obvious and test-locked:

- **Pricing** — order is MRP → store discount → refill 10% (**medicines only**, never lab tests)
  → Pro 5% (both) → referral credit → delivery. Credits are clamped so `payable` is never negative.
  Delivery fee is basket-size only (free above ₹399); Pro's express promise lives in
  `Order.estimatedDelivery` (24h vs 72h), not in the fee.
- **Triage** — weighted overlap with specificity weighting (a rare symptom outranks a common one);
  duration/severity and symptom-specific follow-ups re-weight the score; red-flag overrides force
  the triage level up regardless of score. Match probability is clamped to 8–96%.
- **Lab ranges** — a zero-width range (normal low *is* zero) must not flag its own value as
  critical, and a value exactly half a span out *is* critical while one just outside is only
  high/low. Pattern advice fires too (e.g. diabetic HbA1c ⇒ "see a doctor").
- **Pill recognition** — MD5 of the image bytes → 31-bit seed → deterministic per-medicine score →
  ranking, behind a 1.8 s delay that drives the scanning UI. Same photo ⇒ same result, which is
  what makes it read as recognition rather than a shuffle. `recogniseSample(id)` pins a known
  medicine to the top for the sample buttons.

---

## 6. Data

```
Medicine ──< Ingredient · SideEffect · DrugInteraction
         ──1 PregnancyCategory (A|B|C|D|X) · StorageInfo
CartItem ──> Order ──< CartItem              line-level price snapshot
LabTest  ──< LabRange (value, normalLow/High, unit, status maths)
LabBundle ──< LabTest                        offerPrice vs summed MRP = price comparison
Article  ──1 Doctor (name, speciality, verified)
Reminder ──< DoseTime + adherence entries
Condition ──< Symptom (symptomIds) ── SymptomQuestion (follow-ups)
ProPlan · RefillSubscription · Referral → wallet · Profile · Address · PriceBreakdown
```

Every model has `fromJson`/`toJson`; providers own codec construction;
`readList(key, fromJson)` / `writeList(key, items, toJson)` are the only list accessors, so adding
a field to one model cannot break an unrelated key.

`addresses_v2` is versioned deliberately: the seed address changed, and a version bump makes a
changed default win over an already-persisted copy. `StorageService.resetForTest()` gives each
test a clean in-memory store, so persistence is exercised, not stubbed.

`FirestoreService` writes the complete catalogue in an idempotent batch after authentication.
The seeded collections are `medicines`, `lab_tests`, `lab_bundles`, `articles`, `symptoms`,
`questions`, `conditions` and `meta`. The `meta` collection documents demographics, red-flag
rules, pricing, plans, app capabilities and the field-level schema. Every provider write also
mirrors its serialized value to `users/{uid}/data/{key}`; local storage remains the immediate
read/write cache for the Web UI.

---

## 7. Pages & flows

### 7.1 Screens (26 across 11 areas)

| # | Screen | File | Purpose | Entered from |
|---|---|---|---|---|
| 1 | `HomeScreen` | `home/home_screen.dart` | Search, location, quick actions, strips: Shop by concern / Top medicines / Health packages / Doctor-verified articles / Saved by you | launch (tab 1) |
| 2 | `MedicineListScreen` | `medicines/medicine_list_screen.dart` | Catalogue: search, category chips, sort, pregnancy filter | home, saved, quick actions |
| 3 | `MedicineDetailScreen` | `medicines/medicine_detail_screen.dart` | Composition, uses, side effects, interactions, pregnancy, storage, add to cart / save / remind | home, catalogue, saved, scan, triage |
| 4 | `CartScreen` | `cart/cart_screen.dart` | Lines, steppers, per-line remove, clear cart, price summary, interaction warning | tab 4, order actions |
| 5 | `CheckoutScreen` | `cart/checkout_screen.dart` | Address, payment, savings breakdown, mock payment, place order | cart |
| 6 | `OrderSuccessScreen` | `cart/order_success_screen.dart` | Order id, amount saved, delivery estimate | checkout |
| 7 | `OrdersScreen` | `profile/orders_screen.dart` | History with status timeline | tab 2, profile |
| 8 | `OrderDetailScreen` | `profile/order_detail_screen.dart` | Invoice-style lines, address, status | orders |
| 9 | `RemindersScreen` | `reminders/reminders_screen.dart` | List, adherence, daily progress, delete + undo, scan entry | tab 3 |
| 10 | `AddReminderScreen` | `reminders/add_reminder_screen.dart` | Medicine, dose, times, weekdays, duration, note | reminders, detail, scan |
| 11 | `PillScanScreen` | `reminders/pill_scan_screen.dart` | Photo/sample → ranked matches → open or remind | home, reminders |
| 12 | `SymptomCheckerScreen` | `symptom_checker/symptom_checker_screen.dart` | 4-step questionnaire | home, result restart |
| 13 | `SymptomResultScreen` | `symptom_checker/symptom_result_screen.dart` | Ranked conditions, triage, advice, recommendations | checker step 4 |
| 14 | `LabsScreen` | `labs/labs_screen.dart` | Tests + bundle offers with price comparison | home |
| 15 | `LabTestDetailScreen` | `labs/lab_test_detail_screen.dart` | Parameters, ranges, preparation, book | labs, home bundles |
| 16 | `LabBookingScreen` | `labs/lab_booking_screen.dart` | 3 steps: date, slot, address | test detail |
| 17 | `LabResultScreen` | `labs/lab_result_screen.dart` | Range bars, status chips, summary, advice | booking (replace) or sample report |
| 18 | `ArticlesScreen` | `articles/articles_screen.dart` | Category-filtered feed | home, saved |
| 19 | `ArticleDetailScreen` | `articles/article_detail_screen.dart` | Full article, doctor card, save, share | articles, home, saved |
| 20 | `InteractionCheckerScreen` | `interactions/interaction_checker_screen.dart` | Medicines + substances → graded alerts | home, medicine detail |
| 21 | `ProScreen` | `pro/pro_screen.dart` | ₹499/yr, purchase, referral code, wallet, share | home, cart, profile |
| 22 | `ProSuccessScreen` | `pro/pro_success_screen.dart` | Purchase confirmation, resets stack | Pro purchase |
| 23 | `ProfileScreen` | `profile/profile_screen.dart` | Header, orders/reminders/labs/addresses, settings, data management | tab 5 |
| 24 | `ProfileEditScreen` | `profile/profile_edit_screen.dart` | Name, email, phone, city | profile |
| 25 | `SavedMedicinesScreen` | `profile/saved_medicines_screen.dart` | Wishlist with unsave | profile, home strip |
| 26 | `SavedArticlesScreen` | `profile/saved_articles_screen.dart` | Saved reading with unsave | profile |

### 7.2 Navigation

Five tabs in an `IndexedStack` (per-tab state and scroll preserved); everything else is pushed.

```
AppShell ── tabs ──▶ Home · Orders · Reminders · Cart · Profile

Home ─┬─▶ MedicineList ─▶ MedicineDetail ─┬─▶ Cart ─▶ Checkout ─▶ OrderSuccess
      ├─▶ MedicineDetail (carousel)        ├─▶ AddReminder(medicine)
      ├─▶ Labs ─▶ LabTestDetail ─▶ LabBooking ─(replace)─▶ LabResult
      ├─▶ Articles ─▶ ArticleDetail
      ├─▶ SymptomChecker ─(step 4)─▶ SymptomResult ─┬─▶ MedicineDetail
      │                          ▲                  └─▶ restart checker
      ├─▶ InteractionChecker
      ├─▶ PillScan ─┬─▶ MedicineDetail
      │             └─▶ AddReminder(medicine)
      └─▶ Pro ─▶ ProSuccess ─▶ AppShell (stack reset)

Orders(tab) ─▶ OrderDetail        Cart(tab) ─▶ Checkout · Pro
Reminders(tab) ─▶ AddReminder · PillScan
Profile(tab) ─┬─▶ ProfileEdit · SavedMedicines ─▶ MedicineDetail
              ├─▶ SavedArticles ─▶ ArticleDetail
              └─▶ Orders ─▶ OrderDetail · Pro · settings/support dialogs
```

### 7.3 Flows

**Order a medicine**
Home → catalogue/search → detail → add to cart → cart (quantity, remove, clear, interaction
warning) → checkout (address, payment, savings breakdown) → mock payment resolves → success screen
with order id → cart empty → orders tab shows *placed* → order detail, status timeline advances.

**Symptom check**
Home quick action → age/gender (+temperature) → multi-select symptoms by body category →
duration + severity + relevant follow-ups (fever/cough/stomach/breathing) → analysing → ranked
conditions with match %, triage, advice → recommended medicines deep-link into the catalogue →
"check again" clears all answers.

**Lab test**
Labs → test or bundle (MRP vs offer vs savings) → detail: parameters, ranges, **preparation** →
book → date → slot → address + price summary → confirm → report with per-parameter range bars,
status chips, summary, advice. A "sample report" can also be opened from a detail without booking.

**Reminder**
Reminders → add (medicine, dose, multiple times, weekdays, duration, note) → active → badge counts
reminders not doses → mark doses taken/skipped → adherence ring and log update → swipe or delete
with Undo. Persisted, so it survives a reload.

**Pill scan**
Scan pill → photo or sample → analysing (~1.8 s) → ranked matches with confidence → open the
medicine, or turn a match straight into a reminder.

**Interaction check**
Pick 2+ medicines → toggle Food / Alcohol / Medicine / Other → graded alerts with consequences;
the same engine puts a warning in the cart before payment.

**Pro & referral**
Pro screen → ₹499 purchase → success (stack reset) → +5% everywhere; monthly refills → +10% on
medicines; share the referral code → ₹100 credit → applied as a clamped offset at checkout.

**Profile**
Header → edit name/email/phone/city (name and email required) → persists and updates the header;
saved medicines / saved articles with unsave; Pro and Monthly refill plan → Pro screen; settings
gear → clear cart, delete all reminders; Help & support and Privacy & terms → a "feature
incoming" notice rather than a dead tap.

### 7.4 Requirement → implementation

| Requirement | Screens | Engine / provider |
|---|---|---|
| Medicine information: composition, uses, side effects | 2, 3 | `Medicine`, `Ingredient`, `SideEffect` |
| Symptom checker with assessment + recommendations | 12, 13 | `SymptomEngine`, `SymptomProvider` |
| Reminder with pill image recognition | 9, 10, 11 | `PillRecognizer`, `ReminderProvider` |
| Articles with doctor verification badge | 18, 19 | `Article`, `Doctor`, `VerifiedBadge` |
| Lab booking with preparation instructions | 14, 15, 16 | `LabTest.preparation`, `LabProvider` |
| Normal range indicators | 17 | `NormalRangeService`, `NormalRangeBar` |
| Interaction checker: food, alcohol, other medicines | 20 | `InteractionEngine`, `InteractionProvider` |
| Pregnancy safety rating A–X | 2, 3 | `PregnancyCategory`, `PregnancyBadge` |
| Storage instructions | 3 | `StorageInfo` |
| Lab bundles with price comparison | 14, 15 | `LabBundle`, `BundleCard`, `PriceComparison` |
| Pro badge, discount, priority delivery | 1, 4, 21, 22 | `ProPlan`, `ProBadge`, `PricingEngine` |
| Referral credit balance with share | 21 | `ProProvider`, `share_plus` |

---

## 8. Testing

Three layers, no mocks of the app's own logic. `StorageService.resetForTest()` gives each test a
clean in-memory store, so persistence is exercised rather than stubbed, and every reported bug has
a named regression test so a reintroduced bug fails by name.

| Suite | Tests | Proves |
|---|---|---|
| `engines_test.dart` | 39 | Pricing reconciliation, discount stacking, delivery threshold, credit clamping, triage ranking and red-flag escalation, range edge cases, catalogue integrity |
| `providers_test.dart` | 38 | Cart merge/remove/qty-0, persistence round-trips, unique order ids, status advance, Pro activate/cancel/expiry, referral credited once, reminder due-date logic |
| `flows_test.dart` | 11 | Checkout → order → detail, back button pushed vs tab-hosted, reminder delete + undo + reload |
| `bugfix_regression_test.dart` | 5 | One guard per reported bug + "no dead taps" across the profile page |
| `cart_flows_test.dart` | 3 | Steppers, per-line remove, clear cart |
| `widget_test.dart` | 3 | Boot, tabs, empty states |
| `screens_sweep_test.dart` | 1 | All 26 screens render at 390×844 without overflow |

**Measured line coverage: 70.1% of 5,491 lines in `lib/`** (3,850 hit), `flutter test --coverage`.

| Area | | Area | | Engine / provider | |
|---|---|---|---|---|---|
| `features/articles` | 94% | `features/labs` | 75% | `OrderProvider` | 98% |
| `features/shell` | 95% | `providers` | 69% | `LabProvider` | 96% |
| `shared` | 89% | `features/reminders` | 56% | `ProProvider` | 92% |
| `features/home` | 86% | `features/interactions` | 66% | `CartProvider` | 89% |
| `data` | 82% | `features/pro` | 31% | `PricingEngine` | 84% |
| `features/medicines` | 80% | `features/symptom_checker` | 22% | `NormalRangeService` | 57% |
| `features/cart` | 79% | `main.dart` | 38% | `SymptomEngine` | 62% |
| `core/services` | 66% | | | `InteractionEngine` | 40% |

The uncovered code is the symptom-checker result UI, the Pro purchase/referral UI, the pill
scanner's sample branches and the saved-list empty states — places the tests bypass. The engines
those screens call are better covered, so the residual risk is UI wiring, not a wrong number.
Four cheapest additions: drive the full symptom flow, cover `InteractionEngine`'s severity table
exhaustively, assert the Pro purchase → wallet credit path, cover saved-list unsave/empty. Those
take the total past 85%.

---

## 9. Enhancement roadmap

| Gap | Seam that already exists | Work |
|---|---|---|
| Catalogue administration | `FirestoreService`, `lib/data/` | Add an authenticated admin screen for reviewing and editing seeded catalogue records |
| Expanded account sync | `StorageService`, Firestore user data | Add remote hydration on sign-in so a new browser can restore saved data and preferences |
| Reminders are in-app only | `ReminderProvider`; `flutter_local_notifications` already in pubspec | Schedule/cancel per `DoseTime`, platform-guarded so web is a no-op, request permission on first use |
| Pill recognition simulated | `PillRecognizer.recognise(bytes)` | TFLite classifier behind the same signature and ranking contract |
| Triage rule-based | `SymptomEngine.analyse()` | Call a model API, keep the local engine as offline fallback |
| Mock payments | checkout payment sheet | Add a payment SDK behind the same sheet when a real commerce deployment is required |
| Manual DI | `main.dart` MultiProvider | `core/di` service locator; optionally move to feature-first modules (§2) |
| No accessibility annotations | colour+label patterns already in place | `Semantics` on badges, status chips, range bars — nothing annotated today |
| No CI | `analyze` + `test` are clean | Pipeline: format check, analyze, test, coverage, `flutter build web` |

---

## 10. Run & limitations

```bash
flutter pub get
flutter run -d chrome                        # or -d web-server --web-port 8080
flutter test
flutter build web
```

The Web app uses Firebase Email/Password Authentication. After sign-in, the catalogue is seeded
to Firestore and user actions are mirrored beneath the authenticated user's document. Local cache
data keeps the interface responsive during short network interruptions.

| Item | Reality |
|---|---|
| Content | Real structure, seeded demo data — 20 medicines, 10 tests, 6 bundles, 8 articles, 17 conditions, plus Firestore schema metadata |
| Pricing, triage, ranges, interactions | Real logic, pure engines, 39 unit tests |
| Cart, orders, reminders, Pro, referrals, profile | Real CRUD flows with local persistence and authenticated Firestore mirroring |
| Payments | Simulated — no payment SDK |
| Pill recognition | Simulated — MD5 of the image bytes, not a classifier |
| Symptom "AI" | Rule-based, not a trained model |
| OS notifications | Dependency declared, not wired |
| Accessibility | Colour+label patterns, but no `Semantics` annotations |
