import '../../domain/entities/catalog_item.dart';
import '../../domain/repositories/catalog_repository.dart';
import '../datasources/remote/catalog_remote_datasource.dart';

class CatalogRepositoryImpl implements CatalogRepository {
  final CatalogRemoteDataSource _remote;

  CatalogRepositoryImpl(this._remote);

  @override
  Future<List<CatalogItem>> getCatalogItems(String shopId) {
    return _remote.getCatalogItems(shopId);
  }

  @override
  Future<List<CatalogItem>> getFeaturedItems({String? type, int? limit}) {
    return _remote.getFeaturedItems(type: type, limit: limit);
  }
}
