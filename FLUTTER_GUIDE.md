# Paw — Flutter Integration Guide

Backend base URL: `http://localhost:3000` (dev) / `https://your-api.com` (prod)

All authenticated endpoints require:
```
Authorization: Bearer <jwt_token>
```

---

## 1. Dependencies

```yaml
# pubspec.yaml
dependencies:
  dio: ^5.7.0
  flutter_secure_storage: ^9.2.2
  app_links: ^6.3.2            # deep-link catch for OAuth callback
  google_sign_in: ^6.2.1       # optional — native Google Sign-In (simpler than redirect)
  flutter_svg: ^2.0.10
  cached_network_image: ^3.4.1
  intl: ^0.19.0
```

---

## 2. API Client (`lib/core/network/api_client.dart`)

```dart
import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class ApiClient {
  static const _baseUrl = 'http://localhost:3000'; // change for prod

  late final Dio _dio;
  final _storage = const FlutterSecureStorage();

  ApiClient() {
    _dio = Dio(BaseOptions(
      baseUrl: _baseUrl,
      connectTimeout: const Duration(seconds: 10),
      receiveTimeout: const Duration(seconds: 15),
    ));

    _dio.interceptors.add(InterceptorsWrapper(
      onRequest: (options, handler) async {
        final token = await _storage.read(key: 'jwt_token');
        if (token != null) options.headers['Authorization'] = 'Bearer $token';
        handler.next(options);
      },
      onError: (e, handler) {
        if (e.response?.statusCode == 401) {
          // Token expired → navigate to login
        }
        handler.next(e);
      },
    ));
  }

  Future<Response> get(String path, {Map<String, dynamic>? params}) =>
      _dio.get(path, queryParameters: params);

  Future<Response> post(String path, {dynamic data}) =>
      _dio.post(path, data: data);

  Future<Response> patch(String path, {dynamic data}) =>
      _dio.patch(path, data: data);

  Future<void> saveToken(String token) =>
      _storage.write(key: 'jwt_token', value: token);

  Future<void> clearToken() => _storage.delete(key: 'jwt_token');
}

final apiClient = ApiClient(); // simple singleton; swap for Riverpod/GetIt if preferred
```

---

## 3. Models

### `lib/features/auth/models/user_model.dart`

```dart
class UserModel {
  final String userId;
  final String email;
  final String fullName;
  final String role;
  final String? picture;
  final String? actorSheetId;

  const UserModel({
    required this.userId,
    required this.email,
    required this.fullName,
    required this.role,
    this.picture,
    this.actorSheetId,
  });

  factory UserModel.fromJson(Map<String, dynamic> j) => UserModel(
        userId:        j['user_id'] as String,
        email:         j['email'] as String,
        fullName:      j['full_name'] as String,
        role:          j['role'] as String,
        picture:       j['picture'] as String?,
        actorSheetId:  j['actor_sheet_id'] as String?,
      );
}
```

### `lib/features/services/models/service_model.dart`

```dart
class ServiceModel {
  final String serviceId;
  final String name;
  final String description;
  final double priceFrom;
  final String icon;    // key into your local icon map
  final String color;   // hex string e.g. "#D6EAE4"
  final String category;

  const ServiceModel({
    required this.serviceId,
    required this.name,
    required this.description,
    required this.priceFrom,
    required this.icon,
    required this.color,
    required this.category,
  });

  factory ServiceModel.fromJson(Map<String, dynamic> j) => ServiceModel(
        serviceId:   j['service_id'] as String,
        name:        j['name'] as String,
        description: j['description'] as String? ?? '',
        priceFrom:   (j['price_from'] as num).toDouble(),
        icon:        j['icon'] as String,
        color:       j['color'] as String,
        category:    j['category'] as String,
      );

  Color get backgroundColor {
    final hex = color.replaceFirst('#', '');
    return Color(int.parse('FF$hex', radix: 16));
  }
}
```

---

## 4. Auth Service (`lib/features/auth/services/auth_service.dart`)

