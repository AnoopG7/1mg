import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_spacing.dart';
import '../../core/utils/formatters.dart';
import '../../models/lab_test.dart';
import '../../providers/lab_provider.dart';
import '../../providers/pro_provider.dart';
import '../../providers/saved_provider.dart';
import '../../shared/widgets/badges.dart';
import '../../shared/widgets/common.dart';
import 'lab_result_screen.dart';

/// Books a home sample collection for one or more lab tests.
class LabBookingScreen extends StatefulWidget {
  const LabBookingScreen({super.key, required this.tests, this.bundle});

  final List<LabTest> tests;
  final LabBundle? bundle;

  @override
  State<LabBookingScreen> createState() => _LabBookingScreenState();
}

class _LabBookingScreenState extends State<LabBookingScreen> {
  int _dateIndex = 0;
  int _timeIndex = 0;
  String _addressId = '';
  bool _accepting = true;

  @override
  void initState() {
    super.initState();
    _addressId = context.read<SavedProvider>().defaultAddress.id;
  }

  @override
  Widget build(BuildContext context) {
    final lab = context.watch<LabProvider>();
    final pro = context.watch<ProProvider>();
    final saved = context.watch<SavedProvider>();

    final basePrice = widget.bundle?.offerPrice ??
        widget.tests.fold<double>(0.0, (s, t) => s + t.price);
    final mrp = widget.bundle?.mrp ??
        widget.tests.fold<double>(0.0, (s, t) => s + t.mrp);
    final price = pro.isPro ? basePrice * 0.95 : basePrice;
    final slots = lab.availableSlots();
    final slotTimes = LabProvider.defaultSlotTimes;
    final address =
        saved.addresses.firstWhere((a) => a.id == _addressId, orElse: () => saved.defaultAddress);
    final needsFasting = widget.tests.any((t) => t.fastingRequired);

    return Scaffold(
      appBar: AppBar(title: const Text('Book a sample collection')),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(
            AppSpacing.pageH, AppSpacing.lg, AppSpacing.pageH, AppSpacing.xxl),
        children: [
          AppCard(
            color: AppColors.primarySurface,
            borderColor: AppColors.primary.withValues(alpha: 0.3),
            child: Row(
              children: [
                const Icon(Icons.biotech_rounded, color: AppColors.primary),
                const SizedBox(width: AppSpacing.md),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        widget.bundle?.name ??
                            (widget.tests.length == 1
                                ? widget.tests.first.name
                                : '${widget.tests.length} tests'),
                        style: const TextStyle(
                            fontSize: 14, fontWeight: FontWeight.w700),
                      ),
                      Text(
                        '${widget.tests.fold<int>(0, (s, t) => s + t.parameters.length)} parameters · Free home collection',
                        style: const TextStyle(
                            fontSize: 11.5, color: AppColors.textSecondary),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: AppSpacing.xl),
          const _StepLabel(
              step: 1, title: 'Choose a collection date', subtitle: null),
          const SizedBox(height: AppSpacing.md),
          SizedBox(
            height: 84,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              itemCount: slots.length,
              separatorBuilder: (_, _) => const SizedBox(width: AppSpacing.sm),
              itemBuilder: (context, i) {
                final selected = i == _dateIndex;
                return GestureDetector(
                  onTap: () {
                    setState(() => _dateIndex = i);
                  },
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 160),
                    width: 74,
                    padding: const EdgeInsets.symmetric(vertical: AppSpacing.md),
                    decoration: BoxDecoration(
                      color: selected ? AppColors.primary : AppColors.surface,
                      borderRadius: BorderRadius.circular(AppRadius.md),
                      border: Border.all(
                        color: selected ? AppColors.primary : AppColors.border,
                      ),
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          Fmt.dateShort(slots[i]).split(' ').first,
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w700,
                            color: selected ? Colors.white : AppColors.textPrimary,
                          ),
                        ),
                        Text(
                          Fmt.dateShort(slots[i]).split(' ').last,
                          style: TextStyle(
                            fontSize: 10.5,
                            color: selected
                                ? Colors.white70
                                : AppColors.textTertiary,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
          const SizedBox(height: AppSpacing.md),
          const _StepLabel(
              step: 2, title: 'Choose a time slot', subtitle: null),
          const SizedBox(height: AppSpacing.md),
          Wrap(
            spacing: AppSpacing.sm,
            runSpacing: AppSpacing.sm,
            children: [
              for (var i = 0; i < slotTimes.length; i++)
                ChoiceChip(
                  label: Text(slotTimes[i]),
                  selected: i == _timeIndex,
                  selectedColor: AppColors.primarySurface,
                  onSelected: (_) {
                    setState(() => _timeIndex = i);
                    lab.setSlotTime(slotTimes[i]);
                  },
                ),
            ],
          ),
          const SizedBox(height: AppSpacing.md),
          AppCard(
            color: AppColors.primarySurface,
            borderColor: AppColors.primary.withValues(alpha: 0.3),
            child: Row(
              children: [
                const Icon(Icons.event_available_rounded,
                    color: AppColors.primary, size: 20),
                const SizedBox(width: AppSpacing.md),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Collection scheduled for',
                        style: TextStyle(
                            fontSize: 11.5, color: AppColors.textSecondary),
                      ),
                      Text(
                        '${Fmt.date(slots[_dateIndex.clamp(0, slots.length - 1)])} · '
                        '${slotTimes[_timeIndex]}',
                        style: const TextStyle(
                            fontSize: 14, fontWeight: FontWeight.w700),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: AppSpacing.xl),
          const _StepLabel(step: 3, title: 'Collection address', subtitle: null),
          const SizedBox(height: AppSpacing.md),
          for (final a in saved.addresses)
            Padding(
              padding: const EdgeInsets.only(bottom: AppSpacing.sm),
              child: AppCard(
                onTap: () => setState(() => _addressId = a.id),
                color: a.id == _addressId
                    ? AppColors.primarySurface
                    : AppColors.surface,
                borderColor:
                    a.id == _addressId ? AppColors.primary : AppColors.border,
                padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.lg, vertical: AppSpacing.md),
                child: Row(
                  children: [
                    Icon(
                      a.id == _addressId
                          ? Icons.radio_button_checked_rounded
                          : Icons.radio_button_unchecked_rounded,
                      color: a.id == _addressId
                          ? AppColors.primary
                          : AppColors.borderStrong,
                      size: 20,
                    ),
                    const SizedBox(width: AppSpacing.md),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Text(a.name,
                                  style: const TextStyle(
                                      fontSize: 13.5,
                                      fontWeight: FontWeight.w700)),
                              const SizedBox(width: 6),
                              AppBadge(
                                  label: a.label,
                                  color: AppColors.textSecondary,
                                  dense: true),
                            ],
                          ),
                          Text(
                            a.oneLine,
                            style: const TextStyle(
                                fontSize: 11.5,
                                color: AppColors.textSecondary,
                                height: 1.4),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          const SizedBox(height: AppSpacing.md),
          CheckboxListTile(
            value: _accepting,
            onChanged: (v) => setState(() => _accepting = v ?? false),
            contentPadding: EdgeInsets.zero,
            controlAffinity: ListTileControlAffinity.leading,
            title: const Text(
              'I have read the preparation instructions',
              style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
            ),
            subtitle: const Text(
              'Required before the phlebotomist can collect your sample',
              style: TextStyle(fontSize: 11.5),
            ),
          ),
          const SizedBox(height: AppSpacing.lg),
          AppCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Price details',
                    style: Theme.of(context).textTheme.titleSmall),
                const SizedBox(height: AppSpacing.sm),
                InfoRow(label: 'Total tests', value: '${widget.tests.length}'),
                if (mrp > basePrice)
                  InfoRow(
                    label: 'Package discount',
                    value: '− ${Fmt.money(mrp - basePrice)}',
                    valueColor: AppColors.success,
                  ),
                if (pro.isPro)
                  InfoRow(
                    label: '1mg Pro (5%)',
                    value: '− ${Fmt.money(basePrice - price)}',
                    valueColor: AppColors.proGold,
                  ),
                InfoRow(
                  label: 'Home collection',
                  value: 'Free',
                  valueColor: AppColors.success,
                ),
                const Divider(height: AppSpacing.xl),
                InfoRow(
                  label: 'Total payable',
                  value: Fmt.money(price),
                  bold: true,
                ),
              ],
            ),
          ),
          if (needsFasting) ...[
            const SizedBox(height: AppSpacing.md),
            const NoticeBanner(
              color: AppColors.warning,
              icon: Icons.no_food_rounded,
              title: 'Remember to fast',
              message:
                  'This test requires 8–12 hours of fasting. Only plain water is '
                  'allowed. Taking a heavy or sweet meal before collection will '
                  'invalidate your results and you will need to re-book.',
            ),
          ],
        ],
      ),
      bottomNavigationBar: Container(
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
        child: FilledButton.icon(
          onPressed: _accepting
              ? () {
                  final id = lab.book(
                    testIds: widget.tests.map((t) => t.id).toList(),
                    bundleId: widget.bundle?.id,
                    name: widget.bundle?.name ??
                        (widget.tests.length == 1
                            ? widget.tests.first.name
                            : '${widget.tests.length} lab tests'),
                    slot: slots[_dateIndex.clamp(0, slots.length - 1)],
                    slotTime: slotTimes[_timeIndex],
                    address: address.oneLine,
                    price: price,
                    mrp: mrp,
                  );
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(
                      builder: (_) => LabResultScreen(
                        tests: widget.tests,
                        isSample: false,
                        bookingId: id,
                      ),
                    ),
                  );
                }
              : null,
          icon: const Icon(Icons.check_rounded, size: 19),
          label: Text(_accepting
              ? 'Confirm booking · ${Fmt.money(price)}'
              : 'Accept preparation instructions to continue'),
        ),
      ),
    );
  }
}

class _StepLabel extends StatelessWidget {
  const _StepLabel({required this.step, required this.title, this.subtitle});

  final int step;
  final String title;
  final String? subtitle;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 22,
          height: 22,
          alignment: Alignment.center,
          decoration: const BoxDecoration(
            color: AppColors.primary,
            shape: BoxShape.circle,
          ),
          child: Text('$step',
              style: const TextStyle(
                  color: Colors.white,
                  fontSize: 11,
                  fontWeight: FontWeight.w700)),
        ),
        const SizedBox(width: AppSpacing.md),
        Expanded(
          child: Text(title,
              style: const TextStyle(
                  fontSize: 14.5, fontWeight: FontWeight.w700)),
        ),
        if (subtitle != null)
          Text(subtitle!,
              style: const TextStyle(
                  fontSize: 11.5, color: AppColors.textTertiary)),
      ],
    );
  }
}
