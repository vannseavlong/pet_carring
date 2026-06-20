import '../entities/service.dart';
import '../repositories/service_repository.dart';

class GetServicesUseCase {
  final ServiceRepository _repository;

  GetServicesUseCase(this._repository);

  Future<List<Service>> call() => _repository.getServices();
}
