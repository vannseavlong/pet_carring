import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../controllers/auth_controller.dart';
import '../../theme/app_colors.dart';
import '../app/app_screen.dart';
import 'login_screen.dart';

class AuthWrapper extends StatelessWidget {
  const AuthWrapper({super.key});

  @override
  Widget build(BuildContext context) {
    final auth = Get.find<AuthController>();
    return Obx(() {
      if (auth.isChecking.value) {
        return const Scaffold(
          backgroundColor: AppColors.creamWarm,
          body: Center(
            child: CircularProgressIndicator(color: AppColors.sageMid),
          ),
        );
      }
      if (auth.isLoggedIn.value) return const AppScreen();
      return const LoginScreen();
    });
  }
}
