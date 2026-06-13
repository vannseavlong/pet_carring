import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'di/app_binding.dart';
import 'presentation/theme/app_theme.dart';
import 'presentation/views/app/app_screen.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      title: 'Pet Boarding Manager',
      theme: AppTheme.light,
      initialBinding: AppBinding(),
      home: const AppScreen(),
      debugShowCheckedModeBanner: false,
    );
  }
}
