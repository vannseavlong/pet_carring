import 'package:flutter/material.dart';
import 'package:hugeicons/hugeicons.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_spacing.dart';
import '../../theme/app_typography.dart';

class PetService {
  final String title;
  final String price;
  final IconData icon;
  final Color cardColor;
  final Color iconBgColor;

  const PetService({
    required this.title,
    required this.price,
    required this.icon,
    required this.cardColor,
    required this.iconBgColor,
  });
}

final _services = [
  PetService(
    title: 'Bath & Grooming',
    price: 'From \$25',
    icon: HugeIcons.strokeRoundedShampoo,
    cardColor: Color(0xFFE8F0EE),
    iconBgColor: Color(0xFFC8DDD7),
  ),
  PetService(
    title: 'Dog Walking',
    price: 'From \$15',
    icon: HugeIcons.strokeRoundedBone01,
    cardColor: Color(0xFFF5EDE6),
    iconBgColor: Color(0xFFEDD5C0),
  ),
  PetService(
    title: 'Playtime',
    price: 'From \$12',
    icon: HugeIcons.strokeRoundedTennisBall,
    cardColor: Color(0xFFE8F0EE),
    iconBgColor: Color(0xFFC8DDD7),
  ),
  PetService(
    title: 'Meds & Care',
    price: 'From \$10',
    icon: HugeIcons.strokeRoundedMedicine01,
    cardColor: Color(0xFFEDE8F5),
    iconBgColor: Color(0xFFD5C8EB),
  ),
  PetService(
    title: 'Haircut & Styling',
    price: 'From \$30',
    icon: HugeIcons.strokeRoundedScissor,
    cardColor: Color(0xFFF5EDE6),
    iconBgColor: Color(0xFFEDD5C0),
  ),
  PetService(
    title: 'Pick-up & Drop-off',
    price: 'From \$20',
    icon: HugeIcons.strokeRoundedCar01,
    cardColor: Color(0xFFE8F0EE),
    iconBgColor: Color(0xFFC8DDD7),
  ),
];

class ServicesSection extends StatelessWidget {
  const ServicesSection({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Our Services', style: AppTypography.sectionHeader),
        const SizedBox(height: AppSpacing.md),
        GridView.count(
          crossAxisCount: 2,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          crossAxisSpacing: AppSpacing.sm,
          mainAxisSpacing: AppSpacing.sm,
          childAspectRatio: 1,
          children: _services.map((s) => _ServiceCard(service: s)).toList(),
        ),
      ],
    );
  }
}

class _ServiceCard extends StatelessWidget {
  final PetService service;
  const _ServiceCard({required this.service});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: service.cardColor,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: service.iconBgColor,
              shape: BoxShape.circle,
            ),
            child: Center(
              child: HugeIcon(
                icon: service.icon,
                color: AppColors.sageDeep,
                size: 24,
              ),
            ),
          ),
          const Spacer(),
          Text(
            service.title,
            style: AppTypography.sectionHeader.copyWith(fontSize: 16),
          ),
          const SizedBox(height: AppSpacing.xs),
          Text(
            service.price,
            style: AppTypography.bodyMedium.copyWith(color: AppColors.sageMid),
          ),
        ],
      ),
    );
  }
}
