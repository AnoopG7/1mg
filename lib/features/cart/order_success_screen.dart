import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_spacing.dart';
import '../../core/utils/formatters.dart';
import '../../providers/order_provider.dart';
import '../../providers/pro_provider.dart';
import '../../shared/widgets/common.dart';
import '../pro/pro_screen.dart';
import '../shell/app_shell.dart';

/// Post-checkout confirmation with the order summary and next steps.
class OrderSuccessScreen extends StatelessWidget {
  const OrderSuccessScreen({
    super.key,
    required this.orderId,
    required this.saved,
  });

  final String orderId;

  /// How much the user saved on this order.
  final double saved;

  @override
  Widget build(BuildContext context) {
    final order = context.read<OrderProvider>().byId(orderId);
    final pro = context.watch<ProProvider>();

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, _) {
        if (!didPop) _backToShell(context, 1);
      },
      child: Scaffold(
        body: SafeArea(
          child: ListView(
            padding: const EdgeInsets.fromLTRB(
              AppSpacing.pageH,
              AppSpacing.xl,
              AppSpacing.pageH,
              AppSpacing.xl,
            ),
            children: [
              const SizedBox(height: AppSpacing.lg),
              Center(
                child: Container(
                  width: 84,
                  height: 84,
                  decoration: const BoxDecoration(
                    color: AppColors.successSurface,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.check_rounded,
                    size: 44,
                    color: AppColors.success,
                  ),
                ),
              ),
              const SizedBox(height: AppSpacing.xl),
              Text(
                'Order confirmed',
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.headlineSmall,
              ),
              const SizedBox(height: AppSpacing.xs),
              Text(
                'Order $orderId has been placed successfully',
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.bodyMedium,
              ),
              const SizedBox(height: AppSpacing.xxl),
              if (order != null)
                AppCard(
                  child: Column(
                    children: [
                      InfoRow(label: 'Order ID', value: order.id),
                      InfoRow(
                        label: 'Placed on',
                        value: Fmt.dateTime(order.placedAt),
                      ),
                      InfoRow(label: 'Payment', value: order.paymentMethod),
                      InfoRow(label: 'Items', value: '${order.itemCount}'),
                      InfoRow(
                        label: 'Amount paid',
                        value: Fmt.money(order.total),
                        bold: true,
                      ),
                      if (saved > 0)
                        Padding(
                          padding: const EdgeInsets.only(top: 6),
                          child: Text(
                            'You saved ${Fmt.money(saved)} on this order',
                            style: const TextStyle(
                              fontSize: 12,
                              color: AppColors.success,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
              const SizedBox(height: AppSpacing.lg),
              AppCard(
                color: AppColors.primarySurface,
                borderColor: AppColors.primary.withValues(alpha: 0.3),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const Icon(
                          Icons.local_shipping_rounded,
                          size: 18,
                          color: AppColors.primary,
                        ),
                        const SizedBox(width: AppSpacing.sm),
                        Flexible(
                          child: Text(
                            'Delivery by ${order == null || order.estimatedDelivery == null ? '72 hours' : Fmt.dateTime(order.estimatedDelivery!)}',
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              fontSize: 13.5,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: AppSpacing.md),
                    if (pro.isPro)
                      const BulletPoint(
                        text:
                            '1mg Pro is active — your order ships with priority '
                            'delivery and arrives within 24 hours.',
                        icon: Icons.workspace_premium_rounded,
                        color: AppColors.proGold,
                      ),
                    const BulletPoint(
                      text: 'You can track this order any time from the Orders tab.',
                      icon: Icons.receipt_long_rounded,
                      color: AppColors.secondary,
                    ),
                    const BulletPoint(
                      text:
                          'Set a reminder so you never miss a dose of your new '
                          'medicines.',
                      icon: Icons.alarm_rounded,
                      color: AppColors.secondary,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: AppSpacing.xl),
              FilledButton.icon(
                onPressed: () => _backToShell(context, 1),
                icon: const Icon(Icons.receipt_long_rounded, size: 18),
                label: const Text('View my orders'),
              ),
              const SizedBox(height: AppSpacing.sm),
              OutlinedButton.icon(
                onPressed: () => _backToShell(context, 0),
                icon: const Icon(Icons.home_rounded, size: 18),
                label: const Text('Back to home'),
              ),
              const SizedBox(height: AppSpacing.sm),
              OutlinedButton.icon(
                onPressed: () {
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(builder: (_) => const ProScreen()),
                  );
                },
                icon: const Icon(Icons.workspace_premium_rounded, size: 18),
                label: pro.isPro
                    ? const Text('Manage 1mg Pro')
                    : const Text('Explore 1mg Pro'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// Returns to the existing [AppShell] and switches it to [tab].
  ///
  /// This deliberately pops instead of pushing another AppShell: the shell that
  /// launched checkout is still on the stack, and a second one would give the
  /// user a duplicate navigator with its own tab state.
  void _backToShell(BuildContext context, int tab) {
    // Select the tab first, while this route's context is still alive and the
    // shell is a usable ancestor.
    AppShell.goToTab(context, tab);
    Navigator.of(context).popUntil((route) => route.isFirst);
  }
}
