import 'package:flutter/material.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_spacing.dart';
import '../../theme/app_typography.dart';

class StatusCard extends StatelessWidget {
  const StatusCard({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: AppColors.sageDeep,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          const Icon(Icons.pets, color: AppColors.creamWarm, size: 22),
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
      ),
    );
  }
}
