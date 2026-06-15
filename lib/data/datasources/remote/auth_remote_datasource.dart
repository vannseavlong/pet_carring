import '../../../core/network/api_client.dart';
import '../../../core/network/api_endpoints.dart';
import '../../models/user_model.dart';

abstract interface class AuthRemoteDataSource {
  Future<(UserModel, String)> login({
    required String email,
    required String password,
  });
  Future<(UserModel, String)> register({
    required String fullName,
    required String email,
    required String password,
  });
  Future<UserModel> getMe();
}

class AuthRemoteDataSourceImpl implements AuthRemoteDataSource {
  final ApiClient _client;
  const AuthRemoteDataSourceImpl(this._client);

  @override
  Future<(UserModel, String)> login({
    required String email,
    required String password,
  }) async {
    final res = await _client.post(
      ApiEndpoints.login,
      data: {'email': email, 'password': password},
    );
    final data = res.data as Map<String, dynamic>;
    return (
      UserModel.fromJson(data['user'] as Map<String, dynamic>),
      data['token'] as String,
    );
  }

  @override
  Future<(UserModel, String)> register({
    required String fullName,
    required String email,
    required String password,
  }) async {
    final res = await _client.post(
      ApiEndpoints.register,
      data: {'full_name': fullName, 'email': email, 'password': password},
    );
    final data = res.data as Map<String, dynamic>;
    return (
      UserModel.fromJson(data['user'] as Map<String, dynamic>),
      data['token'] as String,
    );
  }

  @override
  Future<UserModel> getMe() async {
    final res = await _client.get(ApiEndpoints.me);
    return UserModel.fromJson(res.data['user'] as Map<String, dynamic>);
  }
}
