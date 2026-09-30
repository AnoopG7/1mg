import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_spacing.dart';
import 'badges.dart';

/// Bordered white card used as the base building block across the app.
class AppCard extends StatelessWidget {
  const AppCard({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(AppSpacing.lg),
    this.onTap,
    this.color,
    this.borderColor,
    this.borderRadius,
    this.shadow = false,
    this.margin,
  });

  final Widget child;
  final EdgeInsetsGeometry padding;
  final VoidCallback? onTap;
  final Color? color;
  final Color? borderColor;
  final BorderRadius? borderRadius;
  final bool shadow;
  final EdgeInsetsGeometry? margin;

  @override
  Widget build(BuildContext context) {
    final radius = borderRadius ?? AppRadius.cardRadius;

    // The card surface is a Material (not a decorated Container) so that
    // descendants like ListTile and CheckboxListTile resolve to it as their
    // nearest Material ancestor and their ink splashes stay visible.
    Widget inner = child;
    if (onTap != null) {
      inner = InkWell(onTap: onTap, borderRadius: radius, child: child);
    }

    Widget result = Material(
      type: MaterialType.canvas,
      color: color ?? AppColors.surface,
      shape: RoundedRectangleBorder(
        borderRadius: radius,
        side: BorderSide(color: borderColor ?? AppColors.border),
      ),
      clipBehavior: Clip.antiAlias,
      child: Padding(padding: padding, child: inner),
    );

    if (shadow) {
      result = Container(
        decoration: BoxDecoration(
          borderRadius: radius,
          boxShadow: AppShadows.card,
        ),
        child: result,
      );
    }

    if (margin != null) {
      result = Padding(padding: margin!, child: result);
    }

    return result;
  }
}

/// Section title with an optional "See all" action.
class SectionHeader extends StatelessWidget {
  const SectionHeader({
    super.key,
    required this.title,
    this.subtitle,
    this.actionLabel,
    this.onAction,
    this.icon,
    this.padding = const EdgeInsets.fromLTRB(
        AppSpacing.pageH, AppSpacing.xl, AppSpacing.pageH, AppSpacing.md),
  });

  final String title;
  final String? subtitle;
  final String? actionLabel;
  final VoidCallback? onAction;
  final IconData? icon;
  final EdgeInsetsGeometry padding;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: padding,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          if (icon != null) ...[
            Icon(icon, size: 18, color: AppColors.primary),
            const SizedBox(width: AppSpacing.sm),
          ],
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(title, style: Theme.of(context).textTheme.titleLarge),
                if (subtitle != null) ...[
                  const SizedBox(height: 2),
                  Text(
                    subtitle!,
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                ],
              ],
            ),
          ),
          if (actionLabel != null)
            TextButton(
              onPressed: onAction,
              child: Row(
                children: [
                  Text(actionLabel!),
                  const Icon(Icons.chevron_right_rounded, size: 18),
                ],
              ),
            ),
        ],
      ),
    );
  }
}

/// Simple pill-shaped filter chip row.
class FilterChipRow extends StatelessWidget {
  const FilterChipRow({
    super.key,
    required this.items,
    required this.selected,
    required this.onSelect,
    this.padding =
        const EdgeInsets.symmetric(horizontal: AppSpacing.pageH),
  });

  final List<String> items;
  final String selected;
  final ValueChanged<String> onSelect;
  final EdgeInsetsGeometry padding;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 36,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: padding,
        itemCount: items.length,
        separatorBuilder: (_, _) => const SizedBox(width: AppSpacing.sm),
        itemBuilder: (context, i) {
          final item = items[i];
          final isSelected = item == selected;
          return GestureDetector(
            onTap: () => onSelect(item),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 180),
              padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.lg,
                vertical: AppSpacing.sm,
              ),
              decoration: BoxDecoration(
                color: isSelected ? AppColors.primary : AppColors.surface,
                borderRadius: AppRadius.pillRadius,
                border: Border.all(
                  color: isSelected ? AppColors.primary : AppColors.border,
                ),
              ),
              child: Text(
                item,
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: isSelected ? Colors.white : AppColors.textSecondary,
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

/// Empty state with an icon, message and optional action.
class EmptyState extends StatelessWidget {
  const EmptyState({
    super.key,
    required this.icon,
    required this.title,
    required this.message,
    this.actionLabel,
    this.onAction,
    this.compact = false,
  });

  final IconData icon;
  final String title;
  final String message;
  final String? actionLabel;
  final VoidCallback? onAction;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: EdgeInsets.all(compact ? AppSpacing.xl : AppSpacing.xxxl),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: compact ? 56 : 76,
              height: compact ? 56 : 76,
              decoration: const BoxDecoration(
                color: AppColors.surfaceAlt,
                shape: BoxShape.circle,
              ),
              child: Icon(
                icon,
                size: compact ? 26 : 34,
                color: AppColors.textTertiary,
              ),
            ),
            SizedBox(height: compact ? AppSpacing.md : AppSpacing.lg),
            Text(
              title,
              textAlign: TextAlign.center,
              style: compact
                  ? Theme.of(context).textTheme.titleSmall
                  : Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: AppSpacing.xs),
            Text(
              message,
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodySmall,
            ),
            if (actionLabel != null) ...[
              const SizedBox(height: AppSpacing.lg),
              FilledButton(onPressed: onAction, child: Text(actionLabel!)),
            ],
          ],
        ),
      ),
    );
  }
}

/// Horizontal label + value row used in detail sections.
class InfoRow extends StatelessWidget {
  const InfoRow({
    super.key,
    required this.label,
    required this.value,
    this.valueColor,
    this.bold = false,
    this.icon,
  });

