import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:hugeicons/hugeicons.dart';
import '../theme/app_colors.dart';
import '../theme/app_spacing.dart';
import '../theme/app_typography.dart';
import 'app_button.dart';

/// Non-dismissible dialog shown when a request fails due to connectivity.
/// The only way out is the Retry button — there is no implicit "cancel".
class NoInternetDialog extends StatelessWidget {
  final VoidCallback onRetry;

  const NoInternetDialog({super.key, required this.onRetry});

  static Future<void> show({required VoidCallback onRetry}) {
    return Get.dialog<void>(
      NoInternetDialog(onRetry: onRetry),
      barrierDismissible: false,
    );
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      child: Dialog(
        backgroundColor: AppColors.creamWarm,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.lg),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 64,
                height: 64,
                decoration: const BoxDecoration(
                  color: AppColors.blushSoft,
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  HugeIcons.strokeRoundedWifiOff01,
                  color: AppColors.sageDeep,
                  size: 32,
                ),
              ),
              const SizedBox(height: AppSpacing.md),
              Text(
                'No Internet Connection',
                style: AppTypography.sectionHeader,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: AppSpacing.sm),
              Text(
                'Please check your internet connection and try again.',
                style:
                    AppTypography.bodyMedium.copyWith(color: AppColors.sageMid),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: AppSpacing.lg),
              AppButton(
                label: 'Retry',
                icon: HugeIcons.strokeRoundedCircleArrowReload02,
                onPressed: () {
                  Get.back();
                  onRetry();
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
