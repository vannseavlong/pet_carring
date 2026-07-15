import '../entities/catalog_item.dart';

abstract interface class CatalogRepository {
  Future<List<CatalogItem>> getCatalogItems(String shopId);
}
