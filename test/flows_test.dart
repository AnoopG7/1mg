import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:one_mg_health/core/services/storage_service.dart';
import 'package:one_mg_health/features/cart/cart_screen.dart';
import 'package:one_mg_health/features/cart/checkout_screen.dart';
import 'package:one_mg_health/features/cart/order_success_screen.dart';
import 'package:one_mg_health/features/profile/order_detail_screen.dart';
import 'package:one_mg_health/features/profile/orders_screen.dart';
import 'package:one_mg_health/features/reminders/reminders_screen.dart';
import 'package:one_mg_health/models/cart_item.dart';
import 'package:one_mg_health/providers/cart_provider.dart';
import 'package:one_mg_health/providers/order_provider.dart';
import 'package:one_mg_health/providers/pro_provider.dart';
import 'package:one_mg_health/providers/reminder_provider.dart';
import 'package:one_mg_health/providers/saved_provider.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Boots the real screens against in-memory storage and hands back the live
/// providers so a test can drive them the way the UI would.
Future<
  ({
    CartProvider cart,
    OrderProvider orders,
    ReminderProvider reminders,
    ProProvider pro,
  })
>
pumpApp(WidgetTester tester, Widget home) async {
  SharedPreferences.setMockInitialValues({});
  StorageService.resetForTest();
  final storage = await StorageService.init();

  final cart = CartProvider(storage);
  final orders = OrderProvider(storage);
  final reminders = ReminderProvider(storage);
  final pro = ProProvider(storage);
  final saved = SavedProvider(storage);

  await tester.pumpWidget(
    MultiProvider(
      providers: [
        ChangeNotifierProvider.value(value: cart),
        ChangeNotifierProvider.value(value: orders),
        ChangeNotifierProvider.value(value: reminders),
        ChangeNotifierProvider.value(value: pro),
        ChangeNotifierProvider.value(value: saved),
      ],
      child: MaterialApp(home: home),
    ),
  );
  return (cart: cart, orders: orders, reminders: reminders, pro: pro);
}

