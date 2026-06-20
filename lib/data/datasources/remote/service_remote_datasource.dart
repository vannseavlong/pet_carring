import 'package:dio/dio.dart';
import '../../../core/errors/app_exception.dart';
import '../../../core/network/api_client.dart';
import '../../../core/network/api_endpoints.dart';
import '../../models/service_model.dart';

abstract interface class ServiceRemoteDataSource {
  Future<List<ServiceModel>> getServices();
}

class ServiceRemoteDataSourceImpl implements ServiceRemoteDataSource {
  final ApiClient _apiClient;

  ServiceRemoteDataSourceImpl(this._apiClient);

  @override
  Future<List<ServiceModel>> getServices() async {
    try {
      final response = await _apiClient.dio.get(ApiEndpoints.services);
      final data = response.data['services'] as List<dynamic>;
      return data
          .map((e) => ServiceModel.fromJson(e as Map<String, dynamic>))
          .toList();
    } on DioException catch (e) {
      throw NetworkException(
        e.message ?? 'Network error',
        statusCode: e.response?.statusCode,
      );
    }
  }
}
