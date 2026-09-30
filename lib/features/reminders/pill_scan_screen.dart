import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import '../../core/services/pill_recognizer.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_spacing.dart';
import '../../data/mock_medicines.dart';
import '../../models/medicine.dart';
import '../../models/reminder.dart';
import '../../shared/widgets/badges.dart';
import '../../shared/widgets/common.dart';
import '../medicines/medicine_detail_screen.dart';
import 'add_reminder_screen.dart';

enum _ScanState { idle, picking, analysing, done }

/// Pill image recognition: pick or capture a photo, then get ranked matches.
class PillScanScreen extends StatefulWidget {
  const PillScanScreen({super.key});

  @override
  State<PillScanScreen> createState() => _PillScanScreenState();
}

class _PillScanScreenState extends State<PillScanScreen> {
  final _picker = ImagePicker();
  final _recognizer = const PillRecognizer();

  _ScanState _state = _ScanState.idle;
  Uint8List? _imageBytes;
  List<PillMatch> _matches = const [];
  String _fingerprint = '';

  Future<void> _pick(ImageSource source) async {
    setState(() => _state = _ScanState.picking);
    try {
      final file = await _picker.pickImage(
        source: source,
        maxWidth: 1200,
        imageQuality: 80,
      );
      if (file == null) {
        setState(() => _state = _ScanState.idle);
        return;
      }
      final bytes = await file.readAsBytes();
      await _run(bytes);
    } catch (e) {
      if (!mounted) return;
      setState(() => _state = _ScanState.idle);
      ScaffoldMessenger.of(context)
        ..hideCurrentSnackBar()
        ..showSnackBar(
          SnackBar(
            content: Text('Could not open the camera on this device. '
                'Try a sample pill below.'),
          ),
        );
    }
  }

  Future<void> _runSample(Medicine m) async {
    setState(() => _state = _ScanState.analysing);
    final matches = await _recognizer.recogniseSample(m.id);
    if (!mounted) return;
    setState(() {
      _matches = matches;
      _state = _ScanState.done;
      _fingerprint = 'DEMO-${m.id}';
      _imageBytes = null;
    });
  }

  Future<void> _run(Uint8List bytes) async {
    setState(() {
      _state = _ScanState.analysing;
      _imageBytes = bytes;
    });
    final matches = await _recognizer.recognise(bytes);
    if (!mounted) return;
    setState(() {
      _matches = matches;
      _state = _ScanState.done;
      _fingerprint = PillRecognizer.fingerprint(bytes);
    });
  }

  void _reset() {
    setState(() {
      _state = _ScanState.idle;
      _imageBytes = null;
      _matches = const [];
      _fingerprint = '';
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Identify your pill'),
        actions: [
          if (_state != _ScanState.idle)
            TextButton(onPressed: _reset, child: const Text('Scan again')),
        ],
      ),
      body: switch (_state) {
        _ScanState.idle => _idleView(context),
        _ScanState.picking => const Center(child: CircularProgressIndicator()),
        _ScanState.analysing => _analysingView(),
        _ScanState.done => _resultView(),
      },
    );
  }

