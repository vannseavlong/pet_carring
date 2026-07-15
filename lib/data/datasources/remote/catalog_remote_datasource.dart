import 'package:dio/dio.dart';
import '../../../core/errors/app_exception.dart';
import '../../../core/network/api_client.dart';
import '../../../core/network/api_endpoints.dart';
import '../../models/catalog_item_model.dart';

abstract interface class CatalogRemoteDataSource {
  Future<List<CatalogItemModel>> getCatalogItems(String shopId);
}

class CatalogRemoteDataSourceImpl implements CatalogRemoteDataSource {
  final ApiClient _apiClient;

  CatalogRemoteDataSourceImpl(this._apiClient);

  @override
  Future<List<CatalogItemModel>> getCatalogItems(String shopId) async {
    try {
      final response = await _apiClient.dio.get(
        ApiEndpoints.shopCatalogItems(shopId),
      );
      final data = response.data['items'] as List<dynamic>;
      return data
          .map((e) => CatalogItemModel.fromJson(e as Map<String, dynamic>))
          .toList();
    } on DioException catch (e) {
      throw NetworkException(
        e.message ?? 'Network error',
        statusCode: e.response?.statusCode,
      );
    }
  }
}
