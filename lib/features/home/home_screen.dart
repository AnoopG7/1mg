import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_spacing.dart';
import '../../core/utils/formatters.dart';
import '../../data/mock_articles.dart';
import '../../data/mock_labs.dart';
import '../../data/mock_medicines.dart';
import '../../models/medicine.dart';
import '../../providers/profile_provider.dart';
import '../../providers/pro_provider.dart';
import '../../providers/reminder_provider.dart';
import '../../providers/saved_provider.dart';
import '../../shared/widgets/badges.dart';
import '../../shared/widgets/common.dart';
import '../articles/article_detail_screen.dart';
import '../interactions/interaction_checker_screen.dart';
import '../labs/lab_test_detail_screen.dart';
import '../medicines/medicine_detail_screen.dart';
import '../medicines/medicine_list_screen.dart';
import '../pro/pro_screen.dart';
import '../reminders/pill_scan_screen.dart';
import '../articles/articles_screen.dart';
import '../labs/labs_screen.dart';
import '../symptom_checker/symptom_checker_screen.dart';
import '../../shared/widgets/brand_mark.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final pro = context.watch<ProProvider>();
    final reminders = context.watch<ReminderProvider>();
    final saved = context.watch<SavedProvider>();

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          const SliverToBoxAdapter(child: _TopBar()),
          const SliverToBoxAdapter(child: _SearchBar()),
          const SliverToBoxAdapter(child: _QuickActions()),
          if (!pro.isPro)
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(
                  AppSpacing.pageH,
                  AppSpacing.lg,
                  AppSpacing.pageH,
                  0,
                ),
                child: ProPromoCard(
                  title: 'Get 1mg Pro',
                  subtitle: '₹499/year — extra 5% off, priority delivery & free consultations',
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const ProScreen()),
                  ),
                ),
              ),
            ),
          if (reminders.today.isNotEmpty)
            SliverToBoxAdapter(child: _TodayReminders(reminders: reminders)),
          const SliverToBoxAdapter(
            child: SectionHeader(
              title: 'Shop by concern',
              subtitle: 'Popular categories this week',
            ),
          ),
          const SliverToBoxAdapter(child: _CategoryGrid()),
          SliverToBoxAdapter(
            child: SectionHeader(
              title: 'Top medicines',
              subtitle: 'Most searched this week',
              actionLabel: 'See all',
              onAction: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const MedicineListScreen()),
              ),
            ),
          ),
          const SliverToBoxAdapter(child: _TopMedicines()),
          const SliverToBoxAdapter(
            child: SectionHeader(
              title: 'Health packages',
              subtitle: 'Up to 50% off on complete checkups',
            ),
          ),
          const SliverToBoxAdapter(child: _BundleStrip()),
          SliverToBoxAdapter(
            child: SectionHeader(
              title: 'Doctor-verified articles',
              subtitle: 'Written and reviewed by specialists',
              actionLabel: 'See all',
              onAction: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const ArticlesScreen()),
              ),
            ),
          ),
          const SliverToBoxAdapter(child: _ArticleStrip()),
          if (saved.medicineIds.isNotEmpty) ...[
            const SliverToBoxAdapter(
              child: SectionHeader(title: 'Saved by you'),
            ),
            SliverToBoxAdapter(child: _SavedStrip(savedIds: saved.medicineIds)),
          ],
          const SliverToBoxAdapter(child: _TrustFooter()),
        ],
      ),
    );
  }
}

