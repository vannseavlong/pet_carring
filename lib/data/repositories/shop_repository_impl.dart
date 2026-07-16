import '../../core/errors/app_exception.dart';
import '../../domain/entities/shop.dart';
import '../../domain/repositories/shop_repository.dart';
import '../datasources/local/shop_local_datasource.dart';
import '../datasources/remote/shop_remote_datasource.dart';

class ShopRepositoryImpl implements ShopRepository {
  final ShopRemoteDataSource _remote;
  final ShopLocalDataSource _local;

  ShopRepositoryImpl(this._remote, this._local);

  @override
  Future<List<Shop>> getShops() async {
    try {
      final shops = await _remote.getShops();
      await _local.cacheShops(shops);
      return shops;
    } on AppException {
      return _local.getCachedShops();
    }
  }

  @override
  Future<Shop> getShopById(String shopId) async {
    try {
      return await _remote.getShopById(shopId);
    } on AppException {
      final cached = await _local.getCachedShops();
      for (final shop in cached) {
        if (shop.shopId == shopId) return shop;
      }
      rethrow;
    }
  }
}
