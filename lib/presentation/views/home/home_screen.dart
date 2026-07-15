import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../core/utils/shop_categories.dart';
import '../../controllers/booking_controller.dart';
import '../../routes/app_routes.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_spacing.dart';
import '../../theme/app_typography.dart';
import 'home_header.dart';
import 'popular_shops_section.dart';
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
                Container(
                  padding: const EdgeInsets.all(AppSpacing.md),
                  decoration: BoxDecoration(
                    color: AppColors.sageDeep,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: const [
                      HomeHeader(),
                      SizedBox(height: AppSpacing.md),
                      StatusCard(),
                    ],
                  ),
                ),
                const SizedBox(height: AppSpacing.lg),
                _SearchEntry(onTap: () => Get.toNamed(AppRoutes.search)),
                const SizedBox(height: AppSpacing.lg),
                _CategoryChips(
                  onSelect: (category) =>
                      Get.toNamed(AppRoutes.browse, arguments: category),
                ),
                const SizedBox(height: AppSpacing.lg),
                const PopularShopsSection(),
              ],
            ),
          );
        }),
      ),
    );
  }
}

class _SearchEntry extends StatelessWidget {
  final VoidCallback onTap;
  const _SearchEntry({required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.md,
          vertical: 14,
        ),
        decoration: BoxDecoration(
          color: AppColors.blushSoft,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            const Icon(Icons.search, color: AppColors.sageMid),
            const SizedBox(width: AppSpacing.sm),
            Text(
              'Search shops...',
              style: AppTypography.bodyLarge.copyWith(color: AppColors.mist),
            ),
          ],
        ),
      ),
    );
  }
}

class _CategoryChips extends StatelessWidget {
  final ValueChanged<String> onSelect;
  const _CategoryChips({required this.onSelect});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 40,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: ShopCategories.all.length,
        separatorBuilder: (context, index) => const SizedBox(width: AppSpacing.sm),
        itemBuilder: (context, index) {
          final category = ShopCategories.all[index];
          return GestureDetector(
            onTap: () => onSelect(category.value),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: AppColors.blushSoft,
                borderRadius: BorderRadius.circular(100),
              ),
              child: Text(
                '${category.emoji} ${category.label}',
                style: AppTypography.bodyMedium.copyWith(
                  color: AppColors.ink,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
