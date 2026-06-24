import 'package:flutter_dotenv/flutter_dotenv.dart';
import '../../flavors.dart';

class AppConfig {
  final Flavor flavor;
  final String baseUrl;
  final String appName;

  const AppConfig._({
    required this.flavor,
    required this.baseUrl,
    required this.appName,
  });

  static AppConfig? _instance;
  static AppConfig get instance => _instance!;
  static void setup(AppConfig config) => _instance = config;

  factory AppConfig.dev() => AppConfig._(
        flavor: Flavor.dev,
        baseUrl: dotenv.env['BASE_URL'] ?? 'http://10.0.2.2:3000',
        appName: 'Paw (Dev)',
      );

  factory AppConfig.prod() => AppConfig._(
        flavor: Flavor.prod,
        baseUrl: dotenv.env['BASE_URL'] ?? 'https://your-api.com',
        appName: 'Paw',
      );

  bool get isDev => flavor == Flavor.dev;
}
