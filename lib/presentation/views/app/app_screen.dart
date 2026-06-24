import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:pet_carrying_app/presentation/theme/app_colors.dart';
import 'package:pet_carrying_app/presentation/theme/app_typography.dart';
import '../../controllers/navigation_controller.dart';
import '../home/home_screen.dart';
import '../stays/stays_screen.dart';
import '../history/history_screen.dart';
import '../profile/profile_screen.dart';

class AppScreen extends StatelessWidget {
  const AppScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final nav = Get.find<NavigationController>();

    final screens = [
      const HomeScreen(),
      const StaysScreen(),
      const HistoryScreen(),
      const ProfileScreen(),
    ];

    return Obx(() => Scaffold(
      body: IndexedStack(
        index: nav.currentIndex.value,
        children: screens,
      ),

      // 1. The amber + button
      floatingActionButton: FloatingActionButton(
        onPressed: () {},
        shape: const CircleBorder(),
        child: const Icon(Icons.add),
      ),

      // 2. Docks the FAB to the center of the bottom bar
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,


      // 3. The nav bar with notch cut out for the FAB
      bottomNavigationBar: BottomAppBar(
        shape: const CircularNotchedRectangle(),
        notchMargin: 8,
        color: Colors.white,
        elevation: 8,
        height: 60,
        padding: EdgeInsets.zero,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            _NavItem(icon: Icons.home_outlined, label: 'Home', index: 0, nav: nav),
            _NavItem(icon: Icons.pets_outlined, label: 'Stays', index: 1, nav: nav),
            const SizedBox(width: 48),
            _NavItem(icon: Icons.history, label: 'History', index: 2, nav: nav),
            _NavItem(icon: Icons.person_outline, label: 'Profile', index: 3, nav: nav),
            
          ],
        ),
      ),
    ));
  }
}

class _NavItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final int index;
  final NavigationController nav;

  const _NavItem({
    required this.icon,
    required this.label,
    required this.index,
    required this.nav,
  });

  @override
  Widget build(BuildContext context) {
    final isActive = nav.currentIndex.value == index;

    return GestureDetector(
      onTap: () => nav.changePage(index),
      child: Padding(
        padding: const EdgeInsets.only(top: 8),
        child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            color: isActive ? AppColors.sageDeep : AppColors.mist,
          ),
          Text(
            label,
            style: AppTypography.micro.copyWith(
              color: isActive ? AppColors.sageDeep : AppColors.mist,
            ),
          ),
        ],
      ),
        ),
    );
  }
}