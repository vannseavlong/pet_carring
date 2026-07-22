import 'package:dio/dio.dart';
import 'package:get/get.dart';
import '../../core/errors/app_exception.dart';
import '../../domain/entities/user.dart';
import '../../domain/usecases/get_current_user_usecase.dart';
import '../../domain/usecases/login_usecase.dart';
import '../../domain/usecases/login_with_google_token_usecase.dart';
import '../../domain/usecases/logout_usecase.dart';
import '../../domain/usecases/register_usecase.dart';

// Admin and merchant accounts have no per-user Google Sheet (see
// paw_sheetDB's requireActorSheet()), so bookings/profile calls 422 for
// them. This app is customer-only — admins use admin_portal, merchants use
// their own dashboard — so those roles are rejected right after login
// instead of failing later on a booking with a cryptic error.
const _unsupportedRoleMessage =
    'This app is for customer accounts only. Admins and merchants should use their dedicated portal.';

bool _isCustomerRole(User user) => user.role == 'user';

class AuthController extends GetxController {
  final GetCurrentUserUseCase _getCurrentUser;
  final LoginUseCase _login;
  final RegisterUseCase _register;
  final LogoutUseCase _logout;
  final LoginWithGoogleTokenUseCase _loginWithGoogleToken;

  AuthController(
    this._getCurrentUser,
    this._login,
    this._register,
    this._logout,
    this._loginWithGoogleToken,
  );

  final isChecking = true.obs;
  final isLoggedIn = false.obs;
  final isLoading = false.obs;
  final Rx<User?> currentUser = Rx<User?>(null);
  final errorMessage = ''.obs;

  @override
  void onInit() {
    super.onInit();
    _checkSession();
  }

  Future<void> _checkSession() async {
    final user = await _getCurrentUser();
    if (user != null && !_isCustomerRole(user)) {
      await _logout();
      currentUser.value = null;
      isLoggedIn.value = false;
      isChecking.value = false;
      return;
    }
    currentUser.value = user;
    isLoggedIn.value = user != null;
    isChecking.value = false;
  }

  Future<void> login({required String email, required String password}) async {
    errorMessage.value = '';
    isLoading.value = true;
    try {
      final user = await _login(email: email, password: password);
      if (!_isCustomerRole(user)) {
        await _logout();
        errorMessage.value = _unsupportedRoleMessage;
        throw const AppException(_unsupportedRoleMessage);
      }
      currentUser.value = user;
      isLoggedIn.value = true;
    } on DioException catch (e) {
      errorMessage.value = _extractErrorMessage(e, 'Login failed');
      rethrow;
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> register({
    required String fullName,
    required String email,
    required String password,
  }) async {
    errorMessage.value = '';
    isLoading.value = true;
    try {
      final user =
          await _register(fullName: fullName, email: email, password: password);
      currentUser.value = user;
      isLoggedIn.value = true;
    } on DioException catch (e) {
      errorMessage.value = _extractErrorMessage(e, 'Registration failed');
      rethrow;
    } finally {
      isLoading.value = false;
    }
  }

  String _extractErrorMessage(DioException e, String fallback) {
    final data = e.response?.data;
    if (data is! Map) return fallback;
    final error = data['error'] as String? ?? fallback;
    final details = data['details'];
    if (details is List && details.isNotEmpty) {
      return '$error: ${details.join(', ')}';
    }
    return error;
  }

  Future<void> completeGoogleSignIn(String token) async {
    errorMessage.value = '';
    isLoading.value = true;
    try {
      final user = await _loginWithGoogleToken(token);
      if (!_isCustomerRole(user)) {
        await _logout();
        errorMessage.value = _unsupportedRoleMessage;
        return;
      }
      currentUser.value = user;
      isLoggedIn.value = true;
    } catch (_) {
      errorMessage.value = 'Google sign-in failed';
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> logout() async {
    await _logout();
    currentUser.value = null;
    isLoggedIn.value = false;
  }
}
