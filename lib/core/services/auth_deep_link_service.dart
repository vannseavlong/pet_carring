import 'dart:async';
import 'package:app_links/app_links.dart';
import 'package:get/get.dart';
import '../../presentation/controllers/auth_controller.dart';

/// Listens for the `paw://auth-callback?token=...` redirect the backend's
/// Google OAuth flow sends the system browser back to.
class AuthDeepLinkService {
  final AppLinks _appLinks = AppLinks();
  StreamSubscription<Uri>? _subscription;

  Future<void> init() async {
    _subscription = _appLinks.uriLinkStream.listen(_handleUri);
    // Covers a cold start: if Android killed the app while the user was in
    // the browser completing Google sign-in, the redirect that relaunches
    // the app never reaches uriLinkStream — only getInitialLink() sees it.
    final initialUri = await _appLinks.getInitialLink();
    if (initialUri != null) _handleUri(initialUri);
  }

  void _handleUri(Uri uri) {
    if (uri.scheme != 'paw' || uri.host != 'auth-callback') return;
    final token = uri.queryParameters['token'];
    if (token == null) return;
    Get.find<AuthController>().completeGoogleSignIn(token);
  }

  void dispose() => _subscription?.cancel();
}
