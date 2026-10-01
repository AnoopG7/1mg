import 'package:flutter/material.dart';

import '../../core/ui/icon_registry.dart';


enum CartItemKind {
  medicine,
  labBundle,
  labTest;

  /// Resolves a wire value, defaulting to [CartItemKind.medicine] so an
  /// unrecognised kind still renders as a medicine row.
  static CartItemKind fromName(String? name) => values.firstWhere(
        (k) => k.name == name,
        orElse: () => CartItemKind.medicine,
      );
}




class CartItem {
  const CartItem({
    required this.id,
    required this.title,
    required this.subtitle,
    required this.kind,
    required this.unitPrice,
    required this.mrp,
    required this.quantity,
    this.medicineId,
    this.testId,
    this.bundleId,
    this.isPrescription = false,
  });

  final String id;
  final String title;
  final String subtitle;
  final CartItemKind kind;
  final double unitPrice;
  final double mrp;
  final int quantity;
  final String? medicineId;
  final String? testId;
  final String? bundleId;
  final bool isPrescription;

  double get lineTotal => unitPrice * quantity;
  double get lineMrp => mrp * quantity;
  double get lineSavings => lineMrp - lineTotal;

  CartItem copyWith({int? quantity, double? unitPrice, double? mrp}) => CartItem(
        id: id,
        title: title,
        subtitle: subtitle,
        kind: kind,
        unitPrice: unitPrice ?? this.unitPrice,
        mrp: mrp ?? this.mrp,
        quantity: quantity ?? this.quantity,
        medicineId: medicineId,
        testId: testId,
        bundleId: bundleId,
        isPrescription: isPrescription,
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'title': title,
        'subtitle': subtitle,
        'kind': kind.name,
        'unitPrice': unitPrice,
        'mrp': mrp,
        'quantity': quantity,
        'medicineId': medicineId,
        'testId': testId,
        'bundleId': bundleId,
        'isPrescription': isPrescription,
      };

  factory CartItem.fromJson(Map<String, dynamic> json) => CartItem(
        id: json['id'] as String? ?? '',
        title: json['title'] as String? ?? '',
        subtitle: json['subtitle'] as String? ?? '',
        kind: CartItemKind.fromName(json['kind'] as String?),
        unitPrice: (json['unitPrice'] as num?)?.toDouble() ?? 0,
        mrp: (json['mrp'] as num?)?.toDouble() ?? 0,
        quantity: (json['quantity'] as num?)?.toInt() ?? 1,
        medicineId: json['medicineId'] as String?,
        testId: json['testId'] as String?,
        bundleId: json['bundleId'] as String?,
        isPrescription: json['isPrescription'] as bool? ?? false,
      );
}

class Address {
  const Address({
    required this.id,
    required this.name,
    required this.phone,
    required this.line1,
    required this.line2,
    required this.city,
    required this.pincode,
    required this.label,
    this.isDefault = false,
  });

  final String id;
  final String name;
  final String phone;
  final String line1;
  final String line2;
  final String city;
  final String pincode;
  final String label;
  final bool isDefault;

  String get oneLine => '$line1, $line2, $city $pincode';

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'phone': phone,
        'line1': line1,
        'line2': line2,
        'city': city,
        'pincode': pincode,
        'label': label,
        'isDefault': isDefault,
      };

  factory Address.fromJson(Map<String, dynamic> json) => Address(
        id: json['id'] as String? ?? '',
        name: json['name'] as String? ?? '',
        phone: json['phone'] as String? ?? '',
        line1: json['line1'] as String? ?? '',
        line2: json['line2'] as String? ?? '',
        city: json['city'] as String? ?? '',
        pincode: json['pincode'] as String? ?? '',
        label: json['label'] as String? ?? 'Home',
        isDefault: json['isDefault'] as bool? ?? false,
      );
}

