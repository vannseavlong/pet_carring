import 'package:flutter/material.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_spacing.dart';
import '../../theme/app_typography.dart';

class HomeHeader extends StatelessWidget {
  const HomeHeader({super.key});


  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        // Avatar
        CircleAvatar(
          radius: 24,
          backgroundImage: const NetworkImage(
            'https://i.pravatar.cc/150?img=3',
          ),
        ),
        const SizedBox(width: AppSpacing.md),
        // Greeting + name
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Good morning,',
                style: AppTypography.micro.copyWith(color: AppColors.mist),
              ),
              Text(
                'Alex 🐾',
                style: AppTypography.display.copyWith(
                  fontSize: 24,
                  color: AppColors.creamWarm,
                ),
              ),
            ],
          ),
        ),
        // Notification bell with badge
        Stack(
          children: [
            Container(
              width: 44,
              height: 44,
              decoration: const BoxDecoration(
                color: AppColors.blushSoft,
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.notifications_outlined, color: AppColors.ink),
            ),
            Positioned(
              right: 0,
              top: 0,
              child: Container(
                width: 18,
                height: 18,
                decoration: const BoxDecoration(
                  color: AppColors.amberAccent,
                  shape: BoxShape.circle,
                ),
                child: Center(
                  child: Text(
                    '3',
                    style: AppTypography.micro.copyWith(color: Colors.white),
                  ),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }
}

