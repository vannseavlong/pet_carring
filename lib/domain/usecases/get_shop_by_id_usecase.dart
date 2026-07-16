import '../entities/shop.dart';
import '../repositories/shop_repository.dart';

class GetShopByIdUseCase {
  final ShopRepository _repository;

  GetShopByIdUseCase(this._repository);

  Future<Shop> call(String shopId) => _repository.getShopById(shopId);
}
