import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:one_mg_health/core/services/storage_service.dart';
import 'package:one_mg_health/features/cart/cart_screen.dart';
import 'package:one_mg_health/models/cart_item.dart';
import 'package:one_mg_health/providers/cart_provider.dart';
import 'package:one_mg_health/providers/pro_provider.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

CartItem it(String id, String title, int q) => CartItem(
  id: id,
  title: title,
  subtitle: '10 tablets',
  kind: CartItemKind.medicine,
  unitPrice: 25,
  mrp: 30,
  quantity: q,
);

Future<(CartProvider, ProProvider, StorageService)> setup(
  WidgetTester tester,
) async {
  tester.view.physicalSize = const Size(390, 844);
  tester.view.devicePixelRatio = 1.0;
  addTearDown(tester.view.reset);
  SharedPreferences.setMockInitialValues({});
  StorageService.resetForTest();
  final storage = await StorageService.init();
  return (CartProvider(storage), ProProvider(storage), storage);
}

Future<void> pump(WidgetTester tester, CartProvider c, ProProvider p) async {
  await tester.pumpWidget(
    MultiProvider(
      providers: [
        ChangeNotifierProvider.value(value: c),
        ChangeNotifierProvider.value(value: p),
      ],
      child: const MaterialApp(home: CartScreen()),
    ),
  );
  await tester.pumpAndSettle();
}

void main() {
  testWidgets('per-item remove button drops only that line', (tester) async {
    final (c, p, _) = await setup(tester);
    c.add(it('m1', 'Paracetamol 500', 1));
    c.add(it('m2', 'Vitamin D3', 1));
    await pump(tester, c, p);
    expect(c.items.length, 2);

    await tester.tap(find.byTooltip('Remove').first);
    await tester.pumpAndSettle();

    expect(c.items.length, 1);
    expect(c.items.single.id, 'm2');
  });

  testWidgets('quantity stepper decrements and removes the line at zero', (
    tester,
  ) async {
    final (c, p, _) = await setup(tester);
    c.add(it('m1', 'Paracetamol 500', 2), quantity: 2);
    await pump(tester, c, p);
    expect(c.items.single.quantity, 2);

    await tester.tap(find.byIcon(Icons.remove_rounded));
    await tester.pumpAndSettle();
    expect(c.items.single.quantity, 1);

    await tester.tap(find.byIcon(Icons.delete_outline_rounded).first);
    await tester.pumpAndSettle();
    expect(c.items, isEmpty);
    expect(find.text('Your cart is empty'), findsOneWidget);
  });

  testWidgets('clearing the cart persists and survives a reload', (
    tester,
  ) async {
    final (c, p, storage) = await setup(tester);
    c.add(it('m1', 'Paracetamol 500', 1));
    c.add(it('m2', 'Vitamin D3', 1));
    await pump(tester, c, p);

    await tester.tap(find.text('Clear'));
    await tester.pumpAndSettle();
    await tester.tap(find.widgetWithText(FilledButton, 'Clear'));
    await tester.pumpAndSettle();
    expect(c.items, isEmpty);
    expect(find.text('Your cart is empty'), findsOneWidget);

    final reloaded = CartProvider(storage);
    expect(reloaded.items, isEmpty);
  });
}