```dart
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../../../core/network/api_client.dart';
import '../models/user_model.dart';

class AuthService {
  final _storage = const FlutterSecureStorage();

  // ── Email + Password ──────────────────────────────────────────────────────

  Future<UserModel> register({
    required String fullName,
    required String email,
    required String password,
  }) async {
    final res = await apiClient.post('/auth/register', data: {
      'full_name': fullName,
      'email':     email,
      'password':  password,
    });
    await apiClient.saveToken(res.data['token'] as String);
    return UserModel.fromJson(res.data['user'] as Map<String, dynamic>);
  }

  Future<UserModel> login({
    required String email,
    required String password,
  }) async {
    final res = await apiClient.post('/auth/login', data: {
      'email':    email,
      'password': password,
    });
    await apiClient.saveToken(res.data['token'] as String);
    return UserModel.fromJson(res.data['user'] as Map<String, dynamic>);
  }

  // ── Google OAuth (redirect flow) ──────────────────────────────────────────
  // The backend opens /auth/google → Google → /auth/callback → deep-link back.
  // Use app_links to catch the deep link and extract the JWT.
  //
  // In main.dart, set up the listener once:
  //
  //   AppLinks().uriLinkStream.listen((uri) {
  //     if (uri.host == 'auth' && uri.queryParameters['token'] != null) {
  //       apiClient.saveToken(uri.queryParameters['token']!);
  //       // navigate to home
  //     }
  //   });
  //
  // Then launch the OAuth URL:
  //
  //   await launchUrl(
  //     Uri.parse('http://localhost:3000/auth/google'),
  //     mode: LaunchMode.externalApplication,
  //   );

  // ── Current user ──────────────────────────────────────────────────────────

  Future<UserModel?> me() async {
    try {
      final res = await apiClient.get('/auth/me');
      return UserModel.fromJson(res.data['user'] as Map<String, dynamic>);
    } catch (_) {
      return null;
    }
  }

  Future<void> logout() => apiClient.clearToken();
}
```

---

## 5. Login Page (`lib/features/auth/pages/login_page.dart`)

Matches the design: cream background, dark-green primary, orange accent.

