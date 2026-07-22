import '../../models/category_model.dart';

abstract interface class CategoryLocalDataSource {
  Future<List<CategoryModel>> getCachedCategories();
  Future<void> cacheCategories(List<CategoryModel> categories);
}

class CategoryLocalDataSourceImpl implements CategoryLocalDataSource {
  // Seeded with the same categories the app used to hardcode in
  // ShopCategories; cleared and replaced once the categories API responds.
  final List<CategoryModel> _cache = [
    CategoryModel(categoryId: 'cat_grooming', name: 'Grooming', icon: '🛁', sortOrder: 1),
    CategoryModel(categoryId: 'cat_boarding', name: 'Boarding', icon: '🏡', sortOrder: 2),
    CategoryModel(categoryId: 'cat_daycare', name: 'Daycare', icon: '🎾', sortOrder: 3),
    CategoryModel(categoryId: 'cat_pet_shop', name: 'Pet Shop', icon: '🛍️', sortOrder: 4),
  ];

  @override
  Future<List<CategoryModel>> getCachedCategories() async =>
      List.unmodifiable(_cache);

  @override
  Future<void> cacheCategories(List<CategoryModel> categories) async {
    _cache
      ..clear()
      ..addAll(categories);
  }
}
