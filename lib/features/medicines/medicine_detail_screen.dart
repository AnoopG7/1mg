import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_spacing.dart';
import '../../core/utils/formatters.dart';
import '../../models/drug_interaction.dart';
import '../../models/medicine.dart';
import '../../models/pregnancy_category.dart';
import '../../providers/cart_provider.dart';
import '../../providers/pro_provider.dart';
import '../../providers/reminder_provider.dart';
import '../../providers/saved_provider.dart';
import '../../shared/widgets/badges.dart';
import '../../shared/widgets/common.dart';
import '../home/home_screen.dart' show PillVisual;
import '../interactions/interaction_checker_screen.dart';
import '../reminders/add_reminder_screen.dart';
import 'medicine_list_screen.dart' show CartSeed;

/// Full medicine information: composition, uses, side effects, interactions,
/// pregnancy safety and storage instructions.
class MedicineDetailScreen extends StatelessWidget {
  const MedicineDetailScreen({super.key, required this.medicine});

  final Medicine medicine;

  @override
  Widget build(BuildContext context) {
    final pro = context.watch<ProProvider>();
    final saved = context.watch<SavedProvider>();
    final price = pro.isPro ? medicine.price * 0.95 : medicine.price;

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          _DetailAppBar(medicine: medicine, saved: saved),
          SliverToBoxAdapter(child: _Header(medicine: medicine, price: price)),
          SliverToBoxAdapter(child: _PregnancySection(medicine: medicine)),
          SliverToBoxAdapter(child: _CompositionSection(medicine: medicine)),
          SliverToBoxAdapter(child: _UsesSection(medicine: medicine)),
          SliverToBoxAdapter(child: _SideEffectsSection(medicine: medicine)),
          SliverToBoxAdapter(child: _InteractionsSection(medicine: medicine)),
          SliverToBoxAdapter(child: _StorageSection(medicine: medicine)),
          const SliverToBoxAdapter(child: _Disclaimer()),
          SliverToBoxAdapter(
            child: SizedBox(
              height: 90 + MediaQuery.of(context).padding.bottom,
            ),
          ),
        ],
      ),
      bottomNavigationBar: _AddToCartBar(medicine: medicine, price: price),
    );
  }
}

class _DetailAppBar extends StatelessWidget {
  const _DetailAppBar({required this.medicine, required this.saved});

  final Medicine medicine;
  final SavedProvider saved;

  @override
  Widget build(BuildContext context) {
    return SliverAppBar(
      pinned: true,
      expandedHeight: 190,
      backgroundColor: AppColors.surface,
      actions: [
        IconButton(
          onPressed: () => saved.toggleMedicine(medicine.id),
          icon: Icon(
            saved.isMedicineSaved(medicine.id)
                ? Icons.bookmark_rounded
                : Icons.bookmark_border_rounded,
            color: saved.isMedicineSaved(medicine.id)
                ? AppColors.primary
                : AppColors.textPrimary,
          ),
        ),
        IconButton(
          onPressed: () {
            ScaffoldMessenger.of(context)
              ..hideCurrentSnackBar()
              ..showSnackBar(
                SnackBar(
                  content: Text('Link copied for ${medicine.name}'),
                ),
              );
          },
          icon: const Icon(Icons.ios_share_rounded),
        ),
      ],
      flexibleSpace: FlexibleSpaceBar(
        background: Container(
          color: Color(medicine.pillColor),
          alignment: Alignment.center,
          child: PillVisual(medicine: medicine, size: 120),
        ),
      ),
    );
  }
}

class _Header extends StatelessWidget {
  const _Header({required this.medicine, required this.price});

