import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_spacing.dart';
import '../../data/mock_symptoms.dart';
import '../../models/symptom.dart';
import '../../providers/symptom_provider.dart';
import '../../shared/widgets/common.dart';
import 'symptom_result_screen.dart';

/// 4-step symptom checker: profile → symptoms → questions → result.
class SymptomCheckerScreen extends StatelessWidget {
  const SymptomCheckerScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<SymptomProvider>();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Symptom checker'),
        actions: [
          if (provider.step != CheckerStep.profile)
            TextButton(
              onPressed: provider.reset,
              child: const Text('Start over'),
            ),
        ],
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(4),
          child: _ProgressBar(step: provider.step),
        ),
      ),
      body: switch (provider.step) {
        CheckerStep.profile => _ProfileStep(provider: provider),
        CheckerStep.symptoms => _SymptomStep(provider: provider),
        CheckerStep.questions => _QuestionStep(provider: provider),
        CheckerStep.result => SymptomResultScreen(provider: provider),
      },
    );
  }
}

class _ProgressBar extends StatelessWidget {
  const _ProgressBar({required this.step});

  final CheckerStep step;

  @override
  Widget build(BuildContext context) {
    final index = step.index;
    return Padding(
      padding: const EdgeInsets.fromLTRB(
          AppSpacing.pageH, 0, AppSpacing.pageH, AppSpacing.md),
      child: Row(
        children: [
          for (var i = 0; i < MockSymptoms.stepTitles.length; i++) ...[
            Expanded(
              child: Container(
                height: 4,
                decoration: BoxDecoration(
                  color: i <= index ? AppColors.primary : AppColors.border,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            if (i < MockSymptoms.stepTitles.length - 1)
              const SizedBox(width: 4),
          ],
        ],
      ),
    );
  }
}

class _ProfileStep extends StatelessWidget {
  const _ProfileStep({required this.provider});

  final SymptomProvider provider;

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.fromLTRB(
          AppSpacing.pageH, AppSpacing.lg, AppSpacing.pageH, AppSpacing.xxl),
      children: [
        Text('Let\'s get started',
            style: Theme.of(context).textTheme.headlineSmall),
        const SizedBox(height: 4),
        Text(
          'A few details help our assessment engine give you a more accurate '
          'preliminary result.',
          style: Theme.of(context).textTheme.bodyMedium,
        ),
        const SizedBox(height: AppSpacing.xl),
        const _StepLabel('Your age group'),
        const SizedBox(height: AppSpacing.md),
        for (final band in MockSymptoms.ageBands)
          _OptionTile(
            label: band,
            selected: provider.ageBand == band,
            onTap: () => provider.setAgeBand(band),
          ),
        const SizedBox(height: AppSpacing.xl),
        const _StepLabel('Gender'),
        const SizedBox(height: AppSpacing.md),
        Row(
          children: [
            for (final g in MockSymptoms.genders) ...[
              Expanded(
                child: _OptionTile(
                  label: g,
                  selected: provider.gender == g,
                  onTap: () => provider.setGender(g),
                ),
              ),
              if (g != MockSymptoms.genders.last)
                const SizedBox(width: AppSpacing.sm),
            ],
          ],
        ),
        const SizedBox(height: AppSpacing.xxl),
        const NoticeBanner(
          color: AppColors.danger,
          icon: Icons.emergency_rounded,
          title: 'Not a diagnosis',
          message:
              'This tool offers a preliminary, educational assessment only. It '
              'does not replace a consultation with a qualified doctor. In an '
              'emergency, call your local emergency number immediately.',
        ),
        const SizedBox(height: AppSpacing.xl),
        FilledButton(
          onPressed: provider.goToSymptoms,
          child: const Text('Continue to symptoms'),
        ),
      ],
    );
  }
}

class _StepLabel extends StatelessWidget {
  const _StepLabel(this.text);

  final String text;

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w700),
    );
  }
}

class _OptionTile extends StatelessWidget {
  const _OptionTile({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.sm),
      child: AppCard(
        onTap: onTap,
        padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.lg, vertical: AppSpacing.md),
        color: selected ? AppColors.primarySurface : AppColors.surface,
        borderColor: selected ? AppColors.primary : AppColors.border,
        child: Row(
          children: [
            Expanded(
              child: Text(
                label,
                style: TextStyle(
                  fontSize: 13.5,
                  fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
                ),
              ),
            ),
            Icon(
              selected
                  ? Icons.radio_button_checked_rounded
                  : Icons.radio_button_unchecked_rounded,
              color: selected ? AppColors.primary : AppColors.borderStrong,
              size: 20,
            ),
          ],
        ),
      ),
    );
  }
}

class _SymptomStep extends StatelessWidget {
  const _SymptomStep({required this.provider});

  final SymptomProvider provider;

