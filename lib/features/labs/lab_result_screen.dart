import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/services/normal_range.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_spacing.dart';
import '../../core/utils/formatters.dart';
import '../../models/lab_test.dart';
import '../../providers/lab_provider.dart';
import '../../shared/widgets/badges.dart';
import '../../shared/widgets/common.dart';
import '../../shared/widgets/normal_range_bar.dart';

/// Displays lab values against their normal ranges with a status chip and a
/// plain-English interpretation.
class LabResultScreen extends StatelessWidget {
  const LabResultScreen({
    super.key,
    required this.tests,
    this.isSample = false,
    this.bookingId,
  });

  final List<LabTest> tests;

  /// True when showing a demo report before a real result exists.
  final bool isSample;
  final String? bookingId;

  @override
  Widget build(BuildContext context) {
    final service = const NormalRangeService();
    final summary = service.summarise(tests);
    final advice = service.advice(summary);
    // The booking created moments ago, so we can echo the exact slot the user
    // picked instead of showing a generic confirmation.
    final booking =
        bookingId == null ? null : context.watch<LabProvider>().byId(bookingId!);

    return Scaffold(
      appBar: AppBar(
        title: Text(isSample ? 'Sample report' : 'Your report'),
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(
            AppSpacing.pageH, AppSpacing.lg, AppSpacing.pageH, AppSpacing.xxxl),
        children: [
          if (isSample)
            const Padding(
              padding: EdgeInsets.only(bottom: AppSpacing.md),
              child: NoticeBanner(
                color: AppColors.purple,
                icon: Icons.preview_rounded,
                title: 'Sample report',
                message:
                    'This is an example of how your report will look. Actual '
                    'values depend on your own results.',
              ),
            )
          else if (bookingId != null)
            Padding(
              padding: const EdgeInsets.only(bottom: AppSpacing.md),
              child: Column(
                children: [
                  const NoticeBanner(
                    color: AppColors.success,
                    icon: Icons.check_circle_rounded,
                    title: 'Booking confirmed',
                    message:
                        'Your sample collection is scheduled. We will notify you when '
                        'the report is ready in 24–48 hours.',
                  ),
                  if (booking != null) ...[
                    const SizedBox(height: AppSpacing.sm),
                    AppCard(
                      child: Column(
                        children: [
                          InfoRow(
                            label: 'Booking ID',
                            value: booking.id,
                            valueColor: AppColors.textSecondary,
                          ),
                          InfoRow(
                            label: 'Collection',
                            value: Fmt.date(booking.slot),
                            valueColor: AppColors.textSecondary,
                          ),
                          InfoRow(
                            label: 'Time slot',
                            value: booking.slotTime.isEmpty
                                ? 'Not specified'
                                : booking.slotTime,
                            valueColor: AppColors.textSecondary,
                          ),
                          InfoRow(
                            label: 'Address',
                            value: booking.address,
                            valueColor: AppColors.textSecondary,
                          ),
                        ],
                      ),
                    ),
                  ],
                ],
              ),
            ),
          _SummaryCard(summary: summary, headline: service.headline(summary)),
          const SizedBox(height: AppSpacing.lg),
          Text('What this means for you',
              style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: AppSpacing.md),
          AppCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                for (final a in advice)
                  BulletPoint(
                    text: a,
                    icon: Icons.lightbulb_rounded,
                    color: AppColors.info,
                  ),
              ],
            ),
          ),
          const SizedBox(height: AppSpacing.lg),
          Row(
            children: [
              Flexible(
                child: Text('Detailed report',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: Theme.of(context).textTheme.titleMedium),
              ),
              const Spacer(),
              const AppBadge(
                label: 'Low · Normal · High',
                icon: Icons.legend_toggle_rounded,
                color: AppColors.textTertiary,
                dense: true,
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            'Each value is shown with its reference range. The green band is the '
            'normal range for that parameter.',
            style: Theme.of(context).textTheme.bodySmall,
          ),
          const SizedBox(height: AppSpacing.md),
          for (final t in tests) ...[
            _TestSection(test: t),
            const SizedBox(height: AppSpacing.lg),
          ],
          const NoticeBanner(
            color: AppColors.textTertiary,
            icon: Icons.medical_information_rounded,
            message:
                'Reference ranges vary slightly between laboratories, age groups '
                'and sexes. Always discuss your report with a doctor before '
                'starting any treatment.',
          ),
          if (!isSample && bookingId != null) ...[
            const SizedBox(height: AppSpacing.lg),
            OutlinedButton.icon(
              onPressed: () {
                context.read<LabProvider>().markReportReady(bookingId!);
                ScaffoldMessenger.of(context)
                  ..hideCurrentSnackBar()
                  ..showSnackBar(
                    const SnackBar(
                        content: Text('Report marked as ready')),
                  );
              },
              icon: const Icon(Icons.download_rounded, size: 18),
              label: const Text('Download report (PDF)'),
            ),
          ],
        ],
      ),
    );
  }
}

