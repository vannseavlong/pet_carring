import 'package:flutter/material.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_spacing.dart';
import '../../theme/app_typography.dart';

class StatusCard extends StatelessWidget {
  const StatusCard({super.key});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 36,
          height: 36,
          decoration: const BoxDecoration(
            color: AppColors.sageMid,
            shape: BoxShape.circle,
          ),
          child: const Icon(Icons.pets, color: AppColors.creamWarm, size: 18),
        ),
        const SizedBox(width: AppSpacing.md),
        Expanded(
          child: RichText(
            text: TextSpan(
              children: [
                TextSpan(
                  text: '3 pets checked in',
                  style: AppTypography.bodyMedium.copyWith(
                    color: AppColors.creamWarm,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                TextSpan(
                  text: '  ·  2 spots left',
                  style: AppTypography.bodyMedium.copyWith(
                    color: AppColors.mist,
                  ),
                ),
              ],
            ),
          ),
        ),
        GestureDetector(
          onTap: () {},
          child: Text(
            'View →',
            style: AppTypography.bodyMedium.copyWith(
              color: AppColors.amberAccent,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ],
    );
  }
}
