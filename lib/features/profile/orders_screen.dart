import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_spacing.dart';
import '../../core/utils/formatters.dart';
import '../../models/cart_item.dart';
import '../../providers/order_provider.dart';
import '../../shared/widgets/badges.dart';
import '../../shared/widgets/common.dart';
import '../shell/app_shell.dart';
import 'order_detail_screen.dart';

/// Past and in-flight medicine / lab orders.
class OrdersScreen extends StatelessWidget {
  const OrdersScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final orders = context.watch<OrderProvider>();

    return Scaffold(
      appBar: AppBar(title: const Text('My orders')),
      body: orders.isEmpty
          ? EmptyState(
              icon: Icons.receipt_long_outlined,
              title: 'No orders yet',
              message:
                  'Once you place an order you can track its status, delivery '
                  'date and invoice here.',
              actionLabel: 'Shop now',
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
                if (orders.active.isNotEmpty) ...[
                  Text(
                    'In progress',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  const SizedBox(height: AppSpacing.md),
                  for (final o in orders.active) ...[
                    _OrderCard(order: o),
                    const SizedBox(height: AppSpacing.sm),
                  ],
                  const SizedBox(height: AppSpacing.md),
                ],
                Text(
                  'Delivered',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                const SizedBox(height: AppSpacing.md),
                for (final o in orders.orders.where(
                  (o) => o.status == OrderStatus.delivered,
                )) ...[
                  _OrderCard(order: o),
                  const SizedBox(height: AppSpacing.sm),
                ],
              ],
            ),
    );
  }
}

class _OrderCard extends StatelessWidget {
  const _OrderCard({required this.order});

  final Order order;

  @override
  Widget build(BuildContext context) {
    final title = order.items.isEmpty
        ? 'Order'
        : order.items.length == 1
        ? order.items.first.title
        : '${order.items.length} items';

    return AppCard(
      onTap: () => Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => OrderDetailScreen(orderId: order.id)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 34,
                height: 34,
                decoration: BoxDecoration(
                  color: order.status.color.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(AppRadius.sm),
                ),
                child: Icon(
                  order.status.icon,
                  size: 17,
                  color: order.status.color,
                ),
              ),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    Text(
                      '${order.id} · ${Fmt.dateShort(order.placedAt)}',
                      style: const TextStyle(
                        fontSize: 11.5,
                        color: AppColors.textTertiary,
                      ),
                    ),
                  ],
                ),
              ),
              Text(
                Fmt.money(order.total),
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.md),
          Row(
            children: [
              AppBadge(
                label: order.status.label,
                color: order.status.color,
                dense: true,
              ),
              if (order.isPriority) ...[
                const SizedBox(width: 6),
                const AppBadge(
                  label: 'Priority',
                  icon: Icons.bolt_rounded,
                  color: AppColors.proGold,
                  dense: true,
                ),
              ],
              const Spacer(),
              if (order.estimatedDelivery != null &&
                  order.status != OrderStatus.delivered)
                Text(
                  'Arrives ${Fmt.dateShort(order.estimatedDelivery!)}',
                  style: const TextStyle(
                    fontSize: 11.5,
                    color: AppColors.textSecondary,
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }
}
