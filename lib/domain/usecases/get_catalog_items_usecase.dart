import '../entities/catalog_item.dart';
import '../repositories/catalog_repository.dart';

class GetCatalogItemsUseCase {
  final CatalogRepository _repository;

  GetCatalogItemsUseCase(this._repository);

  Future<List<CatalogItem>> call(String shopId) =>
      _repository.getCatalogItems(shopId);
}
