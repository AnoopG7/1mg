import 'package:flutter/foundation.dart';
import 'package:uuid/uuid.dart';

import '../core/services/storage_service.dart';

/// A booked lab test — slot, address, price and report status.
class LabBooking {
  const LabBooking({
    required this.id,
    required this.testIds,
    required this.bundleId,
    required this.name,
    required this.slot,
    required this.address,
    required this.price,
    required this.mrp,
    required this.bookedAt,
    required this.isReportReady,
    this.slotTime = '',
  });

  final String id;
  final List<String> testIds;
  final String? bundleId;
  final String name;

  /// Collection date, at 6:30 AM. The human-facing window is [slotTime].
  final DateTime slot;

  /// e.g. `9:30 AM – 10:30 AM`. Empty only for bookings saved before this
  /// field existed.
  final String slotTime;
  final String address;
  final double price;
  final double mrp;
  final DateTime bookedAt;
  final bool isReportReady;

  double get savings => mrp - price;

  /// Single line describing when the phlebotomist arrives.
  String get when {
    final d = '${slot.day}/${slot.month}/${slot.year}';
    return slotTime.isEmpty ? d : '$d · $slotTime';
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'testIds': testIds,
        'bundleId': bundleId,
        'name': name,
        'slot': slot.toIso8601String(),
        'slotTime': slotTime,
        'address': address,
        'price': price,
        'mrp': mrp,
        'bookedAt': bookedAt.toIso8601String(),
        'isReportReady': isReportReady,
      };

  factory LabBooking.fromJson(Map<String, dynamic> json) => LabBooking(
        id: json['id'] as String,
        testIds: (json['testIds'] as List<dynamic>? ?? []).cast<String>(),
        bundleId: json['bundleId'] as String?,
        name: json['name'] as String? ?? '',
        slot: DateTime.parse(json['slot'] as String),
        slotTime: json['slotTime'] as String? ?? '',
        address: json['address'] as String? ?? '',
        price: (json['price'] as num).toDouble(),
        mrp: (json['mrp'] as num?)?.toDouble() ?? 0,
        bookedAt: DateTime.parse(json['bookedAt'] as String),
        isReportReady: json['isReportReady'] as bool? ?? false,
      );
}

class LabProvider extends ChangeNotifier {
  LabProvider(this._storage) {
    _bookings = _storage.readList('lab_bookings', LabBooking.fromJson);
    _slotTime = _storage.readString('lab_slot_time');
    if (_slotTime.isEmpty) _slotTime = defaultSlotTimes.first;
  }

  final StorageService _storage;
  static const _uuid = Uuid();

  /// Collection windows offered for every date. Kept here so the booking
  /// screen, the provider default and any future surface stay in sync.
  static const List<String> defaultSlotTimes = [
    '6:30 AM – 7:30 AM',
    '7:30 AM – 8:30 AM',
    '8:30 AM – 9:30 AM',
    '9:30 AM – 10:30 AM',
    '4:00 PM – 5:00 PM',
  ];

  late List<LabBooking> _bookings;
  late String _slotTime;

  List<LabBooking> get bookings => List.unmodifiable(_bookings.reversed);
  bool get isEmpty => _bookings.isEmpty;
  String get slotTime => _slotTime;

  /// Next 5 home collection slots.
  List<DateTime> availableSlots() {
    final now = DateTime.now();
    return List.generate(5, (i) {
      final day = now.add(Duration(days: i + 1));
      return DateTime(day.year, day.month, day.day, 6, 30);
    });
  }

  void setSlotTime(String time) {
    if (time == _slotTime) return;
    _slotTime = time;
    _storage.writeString('lab_slot_time', time);
    notifyListeners();
  }

  String book({
    required List<String> testIds,
    String? bundleId,
    required String name,
    required DateTime slot,
    String? slotTime,
    required String address,
    required double price,
    required double mrp,
  }) {
    final now = DateTime.now();
    final booking = LabBooking(
      id: 'LB${_uuid.v4().substring(0, 6).toUpperCase()}',
      testIds: testIds,
      bundleId: bundleId,
      name: name,
      slot: slot,
      slotTime: slotTime ?? _slotTime,
      address: address,
      price: price,
      mrp: mrp,
      bookedAt: now,
      isReportReady: false,
    );
    _bookings.add(booking);
    _storage.writeList('lab_bookings', _bookings, (b) => b.toJson());
    notifyListeners();
    return booking.id;
  }

  void markReportReady(String id) {
    final index = _bookings.indexWhere((b) => b.id == id);
    if (index < 0) return;
    final b = _bookings[index];
    _bookings[index] = LabBooking(
      id: b.id,
      testIds: b.testIds,
      bundleId: b.bundleId,
      name: b.name,
      slot: b.slot,
      address: b.address,
      price: b.price,
      mrp: b.mrp,
      bookedAt: b.bookedAt,
      isReportReady: true,
    );
    _storage.writeList('lab_bookings', _bookings, (b) => b.toJson());
    notifyListeners();
  }

  LabBooking? byId(String id) {
    for (final b in _bookings) {
      if (b.id == id) return b;
    }
    return null;
  }
}