```dart
import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import '../services/auth_service.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});
  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _formKey    = GlobalKey<FormState>();
  final _emailCtrl  = TextEditingController();
  final _passCtrl   = TextEditingController();
  final _auth       = AuthService();
  bool  _loading    = false;
  bool  _obscure    = true;

  static const _green  = Color(0xFF2C4A3E);
  static const _cream  = Color(0xFFF5F0E8);
  static const _orange = Color(0xFFE07B39);

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _loading = true);
    try {
      await _auth.login(email: _emailCtrl.text.trim(), password: _passCtrl.text);
      if (!mounted) return;
      Navigator.pushReplacementNamed(context, '/home');
    } on DioException catch (e) {
      final msg = (e.response?.data as Map?)?['error'] ?? 'Login failed';
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _googleSignIn() async {
    // Launch backend OAuth redirect — app_links listener in main.dart handles the return
    // await launchUrl(Uri.parse('http://localhost:3000/auth/google'),
    //     mode: LaunchMode.externalApplication);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _cream,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 40),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 24),
                // Logo / wordmark
                Text('🐾', style: const TextStyle(fontSize: 40)),
                const SizedBox(height: 8),
                Text('Welcome back',
                    style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: _green)),
                const SizedBox(height: 4),
                Text('Sign in to your Paw account',
                    style: TextStyle(color: Colors.grey.shade600)),
                const SizedBox(height: 40),

                // Email field
                _label('Email'),
                TextFormField(
                  controller: _emailCtrl,
                  keyboardType: TextInputType.emailAddress,
                  decoration: _inputDeco('e.g. alex@email.com'),
                  validator: (v) =>
                      v != null && v.contains('@') ? null : 'Enter a valid email',
                ),
                const SizedBox(height: 16),

                // Password field
                _label('Password'),
                TextFormField(
                  controller: _passCtrl,
                  obscureText: _obscure,
                  decoration: _inputDeco('••••••••').copyWith(
                    suffixIcon: IconButton(
                      icon: Icon(_obscure ? Icons.visibility_off : Icons.visibility),
                      onPressed: () => setState(() => _obscure = !_obscure),
                    ),
                  ),
                  validator: (v) =>
                      v != null && v.length >= 8 ? null : 'Minimum 8 characters',
                ),
                const SizedBox(height: 32),

                // Sign in button
                SizedBox(
                  width: double.infinity,
                  height: 52,
                  child: ElevatedButton(
                    onPressed: _loading ? null : _submit,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: _green,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14)),
                    ),
                    child: _loading
                        ? const CircularProgressIndicator(color: Colors.white)
                        : const Text('Sign In',
                            style: TextStyle(color: Colors.white, fontSize: 16,
                                fontWeight: FontWeight.w600)),
                  ),
                ),
                const SizedBox(height: 16),

                // Divider
                Row(children: [
                  Expanded(child: Divider(color: Colors.grey.shade300)),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    child: Text('or', style: TextStyle(color: Colors.grey.shade500)),
                  ),
                  Expanded(child: Divider(color: Colors.grey.shade300)),
                ]),
                const SizedBox(height: 16),

                // Google Sign-In button
                SizedBox(
                  width: double.infinity,
                  height: 52,
                  child: OutlinedButton.icon(
                    onPressed: _googleSignIn,
                    icon: Image.asset('assets/icons/google.png', width: 20),
                    label: const Text('Continue with Google'),
                    style: OutlinedButton.styleFrom(
                      side: BorderSide(color: Colors.grey.shade300),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14)),
                    ),
                  ),
                ),
                const SizedBox(height: 24),

                // Sign up link
                Center(
                  child: GestureDetector(
                    onTap: () => Navigator.pushNamed(context, '/register'),
                    child: RichText(
                      text: TextSpan(
                        style: TextStyle(color: Colors.grey.shade600),
                        children: [
                          const TextSpan(text: "Don't have an account? "),
                          TextSpan(text: 'Sign Up',
                              style: TextStyle(color: _orange,
                                  fontWeight: FontWeight.w600)),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _label(String text) => Padding(
        padding: const EdgeInsets.only(bottom: 6),
        child: Text(text,
            style: const TextStyle(
                fontWeight: FontWeight.w600, fontSize: 13,
                letterSpacing: 0.5)),
      );

  InputDecoration _inputDeco(String hint) => InputDecoration(
        hintText: hint,
        filled: true,
        fillColor: Colors.white,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.grey.shade200),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.grey.shade200),
        ),
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      );
}
```

---

## 6. Sign Up Page (`lib/features/auth/pages/register_page.dart`)

