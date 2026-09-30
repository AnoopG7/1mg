import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/services/pricing_engine.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_spacing.dart';
import '../../core/utils/formatters.dart';
import '../../models/subscription.dart';
import '../../providers/pro_provider.dart';
import '../../shared/widgets/badges.dart';
import '../../shared/widgets/common.dart';
import '../shell/app_shell.dart';

/// Celebration screen shown right after Pro is activated.
class ProSuccessScreen extends StatelessWidget {
  const ProSuccessScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final pro = context.watch<ProProvider>();
    const annualSpend = 6000.0;

    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.xl),
          child: Column(
            children: [
              const Spacer(),
              Container(
                width: 96,
                height: 96,
                decoration: const BoxDecoration(
                  gradient: AppColors.proGradient,
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.workspace_premium_rounded,
                    size: 50, color: AppColors.proGoldLight),
              ),
              const SizedBox(height: AppSpacing.xl),
              Text(
                'Welcome to 1mg Pro',
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.headlineSmall,
              ),
              const SizedBox(height: AppSpacing.xs),
              Text(
                'Your extra ${Fmt.percent(ProPlan.extraDiscount * 100)} discount is '
                'live on every medicine and lab test from now on.',
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.bodyMedium,
              ),
              const SizedBox(height: AppSpacing.xxl),
              AppCard(
                color: AppColors.proSurface,
                borderColor: AppColors.proGold,
                child: Column(
                  children: [
                    InfoRow(
                      label: 'Plan',
                      value: '${Fmt.money(ProPlan.pricePerYear)} / year',
                    ),
                    InfoRow(
                      label: 'Renews on',
                      value: pro.plan.expiry == null
                          ? '—'
                          : Fmt.date(pro.plan.expiry!),
                    ),
                    InfoRow(
                      label: 'Your discount on all products',
                      value: '+${Fmt.percent(ProPlan.extraDiscount * 100)}',
                      valueColor: AppColors.proGold,
                    ),
                    if (pro.hasSubscription)
                      InfoRow(
                        label: 'Subscription on top',
                        value:
                            '+${Fmt.percent(RefillSubscription.discount * 100)}',
                        valueColor: AppColors.success,
                      ),
                    const Divider(height: AppSpacing.xl),
                    Row(
                      children: [
                        const Expanded(
                          child: Text(
                            'Estimated annual saving',
                            style: TextStyle(fontSize: 13),
                          ),
                        ),
                        Text(
                          Fmt.money(
                              PricingEngine.proAnnualSaving(annualSpend)),
                          style: const TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w700,
                            color: AppColors.success,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const Spacer(),
              SizedBox(
                width: double.infinity,
                child: FilledButton(
                  onPressed: () => Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(builder: (_) => const AppShell()),
                  ),
                  child: const Text('Start shopping'),
                ),
              ),
              const SizedBox(height: AppSpacing.sm),
              const ProBadge(),
            ],
          ),
        ),
      ),
    );
  }
}
