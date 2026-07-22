import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../domain/entities/shop.dart';
import '../controllers/category_controller.dart';
import '../theme/app_colors.dart';
import '../theme/app_spacing.dart';
import '../theme/app_typography.dart';

/// Shop card.
///
/// Pass [width] for use inside a horizontal rail (e.g. Home's "Popular
/// Shops") — fixed height of [railHeight]; callers must size the rail's
/// `ListView` to match (e.g. `SizedBox(height: ShopCard.railHeight, ...)`).
///
/// Omit [width] for a full-width list item (e.g. Browse/Search) — sizes to
/// its own content, no fixed height needed.
///
/// Both variants share the same composition: logo + shop name on one row,
/// description below spanning the full card width.
class ShopCard extends StatelessWidget {
  final Shop shop;
  final VoidCallback onTap;
  final double? width;

  const ShopCard({super.key, required this.shop, required this.onTap, this.width});

  /// Total height of the rail-width (width != null) variant.
  static const double railHeight = 132.0;

  @override
  Widget build(BuildContext context) {
    final isRail = width != null;

    return Container(
      width: width,
      height: isRail ? railHeight : null,
      decoration: BoxDecoration(
        color: AppColors.blushSoft,
        borderRadius: BorderRadius.circular(18),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(18),
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.all(AppSpacing.md),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child: SizedBox(
                        width: 40,
                        height: 40,
                        child: _ShopLogo(logo: shop.logo),
                      ),
                    ),
                    const SizedBox(width: AppSpacing.sm),
                    Expanded(
                      child: Text(
                        shop.name,
                        style: AppTypography.sectionHeader.copyWith(fontSize: 15),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    if (!isRail) ...[
                      const SizedBox(width: AppSpacing.xs),
                      const Icon(Icons.chevron_right, color: AppColors.mist),
                    ],
                  ],
                ),
                const SizedBox(height: AppSpacing.xs),
                Text(
                  shop.description,
                  style: AppTypography.bodyMedium.copyWith(
                    color: AppColors.sageMid,
                    fontSize: isRail ? 12.5 : null,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                if (!isRail && shop.categoryId.isNotEmpty)
                  Obx(() {
                    final label = Get.find<CategoryController>().labelFor(
                      shop.categoryId,
                    );
                    return Padding(
                      padding: const EdgeInsets.only(top: AppSpacing.xs),
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: AppSpacing.sm,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.sageMid.withValues(alpha: 0.15),
                          borderRadius: BorderRadius.circular(100),
                        ),
                        child: Text(
                          label,
                          style: AppTypography.micro.copyWith(
                            color: AppColors.sageDeep,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    );
                  }),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// The shop's logo image, filling whatever box its parent gives it, with a
/// themed storefront-icon fallback while loading, on error, or when [logo]
/// is empty.
class _ShopLogo extends StatelessWidget {
  final String logo;
  const _ShopLogo({required this.logo});

  @override
  Widget build(BuildContext context) {
    if (logo.isEmpty) return const _ShopLogoFallback();
    return Image.network(
      logo,
      fit: BoxFit.cover,
      width: double.infinity,
      height: double.infinity,
      loadingBuilder: (context, child, progress) {
        if (progress == null) return child;
        return const _ShopLogoFallback(showIcon: false);
      },
      errorBuilder: (context, error, stackTrace) => const _ShopLogoFallback(),
    );
  }
}

class _ShopLogoFallback extends StatelessWidget {
  final bool showIcon;
  const _ShopLogoFallback({this.showIcon = true});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: AppColors.sageMid,
      alignment: Alignment.center,
      child: showIcon
          ? const Icon(Icons.storefront, color: Colors.white, size: 20)
          : null,
    );
  }
}
