import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../controllers/booking_controller.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_spacing.dart';
import '../../theme/app_typography.dart';
import '../../widgets/booking_card.dart';
import '../booking/pet_detail_screen.dart';

class StaysScreen extends StatelessWidget {
  const StaysScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<BookingController>();

    return Scaffold(
      appBar: AppBar(title: const Text('Active Stays')),
      body: Obx(() {
        if (controller.isLoadingActiveStays && controller.activeStays.isEmpty) {
          return const Center(
            child: CircularProgressIndicator(color: AppColors.sageMid),
          );
        }
        if (controller.activeStays.isEmpty) {
          return RefreshIndicator(
            onRefresh: controller.fetchActiveStays,
            child: ListView(
              children: [
                Center(
                  child: Padding(
                    padding: const EdgeInsets.only(top: AppSpacing.xxl),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Text('🐾', style: TextStyle(fontSize: 48)),
                        const SizedBox(height: AppSpacing.md),
                        Text('No active stays', style: AppTypography.sectionHeader),
                        const SizedBox(height: AppSpacing.sm),
                        Text(
                          'Confirmed bookings will appear here',
                          style: AppTypography.bodyMedium.copyWith(
                            color: AppColors.mist,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          );
        }
        return RefreshIndicator(
          onRefresh: controller.fetchActiveStays,
          child: ListView.builder(
            padding: const EdgeInsets.symmetric(vertical: AppSpacing.sm),
            itemCount: controller.activeStays.length,
            itemBuilder: (context, index) {
              final booking = controller.activeStays[index];
              return BookingCard(
                booking: booking,
                onTap: () => Get.to(() => PetDetailScreen(booking: booking)),
              );
            },
          ),
        );
      }),
    );
  }
}
