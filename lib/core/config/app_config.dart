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

  factory AppConfig.dev() => const AppConfig._(
        flavor: Flavor.dev,
        baseUrl: 'http://localhost:3000',
        appName: 'Paw (Dev)',
      );

  factory AppConfig.prod() => const AppConfig._(
        flavor: Flavor.prod,
        baseUrl: 'https://your-api.com',
        appName: 'Paw',
      );

  bool get isDev => flavor == Flavor.dev;
}
