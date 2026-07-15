import '../entities/shop.dart';

abstract interface class ShopRepository {
  Future<List<Shop>> getShops();
}
