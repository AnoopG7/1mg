import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/services/interaction_engine.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_spacing.dart';
import '../../data/mock_medicines.dart';
import '../../models/drug_interaction.dart';
import '../../models/medicine.dart';
import '../../providers/interaction_provider.dart';
import '../../shared/widgets/badges.dart';
import '../../shared/widgets/common.dart';

/// Checks a set of medicines against each other and against food, alcohol and
/// other common substances.
class InteractionCheckerScreen extends StatefulWidget {
  const InteractionCheckerScreen({super.key, this.preSelected = const []});

  /// Medicine ids to preselect, e.g. from the cart.
  final List<String> preSelected;

  @override
  State<InteractionCheckerScreen> createState() =>
      _InteractionCheckerScreenState();
}

class _InteractionCheckerScreenState extends State<InteractionCheckerScreen> {
  final TextEditingController _search = TextEditingController();
  bool _initialised = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_initialised) return;
    _initialised = true;
    final provider = context.read<InteractionProvider>();
    for (final id in widget.preSelected) {
      provider.toggleMedicine(id);
    }
  }

  @override
  void dispose() {
    _search.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<InteractionProvider>();
    final alerts = provider.alerts;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Interaction checker'),
        actions: [
          if (provider.selected.isNotEmpty || provider.substances.isNotEmpty)
            TextButton(
              onPressed: provider.clear,
              child: const Text('Reset'),
            ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(
            AppSpacing.pageH, AppSpacing.md, AppSpacing.pageH, AppSpacing.xxl),
        children: [
          const NoticeBanner(
            color: AppColors.info,
            icon: Icons.info_rounded,
            message:
                'Select two or more medicines to check for interactions between '
                'them, or toggle substances like alcohol and grapefruit below.',
          ),
          const SizedBox(height: AppSpacing.lg),
          _StepHeader(
            step: 1,
            title: 'Select your medicines',
            subtitle: provider.selected.isEmpty
                ? 'None selected yet'
                : '${provider.selected.length} selected',
          ),
          const SizedBox(height: AppSpacing.md),
          TextField(
            controller: _search,
            onChanged: (_) => setState(() {}),
            decoration: const InputDecoration(
              hintText: 'Search medicines',
              prefixIcon: Icon(Icons.search_rounded),
            ),
          ),
          const SizedBox(height: AppSpacing.md),
          ...MockMedicines.all
              .where((m) => _search.text.isEmpty ||
                  m.searchText.contains(_search.text.toLowerCase()))
              .map((m) => _MedicineTile(
                    medicine: m,
                    selected: provider.isSelected(m.id),
                    onTap: () => provider.toggleMedicine(m.id),
                  )),
          const SizedBox(height: AppSpacing.xl),
          _StepHeader(
            step: 2,
            title: 'Food, alcohol & other substances',
            subtitle: 'What else are you taking or consuming?',
          ),
          const SizedBox(height: AppSpacing.md),
          Wrap(
            spacing: AppSpacing.sm,
            runSpacing: AppSpacing.sm,
            children: [
              for (final type in InteractionType.values)
                FilterChip(
                  label: Text(type.label),
                  avatar: Icon(type.icon, size: 16, color: type.color),
                  selected: provider.types.contains(type),
                  selectedColor: type.color.withValues(alpha: 0.12),
                  checkmarkColor: type.color,
                  onSelected: (_) => provider.toggleType(type),
                ),
            ],
          ),
          const SizedBox(height: AppSpacing.md),
          ..._substanceGroups(provider),
          const SizedBox(height: AppSpacing.xl),
          _StepHeader(
            step: 3,
            title: 'Results',
            subtitle: alerts.isEmpty
                ? 'No interactions detected'
                : '${alerts.length} interaction(s) found',
          ),
          const SizedBox(height: AppSpacing.md),
          if (alerts.isEmpty)
            const NoticeBanner(
              color: AppColors.success,
              icon: Icons.verified_rounded,
              title: 'No known interactions',
              message:
                  'None of your selections are known to interact with each '
                  'other. Always tell your doctor about every medicine you take, '
                  'including supplements.',
            )
          else ...[
            _AlertSummary(alerts: alerts),
            const SizedBox(height: AppSpacing.md),
            for (final a in alerts)
              Padding(
                padding: const EdgeInsets.only(bottom: AppSpacing.md),
                child: AppCard(
                  borderColor: a.severity.color.withValues(alpha: 0.3),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(a.type.icon, size: 17, color: a.severity.color),
                          const SizedBox(width: AppSpacing.sm),
                          Expanded(
                            child: Text(
                              a.title,
                              style: const TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ),
                          SeverityBadge(
                            label: a.severity.label,
                            color: a.severity.color,
                          ),
                        ],
                      ),
                      const SizedBox(height: AppSpacing.sm),
                      Text(
                        a.detail,
                        style: const TextStyle(
                          fontSize: 13,
                          height: 1.5,
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            if (alerts.any((a) => a.severity == InteractionSeverity.severe))
              const NoticeBanner(
                color: AppColors.danger,
                icon: Icons.gpp_maybe_rounded,
                title: 'Serious interactions found',
                message:
                    'One or more combinations can be dangerous. Contact your '
                    'doctor or pharmacist before combining these medicines.',
              ),
          ],
        ],
      ),
    );
  }

  List<Widget> _substanceGroups(InteractionProvider provider) {
    final widgets = <Widget>[];
    for (final type in provider.types) {
      final items = InteractionEngine.commonSubstances[type] ?? const [];
      if (items.isEmpty) continue;
      widgets.add(
        Padding(
          padding: const EdgeInsets.only(bottom: AppSpacing.sm),
          child: Text(
            type.label,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w700,
              color: type.color,
            ),
          ),
        ),
      );
      widgets.add(
        Wrap(
          spacing: AppSpacing.sm,
          runSpacing: AppSpacing.sm,
          children: [
            for (final s in items)
              FilterChip(
                label: Text(s),
                selected: provider.substances.contains(s),
                selectedColor: type.color.withValues(alpha: 0.12),
                checkmarkColor: type.color,
                onSelected: (_) => provider.toggleSubstance(s),
              ),
          ],
        ),
      );
    }
    return widgets;
  }
}

class _StepHeader extends StatelessWidget {
  const _StepHeader({
    required this.step,
    required this.title,
    required this.subtitle,
  });

  final int step;
  final String title;
  final String subtitle;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 24,
          height: 24,
          alignment: Alignment.center,
          decoration: const BoxDecoration(
            color: AppColors.primary,
            shape: BoxShape.circle,
          ),
          child: Text(
            '$step',
            style: const TextStyle(
              color: Colors.white,
              fontSize: 12,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
        const SizedBox(width: AppSpacing.md),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title,
                  style: const TextStyle(
                      fontSize: 15, fontWeight: FontWeight.w700)),
              Text(subtitle,
                  style: const TextStyle(
                      fontSize: 11.5, color: AppColors.textTertiary)),
            ],
          ),
        ),
      ],
    );
  }
}

