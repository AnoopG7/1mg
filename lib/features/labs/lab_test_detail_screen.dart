import 'package:flutter/material.dart';
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
import 'lab_booking_screen.dart';
import 'lab_result_screen.dart';

/// Detail page for a single test or a health package.
class LabTestDetailScreen extends StatelessWidget {
  const LabTestDetailScreen({super.key, this.test, this.bundle});

  final LabTest? test;
  final LabBundle? bundle;

  List<LabTest> get _tests {
    if (bundle != null) return MockLabs.testsIn(bundle!);
    return [test!];
  }

  String get _name => bundle?.name ?? test!.name;

  @override
  Widget build(BuildContext context) {
    final tests = _tests;
    final pro = context.watch<ProProvider>();
    final basePrice = bundle?.offerPrice ?? test!.price;
    final mrp = bundle?.mrp ?? test!.mrp;
    final price = pro.isPro ? basePrice * 0.95 : basePrice;
    final paramCount = tests.fold(0, (s, t) => s + t.parameters.length);
    final needsFasting =
        tests.any((t) => t.fastingRequired);

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            pinned: true,
            expandedHeight: 160,
            backgroundColor: AppColors.surface,
            flexibleSpace: FlexibleSpaceBar(
              background: Container(
                color: (bundle?.accentColor ?? test!.accentColor)
                    .withValues(alpha: 0.1),
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    Icon(Icons.biotech_rounded,
                        size: 60,
                        color: (bundle?.accentColor ?? test!.accentColor)
                            .withValues(alpha: 0.4)),
                    if (bundle != null)
                      Positioned(
                        top: 64,
                        child: DiscountBadge(
                            percent: bundle!.discountPercent, large: true),
                      ),
                  ],
                ),
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(
                  AppSpacing.pageH, AppSpacing.lg, AppSpacing.pageH, 0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(_name,
                            style: Theme.of(context).textTheme.headlineSmall),
                      ),
                      if (pro.isPro) const ProBadge(),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    bundle?.tagline ?? test!.description,
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                  const SizedBox(height: AppSpacing.md),
                  Wrap(
                    spacing: AppSpacing.sm,
                    runSpacing: AppSpacing.sm,
                    children: [
                      AppBadge(
                        label: '${tests.length} test${tests.length == 1 ? '' : 's'}',
                        icon: Icons.biotech_rounded,
                      ),
                      AppBadge(
                        label: '$paramCount parameters',
                        icon: Icons.table_chart_rounded,
                        color: AppColors.info,
                      ),
                      if (needsFasting)
                        const AppBadge(
                          label: 'Fasting required',
                          icon: Icons.no_food_rounded,
                          color: AppColors.warning,
                        )
                      else
                        const AppBadge(
                          label: 'No fasting',
                          icon: Icons.restaurant_rounded,
                          color: AppColors.success,
                        ),
                      const AppBadge(
                        label: 'Report in 24–48h',
                        icon: Icons.schedule_rounded,
                        color: AppColors.secondary,
                      ),
                    ],
                  ),
                  const SizedBox(height: AppSpacing.lg),
                  AppCard(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        if (bundle != null)
                          PriceComparison(mrp: mrp, offerPrice: price)
                        else
                          Row(
                            children: [
                              Text(Fmt.money(price),
                                  style: const TextStyle(
                                      fontSize: 24,
                                      fontWeight: FontWeight.w700)),
                              const SizedBox(width: AppSpacing.sm),
                              if (mrp > price) ...[
                                Text(Fmt.money(mrp),
                                    style: const TextStyle(
                                      fontSize: 14,
                                      color: AppColors.textTertiary,
                                      decoration: TextDecoration.lineThrough,
                                    )),
                                const SizedBox(width: AppSpacing.sm),
                                DiscountBadge(percent: test!.discountPercent),
                              ],
                            ],
                          ),
                        const Divider(height: AppSpacing.xl),
                        const InfoRow(
                            label: 'Home sample collection',
                            value: 'Free',
                            icon: Icons.home_rounded,
                            valueColor: AppColors.success),
                        InfoRow(
                          label: 'Lab',
                          value: 'NABL accredited',
                          icon: Icons.verified_rounded,
                        ),
                        InfoRow(
                          label: 'Report',
                          value: 'Digital + print',
                          icon: Icons.description_rounded,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: _Section(
              title: 'Preparation instructions',
              icon: Icons.checklist_rounded,
              children: [
                NoticeBanner(
                  color: needsFasting ? AppColors.warning : AppColors.secondary,
                  icon: needsFasting
                      ? Icons.no_food_rounded
                      : Icons.restaurant_rounded,
                  title: needsFasting
                      ? 'Fasting required (8–12 hours)'
                      : 'No fasting required',
                  message: needsFasting
                      ? 'Only plain water is allowed during the fast. Taking a '
                          'sweet beverage or a heavy meal before the test will '
                          'invalidate your results.'
                      : 'Eat normally before the test. Stay well hydrated — it '
                          'makes the blood draw easier and faster.',
                ),
                const SizedBox(height: AppSpacing.md),
                AppCard(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      for (final p in _mergedPrep(tests))
                        BulletPoint(
                          text: p,
                          icon: Icons.check_rounded,
                          color: AppColors.secondary,
                        ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          SliverToBoxAdapter(
            child: _Section(
              title: 'Parameters measured',
              icon: Icons.table_chart_rounded,
              subtitle: '$paramCount values reported with normal ranges',
              children: [
                AppCard(
                  child: Column(
                    children: [
                      for (final t in tests) ...[
                        Padding(
                          padding: const EdgeInsets.only(
                              top: AppSpacing.sm, bottom: AppSpacing.xs),
                          child: Row(
                            children: [
                              Icon(t.icon, size: 14, color: t.accentColor),
                              const SizedBox(width: 6),
                              Expanded(
                                child: Text(
                                  t.name,
                                  style: const TextStyle(
                                      fontSize: 12.5,
                                      fontWeight: FontWeight.w700),
                                ),
                              ),
                            ],
                          ),
                        ),
                        const Divider(height: AppSpacing.md),
                        for (final p in t.parameters)
                          Padding(
                            padding:
                                const EdgeInsets.only(bottom: AppSpacing.md),
                            child: Row(
                              children: [
                                Expanded(
                                  child: Text(
                                    p.parameter,
                                    style: const TextStyle(fontSize: 13),
                                  ),
                                ),
                                Text(
                                  p.displayRange,
                                  style: const TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w600,
                                    color: AppColors.success,
                                  ),
                                ),
                              ],
                            ),
                          ),
                      ],
                    ],
                  ),
                ),
                const SizedBox(height: AppSpacing.md),
                const NoticeBanner(
                  color: AppColors.info,
                  icon: Icons.info_rounded,
                  title: 'Sample report',
                  message:
                      'After booking, use "View sample report" to see exactly how '
                      'your values will be displayed against their normal ranges.',
                ),
              ],
            ),
          ),
          if (bundle != null)
            SliverToBoxAdapter(
              child: _Section(
                title: 'Tests included',
                icon: Icons.checklist_rounded,
                children: [
                  for (final t in tests)
                    Padding(
                      padding: const EdgeInsets.only(bottom: AppSpacing.sm),
                      child: AppCard(
                        padding: const EdgeInsets.symmetric(
                            horizontal: AppSpacing.lg,
                            vertical: AppSpacing.md),
                        child: Row(
                          children: [
                            Icon(t.icon, size: 17, color: t.accentColor),
                            const SizedBox(width: AppSpacing.md),
                            Expanded(
                              child: Text(t.name,
                                  style: const TextStyle(fontSize: 13)),
                            ),
                            Text(
                              Fmt.money(t.price),
                              style: const TextStyle(
                                  fontSize: 12.5,
                                  fontWeight: FontWeight.w600,
                                  color: AppColors.textTertiary),
                            ),
                          ],
                        ),
                      ),
                    ),
                ],
              ),
            ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(AppSpacing.pageH, AppSpacing.xl,
                  AppSpacing.pageH, AppSpacing.xxl),
              child: OutlinedButton.icon(
                onPressed: () => Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => LabResultScreen(tests: tests, isSample: true),
                  ),
                ),
                icon: const Icon(Icons.preview_rounded, size: 18),
                label: const Text('View sample report'),
              ),
            ),
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
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(Fmt.money(price),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                          fontSize: 18, fontWeight: FontWeight.w700)),
                  Text(
                    bundle != null
                        ? 'You save ${Fmt.money(mrp - price)}'
                        : 'Inclusive of taxes',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                        fontSize: 10.5, color: AppColors.success),
                  ),
                ],
              ),
            ),
            const SizedBox(width: AppSpacing.md),
            FilledButton.icon(
              onPressed: () => Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => LabBookingScreen(tests: tests, bundle: bundle),
                ),
              ),
              icon: const Icon(Icons.event_rounded, size: 18),
              label: const Text('Book now'),
            ),
          ],
        ),
      ),
    );
  }

  /// Merges preparation steps from all tests, removing duplicates.
  List<String> _mergedPrep(List<LabTest> tests) {
    final seen = <String>{};
    final out = <String>[];
    for (final t in tests) {
      for (final p in t.preparation) {
        if (seen.add(p)) out.add(p);
      }
    }
    return out;
  }
}

class _Section extends StatelessWidget {
  const _Section({
    required this.title,
    required this.icon,
    required this.children,
    this.subtitle,
  });

  final String title;
  final IconData icon;
  final List<Widget> children;
  final String? subtitle;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(
          AppSpacing.pageH, AppSpacing.xl, AppSpacing.pageH, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 17, color: AppColors.primary),
              const SizedBox(width: AppSpacing.sm),
              Expanded(
                child: Text(title,
                    style: const TextStyle(
                        fontSize: 15.5, fontWeight: FontWeight.w700)),
              ),
            ],
          ),
          if (subtitle != null) ...[
            const SizedBox(height: 2),
            Text(subtitle!,
                style: const TextStyle(
                    fontSize: 11.5, color: AppColors.textTertiary)),
          ],
          const SizedBox(height: AppSpacing.md),
          ...children,
        ],
      ),
    );
  }
}
