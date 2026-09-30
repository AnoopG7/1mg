import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_spacing.dart';
import '../../models/pregnancy_category.dart';

/// Small pill-shaped label used everywhere (Rx, OTC, discounts, categories).
class AppBadge extends StatelessWidget {
  const AppBadge({
    super.key,
    required this.label,
    this.icon,
    this.color = AppColors.primary,
    this.background,
    this.dense = false,
    this.borderColor,
  });

  final String label;
  final IconData? icon;
  final Color color;
  final Color? background;
  final bool dense;
  final Color? borderColor;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: dense ? 6 : 8,
        vertical: dense ? 2 : 4,
      ),
      decoration: BoxDecoration(
        color: background ?? color.withValues(alpha: 0.10),
        borderRadius: AppRadius.pillRadius,
        border: borderColor == null ? null : Border.all(color: borderColor!),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) ...[
            Icon(icon, size: dense ? 10 : 12, color: color),
            const SizedBox(width: 3),
          ],
          Text(
            label,
            style: TextStyle(
              color: color,
              fontSize: dense ? 10 : 11,
              fontWeight: FontWeight.w600,
              height: 1.2,
            ),
          ),
        ],
      ),
    );
  }
}

/// "Up to 50% off" style discount tag.
class DiscountBadge extends StatelessWidget {
  const DiscountBadge({super.key, required this.percent, this.large = false});

  final int percent;
  final bool large;

  @override
  Widget build(BuildContext context) {
    if (percent <= 0) return const SizedBox.shrink();
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: large ? 10 : 7,
        vertical: large ? 5 : 3,
      ),
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [Color(0xFF12A150), Color(0xFF0B8240)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: AppRadius.pillRadius,
      ),
      child: Text(
        '$percent% OFF',
        style: TextStyle(
          color: Colors.white,
          fontSize: large ? 12 : 10,
          fontWeight: FontWeight.w700,
          letterSpacing: 0.2,
        ),
      ),
    );
  }
}

/// "Doctor verified" badge for health articles.
class VerifiedBadge extends StatelessWidget {
  const VerifiedBadge({super.key, this.compact = false});

  final bool compact;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: compact ? 6 : 8,
        vertical: compact ? 3 : 4,
      ),
      decoration: BoxDecoration(
        color: AppColors.verifiedSurface,
        borderRadius: AppRadius.pillRadius,
        border: Border.all(color: AppColors.verified.withValues(alpha: 0.35)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(
            Icons.verified_rounded,
            size: 12,
            color: AppColors.verified,
          ),
          SizedBox(width: compact ? 3 : 4),
          Text(
            'Doctor verified',
            style: TextStyle(
              color: AppColors.verified,
              fontSize: compact ? 9.5 : 11,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}

/// 1mg Pro badge — gold on a dark surface.
class ProBadge extends StatelessWidget {
  const ProBadge({super.key, this.label = '1mg PRO', this.dense = false});

  final String label;
  final bool dense;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: dense ? 6 : 8,
        vertical: dense ? 2 : 4,
      ),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFFE8B84B), Color(0xFFC9922E)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: AppRadius.pillRadius,
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.workspace_premium_rounded,
            size: dense ? 10 : 13,
            color: Colors.white,
          ),
          SizedBox(width: dense ? 2 : 4),
          Text(
            label,
            style: TextStyle(
              color: Colors.white,
              fontSize: dense ? 9 : 11,
              fontWeight: FontWeight.w700,
              letterSpacing: 0.4,
            ),
          ),
        ],
      ),
    );
  }
}

/// Pregnancy safety rating A–X.
class PregnancyBadge extends StatelessWidget {
  const PregnancyBadge({
    super.key,
    required this.category,
    this.showDescription = false,
  });

  final PregnancyCategory category;
  final bool showDescription;

  @override
  Widget build(BuildContext context) {
    final Color color = category.color;
    final String label = category.label;
    final String desc = category.description;

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.md,
        vertical: AppSpacing.sm,
      ),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(AppRadius.md),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 28,
            height: 28,
            alignment: Alignment.center,
            decoration: BoxDecoration(color: color, shape: BoxShape.circle),
            child: Text(
              label,
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w700,
                fontSize: 14,
              ),
            ),
          ),
          const SizedBox(width: AppSpacing.sm),
          Flexible(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'Pregnancy category $label',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: color,
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                if (showDescription)
                  Text(
                    desc,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      color: color.withValues(alpha: 0.85),
                      fontSize: 11,
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

/// Severity pill for interactions and side effects.
class SeverityBadge extends StatelessWidget {
  const SeverityBadge({super.key, required this.label, required this.color});

  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return AppBadge(
      label: label,
      color: color,
      background: color.withValues(alpha: 0.12),
      dense: true,
    );
  }
}
