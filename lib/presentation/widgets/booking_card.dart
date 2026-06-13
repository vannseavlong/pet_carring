import 'package:flutter/material.dart';
import '../../domain/entities/pet_booking.dart';
import '../theme/app_colors.dart';
import '../theme/app_spacing.dart';
import '../theme/app_typography.dart';

class BookingCard extends StatelessWidget {
  final PetBooking booking;
  final VoidCallback onTap;

  const BookingCard({super.key, required this.booking, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(
        horizontal: AppSpacing.md,
        vertical: AppSpacing.sm,
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.md),
          child: Row(
            children: [
              _PetAvatar(petType: booking.petType),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(booking.petName, style: AppTypography.sectionHeader),
                    const SizedBox(height: AppSpacing.xs),
                    Text(
                      'Owner: ${booking.ownerName}',
                      style: AppTypography.bodyMedium,
                    ),
                    const SizedBox(height: AppSpacing.xs),
                    Text(
                      '${booking.totalDays} days · \$${booking.totalCharge.toStringAsFixed(2)}',
                      style: AppTypography.dataMono
                          .copyWith(color: AppColors.sageMid),
                    ),
                  ],
                ),
              ),
              const Icon(Icons.chevron_right, color: AppColors.mist),
            ],
          ),
        ),
      ),
    );
  }
}

class _PetAvatar extends StatelessWidget {
  final String petType;
  const _PetAvatar({required this.petType});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 48,
      height: 48,
      decoration: BoxDecoration(
        color: AppColors.sageMid.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Center(
        child: Text(
          petType.toLowerCase() == 'dog' ? '🐶' : '🐱',
          style: const TextStyle(fontSize: 24),
        ),
      ),
    );
  }
}
