import 'package:flutter/material.dart';
import 'package:hugeicons/hugeicons.dart';
import '../../domain/entities/catalog_item.dart';
import '../theme/app_colors.dart';
import '../theme/app_spacing.dart';
import '../theme/app_typography.dart';
import 'service_icon.dart';

class CatalogItemCard extends StatelessWidget {
  final CatalogItem item;
  final VoidCallback onTap;

  const CatalogItemCard({super.key, required this.item, required this.onTap});

  Color get _cardColor {
    final hex = item.color.replaceFirst('#', '');
    return Color(int.parse('FF$hex', radix: 16));
  }

  @override
  Widget build(BuildContext context) {
    final cardColor = _cardColor;
    final iconBgColor = Color.alphaBlend(
      Colors.black.withValues(alpha: 0.06),
      cardColor,
    );

    return InkWell(
      borderRadius: BorderRadius.circular(14),
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(AppSpacing.md),
        decoration: BoxDecoration(
          color: cardColor,
          borderRadius: BorderRadius.circular(14),
        ),
        child: Row(
          children: [
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(color: iconBgColor, shape: BoxShape.circle),
              child: Center(
                child: HugeIcon(
                  icon: ServiceIcons.resolve(item.icon),
                  color: AppColors.sageDeep,
                  size: 22,
                ),
              ),
            ),
            const SizedBox(width: AppSpacing.md),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    item.name,
                    style: AppTypography.sectionHeader.copyWith(fontSize: 16),
                  ),
                  Text(
                    'From \$${item.priceFrom.toStringAsFixed(0)}',
                    style: AppTypography.bodyMedium.copyWith(color: AppColors.sageMid),
                  ),
                ],
              ),
            ),
            const Icon(Icons.chevron_right, color: AppColors.sageDeep),
          ],
        ),
      ),
    );
  }
}
