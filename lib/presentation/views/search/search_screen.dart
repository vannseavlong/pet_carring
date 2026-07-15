import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../controllers/shop_controller.dart';
import '../../routes/app_routes.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_spacing.dart';
import '../../theme/app_typography.dart';
import '../../widgets/shop_card.dart';

class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final _searchCtrl = TextEditingController();
  final _focusNode = FocusNode();

  ShopController get _shops => Get.find<ShopController>();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _focusNode.requestFocus());
  }

  @override
  void dispose() {
    _searchCtrl.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.creamWarm,
      appBar: AppBar(
        backgroundColor: AppColors.creamWarm,
        elevation: 0,
        titleSpacing: 0,
        title: Padding(
          padding: const EdgeInsets.only(right: AppSpacing.md),
          child: TextField(
            controller: _searchCtrl,
            focusNode: _focusNode,
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
              contentPadding: const EdgeInsets.symmetric(vertical: 12),
            ),
          ),
        ),
      ),
      body: SafeArea(
        child: Obx(() {
          final query = _searchCtrl.text.trim();
          if (query.isEmpty) {
            return Center(
              child: Text(
                'Search for a shop by name',
                style: AppTypography.bodyMedium.copyWith(color: AppColors.mist),
              ),
            );
          }
          final results = _shops.search(query: query);
          if (results.isEmpty) {
            return Center(
              child: Text(
                'No shops found for "$query"',
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
            separatorBuilder: (context, index) => const SizedBox(height: AppSpacing.sm),
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
    );
  }
}