```dart
import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import '../services/auth_service.dart';

class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});
  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final _formKey   = GlobalKey<FormState>();
  final _nameCtrl  = TextEditingController();
  final _emailCtrl = TextEditingController();
  final _passCtrl  = TextEditingController();
  final _auth      = AuthService();
  bool  _loading   = false;

  static const _green  = Color(0xFF2C4A3E);
  static const _cream  = Color(0xFFF5F0E8);
  static const _orange = Color(0xFFE07B39);

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _loading = true);
    try {
      await _auth.register(
        fullName: _nameCtrl.text.trim(),
        email:    _emailCtrl.text.trim(),
        password: _passCtrl.text,
      );
      if (!mounted) return;
      Navigator.pushReplacementNamed(context, '/home');
    } on DioException catch (e) {
      final msg = (e.response?.data as Map?)?['error'] ?? 'Registration failed';
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _cream,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 40),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                IconButton(
                  icon: Icon(Icons.arrow_back, color: _green),
                  onPressed: () => Navigator.pop(context),
                ),
                const SizedBox(height: 16),
                Text('🐾', style: const TextStyle(fontSize: 40)),
                const SizedBox(height: 8),
                Text('Create account',
                    style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold,
                        color: _green)),
                const SizedBox(height: 4),
                Text('Join Paw and book services for your pet',
                    style: TextStyle(color: Colors.grey.shade600)),
                const SizedBox(height: 40),

                _label('Full name'),
                TextFormField(
                  controller: _nameCtrl,
                  decoration: _inputDeco('e.g. Alex Johnson'),
                  textCapitalization: TextCapitalization.words,
                  validator: (v) =>
                      v != null && v.trim().length >= 2 ? null : 'Enter your name',
                ),
                const SizedBox(height: 16),

                _label('Email'),
                TextFormField(
                  controller: _emailCtrl,
                  keyboardType: TextInputType.emailAddress,
                  decoration: _inputDeco('e.g. alex@email.com'),
                  validator: (v) =>
                      v != null && v.contains('@') ? null : 'Enter a valid email',
                ),
                const SizedBox(height: 16),

                _label('Password'),
                TextFormField(
                  controller: _passCtrl,
                  obscureText: true,
                  decoration: _inputDeco('Min. 8 characters'),
                  validator: (v) =>
                      v != null && v.length >= 8 ? null : 'Minimum 8 characters',
                ),
                const SizedBox(height: 32),

                SizedBox(
                  width: double.infinity,
                  height: 52,
                  child: ElevatedButton(
                    onPressed: _loading ? null : _submit,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: _green,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14)),
                    ),
                    child: _loading
                        ? const CircularProgressIndicator(color: Colors.white)
                        : const Text('Create Account',
                            style: TextStyle(color: Colors.white, fontSize: 16,
                                fontWeight: FontWeight.w600)),
                  ),
                ),
                const SizedBox(height: 24),

                Center(
                  child: GestureDetector(
                    onTap: () => Navigator.pop(context),
                    child: RichText(
                      text: TextSpan(
                        style: TextStyle(color: Colors.grey.shade600),
                        children: [
                          const TextSpan(text: 'Already have an account? '),
                          TextSpan(text: 'Sign In',
                              style: TextStyle(color: _orange,
                                  fontWeight: FontWeight.w600)),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _label(String text) => Padding(
        padding: const EdgeInsets.only(bottom: 6),
        child: Text(text,
            style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13,
                letterSpacing: 0.5)),
      );

  InputDecoration _inputDeco(String hint) => InputDecoration(
        hintText: hint,
        filled: true,
        fillColor: Colors.white,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.grey.shade200),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.grey.shade200),
        ),
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      );
}
```

---

## 7. Services Repository (`lib/features/services/services_repository.dart`)

```dart
import '../../../core/network/api_client.dart';
import 'models/service_model.dart';

class ServicesRepository {
  Future<List<ServiceModel>> getServices() async {
    final res = await apiClient.get('/services');
    final list = res.data['services'] as List<dynamic>;
    return list
        .map((j) => ServiceModel.fromJson(j as Map<String, dynamic>))
        .toList();
  }

  Future<ServiceModel> getService(String serviceId) async {
    final res = await apiClient.get('/services/$serviceId');
    return ServiceModel.fromJson(res.data['service'] as Map<String, dynamic>);
  }
}
```

---

## 8. Home Page — Services Grid (`lib/features/home/pages/home_page.dart`)

Matches the design: 2-column card grid, icon circle in top-left of card, name + "From \$X" below.

