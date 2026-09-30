import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_spacing.dart';
import '../../core/utils/formatters.dart';
import '../../models/reminder.dart';
import '../../providers/reminder_provider.dart';
import '../../shared/widgets/badges.dart';
import '../../shared/widgets/common.dart';
import '../../shared/widgets/normal_range_bar.dart' show AdherenceChart;
import 'add_reminder_screen.dart';

class RemindersScreen extends StatelessWidget {
  const RemindersScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<ReminderProvider>();
    final reminders = provider.reminders;

    return Scaffold(
      appBar: AppBar(title: const Text('Medicine reminders')),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const AddReminderScreen()),
        ),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        icon: const Icon(Icons.add_rounded),
        label: const Text('Add reminder'),
      ),
      body: reminders.isEmpty
          ? EmptyState(
              icon: Icons.alarm_off_rounded,
              title: 'No reminders yet',
              message:
                  'Set a reminder so you never miss a dose. You can also scan a '
                  'pill photo to identify a medicine automatically.',
              actionLabel: 'Add your first reminder',
              onAction: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const AddReminderScreen()),
              ),
            )
          : ListView(
              padding: const EdgeInsets.fromLTRB(
                AppSpacing.pageH,
                AppSpacing.md,
                AppSpacing.pageH,
                96,
              ),
              children: [
                _AdherenceSummary(provider: provider),
                const SizedBox(height: AppSpacing.lg),
                Text(
                  'All reminders (${reminders.length})',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                const SizedBox(height: AppSpacing.md),
                for (final r in reminders)
                  Padding(
                    padding: const EdgeInsets.only(bottom: AppSpacing.md),
                    // Swipe is the primary delete gesture: the trailing icon on
                    // the card sits below the fold, so it is easy to miss.
                    child: Dismissible(
                      key: ValueKey(r.id),
                      direction: DismissDirection.endToStart,
                      background: const _DeleteBackground(),
                      onDismissed: (_) => deleteReminder(context, provider, r),
                      child: _ReminderCard(reminder: r, provider: provider),
                    ),
                  ),
              ],
            ),
    );
  }
}

/// Removes a reminder and offers an undo, so a stray swipe is recoverable.
void deleteReminder(
  BuildContext context,
  ReminderProvider provider,
  Reminder r,
) {
  provider.remove(r.id);
  ScaffoldMessenger.of(context)
    ..hideCurrentSnackBar()
    ..showSnackBar(
      SnackBar(
        content: Text('${r.medicineName} reminder deleted'),
        action: SnackBarAction(
          label: 'Undo',
          onPressed: () => provider.restore(r),
        ),
      ),
    );
}

class _AdherenceSummary extends StatelessWidget {
  const _AdherenceSummary({required this.provider});

  final ReminderProvider provider;

  @override
  Widget build(BuildContext context) {
    final pct = (provider.todayAdherence * 100).round();
    final week = provider.weeklyAdherence();

    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 46,
                height: 46,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: AppColors.secondarySurface,
                  borderRadius: BorderRadius.circular(AppRadius.md),
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      '$pct',
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        color: AppColors.secondary,
                        height: 1,
                      ),
                    ),
                    const Text(
                      '%',
                      style: TextStyle(
                        fontSize: 9,
                        color: AppColors.secondary,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Today\'s adherence',
                      style: Theme.of(context).textTheme.titleSmall,
                    ),
                    Text(
                      '${provider.dosesTakenToday} of ${provider.dosesDueToday} doses taken',
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        const Icon(
                          Icons.local_fire_department_rounded,
                          size: 14,
                          color: AppColors.warning,
                        ),
                        const SizedBox(width: 3),
                        Text(
                          '${provider.streak} day streak',
                          style: const TextStyle(
                            fontSize: 11.5,
                            fontWeight: FontWeight.w600,
                            color: AppColors.warning,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.lg),
          const Divider(),
          const SizedBox(height: AppSpacing.md),
          const SizedBox(height: AppSpacing.sm),
          const Text(
            'Last 7 days',
            style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700),
          ),
          // Kept on its own line rather than sharing a Row with the heading:
          // the legend is wider than a phone-width card at larger text scales.
          const Text(
            'Green = complete · Orange = missed',
            style: TextStyle(fontSize: 10, color: AppColors.textTertiary),
          ),
          const SizedBox(height: AppSpacing.sm),
          AdherenceChart(values: week),
        ],
      ),
    );
  }
}

class _ReminderCard extends StatelessWidget {
  const _ReminderCard({required this.reminder, required this.provider});

  final Reminder reminder;
  final ReminderProvider provider;

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    final endDate = reminder.startDate.add(
      Duration(days: reminder.durationDays),
    );