  Widget _idleView(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.fromLTRB(
          AppSpacing.pageH, AppSpacing.lg, AppSpacing.pageH, AppSpacing.xxl),
      children: [
        Container(
          height: 240,
          decoration: BoxDecoration(
            color: AppColors.purpleSurface,
            borderRadius: BorderRadius.circular(AppRadius.lg),
          ),
          child: Stack(
            alignment: Alignment.center,
            children: [
              Icon(Icons.medication_rounded,
                  size: 90, color: AppColors.purple.withValues(alpha: 0.28)),
              CustomPaint(
                size: const Size(200, 140),
                painter: _ScannerOverlayPainter(),
              ),
              const Positioned(
                bottom: AppSpacing.lg,
                child: Text(
                  'Place the pill inside the frame',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: AppColors.purple,
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: AppSpacing.xl),
        Text('Recognise any medicine from its photo',
            style: Theme.of(context).textTheme.titleLarge),
        const SizedBox(height: 4),
        Text(
          'Our recognition engine matches the pill\'s shape, colour, imprint and '
          'composition against the medicine database, and gives you the closest '
          'matches with a confidence score.',
          style: Theme.of(context).textTheme.bodyMedium,
        ),
        const SizedBox(height: AppSpacing.xl),
        Row(
          children: [
            Expanded(
              child: FilledButton.icon(
                onPressed: () => _pick(ImageSource.camera),
                icon: const Icon(Icons.photo_camera_rounded, size: 19),
                label: const Text('Camera'),
              ),
            ),
            const SizedBox(width: AppSpacing.md),
            Expanded(
              child: OutlinedButton.icon(
                onPressed: () => _pick(ImageSource.gallery),
                icon: const Icon(Icons.photo_library_rounded, size: 19),
                label: const Text('Gallery'),
              ),
            ),
          ],
        ),
        const SizedBox(height: AppSpacing.xl),
        const Row(
          children: [
            Expanded(child: Divider()),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: AppSpacing.md),
              child: Text(
                'or try a sample',
                style: TextStyle(fontSize: 11.5, color: AppColors.textTertiary),
              ),
            ),
            Expanded(child: Divider()),
          ],
        ),
        const SizedBox(height: AppSpacing.md),
        AppCard(
          color: AppColors.warningSurface,
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Icon(Icons.science_rounded,
                  size: 18, color: AppColors.warning),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Demo mode',
                      style: Theme.of(context).textTheme.titleSmall,
                    ),
                    const SizedBox(height: 2),
                    Text(
                      'Recognition runs locally in this college project. If you '
                      'have no camera, pick a sample pill to see the matching '
                      'flow — the result is deterministic for the same pill.',
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                    const SizedBox(height: AppSpacing.md),
                    Wrap(
                      spacing: AppSpacing.sm,
                      runSpacing: AppSpacing.sm,
                      children: [
                        for (final m in MockMedicines.all.take(4))
                          ActionChip(
                            label: Text(m.name),
                            onPressed: () => _runSample(m),
                          ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _analysingView() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.xxl),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (_imageBytes != null)
              Container(
                height: 140,
                width: 200,
                decoration: BoxDecoration(
                  color: AppColors.surfaceAlt,
                  borderRadius: BorderRadius.circular(AppRadius.md),
                ),
                child: const Center(
                  child: Icon(Icons.image_rounded,
                      size: 40, color: AppColors.textTertiary),
                ),
              ),
            const SizedBox(height: AppSpacing.xl),
            const SizedBox(
              width: 44,
              height: 44,
              child: CircularProgressIndicator(strokeWidth: 3),
            ),
            const SizedBox(height: AppSpacing.lg),
            Text('Analysing the pill image',
                style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: AppSpacing.sm),
            const Text(
              'Extracting shape, colour and imprint, then matching against the '
              'medicine database…',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 13, color: AppColors.textSecondary),
            ),
          ],
        ),
      ),
    );
  }

  Widget _resultView() {
    final top = _matches.isEmpty ? null : _matches.first;

    return ListView(
      padding: const EdgeInsets.fromLTRB(
          AppSpacing.pageH, AppSpacing.lg, AppSpacing.pageH, AppSpacing.xxl),
      children: [
        if (top != null) _TopMatchCard(match: top, fingerprint: _fingerprint),
        const SizedBox(height: AppSpacing.lg),
        Row(
          children: [
            Text('Other possible matches',
                style: Theme.of(context).textTheme.titleMedium),
            const Spacer(),
            Text('${_matches.length} results',
                style: Theme.of(context).textTheme.bodySmall),
          ],
        ),
        const SizedBox(height: 4),
        Text(
          'Confidence is the engine\'s estimate. Always confirm the imprint code '
          'printed on the pill before taking it.',
          style: Theme.of(context).textTheme.bodySmall,
        ),
        const SizedBox(height: AppSpacing.md),
        for (final m in _matches.skip(1))
          Padding(
            padding: const EdgeInsets.only(bottom: AppSpacing.sm),
            child: _MatchRow(match: m),
          ),
        const SizedBox(height: AppSpacing.lg),
        const NoticeBanner(
          color: AppColors.danger,
          icon: Icons.gpp_maybe_rounded,
          title: 'Safety warning',
          message:
              'Never take a medicine identified only by a photo. Check the '
              'imprint, expiry and manufacturer printed on the strip, and ask a '
              'pharmacist if anything does not match.',
        ),
      ],
    );
  }
}

class _TopMatchCard extends StatelessWidget {
  const _TopMatchCard({required this.match, required this.fingerprint});

  final PillMatch match;
  final String fingerprint;

