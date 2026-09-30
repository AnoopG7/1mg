import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_spacing.dart';

/// The "1" brand mark used in app bars, headers and empty states.
class BrandMark extends StatelessWidget {
  const BrandMark({super.key, this.size = 32});

  final double size;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [AppColors.primary, Color(0xFFFF8A3D)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(size * 0.3),
      ),
      child: Text(
        '1',
        style: GoogleFonts.poppins(
          fontSize: size * 0.5,
          fontWeight: FontWeight.w700,
          color: Colors.white,
          height: 1,
        ),
      ),
    );
  }
}

/// Compact "1mg Health" wordmark with the brand mark.
class BrandLockup extends StatelessWidget {
  const BrandLockup({super.key, this.showLocation = true});

  final bool showLocation;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        const BrandMark(size: 34),
        const SizedBox(width: AppSpacing.sm),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '1mg Health',
                style: Theme.of(context).textTheme.titleMedium,
              ),
              Text(
                showLocation
                    ? 'Mumbai · Delivery in 24h'
                    : 'Your health companion',
                style: Theme.of(context).textTheme.bodySmall,
              ),
            ],
          ),
        ),
      ],
    );
  }
}