  final Medicine medicine;
  final double price;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(
          AppSpacing.pageH, AppSpacing.lg, AppSpacing.pageH, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  medicine.name,
                  style: Theme.of(context).textTheme.headlineSmall,
                ),
              ),
              if (medicine.rx)
                const AppBadge(
                  label: 'Prescription only',
                  icon: Icons.medical_information_rounded,
                  color: AppColors.info,
                )
              else
                const AppBadge(
                  label: 'Over the counter',
                  icon: Icons.storefront_rounded,
                  color: AppColors.success,
                ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            '${medicine.genericName} · ${medicine.strength} · ${medicine.form}',
            style: Theme.of(context).textTheme.bodyMedium,
          ),
          const SizedBox(height: 2),
          Text(
            'Manufactured by ${medicine.manufacturer}',
            style: Theme.of(context).textTheme.bodySmall,
          ),
          const SizedBox(height: AppSpacing.md),
          Row(
            children: [
              const Icon(Icons.star_rounded, size: 16, color: AppColors.warning),
              const SizedBox(width: 4),
              Text(
                '${medicine.rating}',
                style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 13),
              ),
              Text(
                '  ·  ${Fmt.compact(medicine.reviewCount)} ratings',
                style: const TextStyle(fontSize: 12, color: AppColors.textTertiary),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.lg),
          Container(
            padding: const EdgeInsets.all(AppSpacing.lg),
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(AppRadius.lg),
              border: Border.all(color: AppColors.border),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      Fmt.money(price),
                      style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    if (medicine.mrp > price) ...[
                      const SizedBox(width: AppSpacing.sm),
                      Text(
                        Fmt.money(medicine.mrp),
                        style: const TextStyle(
                          fontSize: 14,
                          color: AppColors.textTertiary,
                          decoration: TextDecoration.lineThrough,
                        ),
                      ),
                      const SizedBox(width: AppSpacing.sm),
                      DiscountBadge(percent: medicine.discountPercent),
                    ],
                  ],
                ),
                Text(
                  'Inclusive of all taxes',
                  style: Theme.of(context).textTheme.bodySmall,
                ),
                const SizedBox(height: AppSpacing.md),
                Text(
                  medicine.description,
                  style: const TextStyle(fontSize: 13.5, height: 1.55),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _PregnancySection extends StatelessWidget {
  const _PregnancySection({required this.medicine});

  final Medicine medicine;

  @override
  Widget build(BuildContext context) {
    final c = medicine.pregnancyCategory;

    return _Section(
      title: 'Pregnancy & breastfeeding safety',
      icon: Icons.pregnant_woman_rounded,
      children: [
        PregnancyBadge(category: c, showDescription: true),
        const SizedBox(height: AppSpacing.md),
        const Text(
          'All five FDA-style categories',
          style: TextStyle(fontSize: 11.5, fontWeight: FontWeight.w700),
        ),
        const SizedBox(height: AppSpacing.sm),
        Row(
          children: [
            for (final cat in PregnancyCategory.values)
              Expanded(
                child: Container(
                  margin: const EdgeInsets.only(right: 4),
                  padding: const EdgeInsets.symmetric(vertical: 6),
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: cat == c
                        ? cat.color
                        : cat.color.withValues(alpha: 0.10),
                    borderRadius: BorderRadius.circular(AppRadius.sm),
                  ),
                  child: Text(
                    cat.label,
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                      color: cat == c ? Colors.white : cat.color,
                    ),
                  ),
                ),
              ),
          ],
        ),
        const SizedBox(height: AppSpacing.md),
        NoticeBanner(
          color: medicine.lactationSafe ? AppColors.success : AppColors.warning,
          icon: Icons.child_friendly_rounded,
          title: medicine.lactationSafe
              ? 'Safe while breastfeeding'
              : 'Avoid while breastfeeding',
          message: medicine.lactationSafe
              ? 'Limited data suggests no adverse effect on the nursing infant. '
                  'Always confirm with your doctor.'
              : 'This medicine may pass into breast milk and can affect the '
                  'infant. Ask your doctor for a safer alternative.',
        ),
        const SizedBox(height: AppSpacing.sm),
        Text(
          'Always discuss any medicine with your obstetrician before taking it, '
          'especially during the first and third trimesters.',
          style: Theme.of(context).textTheme.bodySmall,
        ),
      ],
    );
  }
}

class _CompositionSection extends StatelessWidget {
  const _CompositionSection({required this.medicine});

  final Medicine medicine;

  @override
  Widget build(BuildContext context) {
    return _Section(
      title: 'Composition',
      icon: Icons.science_rounded,
      children: [
        for (final ing in medicine.composition)
          Container(
            margin: const EdgeInsets.only(bottom: AppSpacing.sm),
            padding: const EdgeInsets.all(AppSpacing.md),
            decoration: BoxDecoration(
              color: AppColors.surfaceAlt,
              borderRadius: BorderRadius.circular(AppRadius.md),
            ),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        ing.name,
                        style: const TextStyle(
                          fontSize: 13.5,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      Text(
                        ing.role,
                        style: const TextStyle(
                          fontSize: 11,
                          color: AppColors.textTertiary,
                        ),
                      ),
                    ],
                  ),
                ),
                Text(
                  ing.strengthPerDose,
                  style: const TextStyle(
                    fontSize: 13.5,
                    fontWeight: FontWeight.w700,
                    color: AppColors.primary,
                  ),
                ),
              ],
            ),
          ),
      ],
    );
  }
}

class _UsesSection extends StatelessWidget {
  const _UsesSection({required this.medicine});

  final Medicine medicine;