  @override
  Widget build(BuildContext context) {
    final categories = MockSymptoms.all
        .map((s) => s.category)
        .toSet()
        .toList()
      ..sort();

    return Column(
      children: [
        Container(
          padding: const EdgeInsets.fromLTRB(
              AppSpacing.pageH, 0, AppSpacing.pageH, AppSpacing.md),
          color: AppColors.surface,
          child: Row(
            children: [
              Text(
                'Select all symptoms you have',
                style: Theme.of(context).textTheme.titleSmall,
              ),
              const Spacer(),
              Container(
                padding: const EdgeInsets.symmetric(
                    horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: AppColors.primary,
                  borderRadius: AppRadius.pillRadius,
                ),
                child: Text(
                  '${provider.selectedCount} selected',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ],
          ),
        ),
        Expanded(
          child: ListView(
            padding: const EdgeInsets.fromLTRB(
                AppSpacing.pageH, 0, AppSpacing.pageH, AppSpacing.lg),
            children: [
              for (final cat in categories) ...[
                Padding(
                  padding: const EdgeInsets.only(
                      top: AppSpacing.md, bottom: AppSpacing.sm),
                  child: Text(
                    cat,
                    style: const TextStyle(
                      fontSize: 11.5,
                      fontWeight: FontWeight.w700,
                      color: AppColors.textTertiary,
                      letterSpacing: 0.4,
                    ),
                  ),
                ),
                Wrap(
                  spacing: AppSpacing.sm,
                  runSpacing: AppSpacing.sm,
                  children: [
                    for (final s in MockSymptoms.byCategory(cat))
                      _SymptomChip(
                        symptom: s,
                        selected: provider.selected.contains(s.id),
                        onTap: () => provider.toggleSymptom(s.id),
                      ),
                  ],
                ),
              ],
            ],
          ),
        ),
        Container(
          padding: EdgeInsets.fromLTRB(
            AppSpacing.pageH,
            AppSpacing.md,
            AppSpacing.pageH,
            AppSpacing.md + MediaQuery.of(context).viewInsets.bottom,
          ),
          decoration: const BoxDecoration(
            color: AppColors.surface,
            border: Border(top: BorderSide(color: AppColors.border)),
          ),
          child: FilledButton(
            onPressed:
                provider.selectedCount == 0 ? null : provider.goToQuestions,
            child: Text(provider.selectedCount == 0
                ? 'Select at least one symptom'
                : 'Continue (${provider.selectedCount} selected)'),
          ),
        ),
      ],
    );
  }
}

class _SymptomChip extends StatelessWidget {
  const _SymptomChip({
    required this.symptom,
    required this.selected,
    required this.onTap,
  });

  final Symptom symptom;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 160),
        padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.md, vertical: AppSpacing.sm),
        decoration: BoxDecoration(
          color: selected ? AppColors.primary : AppColors.surface,
          borderRadius: AppRadius.pillRadius,
          border: Border.all(
              color: selected ? AppColors.primary : AppColors.border),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              symptom.icon,
              size: 15,
              color: selected ? Colors.white : AppColors.textSecondary,
            ),
            const SizedBox(width: 6),
            Text(
              symptom.name,
              style: TextStyle(
                fontSize: 12.5,
                fontWeight: FontWeight.w600,
                color: selected ? Colors.white : AppColors.textPrimary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _QuestionStep extends StatelessWidget {
  const _QuestionStep({required this.provider});

  final SymptomProvider provider;

  @override
  Widget build(BuildContext context) {
    final question = provider.currentQuestion;

    if (question == null) {
      // All answered — kick off the engine.
      WidgetsBinding.instance.addPostFrameCallback((_) {
        provider.analyse();
      });
      return const _AnalysingView();
    }

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(
              AppSpacing.pageH, AppSpacing.md, AppSpacing.pageH, 0),
          child: Row(
            children: [
              Text(
                'Question ${provider.questionIndex + 1} of ${provider.totalQuestions}',
                style: const TextStyle(
                  fontSize: 11.5,
                  color: AppColors.textTertiary,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const Spacer(),
              Text(
                'Step ${provider.selectedCount} symptoms reported',
                style: const TextStyle(
                    fontSize: 11.5, color: AppColors.textTertiary),
              ),
            ],
          ),
        ),
        LinearProgressIndicator(
          value: (provider.questionIndex + 1) / provider.totalQuestions,
          minHeight: 4,
          backgroundColor: AppColors.border,
        ),
        Expanded(
          child: ListView(
            padding: const EdgeInsets.fromLTRB(
                AppSpacing.pageH, AppSpacing.xl, AppSpacing.pageH, AppSpacing.xl),
            children: [
              Row(
                children: [
                  if (question.icon != null) ...[
                    Container(
                      width: 44,
                      height: 44,
                      decoration: BoxDecoration(
                        color: AppColors.primarySurface,
                        borderRadius: BorderRadius.circular(AppRadius.md),
                      ),
                      child: Icon(question.icon,
                          size: 22, color: AppColors.primary),
                    ),
                    const SizedBox(width: AppSpacing.md),
                  ],
                  Expanded(
                    child: Text(
                      question.prompt,
                      style: const TextStyle(
                        fontSize: 17,
                        fontWeight: FontWeight.w700,
                        height: 1.3,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.xl),
              for (final opt in question.options)
                _OptionTile(
                  label: opt,
                  selected: provider.answerFor(question.id) == opt,
                  onTap: () => provider.answer(question, opt),
                ),
            ],
          ),
        ),
      ],
    );
  }
}

class _AnalysingView extends StatelessWidget {
  const _AnalysingView();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.xxl),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(
              width: 56,
              height: 56,
              child: CircularProgressIndicator(strokeWidth: 4),
            ),
            const SizedBox(height: AppSpacing.xl),
            Text('Analysing your symptoms',
                style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: AppSpacing.sm),
            Text(
              'Matching your symptoms against our clinical condition database…',
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            const SizedBox(height: AppSpacing.xl),
            const Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _PulseDot(label: 'Conditions'),
                _PulseDot(label: 'Severity'),
                _PulseDot(label: 'Advice'),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _PulseDot extends StatelessWidget {
  const _PulseDot({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.sm),
      child: Column(
        children: [
          Container(
            width: 8,
            height: 8,
            decoration: const BoxDecoration(
              color: AppColors.primary,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(height: 5),
          Text(label,
              style: const TextStyle(fontSize: 10.5, color: AppColors.textTertiary)),
        ],
      ),
    );
  }
}
