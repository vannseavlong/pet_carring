import '../entities/user.dart';
import '../repositories/auth_repository.dart';

class LoginWithGoogleTokenUseCase {
  final AuthRepository _repository;
  const LoginWithGoogleTokenUseCase(this._repository);

  Future<User> call(String token) => _repository.loginWithGoogleToken(token);
}
