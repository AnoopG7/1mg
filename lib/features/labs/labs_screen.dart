import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_spacing.dart';
import '../../core/utils/formatters.dart';
import '../../data/mock_labs.dart';
import '../../models/lab_test.dart';
import '../../providers/pro_provider.dart';
import '../../shared/widgets/badges.dart';
import '../../shared/widgets/common.dart';
import '../../shared/widgets/normal_range_bar.dart';
import 'lab_test_detail_screen.dart';

class LabsScreen extends StatelessWidget {
  const LabsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Lab tests at home'),
          actions: [
            IconButton(
              tooltip: 'Help & support',
              onPressed: () => _showSupportDialog(context),
              icon: const Icon(Icons.support_agent_rounded),
            ),
          ],
          bottom: const TabBar(
            labelColor: AppColors.primary,
            unselectedLabelColor: AppColors.textTertiary,
            indicatorColor: AppColors.primary,
            dividerColor: AppColors.border,
            labelStyle: TextStyle(fontSize: 13.5, fontWeight: FontWeight.w600),
            tabs: [
              Tab(text: 'Health packages'),
              Tab(text: 'Individual tests'),
            ],
          ),
        ),
        body: const TabBarView(children: [_BundleList(), _TestList()]),
      ),
    );
  }
}

/// Help & support dialog: real contact details, the demo disclaimer and a
/// working "copy number" action.
void _showSupportDialog(BuildContext context) {
  showDialog<void>(
    context: context,
    builder: (ctx) => AlertDialog(
      title: const Text('Help & support'),
      content: const Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Have questions about a health package or home sample collection? '
            'Reach our demo line between 8 AM and 8 PM.',
          ),
          SizedBox(height: AppSpacing.md),
          Text(
            'Support: 1800-123-1000\nWhatsApp: +91 98765 10010',
            style: TextStyle(fontWeight: FontWeight.w600),
          ),
          SizedBox(height: AppSpacing.md),
          Text(
            'This is a college demo — no real bookings are made and no payment '
            'is processed.',
            style: TextStyle(
              fontSize: 11.5,
              color: AppColors.textTertiary,
              height: 1.4,
            ),
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () async {
            await Clipboard.setData(const ClipboardData(text: '1800-123-1000'));
            if (ctx.mounted) Navigator.pop(ctx);
            if (context.mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Support number copied')),
              );
            }
          },
          child: const Text('Copy number'),
        ),
        FilledButton(
          onPressed: () => Navigator.pop(ctx),
          child: const Text('Got it'),
        ),
      ],
    ),
  );
}

class _BundleList extends StatelessWidget {
  const _BundleList();

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.pageH,
        AppSpacing.lg,
        AppSpacing.pageH,
        AppSpacing.xxl,
      ),
      children: [
        const NoticeBanner(
          color: AppColors.success,
          icon: Icons.local_offer_rounded,
          title: 'Up to 50% off on complete packages',
          message:
              'Buying a health package instead of separate tests is cheaper — '
              'and you get one home sample collection for everything.',
        ),
        const SizedBox(height: AppSpacing.lg),
        for (final b in MockLabs.bundles)
          Padding(
            padding: const EdgeInsets.only(bottom: AppSpacing.lg),
            child: BundleCard(bundle: b),
          ),
        const SizedBox(height: AppSpacing.md),
        const _HowItWorks(),
      ],
    );
  }
}

class BundleCard extends StatelessWidget {
  const BundleCard({super.key, required this.bundle});

  final LabBundle bundle;

