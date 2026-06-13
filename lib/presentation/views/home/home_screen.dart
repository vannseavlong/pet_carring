import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../controllers/booking_controller.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_spacing.dart';
import '../../theme/app_typography.dart';
import '../../widgets/booking_card.dart';
import '../booking/add_booking_screen.dart';
import '../booking/pet_detail_screen.dart';
import '../history/history_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<BookingController>();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Pet Dashboard'),
        actions: [
          IconButton(
            icon: const Icon(Icons.history),
            color: AppColors.creamWarm,
            onPressed: () => Get.to(() => const HistoryScreen()),
          ),
        ],
      ),
      body: Obx(() => _buildBody(controller)),
      floatingActionButton: FloatingActionButton(
        child: const Icon(Icons.add),
        onPressed: () => Get.to(() => const AddBookingScreen()),
      ),
    );
  }

  Widget _buildBody(BookingController controller) {
    if (controller.isLoading) {
      return const Center(
        child: CircularProgressIndicator(color: AppColors.sageMid),
      );
    }
    if (controller.state.value == ViewState.error) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              controller.errorMessage.value.isNotEmpty
                  ? controller.errorMessage.value
                  : 'Something went wrong',
              style: AppTypography.bodyLarge,
            ),
            const SizedBox(height: AppSpacing.md),
            TextButton(
              onPressed: controller.fetchBookings,
              child: const Text('Retry'),
            ),
          ],
        ),
      );
    }
    if (controller.activeBookings.isEmpty) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('🐾', style: TextStyle(fontSize: 48)),
            const SizedBox(height: AppSpacing.md),
            Text('No active bookings', style: AppTypography.sectionHeader),
            const SizedBox(height: AppSpacing.sm),
            Text(
              'Tap + to add a new pet stay',
              style: AppTypography.bodyMedium.copyWith(color: AppColors.mist),
            ),
          ],
        ),
      );
    }
    return ListView.builder(
      padding: const EdgeInsets.symmetric(vertical: AppSpacing.sm),
      itemCount: controller.activeBookings.length,
      itemBuilder: (context, index) {
        final booking = controller.activeBookings[index];
        return BookingCard(
          booking: booking,
          onTap: () => Get.to(() => PetDetailScreen(booking: booking)),
        );
      },
    );
  }
}
