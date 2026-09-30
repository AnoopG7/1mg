import 'package:flutter/foundation.dart';

import '../core/services/storage_service.dart';
import '../models/cart_item.dart';

class CartProvider extends ChangeNotifier {
  CartProvider(this._storage) {
    _items = _storage.readList('cart_items', CartItem.fromJson);
  }

  final StorageService _storage;
  late List<CartItem> _items;

  List<CartItem> get items => List.unmodifiable(_items);
  int get itemCount => _items.fold<int>(0, (s, e) => s + e.quantity);
  bool get isEmpty => _items.isEmpty;
  bool get isNotEmpty => _items.isNotEmpty;

  /// Medicines only — used by the interaction checker prompt on checkout.
  List<CartItem> get medicines =>
      _items.where((i) => i.kind == CartItemKind.medicine).toList();

  bool get hasPrescriptionItem => _items.any((i) => i.isPrescription);

  double get mrpTotal => _items.fold(0.0, (s, e) => s + e.lineMrp);
  double get totalRaw => _items.fold(0.0, (s, e) => s + e.lineTotal);
  double get total => totalRaw + deliveryFee;
  double get deliveryFee => totalRaw >= 399 ? 0 : 49;
  double get savings => mrpTotal - totalRaw;

  bool contains(String id) => _items.any((i) => i.id == id);

  CartItem? itemById(String id) {
    for (final i in _items) {
      if (i.id == id) return i;
    }
    return null;
  }

  void add(CartItem item, {int quantity = 1}) {
    final existingIndex = _items.indexWhere((i) => i.id == item.id);
    if (existingIndex >= 0) {
      final existing = _items[existingIndex];
      _items[existingIndex] = existing.copyWith(
        quantity: existing.quantity + quantity,
      );
    } else {
      _items.add(item.copyWith(quantity: quantity));
    }
    _persist();
    notifyListeners();
  }

  void updateQuantity(String id, int quantity) {
    final index = _items.indexWhere((i) => i.id == id);
    if (index < 0) return;
    if (quantity <= 0) {
      _items.removeAt(index);
    } else {
      _items[index] = _items[index].copyWith(quantity: quantity);
    }
    _persist();
    notifyListeners();
  }

  void remove(String id) {
    _items.removeWhere((i) => i.id == id);
    _persist();
    notifyListeners();
  }

  void clear() {
    _items.clear();
    _persist();
    notifyListeners();
  }

  void _persist() {
    _storage.writeList('cart_items', _items, (i) => i.toJson());
  }
}
