import '../entities/shop.dart';
import '../repositories/shop_repository.dart';

class GetShopsUseCase {
  final ShopRepository _repository;

  GetShopsUseCase(this._repository);

  Future<List<Shop>> call() => _repository.getShops();
}
