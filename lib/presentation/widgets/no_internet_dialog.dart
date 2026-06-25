import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:hugeicons/hugeicons.dart';
import '../theme/app_colors.dart';
import '../theme/app_spacing.dart';
import '../theme/app_typography.dart';
import 'app_button.dart';

/// What's blocking the request — drives the dialog's icon and copy.
enum ConnectionIssue {
  /// Device has no route to the server at all.
  offline,

  /// Server reached but didn't respond in time — likely a cold start
  /// (e.g. a Render free-tier instance spinning back up after idling).
  serverWaking,
}

/// Non-dismissible dialog shown when a request fails due to connectivity
/// or because the backend is still waking up. The only way out is the
/// Retry button — there is no implicit "cancel".
class NoInternetDialog extends StatelessWidget {
  final VoidCallback onRetry;
  final ConnectionIssue issue;

  const NoInternetDialog({
    super.key,
    required this.onRetry,
    this.issue = ConnectionIssue.offline,
  });

  static Future<void> show({
    required VoidCallback onRetry,
    ConnectionIssue issue = ConnectionIssue.offline,
  }) {
    return Get.dialog<void>(
      NoInternetDialog(onRetry: onRetry, issue: issue),
      barrierDismissible: false,
    );
  }

  @override
  Widget build(BuildContext context) {
    final (icon, title, message) = switch (issue) {
      ConnectionIssue.offline => (
          HugeIcons.strokeRoundedWifiOff01,
          'No Internet Connection',
          'Please check your internet connection and try again.',
        ),
      ConnectionIssue.serverWaking => (
          HugeIcons.strokeRoundedSleeping,
          'Server Is Waking Up',
          'Our server is starting back up after sitting idle — this can take up to a minute. Tap retry to check again.',
        ),
    };

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
                child: Icon(icon, color: AppColors.sageDeep, size: 32),
              ),
              const SizedBox(height: AppSpacing.md),
              Text(
                title,
                style: AppTypography.sectionHeader,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: AppSpacing.sm),
              Text(
                message,
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
