import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/services/pricing_engine.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_spacing.dart';
import '../../core/utils/formatters.dart';
import '../../models/cart_item.dart';
import '../../providers/cart_provider.dart';
import '../../providers/pro_provider.dart';
import '../../shared/widgets/common.dart';
import '../pro/pro_screen.dart';
import '../shell/app_shell.dart';
import 'checkout_screen.dart';

/// The shopping cart with live discount breakdown.
class CartScreen extends StatelessWidget {
  const CartScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final cart = context.watch<CartProvider>();
    final pro = context.watch<ProProvider>();

    final engine = PricingEngine(
      isPro: pro.isPro,
      hasSubscription: pro.hasSubscription,
    );
    final price = engine.breakdown(cart.items);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Cart'),
        actions: [
          if (cart.isNotEmpty)
            TextButton(
              onPressed: () => _confirmClear(context, cart),
              child: const Text('Clear'),
            ),
        ],
      ),
      body: cart.isEmpty
          ? EmptyState(
              icon: Icons.shopping_cart_outlined,
              title: 'Your cart is empty',
              message:
                  'Add medicines or health packages to see your offers, '
                  'discounts and free-delivery progress here.',
              actionLabel: 'Browse medicines',
              onAction: () => AppShell.goToTab(context, 0),
            )
          : ListView(
              padding: const EdgeInsets.fromLTRB(
                AppSpacing.pageH,
                AppSpacing.lg,
                AppSpacing.pageH,
                AppSpacing.xxl,
              ),
              children: [
                if (cart.hasPrescriptionItem)
                  const Padding(
                    padding: EdgeInsets.only(bottom: AppSpacing.md),
                    child: NoticeBanner(
                      color: AppColors.warning,
                      icon: Icons.medical_information_rounded,
                      title: 'Prescription medicine in cart',
                      message:
                          'You will need to upload a valid prescription before '
                          'dispatch. Keep it handy for faster verification.',
                    ),
                  ),
                for (final item in cart.items) ...[
                  _CartRow(item: item),
                  const SizedBox(height: AppSpacing.sm),
                ],
                const SizedBox(height: AppSpacing.sm),
                if (price.deliveryFee > 0)
                  _FreeDeliveryProgress(
                    subtotal: price.total - price.deliveryFee,
                  ),
                if (pro.effectiveRate > 0 || pro.referralCredits > 0) ...[
                  const SizedBox(height: AppSpacing.sm),
                  _OfferStrip(),
                ],
                const SizedBox(height: AppSpacing.lg),
                AppCard(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Price details',
                        style: Theme.of(context).textTheme.titleSmall,
                      ),
                      const SizedBox(height: AppSpacing.sm),
                      InfoRow(
                        label: 'Total MRP',
                        value: Fmt.money(price.mrpTotal),
                      ),
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
                        label: 'Delivery fee',
                        value: price.deliveryFee == 0
                            ? 'FREE'
                            : Fmt.money(price.deliveryFee),
                        valueColor: price.deliveryFee == 0
                            ? AppColors.success
                            : null,
                      ),
                      const Divider(height: AppSpacing.xl),
                      InfoRow(
                        label: 'Total amount',
                        value: Fmt.money(price.payable),
                        bold: true,
                      ),
                      if (price.totalDiscount > 0) ...[
                        const SizedBox(height: 4),
                        Text(
                          'You save ${Fmt.money(price.totalDiscount)} on this order',
                          style: const TextStyle(
                            fontSize: 12,
                            color: AppColors.success,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
                const SizedBox(height: AppSpacing.md),
                OutlinedButton.icon(
                  onPressed: () => AppShell.goToTab(context, 0),
                  icon: const Icon(Icons.arrow_back_rounded, size: 18),
                  label: const Text('Continue shopping'),
                ),
              ],
            ),
      bottomNavigationBar: cart.isEmpty
          ? null
          : Container(
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
                onPressed: () => Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const CheckoutScreen()),
                ),
                icon: const Icon(Icons.lock_rounded, size: 17),
                label: Text('Checkout · ${Fmt.money(price.payable)}'),
              ),
            ),
    );
  }

  Future<void> _confirmClear(BuildContext context, CartProvider cart) async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Clear cart?'),
        content: const Text('This removes every item from your cart.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Keep items'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Clear'),
          ),
        ],
      ),
    );
    if (ok == true) cart.clear();
  }
}

class _CartRow extends StatelessWidget {
  const _CartRow({required this.item});

  final CartItem item;

