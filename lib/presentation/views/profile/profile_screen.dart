import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:hugeicons/hugeicons.dart';
import '../../controllers/auth_controller.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_spacing.dart';
import '../../theme/app_typography.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final auth = Get.find<AuthController>();

    return Scaffold(
      body: SafeArea(
        child: Obx(() {
          final user = auth.currentUser.value;
          if (user == null) return const SizedBox.shrink();

          return SingleChildScrollView(
            padding: const EdgeInsets.all(AppSpacing.md),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _ProfileHeader(
                  name: user.fullName,
                  email: user.email,
                  role: user.role,
                  picture: user.picture,
                ),
                const SizedBox(height: AppSpacing.lg),
                Text(
                  'Account',
                  style: AppTypography.sectionHeader.copyWith(fontSize: 18),
                ),
                const SizedBox(height: AppSpacing.sm),
                _SettingsGroup(items: [
                  _SettingsItem(
                    icon: HugeIcons.strokeRoundedUserCircle02,
                    label: 'Edit Profile',
                    onTap: () => _comingSoon('Edit Profile'),
                  ),
                  _SettingsItem(
                    icon: HugeIcons.strokeRoundedNotification03,
                    label: 'Notifications',
                    onTap: () => _comingSoon('Notifications'),
                  ),
                  _SettingsItem(
                    icon: HugeIcons.strokeRoundedCreditCard,
                    label: 'Payment Methods',
                    onTap: () => _comingSoon('Payment Methods'),
                  ),
                  _SettingsItem(
                    icon: HugeIcons.strokeRoundedLanguageSquare,
                    label: 'Language',
                    onTap: () => _comingSoon('Language'),
                  ),
                ]),
                const SizedBox(height: AppSpacing.lg),
                Text(
                  'Support',
                  style: AppTypography.sectionHeader.copyWith(fontSize: 18),
                ),
                const SizedBox(height: AppSpacing.sm),
                _SettingsGroup(items: [
                  _SettingsItem(
                    icon: HugeIcons.strokeRoundedHelpCircle,
                    label: 'Help & Support',
                    onTap: () => _comingSoon('Help & Support'),
                  ),
                  _SettingsItem(
                    icon: HugeIcons.strokeRoundedShield01,
                    label: 'Privacy & Security',
                    onTap: () => _comingSoon('Privacy & Security'),
                  ),
                  _SettingsItem(
                    icon: HugeIcons.strokeRoundedInformationCircle,
                    label: 'About Paw',
                    onTap: () => _comingSoon('About Paw'),
                  ),
                ]),
                const SizedBox(height: AppSpacing.lg),
                const _LogoutButton(),
                const SizedBox(height: AppSpacing.md),
              ],
            ),
          );
        }),
      ),
    );
  }

  void _comingSoon(String feature) {
    Get.snackbar(
      feature,
      'Coming soon',
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: AppColors.blushSoft,
      colorText: AppColors.ink,
      margin: const EdgeInsets.all(AppSpacing.md),
      borderRadius: 12,
    );
  }
}

class _ProfileHeader extends StatelessWidget {
  final String name;
  final String email;
  final String role;
  final String? picture;

  const _ProfileHeader({
    required this.name,
    required this.email,
    required this.role,
    required this.picture,
  });

