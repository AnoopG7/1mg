import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:one_mg_health/core/services/storage_service.dart';
import 'package:one_mg_health/data/mock_articles.dart';
import 'package:one_mg_health/data/mock_labs.dart';
import 'package:one_mg_health/data/mock_medicines.dart';
import 'package:one_mg_health/features/articles/article_detail_screen.dart';
import 'package:one_mg_health/features/articles/articles_screen.dart';
import 'package:one_mg_health/features/cart/cart_screen.dart';
import 'package:one_mg_health/features/cart/checkout_screen.dart';
import 'package:one_mg_health/features/cart/order_success_screen.dart';
import 'package:one_mg_health/features/home/home_screen.dart';
import 'package:one_mg_health/features/interactions/interaction_checker_screen.dart';
import 'package:one_mg_health/features/labs/lab_booking_screen.dart';
import 'package:one_mg_health/features/labs/lab_result_screen.dart';
import 'package:one_mg_health/features/labs/lab_test_detail_screen.dart';
import 'package:one_mg_health/features/labs/labs_screen.dart';
import 'package:one_mg_health/features/medicines/medicine_detail_screen.dart';
import 'package:one_mg_health/features/medicines/medicine_list_screen.dart';
import 'package:one_mg_health/features/pro/pro_screen.dart';
import 'package:one_mg_health/features/profile/order_detail_screen.dart';
import 'package:one_mg_health/features/profile/orders_screen.dart';
import 'package:one_mg_health/features/profile/profile_screen.dart';
import 'package:one_mg_health/features/reminders/add_reminder_screen.dart';
import 'package:one_mg_health/features/reminders/pill_scan_screen.dart';
import 'package:one_mg_health/features/reminders/reminders_screen.dart';
import 'package:one_mg_health/features/symptom_checker/symptom_checker_screen.dart';
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

late CartProvider _cart;
late OrderProvider _orders;
late ReminderProvider _reminders;
late ProProvider _pro;
late SavedProvider _saved;
late ProfileProvider _profile;
late LabProvider _lab;
late SymptomProvider _symptoms;
late InteractionProvider _interactions;

Future<BuildContext> providers(WidgetTester tester) async {
  tester.view.physicalSize = const Size(390, 844);
  tester.view.devicePixelRatio = 1.0;
  addTearDown(tester.view.reset);
  SharedPreferences.setMockInitialValues({});
  StorageService.resetForTest();
  final storage = await StorageService.init();
  _cart = CartProvider(storage);
  _orders = OrderProvider(storage);
  _reminders = ReminderProvider(storage);
  _pro = ProProvider(storage);
  _saved = SavedProvider(storage);
  _profile = ProfileProvider(storage);
  _lab = LabProvider(storage);
  _symptoms = SymptomProvider();
  _interactions = InteractionProvider();

  final key = GlobalKey();
  await tester.pumpWidget(
    MultiProvider(
      key: key,
      providers: [
        ChangeNotifierProvider.value(value: _cart),
        ChangeNotifierProvider.value(value: _orders),
        ChangeNotifierProvider.value(value: _reminders),
        ChangeNotifierProvider.value(value: _pro),
        ChangeNotifierProvider.value(value: _saved),
        ChangeNotifierProvider.value(value: _profile),
        ChangeNotifierProvider.value(value: _lab),
        ChangeNotifierProvider.value(value: _symptoms),
        ChangeNotifierProvider.value(value: _interactions),
      ],
      child: const SizedBox.shrink(),
    ),
  );
  return key.currentContext!;
}

Future<void> pumpScreen(WidgetTester tester, Widget screen) async {
  await tester.pumpWidget(
    MultiProvider(
      providers: [
        ChangeNotifierProvider.value(value: _cart),
        ChangeNotifierProvider.value(value: _orders),
        ChangeNotifierProvider.value(value: _reminders),
        ChangeNotifierProvider.value(value: _pro),
        ChangeNotifierProvider.value(value: _saved),
        ChangeNotifierProvider.value(value: _profile),
        ChangeNotifierProvider.value(value: _lab),
        ChangeNotifierProvider.value(value: _symptoms),
        ChangeNotifierProvider.value(value: _interactions),
      ],
      child: MaterialApp(home: screen),
    ),
  );
  await tester.pump(const Duration(milliseconds: 200));
}

void main() {
  final med = MockMedicines.all.first;
  final test = MockLabs.tests.first;

  // Build each screen, then throw identifiable overflow/exception failures.
  Future<String?> describeIssue(
    WidgetTester tester,
    Widget screen,
    String name,
  ) async {
    await pumpScreen(tester, screen);
    final errors = tester.takeException();
    if (errors == null) return null;
    return '$name rendered with an exception: $errors';
  }

  testWidgets('all screens render without overflow at 390x844', (tester) async {
    await providers(tester);
    _cart.add(
      const CartItem(
        id: 'm1',
        title: 'Dolo 650',
        subtitle: '10 tablets',
        kind: CartItemKind.medicine,
        unitPrice: 25,
        mrp: 30,
        quantity: 1,
      ),
    );
    _orders.placeOrder(
      items: [_cart.items.first],
      total: 25,
      address: 'No 4, MG Road',
      isPriority: false,
    );
    _reminders.add(
      medicineId: 'm1',
      medicineName: 'Dolo 650',
      dosage: '650mg · 1 tablet',
      times: const ['08:00'],
      durationDays: 5,
    );
    _saved.toggleMedicine('m1');
    _lab.book(
      testIds: [test.id],
      bundleId: null,
      name: test.name,
      slot: DateTime.now().add(const Duration(days: 1)),
      slotTime: '6:30 AM – 7:30 AM',
      address: 'No 4, MG Road',
      price: 349,
      mrp: 500,
    );
    await tester.pumpAndSettle();

    final cases = <String, Widget Function()>{
      'Home': () => const HomeScreen(),
      'MedicineList': () => const MedicineListScreen(),
      'MedicineDetail': () => MedicineDetailScreen(medicine: med),
      'SymptomChecker': () => const SymptomCheckerScreen(),
      'PillScan': () => const PillScanScreen(),
      'InteractionChecker': () => const InteractionCheckerScreen(),
      'Labs': () => const LabsScreen(),
      'LabTestDetail': () => LabTestDetailScreen(test: test),
      'LabBooking': () => LabBookingScreen(tests: [test]),
      'LabResult': () => LabResultScreen(tests: [test], isSample: true),
      'Articles': () => const ArticlesScreen(),
      'ArticleDetail': () =>
          ArticleDetailScreen(article: MockArticles.all.first),
      'Pro': () => const ProScreen(),
      'Cart': () => const CartScreen(),
      'Checkout': () => const CheckoutScreen(),
      'OrderSuccess': () =>
          const OrderSuccessScreen(orderId: 'LB000001', saved: 0),
      'Orders': () => const OrdersScreen(),
      'OrderDetail': () => OrderDetailScreen(orderId: _orders.orders.first.id),
      'Reminders': () => const RemindersScreen(),
      'AddReminder': () => const AddReminderScreen(),
      'Profile': () => const ProfileScreen(),
    };

    late final Set<String> issues = {};
    for (final e in cases.entries) {
      final issue = await describeIssue(tester, e.value(), e.key);
      if (issue != null) issues.add(issue);
    }
    expect(
      issues,
      isEmpty,
      reason: issues.isEmpty ? null : issues.join('\n  '),
    );
  });
}
