import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_spacing.dart';
import '../../data/mock_medicines.dart';
import '../../models/medicine.dart';
import '../../providers/saved_provider.dart';
import '../../shared/widgets/common.dart';
import '../home/home_screen.dart' show PillVisual;
import '../medicines/medicine_detail_screen.dart';
import '../medicines/medicine_list_screen.dart';

/// All medicines bookmarked from the "Saved medicines" profile row.
class SavedMedicinesScreen extends StatelessWidget {
  const SavedMedicinesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final saved = context.watch<SavedProvider>();
    final meds = saved.medicineIds
        .map(MockMedicines.byId)
        .whereType<Medicine>()
        .toList();

    return Scaffold(
      appBar: AppBar(title: const Text('Saved medicines')),
      body: meds.isEmpty
          ? EmptyState(
              icon: Icons.favorite_border_rounded,
              title: 'No saved medicines',
              message:
                  'Tap the bookmark on any medicine to save it here for quick '
                  'access later.',
              actionLabel: 'Browse medicines',
              onAction: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const MedicineListScreen()),
              ),
            )
          : ListView.separated(
              padding: const EdgeInsets.fromLTRB(
                AppSpacing.pageH,
                AppSpacing.lg,
                AppSpacing.pageH,
                AppSpacing.xxl,
              ),
              itemCount: meds.length,
              separatorBuilder: (_, _) => const SizedBox(height: AppSpacing.sm),
              itemBuilder: (context, i) {
                final m = meds[i];
                return AppCard(
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => MedicineDetailScreen(medicine: m),
                    ),
                  ),
                  child: Row(
                    children: [
                      PillVisual(medicine: m, size: 36),
                      const SizedBox(width: AppSpacing.md),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              m.name,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                fontSize: 13.5,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                            Text(
                              '${m.genericName} · ${m.strength}',
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                fontSize: 11.5,
                                color: AppColors.textSecondary,
                              ),
                            ),
                            Text(
                              m.form,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                fontSize: 11,
                                color: AppColors.textTertiary,
                              ),
                            ),
                          ],
                        ),
                      ),
                      IconButton(
                        tooltip: 'Remove from saved',
                        padding: const EdgeInsets.all(4),
                        constraints: const BoxConstraints(
                          minWidth: 40,
                          minHeight: 40,
                        ),
                        onPressed: () => saved.toggleMedicine(m.id),
                        icon: const Icon(
                          Icons.bookmark_rounded,
                          size: 20,
                          color: AppColors.primary,
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
    );
  }
}
