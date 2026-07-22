import '../../domain/entities/shop.dart';
import '../../domain/repositories/shop_repository.dart';
import '../datasources/remote/shop_remote_datasource.dart';

class ShopRepositoryImpl implements ShopRepository {
  final ShopRemoteDataSource _remote;

  ShopRepositoryImpl(this._remote);

  @override
  Future<List<Shop>> getShops() {
    return _remote.getShops();
  }

  @override
  Future<Shop> getShopById(String shopId) {
    return _remote.getShopById(shopId);
  }
}
