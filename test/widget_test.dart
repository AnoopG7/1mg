import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:one_mg_health/core/services/storage_service.dart';
import 'package:one_mg_health/main.dart';
import 'package:one_mg_health/providers/cart_provider.dart';
import 'package:one_mg_health/providers/interaction_provider.dart';
import 'package:one_mg_health/providers/lab_provider.dart';
import 'package:one_mg_health/providers/order_provider.dart';
import 'package:one_mg_health/providers/profile_provider.dart';
import 'package:one_mg_health/providers/pro_provider.dart';
import 'package:one_mg_health/providers/reminder_provider.dart';
import 'package:one_mg_health/providers/saved_provider.dart';
import 'package:one_mg_health/providers/symptom_provider.dart';

/// Builds the app against in-memory preferences so no real storage is touched.
Future<StorageService> _pumpApp(WidgetTester tester) async {
  SharedPreferences.setMockInitialValues({});
  final storage = await StorageService.init();

  await tester.pumpWidget(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => CartProvider(storage)),
        ChangeNotifierProvider(create: (_) => OrderProvider(storage)),
        ChangeNotifierProvider(create: (_) => ReminderProvider(storage)),
        ChangeNotifierProvider(create: (_) => ProProvider(storage)),
        ChangeNotifierProvider(create: (_) => SavedProvider(storage)),
        ChangeNotifierProvider(create: (_) => ProfileProvider(storage)),
        ChangeNotifierProvider(create: (_) => LabProvider(storage)),
        ChangeNotifierProvider(create: (_) => SymptomProvider()),
        ChangeNotifierProvider(create: (_) => InteractionProvider()),
      ],
      child: const OneMgApp(),
    ),
  );
  await tester.pump();
  return storage;
}

void main() {
  testWidgets('boots to the home screen with all five tabs', (tester) async {
    await _pumpApp(tester);

    expect(find.text('1mg Health'), findsOneWidget);
    expect(find.byType(NavigationBar), findsOneWidget);

    for (final tab in ['Home', 'Orders', 'Reminders', 'Cart', 'Profile']) {
      expect(find.text(tab), findsOneWidget, reason: 'missing tab $tab');
    }
  });

  testWidgets('quick actions navigate to symptom checker and lab tests', (
    tester,
  ) async {
    await _pumpApp(tester);

    expect(find.text('Symptom\nChecker'), findsOneWidget);
    expect(find.text('Lab Tests'), findsOneWidget);
    expect(find.text('Articles'), findsOneWidget);
  });

  testWidgets('cart tab shows an empty state on a fresh install', (
    tester,
  ) async {
    await _pumpApp(tester);

    await tester.tap(find.text('Cart'));
    await tester.pumpAndSettle();

    expect(find.text('Your cart is empty'), findsOneWidget);
  });
}