  @override
  Widget build(BuildContext context) {
    return _Section(
      title: 'What it is used for',
      icon: Icons.help_outline_rounded,
      children: [
        for (final use in medicine.uses)
          BulletPoint(text: use, icon: Icons.check_circle_rounded,
              color: AppColors.success),
      ],
    );
  }
}

class _SideEffectsSection extends StatelessWidget {
  const _SideEffectsSection({required this.medicine});

  final Medicine medicine;

  @override
  Widget build(BuildContext context) {
    if (medicine.sideEffects.isEmpty) {
      return _Section(
        title: 'Side effects',
        icon: Icons.warning_amber_rounded,
        children: const [
          NoticeBanner(
            color: AppColors.success,
            icon: Icons.check_circle_rounded,
            message: 'No commonly reported side effects for this medicine.',
          ),
        ],
      );
    }

    return _Section(
      title: 'Side effects',
      icon: Icons.warning_amber_rounded,
      children: [
        for (final se in medicine.sideEffects)
          Padding(
            padding: const EdgeInsets.only(bottom: AppSpacing.sm),
            child: Row(
              children: [
                Container(
                  width: 6,
                  height: 6,
                  decoration: BoxDecoration(
                    color: se.severity.color,
                    shape: BoxShape.circle,
                  ),
                ),
                const SizedBox(width: AppSpacing.md),
                Expanded(
                  child: Text(se.name, style: const TextStyle(fontSize: 13.5)),
                ),
                Text(
                  se.frequency,
                  style: const TextStyle(fontSize: 11, color: AppColors.textTertiary),
                ),
                const SizedBox(width: AppSpacing.sm),
                SeverityBadge(
                  label: se.severity.label,
                  color: se.severity.color,
                ),
              ],
            ),
          ),
        const SizedBox(height: AppSpacing.sm),
        NoticeBanner(
          color: AppColors.info,
          icon: Icons.info_rounded,
          message:
              'Side effects vary from person to person. Stop the medicine and '
              'contact your doctor if you develop a severe reaction.',
        ),
      ],
    );
  }
}

class _InteractionsSection extends StatelessWidget {
  const _InteractionsSection({required this.medicine});

  final Medicine medicine;

