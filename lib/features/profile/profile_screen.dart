import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_spacing.dart';
import '../../core/utils/formatters.dart';
import '../../providers/cart_provider.dart';
import '../../providers/auth_provider.dart';
import '../../providers/lab_provider.dart';
import '../../providers/order_provider.dart';
import '../../providers/profile_provider.dart';
import '../../providers/pro_provider.dart';
import '../../providers/reminder_provider.dart';
import '../../providers/saved_provider.dart';
import '../../shared/widgets/badges.dart';
import '../../shared/widgets/common.dart';
import '../pro/pro_screen.dart';
import 'orders_screen.dart';
import 'profile_edit_screen.dart';
import 'saved_articles_screen.dart';
import 'saved_medicines_screen.dart';

/// Account hub: profile header, saved items, addresses, lab bookings, Pro.
class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final saved = context.watch<SavedProvider>();
    final pro = context.watch<ProProvider>();
    final orders = context.watch<OrderProvider>();
    final lab = context.watch<LabProvider>();
    final reminders = context.watch<ReminderProvider>();
    final cart = context.watch<CartProvider>();
    final profile = context.watch<ProfileProvider>().profile;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Profile'),
        actions: [
          IconButton(
            tooltip: 'Settings',
            onPressed: () => _showSettingsDialog(context),
            icon: const Icon(Icons.settings_outlined),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(
          AppSpacing.pageH,
          AppSpacing.lg,
          AppSpacing.pageH,
          AppSpacing.xxl,
        ),
        children: [
          _ProfileHeader(profile: profile),
          const SizedBox(height: AppSpacing.lg),
          Row(
            children: [
              Expanded(
                child: _StatTile(
                  label: 'Orders',
                  value: '${orders.count}',
                  icon: Icons.receipt_long_rounded,
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const OrdersScreen()),
                  ),
                ),
              ),
              const SizedBox(width: AppSpacing.sm),
              Expanded(
                child: _StatTile(
                  label: 'Reminders',
                  value: '${reminders.reminders.length}',
                  icon: Icons.alarm_rounded,
                ),
              ),
              const SizedBox(width: AppSpacing.sm),
              Expanded(
                child: _StatTile(
                  label: 'In cart',
                  value: '${cart.itemCount}',
                  icon: Icons.shopping_cart_rounded,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.lg),
          ProPromoCard(
            title: pro.isPro ? '1mg Pro active' : 'Join 1mg Pro',
            subtitle: pro.isPro
                ? 'You save an extra 5% on every order · ${pro.plan.daysRemaining} days left'
                : 'Extra 5% off, priority delivery and free express shipping',
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const ProScreen()),
            ),
          ),
          const SizedBox(height: AppSpacing.lg),
          _SettingsCard(pro: pro, saved: saved, profile: profile),
          const SizedBox(height: AppSpacing.lg),
          if (lab.bookings.isNotEmpty) ...[
            Text(
              'Lab bookings',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: AppSpacing.md),
            for (final b in lab.bookings.take(3))
              Padding(
                padding: const EdgeInsets.only(bottom: AppSpacing.sm),
                child: AppCard(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.lg,
                    vertical: AppSpacing.md,
                  ),
                  child: Row(
                    children: [
                      Container(
                        width: 34,
                        height: 34,
                        decoration: BoxDecoration(
                          color: AppColors.secondarySurface,
                          borderRadius: BorderRadius.circular(AppRadius.sm),
                        ),
                        child: const Icon(
                          Icons.biotech_rounded,
                          size: 17,
                          color: AppColors.secondary,
                        ),
                      ),
                      const SizedBox(width: AppSpacing.md),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              b.name,
                              style: const TextStyle(
                                fontSize: 13.5,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                            Text(
                              '${Fmt.date(b.slot)} · ${b.id}',
                              style: const TextStyle(
                                fontSize: 11.5,
                                color: AppColors.textTertiary,
                              ),
                            ),
                          ],
                        ),
                      ),
                      AppBadge(
                        label: b.isReportReady ? 'Report ready' : 'Scheduled',
                        color: b.isReportReady
                            ? AppColors.success
                            : AppColors.info,
                        dense: true,
                      ),
                    ],
                  ),
                ),
              ),
            const SizedBox(height: AppSpacing.sm),
          ],
          if (saved.addresses.isNotEmpty) ...[
            Text(
              'Saved addresses',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: AppSpacing.md),
            for (final a in saved.addresses)
              Padding(
                padding: const EdgeInsets.only(bottom: AppSpacing.sm),
                child: AppCard(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.lg,
                    vertical: AppSpacing.md,
                  ),
                  child: Row(
                    children: [
                      Icon(
                        a.isDefault
                            ? Icons.home_rounded
                            : Icons.location_on_outlined,
                        size: 18,
                        color: a.isDefault
                            ? AppColors.primary
                            : AppColors.textTertiary,
                      ),
                      const SizedBox(width: AppSpacing.md),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Text(
                                  a.label,
                                  style: const TextStyle(
                                    fontSize: 13,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                                if (a.isDefault) ...[
                                  const SizedBox(width: 6),
                                  const AppBadge(label: 'Default', dense: true),
                                ],
                              ],
                            ),
                            Text(
                              a.oneLine,
                              style: const TextStyle(
                                fontSize: 11.5,
                                color: AppColors.textSecondary,
                                height: 1.4,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
          ],
        ],
      ),
    );
  }
}

