import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:hugeicons/hugeicons.dart';
import '../../../core/utils/recent_search_store.dart';
import '../../../core/utils/shop_categories.dart';
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

  String? _category;
  List<String> _recentSearches = const [];

  ShopController get _shops => Get.find<ShopController>();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _focusNode.requestFocus());
    _loadRecentSearches();
  }

  @override
  void dispose() {
    _searchCtrl.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  Future<void> _loadRecentSearches() async {
    final recent = await RecentSearchStore.load();
    if (mounted) setState(() => _recentSearches = recent);
  }

  Future<void> _commitSearch(String term) async {
    if (term.trim().isEmpty) return;
    final recent = await RecentSearchStore.add(term);
    if (mounted) setState(() => _recentSearches = recent);
  }

  Future<void> _removeRecentSearch(String term) async {
    final recent = await RecentSearchStore.remove(term);
    if (mounted) setState(() => _recentSearches = recent);
  }

  Future<void> _clearRecentSearches() async {
    final recent = await RecentSearchStore.clear();
    if (mounted) setState(() => _recentSearches = recent);
  }

  void _runSearch(String term) {
    _searchCtrl.text = term;
    _searchCtrl.selection = TextSelection.fromPosition(
      TextPosition(offset: term.length),
    );
    setState(() {});
    _commitSearch(term);
  }

  Future<void> _openFilterSheet() async {
    final selected = await showModalBottomSheet<String?>(
      context: context,
      backgroundColor: AppColors.creamWarm,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => _FilterSheet(selectedCategory: _category),
    );
    if (selected != _category) {
      setState(() => _category = selected);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.creamWarm,
      appBar: AppBar(
        backgroundColor: AppColors.creamWarm,
        elevation: 0,
        titleSpacing: 0,
        automaticallyImplyLeading: false,
        title: Padding(
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
          child: Row(
            children: [
              Stack(
                clipBehavior: Clip.none,
                children: [
                  IconButton(
                    onPressed: _openFilterSheet,
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(minWidth: 40, minHeight: 40),
                    style: IconButton.styleFrom(
                      backgroundColor: _category != null
                          ? AppColors.sageDeep
                          : AppColors.blushSoft,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    icon: Icon(
                      Icons.tune,
                      color: _category != null ? Colors.white : AppColors.sageMid,
                    ),
                  ),
                  if (_category != null)
                    Positioned(
                      top: 4,
                      right: 4,
                      child: Container(
                        width: 8,
                        height: 8,
                        decoration: const BoxDecoration(
                          color: AppColors.amberAccent,
                          shape: BoxShape.circle,
                        ),
                      ),
                    ),
                ],
              ),
              const SizedBox(width: AppSpacing.sm),
              Expanded(
                child: TextField(
                  controller: _searchCtrl,
                  focusNode: _focusNode,
                  textInputAction: TextInputAction.search,
                  onChanged: (_) => setState(() {}),
                  onSubmitted: _commitSearch,
                  decoration: InputDecoration(
                    hintText: 'Search shops...',
                    hintStyle: AppTypography.bodyLarge.copyWith(color: AppColors.mist),
                    prefixIcon: const Icon(Icons.search, color: AppColors.sageMid),
                    suffixIcon: _searchCtrl.text.isEmpty
                        ? null
                        : IconButton(
                            icon: const Icon(Icons.close, color: AppColors.mist, size: 18),
                            onPressed: () => setState(() => _searchCtrl.clear()),
                          ),
                    filled: true,
                    fillColor: AppColors.blushSoft,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide.none,
                    ),
                    contentPadding: const EdgeInsets.symmetric(vertical: 12, horizontal: 12),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
      body: SafeArea(
        child: Obx(() {
          // Read the reactive list unconditionally so Obx always has an
          // observable to subscribe to, even on the early-return branches
          // below (otherwise GetX throws "improper use of GetX").
          final loading = _shops.isLoading;
          final allShops = _shops.shops;

          final query = _searchCtrl.text.trim();

          if (loading && allShops.isEmpty) {
            return const Center(
              child: CircularProgressIndicator(color: AppColors.sageMid),
            );
          }

          if (query.isEmpty && _category == null) {
            return _EmptySearchState(
              recentSearches: _recentSearches,
              onRecentTap: _runSearch,
              onRecentRemove: _removeRecentSearch,
              onClearRecent: _clearRecentSearches,
              onCategoryTap: (value) => setState(() => _category = value),
            );
          }

          final results = _shops.search(query: query, category: _category);
          if (results.isEmpty) {
            return _NoResultsState(query: query, category: _category);
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
                onTap: () {
                  if (query.isNotEmpty) _commitSearch(query);
                  Get.toNamed(AppRoutes.shopDetail, arguments: shop);
                },
              );
            },
          );
        }),
      ),
    );
  }
}

class _EmptySearchState extends StatelessWidget {
  final List<String> recentSearches;
  final ValueChanged<String> onRecentTap;
  final ValueChanged<String> onRecentRemove;
  final VoidCallback onClearRecent;
  final ValueChanged<String> onCategoryTap;

  const _EmptySearchState({
    required this.recentSearches,
    required this.onRecentTap,
    required this.onRecentRemove,
    required this.onClearRecent,
    required this.onCategoryTap,
  });

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(AppSpacing.md),
      children: [
        if (recentSearches.isNotEmpty) ...[
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Recent searches', style: AppTypography.bodyMedium.copyWith(fontWeight: FontWeight.w600)),
              GestureDetector(
                onTap: onClearRecent,
                child: Text(
                  'Clear',
                  style: AppTypography.bodyMedium.copyWith(color: AppColors.sageMid),
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.sm),
          Wrap(
            spacing: AppSpacing.sm,
            runSpacing: AppSpacing.sm,
            children: [
              for (final term in recentSearches)
                _RecentSearchChip(
                  term: term,
                  onTap: () => onRecentTap(term),
                  onRemove: () => onRecentRemove(term),
                ),
            ],
          ),
          const SizedBox(height: AppSpacing.lg),
        ],
        const SizedBox(height: AppSpacing.sm),
        Text('Browse by category', style: AppTypography.bodyMedium.copyWith(fontWeight: FontWeight.w600)),
        const SizedBox(height: AppSpacing.sm),
        GridView.count(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          crossAxisCount: 2,
          crossAxisSpacing: AppSpacing.sm,
          mainAxisSpacing: AppSpacing.sm,
          childAspectRatio: 2.4,
          children: [
            for (final category in ShopCategories.all)
              _CategoryTile(
                emoji: category.emoji,
                label: category.label,
                onTap: () => onCategoryTap(category.value),
              ),
          ],
        ),
      ],
    );
  }
}

class _RecentSearchChip extends StatelessWidget {
  final String term;
  final VoidCallback onTap;
  final VoidCallback onRemove;

  const _RecentSearchChip({required this.term, required this.onTap, required this.onRemove});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.only(left: AppSpacing.md, right: AppSpacing.xs, top: 6, bottom: 6),
        decoration: BoxDecoration(
          color: AppColors.blushSoft,
          borderRadius: BorderRadius.circular(100),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.history, size: 14, color: AppColors.sageMid),
            const SizedBox(width: 6),
            Text(term, style: AppTypography.bodyMedium),
            GestureDetector(
              onTap: onRemove,
              child: const Padding(
                padding: EdgeInsets.all(4),
                child: Icon(Icons.close, size: 14, color: AppColors.mist),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _CategoryTile extends StatelessWidget {
  final String emoji;
  final String label;
  final VoidCallback onTap;

  const _CategoryTile({required this.emoji, required this.label, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(14),
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
        decoration: BoxDecoration(
          color: AppColors.blushSoft,
          borderRadius: BorderRadius.circular(14),
        ),
        alignment: Alignment.centerLeft,
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(emoji, style: const TextStyle(fontSize: 20)),
            const SizedBox(width: AppSpacing.sm),
            Flexible(
              child: Text(
                label,
                style: AppTypography.bodyMedium.copyWith(fontWeight: FontWeight.w600),
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _NoResultsState extends StatelessWidget {
  final String query;
  final String? category;

  const _NoResultsState({required this.query, required this.category});

  @override
  Widget build(BuildContext context) {
    final label = query.isNotEmpty
        ? '"$query"'
        : ShopCategories.labelFor(category ?? '');
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 64,
              height: 64,
              decoration: const BoxDecoration(
                color: AppColors.blushSoft,
                shape: BoxShape.circle,
              ),
              child: const Icon(
                HugeIcons.strokeRoundedSearchRemove,
                color: AppColors.sageDeep,
                size: 28,
              ),
            ),
            const SizedBox(height: AppSpacing.md),
            Text(
              'No shops found for $label',
              style: AppTypography.bodyMedium.copyWith(color: AppColors.mist),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}

class _FilterSheet extends StatelessWidget {
  final String? selectedCategory;

  const _FilterSheet({required this.selectedCategory});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(
          AppSpacing.md,
          AppSpacing.sm,
          AppSpacing.md,
          AppSpacing.lg,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 40,
                height: 4,
                margin: const EdgeInsets.only(bottom: AppSpacing.md),
                decoration: BoxDecoration(
                  color: AppColors.mist,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Filter by category', style: AppTypography.sectionHeader.copyWith(fontSize: 18)),
                if (selectedCategory != null)
                  GestureDetector(
                    onTap: () => Navigator.of(context).pop(null),
                    child: Text(
                      'Reset',
                      style: AppTypography.bodyMedium.copyWith(color: AppColors.sageMid),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: AppSpacing.md),
            Wrap(
              spacing: AppSpacing.sm,
              runSpacing: AppSpacing.sm,
              children: [
                for (final category in ShopCategories.all)
                  _FilterChip(
                    label: '${category.emoji} ${category.label}',
                    selected: selectedCategory == category.value,
                    onTap: () => Navigator.of(context).pop(category.value),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _FilterChip extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback onTap;

  const _FilterChip({required this.label, required this.selected, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md, vertical: 10),
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