class _MedicineTile extends StatelessWidget {
  const _MedicineTile({
    required this.medicine,
    required this.selected,
    required this.onTap,
  });

  final Medicine medicine;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.sm),
      child: AppCard(
        onTap: onTap,
        color: selected ? AppColors.primarySurface : AppColors.surface,
        borderColor: selected ? AppColors.primary : AppColors.border,
        padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.lg, vertical: AppSpacing.md),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    medicine.name,
                    style: const TextStyle(
                        fontSize: 13.5, fontWeight: FontWeight.w700),
                  ),
                  Text(
                    '${medicine.genericName} ${medicine.strength}',
                    style: const TextStyle(
                        fontSize: 11, color: AppColors.textTertiary),
                  ),
                ],
              ),
            ),
            if (medicine.interactions.isNotEmpty)
              AppBadge(
                label: '${medicine.interactions.length} rules',
                color: AppColors.textTertiary,
                dense: true,
              ),
            const SizedBox(width: AppSpacing.sm),
            Icon(
              selected
                  ? Icons.check_circle_rounded
                  : Icons.radio_button_unchecked_rounded,
              color: selected ? AppColors.primary : AppColors.borderStrong,
            ),
          ],
        ),
      ),
    );
  }
}

class _AlertSummary extends StatelessWidget {
  const _AlertSummary({required this.alerts});

  final List<InteractionAlert> alerts;

  @override
  Widget build(BuildContext context) {
    int count(InteractionSeverity s) =>
        alerts.where((a) => a.severity == s).length;

    return Row(
      children: [
        for (final s in InteractionSeverity.values)
          Expanded(
            child: Container(
              margin: const EdgeInsets.only(right: AppSpacing.sm),
              padding: const EdgeInsets.symmetric(vertical: AppSpacing.md),
              decoration: BoxDecoration(
                color: s.color.withValues(alpha: 0.08),
                borderRadius: BorderRadius.circular(AppRadius.md),
                border: Border.all(color: s.color.withValues(alpha: 0.25)),
              ),
              child: Column(
                children: [
                  Text(
                    '${count(s)}',
                    style: TextStyle(
                      fontSize: 19,
                      fontWeight: FontWeight.w700,
                      color: s.color,
                    ),
                  ),
                  Text(
                    s.label,
                    style: TextStyle(
                      fontSize: 10.5,
                      color: s.color,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
          ),
      ],
    );
  }
}
