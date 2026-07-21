import 'package:flutter/material.dart';
import '../../domain/entities/catalog_item.dart';
import '../theme/app_colors.dart';
import '../theme/app_spacing.dart';
import '../theme/app_typography.dart';

/// Product tile for the home-screen "Featured Products" grid. The product
/// image is the dominant visual — a different language from
/// [CatalogItemCard]'s horizontal icon-row layout used for shop-detail
/// services, so this is its own widget rather than a variant of that one.
class ProductCard extends StatelessWidget {
  final CatalogItem item;
  final VoidCallback onTap;

  const ProductCard({super.key, required this.item, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(16),
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.blushSoft,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.mist.withValues(alpha: 0.25)),
        ),
        clipBehavior: Clip.antiAlias,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            AspectRatio(aspectRatio: 1, child: _ProductImage(url: item.image)),
            Padding(
              padding: const EdgeInsets.all(AppSpacing.sm),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    item.name,
                    style: AppTypography.bodyMedium.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 2),
                  Text(
                    'From \$${item.priceFrom.toStringAsFixed(0)}',
                    style: AppTypography.bodyMedium.copyWith(
                      color: AppColors.sageMid,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ProductImage extends StatelessWidget {
  final String url;
  const _ProductImage({required this.url});

  @override
  Widget build(BuildContext context) {
    if (url.isEmpty) return const _ProductImageFallback();
    return Image.network(
      url,
      fit: BoxFit.cover,
      width: double.infinity,
      loadingBuilder: (context, child, progress) {
        if (progress == null) return child;
        return const _ProductImageFallback(showIcon: false);
      },
      errorBuilder: (context, error, stackTrace) =>
          const _ProductImageFallback(),
    );
  }
}

class _ProductImageFallback extends StatelessWidget {
  final bool showIcon;
  const _ProductImageFallback({this.showIcon = true});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: AppColors.blushSoft,
      alignment: Alignment.center,
      child: showIcon
          ? const Icon(Icons.shopping_bag, color: AppColors.sageMid, size: 32)
          : null,
    );
  }
}
