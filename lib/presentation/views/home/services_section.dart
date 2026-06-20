import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:hugeicons/hugeicons.dart';
import '../../../domain/entities/service.dart';
import '../../controllers/service_controller.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_spacing.dart';
import '../../theme/app_typography.dart';
import '../../widgets/service_icon.dart';
import '../booking/add_booking_screen.dart';

class ServicesSection extends StatelessWidget {
  const ServicesSection({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<ServiceController>();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Our Services', style: AppTypography.sectionHeader),
        const SizedBox(height: AppSpacing.md),
        Obx(() {
          if (controller.isLoading && controller.services.isEmpty) {
            return const Padding(
              padding: EdgeInsets.symmetric(vertical: AppSpacing.xl),
              child: Center(
                child: CircularProgressIndicator(color: AppColors.sageMid),
              ),
            );
          }
          if (controller.services.isEmpty) {
            return Padding(
              padding: const EdgeInsets.symmetric(vertical: AppSpacing.lg),
              child: Text(
                'No services available',
                style: AppTypography.bodyMedium.copyWith(color: AppColors.mist),
              ),
            );
          }
          return GridView.count(
            crossAxisCount: 2,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            crossAxisSpacing: AppSpacing.sm,
            mainAxisSpacing: AppSpacing.sm,
            childAspectRatio: 1,
            children:
                controller.services.map((s) => _ServiceCard(service: s)).toList(),
          );
        }),
      ],
    );
  }
}

class _ServiceCard extends StatelessWidget {
  final Service service;
  const _ServiceCard({required this.service});

  Color get _cardColor {
    final hex = service.color.replaceFirst('#', '');
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
      borderRadius: BorderRadius.circular(16),
      onTap: () => Get.to(() => AddBookingScreen(initialService: service)),
      child: Container(
        padding: const EdgeInsets.all(AppSpacing.md),
        decoration: BoxDecoration(
          color: cardColor,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: iconBgColor,
                shape: BoxShape.circle,
              ),
              child: Center(
                child: HugeIcon(
                  icon: ServiceIcons.resolve(service.icon),
                  color: AppColors.sageDeep,
                  size: 24,
                ),
              ),
            ),
            const Spacer(),
            Text(
              service.name,
              style: AppTypography.sectionHeader.copyWith(fontSize: 16),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: AppSpacing.xs),
            Text(
              'From \$${service.priceFrom.toStringAsFixed(0)}',
              style: AppTypography.bodyMedium.copyWith(color: AppColors.sageMid),
            ),
          ],
        ),
      ),
    );
  }
}
