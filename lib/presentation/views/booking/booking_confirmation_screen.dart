import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../core/utils/date_formatter.dart';
import '../../../core/utils/pet_types.dart';
import '../../../domain/entities/pet_booking.dart';
import '../../../domain/entities/shop.dart';
import '../../controllers/navigation_controller.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_spacing.dart';
import '../../theme/app_typography.dart';
import '../app/app_screen.dart';

typedef BookingConfirmationArgs = ({PetBooking booking, Shop shop});

class BookingConfirmationScreen extends StatelessWidget {
  final PetBooking booking;
  final Shop shop;

  const BookingConfirmationScreen({
    super.key,
    required this.booking,
    required this.shop,
  });

  void _goToBookings() {
    Get.find<NavigationController>().changePage(2);
    Get.offAll(() => const AppScreen());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.creamWarm,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.lg),
          child: Column(
            children: [
              const Spacer(),
              Container(
                width: 88,
                height: 88,
                decoration: const BoxDecoration(
                  color: AppColors.sageDeep,
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.check, color: Colors.white, size: 44),
              ),
              const SizedBox(height: AppSpacing.lg),
              Text(
                'Booking Confirmed!',
                style: AppTypography.display.copyWith(fontSize: 26),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: AppSpacing.sm),
              Text(
                'We’ve sent the details to ${shop.name}.',
                style: AppTypography.bodyMedium.copyWith(
                  color: AppColors.sageMid,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: AppSpacing.xl),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(AppSpacing.lg),
                decoration: BoxDecoration(
                  color: AppColors.blushSoft,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: AppColors.mist),
                ),
                child: Column(
                  children: [
                    _Row(
                      label: 'Pet',
                      value:
                          '${PetTypes.emojiFor(booking.petType)} ${booking.petName}',
                    ),
                    _Row(label: 'Shop', value: shop.name),
                    _Row(label: 'Service', value: booking.serviceName),
                    _Row(
                      label: 'Check In',
                      value: DateFormatter.toDisplay(booking.checkInDate),
                    ),
                    _Row(
                      label: 'Check Out',
                      value: DateFormatter.toDisplay(booking.checkOutDate),
                    ),
                    const Divider(color: AppColors.mist, height: AppSpacing.lg),
                    _Row(
                      label: 'Total',
                      value: '\$${booking.totalCharge.toStringAsFixed(2)}',
                      emphasize: true,
                    ),
                  ],
                ),
              ),
              const Spacer(),
              SizedBox(
                width: double.infinity,
                height: 52,
                child: ElevatedButton(
                  onPressed: _goToBookings,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.sageDeep,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                  child: Text(
                    'View My Bookings',
                    style: AppTypography.bodyLarge.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _Row extends StatelessWidget {
  final String label;
  final String value;
  final bool emphasize;
  const _Row({required this.label, required this.value, this.emphasize = false});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: AppSpacing.xs),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: AppTypography.bodyMedium.copyWith(color: AppColors.mist),
          ),
          Text(
            value,
            style: emphasize
                ? AppTypography.sectionHeader.copyWith(fontSize: 18)
                : AppTypography.bodyMedium,
          ),
        ],
      ),
    );
  }
}
