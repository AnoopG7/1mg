import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/services/interaction_engine.dart';
import '../../core/services/pricing_engine.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_spacing.dart';
import '../../core/utils/formatters.dart';
import '../../data/mock_medicines.dart';
import '../../models/cart_item.dart';
import '../../models/medicine.dart';
import '../../providers/cart_provider.dart';
import '../../providers/order_provider.dart';
import '../../providers/pro_provider.dart';
import '../../providers/saved_provider.dart';
import '../../shared/widgets/badges.dart';
import '../../shared/widgets/common.dart';
import 'order_success_screen.dart';

/// Address + payment selection, then places the order.
class CheckoutScreen extends StatefulWidget {
  const CheckoutScreen({super.key});

  @override
  State<CheckoutScreen> createState() => _CheckoutScreenState();
}

class _CheckoutScreenState extends State<CheckoutScreen> {
  String _addressId = '';
  String _payment = 'UPI';
  bool _useCredits = false;
  bool _placing = false;

  static const List<({String name, IconData icon})> _payments = [
    (name: 'UPI', icon: Icons.account_balance_rounded),
    (name: 'Card', icon: Icons.credit_card_rounded),
    (name: 'Net banking', icon: Icons.language_rounded),
    (name: 'Cash on delivery', icon: Icons.payments_rounded),
  ];

  @override
  void initState() {
    super.initState();
    _addressId = context.read<SavedProvider>().defaultAddress.id;
  }

