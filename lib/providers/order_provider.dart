import 'package:flutter/foundation.dart';
import 'package:uuid/uuid.dart';

import '../core/services/storage_service.dart';
import '../models/cart_item.dart';

class OrderProvider extends ChangeNotifier {
  OrderProvider(this._storage) {
    _orders = _storage.readList('orders', Order.fromJson);
  }

  final StorageService _storage;
  late List<Order> _orders;

  static const _uuid = Uuid();

  List<Order> get orders => List.unmodifiable(_orders.reversed);
  bool get isEmpty => _orders.isEmpty;
  int get count => _orders.length;

  /// Orders still moving through the delivery pipeline.
  List<Order> get active => _orders
      .where((o) =>
          o.status != OrderStatus.delivered &&
          o.status != OrderStatus.reportReady)
      .toList(growable: false);

  Order? byId(String id) {
    for (final o in _orders) {
      if (o.id == id) return o;
    }
    return null;
  }

  String placeOrder({
    required List<CartItem> items,
    required double total,
    required String address,
    required bool isPriority,
    String paymentMethod = 'UPI',
  }) {
    final now = DateTime.now();
    final id = '1MG${_uuid.v4().substring(0, 6).toUpperCase()}';

    final order = Order(
      id: id,
      placedAt: now,
      items: List.of(items),
      total: total,
      status: OrderStatus.placed,
      deliveryAddress: address,
      paymentMethod: paymentMethod,
      isPriority: isPriority,
      estimatedDelivery: now.add(Duration(hours: isPriority ? 24 : 72)),
    );

    _orders.add(order);
    _persist();
    notifyListeners();
    return id;
  }

  void advance(String id) {
    final index = _orders.indexWhere((o) => o.id == id);
    if (index < 0) return;
    final current = _orders[index];
    final order = switch (current.status) {
      OrderStatus.placed => OrderStatus.confirmed,
      OrderStatus.confirmed => OrderStatus.packed,
      OrderStatus.packed => OrderStatus.shipped,
      OrderStatus.shipped => OrderStatus.delivered,
      _ => current.status,
    };
    _orders[index] = _copyWithStatus(current, order);
    _persist();
    notifyListeners();
  }

  Order _copyWithStatus(Order source, OrderStatus status) => Order(
        id: source.id,
        placedAt: source.placedAt,
        items: source.items,
        total: source.total,
        status: status,
        deliveryAddress: source.deliveryAddress,
        paymentMethod: source.paymentMethod,
        estimatedDelivery: source.estimatedDelivery,
        isPriority: source.isPriority,
      );

  void _persist() {
    _storage.writeList('orders', _orders, (o) => o.toJson());
  }
}
