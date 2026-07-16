import '../entities/shop.dart';

abstract interface class ShopRepository {
  Future<List<Shop>> getShops();
  Future<Shop> getShopById(String shopId);
}
