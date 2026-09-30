import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_spacing.dart';
import '../../core/utils/formatters.dart';
import '../../models/cart_item.dart';
import '../../providers/order_provider.dart';
import '../../shared/widgets/badges.dart';
import '../../shared/widgets/common.dart';

/// Full detail for a single order, including a live status timeline.
class OrderDetailScreen extends StatelessWidget {
  const OrderDetailScreen({super.key, required this.orderId});

  final String orderId;

  static const List<OrderStatus> _timeline = [
    OrderStatus.placed,
    OrderStatus.confirmed,
    OrderStatus.packed,
    OrderStatus.shipped,
    OrderStatus.delivered,
  ];

  @override
  Widget build(BuildContext context) {
    final order = context.watch<OrderProvider>().byId(orderId);

    if (order == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Order')),
        body: const EmptyState(
          icon: Icons.search_off_rounded,
          title: 'Order not found',
          message: 'This order is no longer available in your history.',
        ),
      );
    }

    final currentIndex = _timeline.indexOf(order.status);

    return Scaffold(
      appBar: AppBar(title: Text('Order ${order.id}')),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(
          AppSpacing.pageH,
          AppSpacing.lg,
          AppSpacing.pageH,
          AppSpacing.xxl,
        ),
        children: [
          AppCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: order.status.color.withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(AppRadius.sm),
                      ),
                      child: Icon(
                        order.status.icon,
                        size: 20,
                        color: order.status.color,
                      ),
                    ),
                    const SizedBox(width: AppSpacing.md),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            order.status.label,
                            style: const TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          Text(
                            order.estimatedDelivery == null
                                ? 'Delivered'
                                : 'Expected ${Fmt.date(order.estimatedDelivery!)}',
                            style: const TextStyle(
                              fontSize: 12,
                              color: AppColors.textSecondary,
                            ),
                          ),
                        ],
                      ),
                    ),
                    if (order.isPriority) const ProBadge(dense: true),
                  ],
                ),
                if (currentIndex >= 0) ...[
                  const SizedBox(height: AppSpacing.lg),
                  _Timeline(currentIndex: currentIndex),
                ],
              ],
            ),
          ),
          const SizedBox(height: AppSpacing.lg),
          Text(
            'Items (${order.itemCount})',
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: AppSpacing.md),
          AppCard(
            child: Column(
              children: [
                for (final item in order.items) ...[
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Icon(
                        switch (item.kind) {
                          CartItemKind.medicine => Icons.medication_rounded,
                          CartItemKind.labBundle =>
                            Icons.workspace_premium_rounded,
                          CartItemKind.labTest => Icons.biotech_rounded,
                        },
                        size: 17,
                        color: AppColors.textSecondary,
                      ),
                      const SizedBox(width: AppSpacing.md),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              item.title,
                              style: const TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            if (item.subtitle.isNotEmpty)
                              Text(
                                item.subtitle,
                                style: const TextStyle(
                                  fontSize: 11.5,
                                  color: AppColors.textTertiary,
                                ),
                              ),
                            Text(
                              'Qty ${item.quantity}',
                              style: const TextStyle(
                                fontSize: 11,
                                color: AppColors.textTertiary,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Text(
                        Fmt.money(item.lineTotal),
                        style: const TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
                  ),
                  if (item != order.items.last)
                    const Divider(height: AppSpacing.xl),
                ],
              ],
            ),
          ),
          const SizedBox(height: AppSpacing.lg),
          AppCard(
            child: Column(
              children: [
                InfoRow(label: 'Payment method', value: order.paymentMethod),
                InfoRow(
                  label: 'Placed on',
                  value: Fmt.dateTime(order.placedAt),
                ),
                InfoRow(
                  label: 'Delivery address',
                  value: order.deliveryAddress,
                ),
                if (order.isPriority)
                  const InfoRow(
                    label: 'Delivery speed',
                    value: '1mg Pro priority (24h)',
                    valueColor: AppColors.proGold,
                  ),
                const Divider(height: AppSpacing.xl),
                InfoRow(
                  label: 'Total paid',
                  value: Fmt.money(order.total),
                  bold: true,
                ),
              ],
            ),
          ),
          const SizedBox(height: AppSpacing.lg),
          if (order.status != OrderStatus.delivered)
            FilledButton.icon(
              onPressed: () => context.read<OrderProvider>().advance(order.id),
              icon: const Icon(Icons.fast_forward_rounded, size: 18),
              label: Text('Simulate: mark as ${_nextLabel(order.status)}'),
            )
          else
            OutlinedButton.icon(
              onPressed: () => ScaffoldMessenger.of(context)
                ..hideCurrentSnackBar()
                ..showSnackBar(
                  const SnackBar(
                    content: Text('Invoice download is disabled in demo'),
                  ),
                ),
              icon: const Icon(Icons.receipt_long_rounded, size: 18),
              label: const Text('Download invoice'),
            ),
        ],
      ),
    );
  }

  String _nextLabel(OrderStatus s) => switch (s) {
    OrderStatus.placed => 'confirmed',
    OrderStatus.confirmed => 'packed',
    OrderStatus.packed => 'shipped',
    OrderStatus.shipped => 'delivered',
    _ => 'next stage',
  };
}

class _Timeline extends StatelessWidget {
  const _Timeline({required this.currentIndex});

  final int currentIndex;

  @override
  Widget build(BuildContext context) {
    const steps = [
      (label: 'Placed', icon: Icons.receipt_long_rounded),
      (label: 'Confirmed', icon: Icons.check_circle_rounded),
      (label: 'Packed', icon: Icons.inventory_2_rounded),
      (label: 'Shipped', icon: Icons.local_shipping_rounded),
      (label: 'Delivered', icon: Icons.done_all_rounded),
    ];

    return Row(
      children: [
        for (var i = 0; i < steps.length; i++) ...[
          Expanded(
            flex: 3,
            child: Column(
              children: [
                Container(
                  width: 26,
                  height: 26,
                  decoration: BoxDecoration(
                    color: i <= currentIndex
                        ? AppColors.primary
                        : AppColors.surfaceAlt,
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    steps[i].icon,
                    size: 13,
                    color: i <= currentIndex
                        ? Colors.white
                        : AppColors.textTertiary,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  steps[i].label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 9.5,
                    fontWeight: i == currentIndex
                        ? FontWeight.w700
                        : FontWeight.w500,
                    color: i <= currentIndex
                        ? AppColors.primary
                        : AppColors.textTertiary,
                  ),
                ),
              ],
            ),
          ),
          if (i < steps.length - 1)
            Expanded(
              child: Container(
                height: 2,
                margin: const EdgeInsets.only(bottom: 16),
                color: i < currentIndex ? AppColors.primary : AppColors.border,
              ),
            ),
        ],
      ],
    );
  }
}
