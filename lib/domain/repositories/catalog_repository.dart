import '../entities/catalog_item.dart';

abstract interface class CatalogRepository {
  Future<List<CatalogItem>> getCatalogItems(String shopId);

  /// Cross-shop catalog items (e.g. for a home-screen "Featured Products"
  /// grid). [type] filters by `CatalogItemType`; [limit] caps result count.
  Future<List<CatalogItem>> getFeaturedItems({String? type, int? limit});
}
