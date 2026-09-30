import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:share_plus/share_plus.dart';

import '../../core/services/pricing_engine.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_spacing.dart';
import '../../core/utils/formatters.dart';
import '../../models/subscription.dart';
import '../../providers/pro_provider.dart';
import '../../shared/widgets/badges.dart';
import '../../shared/widgets/common.dart';
import 'pro_success_screen.dart';

/// 1mg Pro plan details, benefits, subscription management and referrals.
class ProScreen extends StatelessWidget {
  const ProScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final pro = context.watch<ProProvider>();

    return Scaffold(
      appBar: AppBar(
        title: const Text('1mg Pro'),
        actions: const [Padding(padding: EdgeInsets.only(right: 16), child: ProBadge())],
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(
            AppSpacing.pageH, AppSpacing.lg, AppSpacing.pageH, AppSpacing.xxl),
        children: [
          if (pro.isPro)
            _ActiveBanner(daysRemaining: pro.plan.daysRemaining)
          else
            _UpsellHero(),
          const SizedBox(height: AppSpacing.xl),
          Text('Benefits', style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: AppSpacing.md),
          AppCard(
            child: Column(
              children: [
                for (final b in ProPlan.benefits)
                  BulletPoint(
                    text: b,
                    icon: Icons.check_circle_rounded,
                    color: AppColors.proGold,
                  ),
              ],
            ),
          ),
          const SizedBox(height: AppSpacing.lg),
          Text('What you save',
              style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: AppSpacing.md),
          const _SavingsTable(),
          const SizedBox(height: AppSpacing.lg),
          Text('Refer friends, earn ₹100',
              style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: AppSpacing.md),
          _ReferralCard(pro: pro),
          if (pro.wallet.referrals.isNotEmpty) ...[
            const SizedBox(height: AppSpacing.md),
            AppCard(
              padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.lg, vertical: AppSpacing.md),
              child: Column(
                children: [
                  for (final r in pro.wallet.referrals)
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 6),
                      child: Row(
                        children: [
                          Icon(
                            r.credited
                                ? Icons.check_circle_rounded
                                : Icons.schedule_rounded,
                            size: 16,
                            color: r.credited
                                ? AppColors.success
                                : AppColors.warning,
                          ),
                          const SizedBox(width: AppSpacing.md),
                          Expanded(
                            child: Text('${r.name} joined',
                                style: const TextStyle(fontSize: 13)),
                          ),
                          Text(
                            r.credited
                                ? '+${Fmt.money(r.earnedAmount)}'
                                : 'pending',
                            style: TextStyle(
                              fontSize: 12.5,
                              fontWeight: FontWeight.w700,
                              color: r.credited
                                  ? AppColors.success
                                  : AppColors.textTertiary,
                            ),
                          ),
                        ],
                      ),
                    ),
                ],
              ),
            ),
          ],
          if (pro.hasSubscription) ...[
            const SizedBox(height: AppSpacing.lg),
            Text('Monthly refill subscription',
                style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: AppSpacing.md),
            AppCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  InfoRow(label: 'Medicine', value: pro.subscription.medicineName),
                  InfoRow(
                    label: 'Monthly price',
                    value: Fmt.money(pro.subscription.monthlyPrice),
                  ),
                  InfoRow(
                    label: 'You save 10% every refill',
                    value: Fmt.money(
                        pro.subscription.monthlyPrice * RefillSubscription.discount),
                    valueColor: AppColors.success,
                  ),
                  if (pro.subscription.nextDelivery != null)
                    InfoRow(
                      label: 'Next delivery',
                      value: Fmt.date(pro.subscription.nextDelivery!),
                    ),
                  const SizedBox(height: AppSpacing.sm),
                  OutlinedButton(
                    onPressed: pro.cancelSubscription,
                    child: const Text('Cancel subscription'),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
      bottomNavigationBar: pro.isPro
          ? null
          : Container(
              padding: EdgeInsets.fromLTRB(
                AppSpacing.pageH,
                AppSpacing.md,
                AppSpacing.pageH,
                AppSpacing.md + MediaQuery.of(context).padding.bottom,
              ),
              decoration: const BoxDecoration(
                gradient: AppColors.proGradient,
              ),
              child: SafeArea(
                top: false,
                child: FilledButton.icon(
                  style: FilledButton.styleFrom(
                    backgroundColor: AppColors.proGoldLight,
                    foregroundColor: AppColors.proTextOnDark,
                  ),
                  onPressed: () => _purchase(context, pro),
                  icon: const Icon(Icons.workspace_premium_rounded, size: 18),
                  label: Text(
                      'Get Pro for ${Fmt.money(ProPlan.pricePerYear)} / year'),
                ),
              ),
            ),
    );
  }

  Future<void> _purchase(BuildContext context, ProProvider pro) async {
    final confirmed = await showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      builder: (ctx) => const _ProPlansSheet(),
    );
    if (confirmed != true || !context.mounted) return;
    pro.purchasePro();
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (_) => const ProSuccessScreen()),
    );
  }
}