    return AppCard(
      color: reminder.isActive ? AppColors.surface : AppColors.surfaceAlt,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Flexible(
                          child: Text(
                            reminder.medicineName,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              fontSize: 14.5,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                        if (reminder.scannedFromImage) ...[
                          const SizedBox(width: 6),
                          const AppBadge(
                            label: 'Scanned',
                            icon: Icons.center_focus_strong_rounded,
                            color: AppColors.purple,
                            dense: true,
                          ),
                        ],
                      ],
                    ),
                    const SizedBox(height: 2),
                    Text(
                      '${reminder.dosage} · ${reminder.times.length}× a day',
                      style: const TextStyle(
                        fontSize: 12,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
              Switch(
                value: reminder.isActive,
                onChanged: (_) => provider.toggle(reminder.id),
              ),
              IconButton(
                tooltip: 'Delete reminder',
                padding: const EdgeInsets.all(4),
                constraints: const BoxConstraints(minWidth: 40, minHeight: 40),
                onPressed: () => deleteReminder(context, provider, reminder),
                icon: Icon(
                  Icons.delete_outline_rounded,
                  size: 19,
                  color: AppColors.textTertiary,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.sm),
          Row(
            children: [
              const Icon(
                Icons.calendar_today_rounded,
                size: 13,
                color: AppColors.textTertiary,
              ),
              const SizedBox(width: 5),
              Text(
                '${Fmt.dateShort(reminder.startDate)} – ${Fmt.dateShort(endDate)} · ${Fmt.untilDay(endDate)}',
                style: const TextStyle(
                  fontSize: 11,
                  color: AppColors.textTertiary,
                ),
              ),
              const Spacer(),
              if (reminder.withFood)
                const AppBadge(
                  label: 'After food',
                  icon: Icons.restaurant_rounded,
                  color: AppColors.secondary,
                  dense: true,
                ),
            ],
          ),
          if (reminder.notes.isNotEmpty) ...[
            const SizedBox(height: AppSpacing.sm),
            Text(
              reminder.notes,
              style: const TextStyle(
                fontSize: 11.5,
                color: AppColors.textSecondary,
                height: 1.4,
              ),
            ),
          ],
          const SizedBox(height: AppSpacing.md),
          const Divider(),
          const SizedBox(height: AppSpacing.md),
          Text(
            'Today\'s doses',
            style: Theme.of(context).textTheme.labelMedium,
          ),
          const SizedBox(height: AppSpacing.sm),
          Wrap(
            spacing: AppSpacing.sm,
            runSpacing: AppSpacing.sm,
            children: [
              for (final t in reminder.times)
                _DoseChip(
                  time: t,
                  taken: provider.isDoseTaken(reminder.id, t, now),
                  onTap: () => provider.markDose(reminder.id, t, now),
                ),
            ],
          ),
          const SizedBox(height: AppSpacing.md),
          Row(
            children: [
              Expanded(
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(3),
                  child: LinearProgressIndicator(
                    value: reminder.adherence,
                    minHeight: 5,
                    backgroundColor: AppColors.surfaceAlt,
                  ),
                ),
              ),
              const SizedBox(width: AppSpacing.sm),
              Text(
                '${reminder.dosesTaken}/${reminder.totalDoses} doses',
                style: const TextStyle(
                  fontSize: 10.5,
                  color: AppColors.textTertiary,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _DoseChip extends StatelessWidget {
  const _DoseChip({
    required this.time,
    required this.taken,
    required this.onTap,
  });

  final String time;
  final bool taken;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 160),
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.md,
          vertical: AppSpacing.sm,
        ),
        decoration: BoxDecoration(
          color: taken ? AppColors.success : AppColors.surfaceAlt,
          borderRadius: AppRadius.pillRadius,
          border: Border.all(
            color: taken ? AppColors.success : AppColors.border,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              taken ? Icons.check_rounded : Icons.schedule_rounded,
              size: 14,
              color: taken ? Colors.white : AppColors.textSecondary,
            ),
            const SizedBox(width: 5),
            Text(
              Fmt.time(time),
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: taken ? Colors.white : AppColors.textPrimary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Red panel revealed while a reminder card is swiped away.
class _DeleteBackground extends StatelessWidget {
  const _DeleteBackground();

  @override
  Widget build(BuildContext context) {
    return Container(
      alignment: Alignment.centerRight,
      padding: const EdgeInsets.only(right: AppSpacing.xl),
      decoration: BoxDecoration(
        color: AppColors.danger,
        borderRadius: AppRadius.cardRadius,
      ),
      child: const Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          Icon(Icons.delete_outline_rounded, color: Colors.white, size: 22),
          SizedBox(width: AppSpacing.sm),
          Text(
            'Delete',
            style: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.w700,
              fontSize: 13,
            ),
          ),
        ],
      ),
    );
  }
}