/// Banner shown for features that are intentionally not built yet, so the
/// row still does something instead of being a dead tap.
void _showFeatureComing(BuildContext context, String feature) {
  showDialog<void>(
    context: context,
    builder: (ctx) => AlertDialog(
      title: Text(feature),
      content: const NoticeBanner(
        color: AppColors.info,
        icon: Icons.hourglass_top_rounded,
        title: 'Feature incoming',
        message:
            'This part is still being built for the demo. Check back soon — '
            'everything else on this page already works.',
      ),
      actions: [
        FilledButton(
          onPressed: () => Navigator.pop(ctx),
          child: const Text('Got it'),
        ),
      ],
    ),
  );
}

/// Settings dialog with real actions: about info and one-tap data management
/// (clear cart, delete all reminders) so the gear is never a dead icon.
void _showSettingsDialog(BuildContext context) {
  final auth = context.read<AuthProvider?>();
  final cart = context.read<CartProvider>();
  final reminders = context.read<ReminderProvider>();

  showDialog<void>(
    context: context,
    builder: (ctx) => AlertDialog(
      title: const Text('Settings'),
      content: const SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'OneMg Health (demo)\nVersion 1.0.0',
              style: TextStyle(fontWeight: FontWeight.w600),
            ),
            SizedBox(height: AppSpacing.sm),
            Text(
              'A college project — medicine information and reminders are for '
              'education only, never a medical diagnosis.',
              style: TextStyle(
                fontSize: 11.5,
                color: AppColors.textTertiary,
                height: 1.4,
              ),
            ),
            SizedBox(height: AppSpacing.md),
            Text(
              'Manage demo data',
              style: TextStyle(fontWeight: FontWeight.w700),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () {
            Navigator.pop(ctx);
            showDialog<void>(
              context: context,
              builder: (c) => AlertDialog(
                title: const Text('Clear cart?'),
                content: Text(
                  cart.isEmpty
                      ? 'Your cart is already empty.'
                      : 'This removes ${cart.itemCount} item(s) from your cart.',
                ),
                actions: [
                  TextButton(
                    onPressed: () => Navigator.pop(c),
                    child: const Text('Keep items'),
                  ),
                  FilledButton(
                    onPressed: () {
                      cart.clear();
                      Navigator.pop(c);
                    },
                    child: const Text('Clear cart'),
                  ),
                ],
              ),
            );
          },
          child: const Text('Clear cart'),
        ),
        TextButton(
          onPressed: () {
            Navigator.pop(ctx);
            showDialog<void>(
              context: context,
              builder: (c) => AlertDialog(
                title: const Text('Delete all reminders?'),
                content: Text(
                  reminders.reminders.isEmpty
                      ? 'You have no reminders.'
                      : 'This removes all ${reminders.reminders.length} '
                            'reminder(s).',
                ),
                actions: [
                  TextButton(
                    onPressed: () => Navigator.pop(c),
                    child: const Text('Cancel'),
                  ),
                  FilledButton(
                    onPressed: () {
                      reminders.clearAll();
                      Navigator.pop(c);
                    },
                    child: const Text('Delete all'),
                  ),
                ],
              ),
            );
          },
          child: const Text('Delete reminders'),
        ),
        FilledButton(
          onPressed: () => Navigator.pop(ctx),
          child: const Text('Done'),
        ),
        if (auth != null)
          TextButton(
            onPressed: () {
              Navigator.pop(ctx);
              auth.signOut();
            },
            child: const Text('Sign out'),
          ),
      ],
    ),
  );
}