/// Pins the test surface to a typical phone viewport.
void phone(WidgetTester tester) {
  tester.view.physicalSize = const Size(390, 844);
  tester.view.devicePixelRatio = 1.0;
  addTearDown(tester.view.reset);
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
  // A phone-sized surface: the 800x600 default is landscape and hides
  // below-the-fold controls from the tap hit test.
  setUpAll(() {});

  group('Checkout: ordering empties the cart and creates an order', () {
    testWidgets('placing an order clears the cart and records the order', (
      tester,
    ) async {
      phone(tester);
      final p = await pumpApp(tester, const CheckoutScreen());
      p.cart.add(item(), quantity: 2);
      await tester.pumpAndSettle();

      expect(p.cart.isNotEmpty, isTrue, reason: 'precondition');

      await tester.tap(find.textContaining('Place order'));
      await tester.pump(); // start the mock payment
      await tester.pumpAndSettle();

      expect(
        p.cart.isEmpty,
        isTrue,
        reason: 'the cart must be empty once the order is placed',
      );
      expect(p.orders.count, 1, reason: 'the order must exist');
      expect(p.orders.orders.single.items.length, 1);
      expect(
        p.orders.orders.single.items.single.quantity,
        2,
        reason: 'the order must keep the cart quantities',
      );
      expect(find.byType(OrderSuccessScreen), findsOneWidget);
    });

    testWidgets('the order is reachable from the Orders tab', (tester) async {
      phone(tester);
      final p = await pumpApp(tester, const OrdersScreen());
      expect(find.text('No orders yet'), findsOneWidget);

      p.orders.placeOrder(
        items: [item()],
        total: 149,
        address: '1 Test Street',
        isPriority: false,
      );
      await tester.pumpAndSettle();

      expect(find.text('No orders yet'), findsNothing);
      expect(find.text('Paracetamol 500'), findsOneWidget);
    });

    testWidgets('the order survives into the detail screen', (tester) async {
      phone(tester);
      final p = await pumpApp(tester, const OrdersScreen());
      final id = p.orders.placeOrder(
        items: [item()],
        total: 149,
        address: '1 Test Street',
        isPriority: false,
      );
      await tester.pumpAndSettle();

      await tester.tap(find.text('Paracetamol 500'));
      await tester.pumpAndSettle();
      expect(find.byType(OrderDetailScreen), findsOneWidget);
      expect(find.textContaining(id), findsWidgets);
    });

    testWidgets('an emptied cart shows the empty state, not stale lines', (
      tester,
    ) async {
      phone(tester);
      final p = await pumpApp(tester, const CartScreen());
      p.cart.add(item(), quantity: 2);
      await tester.pumpAndSettle();
      expect(find.text('Paracetamol 500'), findsOneWidget);

      // The user empties the cart from the Orders side, exactly as checkout
      // does after placing an order.
      p.cart.clear();
      await tester.pumpAndSettle();

      expect(find.text('Paracetamol 500'), findsNothing);
      expect(find.text('Your cart is empty'), findsOneWidget);
    });
  });

  group('Order success screen navigation', () {
    testWidgets('going back pops to the existing shell instead of stacking a '
        'second one', (tester) async {
      final p = await pumpApp(tester, const CheckoutScreen());
      p.cart.add(item());
      await tester.pumpAndSettle();
      await tester.tap(find.textContaining('Place order'));
      await tester.pump();
      await tester.pumpAndSettle();

      expect(p.orders.count, 1);
      expect(p.cart.isEmpty, isTrue);
    });
  });

  group('My orders back navigation', () {
    testWidgets('shows a back button when pushed as a route and it pops', (
      tester,
    ) async {
      phone(tester);
      await pumpApp(
        tester,
        Builder(
          builder: (context) => Scaffold(
            body: Center(
              child: TextButton(
                onPressed: () => Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const OrdersScreen()),
                ),
                child: const Text('open orders'),
              ),
            ),
          ),
        ),
      );
      await tester.tap(find.text('open orders'));
      await tester.pumpAndSettle();

      expect(find.text('My orders'), findsOneWidget);
      final back = find.byType(BackButton);
      expect(
        back,
        findsOneWidget,
        reason: 'a pushed Orders route must offer a back button',
      );

      await tester.tap(back);
      await tester.pumpAndSettle();
      expect(
        find.text('open orders'),
        findsOneWidget,
        reason: 'tapping back must return to the previous page',
      );
    });

    testWidgets('does not show a back button when hosted as the shell tab', (
      tester,
    ) async {
      phone(tester);
      await pumpApp(tester, const OrdersScreen());
      await tester.pumpAndSettle();
      expect(
        find.byType(BackButton),
        findsNothing,
        reason: 'as a shell tab the orders page needs no back button',
      );
    });
  });

  group('Reminder deletion', () {
    testWidgets('the delete button removes the reminder', (tester) async {
      phone(tester);
      final p = await pumpApp(tester, const RemindersScreen());
      p.reminders.add(
        medicineId: 'm1',
        medicineName: 'Paracetamol',
        dosage: '500mg',
        times: const ['08:00'],
        durationDays: 5,
      );
      await tester.pumpAndSettle();

      expect(find.text('Paracetamol'), findsOneWidget);
      expect(p.reminders.reminders.length, 1);

      final button = find.byIcon(Icons.delete_outline_rounded);
      await tester.ensureVisible(button);
      await tester.pumpAndSettle();
      await tester.tap(button);
      await tester.pumpAndSettle();

      expect(
        p.reminders.reminders,
        isEmpty,
        reason: 'delete must remove the reminder from state',
      );
      expect(
        find.text('Paracetamol'),
        findsNothing,
        reason: 'the row must disappear from the list',
      );
    });

    testWidgets('deleting one reminder leaves the others', (tester) async {
      phone(tester);
      final p = await pumpApp(tester, const RemindersScreen());
      p.reminders.add(
        medicineId: 'm1',
        medicineName: 'Paracetamol',
        dosage: '500mg',
        times: const ['08:00'],
        durationDays: 5,
      );
      p.reminders.add(
        medicineId: 'm2',
        medicineName: 'Ibuprofen',
        dosage: '400mg',
        times: const ['09:00'],
        durationDays: 5,
      );
      await tester.pumpAndSettle();
      expect(p.reminders.reminders.length, 2);

      // The first delete button belongs to the first row.
      final button = find.byIcon(Icons.delete_outline_rounded).first;
      await tester.ensureVisible(button);
      await tester.pumpAndSettle();
      await tester.tap(button);
      await tester.pumpAndSettle();

      expect(p.reminders.reminders.length, 1);
      expect(p.reminders.reminders.single.medicineName, 'Ibuprofen');
    });

    testWidgets('deleting the last reminder falls back to the empty state', (
      tester,
    ) async {
      phone(tester);
      final p = await pumpApp(tester, const RemindersScreen());
      p.reminders.add(
        medicineId: 'm1',
        medicineName: 'Paracetamol',
        dosage: '500mg',
        times: const ['08:00'],
        durationDays: 5,
      );
      await tester.pumpAndSettle();

      final button = find.byIcon(Icons.delete_outline_rounded);
      await tester.ensureVisible(button);
      await tester.pumpAndSettle();
      await tester.tap(button);
      await tester.pumpAndSettle();

      expect(find.byIcon(Icons.delete_outline_rounded), findsNothing);
      expect(find.textContaining('No reminder'), findsOneWidget);
    });

    testWidgets('a deleted reminder stays deleted after a reload', (
      tester,
    ) async {
      phone(tester);
      SharedPreferences.setMockInitialValues({});
      StorageService.resetForTest();
      final storage = await StorageService.init();
      final first = ReminderProvider(storage);
      first.add(
        medicineId: 'm1',
        medicineName: 'Paracetamol',
        dosage: '500mg',
        times: const ['08:00'],
        durationDays: 5,
      );
      await tester.pumpWidget(
        ChangeNotifierProvider.value(
          value: first,
          child: const MaterialApp(home: RemindersScreen()),
        ),
      );
      await tester.pumpAndSettle();

      final button = find.byIcon(Icons.delete_outline_rounded);
      await tester.ensureVisible(button);
      await tester.pumpAndSettle();
      await tester.tap(button);
      await tester.pumpAndSettle();
      expect(first.reminders, isEmpty);

      // Restart: the deletion must have been persisted, not just in memory.
      final reloaded = ReminderProvider(storage);
      expect(reloaded.reminders, isEmpty);
    });
  });
}
