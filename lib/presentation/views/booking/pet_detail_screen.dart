import 'package:flutter/material.dart';
import '../../../core/utils/date_formatter.dart';
import '../../../domain/entities/pet_booking.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_spacing.dart';
import '../../theme/app_typography.dart';

class PetDetailScreen extends StatelessWidget {
  final PetBooking booking;
  const PetDetailScreen({super.key, required this.booking});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("${booking.petName}'s Stay")),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppSpacing.md),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _PetHeader(booking: booking),
            const SizedBox(height: AppSpacing.lg),
            _DetailSection(booking: booking),
            const SizedBox(height: AppSpacing.lg),
            _ChargeSection(booking: booking),
          ],
        ),
      ),
    );
  }
}

class _PetHeader extends StatelessWidget {
  final PetBooking booking;
  const _PetHeader({required this.booking});

  @override
  Widget build(BuildContext context) {
    final isActive = booking.status == 'active';
    return Container(
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        color: AppColors.blushSoft,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.mist),
      ),
      child: Row(
        children: [
          Container(
            width: 64,
            height: 64,
            decoration: BoxDecoration(
              color: AppColors.sageMid.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Center(
              child: Text(
                booking.petType.toLowerCase() == 'dog' ? '🐶' : '🐱',
                style: const TextStyle(fontSize: 32),
              ),
            ),
          ),
          const SizedBox(width: AppSpacing.md),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                booking.petName,
                style: AppTypography.display.copyWith(fontSize: 28),
              ),
              Text(
                booking.petType,
                style: AppTypography.bodyMedium.copyWith(
                  color: AppColors.sageMid,
                ),
              ),
              const SizedBox(height: AppSpacing.xs),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.sm,
                  vertical: 2,
                ),
                decoration: BoxDecoration(
                  color: isActive
                      ? AppColors.sageMid.withValues(alpha: 0.15)
                      : AppColors.mist.withValues(alpha: 0.3),
                  borderRadius: BorderRadius.circular(100),
                ),
                child: Text(
                  booking.status.toUpperCase(),
                  style: AppTypography.micro.copyWith(
                    color: isActive ? AppColors.sageMid : AppColors.mist,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _DetailSection extends StatelessWidget {
  final PetBooking booking;
  const _DetailSection({required this.booking});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Stay Details', style: AppTypography.sectionHeader),
        const SizedBox(height: AppSpacing.md),
        const Divider(color: AppColors.mist),
        _DetailRow(label: 'Owner', value: booking.ownerName),
        _DetailRow(
          label: 'Check In',
          value: DateFormatter.toDisplay(booking.checkInDate),
        ),
        _DetailRow(
          label: 'Check Out',
          value: DateFormatter.toDisplay(booking.checkOutDate),
        ),
        _DetailRow(label: 'Total Days', value: '${booking.totalDays} days'),
      ],
    );
  }
}

class _ChargeSection extends StatelessWidget {
  final PetBooking booking;
  const _ChargeSection({required this.booking});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        color: AppColors.sageDeep,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Daily Rate',
                style: AppTypography.micro.copyWith(color: AppColors.mist),
              ),
              Text(
                '\$${booking.dailyRate.toStringAsFixed(2)}/day',
                style: AppTypography.dataMono.copyWith(
                  color: AppColors.creamWarm,
                ),
              ),
            ],
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                'Total Charge',
                style: AppTypography.micro.copyWith(color: AppColors.mist),
              ),
              Text(
                '\$${booking.totalCharge.toStringAsFixed(2)}',
                style: AppTypography.display.copyWith(
                  color: AppColors.amberAccent,
                  fontSize: 28,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _DetailRow extends StatelessWidget {
  final String label;
  final String value;
  const _DetailRow({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: AppSpacing.sm),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: AppTypography.bodyMedium.copyWith(color: AppColors.mist),
          ),
          Text(value, style: AppTypography.bodyMedium),
        ],
      ),
    );
  }
}
