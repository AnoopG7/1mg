import 'package:flutter/foundation.dart';

import '../core/services/storage_service.dart';
import '../models/subscription.dart';

/// Owns 1mg Pro state, the monthly refill subscription, and the referral
/// credit wallet (₹100 per successful referral).
class ProProvider extends ChangeNotifier {
  ProProvider(this._storage) {
    _load();
  }

  final StorageService _storage;
  late ProPlan _plan;
  late RefillSubscription _subscription;
  late ReferralWallet _wallet;

  ProPlan get plan => _plan;
  RefillSubscription get subscription => _subscription;
  ReferralWallet get wallet => _wallet;

  bool get isPro => _plan.isValid;
  bool get hasSubscription => _subscription.active;
  double get referralCredits => _wallet.credits;
  String get referralCode => _wallet.myCode;

  void syncAccountName(String? name) {
    final cleaned = name?.replaceAll(RegExp(r'[^A-Za-z0-9]'), '').toUpperCase();
    if (cleaned == null || cleaned.isEmpty) return;
    final code = cleaned.length > 8 ? cleaned.substring(0, 8) : cleaned;
    if (code == _wallet.myCode) return;
    _wallet = _wallet.copyWith(myCode: code);
    _storage.writeString('referral_code', code);
    notifyListeners();
  }

  /// Combined discount rate the user is earning (0.05 Pro + 0.10 subscription).
  double get effectiveRate =>
      (isPro ? ProPlan.extraDiscount : 0) +
      (hasSubscription ? RefillSubscription.discount : 0);

  void purchasePro() {
    final now = DateTime.now();
    _plan = ProPlan(
      active: true,
      purchasedAt: now,
      expiry: DateTime(now.year + 1, now.month, now.day),
    );
    _storage.writeBool('pro_active', true);
    _storage.writeString('pro_purchased_at', now.toIso8601String());
    _storage.writeString('pro_expiry', _plan.expiry!.toIso8601String());
    notifyListeners();
  }

  void cancelPro() {
    _plan = const ProPlan(active: false, expiry: null);
    _storage.writeBool('pro_active', false);
    _storage.remove('pro_expiry');
    notifyListeners();
  }

  void startSubscription({required String medicineId, required String name, required double price}) {
    _subscription = RefillSubscription(
      active: true,
      medicineId: medicineId,
      medicineName: name,
      monthlyPrice: price,
      nextDelivery: DateTime.now().add(const Duration(days: 30)),
    );
    _storage.writeBool('sub_active', true);
    _storage.writeString('sub_medicine_id', medicineId);
    _storage.writeString('sub_medicine_name', name);
    _storage.writeDouble('sub_price', price);
    notifyListeners();
  }

  void cancelSubscription() {
    _subscription = const RefillSubscription(
      active: false,
      medicineId: '',
      medicineName: '',
      monthlyPrice: 0,
    );
    _storage.writeBool('sub_active', false);
    notifyListeners();
  }

  /// Simulates a friend signing up and completing their first purchase.
  void simulateReferralJoined() {
    final referral = Referral(
      code: 'REF${1000 + _wallet.referrals.length * 7}',
      name: _friendNames[_wallet.referrals.length % _friendNames.length],
      joinedOn: DateTime.now(),
      credited: true,
      earnedAmount: ReferralWallet.creditPerReferral,
    );
    _wallet = _wallet.copyWith(
      referrals: [..._wallet.referrals, referral],
      credits: _wallet.credits + ReferralWallet.creditPerReferral,
    );
    _storage.writeDouble('referral_credits', _wallet.credits);
    _storage.writeList(
      'referrals',
      _wallet.referrals,
      (r) => {
        'code': r.code,
        'name': r.name,
        'joinedOn': r.joinedOn.toIso8601String(),
        'credited': r.credited,
        'earnedAmount': r.earnedAmount,
      },
    );
    notifyListeners();
  }

  /// Spends wallet credit at checkout.
  void applyCredits(double amount) {
    final use = amount.clamp(0.0, _wallet.credits);
    _wallet = _wallet.copyWith(credits: _wallet.credits - use);
    _storage.writeDouble('referral_credits', _wallet.credits);
    notifyListeners();
  }

  String get shareMessage =>
      'Join me on 1mg Health! Use my referral code ${_wallet.myCode} to get '
      '₹100 off your first medicine order. Download now and stay on top of your '
      'health — free symptom checker, medicine reminders and lab tests at home.';

  void _load() {
    final active = _storage.readBool('pro_active');
    final expiryRaw = _storage.readString('pro_expiry');
    _plan = ProPlan(
      active: active,
      purchasedAt: _storage.readString('pro_purchased_at').isEmpty
          ? null
          : DateTime.tryParse(_storage.readString('pro_purchased_at')),
      expiry: expiryRaw.isEmpty ? null : DateTime.tryParse(expiryRaw),
    );

    _subscription = RefillSubscription(
      active: _storage.readBool('sub_active'),
      medicineId: _storage.readString('sub_medicine_id'),
      medicineName: _storage.readString('sub_medicine_name'),
      monthlyPrice: _storage.readDouble('sub_price'),
      nextDelivery: DateTime.now().add(const Duration(days: 30)),
    );

    final referrals = _storage.readList(
      'referrals',
      (json) => Referral(
        code: json['code'] as String,
        name: json['name'] as String,
        joinedOn: DateTime.parse(json['joinedOn'] as String),
        credited: json['credited'] as bool? ?? false,
        earnedAmount: (json['earnedAmount'] as num?)?.toDouble() ?? 0,
      ),
    );

    _wallet = ReferralWallet(
      myCode: _storage.readString('referral_code', fallback: 'USER'),
      credits: _storage.readDouble('referral_credits'),
      referrals: referrals,
    );
  }

  static const List<String> _friendNames = [
    'Priya S.',
    'Rahul M.',
    'Sneha K.',
    'Arjun T.',
    'Meera R.',
  ];
}
