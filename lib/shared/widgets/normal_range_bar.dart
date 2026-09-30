import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_spacing.dart';
import '../../core/utils/formatters.dart';
import '../../models/lab_test.dart';

/// Visual indicator of a lab value against its normal reference range.
///
/// Renders a horizontal bar with a green "normal" band and a marker showing
/// where the measured value sits, plus a Low / Normal / High / Critical chip.
class NormalRangeBar extends StatelessWidget {
  const NormalRangeBar({
    super.key,
    required this.range,
    this.showLabel = true,
    this.showName = true,
  });

  final LabRange range;
  final bool showLabel;

  /// When false the parameter name row is hidden, letting the caller supply
  /// its own header (used by the report screen, which shows the value first).
  final bool showName;

  @override
  Widget build(BuildContext context) {
    final status = RangeStatus.of(range);
    final valuePos = range.normalizedPosition;
    final low = range.normalLow * 0.6;
    final high = range.normalHigh * 1.4;
    final barStart = range.bandStart;
    final barWidth = (range.bandEnd - range.bandStart).clamp(0.04, 1.0);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            if (showName)
              Expanded(
                child: Text(
                  range.parameter,
                  style: const TextStyle(
                    fontSize: 13.5,
                    fontWeight: FontWeight.w600,
                  ),
                ),
            )
            else
              const Spacer(),
            _StatusChip(label: status.label, color: status.color, icon: status.icon),
          ],
        ),
        const SizedBox(height: AppSpacing.sm),
        // The bar itself
        LayoutBuilder(
          builder: (context, constraints) {
            final width = constraints.maxWidth;
            return SizedBox(
              height: 30,
              child: Stack(
                children: [
                  // Track
                  Positioned.fill(
                    child: Container(
                      decoration: BoxDecoration(
                        color: AppColors.surfaceAlt,
                        borderRadius: AppRadius.pillRadius,
                      ),
                    ),
                  ),
                  // Normal band
                  Positioned(
                    left: barStart * width,
                    width: barWidth * width,
                    top: 0,
                    bottom: 0,
                    child: Container(
                      decoration: BoxDecoration(
                        color: AppColors.rangeNormal.withValues(alpha: 0.22),
                        borderRadius: BorderRadius.circular(AppRadius.pill),
                        border: Border.all(
                          color: AppColors.rangeNormal.withValues(alpha: 0.45),
                        ),
                      ),
                    ),
                  ),
                  // Value marker
                  Positioned(
                    left: (valuePos * width - 3).clamp(0.0, width - 6),
                    top: 0,
                    bottom: 0,
                    child: Container(
                      width: 6,
                      decoration: BoxDecoration(
                        color: status.color,
                        borderRadius: BorderRadius.circular(3),
                        boxShadow: [
                          BoxShadow(
                            color: status.color.withValues(alpha: 0.4),
                            blurRadius: 6,
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            );
          },
        ),
        const SizedBox(height: 5),
        Row(
          children: [
            Text(
              low.toStringAsFixed(low < 10 ? 1 : 0),
              style: const TextStyle(
                fontSize: 10.5,
                color: AppColors.textTertiary,
              ),
            ),
            const Spacer(),
            if (showLabel)
              Text(
                'Normal ${range.displayRange}',
                style: const TextStyle(
                  fontSize: 10.5,
                  color: AppColors.rangeNormal,
                  fontWeight: FontWeight.w600,
                ),
              ),
            const Spacer(),
            Text(
              high.toStringAsFixed(high < 10 ? 1 : 0),
              style: const TextStyle(
                fontSize: 10.5,
                color: AppColors.textTertiary,
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class _StatusChip extends StatelessWidget {
  const _StatusChip({
    required this.label,
    required this.color,
    required this.icon,
  });

  final String label;
  final Color color;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: AppRadius.pillRadius,
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 11, color: color),
          const SizedBox(width: 3),
          Text(
            label,
            style: TextStyle(
              fontSize: 10.5,
              fontWeight: FontWeight.w700,
              color: color,
            ),
          ),
        ],
      ),
    );
  }
}

/// Compact chart of a patient's weekly medicine adherence.
class AdherenceChart extends StatelessWidget {
  const AdherenceChart({super.key, required this.values});

  /// 7 values, 0–1.
  final List<double> values;

  static const List<String> _labels = ['M', 'T', 'W', 'T', 'F', 'S', 'S'];

  @override
  Widget build(BuildContext context) {
    final today = DateTime.now().weekday - 1; // 0 = Monday
    return SizedBox(
      height: 120,
      child: BarChart(
        BarChartData(
          maxY: 1.0,
          minY: 0.0,
          alignment: BarChartAlignment.spaceAround,
          gridData: FlGridData(
            show: true,
            drawVerticalLine: false,
            horizontalInterval: 0.5,
            getDrawingHorizontalLine: (_) => FlLine(
              color: AppColors.border,
              strokeWidth: 1,
              dashArray: [4, 4],
            ),
          ),
          borderData: FlBorderData(show: false),
          titlesData: FlTitlesData(
            topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
            rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
            leftTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
            bottomTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                reservedSize: 22,
                getTitlesWidget: (value, meta) {
                  final i = value.toInt();
                  if (i < 0 || i > 6) return const SizedBox.shrink();
                  final isToday = i == (6 - today);
                  return Padding(
                    padding: const EdgeInsets.only(top: 6),
                    child: Text(
                      _labels[i],
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight:
                            isToday ? FontWeight.w700 : FontWeight.w500,
                        color: isToday
                            ? AppColors.primary
                            : AppColors.textTertiary,
                      ),
                    ),
                  );
                },
              ),
            ),
          ),
          barTouchData: BarTouchData(
            touchTooltipData: BarTouchTooltipData(
              getTooltipColor: (_) => AppColors.textPrimary,
              getTooltipItem: (group, groupIndex, rod, rodIndex) {
                return BarTooltipItem(
                  '${(rod.toY * 100).round()}%',
                  const TextStyle(
                    color: Colors.white,
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                );
              },
            ),
          ),
          barGroups: List.generate(values.length, (i) {
            final v = values[i].clamp(0.0, 1.0);
            final isToday = i == 6 - today;
            return BarChartGroupData(
              x: i,
              barRods: [
                BarChartRodData(
                  toY: v,
                  width: 16,
                  borderRadius: const BorderRadius.vertical(
                    top: Radius.circular(4),
                  ),
                  color: isToday
                      ? AppColors.primary
                      : (v >= 0.99
                          ? AppColors.secondary
                          : AppColors.warning),
                ),
              ],
            );
          }),
        ),
      ),
    );
  }
}

/// Side-by-side MRP vs offer price comparison for lab bundles.
class PriceComparison extends StatelessWidget {
  const PriceComparison({
    super.key,
    required this.mrp,
    required this.offerPrice,
    this.compact = false,
  });

  final double mrp;
  final double offerPrice;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    final saving = mrp - offerPrice;
    final savingPercent = mrp <= 0 ? 0 : ((saving / mrp) * 100).round();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text(
              Fmt.money(offerPrice),
              style: TextStyle(
                fontSize: compact ? 17 : 24,
                fontWeight: FontWeight.w700,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(width: 6),
            Flexible(
              child: Padding(
                padding: EdgeInsets.only(bottom: compact ? 1 : 3),
                child: Text(
                  Fmt.money(mrp),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: compact ? 13 : 15,
                    color: AppColors.textTertiary,
                    decoration: TextDecoration.lineThrough,
                    decorationColor: AppColors.textTertiary,
                  ),
                ),
              ),
            ),
            const Spacer(),
            if (saving > 0)
              Flexible(
                child: Text(
                  'You save ${Fmt.money(saving)}',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: compact ? 11 : 12.5,
                    color: AppColors.success,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
          ],
        ),
        const SizedBox(height: 6),
        ClipRRect(
          borderRadius: BorderRadius.circular(3),
          child: SizedBox(
            height: 6,
            child: Stack(
              children: [
                Container(color: AppColors.surfaceAlt),
                FractionallySizedBox(
                  widthFactor:
                      mrp <= 0 ? 0 : (offerPrice / mrp).clamp(0.0, 1.0),
                  child: Container(color: AppColors.success),
                ),
              ],
            ),
          ),
        ),
        if (!compact) ...[
          const SizedBox(height: 6),
          Row(
            children: [
              Flexible(
                child: Text(
                  '$savingPercent% off on complete package',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 11.5,
                    color: AppColors.textSecondary,
                  ),
                ),
              ),
              const SizedBox(width: AppSpacing.sm),
              Flexible(
                child: Text(
                  'Individual tests: ${Fmt.money(mrp)}',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 11.5,
                    color: AppColors.textTertiary,
                  ),
                ),
              ),
            ],
          ),
        ],
      ],
    );
  }
}
