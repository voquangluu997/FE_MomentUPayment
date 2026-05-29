import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:moment_u_payment/core/constants/app_colors.dart';
import 'package:moment_u_payment/core/providers/locale_provider.dart';
import 'package:moment_u_payment/features/notification/presentation/screens/notification_settings_screen.dart';
import 'package:moment_u_payment/l10n/app_localizations.dart';
import 'package:moment_u_payment/features/auth/presentation/auth_provider.dart';
import 'package:moment_u_payment/core/providers/currency_provider.dart';

class SettingsBottomSheet extends ConsumerWidget {
  const SettingsBottomSheet({super.key});

  static void show(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => const SettingsBottomSheet(),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final currentLocale = ref.watch(localeProvider);
    final currentCurrency = ref.watch(currencyProvider);

    return Container(
      decoration: const BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      padding: const EdgeInsets.only(top: 12, bottom: 24, left: 24, right: 24),
      constraints: BoxConstraints(
        maxHeight: MediaQuery.of(context).size.height * 0.8,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: Colors.grey.withOpacity(0.3),
              borderRadius: BorderRadius.circular(10),
            ),
          ),
          const SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                l10n.settingsAndUtilities, // "Cài đặt & Tiện ích"
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: AppColors.primaryDark,
                ),
              ),
              IconButton(
                onPressed: () => Navigator.of(context).pop(),
                icon: const Icon(Icons.close_rounded),
                color: AppColors.primaryDark,
              ),
            ],
          ),
          const SizedBox(height: 12),
          Flexible(
            child: SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              child: Column(
                children: [
                  _buildSettingItem(
                    icon: Icons.language_rounded,
                    title: l10n.language, // "Ngôn ngữ (Language)"
                    subtitle: currentLocale.languageCode == 'en'
                        ? l10n
                              .english // "English"
                        : l10n.vietnamese, // "Tiếng Việt"
                    trailing: Switch(
                      value: currentLocale.languageCode == 'en',
                      activeColor: AppColors.primary,
                      onChanged: (_) =>
                          ref.read(localeProvider.notifier).toggleLocale(),
                    ),
                  ),

                  _buildSettingItem(
                    icon: Icons.monetization_on_rounded,
                    title: l10n.currencyUnit, // "Đơn vị tiền tệ"
                    subtitle:
                        '${l10n.currentlyUsing}: $currentCurrency', // "Đang dùng: $currentCurrency"
                    trailing: PopupMenuButton<String>(
                      initialValue: currentCurrency,
                      position: PopupMenuPosition.under,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                      color: AppColors.cardBackground,
                      elevation: 3,
                      onSelected: (newValue) {
                        ref
                            .read(currencyProvider.notifier)
                            .setCurrency(newValue);
                      },
                      itemBuilder: (BuildContext context) {
                        return ['₫', '\$', '€', '¥'].map((String value) {
                          final isSelected = value == currentCurrency;
                          return PopupMenuItem<String>(
                            value: value,
                            height: 40,
                            child: Center(
                              child: Text(
                                value,
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: isSelected
                                      ? FontWeight.bold
                                      : FontWeight.normal,
                                  color: isSelected
                                      ? AppColors.primary
                                      : AppColors.primaryDark,
                                ),
                              ),
                            ),
                          );
                        }).toList();
                      },
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.primary.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              currentCurrency,
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                color: AppColors.primary,
                                fontSize: 14,
                              ),
                            ),
                            const SizedBox(width: 4),
                            const Icon(
                              Icons.keyboard_arrow_down_rounded,
                              color: AppColors.primary,
                              size: 18,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),

                  _buildSettingItem(
                    icon: Icons.dark_mode_rounded,
                    title: l10n.darkMode, // "Chế độ tối (Dark Mode)"
                    subtitle: l10n.lightTheme, // "Giao diện sáng"
                    trailing: Switch(value: false, onChanged: (val) {}),
                  ),

                  _buildSettingItem(
                    icon: Icons.notifications_active_rounded,
                    title: l10n.notificationSettingsTitle,
                    subtitle: l10n
                        .notificationSettingsSubtitle, // "Quản lý cảnh báo & chi tiêu"
                    onTap: () {
                      Navigator.of(context).pop();
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (_) => const NotificationSettingsScreen(),
                        ),
                      );
                    },
                  ),

                  _buildSettingItem(
                    icon: Icons.lock_reset_rounded,
                    title: l10n.changePassword, // "Đổi mật khẩu"
                    subtitle: l10n
                        .changePasswordSubtitle, // "Thay đổi mật khẩu tài khoản hiện tại"
                    onTap: () {
                      Navigator.of(context).pop();
                      _showUpdatePasswordDialog(context);
                    },
                  ),

                  _buildSettingItem(
                    icon: Icons.help_outline_rounded,
                    title: l10n.helpCenter, // "Trung tâm trợ giúp"
                    subtitle:
                        l10n.helpCenterSubtitle, // "Hỏi đáp & Liên hệ hỗ trợ"
                    onTap: () {},
                  ),

                  const Padding(
                    padding: EdgeInsets.symmetric(vertical: 8.0),
                    child: Divider(thickness: 0.5),
                  ),

                  ListTile(
                    contentPadding: EdgeInsets.zero,
                    leading: Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: Colors.red.shade50,
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.logout_rounded,
                        color: Colors.redAccent,
                        size: 22,
                      ),
                    ),
                    title: Text(
                      l10n.logout, // "Đăng xuất"
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Colors.redAccent,
                        fontSize: 15,
                      ),
                    ),
                    subtitle: Text(
                      l10n.logoutSubtitle, // "Rời khỏi phiên đăng nhập hiện tại"
                      style: const TextStyle(fontSize: 12),
                    ),
                    onTap: () async {
                      Navigator.of(context).pop();
                      ScaffoldMessenger.of(context).hideCurrentSnackBar();

                      await ref.read(authProvider.notifier).logout();

                      if (!context.mounted) return;
                      Navigator.of(
                        context,
                      ).pushNamedAndRemoveUntil('/login', (route) => false);
                    },
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSettingItem({
    required IconData icon,
    required String title,
    required String subtitle,
    Widget? trailing,
    VoidCallback? onTap,
  }) {
    return ListTile(
      contentPadding: EdgeInsets.zero,
      leading: Container(
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: AppColors.primary.withOpacity(0.1),
          shape: BoxShape.circle,
        ),
        child: Icon(icon, color: AppColors.primary, size: 22),
      ),
      title: Text(
        title,
        style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 15),
      ),
      subtitle: Text(
        subtitle,
        style: TextStyle(color: Colors.grey.shade600, fontSize: 13),
      ),
      trailing:
          trailing ?? const Icon(Icons.arrow_forward_ios_rounded, size: 16),
      onTap: onTap,
    );
  }

  void _showUpdatePasswordDialog(BuildContext context) {
    final oldPasswordController = TextEditingController();
    final newPasswordController = TextEditingController();

    showDialog(
      context: context,
      builder: (dialogContext) => Consumer(
        builder: (context, ref, child) {
          // Lấy l10n bên trong context của Dialog
          final l10n = AppLocalizations.of(context)!;

          return AlertDialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
            ),
            title: Text(
              l10n.newPasswordTitle, // "Đổi mật khẩu mới"
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: oldPasswordController,
                  obscureText: true,
                  decoration: InputDecoration(
                    labelText: l10n.currentPassword, // "Mật khẩu hiện tại"
                  ),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: newPasswordController,
                  obscureText: true,
                  decoration: InputDecoration(
                    labelText: l10n.newPassword,
                  ), // "Mật khẩu mới"
                ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: Text(
                  l10n.cancel,
                  style: const TextStyle(color: Colors.grey),
                ), // "Hủy"
              ),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                onPressed: () async {
                  final oldPw = oldPasswordController.text.trim();
                  final newPw = newPasswordController.text.trim();

                  if (oldPw.isNotEmpty && newPw.isNotEmpty) {
                    final authNotifier = ref.read(authProvider.notifier);
                    final scaffoldMessenger = ScaffoldMessenger.of(context);
                    Navigator.pop(context);

                    final isSuccess = await authNotifier.updatePassword(
                      oldPw,
                      newPw,
                    );
                    if (isSuccess) {
                      scaffoldMessenger.showSnackBar(
                        SnackBar(
                          content: Text(
                            l10n.updatePasswordSuccess,
                          ), // "Cập nhật mật khẩu thành công!"
                          backgroundColor: AppColors.success,
                        ),
                      );
                    } else {
                      scaffoldMessenger.showSnackBar(
                        SnackBar(
                          content: Text(
                            l10n.updatePasswordError,
                          ), // "Mật khẩu hiện tại không đúng hoặc lỗi kết nối."
                          backgroundColor: AppColors.error,
                        ),
                      );
                    }
                  }
                },
                child: Text(
                  l10n.update, // "Cập nhật"
                  style: const TextStyle(color: Colors.white),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
