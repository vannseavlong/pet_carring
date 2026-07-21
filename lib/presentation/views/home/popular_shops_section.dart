import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../controllers/shop_controller.dart';
import '../../routes/app_routes.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_spacing.dart';
import '../../theme/app_typography.dart';
import '../../widgets/shop_card.dart';

class PopularShopsSection extends StatelessWidget {
  const PopularShopsSection({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<ShopController>();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text('Popular Shops', style: AppTypography.sectionHeader),
            GestureDetector(
              onTap: () => Get.toNamed(AppRoutes.browse),
              child: Text(
                'See all →',
                style: AppTypography.bodyMedium.copyWith(
                  color: AppColors.amberAccent,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: AppSpacing.md),
        Obx(() {
          if (controller.isLoading && controller.shops.isEmpty) {
            return const Padding(
              padding: EdgeInsets.symmetric(vertical: AppSpacing.xl),
              child: Center(
                child: CircularProgressIndicator(color: AppColors.sageMid),
              ),
            );
          }
          if (controller.shops.isEmpty) {
            return Padding(
              padding: const EdgeInsets.symmetric(vertical: AppSpacing.lg),
              child: Text(
                'No shops available',
                style: AppTypography.bodyMedium.copyWith(color: AppColors.mist),
              ),
            );
          }
          return SizedBox(
            height: ShopCard.railHeight,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              itemCount: controller.shops.length,
              separatorBuilder: (context, index) => const SizedBox(width: AppSpacing.sm),
              itemBuilder: (context, index) {
                final shop = controller.shops[index];
                return ShopCard(
                  shop: shop,
                  width: 220,
                  onTap: () => Get.toNamed(AppRoutes.shopDetail, arguments: shop),
                );
              },
            ),
          );
        }),
      ],
    );
  }
}
