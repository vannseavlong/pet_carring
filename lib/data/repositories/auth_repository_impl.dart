import '../../core/network/api_client.dart';
import '../../domain/entities/user.dart';
import '../../domain/repositories/auth_repository.dart';
import '../datasources/remote/auth_remote_datasource.dart';

class AuthRepositoryImpl implements AuthRepository {
  final AuthRemoteDataSource _remote;
  final ApiClient _client;

  const AuthRepositoryImpl(this._remote, this._client);

  @override
  Future<User> login({required String email, required String password}) async {
    final (user, token) = await _remote.login(email: email, password: password);
    await _client.saveToken(token);
    return user;
  }

  @override
  Future<User> register({
    required String fullName,
    required String email,
    required String password,
  }) async {
    final (user, token) = await _remote.register(
      fullName: fullName,
      email: email,
      password: password,
    );
    await _client.saveToken(token);
    return user;
  }

  @override
  Future<User?> getCurrentUser() async {
    try {
      final hasToken = await _client.hasToken();
      if (!hasToken) return null;
      return await _remote.getMe();
    } catch (_) {
      return null;
    }
  }

  @override
  Future<User> loginWithGoogleToken(String token) async {
    await _client.saveToken(token);
    return await _remote.getMe();
  }

  @override
  Future<void> logout() => _client.clearToken();
}
