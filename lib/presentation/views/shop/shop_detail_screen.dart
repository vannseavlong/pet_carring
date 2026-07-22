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
import '../../widgets/product_card.dart';

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

  void _showProductDetails(CatalogItem item) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) => _ProductDetailSheet(item: item),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.creamWarm,
      appBar: AppBar(
        backgroundColor: AppColors.creamWarm,
        elevation: 0,
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
                    _ProductGrid(
                      items: products,
                      emptyLabel: 'No products yet',
                      onTapItem: _showProductDetails,
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

  static const double _bannerHeight = 130;
  static const double _logoSize = 72;
  static const double _logoOverlap = 34;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.fromLTRB(
        AppSpacing.md,
        0,
        AppSpacing.md,
        AppSpacing.sm,
      ),
      decoration: BoxDecoration(
        color: AppColors.sageDeep,
        borderRadius: BorderRadius.circular(20),
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Stack(
            clipBehavior: Clip.none,
            children: [
              SizedBox(
                height: _bannerHeight,
                width: double.infinity,
                child: _ShopBanner(url: shop.banner),
              ),
              Positioned(
                left: AppSpacing.md,
                bottom: -_logoOverlap,
                child: Container(
                  width: _logoSize,
                  height: _logoSize,
                  padding: const EdgeInsets.all(3),
                  decoration: const BoxDecoration(
                    color: AppColors.creamWarm,
                    shape: BoxShape.circle,
                  ),
                  child: ClipOval(child: _ShopLogo(url: shop.logo)),
                ),
              ),
            ],
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(
              AppSpacing.md,
              _logoOverlap + AppSpacing.sm,
              AppSpacing.md,
              AppSpacing.md,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  shop.name,
                  style: AppTypography.sectionHeader.copyWith(
                    color: AppColors.creamWarm,
                  ),
                ),
                const SizedBox(height: AppSpacing.xs),
                Text(
                  shop.description.isNotEmpty
                      ? shop.description
                      : 'No description yet.',
                  style: AppTypography.bodyMedium.copyWith(color: AppColors.creamWarm),
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
          ),
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

class _ShopBanner extends StatelessWidget {
  final String url;
  const _ShopBanner({required this.url});

  @override
  Widget build(BuildContext context) {
    if (url.isEmpty) return const _ShopBannerFallback();
    return Image.network(
      url,
      fit: BoxFit.cover,
      width: double.infinity,
      height: double.infinity,
      loadingBuilder: (context, child, progress) {
        if (progress == null) return child;
        return const _ShopBannerFallback(showIcon: false);
      },
      errorBuilder: (context, error, stackTrace) => const _ShopBannerFallback(),
    );
  }
}

class _ShopBannerFallback extends StatelessWidget {
  final bool showIcon;
  const _ShopBannerFallback({this.showIcon = true});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: AppColors.sageMid,
      alignment: Alignment.center,
      child: showIcon
          ? const Icon(Icons.storefront, color: AppColors.creamWarm, size: 36)
          : null,
    );
  }
}

class _ShopLogo extends StatelessWidget {
  final String url;
  const _ShopLogo({required this.url});

  @override
  Widget build(BuildContext context) {
    if (url.isEmpty) return const _ShopLogoFallback();
    return Image.network(
      url,
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
      color: AppColors.blushSoft,
      alignment: Alignment.center,
      child: showIcon
          ? const Icon(Icons.storefront, color: AppColors.sageDeep, size: 28)
          : null,
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

class _ProductGrid extends StatelessWidget {
  final List<CatalogItem> items;
  final String emptyLabel;
  final ValueChanged<CatalogItem> onTapItem;

  const _ProductGrid({
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
    return GridView.builder(
      padding: const EdgeInsets.all(AppSpacing.md),
      itemCount: items.length,
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        mainAxisSpacing: AppSpacing.sm,
        crossAxisSpacing: AppSpacing.sm,
        childAspectRatio: 0.72,
      ),
      itemBuilder: (context, index) {
        final item = items[index];
        return ProductCard(item: item, onTap: () => onTapItem(item));
      },
    );
  }
}

class _ProductDetailSheet extends StatelessWidget {
  final CatalogItem item;
  const _ProductDetailSheet({required this.item});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      top: false,
      child: Container(
        margin: const EdgeInsets.fromLTRB(
          AppSpacing.md,
          0,
          AppSpacing.md,
          AppSpacing.md,
        ),
        decoration: BoxDecoration(
          color: AppColors.creamWarm,
          borderRadius: BorderRadius.circular(20),
        ),
        clipBehavior: Clip.antiAlias,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Padding(
                  padding: const EdgeInsets.only(top: AppSpacing.sm),
                  child: Container(
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(
                      color: AppColors.mist,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
              ),
              AspectRatio(
                aspectRatio: 1.4,
                child: _ProductDetailImage(url: item.image),
              ),
              Padding(
                padding: const EdgeInsets.all(AppSpacing.lg),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(item.name, style: AppTypography.sectionHeader),
                    const SizedBox(height: AppSpacing.xs),
                    Text(
                      'From \$${item.priceFrom.toStringAsFixed(0)}',
                      style: AppTypography.bodyLarge.copyWith(
                        color: AppColors.sageMid,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    if (item.description.isNotEmpty) ...[
                      const SizedBox(height: AppSpacing.md),
                      Text(item.description, style: AppTypography.bodyMedium),
                    ],
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ProductDetailImage extends StatelessWidget {
  final String url;
  const _ProductDetailImage({required this.url});

  @override
  Widget build(BuildContext context) {
    if (url.isEmpty) return const _ProductDetailImageFallback();
    return Image.network(
      url,
      fit: BoxFit.cover,
      width: double.infinity,
      errorBuilder: (context, error, stackTrace) =>
          const _ProductDetailImageFallback(),
    );
  }
}

class _ProductDetailImageFallback extends StatelessWidget {
  const _ProductDetailImageFallback();

  @override
  Widget build(BuildContext context) {
    return Container(
      color: AppColors.blushSoft,
      alignment: Alignment.center,
      child: const Icon(
        Icons.shopping_bag,
        color: AppColors.sageMid,
        size: 48,
      ),
    );
  }
}