```dart
import 'package:flutter/material.dart';
import '../../services/models/service_model.dart';
import '../../services/services_repository.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});
  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final _repo     = ServicesRepository();
  List<ServiceModel> _services = [];
  bool _loading = true;

  static const _green  = Color(0xFF2C4A3E);
  static const _cream  = Color(0xFFF5F0E8);
  static const _orange = Color(0xFFE07B39);

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    try {
      final s = await _repo.getServices();
      if (mounted) setState(() { _services = s; _loading = false; });
    } catch (_) {
      if (mounted) setState(() => _loading = false);
    }
  }

  // Map service icon keys → Flutter icons
  // Add more as needed
  static const _iconMap = <String, IconData>{
    'spray_bottle': Icons.water_drop,
    'bone':         Icons.pets,
    'tennis_ball':  Icons.sports_tennis,
    'meds_hand':    Icons.medication,
    'scissors':     Icons.content_cut,
    'car':          Icons.directions_car,
  };

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _cream,
      body: SafeArea(
        child: CustomScrollView(
          slivers: [
            // ── Header ──────────────────────────────────────────────────────
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
                child: Row(
                  children: [
                    const CircleAvatar(radius: 22,
                        backgroundImage: AssetImage('assets/images/avatar.png')),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Good morning,',
                              style: TextStyle(color: Colors.grey.shade500,
                                  fontSize: 13)),
                          const Text('Alex 🐾',
                              style: TextStyle(fontSize: 22,
                                  fontWeight: FontWeight.bold)),
                        ],
                      ),
                    ),
                    Stack(
                      children: [
                        Container(
                          width: 44, height: 44,
                          decoration: BoxDecoration(
                            color: _cream,
                            shape: BoxShape.circle,
                            border: Border.all(color: Colors.grey.shade200),
                          ),
                          child: const Icon(Icons.notifications_outlined),
                        ),
                        Positioned(
                          right: 4, top: 4,
                          child: Container(
                            width: 16, height: 16,
                            decoration: const BoxDecoration(
                                color: _orange, shape: BoxShape.circle),
                            child: const Center(
                              child: Text('3',
                                  style: TextStyle(color: Colors.white,
                                      fontSize: 10, fontWeight: FontWeight.bold)),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),

            // ── Checked-in banner ────────────────────────────────────────────
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                  decoration: BoxDecoration(
                    color: _green,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.pets, color: Colors.white, size: 20),
                      const SizedBox(width: 10),
                      const Expanded(
                        child: Text.rich(TextSpan(
                          style: TextStyle(color: Colors.white),
                          children: [
                            TextSpan(text: '3 pets checked in',
                                style: TextStyle(fontWeight: FontWeight.bold)),
                            TextSpan(text: '  ·  2 spots left'),
                          ],
                        )),
                      ),
                      GestureDetector(
                        onTap: () => Navigator.pushNamed(context, '/stays'),
                        child: Text('View →',
                            style: TextStyle(color: _orange,
                                fontWeight: FontWeight.w600)),
                      ),
                    ],
                  ),
                ),
              ),
            ),

            // ── Section title ────────────────────────────────────────────────
            const SliverToBoxAdapter(
              child: Padding(
                padding: EdgeInsets.fromLTRB(20, 24, 20, 12),
                child: Text('Our Services',
                    style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
              ),
            ),

            // ── Services grid ────────────────────────────────────────────────
            _loading
                ? const SliverFillRemaining(
                    child: Center(child: CircularProgressIndicator()))
                : SliverPadding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    sliver: SliverGrid(
                      gridDelegate:
                          const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 2,
                        crossAxisSpacing: 12,
                        mainAxisSpacing: 12,
                        childAspectRatio: 0.9,
                      ),
                      delegate: SliverChildBuilderDelegate(
                        (context, index) =>
                            _ServiceCard(service: _services[index]),
                        childCount: _services.length,
                      ),
                    ),
                  ),

            const SliverToBoxAdapter(child: SizedBox(height: 100)),
          ],
        ),
      ),
    );
  }
}

class _ServiceCard extends StatelessWidget {
  final ServiceModel service;
  const _ServiceCard({required this.service});

  static const _iconMap = <String, IconData>{
    'spray_bottle': Icons.water_drop,
    'bone':         Icons.pets,
    'tennis_ball':  Icons.sports_tennis,
    'meds_hand':    Icons.medication,
    'scissors':     Icons.content_cut,
    'car':          Icons.directions_car,
  };

  @override
  Widget build(BuildContext context) {
    final bgColor = service.backgroundColor;
    // Slightly darker shade for the icon circle
    final iconBg = HSLColor.fromColor(bgColor)
        .withLightness((HSLColor.fromColor(bgColor).lightness - 0.06).clamp(0, 1))
        .toColor();
    final iconColor = HSLColor.fromColor(bgColor)
        .withLightness(0.25)
        .toColor();

    return GestureDetector(
      onTap: () => Navigator.pushNamed(context, '/service/${service.serviceId}'),
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: bgColor,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Icon circle
            Container(
              width: 48, height: 48,
              decoration: BoxDecoration(color: iconBg, shape: BoxShape.circle),
              child: Icon(
                _iconMap[service.icon] ?? Icons.pets,
                color: iconColor, size: 24,
              ),
            ),
            const Spacer(),
            Text(service.name,
                style: const TextStyle(
                    fontSize: 15, fontWeight: FontWeight.bold)),
            const SizedBox(height: 4),
            Text('From \$${service.priceFrom.toStringAsFixed(0)}',
                style: TextStyle(
                    color: const Color(0xFF2C4A3E).withOpacity(0.7),
                    fontSize: 13)),
          ],
        ),
      ),
    );
  }
}
```

