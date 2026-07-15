import 'package:flutter/material.dart';
import '../../core/utils/shop_categories.dart';
import '../../domain/entities/shop.dart';
import '../theme/app_colors.dart';
import '../theme/app_spacing.dart';
import '../theme/app_typography.dart';

/// Shop card. Pass [width] for use inside a horizontal rail (e.g. Home's
/// "Popular Shops"); omit it for a full-width list item (e.g. Browse).
class ShopCard extends StatelessWidget {
  final Shop shop;
  final VoidCallback onTap;
  final double? width;

  const ShopCard({super.key, required this.shop, required this.onTap, this.width});

  @override
  Widget build(BuildContext context) {
    final categoryLabel = shop.category.isNotEmpty
        ? ShopCategories.labelFor(shop.category)
        : null;

    return InkWell(
      borderRadius: BorderRadius.circular(16),
      onTap: onTap,
      child: Container(
        width: width,
        padding: const EdgeInsets.all(AppSpacing.md),
        decoration: BoxDecoration(
          color: AppColors.blushSoft,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Row(
          crossAxisAlignment: width == null
              ? CrossAxisAlignment.center
              : CrossAxisAlignment.start,
          mainAxisSize: width == null ? MainAxisSize.max : MainAxisSize.min,
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: const BoxDecoration(
                color: AppColors.sageMid,
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.storefront, color: Colors.white, size: 22),
            ),
            const SizedBox(width: AppSpacing.sm),
            if (width != null)
              SizedBox(
                width: width! - 48 - AppSpacing.sm - AppSpacing.md * 2,
                child: _ShopInfo(shop: shop, categoryLabel: categoryLabel),
              )
            else
              Expanded(child: _ShopInfo(shop: shop, categoryLabel: categoryLabel)),
            if (width == null)
              const Icon(Icons.chevron_right, color: AppColors.mist),
          ],
        ),
      ),
    );
  }
}

class _ShopInfo extends StatelessWidget {
  final Shop shop;
  final String? categoryLabel;
  const _ShopInfo({required this.shop, required this.categoryLabel});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          shop.name,
          style: AppTypography.sectionHeader.copyWith(fontSize: 15),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        const SizedBox(height: 2),
        Text(
          shop.description,
          style: AppTypography.bodyMedium.copyWith(color: AppColors.sageMid),
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
        ),
        if (categoryLabel != null) ...[
          const SizedBox(height: AppSpacing.xs),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.sm, vertical: 2),
            decoration: BoxDecoration(
              color: AppColors.sageMid.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(100),
            ),
            child: Text(
              categoryLabel!,
              style: AppTypography.micro.copyWith(
                color: AppColors.sageDeep,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ],
    );
  }
}