  @override
  Widget build(BuildContext context) {
    final byType = <String, List<DrugInteraction>>{};
    for (final i in medicine.interactions) {
      byType.putIfAbsent(i.type.label, () => []).add(i);
    }

    return _Section(
      title: 'Interactions',
      icon: Icons.warning_rounded,
      trailing: TextButton.icon(
        onPressed: () => Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const InteractionCheckerScreen()),
        ),
        icon: const Icon(Icons.compare_arrows_rounded, size: 16),
        label: const Text('Check'),
      ),
      children: [
        for (final entry in byType.entries) ...[
          Padding(
            padding: const EdgeInsets.only(top: AppSpacing.sm),
            child: Text(
              entry.key,
              style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700),
            ),
          ),
          const SizedBox(height: AppSpacing.sm),
          for (final i in entry.value)
            Container(
              margin: const EdgeInsets.only(bottom: AppSpacing.sm),
              padding: const EdgeInsets.all(AppSpacing.md),
              decoration: BoxDecoration(
                color: i.severity.color.withValues(alpha: 0.05),
                borderRadius: BorderRadius.circular(AppRadius.md),
                border: Border.all(
                  color: i.severity.color.withValues(alpha: 0.22),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(i.type.icon, size: 15, color: i.severity.color),
                      const SizedBox(width: AppSpacing.sm),
                      Expanded(
                        child: Text(
                          i.displayName,
                          style: const TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                      SeverityBadge(
                        label: i.severity.label,
                        color: i.severity.color,
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Text(
                    i.note,
                    style: const TextStyle(
                      fontSize: 12.5,
                      height: 1.5,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
        ],
        if (medicine.interactions.isEmpty)
          const NoticeBanner(
            color: AppColors.success,
            icon: Icons.check_circle_rounded,
            message: 'No documented food, alcohol or medicine interactions.',
          ),
      ],
    );
  }
}

class _StorageSection extends StatelessWidget {
  const _StorageSection({required this.medicine});

  final Medicine medicine;

  @override
  Widget build(BuildContext context) {
    final s = medicine.storage;

    return _Section(
      title: 'Storage instructions',
      icon: s.icon,
      children: [
        Container(
          padding: const EdgeInsets.all(AppSpacing.lg),
          decoration: BoxDecoration(
            color: s.isRefrigerated
                ? AppColors.infoSurface
                : AppColors.secondarySurface,
            borderRadius: BorderRadius.circular(AppRadius.md),
          ),
          child: Column(
            children: [
              Row(
                children: [
                  Icon(s.icon,
                      size: 22,
                      color: s.isRefrigerated
                          ? AppColors.info
                          : AppColors.secondary),
                  const SizedBox(width: AppSpacing.md),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          s.temperatureRange,
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        Text(
                          s.light,
                          style: const TextStyle(
                            fontSize: 11.5,
                            color: AppColors.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  ),
                  if (s.isRefrigerated)
                    const AppBadge(
                      label: 'Refrigerated',
                      color: AppColors.info,
                      dense: true,
                    ),
                ],
              ),
              const Divider(height: AppSpacing.xl),
              InfoRow(label: 'Humidity', value: s.humidity, icon: Icons.water_drop_outlined),
              InfoRow(
                label: 'Light',
                value: s.light,
                icon: Icons.wb_sunny_outlined,
              ),
            ],
          ),
        ),
        const SizedBox(height: AppSpacing.md),
        Text(
          s.instructions,
          style: const TextStyle(fontSize: 13, height: 1.55),
        ),
        const SizedBox(height: AppSpacing.md),
        Row(
          children: [
            Expanded(
              child: _StorageTip(
                icon: Icons.kitchen_rounded,
                text: 'Keep out of the kitchen and bathroom — heat and humidity '
                    'degrade most tablets.',
              ),
            ),
            const SizedBox(width: AppSpacing.sm),
            Expanded(
              child: _StorageTip(
                icon: Icons.child_care_rounded,
                text: 'Always store above the reach and sight of children.',
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class _StorageTip extends StatelessWidget {
  const _StorageTip({required this.icon, required this.text});

  final IconData icon;
  final String text;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: AppColors.surfaceAlt,
        borderRadius: BorderRadius.circular(AppRadius.md),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 18, color: AppColors.textSecondary),
          const SizedBox(height: 6),
          Text(
            text,
            style: const TextStyle(
              fontSize: 11,
              height: 1.4,
              color: AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }
}

class _Disclaimer extends StatelessWidget {
  const _Disclaimer();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(
          AppSpacing.pageH, 0, AppSpacing.pageH, AppSpacing.lg),
      child: NoticeBanner(
        color: AppColors.textTertiary,
        icon: Icons.info_rounded,
        message:
            'This information is for reference only and does not replace advice '
            'from a qualified doctor or pharmacist. Always check the package '
            'insert before taking any medicine.',
      ),
    );
  }
}

class _Section extends StatelessWidget {
  const _Section({
    required this.title,
    required this.icon,
    required this.children,
    this.trailing,
  });

  final String title;
  final IconData icon;
  final List<Widget> children;
  final Widget? trailing;

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
                child: Text(
                  title,
                  style: const TextStyle(
                    fontSize: 15.5,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              ?trailing,
            ],
          ),
          const SizedBox(height: AppSpacing.md),
          ...children,
        ],
      ),
    );
  }
}

class _AddToCartBar extends StatelessWidget {
  const _AddToCartBar({required this.medicine, required this.price});

  final Medicine medicine;
  final double price;

  @override
  Widget build(BuildContext context) {
    final cart = context.watch<CartProvider>();
    final reminders = context.watch<ReminderProvider>();
    final inCart = cart.contains(medicine.id);

    return Container(
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
                    style: const TextStyle(
                        fontSize: 17, fontWeight: FontWeight.w700)),
                Text(
                  inCart
                      ? '${cart.itemById(medicine.id)?.quantity} in cart'
                      : 'Free delivery above ₹399',
                  style: const TextStyle(
                      fontSize: 10.5, color: AppColors.textTertiary),
                ),
              ],
            ),
          ),
          OutlinedButton.icon(
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => AddReminderScreen(medicine: medicine),
              ),
            ),
            style: OutlinedButton.styleFrom(
              minimumSize: const Size(0, 46),
              padding: const EdgeInsets.symmetric(horizontal: 14),
            ),
            icon: const Icon(Icons.alarm_add_rounded, size: 18),
            label: const Text('Remind'),
          ),
          const SizedBox(width: AppSpacing.sm),
          FilledButton(
            onPressed: () {
              cart.add(CartSeed.medicine(medicine, price));
              final items = reminders.totalActive;
              ScaffoldMessenger.of(context)
                ..hideCurrentSnackBar()
                ..showSnackBar(
                  SnackBar(
                    content: Text(
                        '${medicine.name} added to cart · $items active reminders'),
                  ),
                );
            },
            style: FilledButton.styleFrom(
              minimumSize: const Size(0, 46),
              padding: const EdgeInsets.symmetric(horizontal: 20),
            ),
            child: Text(inCart ? 'Add more' : 'Add to cart'),
          ),
        ],
      ),
    );
  }
}