  @override
  Widget build(BuildContext context) {
    final cart = context.watch<CartProvider>();
    final pro = context.watch<ProProvider>();
    final saved = context.watch<SavedProvider>();

    final engine = PricingEngine(
      isPro: pro.isPro,
      hasSubscription: pro.hasSubscription,
      referralCredits: _useCredits ? pro.referralCredits : 0,
    );
    final price = engine.breakdown(cart.items);
    final address = saved.addresses.firstWhere(
      (a) => a.id == _addressId,
      orElse: () => saved.defaultAddress,
    );

    final conflicts = _conflicts(cart);

    return Scaffold(
      appBar: AppBar(title: const Text('Checkout')),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(
          AppSpacing.pageH,
          AppSpacing.lg,
          AppSpacing.pageH,
          AppSpacing.xxl,
        ),
        children: [
          if (conflicts.isNotEmpty) ...[
            NoticeBanner(
              color: AppColors.danger,
              icon: Icons.warning_amber_rounded,
              title: '${conflicts.length} interaction risk in your cart',
              message: conflicts.first.detail,
            ),
            const SizedBox(height: AppSpacing.md),
          ],
          const _SectionTitle('Delivery address'),
          const SizedBox(height: AppSpacing.md),
          for (final a in saved.addresses)
            Padding(
              padding: const EdgeInsets.only(bottom: AppSpacing.sm),
              child: AppCard(
                onTap: () => setState(() => _addressId = a.id),
                color: a.id == _addressId
                    ? AppColors.primarySurface
                    : AppColors.surface,
                borderColor: a.id == _addressId
                    ? AppColors.primary
                    : AppColors.border,
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.lg,
                  vertical: AppSpacing.md,
                ),
                child: Row(
                  children: [
                    Icon(
                      a.id == _addressId
                          ? Icons.radio_button_checked_rounded
                          : Icons.radio_button_unchecked_rounded,
                      size: 20,
                      color: a.id == _addressId
                          ? AppColors.primary
                          : AppColors.borderStrong,
                    ),
                    const SizedBox(width: AppSpacing.md),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            '${a.name} · ${a.phone}',
                            style: const TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          Text(
                            a.oneLine,
                            style: const TextStyle(
                              fontSize: 11.5,
                              color: AppColors.textSecondary,
                              height: 1.4,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          const SizedBox(height: AppSpacing.lg),
          const _SectionTitle('Payment method'),
          const SizedBox(height: AppSpacing.md),
          Wrap(
            spacing: AppSpacing.sm,
            runSpacing: AppSpacing.sm,
            children: [
              for (final p in _payments)
                ChoiceChip(
                  avatar: Icon(p.icon, size: 15),
                  label: Text(p.name),
                  selected: _payment == p.name,
                  selectedColor: AppColors.primarySurface,
                  onSelected: (_) => setState(() => _payment = p.name),
                ),
            ],
          ),
          const SizedBox(height: AppSpacing.lg),
          if (pro.referralCredits > 0)
            AppCard(
              onTap: () => setState(() => _useCredits = !_useCredits),
              color: _useCredits ? AppColors.proSurface : AppColors.surface,
              borderColor: _useCredits ? AppColors.proGold : AppColors.border,
              child: Row(
                children: [
                  Icon(
                    _useCredits
                        ? Icons.check_circle_rounded
                        : Icons.radio_button_unchecked_rounded,
                    size: 20,
                    color: _useCredits
                        ? AppColors.proGold
                        : AppColors.borderStrong,
                  ),
                  const SizedBox(width: AppSpacing.md),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Use referral credit (${Fmt.money(pro.referralCredits)})',
                          style: const TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        Text(
                          'Earned from ${pro.wallet.successfulCount} successful referral(s)',
                          style: const TextStyle(
                            fontSize: 11.5,
                            color: AppColors.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          const SizedBox(height: AppSpacing.lg),
          AppCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Bill summary',
                  style: Theme.of(context).textTheme.titleSmall,
                ),
                const SizedBox(height: AppSpacing.sm),
                InfoRow(label: 'Item MRP', value: Fmt.money(price.mrpTotal)),
                if (price.storeDiscount > 0)
                  InfoRow(
                    label: 'Store discount',
                    value: '− ${Fmt.money(price.storeDiscount)}',
                    valueColor: AppColors.success,
                  ),
                if (price.subscriptionDiscount > 0)
                  InfoRow(
                    label: 'Subscription (10%)',
                    value: '− ${Fmt.money(price.subscriptionDiscount)}',
                    valueColor: AppColors.success,
                  ),
                if (price.proDiscount > 0)
                  InfoRow(
                    label: '1mg Pro (5%)',
                    value: '− ${Fmt.money(price.proDiscount)}',
                    valueColor: AppColors.proGold,
                  ),
                if (price.referralApplied > 0)
                  InfoRow(
                    label: 'Referral credit',
                    value: '− ${Fmt.money(price.referralApplied)}',
                    valueColor: AppColors.proGold,
                  ),
                InfoRow(
                  label: 'Delivery',
                  value: price.deliveryFee == 0
                      ? 'FREE'
                      : Fmt.money(price.deliveryFee),
                  valueColor: price.deliveryFee == 0 ? AppColors.success : null,
                ),
                if (pro.isPro)
                  const Padding(
                    padding: EdgeInsets.only(top: 4),
                    child: Row(
                      children: [
                        ProBadge(dense: true),
                        SizedBox(width: 6),
                        Expanded(
                          child: Text(
                            'Priority delivery included',
                            style: TextStyle(
                              fontSize: 11.5,
                              color: AppColors.textSecondary,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                const Divider(height: AppSpacing.xl),
                InfoRow(
                  label: 'Payable via $_payment',
                  value: Fmt.money(price.payable),
                  bold: true,
                ),
              ],
            ),
          ),
          const SizedBox(height: AppSpacing.md),
          const NoticeBanner(
            color: AppColors.textTertiary,
            icon: Icons.info_rounded,
            message:
                'This is a demo checkout. No real payment is processed and no '
                'money is charged.',
          ),
        ],
      ),
      bottomNavigationBar: Container(
        padding: EdgeInsets.fromLTRB(
          AppSpacing.pageH,
          AppSpacing.md,
          AppSpacing.pageH,
          AppSpacing.md + MediaQuery.of(context).padding.bottom,
        ),
        decoration: const BoxDecoration(
          color: AppColors.surface,
          border: Border(top: BorderSide(color: AppColors.border)),
        ),
        child: FilledButton.icon(
          onPressed: _placing
              ? null
              : () => _place(price, address.oneLine, pro),
          icon: _placing
              ? const SizedBox(
                  width: 16,
                  height: 16,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: Colors.white,
                  ),
                )
              : const Icon(Icons.lock_rounded, size: 17),
          label: Text(
            _placing
                ? 'Placing order…'
                : 'Place order · ${Fmt.money(price.payable)}',
          ),
        ),
      ),
    );
  }

  /// Runs the interaction engine over every pair of medicines in the cart.
  List<InteractionAlert> _conflicts(CartProvider cart) {
    final medicines = cart.medicines
        .map((i) => i.medicineId)
        .whereType<String>()
        .map(MockMedicines.byId)
        .whereType<Medicine>()
        .toList();
    if (medicines.length < 2) return const [];
    return const InteractionEngine().check(medicines: medicines);
  }

  void _place(PriceBreakdown price, String address, ProProvider pro) {
    final cart = context.read<CartProvider>();
    final orders = context.read<OrderProvider>();
    if (_placing || cart.isEmpty) return;

    // This is a demo checkout with no real payment gateway, so the mock
    // payment completes instantly. Keep the flow synchronous: there is no
    // async work to wait for, so the button can never sit on "Placing order…".
    setState(() => _placing = true);

    try {
      final orderId = orders.placeOrder(
        items: cart.items,
        total: price.payable,
        address: address,
        isPriority: pro.isPro,
        paymentMethod: _payment,
      );
      if (_useCredits && price.referralApplied > 0) {
        pro.applyCredits(price.referralApplied);
      }
      cart.clear();

      if (!mounted) return;
      setState(() => _placing = false);

      final savings = price.mrpTotal - price.payable;
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (_) => OrderSuccessScreen(
            orderId: orderId,
            saved: savings > 0 ? savings : 0,
          ),
        ),
      );
    } catch (_) {
      // Never leave the button disabled: reset the flag so the user can retry
      // instead of getting stuck on the loading state.
      if (!mounted) return;
      setState(() => _placing = false);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Could not place the order. Please try again.'),
        ),
      );
    }
  }
}

class _SectionTitle extends StatelessWidget {
  const _SectionTitle(this.text);

  final String text;

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w700),
    );
  }
}