  @override
  Widget build(BuildContext context) {
    final color = match.confidence >= 70
        ? AppColors.success
        : match.confidence >= 45
            ? AppColors.warning
            : AppColors.textTertiary;

    return Container(
      padding: const EdgeInsets.all(AppSpacing.xl),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.07),
        borderRadius: BorderRadius.circular(AppRadius.lg),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.check_circle_rounded, size: 18, color: AppColors.success),
              const SizedBox(width: 6),
              Text(
                'Best match',
                style: TextStyle(
                  fontSize: 11.5,
                  fontWeight: FontWeight.w700,
                  color: color,
                ),
              ),
              const Spacer(),
              if (fingerprint.isNotEmpty)
                Text(
                  'ID $fingerprint',
                  style: const TextStyle(
                      fontSize: 10, color: AppColors.textTertiary),
                ),
            ],
          ),
          const SizedBox(height: AppSpacing.md),
          Text(
            match.medicineName,
            style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w700),
          ),
          Text(
            '${match.genericName} · ${match.strength}',
            style: const TextStyle(fontSize: 13, color: AppColors.textSecondary),
          ),
          const SizedBox(height: AppSpacing.md),
          Wrap(
            spacing: AppSpacing.sm,
            runSpacing: AppSpacing.sm,
            children: [
              AppBadge(label: match.form, icon: Icons.medication_rounded),
              AppBadge(
                  label: match.shape, icon: Icons.circle_outlined,
                  color: AppColors.purple),
              AppBadge(
                  label: match.colorName, icon: Icons.palette_rounded,
                  color: AppColors.info),
            ],
          ),
          const SizedBox(height: AppSpacing.lg),
          Row(
            children: [
              Text('${match.confidence}% confidence',
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    color: color,
                  )),
              const Spacer(),
              Text(
                PillRecognizer.confidenceLabel(match.confidence),
                style: const TextStyle(
                    fontSize: 11, color: AppColors.textTertiary),
              ),
            ],
          ),
          const SizedBox(height: 6),
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: match.confidence / 100,
              minHeight: 7,
              backgroundColor: Colors.white,
              valueColor: AlwaysStoppedAnimation(color),
            ),
          ),
          const SizedBox(height: AppSpacing.lg),
          Text('Manufacturer: ${match.manufacturer}',
              style: const TextStyle(
                  fontSize: 11.5, color: AppColors.textTertiary)),
          const SizedBox(height: AppSpacing.lg),
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () {
                    final med = MockMedicines.byId(match.medicineId);
                    if (med == null) return;
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => AddReminderScreen(
                          medicine: med,
                          scanned: true,
                        ),
                      ),
                    );
                  },
                  icon: const Icon(Icons.alarm_add_rounded, size: 18),
                  label: const Text('Set reminder'),
                ),
              ),
              const SizedBox(width: AppSpacing.sm),
              Expanded(
                child: FilledButton.icon(
                  onPressed: () {
                    final med = MockMedicines.byId(match.medicineId);
                    if (med == null) return;
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => MedicineDetailScreen(medicine: med)),
                      );
                  },
                  icon: const Icon(Icons.info_rounded, size: 18),
                  label: const Text('Details'),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _MatchRow extends StatelessWidget {
  const _MatchRow({required this.match});

  final PillMatch match;

  @override
  Widget build(BuildContext context) {
    return AppCard(
      padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.lg, vertical: AppSpacing.md),
      onTap: () {
        final med = MockMedicines.byId(match.medicineId);
        if (med == null) return;
        Navigator.push(
          context,
          MaterialPageRoute(
              builder: (_) => MedicineDetailScreen(medicine: med)),
        );
      },
      child: Row(
        children: [
          Container(
            width: 34,
            height: 34,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: AppColors.surfaceAlt,
              borderRadius: BorderRadius.circular(AppRadius.sm),
            ),
            child: const Icon(Icons.medication_rounded,
                size: 17, color: AppColors.purple),
          ),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  match.medicineName,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                      fontSize: 13.5, fontWeight: FontWeight.w600),
                ),
                Text(
                  '${match.strength} · ${match.form} · ${match.shape}',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                      fontSize: 11, color: AppColors.textTertiary),
                ),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                '${match.confidence}%',
                style: const TextStyle(
                    fontSize: 14, fontWeight: FontWeight.w700),
              ),
              Text(
                PillRecognizer.confidenceLabel(match.confidence),
                style: const TextStyle(
                    fontSize: 9.5, color: AppColors.textTertiary),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

/// Dashed scanning frame with a moving scan line.
class _ScannerOverlayPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = AppColors.purple
      ..strokeWidth = 2.5
      ..style = PaintingStyle.stroke;

    const corner = 22.0;
    final rect = Rect.fromLTWH(0, 0, size.width, size.height);

    // Corner brackets
    final path = Path()
      ..moveTo(0, corner)
      ..lineTo(0, 0)
      ..lineTo(corner, 0)
      ..moveTo(size.width - corner, 0)
      ..lineTo(size.width, 0)
      ..lineTo(size.width, corner)
      ..moveTo(size.width, size.height - corner)
      ..lineTo(size.width, size.height)
      ..lineTo(size.width - corner, size.height)
      ..moveTo(corner, size.height)
      ..lineTo(0, size.height)
      ..lineTo(0, size.height - corner);
    canvas.drawPath(path, paint);

    // Inner guide
    final guide = Paint()
      ..color = AppColors.purple.withValues(alpha: 0.25)
      ..strokeWidth = 1
      ..style = PaintingStyle.stroke;
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        rect.deflate(1.5),
        const Radius.circular(12),
      ),
      guide,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
