import '../../core/errors/app_exception.dart';
import '../../domain/entities/service.dart';
import '../../domain/repositories/service_repository.dart';
import '../datasources/local/service_local_datasource.dart';
import '../datasources/remote/service_remote_datasource.dart';

class ServiceRepositoryImpl implements ServiceRepository {
  final ServiceRemoteDataSource _remote;
  final ServiceLocalDataSource _local;

  ServiceRepositoryImpl(this._remote, this._local);

  @override
  Future<List<Service>> getServices() async {
    try {
      final services = await _remote.getServices();
      await _local.cacheServices(services);
      return services;
    } on AppException {
      return _local.getCachedServices();
    }
  }
}
