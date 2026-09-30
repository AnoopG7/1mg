import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_spacing.dart';
import '../../data/mock_medicines.dart';
import '../../models/medicine.dart';
import '../../providers/reminder_provider.dart';
import '../../shared/widgets/badges.dart';
import '../../shared/widgets/common.dart';

/// Creates a medicine reminder. Can be pre-filled from a medicine detail page
/// or from a pill scan result.
class AddReminderScreen extends StatefulWidget {
  const AddReminderScreen({super.key, this.medicine, this.scanned = false});

  final Medicine? medicine;
  final bool scanned;

  @override
  State<AddReminderScreen> createState() => _AddReminderScreenState();
}

class _AddReminderScreenState extends State<AddReminderScreen> {
  String? _medicineId;
  String _dosage = '1 tablet';
  final Set<String> _times = {'08:00'};
  int _duration = 5;
  bool _withFood = true;
  final TextEditingController _notes = TextEditingController();

  static const List<String> _timeOptions = [
    '06:00', '08:00', '10:00', '12:00',
    '14:00', '16:00', '18:00', '20:00', '22:00',
  ];

  @override
  void initState() {
    super.initState();
    _medicineId = widget.medicine?.id;
    if (widget.medicine != null) {
      _dosage = '${widget.medicine!.strength} · 1 unit';
    }
  }

  @override
  void dispose() {
    _notes.dispose();
    super.dispose();
  }

  Medicine? get _medicine =>
      _medicineId == null ? null : MockMedicines.byId(_medicineId!);