  @override
  Widget build(BuildContext context) {
    final pro = context.watch<ProProvider>();
    final tests = MockLabs.testsIn(bundle);
    final price = pro.isPro ? bundle.offerPrice * 0.95 : bundle.offerPrice;
    final isRecommended = bundle.badge.contains('50%');

    return AppCard(
      padding: EdgeInsets.zero,
      borderColor: isRecommended
          ? AppColors.primary
          : bundle.accentColor.withValues(alpha: 0.3),
      borderRadius: BorderRadius.circular(AppRadius.lg),
      onTap: () => Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => LabTestDetailScreen(bundle: bundle)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(AppSpacing.lg),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  bundle.accentColor.withValues(alpha: 0.14),
                  bundle.accentColor.withValues(alpha: 0.04),
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(AppRadius.lg - 1),
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    DiscountBadge(percent: bundle.discountPercent, large: true),
                    const SizedBox(width: AppSpacing.sm),
                    Expanded(
                      child: Text(
                        bundle.badge,
                        style: TextStyle(
                          fontSize: 11,
                          color: bundle.accentColor,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                    if (isRecommended)
                      const AppBadge(
                        label: 'Most popular',
                        icon: Icons.thumb_up_rounded,
                        color: AppColors.primary,
                        dense: true,
                      ),
                    if (pro.isPro)
                      const Padding(
                        padding: EdgeInsets.only(left: 4),
                        child: ProBadge(dense: true),
                      ),
                  ],
                ),
                const SizedBox(height: AppSpacing.md),
                Text(
                  bundle.name,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    height: 1.3,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  bundle.tagline,
                  style: const TextStyle(
                    fontSize: 12,
                    color: AppColors.textSecondary,
                    height: 1.4,
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(AppSpacing.lg),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                PriceComparison(mrp: bundle.mrp, offerPrice: price),
                const SizedBox(height: AppSpacing.md),
                Row(
                  children: [
                    const Icon(
                      Icons.biotech_rounded,
                      size: 14,
                      color: AppColors.textTertiary,
                    ),
                    const SizedBox(width: 5),
                    Flexible(
                      child: Text(
                        '${tests.length} tests · ${tests.fold(0, (s, t) => s + t.parameters.length)} parameters',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontSize: 11.5,
                          color: AppColors.textTertiary,
                        ),
                      ),
                    ),
                    const Spacer(),
                    const Icon(
                      Icons.holiday_village_rounded,
                      size: 14,
                      color: AppColors.textTertiary,
                    ),
                    const SizedBox(width: 5),
                    const Text(
                      'Free home collection',
                      style: TextStyle(
                        fontSize: 11.5,
                        color: AppColors.textTertiary,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: AppSpacing.md),
                Text(
                  'Recommended for: ${bundle.recommendedFor}',
                  style: const TextStyle(
                    fontSize: 11.5,
                    color: AppColors.textSecondary,
                    height: 1.4,
                    fontStyle: FontStyle.italic,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _TestList extends StatelessWidget {
  const _TestList();

  @override
  Widget build(BuildContext context) {
    final pro = context.watch<ProProvider>();

    return ListView(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.pageH,
        AppSpacing.lg,
        AppSpacing.pageH,
        AppSpacing.xxl,
      ),
      children: [
        for (final t in MockLabs.tests)
          Padding(
            padding: const EdgeInsets.only(bottom: AppSpacing.md),
            child: AppCard(
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => LabTestDetailScreen(test: t)),
              ),
              child: Row(
                children: [
                  Container(
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                      color: t.accentColor.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(AppRadius.md),
                    ),
                    child: Icon(t.icon, size: 22, color: t.accentColor),
                  ),
                  const SizedBox(width: AppSpacing.md),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          t.name,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            fontSize: 13.5,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Row(
                          children: [
                            Text(
                              '${t.parameters.length} parameters',
                              style: const TextStyle(
                                fontSize: 11,
                                color: AppColors.textTertiary,
                              ),
                            ),
                            if (t.fastingRequired) ...[
                              const SizedBox(width: AppSpacing.sm),
                              const AppBadge(
                                label: 'Fasting',
                                icon: Icons.no_food_rounded,
                                color: AppColors.warning,
                                dense: true,
                              ),
                            ],
                          ],
                        ),
                      ],
                    ),
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        Fmt.money(pro.isPro ? t.price * 0.95 : t.price),
                        style: const TextStyle(
                          fontSize: 14.5,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      if (t.discountPercent > 0)
                        Text(
                          Fmt.money(t.mrp),
                          style: const TextStyle(
                            fontSize: 10.5,
                            color: AppColors.textTertiary,
                            decoration: TextDecoration.lineThrough,
                          ),
                        ),
                    ],
                  ),
                ],
              ),
            ),
          ),
      ],
    );
  }
}

class _HowItWorks extends StatelessWidget {
  const _HowItWorks();

  @override
  Widget build(BuildContext context) {
    const steps = [
      (
        Icons.event_available_rounded,
        'Book a slot',
        'Choose a date and 30-minute window for sample collection.',
      ),
      (
        Icons.home_rounded,
        'Free home collection',
        'Our phlebotomist visits with a sterile kit — no queue, no waiting.',
      ),
      (
        Icons.biotech_rounded,
        'Accredited lab testing',
        'NABL-accredited labs process your sample within 24–48 hours.',
      ),
      (
        Icons.description_rounded,
        'View your report',
        'Every value is shown against its normal range with an explanation.',
      ),
    ];

    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'How home collection works',
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: AppSpacing.md),
          for (var i = 0; i < steps.length; i++) ...[
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 32,
                  height: 32,
                  decoration: BoxDecoration(
                    color: AppColors.primarySurface,
                    borderRadius: BorderRadius.circular(AppRadius.sm),
                  ),
                  child: Icon(steps[i].$1, size: 17, color: AppColors.primary),
                ),
                const SizedBox(width: AppSpacing.md),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        steps[i].$2,
                        style: const TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        steps[i].$3,
                        style: const TextStyle(
                          fontSize: 12,
                          height: 1.45,
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            if (i < steps.length - 1)
              const Padding(
                padding: EdgeInsets.only(left: 15, top: 4, bottom: 4),
                child: SizedBox(
                  height: 16,
                  child: VerticalDivider(color: AppColors.border),
                ),
              ),
          ],
        ],
      ),
    );
  }
}
