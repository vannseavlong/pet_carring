import '../entities/user.dart';

abstract interface class AuthRepository {
  Future<User> login({required String email, required String password});
  Future<User> register({
    required String fullName,
    required String email,
    required String password,
  });
  Future<User?> getCurrentUser();
  Future<void> logout();
}
