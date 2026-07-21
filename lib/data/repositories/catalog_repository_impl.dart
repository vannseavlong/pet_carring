import '../../core/errors/app_exception.dart';
import '../../domain/entities/catalog_item.dart';
import '../../domain/repositories/catalog_repository.dart';
import '../datasources/local/catalog_local_datasource.dart';
import '../datasources/remote/catalog_remote_datasource.dart';

class CatalogRepositoryImpl implements CatalogRepository {
  final CatalogRemoteDataSource _remote;
  final CatalogLocalDataSource _local;

  CatalogRepositoryImpl(this._remote, this._local);

  @override
  Future<List<CatalogItem>> getCatalogItems(String shopId) async {
    try {
      final items = await _remote.getCatalogItems(shopId);
      await _local.cacheCatalogItems(shopId, items);
      return items;
    } on AppException {
      return _local.getCachedCatalogItems(shopId);
    }
  }

  @override
  Future<List<CatalogItem>> getFeaturedItems({String? type, int? limit}) async {
    try {
      final items = await _remote.getFeaturedItems(type: type, limit: limit);
      await _local.cacheFeaturedItems(items);
      return items;
    } on AppException {
      return _local.getCachedFeaturedItems(type: type, limit: limit);
    }
  }
}