class _ProPlansSheet extends StatelessWidget {
  const _ProPlansSheet();

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.xl),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Choose your plan',
                style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: AppSpacing.lg),
            AppCard(
              color: AppColors.proSurface,
              borderColor: AppColors.proGold,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const ProBadge(),
                      const SizedBox(width: AppSpacing.sm),
                      const AppBadge(
                          label: 'Most popular',
                          color: AppColors.proGold,
                          dense: true),
                    ],
                  ),
                  const SizedBox(height: AppSpacing.md),
                  Text(
                    '${Fmt.money(ProPlan.pricePerYear)} / year',
                    style: const TextStyle(
                        fontSize: 22, fontWeight: FontWeight.w700),
                  ),
                  Text(
                    'Just ${Fmt.money(ProPlan.pricePerYear / 12)} a month',
                    style: const TextStyle(
                        fontSize: 12, color: AppColors.textSecondary),
                  ),
                  const SizedBox(height: AppSpacing.md),
                  const BulletPoint(
                    text: 'Extra 5% off on every medicine and lab test',
                    icon: Icons.check_rounded,
                    color: AppColors.proGold,
                  ),
                  const BulletPoint(
                    text: 'Priority delivery within 24 hours',
                    icon: Icons.check_rounded,
                    color: AppColors.proGold,
                  ),
                  const BulletPoint(
                    text: 'Free express delivery on orders above ₹399',
                    icon: Icons.check_rounded,
                    color: AppColors.proGold,
                  ),
                ],
              ),
            ),
            const SizedBox(height: AppSpacing.lg),
            SizedBox(
              width: double.infinity,
              child: FilledButton(
                onPressed: () => Navigator.pop(context, true),
                child: const Text('Pay and activate'),
              ),
            ),
            const SizedBox(height: AppSpacing.xs),
            Center(
              child: TextButton(
                onPressed: () => Navigator.pop(context, false),
                child: const Text('Not now'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _UpsellHero extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.xl),
      decoration: BoxDecoration(
        gradient: AppColors.proGradient,
        borderRadius: BorderRadius.circular(AppRadius.lg),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const ProBadge(),
          const SizedBox(height: AppSpacing.md),
          const Text(
            '1mg Pro',
            style: TextStyle(
                color: Colors.white,
                fontSize: 24,
                fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 4),
          const Text(
            'Extra 5% off on every medicine, free express delivery and priority '
            'support — for one flat annual price.',
            style: TextStyle(
                color: AppColors.proText, fontSize: 13, height: 1.45),
          ),
          const SizedBox(height: AppSpacing.lg),
          Row(
            children: [
              Text(
                Fmt.money(ProPlan.pricePerYear),
                style: const TextStyle(
                    color: Colors.white,
                    fontSize: 26,
                    fontWeight: FontWeight.w700),
              ),
              const SizedBox(width: 6),
              const Text('/ year',
                  style: TextStyle(color: AppColors.proText, fontSize: 13)),
            ],
          ),
        ],
      ),
    );
  }
}

class _ActiveBanner extends StatelessWidget {
  const _ActiveBanner({required this.daysRemaining});

  final int daysRemaining;

  @override
  Widget build(BuildContext context) {
    return AppCard(
      color: AppColors.proSurface,
      borderColor: AppColors.proGold,
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: const BoxDecoration(
              color: AppColors.proGold,
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.workspace_premium_rounded,
                color: Colors.white, size: 22),
          ),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('1mg Pro is active',
                    style: TextStyle(
                        fontSize: 15, fontWeight: FontWeight.w700)),
                Text(
                  'Renews in $daysRemaining day${daysRemaining == 1 ? '' : 's'} · '
                  '5% extra discount on every order',
                  style: const TextStyle(
                      fontSize: 12, color: AppColors.textSecondary),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _SavingsTable extends StatelessWidget {
  const _SavingsTable();

  @override
  Widget build(BuildContext context) {
    const spends = [3000.0, 6000.0, 12000.0];
    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'If you spend this much on medicines in a year, Pro saves you…',
            style: TextStyle(fontSize: 12.5, color: AppColors.textSecondary),
          ),
          const SizedBox(height: AppSpacing.md),
          for (final s in spends)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 5),
              child: Row(
                children: [
                  Text(Fmt.money(s),
                      style: const TextStyle(
                          fontSize: 13.5, fontWeight: FontWeight.w600)),
                  const Icon(Icons.arrow_right_alt_rounded,
                      size: 16, color: AppColors.textTertiary),
                  const Spacer(),
                  Text(
                    Fmt.money(PricingEngine.proAnnualSaving(s)),
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                      color: AppColors.success,
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

class _ReferralCard extends StatelessWidget {
  const _ReferralCard({required this.pro});

  final ProProvider pro;

  @override
  Widget build(BuildContext context) {
    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Your referral code',
                        style: TextStyle(
                            fontSize: 12, color: AppColors.textTertiary)),
                    Text(
                      pro.referralCode,
                      style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.w800,
                        letterSpacing: 2,
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.md, vertical: AppSpacing.sm),
                decoration: BoxDecoration(
                  color: AppColors.proGoldLight,
                  borderRadius: BorderRadius.circular(AppRadius.md),
                ),
                child: Column(
                  children: [
                    Text(
                      Fmt.money(pro.referralCredits),
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                        color: AppColors.proTextOnDark,
                      ),
                    ),
                    const Text('credit available',
                        style: TextStyle(fontSize: 10.5)),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.md),
          Text(
            'Every friend who joins and places their first order adds '
            '${Fmt.money(ReferralWallet.creditPerReferral)} to your wallet, which '
            'you can use at checkout.',
            style: const TextStyle(
                fontSize: 12, color: AppColors.textSecondary, height: 1.45),
          ),
          const SizedBox(height: AppSpacing.md),
          Row(
            children: [
              Expanded(
                child: FilledButton.icon(
                  onPressed: () =>
                      Share.share(pro.shareMessage),
                  icon: const Icon(Icons.share_rounded, size: 17),
                  label: const Text('Share code'),
                ),
              ),
              const SizedBox(width: AppSpacing.sm),
              OutlinedButton(
                onPressed: pro.simulateReferralJoined,
                child: const Text('Simulate friend'),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
