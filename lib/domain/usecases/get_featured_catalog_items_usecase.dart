import '../entities/catalog_item.dart';
import '../repositories/catalog_repository.dart';

/// Cross-shop catalog items for home-screen sections like "Featured
/// Products" (`type: CatalogItemType.product`).
class GetFeaturedCatalogItemsUseCase {
  final CatalogRepository _repository;

  GetFeaturedCatalogItemsUseCase(this._repository);

  Future<List<CatalogItem>> call({String? type, int? limit}) =>
      _repository.getFeaturedItems(type: type, limit: limit);
}
