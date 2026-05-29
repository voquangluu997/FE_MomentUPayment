import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:moment_u_payment/core/constants/app_colors.dart';
import 'package:moment_u_payment/features/notification/presentation/notification_settings_provider.dart';
import 'package:moment_u_payment/l10n/app_localizations.dart';

class NotificationSettingsScreen extends ConsumerWidget {
  const NotificationSettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final settingsState = ref.watch(notificationSettingsProvider);
    final notifier = ref.read(notificationSettingsProvider.notifier);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back_ios_new_rounded,
            color: AppColors.primaryDark,
            size: 20,
          ),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Text(
          l10n.notificationSettingsTitle,
          style: const TextStyle(
            color: AppColors.primaryDark,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: settingsState.isLoading
          ? const Center(
              child: CircularProgressIndicator(color: AppColors.primary),
            )
          : ListView(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              physics: const BouncingScrollPhysics(),
              children: [
                _buildSettingCard(
                  title: l10n.notiCategoryBudget,
                  subtitle:
                      "Cảnh báo khi tiêu vượt mốc 80% hoặc quá 100% hạn mức ví.",
                  icon: Icons.pie_chart_rounded,
                  iconColor: Colors.orange,
                  value: settingsState.budgetAlerts,
                  onChanged: (val) => notifier.toggleSetting(budgetAlerts: val),
                ),
                _buildSettingCard(
                  title: l10n.notiCategorySharedWallet,
                  subtitle:
                      "Tự động gom và thông báo các hành động thêm/sửa/xóa định kỳ để tránh làm phiền.",
                  icon: Icons.layers_rounded,
                  iconColor: Colors.blue,
                  value: settingsState.sharedWalletUpdates,
                  onChanged: (val) =>
                      notifier.toggleSetting(sharedWalletUpdates: val),
                ),
                _buildSettingCard(
                  title: l10n.notiCategorySecurity,
                  subtitle:
                      "Nhận thông báo trạng thái xác thực email thành công hoặc đổi thiết bị.",
                  icon: Icons.verified_user_rounded,
                  iconColor: Colors.green,
                  value: settingsState.securitySystem,
                  onChanged: (val) =>
                      notifier.toggleSetting(securitySystem: val),
                ),
              ],
            ),
    );
  }

  // Widget Tái sử dụng để vẽ từng Ô Cài Đặt (Chuẩn Soft UI)
  Widget _buildSettingCard({
    required String title,
    required String subtitle,
    required IconData icon,
    required Color iconColor,
    required bool value,
    required Function(bool) onChanged,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      decoration: BoxDecoration(
        color: AppColors.cardBackground,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: AppColors.primaryDark.withOpacity(0.02),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(20),
        child: SwitchListTile(
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 8,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          // Icon bo tròn
          secondary: Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: iconColor.withOpacity(0.12),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: iconColor, size: 22),
          ),
          title: Text(
            title,
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              color: AppColors.primaryDark,
              fontSize: 15,
            ),
          ),
          subtitle: Padding(
            padding: const EdgeInsets.only(top: 4),
            child: Text(
              subtitle,
              style: TextStyle(
                color: AppColors.primaryDark.withOpacity(0.55),
                fontSize: 12,
                height: 1.4,
              ),
            ),
          ),
          value: value,
          activeColor: Colors.white,
          activeTrackColor: AppColors.primary,
          inactiveThumbColor: Colors.white,
          inactiveTrackColor: AppColors.primaryDark.withOpacity(0.15),
          onChanged: onChanged,
        ),
      ),
    );
  }
}
