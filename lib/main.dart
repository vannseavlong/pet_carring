import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'core/config/app_config.dart';
import 'di/app_binding.dart';
import 'presentation/theme/app_theme.dart';
import 'presentation/views/auth/auth_wrapper.dart';

void main() {
  bootstrap();
}

void bootstrap() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      title: AppConfig.instance.appName,
      theme: AppTheme.light,
      initialBinding: AppBinding(),
      home: const AuthWrapper(),
      debugShowCheckedModeBanner: AppConfig.instance.isDev,
    );
  }
}
