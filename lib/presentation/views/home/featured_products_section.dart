import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../controllers/shop_controller.dart';
import '../../routes/app_routes.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_spacing.dart';
import '../../theme/app_typography.dart';
import '../../widgets/product_card.dart';

class FeaturedProductsSection extends StatelessWidget {
  const FeaturedProductsSection({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<ShopController>();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Featured Products', style: AppTypography.sectionHeader),
        const SizedBox(height: AppSpacing.md),
        Obx(() {
          if (controller.isLoadingFeaturedProducts &&
              controller.featuredProducts.isEmpty) {
            return const Padding(
              padding: EdgeInsets.symmetric(vertical: AppSpacing.xl),
              child: Center(
                child: CircularProgressIndicator(color: AppColors.sageMid),
              ),
            );
          }
          if (controller.featuredProducts.isEmpty) {
            return Padding(
              padding: const EdgeInsets.symmetric(vertical: AppSpacing.lg),
              child: Text(
                'No products available',
                style: AppTypography.bodyMedium.copyWith(color: AppColors.mist),
              ),
            );
          }
          return GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: controller.featuredProducts.length,
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              mainAxisSpacing: AppSpacing.sm,
              crossAxisSpacing: AppSpacing.sm,
              childAspectRatio: 0.72,
            ),
            itemBuilder: (context, index) {
              final item = controller.featuredProducts[index];
              return ProductCard(
                item: item,
                onTap: () {
                  final shop = controller.shopById(item.shopId);
                  if (shop == null) return;
                  Get.toNamed(AppRoutes.shopDetail, arguments: shop);
                },
              );
            },
          );
        }),
      ],
    );
  }
}