---

## 9. JWT Decode Helper (`lib/core/utils/jwt_utils.dart`)

```dart
import 'dart:convert';

Map<String, dynamic> decodeJwtPayload(String token) {
  final parts = token.split('.');
  if (parts.length != 3) throw const FormatException('Invalid JWT');
  final payload = parts[1];
  // Pad base64
  final normalized = base64Url.normalize(payload);
  return jsonDecode(utf8.decode(base64Url.decode(normalized)))
      as Map<String, dynamic>;
}
```

---

## 10. Routes (`lib/core/router/app_router.dart`)

```dart
import 'package:flutter/material.dart';
import '../../features/auth/pages/login_page.dart';
import '../../features/auth/pages/register_page.dart';
import '../../features/home/pages/home_page.dart';

Map<String, WidgetBuilder> get appRoutes => {
  '/login':    (_) => const LoginPage(),
  '/register': (_) => const RegisterPage(),
  '/home':     (_) => const HomePage(),
};

// In MaterialApp:
// initialRoute: '/login',   (or '/home' if token exists)
// routes: appRoutes,
```

---

## 11. API Reference (user-actor only)

| Method | Endpoint | Auth | Description |
|--------|----------|------|-------------|
| POST | `/auth/register` | — | `{ full_name, email, password }` → `{ token, user }` |
| POST | `/auth/login` | — | `{ email, password }` → `{ token, user }` |
| GET | `/auth/google` | — | Redirect to Google consent (OAuth2 flow) |
| GET | `/auth/me` | Bearer | Current user info |
| GET | `/services` | — | All active services (home grid) |
| GET | `/services/:id` | — | Single service detail |
| GET | `/profile` | Bearer | User profile (auto-created on first call) |
| PATCH | `/profile` | Bearer | `{ full_name?, phone?, avatar_url?, bio? }` |
| POST | `/bookings` | Bearer | Create booking (+ FAB form) |
| GET | `/bookings` | Bearer | List bookings (`?status=pending\|confirmed\|...`) |
| GET | `/bookings/active` | Bearer | Active + confirmed (Stays tab) |
| GET | `/bookings/:id` | Bearer | Single booking detail |
| PATCH | `/bookings/:id` | Bearer | `{ notes?, status: 'cancelled' }` |

### Error response shape
```json
{ "error": "Human-readable message", "details": ["..."] }
```
HTTP status codes: `400` bad input · `401` unauthenticated · `403` forbidden · `404` not found · `409` conflict · `422` unprocessable · `500` server error

---

## 12. Commands quick reference

```bash
# Seed services into admin sheet (run once)
pnpm db:seed seeds/admin.ts --skip-existing

# Create 3 mock user accounts for testing
pnpm db:mock-users 3

# Start the API server
pnpm dev
```