class _SummaryCard extends StatelessWidget {
  const _SummaryCard({required this.summary, required this.headline});

  final LabSummary summary;
  final String headline;

  @override
  Widget build(BuildContext context) {
    final color = summary.criticalCount > 0
        ? AppColors.danger
        : summary.abnormalCount > 0
            ? AppColors.warning
            : AppColors.success;

    return Container(
      padding: const EdgeInsets.all(AppSpacing.xl),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(AppRadius.lg),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                summary.isAllNormal
                    ? Icons.verified_rounded
                    : Icons.warning_amber_rounded,
                color: color,
                size: 22,
              ),
              const SizedBox(width: AppSpacing.sm),
              Expanded(
                child: Text(
                  headline,
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                    color: color,
                    height: 1.35,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.lg),
          Row(
            children: [
              _CountTile(
                label: 'Normal',
                count: summary.normalCount,
                color: AppColors.rangeNormal,
              ),
              _CountTile(
                label: 'Low',
                count: summary.lowCount,
                color: AppColors.rangeLow,
              ),
              _CountTile(
                label: 'High',
                count: summary.highCount,
                color: AppColors.rangeHigh,
              ),
              _CountTile(
                label: 'Critical',
                count: summary.criticalCount,
                color: AppColors.rangeCritical,
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _CountTile extends StatelessWidget {
  const _CountTile({
    required this.label,
    required this.count,
    required this.color,
  });

  final String label;
  final int count;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        margin: const EdgeInsets.only(right: AppSpacing.sm),
        padding: const EdgeInsets.symmetric(vertical: AppSpacing.md),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(AppRadius.md),
        ),
        child: Column(
          children: [
            Text(
              '$count',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w700,
                color: color,
              ),
            ),
            Text(
              label,
              style: TextStyle(
                fontSize: 10,
                color: color,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _TestSection extends StatelessWidget {
  const _TestSection({required this.test});

  final LabTest test;

  @override
  Widget build(BuildContext context) {
    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  color: test.accentColor.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(AppRadius.sm),
                ),
                child: Icon(test.icon, size: 17, color: test.accentColor),
              ),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: Text(
                  test.name,
                  style: const TextStyle(
                      fontSize: 14, fontWeight: FontWeight.w700),
                ),
              ),
              AppBadge(
                label: '${test.parameters.length} params',
                color: AppColors.textTertiary,
                dense: true,
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.lg),
          for (var i = 0; i < test.parameters.length; i++) ...[
            if (i > 0) const Divider(height: AppSpacing.xl),
            _ValueRow(range: test.parameters[i]),
          ],
        ],
      ),
    );
  }
}

class _ValueRow extends StatelessWidget {
  const _ValueRow({required this.range});

  final LabRange range;

  @override
  Widget build(BuildContext context) {
    final status = RangeStatus.of(range);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: Text(
                range.parameter,
                style: const TextStyle(
                    fontSize: 13.5, fontWeight: FontWeight.w600),
              ),
            ),
            Text(
              range.displayValue,
              style: TextStyle(
                fontSize: 13.5,
                fontWeight: FontWeight.w700,
                color: status.color,
              ),
            ),
          ],
        ),
        const SizedBox(height: AppSpacing.sm),
        NormalRangeBar(range: range, showLabel: false, showName: false),
      ],
    );
  }
}
