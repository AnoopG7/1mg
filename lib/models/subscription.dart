/// 1mg Pro plan and referral wallet.
class ProPlan {
  const ProPlan({
    required this.active,
    required this.expiry,
    this.purchasedAt,
  });

  final bool active;
  final DateTime? expiry;
  final DateTime? purchasedAt;

  static const double pricePerYear = 499;
  static const double extraDiscount = 0.05;

  static const List<String> benefits = [
    'Extra 5% off on every medicine & lab test',
    'Priority delivery within 24 hours',
    'Free express delivery on orders above ₹399',
    'Unlimited medicine reminders',
    'Free doctor consultation (3 per year)',
    'Early access to health packages',
  ];

  bool get isValid {
    if (!active || expiry == null) return false;
    return expiry!.isAfter(DateTime.now());
  }

  int get daysRemaining {
    if (expiry == null) return 0;
    return expiry!.difference(DateTime.now()).inDays.clamp(0, 3650);
  }

  ProPlan copyWith({
    bool? active,
    DateTime? expiry,
    DateTime? purchasedAt,
  }) =>
      ProPlan(
        active: active ?? this.active,
        expiry: expiry ?? this.expiry,
        purchasedAt: purchasedAt ?? this.purchasedAt,
      );
}

/// Monthly medicine refill subscription — 10% off refills.
class RefillSubscription {
  const RefillSubscription({
    required this.active,
    required this.medicineId,
    required this.medicineName,
    required this.monthlyPrice,
    this.nextDelivery,
  });

  final bool active;
  final String medicineId;
  final String medicineName;
  final double monthlyPrice;
  final DateTime? nextDelivery;

  static const double discount = 0.10;
}

/// A referral, and the ₹100 credit it earns.
class Referral {
  const Referral({
    required this.code,
    required this.name,
    required this.joinedOn,
    required this.credited,
    required this.earnedAmount,
  });

  final String code;
  final String name;
  final DateTime joinedOn;

  /// Has this referral completed a purchase?
  final bool credited;
  final double earnedAmount;
}

/// Referral wallet state.
class ReferralWallet {
  const ReferralWallet({
    required this.myCode,
    required this.credits,
    required this.referrals,
  });

  final String myCode;

  /// ₹ credit balance, ₹100 per successful referral.
  final double credits;
  final List<Referral> referrals;

  static const double creditPerReferral = 100;

  int get successfulCount => referrals.where((r) => r.credited).length;

  ReferralWallet copyWith({double? credits, List<Referral>? referrals}) =>
      ReferralWallet(
        myCode: myCode,
        credits: credits ?? this.credits,
        referrals: referrals ?? this.referrals,
      );
}