enum OrderStatus {
  placed('Order placed', 'order_placed', 0xFF2C6BED),
  confirmed('Confirmed', 'order_confirmed', 0xFF7B4DFF),
  packed('Packed', 'order_packed', 0xFFE8A317),
  shipped('Shipped', 'order_shipped', 0xFF00A9A5),
  delivered('Delivered', 'order_delivered', 0xFF12A150),
  sampleCollected('Sample collected', 'sample_collected', 0xFF7B4DFF),
  reportReady('Report ready', 'report_ready', 0xFF12A150);

  const OrderStatus(this.label, this.iconKey, this.colorValue);

  final String label;

  /// Registry key — see [IconRegistry]. Stored as a string so it serialises.
  final String iconKey;

  /// ARGB int so the status tint serialises.
  final int colorValue;

  IconData get icon => IconRegistry.resolve(iconKey);
  Color get color => IconRegistry.colorFromHex(colorValue);

  /// Resolves a wire value, defaulting to [OrderStatus.placed] so an unknown
  /// status never silently disappears from a timeline.
  static OrderStatus fromName(String? name) => values.firstWhere(
        (s) => s.name == name,
        orElse: () => OrderStatus.placed,
      );
}

class Order {
  const Order({
    required this.id,
    required this.placedAt,
    required this.items,
    required this.total,
    required this.status,
    required this.deliveryAddress,
    this.paymentMethod = 'UPI',
    this.estimatedDelivery,
    this.isPriority = false,
  });

  final String id;
  final DateTime placedAt;
  final List<CartItem> items;
  final double total;
  final OrderStatus status;
  final String deliveryAddress;
  final String paymentMethod;
  final DateTime? estimatedDelivery;
  final bool isPriority;

  int get itemCount => items.fold(0, (s, e) => s + e.quantity);

  Map<String, dynamic> toJson() => {
        'id': id,
        'placedAt': placedAt.toIso8601String(),
        'items': items.map((i) => i.toJson()).toList(),
        'total': total,
        'status': status.name,
        'deliveryAddress': deliveryAddress,
        'paymentMethod': paymentMethod,
        'estimatedDelivery': estimatedDelivery?.toIso8601String(),
        'isPriority': isPriority,
      };

  factory Order.fromJson(Map<String, dynamic> json) => Order(
        id: json['id'] as String? ?? '',
        placedAt: _parseDate(json['placedAt']) ??
            DateTime.fromMillisecondsSinceEpoch(0),
        items: (json['items'] as List<dynamic>? ?? [])
            .whereType<Map<String, dynamic>>()
            .map(CartItem.fromJson)
            .toList(),
        total: (json['total'] as num?)?.toDouble() ?? 0,
        status: OrderStatus.fromName(json['status'] as String?),
        deliveryAddress: json['deliveryAddress'] as String? ?? '',
        paymentMethod: json['paymentMethod'] as String? ?? 'UPI',
        estimatedDelivery: _parseDate(json['estimatedDelivery']),
        isPriority: json['isPriority'] as bool? ?? false,
      );
}

/// Parses a stored date, tolerating a missing or malformed value.
///
/// Returns the epoch rather than throwing, so one corrupt document cannot take
/// down a whole list read.
DateTime? _parseDate(Object? raw) {
  if (raw is! String || raw.isEmpty) return null;
  return DateTime.tryParse(raw);
}

/// Price breakdown shown at checkout.
class PriceBreakdown {
  const PriceBreakdown({
    required this.mrpTotal,
    required this.storeDiscount,
    required this.subscriptionDiscount,
    required this.proDiscount,
    required this.referralApplied,
    required this.deliveryFee,
    required this.payable,
  });

  final double mrpTotal;
  final double storeDiscount;
  final double subscriptionDiscount;
  final double proDiscount;
  final double referralApplied;
  final double deliveryFee;
  final double payable;

  double get totalDiscount =>
      storeDiscount + subscriptionDiscount + proDiscount + referralApplied;

  double get total => mrpTotal - totalDiscount + deliveryFee;
}
