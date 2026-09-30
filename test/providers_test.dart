import 'package:flutter_test/flutter_test.dart';
import 'package:one_mg_health/models/cart_item.dart';
import 'package:one_mg_health/core/services/storage_service.dart';
import 'package:one_mg_health/models/subscription.dart';
import 'package:one_mg_health/providers/cart_provider.dart';
import 'package:one_mg_health/providers/lab_provider.dart';
import 'package:one_mg_health/providers/order_provider.dart';
import 'package:one_mg_health/providers/pro_provider.dart';
import 'package:one_mg_health/providers/reminder_provider.dart';
import 'package:one_mg_health/providers/saved_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

CartItem _item({
  String id = 'm1',
  double price = 100,
  double mrp = 100,
  int qty = 1,
}) =>
    CartItem(
      id: id,
      title: 'Item $id',
      subtitle: 'strip',
      kind: CartItemKind.medicine,
      unitPrice: price,
      mrp: mrp,
      quantity: qty,
      medicineId: id,
    );

/// StorageService is a singleton, so each test needs a fresh one.
Future<StorageService> freshStorage() async {
  SharedPreferences.setMockInitialValues({});
  StorageService.resetForTest();
  return StorageService.init();
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('CartProvider', () {
    test('add merges quantities for an item already in the cart', () async {
      final cart = CartProvider(await freshStorage());
      cart.add(_item());
      cart.add(_item(), quantity: 2);
      expect(cart.items.length, 1);
      expect(cart.items.single.quantity, 3);
      expect(cart.itemCount, 3);
    });

    test('the quantity argument wins over the one on the CartItem', () async {
      final cart = CartProvider(await freshStorage());
      cart.add(_item(qty: 7), quantity: 2);
      expect(cart.items.single.quantity, 2);
    });

    test('different ids stay separate', () async {
      final cart = CartProvider(await freshStorage());
      cart.add(_item(id: 'a'));
      cart.add(_item(id: 'b'));
      expect(cart.items.length, 2);
    });

    test('setting quantity to zero removes the line', () async {
      final cart = CartProvider(await freshStorage());
      cart.add(_item());
      cart.updateQuantity('m1', 0);
      expect(cart.isEmpty, isTrue);
    });

    test('setting a negative quantity removes the line', () async {
      final cart = CartProvider(await freshStorage());
      cart.add(_item());
      cart.updateQuantity('m1', -5);
      expect(cart.isEmpty, isTrue);
    });

    test('updating an unknown id is a no-op', () async {
      final cart = CartProvider(await freshStorage());
      cart.add(_item(id: 'a'));
      cart.updateQuantity('nope', 4);
      expect(cart.items.length, 1);
    });

    test('remove and clear work', () async {
      final cart = CartProvider(await freshStorage());
      cart.add(_item(id: 'a'));
      cart.add(_item(id: 'b'));
      cart.remove('a');
      expect(cart.items.length, 1);
      cart.clear();
      expect(cart.isEmpty, isTrue);
    });

    test('totals reflect quantity and the MRP gap', () async {
      final cart = CartProvider(await freshStorage());
      cart.add(_item(price: 80, mrp: 100), quantity: 3);
      expect(cart.mrpTotal, 300);
      expect(cart.totalRaw, 240);
      expect(cart.savings, 60);
    });

    test('cart survives a reload from storage', () async {
      final storage = await freshStorage();
      final cart = CartProvider(storage);
      cart.add(_item(id: 'keep'), quantity: 2);
      // A brand new provider reading the same storage, as after an app restart.
      final reloaded = CartProvider(storage);
      expect(reloaded.items.length, 1);
      expect(reloaded.items.single.quantity, 2);
    });

    test('notifies listeners on every mutation', () async {
      final cart = CartProvider(await freshStorage());
      var calls = 0;
      cart.addListener(() => calls++);
      cart.add(_item());
      cart.updateQuantity('m1', 2);
      cart.remove('m1');
      expect(calls, 3);
    });
  });

  group('OrderProvider', () {
    test('placing an order records it and returns a usable id', () async {
      final orders = OrderProvider(await freshStorage());
      final id = orders.placeOrder(
        items: [_item()],
        total: 249,
        address: '1 Test Street',
        isPriority: false,
      );
      expect(id, startsWith('1MG'));
      expect(orders.count, 1);
      expect(orders.byId(id), isNotNull);
      expect(orders.byId(id)!.total, 249);
    });

    test('ids are unique across orders', () async {
      final orders = OrderProvider(await freshStorage());
      final ids = {
        for (var i = 0; i < 25; i++)
          orders.placeOrder(
            items: [_item()],
            total: 100,
            address: 'a',
            isPriority: false,
          )
      };
      expect(ids.length, 25);
    });

    test('priority orders are estimated to arrive a day earlier', () async {
      final orders = OrderProvider(await freshStorage());
      final normal = orders.placeOrder(
          items: [_item()], total: 100, address: 'a', isPriority: false);
      final pro = orders.placeOrder(
          items: [_item()], total: 100, address: 'a', isPriority: true);
      final hours = orders.byId(pro)!.estimatedDelivery!
          .difference(orders.byId(normal)!.estimatedDelivery!)
          .inHours;
      expect(hours, lessThan(0));
    });

    test('advance moves an order along and reaches delivered', () async {
      final orders = OrderProvider(await freshStorage());
      final id = orders.placeOrder(
          items: [_item()], total: 100, address: 'a', isPriority: false);
      var guard = 0;
      while (orders.byId(id)!.status != OrderStatus.delivered && guard++ < 10) {
        orders.advance(id);
      }
      expect(orders.byId(id)!.status, OrderStatus.delivered);
      expect(orders.active.any((o) => o.id == id), isFalse);
    });

    test('advancing an unknown id is a no-op', () async {
      final orders = OrderProvider(await freshStorage());
      orders.placeOrder(
          items: [_item()], total: 100, address: 'a', isPriority: false);
      orders.advance('nope');
      expect(orders.count, 1);
    });

    test('newest order is first', () async {
      final orders = OrderProvider(await freshStorage());
      final first = orders.placeOrder(
          items: [_item()], total: 1, address: 'a', isPriority: false);
      final second = orders.placeOrder(
          items: [_item()], total: 2, address: 'a', isPriority: false);
      expect(orders.orders.first.id, second);
      expect(orders.orders.first.id, isNot(first));
    });
  });

  group('ProProvider', () {
    test('buying Pro activates it for a year', () async {
      final pro = ProProvider(await freshStorage());
      expect(pro.isPro, isFalse);
      pro.purchasePro();
      expect(pro.isPro, isTrue);
      final days = pro.plan.expiry!.difference(pro.plan.purchasedAt!).inDays;
      expect(days, closeTo(365, 2));
    });

    test('cancelling Pro turns the discount off again', () async {
      final pro = ProProvider(await freshStorage());
      pro.purchasePro();
      pro.cancelPro();
      expect(pro.isPro, isFalse);
    });

    test('Pro survives a reload', () async {
      final storage = await freshStorage();
      ProProvider(storage).purchasePro();
      expect(ProProvider(storage).isPro, isTrue);
    });

    test('subscription stacks on top of Pro', () async {
      final pro = ProProvider(await freshStorage());
      pro.purchasePro();
      pro.startSubscription(medicineId: 'm1', name: 'Med', price: 100);
      expect(pro.hasSubscription, isTrue);
      expect(pro.effectiveRate, closeTo(0.15, 0.0001));
      pro.cancelSubscription();
      expect(pro.hasSubscription, isFalse);
      expect(pro.effectiveRate, closeTo(0.05, 0.0001));
    });

    test('a successful referral credits the wallet exactly once', () async {
      final pro = ProProvider(await freshStorage());
      expect(pro.referralCredits, 0);
      pro.simulateReferralJoined();
      expect(pro.referralCredits, ReferralWallet.creditPerReferral);
      expect(pro.wallet.successfulCount, 1);
    });

    test('applying credits cannot drive the balance negative', () async {
      final pro = ProProvider(await freshStorage());
      pro.applyCredits(100);
      pro.applyCredits(500);
      expect(pro.referralCredits, greaterThanOrEqualTo(0));
    });

    test('a share message is produced for the referral flow', () async {
      final pro = ProProvider(await freshStorage());
      expect(pro.shareMessage, isNotEmpty);
      expect(pro.referralCode, isNotEmpty);
    });
  });

  group('ReminderProvider', () {
    test('adding a reminder makes it active and due today', () async {
      final r = ReminderProvider(await freshStorage());
      r.add(
        medicineId: 'm1',
        medicineName: 'Paracetamol',
        dosage: '500mg',
        times: const ['08:00'],
        durationDays: 5,
      );
      expect(r.reminders.length, 1);
      expect(r.totalActive, 1);
      expect(r.dosesDueToday, 1);
    });

    test('an inactive reminder is not counted as due', () async {
      final r = ReminderProvider(await freshStorage());
      r.add(
        medicineId: 'm1',
        medicineName: 'Paracetamol',
        dosage: '500mg',
        times: const ['08:00'],
        durationDays: 5,
      );
      r.toggle(r.reminders.first.id);
      expect(r.totalActive, 0);
      expect(r.dosesDueToday, 0);
    });

    test('marking a dose toggles it, as the reminder chip expects', () async {
      final r = ReminderProvider(await freshStorage());
      r.add(
        medicineId: 'm1',
        medicineName: 'Paracetamol',
        dosage: '500mg',
        times: const ['08:00', '20:00'],
        durationDays: 5,
      );
      final id = r.reminders.first.id;
      final today = DateTime.now();
      r.markDose(id, '08:00', today);
      expect(r.isDoseTaken(id, '08:00', today), isTrue);
      expect(r.dosesTakenToday, 1);
      // Tapping the same dose again clears it rather than double counting.
      r.markDose(id, '08:00', today);
      expect(r.isDoseTaken(id, '08:00', today), isFalse);
      expect(r.dosesTakenToday, 0);
      // The other dose of the day is independent.
      expect(r.isDoseTaken(id, '20:00', today), isFalse);
      // A different day is independent.
      expect(
          r.isDoseTaken(id, '08:00', today.add(const Duration(days: 1))),
          isFalse);
      r.markDose(id, '08:00', today);
      r.markDose(id, '20:00', today);
      expect(r.dosesTakenToday, 2);
    });

    test('removing a reminder clears it', () async {
      final r = ReminderProvider(await freshStorage());
      r.add(
        medicineId: 'm1',
        medicineName: 'Paracetamol',
        dosage: '500mg',
        times: const ['08:00'],
        durationDays: 5,
      );
      r.remove(r.reminders.first.id);
      expect(r.reminders, isEmpty);
    });

    test('weekly adherence always returns 7 buckets in 0..1', () async {
      final r = ReminderProvider(await freshStorage());
      r.add(
        medicineId: 'm1',
        medicineName: 'Paracetamol',
        dosage: '500mg',
        times: const ['08:00'],
        durationDays: 7,
      );
      final week = r.weeklyAdherence();
      expect(week.length, 7);
      for (final v in week) {
        expect(v, inInclusiveRange(0, 1));
      }
    });
  });

  group('SavedProvider', () {
    test('medicines and articles toggle independently', () async {
      final saved = SavedProvider(await freshStorage());
      saved.toggleMedicine('m1');
      expect(saved.isMedicineSaved('m1'), isTrue);
      expect(saved.isArticleSaved('m1'), isFalse);
      saved.toggleMedicine('m1');
      expect(saved.isMedicineSaved('m1'), isFalse);
    });

    test('a default address always exists', () async {
      final saved = SavedProvider(await freshStorage());
      expect(saved.addresses, isNotEmpty);
      expect(saved.defaultAddress.id, isNotEmpty);
    });

    test('addresses can be added and removed', () async {
      final saved = SavedProvider(await freshStorage());
      final before = saved.addresses.length;
      saved.addAddress(const Address(
        id: 'a2',
        name: 'Anoop',
        phone: '9999999999',
        line1: '2 Office Road',
        line2: 'Floor 3',
        city: 'Pune',
        pincode: '411001',
        label: 'Work',
      ));
      expect(saved.addresses.length, before + 1);
      saved.removeAddress('a2');
      expect(saved.addresses.length, before);
    });

    test('removing every address is refused so a default survives', () async {
      final saved = SavedProvider(await freshStorage());
      for (final a in saved.addresses.toList()) {
        saved.removeAddress(a.id);
      }
      expect(saved.addresses, isNotEmpty);
      expect(saved.defaultAddress.id, isNotEmpty);
    });
  });

  group('LabProvider — the booking slot is actually remembered', () {
    test('a booking stores the exact date and time chosen', () async {
      final lab = LabProvider(await freshStorage());
      final slots = lab.availableSlots();
      final chosen = slots[2];
      final id = lab.book(
        testIds: const ['t001'],
        name: 'Complete Health',
        slot: chosen,
        slotTime: LabProvider.defaultSlotTimes[3],
        address: '1 Test Street',
        price: 900,
        mrp: 1200,
      );
      final booking = lab.bookings.firstWhere((b) => b.id == id);
      expect(booking.slot, chosen);
      expect(booking.slotTime, LabProvider.defaultSlotTimes[3]);
      expect(booking.when, contains('${chosen.day}/${chosen.month}'));
    });

    test('different dates produce different stored bookings', () async {
      final lab = LabProvider(await freshStorage());
      final slots = lab.availableSlots();
      final a = lab.book(
        testIds: const ['t001'],
        name: 'A',
        slot: slots[0],
        slotTime: LabProvider.defaultSlotTimes[0],
        address: 'x',
        price: 1,
        mrp: 1,
      );
      final b = lab.book(
        testIds: const ['t001'],
        name: 'B',
        slot: slots[4],
        slotTime: LabProvider.defaultSlotTimes[4],
        address: 'x',
        price: 1,
        mrp: 1,
      );
      expect(lab.byId(a)!.slot, isNot(lab.byId(b)!.slot));
      expect(lab.byId(b)!.slot.day, slots[4].day);
    });

    test('a booking round-trips through storage', () async {
      final storage = await freshStorage();
      final lab = LabProvider(storage);
      final slots = lab.availableSlots();
      final id = lab.book(
        testIds: const ['t002'],
        name: 'Diabetes',
        slot: slots[1],
        slotTime: LabProvider.defaultSlotTimes[2],
        address: '9 Park Lane',
        price: 500,
        mrp: 600,
      );
      final reloaded = LabProvider(storage);
      final booking = reloaded.byId(id)!;
      expect(booking.slot, slots[1]);
      expect(booking.slotTime, LabProvider.defaultSlotTimes[2]);
      expect(booking.address, '9 Park Lane');
    });

    test('bookings saved before slotTime existed still load', () async {
      // Simulates a booking written by an older build with no slotTime key.
      SharedPreferences.setMockInitialValues({
        'lab_bookings': '[{"id":"LBOLD","testIds":["t001"],"bundleId":null,'
            '"name":"Legacy","slot":"2026-01-02T06:30:00.000",'
            '"address":"old","price":100,"mrp":120,'
            '"bookedAt":"2026-01-01T00:00:00.000","isReportReady":false}]',
      });
      StorageService.resetForTest();
      final lab = LabProvider(await StorageService.init());
      final old = lab.byId('LBOLD');
      expect(old, isNotNull);
      expect(old!.slotTime, isEmpty);
      expect(old.when, isNotEmpty);
    });

    test('the chosen time window comes from the shared list', () async {
      final lab = LabProvider(await freshStorage());
      expect(lab.slotTime, LabProvider.defaultSlotTimes.first);
      lab.setSlotTime(LabProvider.defaultSlotTimes[4]);
      expect(lab.slotTime, LabProvider.defaultSlotTimes[4]);
      expect(LabProvider.defaultSlotTimes.length, 5);
      expect(LabProvider.defaultSlotTimes.every((t) => t.contains('AM') || t.contains('PM')),
          isTrue);
    });

    test('markReportReady flips only the target booking', () async {
      final lab = LabProvider(await freshStorage());
      final slots = lab.availableSlots();
      final a = lab.book(
          testIds: const ['t001'],
          name: 'A',
          slot: slots[0],
          slotTime: LabProvider.defaultSlotTimes[0],
          address: 'x',
          price: 1,
          mrp: 1);
      final b = lab.book(
          testIds: const ['t001'],
          name: 'B',
          slot: slots[0],
          slotTime: LabProvider.defaultSlotTimes[0],
          address: 'x',
          price: 1,
          mrp: 1);
      lab.markReportReady(a);
      expect(lab.byId(a)!.isReportReady, isTrue);
      expect(lab.byId(b)!.isReportReady, isFalse);
    });
  });
}
