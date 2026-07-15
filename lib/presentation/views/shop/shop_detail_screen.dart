import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../domain/entities/catalog_item.dart';
import '../../../domain/entities/shop.dart';
import '../../controllers/shop_controller.dart';
import '../../routes/app_routes.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_spacing.dart';
import '../../theme/app_typography.dart';
import '../../widgets/catalog_item_card.dart';

class ShopDetailScreen extends StatefulWidget {
  final Shop shop;

  const ShopDetailScreen({super.key, required this.shop});

  @override
  State<ShopDetailScreen> createState() => _ShopDetailScreenState();
}

class _ShopDetailScreenState extends State<ShopDetailScreen>
    with SingleTickerProviderStateMixin {
  late final _tabController = TabController(length: 2, vsync: this);

  ShopController get _shops => Get.find<ShopController>();

  @override
  void initState() {
    super.initState();
    _shops.fetchCatalogItems(widget.shop.shopId);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  void _bookItem(CatalogItem item) {
    Get.toNamed(AppRoutes.booking, arguments: (shop: widget.shop, item: item));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.creamWarm,
      appBar: AppBar(
        backgroundColor: AppColors.creamWarm,
        elevation: 0,
        title: Text(widget.shop.name, style: AppTypography.sectionHeader),
      ),
      body: SafeArea(
        child: Column(
          children: [
            _ShopHeader(shop: widget.shop),
            TabBar(
              controller: _tabController,
              labelColor: AppColors.sageDeep,
              unselectedLabelColor: AppColors.mist,
              indicatorColor: AppColors.sageDeep,
              tabs: const [Tab(text: 'Services'), Tab(text: 'Products')],
            ),
            Expanded(
              child: Obx(() {
                if (_shops.isLoadingCatalog && _shops.selectedShopCatalog.isEmpty) {
                  return const Center(
                    child: CircularProgressIndicator(color: AppColors.sageMid),
                  );
                }
                final items = _shops.selectedShopCatalog;
                final services = items
                    .where((i) => i.itemType == CatalogItemType.service)
                    .toList();
                final products = items
                    .where((i) => i.itemType == CatalogItemType.product)
                    .toList();
                return TabBarView(
                  controller: _tabController,
                  children: [
                    _CatalogList(
                      items: services,
                      emptyLabel: 'No services yet',
                      onTapItem: _bookItem,
                    ),
                    _CatalogList(
                      items: products,
                      emptyLabel: 'No products yet',
                      onTapItem: _bookItem,
                    ),
                  ],
                );
              }),
            ),
          ],
        ),
      ),
    );
  }
}

class _ShopHeader extends StatelessWidget {
  final Shop shop;
  const _ShopHeader({required this.shop});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.fromLTRB(
        AppSpacing.md,
        0,
        AppSpacing.md,
        AppSpacing.sm,
      ),
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: AppColors.sageDeep,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 56,
                height: 56,
                decoration: const BoxDecoration(
                  color: AppColors.blushSoft,
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.storefront, color: AppColors.sageDeep, size: 28),
              ),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: Text(
                  shop.description.isNotEmpty
                      ? shop.description
                      : 'No description yet.',
                  style: AppTypography.bodyMedium.copyWith(color: AppColors.creamWarm),
                ),
              ),
            ],
          ),
          if (shop.hours.isNotEmpty) ...[
            const SizedBox(height: AppSpacing.sm),
            _InfoRow(icon: Icons.schedule, text: shop.hours),
          ],
          if (shop.contactPhone.isNotEmpty) ...[
            const SizedBox(height: AppSpacing.xs),
            _InfoRow(icon: Icons.call_outlined, text: shop.contactPhone),
          ],
        ],
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  final IconData icon;
  final String text;
  const _InfoRow({required this.icon, required this.text});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: 16, color: AppColors.mist),
        const SizedBox(width: AppSpacing.xs),
        Text(
          text,
          style: AppTypography.bodyMedium.copyWith(color: AppColors.mist),
        ),
      ],
    );
  }
}

class _CatalogList extends StatelessWidget {
  final List<CatalogItem> items;
  final String emptyLabel;
  final ValueChanged<CatalogItem> onTapItem;

  const _CatalogList({
    required this.items,
    required this.emptyLabel,
    required this.onTapItem,
  });

  @override
  Widget build(BuildContext context) {
    if (items.isEmpty) {
      return Center(
        child: Text(
          emptyLabel,
          style: AppTypography.bodyMedium.copyWith(color: AppColors.mist),
        ),
      );
    }
    return ListView.separated(
      padding: const EdgeInsets.all(AppSpacing.md),
      itemCount: items.length,
      separatorBuilder: (context, index) => const SizedBox(height: AppSpacing.sm),
      itemBuilder: (context, index) {
        final item = items[index];
        return CatalogItemCard(item: item, onTap: () => onTapItem(item));
      },
    );
  }
}
