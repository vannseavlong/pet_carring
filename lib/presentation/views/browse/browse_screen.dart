import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../controllers/category_controller.dart';
import '../../controllers/shop_controller.dart';
import '../../routes/app_routes.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_spacing.dart';
import '../../theme/app_typography.dart';
import '../../widgets/shop_card.dart';

class BrowseScreen extends StatefulWidget {
  final String? initialCategory;

  const BrowseScreen({super.key, this.initialCategory});

  @override
  State<BrowseScreen> createState() => _BrowseScreenState();
}

class _BrowseScreenState extends State<BrowseScreen> {
  final _searchCtrl = TextEditingController();
  late String? _category = widget.initialCategory;

  ShopController get _shops => Get.find<ShopController>();
  CategoryController get _categories => Get.find<CategoryController>();

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.creamWarm,
      appBar: AppBar(
        backgroundColor: AppColors.creamWarm,
        elevation: 0,
        title: const Text('Browse'),
      ),
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.md,
                vertical: AppSpacing.sm,
              ),
              child: TextField(
                controller: _searchCtrl,
                onChanged: (_) => setState(() {}),
                decoration: InputDecoration(
                  hintText: 'Search shops...',
                  hintStyle: AppTypography.bodyLarge.copyWith(color: AppColors.mist),
                  prefixIcon: const Icon(Icons.search, color: AppColors.sageMid),
                  filled: true,
                  fillColor: AppColors.blushSoft,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none,
                  ),
                  contentPadding: const EdgeInsets.symmetric(vertical: 14),
                ),
              ),
            ),
            SizedBox(
              height: 40,
              child: Obx(() {
                final categories = _categories.categories;
                return ListView(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
                  children: [
                    _CategoryChip(
                      label: 'All',
                      selected: _category == null,
                      onTap: () => setState(() => _category = null),
                    ),
                    const SizedBox(width: AppSpacing.sm),
                    for (final category in categories) ...[
                      _CategoryChip(
                        label: '${category.icon} ${category.name}',
                        selected: _category == category.categoryId,
                        onTap: () => setState(() => _category = category.categoryId),
                      ),
                      const SizedBox(width: AppSpacing.sm),
                    ],
                  ],
                );
              }),
            ),
            const SizedBox(height: AppSpacing.sm),
            Expanded(
              child: Obx(() {
                if (_shops.isLoading && _shops.shops.isEmpty) {
                  return const Center(
                    child: CircularProgressIndicator(color: AppColors.sageMid),
                  );
                }
                final results = _shops.search(
                  query: _searchCtrl.text,
                  categoryId: _category,
                );
                if (results.isEmpty) {
                  return Center(
                    child: Text(
                      'No shops found',
                      style: AppTypography.bodyMedium.copyWith(color: AppColors.mist),
                    ),
                  );
                }
                return ListView.separated(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.md,
                    vertical: AppSpacing.sm,
                  ),
                  itemCount: results.length,
                  separatorBuilder: (_, _) => const SizedBox(height: AppSpacing.sm),
                  itemBuilder: (context, index) {
                    final shop = results[index];
                    return ShopCard(
                      shop: shop,
                      onTap: () => Get.toNamed(AppRoutes.shopDetail, arguments: shop),
                    );
                  },
                );
              }),
            ),
          ],
        ),
      ),
    );
  }
}

class _CategoryChip extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback onTap;

  const _CategoryChip({required this.label, required this.selected, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: selected ? AppColors.sageDeep : AppColors.blushSoft,
          borderRadius: BorderRadius.circular(100),
        ),
        child: Text(
          label,
          style: AppTypography.bodyMedium.copyWith(
            color: selected ? Colors.white : AppColors.ink,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }
}