  @override
  Widget build(BuildContext context) {
    final initials = name.trim().isNotEmpty ? name.trim()[0].toUpperCase() : '?';

    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: AppColors.sageDeep,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 32,
            backgroundColor: AppColors.blushSoft,
            backgroundImage: picture != null ? NetworkImage(picture!) : null,
            child: picture == null
                ? Text(
                    initials,
                    style: AppTypography.sectionHeader.copyWith(
                      color: AppColors.sageDeep,
                    ),
                  )
                : null,
          ),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name,
                  style: AppTypography.sectionHeader.copyWith(
                    color: AppColors.creamWarm,
                    fontSize: 18,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 2),
                Text(
                  email,
                  style: AppTypography.bodyMedium.copyWith(color: AppColors.mist),
                  overflow: TextOverflow.ellipsis,
                ),
                if (role.isNotEmpty) ...[
                  const SizedBox(height: AppSpacing.sm),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppSpacing.sm,
                      vertical: 2,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.amberAccent.withValues(alpha: 0.2),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      role[0].toUpperCase() + role.substring(1),
                      style: AppTypography.micro.copyWith(
                        color: AppColors.amberAccent,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _SettingsItem {
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  const _SettingsItem({
    required this.icon,
    required this.label,
    required this.onTap,
  });
}

class _SettingsGroup extends StatelessWidget {
  final List<_SettingsItem> items;

  const _SettingsGroup({required this.items});

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(16),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          border: Border.all(color: AppColors.mist.withValues(alpha: 0.4)),
        ),
        child: Column(
          children: [
            for (var i = 0; i < items.length; i++) ...[
              _SettingsRow(item: items[i]),
              if (i != items.length - 1)
                Divider(
                  height: 1,
                  thickness: 1,
                  color: AppColors.mist.withValues(alpha: 0.3),
                  indent: 56,
                  endIndent: AppSpacing.md,
                ),
            ],
          ],
        ),
      ),
    );
  }
}

class _SettingsRow extends StatelessWidget {
  final _SettingsItem item;

  const _SettingsRow({required this.item});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: item.onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.md,
          vertical: AppSpacing.sm + 4,
        ),
        child: Row(
          children: [
            Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: AppColors.sageMid.withValues(alpha: 0.15),
                shape: BoxShape.circle,
              ),
              child: Center(
                child: HugeIcon(icon: item.icon, color: AppColors.sageDeep, size: 18),
              ),
            ),
            const SizedBox(width: AppSpacing.md),
            Expanded(child: Text(item.label, style: AppTypography.bodyMedium)),
            const Icon(Icons.chevron_right, color: AppColors.mist),
          ],
        ),
      ),
    );
  }
}

class _LogoutButton extends StatefulWidget {
  const _LogoutButton();

  @override
  State<_LogoutButton> createState() => _LogoutButtonState();
}

class _LogoutButtonState extends State<_LogoutButton> {
  bool _loading = false;

  Future<void> _confirmAndLogout() async {
    final errorColor = Theme.of(context).colorScheme.error;

    final confirmed = await Get.dialog<bool>(
      AlertDialog(
        backgroundColor: AppColors.creamWarm,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text(
          'Log out?',
          style: AppTypography.sectionHeader.copyWith(fontSize: 18),
        ),
        content: Text(
          'You will need to sign in again to access your account.',
          style: AppTypography.bodyMedium,
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(result: false),
            child: Text(
              'Cancel',
              style: AppTypography.bodyMedium.copyWith(color: AppColors.sageMid),
            ),
          ),
          TextButton(
            onPressed: () => Get.back(result: true),
            child: Text(
              'Log Out',
              style: AppTypography.bodyMedium.copyWith(
                color: errorColor,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );

    if (confirmed != true) return;

    setState(() => _loading = true);
    try {
      await Get.find<AuthController>().logout();
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final errorColor = Theme.of(context).colorScheme.error;

    return SizedBox(
      width: double.infinity,
      child: OutlinedButton.icon(
        onPressed: _loading ? null : _confirmAndLogout,
        icon: _loading
            ? SizedBox(
                width: 16,
                height: 16,
                child: CircularProgressIndicator(strokeWidth: 2, color: errorColor),
              )
            : Icon(Icons.logout, size: 18, color: errorColor),
        label: Text(
          'Log Out',
          style: AppTypography.bodyMedium.copyWith(
            color: errorColor,
            fontWeight: FontWeight.w600,
          ),
        ),
        style: OutlinedButton.styleFrom(
          side: BorderSide(color: errorColor),
          padding: const EdgeInsets.symmetric(vertical: AppSpacing.md),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        ),
      ),
    );
  }
}
