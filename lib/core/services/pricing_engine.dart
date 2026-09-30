import '../../models/cart_item.dart';
import '../../models/medicine.dart';
import '../../models/subscription.dart';

/// Central place for all the pricing-strategy rules:
/// bundle offers, 10% subscription discount, 1mg Pro's extra 5%, referral
/// credits, and delivery fees.
class PricingEngine {
  const PricingEngine({
    this.isPro = false,
    this.hasSubscription = false,
    this.referralCredits = 0,
  });

  final bool isPro;
  final bool hasSubscription;
  final double referralCredits;

  static const double proDiscountRate = ProPlan.extraDiscount;
  static const double subscriptionDiscountRate = RefillSubscription.discount;
  static const double freeDeliveryAbove = 399;
  static const double standardDeliveryFee = 49;

  /// Effective discount the user is currently earning on medicines and tests.
  double get rate =>
      (isPro ? proDiscountRate : 0) +
      (hasSubscription ? subscriptionDiscountRate : 0);

  /// How the discount is labelled in the UI.
  String get rateLabel {
    if (isPro && hasSubscription) return '1mg Pro + Subscription';
    if (isPro) return '1mg Pro';
    if (hasSubscription) return 'Monthly Refill';
    return 'Standard';
  }

  PriceBreakdown breakdown(List<CartItem> items) {
    if (items.isEmpty) {
      return const PriceBreakdown(
        mrpTotal: 0,
        storeDiscount: 0,
        subscriptionDiscount: 0,
        proDiscount: 0,
        referralApplied: 0,
        deliveryFee: 0,
        payable: 0,
      );
    }

    var mrpTotal = 0.0;
    var storeDiscount = 0.0;
    var medicineSubtotal = 0.0;
    var labSubtotal = 0.0;

    for (final item in items) {
      mrpTotal += item.mrp * item.quantity;
      // Store discount is the gap between the list MRP and the selling price.
      storeDiscount += item.lineMrp - item.lineTotal;
      if (item.kind == CartItemKind.medicine) {
        medicineSubtotal += item.lineTotal;
      } else {
        labSubtotal += item.lineTotal;
      }
    }

    // The 10% refill discount covers medicines only; Pro's 5% covers everything.
    final subscriptionCut =
        hasSubscription ? medicineSubtotal * subscriptionDiscountRate : 0.0;
    final proCut =
        isPro ? (medicineSubtotal + labSubtotal) * proDiscountRate : 0.0;

    final afterDiscount = mrpTotal - storeDiscount - subscriptionCut - proCut;
    final credits = referralCredits.clamp(0.0, afterDiscount.clamp(0.0, double.infinity));
    final delivery = _deliveryFor(afterDiscount - credits);

    return PriceBreakdown(
      mrpTotal: mrpTotal,
      storeDiscount: storeDiscount,
      subscriptionDiscount: subscriptionCut,
      proDiscount: proCut,
      referralApplied: credits,
      deliveryFee: delivery,
      payable: (afterDiscount - credits + delivery).clamp(0, double.infinity),
    );
  }

  double _deliveryFor(double subtotal) {
    if (subtotal <= 0) return 0;
    // Pro orders ship express at no extra cost, so both Pro and a large enough
    // basket qualify for free delivery here; the 24h-vs-72h promise is carried
    // by Order.estimatedDelivery instead of the fee.
    return subtotal >= freeDeliveryAbove ? 0 : standardDeliveryFee;
  }

  /// Sticker price for a single medicine after Pro discount.
  double medicinePrice(Medicine m) {
    final discounted = m.price * (1 - (isPro ? proDiscountRate : 0));
    return _round(discounted);
  }

  /// Sticker price for a lab test / bundle after Pro discount.
  double labPrice(double price) {
    final discounted = price * (1 - (isPro ? proDiscountRate : 0));
    return _round(discounted);
  }

  /// Yearly saving from 1mg Pro at the given annual spend.
  static double proAnnualSaving(double annualSpend) {
    final discount = annualSpend * proDiscountRate;
    final deliverySaving = 2 * 49; // two express deliveries a year
    return _round(discount + deliverySaving);
  }

  static double bundleSaving(double mrp, double offer) => _round(mrp - offer);

  static double _round(double v) => (v * 100).round() / 100;
}
