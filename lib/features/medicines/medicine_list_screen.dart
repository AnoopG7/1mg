import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_spacing.dart';
import '../../core/utils/formatters.dart';
import '../../data/mock_medicines.dart';
import '../../models/cart_item.dart';
import '../../models/medicine.dart';
import '../../models/pregnancy_category.dart';
import '../../providers/cart_provider.dart';
import '../../providers/pro_provider.dart';
import '../../providers/saved_provider.dart';
import '../../shared/widgets/badges.dart';
import '../../shared/widgets/common.dart';
import '../home/home_screen.dart' show PillVisual;
import 'medicine_detail_screen.dart';

class MedicineListScreen extends StatefulWidget {
  const MedicineListScreen({super.key, this.initialCategory});

  final String? initialCategory;

  @override
  State<MedicineListScreen> createState() => _MedicineListScreenState();
}

class _MedicineListScreenState extends State<MedicineListScreen> {
  late final TextEditingController _controller = TextEditingController();
  late String _query = '';
  late String _category = widget.initialCategory ?? 'All';
  String? _pregnancyFilter;

  static final List<String> _categories = [
    'All',
    ...MedicineCategory.all.map((c) => c.name),
  ];

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  List<Medicine> get _filtered {
    final q = _query.trim().toLowerCase();
    return MockMedicines.all.where((m) {
      if (_category != 'All' && m.category != _category) return false;
      if (_pregnancyFilter != null &&
          m.pregnancyCategory.label != _pregnancyFilter) {
        return false;
      }
      if (q.isEmpty) return true;
      return m.searchText.contains(q);
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    final results = _filtered;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Medicine information'),
        actions: [
          IconButton(
            tooltip: 'Filter by pregnancy safety',
            onPressed: () => _showPregnancyFilter(context),
            icon: const Icon(Icons.filter_list_rounded),
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(
              AppSpacing.pageH,
              AppSpacing.sm,
              AppSpacing.pageH,
              AppSpacing.md,
            ),
            child: TextField(
              controller: _controller,
              onChanged: (v) => setState(() => _query = v),
              decoration: InputDecoration(
                hintText: 'Search by name, generic or use',
                prefixIcon: const Icon(Icons.search_rounded),
                suffixIcon: _query.isEmpty
                    ? null
                    : IconButton(
                        icon: const Icon(Icons.close_rounded),
                        onPressed: () {
                          _controller.clear();
                          setState(() => _query = '');
                        },
                      ),
              ),
            ),
          ),
          if (_pregnancyFilter != null)
            Padding(
              padding: const EdgeInsets.fromLTRB(
                AppSpacing.pageH,
                0,
                AppSpacing.pageH,
                AppSpacing.sm,
              ),
              child: Row(
                children: [
                  AppBadge(
                    label: 'Pregnancy $_pregnancyFilter only',
                    color: PregnancyCategory.values
                        .firstWhere((c) => c.label == _pregnancyFilter)
                        .color,
                  ),
                  const Spacer(),
                  TextButton(
                    onPressed: () => setState(() => _pregnancyFilter = null),
                    child: const Text('Clear'),
                  ),
                ],
              ),
            ),
          FilterChipRow(
            items: _categories,
            selected: _category,
            onSelect: (c) => setState(() => _category = c),
          ),
          const SizedBox(height: AppSpacing.md),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.pageH),
            child: Row(
              children: [
                Flexible(
                  child: Text(
                    '${results.length} medicines',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                ),
                const Spacer(),
                const AppBadge(
                  label: 'Offline database',
                  icon: Icons.offline_bolt_rounded,
                  color: AppColors.secondary,
                ),
              ],
            ),
          ),
          const SizedBox(height: AppSpacing.sm),
          Expanded(
            child: results.isEmpty
                ? const EmptyState(
                    icon: Icons.search_off_rounded,
                    title: 'No medicines found',
                    message:
                        'Try a different search term or clear the filters.',
                  )
                : ListView.separated(
                    padding: const EdgeInsets.fromLTRB(
                      AppSpacing.pageH,
                      0,
                      AppSpacing.pageH,
                      AppSpacing.xxl,
                    ),
                    itemCount: results.length,
                    separatorBuilder: (_, _) =>
                        const SizedBox(height: AppSpacing.md),
                    itemBuilder: (context, i) =>
                        _MedicineCard(medicine: results[i]),
                  ),
          ),
        ],
      ),
    );
  }

  void _showPregnancyFilter(BuildContext context) {
    showModalBottomSheet<void>(
      context: context,
      builder: (sheetContext) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.xl),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Pregnancy safety rating',
                style: Theme.of(context).textTheme.titleLarge,
              ),
              const SizedBox(height: 4),
              Text(
                'Filter medicines by their FDA-style pregnancy category.',
                style: Theme.of(context).textTheme.bodySmall,
              ),
              const SizedBox(height: AppSpacing.lg),
              for (final c in PregnancyCategory.values)
                ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: Container(
                    width: 34,
                    height: 34,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: c.color,
                      shape: BoxShape.circle,
                    ),
                    child: Text(
                      c.label,
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                  title: Text(
                    c.description,
                    style: const TextStyle(fontSize: 13.5),
                  ),
                  trailing: _pregnancyFilter == c.label
                      ? Icon(Icons.check_circle_rounded, color: c.color)
                      : null,
                  onTap: () {
                    setState(() {
                      _pregnancyFilter = _pregnancyFilter == c.label
                          ? null
                          : c.label;
                    });
                    Navigator.pop(sheetContext);
                  },
                ),
              if (_pregnancyFilter != null)
                TextButton(
                  onPressed: () {
                    setState(() => _pregnancyFilter = null);
                    Navigator.pop(sheetContext);
                  },
                  child: const Text('Clear filter'),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

class _MedicineCard extends StatelessWidget {
  const _MedicineCard({required this.medicine});

  final Medicine medicine;

  @override
  Widget build(BuildContext context) {
    final pro = context.watch<ProProvider>();
    final saved = context.watch<SavedProvider>();
    final cart = context.watch<CartProvider>();
    final inCart = cart.contains(medicine.id);
    final price = pro.isPro ? medicine.price * 0.95 : medicine.price;

    return AppCard(
      onTap: () => Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => MedicineDetailScreen(medicine: medicine),
        ),
      ),
      child: Column(
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              PillVisual(medicine: medicine, size: 52),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Flexible(
                          child: Text(
                            medicine.name,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              fontSize: 14.5,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                        if (medicine.rx)
                          const Padding(
                            padding: EdgeInsets.only(left: 6),
                            child: AppBadge(
                              label: 'Rx',
                              color: AppColors.info,
                              dense: true,
                            ),
                          )
                        else
                          const Padding(
                            padding: EdgeInsets.only(left: 6),
                            child: AppBadge(
                              label: 'OTC',
                              color: AppColors.success,
                              dense: true,
                            ),
                          ),
                      ],
                    ),
                    const SizedBox(height: 2),
                    Text(
                      '${medicine.genericName} · ${medicine.strength}',
                      style: const TextStyle(
                        fontSize: 12,
                        color: AppColors.textSecondary,
                      ),
                    ),
                    Text(
                      '${medicine.form} · ${medicine.manufacturer}',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 11,
                        color: AppColors.textTertiary,
                      ),
                    ),
                    const SizedBox(height: AppSpacing.sm),
                    Row(
                      children: [
                        const Icon(
                          Icons.star_rounded,
                          size: 14,
                          color: AppColors.warning,
                        ),
                        const SizedBox(width: 3),
                        Flexible(
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                '${medicine.rating}',
                                style: const TextStyle(
                                  fontSize: 11.5,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              Flexible(
                                child: Text(
                                  ' (${Fmt.compact(medicine.reviewCount)})',
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: const TextStyle(
                                    fontSize: 10.5,
                                    color: AppColors.textTertiary,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        const Spacer(),
                        Flexible(
                          child: PregnancyBadge(
                            category: medicine.pregnancyCategory,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              IconButton(
                padding: const EdgeInsets.all(4),
                constraints: const BoxConstraints(minWidth: 40, minHeight: 40),
                onPressed: () => saved.toggleMedicine(medicine.id),
                icon: Icon(
                  saved.isMedicineSaved(medicine.id)
                      ? Icons.bookmark_rounded
                      : Icons.bookmark_border_rounded,
                  size: 20,
                  color: saved.isMedicineSaved(medicine.id)
                      ? AppColors.primary
                      : AppColors.textTertiary,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.md),
          const Divider(),
          const SizedBox(height: AppSpacing.md),
          Row(
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(
                        Fmt.money(price),
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      if (medicine.mrp > price) ...[
                        const SizedBox(width: 6),
                        Text(
                          Fmt.money(medicine.mrp),
                          style: const TextStyle(
                            fontSize: 11.5,
                            color: AppColors.textTertiary,
                            decoration: TextDecoration.lineThrough,
                          ),
                        ),
                      ],
                    ],
                  ),
                  Text(
                    inCart
                        ? 'In cart · ${cart.itemById(medicine.id)?.quantity} unit(s)'
                        : medicine.interactions.isNotEmpty
                        ? '${medicine.interactions.length} known interactions'
                        : 'No known interactions',
                    style: const TextStyle(
                      fontSize: 10.5,
                      color: AppColors.textTertiary,
                    ),
                  ),
                ],
              ),
              const Spacer(),
              FilledButton.icon(
                onPressed: () {
                  cart.add(CartSeed.medicine(medicine, price));
                  ScaffoldMessenger.of(context)
                    ..hideCurrentSnackBar()
                    ..showSnackBar(
                      SnackBar(content: Text('${medicine.name} added to cart')),
                    );
                },
                style: FilledButton.styleFrom(
                  minimumSize: const Size(0, 38),
                  padding: const EdgeInsets.symmetric(horizontal: 14),
                ),
                icon: Icon(
                  inCart ? Icons.check_rounded : Icons.add_rounded,
                  size: 16,
                ),
                label: Text(inCart ? 'Add more' : 'Add'),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

/// Small helper that builds a [CartItem] for a medicine at a given price.
class CartSeed {
  const CartSeed._();

  static CartItem medicine(Medicine m, double price) => CartItem(
    id: m.id,
    title: m.name,
    subtitle: '${m.genericName} ${m.strength}',
    kind: CartItemKind.medicine,
    unitPrice: price,
    mrp: m.mrp,
    quantity: 1,
    medicineId: m.id,
    isPrescription: m.rx,
  );
}
