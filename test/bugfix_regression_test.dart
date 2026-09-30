import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:one_mg_health/core/services/storage_service.dart';
import 'package:one_mg_health/data/mock_medicines.dart';
import 'package:one_mg_health/features/cart/checkout_screen.dart';
import 'package:one_mg_health/features/cart/order_success_screen.dart';
import 'package:one_mg_health/features/medicines/medicine_list_screen.dart';
import 'package:one_mg_health/features/profile/profile_screen.dart';
import 'package:one_mg_health/features/reminders/reminders_screen.dart';
import 'package:one_mg_health/features/shell/app_shell.dart';
import 'package:one_mg_health/models/cart_item.dart';
import 'package:one_mg_health/providers/cart_provider.dart';
import 'package:one_mg_health/providers/interaction_provider.dart';
import 'package:one_mg_health/providers/lab_provider.dart';
import 'package:one_mg_health/providers/order_provider.dart';
import 'package:one_mg_health/providers/profile_provider.dart';
import 'package:one_mg_health/providers/pro_provider.dart';
import 'package:one_mg_health/providers/reminder_provider.dart';
import 'package:one_mg_health/providers/saved_provider.dart';
import 'package:one_mg_health/providers/symptom_provider.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

Future<
  ({
    CartProvider cart,
    OrderProvider orders,
    ReminderProvider reminders,
    ProProvider pro,
    SavedProvider saved,
    ProfileProvider profile,
  })
>
pumpApp(WidgetTester tester, Widget home) async {
  tester.view.physicalSize = const Size(390, 844);
  tester.view.devicePixelRatio = 1.0;
  addTearDown(tester.view.reset);
  SharedPreferences.setMockInitialValues({});
  StorageService.resetForTest();
  final storage = await StorageService.init();

  final cart = CartProvider(storage);
  final orders = OrderProvider(storage);
  final reminders = ReminderProvider(storage);
  final pro = ProProvider(storage);
  final saved = SavedProvider(storage);
  final profile = ProfileProvider(storage);

  await tester.pumpWidget(
    MultiProvider(
      providers: [
        ChangeNotifierProvider.value(value: cart),
        ChangeNotifierProvider.value(value: orders),
        ChangeNotifierProvider.value(value: reminders),
        ChangeNotifierProvider.value(value: pro),
        ChangeNotifierProvider.value(value: saved),
        ChangeNotifierProvider.value(value: profile),
        ChangeNotifierProvider(create: (_) => LabProvider(storage)),
        ChangeNotifierProvider(create: (_) => SymptomProvider()),
        ChangeNotifierProvider(create: (_) => InteractionProvider()),
      ],
      child: MaterialApp(home: home),
    ),
  );
  await tester.pumpAndSettle();
  return (
    cart: cart,
    orders: orders,
    reminders: reminders,
    pro: pro,
    saved: saved,
    profile: profile,
  );
}

CartItem item() => const CartItem(
  id: 'm1',
  title: 'Paracetamol 500',
  subtitle: '10 tablets',
  kind: CartItemKind.medicine,
  unitPrice: 25,
  mrp: 30,
  quantity: 1,
  medicineId: 'm1',
);

void main() {
  group('Bug 1: checkout must complete instantly, not sit on placing', () {
    testWidgets('mock payment completes, clears cart, creates the order', (
      tester,
    ) async {
      final p = await pumpApp(tester, const CheckoutScreen());
      p.cart.add(item(), quantity: 2);
      await tester.pumpAndSettle();

      final button = find.textContaining('Place order');
      await tester.tap(button);
      await tester.pumpAndSettle();

      expect(find.byType(OrderSuccessScreen), findsOneWidget);
      expect(
        p.cart.isEmpty,
        isTrue,
        reason: 'cart must be cleared once the order is placed',
      );
      expect(p.orders.count, 1, reason: 'the order must be recorded');
    });
  });

  group('Bug 6: wishlist bookmark toggles on the medicine card', () {
    testWidgets('tapping the bookmark saves, tapping again unsaves', (
      tester,
    ) async {
      final p = await pumpApp(tester, const MedicineListScreen());
      final first = MockMedicines.all.first;

      expect(p.saved.isMedicineSaved(first.id), isFalse);
      expect(
        find.byIcon(Icons.bookmark_border_rounded),
        findsWidgets,
        reason: 'precondition: unsaved bookmarks shown',
      );

      await tester.tap(find.byIcon(Icons.bookmark_border_rounded).first);
      await tester.pumpAndSettle();

      expect(
        p.saved.medicineIds,
        contains(first.id),
        reason: 'tapping the bookmark must save the medicine',
      );

      await tester.tap(find.byIcon(Icons.bookmark_rounded).first);
      await tester.pumpAndSettle();

      expect(
        p.saved.isMedicineSaved(first.id),
        isFalse,
        reason: 'tapping an already saved bookmark must remove it',
      );
    });
  });

  group('Bug 3: the reminders badge counts reminders, not dose times', () {
    testWidgets('one reminder with two daily doses shows badge 1', (
      tester,
    ) async {
      final p = await pumpApp(tester, const AppShell());
      // 1 reminder, 2 dose times per day.
      p.reminders.add(
        medicineId: 'm1',
        medicineName: 'Paracetamol',
        dosage: '500mg',
        times: const ['09:00', '21:00'],
        durationDays: 5,
      );
      await tester.pumpAndSettle();

      final badge = find.descendant(
        of: find.byType(NavigationBar),
        matching: find.text('1'),
      );
      expect(badge, findsOneWidget, reason: 'badge must read 1, not 2');
      expect(find.text('2'), findsNothing);
    });
  });

  group('Bug 4: identify-pill button only lives on the homepage', () {
    testWidgets('the reminders screen has no scan action', (tester) async {
      await pumpApp(tester, const RemindersScreen());
      expect(
        find.byTooltip('Scan a pill'),
        findsNothing,
        reason: 'the pill-scan button must not be on the reminders screen',
      );
    });
  });

  group('Profile page links', () {
    testWidgets('every settings row does something (no dead taps)', (
      tester,
    ) async {
      final p = await pumpApp(tester, const ProfileScreen());

      // Personal details -> editable profile page.
      await tester.tap(find.text('Personal details'));
      await tester.pumpAndSettle();
      expect(find.text('Full name'), findsOneWidget);
      await tester.enterText(
        find.widgetWithText(TextField, 'Anoop Gupta'),
        'Test User',
      );
      await tester.tap(find.text('Save changes'));
      await tester.pumpAndSettle();
      expect(p.profile.profile.name, 'Test User');

      // Header and the "Personal details" row both reflect the saved name.
      expect(find.text('Test User'), findsWidgets);

      // Saved medicines / saved articles navigate to their own pages.
      await tester.tap(find.text('Saved medicines'));
      await tester.pumpAndSettle();
      expect(find.text('No saved medicines'), findsOneWidget);
      await tester.pageBack();
      await tester.pumpAndSettle();

      await tester.tap(find.text('Saved articles'));
      await tester.pumpAndSettle();
      expect(find.text('No saved articles'), findsOneWidget);
      await tester.pageBack();
      await tester.pumpAndSettle();

      // Help & support and Privacy & terms show a banner, not a dead tap.
      await tester.tap(find.text('Help & support'));
      await tester.pumpAndSettle();
      expect(find.text('Feature incoming'), findsOneWidget);
      await tester.tap(find.text('Got it'));
      await tester.pumpAndSettle();

      await tester.tap(find.text('Privacy & terms'));
      await tester.pumpAndSettle();
      expect(find.text('Feature incoming'), findsOneWidget);
    });
  });
}