  void _save() {
    final med = _medicine;
    if (med == null || _times.isEmpty) return;

    final sorted = _times.toList()..sort();
    context.read<ReminderProvider>().add(
          medicineId: med.id,
          medicineName: med.name,
          dosage: _dosage,
          times: sorted,
          durationDays: _duration,
          notes: _notes.text.trim(),
          withFood: _withFood,
          scannedFromImage: widget.scanned,
        );

    Navigator.pop(context);
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Text(
            'Reminder set for ${med.name} · ${sorted.length}× daily',
          ),
        ),
      );
  }

  @override
  Widget build(BuildContext context) {
    final med = _medicine;

    return Scaffold(
      appBar: AppBar(
        title: const Text('New reminder'),
        actions: [
          TextButton(
            onPressed: med == null ? null : _save,
            child: const Text('Save'),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(
            AppSpacing.pageH, AppSpacing.lg, AppSpacing.pageH, AppSpacing.xxxl),
        children: [
          if (widget.scanned)
            const Padding(
              padding: EdgeInsets.only(bottom: AppSpacing.md),
              child: NoticeBanner(
                color: AppColors.purple,
                icon: Icons.center_focus_strong_rounded,
                title: 'From pill scan',
                message:
                    'This medicine was added from a photo scan. Please verify '
                    'the name and strength before setting a reminder.',
              ),
            ),
          const _Label('Medicine'),
          const SizedBox(height: AppSpacing.sm),
          AppCard(
            onTap: _pickMedicine,
            padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.lg, vertical: AppSpacing.md),
            child: Row(
              children: [
                Expanded(
                  child: med == null
                      ? const Text(
                          'Select a medicine',
                          style: TextStyle(
                              fontSize: 13.5, color: AppColors.textTertiary),
                        )
                      : Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              med.name,
                              style: const TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w700),
                            ),
                            Text(
                              '${med.genericName} ${med.strength} · ${med.form}',
                              style: const TextStyle(
                                  fontSize: 11.5,
                                  color: AppColors.textTertiary),
                            ),
                          ],
                        ),
                ),
                const Icon(Icons.expand_more_rounded,
                    color: AppColors.textTertiary),
              ],
            ),
          ),
          if (med != null) ...[
            const SizedBox(height: AppSpacing.sm),
            Wrap(
              spacing: AppSpacing.sm,
              children: [
                PregnancyBadge(category: med.pregnancyCategory),
                if (med.rx)
                  const AppBadge(
                    label: 'Prescription medicine',
                    icon: Icons.info_rounded,
                    color: AppColors.info,
                    dense: true,
                  ),
              ],
            ),
          ],
          const SizedBox(height: AppSpacing.xl),
          const _Label('Dose'),
          const SizedBox(height: AppSpacing.sm),
          TextFormField(
            initialValue: _dosage,
            onChanged: (v) => _dosage = v,
            decoration: const InputDecoration(
              hintText: 'e.g. 500 mg · 1 tablet',
            ),
          ),
          const SizedBox(height: AppSpacing.xl),
          const _Label('Time of day'),
          const SizedBox(height: 4),
          Text(
            'Tap to add or remove a dose time',
            style: Theme.of(context).textTheme.bodySmall,
          ),
          const SizedBox(height: AppSpacing.sm),
          Wrap(
            spacing: AppSpacing.sm,
            runSpacing: AppSpacing.sm,
            children: [
              for (final t in _timeOptions)
                _TimeChip(
                  time: t,
                  selected: _times.contains(t),
                  onTap: () => setState(() {
                    if (_times.contains(t)) {
                      _times.remove(t);
                    } else {
                      _times.add(t);
                    }
                  }),
                ),
            ],
          ),
          const SizedBox(height: AppSpacing.xl),
          const _Label('Duration'),
          const SizedBox(height: AppSpacing.sm),
          Row(
            children: [
              Expanded(
                child: Text(
                  '$_duration day${_duration == 1 ? '' : 's'}',
                  style: const TextStyle(
                      fontSize: 14, fontWeight: FontWeight.w700),
                ),
              ),
              Text('${_duration * _times.length} total doses',
                  style: Theme.of(context).textTheme.bodySmall),
            ],
          ),
          Slider(
            value: _duration.toDouble(),
            min: 1,
            max: 30,
            divisions: 29,
            label: '$_duration days',
            onChanged: (v) => setState(() => _duration = v.round()),
          ),
          const SizedBox(height: AppSpacing.sm),
          SwitchListTile(
            value: _withFood,
            onChanged: (v) => setState(() => _withFood = v),
            contentPadding: EdgeInsets.zero,
            title: const Text('Take after food',
                style: TextStyle(fontSize: 13.5, fontWeight: FontWeight.w600)),
            subtitle: const Text(
              'We will remind you to take this dose after a meal',
              style: TextStyle(fontSize: 11.5),
            ),
            secondary: Icon(
              _withFood
                  ? Icons.restaurant_rounded
                  : Icons.restaurant_outlined,
              color: _withFood ? AppColors.secondary : AppColors.textTertiary,
            ),
          ),
          const SizedBox(height: AppSpacing.md),
          const _Label('Notes (optional)'),
          const SizedBox(height: AppSpacing.sm),
          TextField(
            controller: _notes,
            maxLines: 2,
            decoration: const InputDecoration(
              hintText: 'e.g. Do not take with milk',
            ),
          ),
          const SizedBox(height: AppSpacing.xl),
          FilledButton.icon(
            onPressed: med == null || _times.isEmpty ? null : _save,
            icon: const Icon(Icons.alarm_rounded, size: 19),
            label: const Text('Set reminder'),
          ),
          if (_times.isEmpty)
            const Padding(
              padding: EdgeInsets.only(top: AppSpacing.sm),
              child: Text(
                'Select at least one dose time to save this reminder.',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 11.5, color: AppColors.danger),
              ),
            ),
        ],
      ),
    );
  }

  void _pickMedicine() {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      builder: (sheetContext) => DraggableScrollableSheet(
        expand: false,
        initialChildSize: 0.75,
        builder: (_, controller) => ListView.builder(
          controller: controller,
          itemCount: MockMedicines.all.length,
          itemBuilder: (_, i) {
            final m = MockMedicines.all[i];
            final selected = m.id == _medicineId;
            return ListTile(
              selected: selected,
              title: Text(m.name,
                  style: const TextStyle(
                      fontSize: 13.5, fontWeight: FontWeight.w600)),
              subtitle: Text(
                '${m.genericName} ${m.strength} · ${m.category}',
                style: const TextStyle(fontSize: 11.5),
              ),
              trailing: selected
                  ? const Icon(Icons.check_rounded, color: AppColors.primary)
                  : null,
              onTap: () {
                setState(() {
                  _medicineId = m.id;
                  _dosage = '${m.strength} · 1 unit';
                });
                Navigator.pop(sheetContext);
              },
            );
          },
        ),
      ),
    );
  }
}

class _Label extends StatelessWidget {
  const _Label(this.text);

  final String text;

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: const TextStyle(fontSize: 13.5, fontWeight: FontWeight.w700),
    );
  }
}

class _TimeChip extends StatelessWidget {
  const _TimeChip({
    required this.time,
    required this.selected,
    required this.onTap,
  });

  final String time;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final hour = int.parse(time.split(':')[0]);
    final suffix = hour >= 12 ? 'PM' : 'AM';
    final h12 = hour % 12 == 0 ? 12 : hour % 12;

    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.md, vertical: AppSpacing.sm),
        decoration: BoxDecoration(
          color: selected ? AppColors.secondary : AppColors.surface,
          borderRadius: AppRadius.pillRadius,
          border: Border.all(
            color: selected ? AppColors.secondary : AppColors.border,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              selected ? Icons.check_rounded : Icons.schedule_rounded,
              size: 13,
              color: selected ? Colors.white : AppColors.textSecondary,
            ),
            const SizedBox(width: 5),
            Text(
              '$h12:00 $suffix',
              style: TextStyle(
                fontSize: 12,
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
