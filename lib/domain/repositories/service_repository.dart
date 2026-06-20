import '../entities/service.dart';

abstract interface class ServiceRepository {
  Future<List<Service>> getServices();
}