class _ProfileHeader extends StatelessWidget {
  const _ProfileHeader({required this.profile});

  final UserProfile profile;

  @override
  Widget build(BuildContext context) {
    final pro = context.watch<ProProvider>();

    return AppCard(
      onTap: () => Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => const ProfileEditScreen()),
      ),
      child: Row(
        children: [
          Container(
            width: 56,
            height: 56,
            alignment: Alignment.center,
            decoration: const BoxDecoration(
              gradient: AppColors.brandGradient,
              shape: BoxShape.circle,
            ),
            child: Text(
              profile.initials,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 19,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
          const SizedBox(width: AppSpacing.lg),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  profile.name,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  '${profile.phone} · ${profile.city}',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 12,
                    color: AppColors.textSecondary,
                  ),
                ),
                if (pro.isPro) ...[
                  const SizedBox(height: 6),
                  const ProBadge(dense: true),
                ],
              ],
            ),
          ),
          const Icon(
            Icons.chevron_right_rounded,
            size: 22,
            color: AppColors.textTertiary,
          ),
        ],
      ),
    );
  }
}

class _StatTile extends StatelessWidget {
  const _StatTile({
    required this.label,
    required this.value,
    required this.icon,
    this.onTap,
  });

  final String label;
  final String value;
  final IconData icon;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return AppCard(
      onTap: onTap,
      padding: const EdgeInsets.symmetric(vertical: AppSpacing.lg),
      child: Column(
        children: [
          Icon(icon, size: 20, color: AppColors.primary),
          const SizedBox(height: 6),
          Text(
            value,
            style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w700),
          ),
          Text(
            label,
            style: const TextStyle(fontSize: 11, color: AppColors.textTertiary),
          ),
        ],
      ),
    );
  }
}

class _SettingsCard extends StatelessWidget {
  const _SettingsCard({
    required this.pro,
    required this.saved,
    required this.profile,
  });

  final ProProvider pro;
  final SavedProvider saved;
  final UserProfile profile;

  @override
  Widget build(BuildContext context) {
    final rows =
        <({IconData icon, String label, String? value, VoidCallback? onTap})>[
          (
            icon: Icons.person_outline_rounded,
            label: 'Personal details',
            value: profile.name,
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const ProfileEditScreen()),
            ),
          ),
          (
            icon: Icons.favorite_border_rounded,
            label: 'Saved medicines',
            value: '${saved.medicineIds.length}',
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const SavedMedicinesScreen()),
            ),
          ),
          (
            icon: Icons.bookmark_border_rounded,
            label: 'Saved articles',
            value: '${saved.articleIds.length}',
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const SavedArticlesScreen()),
            ),
          ),
          (
            icon: Icons.workspace_premium_outlined,
            label: '1mg Pro',
            value: pro.isPro ? 'Active' : 'Explore',
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const ProScreen()),
            ),
          ),
          (
            icon: Icons.replay_rounded,
            label: 'Monthly refill plan',
            value: pro.hasSubscription ? 'Active' : 'Not subscribed',
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const ProScreen()),
            ),
          ),
          (
            icon: Icons.help_outline_rounded,
            label: 'Help & support',
            value: null,
            onTap: () => _showFeatureComing(context, 'Help & support'),
          ),
          (
            icon: Icons.policy_outlined,
            label: 'Privacy & terms',
            value: null,
            onTap: () => _showFeatureComing(context, 'Privacy & terms'),
          ),
        ];

    return AppCard(
      padding: const EdgeInsets.symmetric(vertical: AppSpacing.xs),
      child: Column(
        children: [
          for (final r in rows)
            ListTile(
              dense: true,
              visualDensity: const VisualDensity(vertical: -2),
              leading: Icon(r.icon, size: 19, color: AppColors.textSecondary),
              title: Text(
                r.label,
                style: const TextStyle(
                  fontSize: 13.5,
                  fontWeight: FontWeight.w600,
                ),
              ),
              trailing: r.value == null
                  ? const Icon(
                      Icons.chevron_right_rounded,
                      size: 20,
                      color: AppColors.textTertiary,
                    )
                  : Text(
                      r.value!,
                      style: const TextStyle(
                        fontSize: 12.5,
                        color: AppColors.primary,
                      ),
                    ),
              onTap: r.onTap,
            ),
        ],
      ),
    );
  }
}
