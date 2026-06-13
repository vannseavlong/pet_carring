import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../controllers/booking_controller.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_spacing.dart';
import '../../theme/app_typography.dart';
import '../../widgets/booking_card.dart';
import '../booking/pet_detail_screen.dart';

class HistoryScreen extends StatelessWidget {
  const HistoryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<BookingController>();

    return Scaffold(
      appBar: AppBar(title: const Text('Past Bookings')),
      body: Obx(() {
        if (controller.historicalBookings.isEmpty) {
          return Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text('📋', style: TextStyle(fontSize: 48)),
                const SizedBox(height: AppSpacing.md),
                Text('No past bookings', style: AppTypography.sectionHeader),
                const SizedBox(height: AppSpacing.sm),
                Text(
                  'Completed stays will appear here',
                  style: AppTypography.bodyMedium.copyWith(
                    color: AppColors.mist,
                  ),
                ),
              ],
            ),
          );
        }
        return ListView.builder(
          padding: const EdgeInsets.symmetric(vertical: AppSpacing.sm),
          itemCount: controller.historicalBookings.length,
          itemBuilder: (context, index) {
            final booking = controller.historicalBookings[index];
            return BookingCard(
              booking: booking,
              onTap: () => Get.to(() => PetDetailScreen(booking: booking)),
            );
          },
        );
      }),
    );
  }
}