  @override
  Widget build(BuildContext context) {
    final cart = context.read<CartProvider>();

    return AppCard(
      padding: const EdgeInsets.all(AppSpacing.md),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 42,
            height: 42,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: AppColors.surfaceAlt,
              borderRadius: BorderRadius.circular(AppRadius.sm),
            ),
            child: Icon(
              switch (item.kind) {
                CartItemKind.medicine => Icons.medication_rounded,
                CartItemKind.labBundle => Icons.workspace_premium_rounded,
                CartItemKind.labTest => Icons.biotech_rounded,
              },
              size: 20,
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item.title,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 13.5,
                    fontWeight: FontWeight.w700,
                    height: 1.3,
                  ),
                ),
                if (item.subtitle.isNotEmpty) ...[
                  const SizedBox(height: 2),
                  Text(
                    item.subtitle,
                    style: const TextStyle(
                      fontSize: 11.5,
                      color: AppColors.textTertiary,
                    ),
                  ),
                ],
                const SizedBox(height: AppSpacing.sm),
                Row(
                  children: [
                    Text(
                      Fmt.money(item.lineTotal),
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    if (item.lineMrp > item.lineTotal) ...[
                      const SizedBox(width: 6),
                      Text(
                        Fmt.money(item.lineMrp),
                        style: const TextStyle(
                          fontSize: 11.5,
                          color: AppColors.textTertiary,
                          decoration: TextDecoration.lineThrough,
                        ),
                      ),
                    ],
                    const Spacer(),
                    if (item.kind == CartItemKind.medicine)
                      _QuantityStepper(
                        quantity: item.quantity,
                        onChanged: (q) => cart.updateQuantity(item.id, q),
                      ),
                  ],
                ),
              ],
            ),
          ),
          IconButton(
            onPressed: () => cart.remove(item.id),
            icon: const Icon(Icons.close_rounded, size: 18),
            color: AppColors.textTertiary,
            // Keep a 40px minimum tap target so the button is easy to hit on
            // touch and web alike, instead of a tiny compact hitbox.
            padding: const EdgeInsets.all(4),
            constraints: const BoxConstraints(minWidth: 40, minHeight: 40),
            tooltip: 'Remove',
          ),
        ],
      ),
    );
  }
}

class _QuantityStepper extends StatelessWidget {
  const _QuantityStepper({required this.quantity, required this.onChanged});

  final int quantity;
  final ValueChanged<int> onChanged;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        border: Border.all(color: AppColors.border),
        borderRadius: AppRadius.pillRadius,
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          _StepButton(
            icon: quantity == 1
                ? Icons.delete_outline_rounded
                : Icons.remove_rounded,
            onTap: () => onChanged(quantity - 1),
          ),
          SizedBox(
            width: 22,
            child: Text(
              '$quantity',
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w700),
            ),
          ),
          _StepButton(
            icon: Icons.add_rounded,
            onTap: () => onChanged(quantity + 1),
          ),
        ],
      ),
    );
  }
}

class _StepButton extends StatelessWidget {
  const _StepButton({required this.icon, required this.onTap});

  final IconData icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      customBorder: const CircleBorder(),
      child: Padding(
        padding: const EdgeInsets.all(5),
        child: Icon(icon, size: 15, color: AppColors.primary),
      ),
    );
  }
}

class _FreeDeliveryProgress extends StatelessWidget {
  const _FreeDeliveryProgress({required this.subtotal});

  final double subtotal;

  @override
  Widget build(BuildContext context) {
    final remaining = (PricingEngine.freeDeliveryAbove - subtotal).clamp(
      0.0,
      double.infinity,
    );
    final progress = (subtotal / PricingEngine.freeDeliveryAbove).clamp(
      0.0,
      1.0,
    );

    return AppCard(
      color: remaining == 0 ? AppColors.successSurface : AppColors.surface,
      borderColor: remaining == 0
          ? AppColors.success.withValues(alpha: 0.35)
          : AppColors.border,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                remaining == 0
                    ? Icons.local_shipping_rounded
                    : Icons.local_shipping_rounded,
                size: 16,
                color: remaining == 0
                    ? AppColors.success
                    : AppColors.textSecondary,
              ),
              const SizedBox(width: AppSpacing.sm),
              Expanded(
                child: Text(
                  remaining == 0
                      ? 'You have unlocked free delivery'
                      : 'Add ${Fmt.money(remaining)} more for free delivery',
                  style: TextStyle(
                    fontSize: 12.5,
                    fontWeight: FontWeight.w600,
                    color: remaining == 0
                        ? AppColors.success
                        : AppColors.textPrimary,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.sm),
          ClipRRect(
            borderRadius: BorderRadius.circular(3),
            child: LinearProgressIndicator(
              value: progress,
              minHeight: 5,
              backgroundColor: AppColors.surfaceAlt,
              valueColor: AlwaysStoppedAnimation(
                remaining == 0 ? AppColors.success : AppColors.primary,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _OfferStrip extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final pro = context.watch<ProProvider>();
    return AppCard(
      color: AppColors.proSurface,
      borderColor: AppColors.proGoldLight,
      child: Row(
        children: [
          const Icon(
            Icons.local_offer_rounded,
            color: AppColors.proGold,
            size: 18,
          ),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  pro.isPro
                      ? 'You are saving ${Fmt.percent(pro.effectiveRate * 100)} with 1mg Pro'
                      : 'Get an extra 5% off with 1mg Pro',
                  style: const TextStyle(
                    fontSize: 12.5,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                if (pro.referralCredits > 0)
                  Text(
                    '${Fmt.money(pro.referralCredits)} referral credit available',
                    style: const TextStyle(
                      fontSize: 11.5,
                      color: AppColors.textSecondary,
                    ),
                  ),
              ],
            ),
          ),
          if (!pro.isPro)
            TextButton(
              onPressed: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const ProScreen()),
              ),
              child: const Text('Get Pro'),
            ),
        ],
      ),
    );
  }
}