  final String label;
  final String value;
  final Color? valueColor;
  final bool bold;
  final IconData? icon;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (icon != null) ...[
            Icon(icon, size: 15, color: AppColors.textTertiary),
            const SizedBox(width: AppSpacing.sm),
          ],
          Expanded(
            flex: 4,
            child: Text(
              label,
              style: const TextStyle(
                fontSize: 13,
                color: AppColors.textTertiary,
              ),
            ),
          ),
          Expanded(
            flex: 6,
            child: Text(
              value,
              textAlign: TextAlign.right,
              style: TextStyle(
                fontSize: 13,
                fontWeight: bold ? FontWeight.w700 : FontWeight.w600,
                color: valueColor ?? AppColors.textPrimary,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Inline notice banner (info / warning / danger).
class NoticeBanner extends StatelessWidget {
  const NoticeBanner({
    super.key,
    required this.message,
    required this.color,
    this.icon = Icons.info_rounded,
    this.title,
    this.onTap,
  });

  final String message;
  final Color color;
  final IconData icon;
  final String? title;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.07),
        borderRadius: BorderRadius.circular(AppRadius.md),
        border: Border.all(color: color.withValues(alpha: 0.25)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 18, color: color),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (title != null) ...[
                  Text(
                    title!,
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                      color: color,
                    ),
                  ),
                  const SizedBox(height: 2),
                ],
                Text(
                  message,
                  style: TextStyle(
                    fontSize: 12.5,
                    height: 1.45,
                    color: AppColors.textPrimary.withValues(alpha: 0.85),
                  ),
                ),
              ],
            ),
          ),
          if (onTap != null)
            Icon(Icons.chevron_right_rounded, size: 18, color: color),
        ],
      ),
    );
  }
}

/// Bulleted list row with a coloured dot.
class BulletPoint extends StatelessWidget {
  const BulletPoint({
    super.key,
    required this.text,
    this.color = AppColors.primary,
    this.icon,
    this.iconColor,
  });

  final String text;
  final Color color;
  final IconData? icon;
  final Color? iconColor;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (icon != null)
            Padding(
              padding: const EdgeInsets.only(top: 1),
              child: Icon(icon, size: 16, color: iconColor ?? color),
            )
          else
            Container(
              margin: const EdgeInsets.only(top: 6, right: 10, left: 4),
              width: 6,
              height: 6,
              decoration: BoxDecoration(color: color, shape: BoxShape.circle),
            ),
          Expanded(
            child: Text(
              text,
              style: const TextStyle(
                fontSize: 13.5,
                height: 1.5,
                color: AppColors.textPrimary,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Shimmering placeholder block shown while content loads.
class SkeletonBox extends StatefulWidget {
  const SkeletonBox({
    super.key,
    this.width,
    this.height = 14,
    this.borderRadius = 6,
  });

  final double? width;
  final double height;
  final double borderRadius;

  @override
  State<SkeletonBox> createState() => _SkeletonBoxState();
}

class _SkeletonBoxState extends State<SkeletonBox>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 1200),
  )..repeat(reverse: true);

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, _) => Container(
        width: widget.width,
        height: widget.height,
        decoration: BoxDecoration(
          color: Color.lerp(
            AppColors.surfaceAlt,
            AppColors.border,
            _controller.value,
          ),
          borderRadius: BorderRadius.circular(widget.borderRadius),
        ),
      ),
    );
  }
}

/// Price block: struck-through MRP next to the selling price.
class PriceBlock extends StatelessWidget {
  const PriceBlock({
    super.key,
    required this.price,
    required this.mrp,
    this.size = 'md',
    this.color,
  });

  final double price;
  final double mrp;
  final String size;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    final big = size == 'lg';
    final showMrp = mrp > price;
    return Row(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.baseline,
      textBaseline: TextBaseline.alphabetic,
      children: [
        Text(
          '₹${price.toStringAsFixed(0)}',
          style: TextStyle(
            fontSize: big ? 22 : 15,
            fontWeight: FontWeight.w700,
            color: color ?? AppColors.textPrimary,
          ),
        ),
        if (showMrp) ...[
          const SizedBox(width: 6),
          Text(
            '₹${mrp.toStringAsFixed(0)}',
            style: TextStyle(
              fontSize: big ? 15 : 12,
              color: AppColors.textTertiary,
              decoration: TextDecoration.lineThrough,
              decorationColor: AppColors.textTertiary,
            ),
          ),
        ],
      ],
    );
  }
}

/// Gold-bordered card used to advertise 1mg Pro upsell.
class ProPromoCard extends StatelessWidget {
  const ProPromoCard({
    super.key,
    required this.title,
    required this.subtitle,
    this.onTap,
  });

  final String title;
  final String subtitle;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppRadius.lg),
        child: Ink(
          padding: const EdgeInsets.all(AppSpacing.lg),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [AppColors.proDark, AppColors.proDarkAlt],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(AppRadius.lg),
          ),
          child: Row(
            children: [
              Container(
                width: 42,
                height: 42,
                decoration: const BoxDecoration(
                  color: Color(0x33FFFFFF),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.workspace_premium_rounded,
                  color: Color(0xFFE8C46A),
                  size: 22,
                ),
              ),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Flexible(
                          child: Text(
                            title,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 14.5,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                        const SizedBox(width: 6),
                        const ProBadge(dense: true),
                      ],
                    ),
                    const SizedBox(height: 2),
                    Text(
                      subtitle,
                      style: const TextStyle(
                        color: AppColors.proText,
                        fontSize: 12,
                        height: 1.35,
                      ),
                    ),
                  ],
                ),
              ),
              const Icon(Icons.chevron_right_rounded, color: Colors.white54),
            ],
          ),
        ),
      ),
    );
  }
}
