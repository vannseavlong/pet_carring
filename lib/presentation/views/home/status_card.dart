import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../core/utils/date_formatter.dart';
import '../../../domain/entities/pet_booking.dart';
import '../../controllers/booking_controller.dart';
import '../../controllers/navigation_controller.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_spacing.dart';
import '../../theme/app_typography.dart';

class StatusCard extends StatelessWidget {
  const StatusCard({super.key});

  PetBooking? _nextUpcoming(List<PetBooking> upcoming) {
    if (upcoming.isEmpty) return null;
    final sorted = [...upcoming]
      ..sort((a, b) => a.checkInDate.compareTo(b.checkInDate));
    return sorted.first;
  }

  @override
  Widget build(BuildContext context) {
    final bookings = Get.find<BookingController>();

    return Obx(() {
      final next = _nextUpcoming(bookings.upcomingBookings);

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
            child: next == null
                ? Text(
                    'No upcoming bookings',
                    style: AppTypography.bodyMedium.copyWith(
                      color: AppColors.mist,
                    ),
                  )
                : RichText(
                    text: TextSpan(
                      children: [
                        TextSpan(
                          text: '${next.petName} · ${next.serviceName}',
                          style: AppTypography.bodyMedium.copyWith(
                            color: AppColors.creamWarm,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        TextSpan(
                          text: '  ·  ${DateFormatter.toDisplay(next.checkInDate)}',
                          style: AppTypography.bodyMedium.copyWith(
                            color: AppColors.mist,
                          ),
                        ),
                      ],
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
          ),
          GestureDetector(
            onTap: () => Get.find<NavigationController>().changePage(2),
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
    });
  }
}
