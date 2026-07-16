import 'package:dio/dio.dart';
import '../../../core/errors/app_exception.dart';
import '../../../core/network/api_client.dart';
import '../../../core/network/api_endpoints.dart';
import '../../models/shop_model.dart';

abstract interface class ShopRemoteDataSource {
  Future<List<ShopModel>> getShops();
  Future<ShopModel> getShopById(String id);
}

class ShopRemoteDataSourceImpl implements ShopRemoteDataSource {
  final ApiClient _apiClient;

  ShopRemoteDataSourceImpl(this._apiClient);

  @override
  Future<List<ShopModel>> getShops() async {
    try {
      final response = await _apiClient.dio.get(ApiEndpoints.shops);
      final data = response.data['shops'] as List<dynamic>;
      return data
          .map((e) => ShopModel.fromJson(e as Map<String, dynamic>))
          .toList();
    } on DioException catch (e) {
      throw NetworkException(
        e.message ?? 'Network error',
        statusCode: e.response?.statusCode,
      );
    }
  }

  @override
  Future<ShopModel> getShopById(String id) async {
    try {
      final response = await _apiClient.dio.get(ApiEndpoints.shopById(id));
      return ShopModel.fromJson(
        response.data['shop'] as Map<String, dynamic>,
      );
    } on DioException catch (e) {
      throw NetworkException(
        e.message ?? 'Network error',
        statusCode: e.response?.statusCode,
      );
    }
  }
}
