import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../controllers/booking_controller.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_spacing.dart';
import 'home_header.dart';
import 'services_section.dart';
import 'status_card.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<BookingController>();

    return Scaffold(
      body: SafeArea(
        child: Obx(() {
          if (controller.isLoading) {
            return const Center(
              child: CircularProgressIndicator(color: AppColors.sageMid),
            );
          }
          return SingleChildScrollView(
            padding: const EdgeInsets.all(AppSpacing.md),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const HomeHeader(),
                const SizedBox(height: AppSpacing.md),
                const StatusCard(),
                const SizedBox(height: AppSpacing.lg),
                const ServicesSection(),
              ],
            ),
          );
        }),
      ),
    );
  }
}