class _TopBar extends StatelessWidget {
  const _TopBar();

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      bottom: false,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(
          AppSpacing.pageH,
          AppSpacing.md,
          AppSpacing.pageH,
          AppSpacing.sm,
        ),
        child: Row(
          children: [
            const Expanded(child: BrandLockup()),
            IconButton(
              tooltip: 'Scan a pill',
              onPressed: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const PillScanScreen()),
              ),
              icon: const Icon(Icons.center_focus_strong_rounded),
            ),
            Container(
              width: 36,
              height: 36,
              alignment: Alignment.center,
              decoration: const BoxDecoration(
                color: AppColors.secondarySurface,
                shape: BoxShape.circle,
              ),
              child: Text(
                context.select<ProfileProvider, String>(
                  (p) => p.profile.initials,
                ),
                style: const TextStyle(
                  color: AppColors.secondary,
                  fontWeight: FontWeight.w700,
                  fontSize: 13,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SearchBar extends StatelessWidget {
  const _SearchBar();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.pageH,
        AppSpacing.sm,
        AppSpacing.pageH,
        0,
      ),
      child: GestureDetector(
        onTap: () => Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const MedicineListScreen()),
        ),
        child: AbsorbPointer(
          child: TextField(
            decoration: InputDecoration(
              hintText: 'Search medicines, composition or uses',
              prefixIcon: const Icon(Icons.search_rounded),
              suffixIcon: Container(
                margin: const EdgeInsets.all(6),
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: AppColors.primarySurface,
                  borderRadius: BorderRadius.circular(AppRadius.sm),
                ),
                padding: const EdgeInsets.symmetric(horizontal: 8),
                child: const Icon(
                  Icons.search_rounded,
                  color: AppColors.primary,
                  size: 18,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _QuickActions extends StatelessWidget {
  const _QuickActions();

  @override
  Widget build(BuildContext context) {
    final actions = [
      (
        'Symptom\nChecker',
        Icons.medical_information_rounded,
        const Color(0xFFDC2F2F),
        const SymptomCheckerScreen(),
      ),
      (
        'Interaction\nChecker',
        Icons.warning_amber_rounded,
        const Color(0xFFF2721C),
        const InteractionCheckerScreen(),
      ),
      (
        'Lab Tests',
        Icons.biotech_rounded,
        AppColors.purple,
        const LabsScreen(),
      ),
      (
        'Articles',
        Icons.menu_book_rounded,
        AppColors.secondary,
        const ArticlesScreen(),
      ),
    ];

    return Padding(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.pageH,
        AppSpacing.lg,
        AppSpacing.pageH,
        0,
      ),
      child: Row(
        children: [
          for (final a in actions) ...[
            Expanded(
              child: GestureDetector(
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => a.$4),
                ),
                child: Container(
                  padding: const EdgeInsets.symmetric(vertical: AppSpacing.md),
                  decoration: BoxDecoration(
                    color: AppColors.surface,
                    borderRadius: BorderRadius.circular(AppRadius.md),
                    border: Border.all(color: AppColors.border),
                  ),
                  child: Column(
                    children: [
                      Container(
                        width: 38,
                        height: 38,
                        decoration: BoxDecoration(
                          color: a.$3.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(AppRadius.sm),
                        ),
                        child: Icon(a.$2, size: 20, color: a.$3),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        a.$1,
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          fontSize: 10.5,
                          fontWeight: FontWeight.w600,
                          height: 1.25,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            if (a != actions.last) const SizedBox(width: AppSpacing.sm),
          ],
        ],
      ),
    );
  }
}

class _TodayReminders extends StatelessWidget {
  const _TodayReminders({required this.reminders});

  final ReminderProvider reminders;

  @override
  Widget build(BuildContext context) {
    final taken = reminders.dosesTakenToday;
    final due = reminders.dosesDueToday;

    return Padding(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.pageH,
        AppSpacing.lg,
        AppSpacing.pageH,
        0,
      ),
      child: AppCard(
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(
                  Icons.alarm_rounded,
                  size: 18,
                  color: AppColors.secondary,
                ),
                const SizedBox(width: AppSpacing.sm),
                Expanded(
                  child: Text(
                    'Today\'s medicines',
                    style: Theme.of(context).textTheme.titleSmall,
                  ),
                ),
                Text(
                  '$taken / $due taken',
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    color: AppColors.secondary,
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.md),
            for (final r in reminders.today.take(3))
              Padding(
                padding: const EdgeInsets.only(bottom: AppSpacing.sm),
                child: Row(
                  children: [
                    Container(
                      width: 6,
                      height: 6,
                      decoration: const BoxDecoration(
                        color: AppColors.secondary,
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: AppSpacing.sm),
                    Expanded(
                      child: Text(
                        '${r.medicineName} · ${r.dosage}',
                        style: const TextStyle(fontSize: 13),
                      ),
                    ),
                    Text(
                      r.nextDoseLabel,
                      style: const TextStyle(
                        fontSize: 11.5,
                        color: AppColors.textTertiary,
                      ),
                    ),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _CategoryGrid extends StatelessWidget {
  const _CategoryGrid();

  @override
  Widget build(BuildContext context) {
    final cats = MedicineCategory.all.take(8).toList();
    return SizedBox(
      height: 96,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: AppSpacing.pageH),
        itemCount: cats.length,
        separatorBuilder: (_, _) => const SizedBox(width: AppSpacing.md),
        itemBuilder: (context, i) {
          final c = cats[i];
          return GestureDetector(
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => MedicineListScreen(initialCategory: c.name),
              ),
            ),
            child: SizedBox(
              width: 64,
              child: Column(
                children: [
                  Container(
                    width: 56,
                    height: 56,
                    decoration: BoxDecoration(
                      color: AppColors.surface,
                      borderRadius: BorderRadius.circular(AppRadius.lg),
                      border: Border.all(color: AppColors.border),
                    ),
                    child: Icon(c.icon, size: 24, color: AppColors.primary),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    c.name,
                    textAlign: TextAlign.center,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 10.5,
                      fontWeight: FontWeight.w500,
                      height: 1.2,
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}

class _TopMedicines extends StatelessWidget {
  const _TopMedicines();

  @override
  Widget build(BuildContext context) {
    final meds = MockMedicines.all.take(6).toList();
    final pro = context.watch<ProProvider>();

    return SizedBox(
      height: 176,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: AppSpacing.pageH),
        itemCount: meds.length,
        separatorBuilder: (_, _) => const SizedBox(width: AppSpacing.md),
        itemBuilder: (context, i) {
          final m = meds[i];
          final price = pro.isPro ? m.price * 0.95 : m.price;
          return SizedBox(
            width: 150,
            child: AppCard(
              padding: const EdgeInsets.all(AppSpacing.md),
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => MedicineDetailScreen(medicine: m),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      PillVisual(medicine: m, size: 34),
                      const Spacer(),
                      if (pro.isPro)
                        const ProBadge(dense: true)
                      else if (m.discountPercent > 0)
                        DiscountBadge(percent: m.discountPercent),
                    ],
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  Text(
                    m.name,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  Text(
                    '${m.genericName} ${m.strength}',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 10.5,
                      color: AppColors.textTertiary,
                    ),
                  ),
                  const Spacer(),
                  Row(
                    children: [
                      Text(
                        Fmt.money(price),
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(width: 5),
                      if (m.mrp > price)
                        Text(
                          Fmt.money(m.mrp),
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
          );
        },
      ),
    );
  }
}

class _BundleStrip extends StatelessWidget {
  const _BundleStrip();

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 158,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: AppSpacing.pageH),
        itemCount: MockLabs.bundles.length,
        separatorBuilder: (_, _) => const SizedBox(width: AppSpacing.md),
        itemBuilder: (context, i) {
          final b = MockLabs.bundles[i];
          return SizedBox(
            width: 250,
            child: AppCard(
              padding: const EdgeInsets.all(AppSpacing.md),
              color: b.accentColor.withValues(alpha: 0.06),
              borderColor: b.accentColor.withValues(alpha: 0.25),
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => LabTestDetailScreen(bundle: b),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      DiscountBadge(percent: b.discountPercent),
                      const SizedBox(width: 6),
                      Expanded(
                        child: Text(
                          b.badge,
                          style: const TextStyle(
                            fontSize: 10.5,
                            color: AppColors.textTertiary,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  Text(
                    b.name,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 13.5,
                      fontWeight: FontWeight.w700,
                      height: 1.3,
                    ),
                  ),
                  Text(
                    '${b.testIds.length} tests included',
                    style: const TextStyle(
                      fontSize: 10.5,
                      color: AppColors.textTertiary,
                    ),
                  ),
                  const Spacer(),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        Fmt.money(b.offerPrice),
                        style: TextStyle(
                          fontSize: 17,
                          fontWeight: FontWeight.w700,
                          color: b.accentColor,
                        ),
                      ),
                      const SizedBox(width: 5),
                      Padding(
                        padding: const EdgeInsets.only(bottom: 2),
                        child: Text(
                          Fmt.money(b.mrp),
                          style: const TextStyle(
                            fontSize: 11,
                            color: AppColors.textTertiary,
                            decoration: TextDecoration.lineThrough,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}

class _ArticleStrip extends StatelessWidget {
  const _ArticleStrip();

  @override
  Widget build(BuildContext context) {
    final articles = MockArticles.all.take(5).toList();
    return SizedBox(
      height: 200,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: AppSpacing.pageH),
        itemCount: articles.length,
        separatorBuilder: (_, _) => const SizedBox(width: AppSpacing.md),
        itemBuilder: (context, i) {
          final a = articles[i];
          return SizedBox(
            width: 250,
            child: AppCard(
              padding: EdgeInsets.zero,
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => ArticleDetailScreen(article: a),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    height: 64,
                    decoration: BoxDecoration(
                      color: a.accentColor.withValues(alpha: 0.12),
                      borderRadius: const BorderRadius.vertical(
                        top: Radius.circular(AppRadius.lg - 1),
                      ),
                    ),
                    child: Stack(
                      children: [
                        Center(
                          child: Icon(
                            Icons.menu_book_rounded,
                            size: 26,
                            color: a.accentColor,
                          ),
                        ),
                        Positioned(
                          top: 6,
                          right: 6,
                          child: VerifiedBadge(compact: true),
                        ),
                      ],
                    ),
                  ),
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.all(AppSpacing.md),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            a.category,
                            style: TextStyle(
                              fontSize: 10,
                              color: a.accentColor,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          const SizedBox(height: 3),
                          Text(
                            a.title,
                            maxLines: 3,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              fontSize: 12.5,
                              fontWeight: FontWeight.w600,
                              height: 1.35,
                            ),
                          ),
                          const Spacer(),
                          Text(
                            '${a.doctor.name} · ${a.readMinutes} min',
                            style: const TextStyle(
                              fontSize: 10,
                              color: AppColors.textTertiary,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}

class _SavedStrip extends StatelessWidget {
  const _SavedStrip({required this.savedIds});

  final List<String> savedIds;

  @override
  Widget build(BuildContext context) {
    final meds = savedIds
        .map(MockMedicines.byId)
        .whereType<Medicine>()
        .take(6)
        .toList();
    if (meds.isEmpty) return const SizedBox.shrink();

    return SizedBox(
      height: 150,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: AppSpacing.pageH),
        itemCount: meds.length,
        separatorBuilder: (_, _) => const SizedBox(width: AppSpacing.md),
        itemBuilder: (context, i) {
          final m = meds[i];
          return SizedBox(
            width: 140,
            child: AppCard(
              padding: const EdgeInsets.all(AppSpacing.md),
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => MedicineDetailScreen(medicine: m),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  PillVisual(medicine: m, size: 30),
                  const Spacer(),
                  Text(
                    m.name,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 12.5,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  Text(
                    m.genericName,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 10.5,
                      color: AppColors.textTertiary,
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}

class _TrustFooter extends StatelessWidget {
  const _TrustFooter();

  @override
  Widget build(BuildContext context) {
    const items = [
      (Icons.local_shipping_rounded, 'Free delivery above ₹399'),
      (Icons.verified_user_rounded, '100% genuine medicines'),
      (Icons.assignment_return_rounded, 'Easy 7-day returns'),
      (Icons.support_agent_rounded, 'Pharmacist support 24/7'),
    ];

    return Padding(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.pageH,
        AppSpacing.xxxl,
        AppSpacing.pageH,
        AppSpacing.xl,
      ),
      child: Column(
        children: [
          const Divider(),
          const SizedBox(height: AppSpacing.lg),
          Wrap(
            spacing: AppSpacing.lg,
            runSpacing: AppSpacing.md,
            alignment: WrapAlignment.center,
            children: [
              for (final i in items)
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(i.$1, size: 15, color: AppColors.textTertiary),
                    const SizedBox(width: 5),
                    Text(
                      i.$2,
                      style: const TextStyle(
                        fontSize: 11,
                        color: AppColors.textTertiary,
                      ),
                    ),
                  ],
                ),
            ],
          ),
          const SizedBox(height: AppSpacing.lg),
          Text(
            '1mg Health is a college project demo. Medicine information is for '
            'reference only and is not a substitute for professional medical advice.',
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.bodySmall,
          ),
          const SizedBox(height: AppSpacing.md),
          const Text(
            'Build 8 · Demo',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 10.5, color: AppColors.textTertiary),
          ),
        ],
      ),
    );
  }
}

/// Stylised pill capsule illustration used in lists.
class PillVisual extends StatelessWidget {
  const PillVisual({super.key, required this.medicine, this.size = 40});

  final Medicine medicine;
  final double size;

  @override
  Widget build(BuildContext context) {
    final color = Color(medicine.pillColor);
    return SizedBox(
      width: size,
      height: size,
      child: Stack(
        alignment: Alignment.center,
        children: [
          Container(
            width: size,
            height: size,
            decoration: BoxDecoration(
              color: AppColors.surfaceAlt,
              borderRadius: BorderRadius.circular(AppRadius.sm),
            ),
          ),
          Transform.rotate(
            angle: -0.5,
            child: Container(
              width: size * 0.62,
              height: size * 0.26,
              decoration: BoxDecoration(
                color: color,
                borderRadius: BorderRadius.circular(size * 0.13),
                border: Border.all(color: AppColors.borderStrong, width: 0.6),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Container(
                      decoration: BoxDecoration(
                        color: AppColors.primary.withValues(alpha: 0.55),
                        borderRadius: BorderRadius.horizontal(
                          left: Radius.circular(size * 0.13),
                        ),
                      ),
                    ),
                  ),
                  Expanded(child: ColoredBox(color: color)),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
