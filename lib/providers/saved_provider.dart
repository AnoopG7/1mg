import 'package:flutter/foundation.dart';

import '../core/services/storage_service.dart';
import '../models/cart_item.dart';

/// Saved medicines, articles and delivery addresses.
class SavedProvider extends ChangeNotifier {
  SavedProvider(this._storage) {
    _medicineIds = _storage.readList(
      'saved_medicines',
      (j) => j['id'] as String,
    );
    _articleIds = _storage.readList('saved_articles', (j) => j['id'] as String);
    _addresses = _storage.readList(_addressesKey, Address.fromJson);
    if (_addresses.isEmpty) {
      _addresses = [_defaultAddress];
      _persistAddresses();
    }
  }

  final StorageService _storage;

  /// Versioned so a change to [defaultAddress] reaches existing installs
  /// instead of being shadowed by an already-persisted copy.
  static const _addressesKey = 'addresses_v2';

  late List<String> _medicineIds;
  late List<String> _articleIds;
  late List<Address> _addresses;

  static const Address _defaultAddress = Address(
    id: 'addr1',
    name: 'Anoop Gupta',
    phone: '1234567890',
    line1: 'Flat 302, Sunrise Apartments',
    line2: 'Andheri West',
    city: 'Mumbai',
    pincode: '400053',
    label: 'Home',
    isDefault: true,
  );

  List<String> get medicineIds => List.unmodifiable(_medicineIds);
  List<String> get articleIds => List.unmodifiable(_articleIds);
  List<Address> get addresses => List.unmodifiable(_addresses);
  Address get defaultAddress =>
      _addresses.firstWhere((a) => a.isDefault, orElse: () => _addresses.first);

  void syncAccountName(String? name) {
    final accountName = name?.trim();
    if (accountName == null || accountName.isEmpty || _addresses.isEmpty) return;
    final index = _addresses.indexWhere((address) => address.isDefault);
    if (index < 0 || _addresses[index].name == accountName) return;
    final address = _addresses[index];
    _addresses[index] = Address(
      id: address.id,
      name: accountName,
      phone: address.phone,
      line1: address.line1,
      line2: address.line2,
      city: address.city,
      pincode: address.pincode,
      label: address.label,
      isDefault: address.isDefault,
    );
    _persistAddresses();
    notifyListeners();
  }

  bool isMedicineSaved(String id) => _medicineIds.contains(id);
  bool isArticleSaved(String id) => _articleIds.contains(id);

  void toggleMedicine(String id) {
    if (!_medicineIds.remove(id)) _medicineIds.add(id);
    _storage.writeList('saved_medicines', _medicineIds, (s) => {'id': s});
    notifyListeners();
  }

  void toggleArticle(String id) {
    if (!_articleIds.remove(id)) _articleIds.add(id);
    _storage.writeList('saved_articles', _articleIds, (s) => {'id': s});
    notifyListeners();
  }

  void addAddress(Address address) {
    _addresses = [..._addresses, address];
    _persistAddresses();
    notifyListeners();
  }

  void removeAddress(String id) {
    if (_addresses.length <= 1) return;
    _addresses = _addresses.where((a) => a.id != id).toList();
    if (!_addresses.any((a) => a.isDefault) && _addresses.isNotEmpty) {
      final first = _addresses.first;
      _addresses = [
        Address(
          id: first.id,
          name: first.name,
          phone: first.phone,
          line1: first.line1,
          line2: first.line2,
          city: first.city,
          pincode: first.pincode,
          label: first.label,
          isDefault: true,
        ),
        ..._addresses.skip(1),
      ];
    }
    _persistAddresses();
    notifyListeners();
  }

  void _persistAddresses() {
    _storage.writeList(_addressesKey, _addresses, (a) => a.toJson());
  }
}
