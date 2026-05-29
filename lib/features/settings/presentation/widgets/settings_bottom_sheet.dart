import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:moment_u_payment/core/constants/app_colors.dart'; // Đảm bảo đường dẫn này chứa appColorsProvider và AppColorTheme
import 'package:moment_u_payment/core/providers/locale_provider.dart';
import 'package:moment_u_payment/core/providers/theme_provider.dart';
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
    // ✨ Lắng nghe bộ màu dynamic từ provider thay vì dùng AppColors tĩnh
    final appColors = ref.watch(appColorsProvider);
    final l10n = AppLocalizations.of(context)!;
    final currentLocale = ref.watch(localeProvider);
    final currentCurrency = ref.watch(currencyProvider);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      decoration: BoxDecoration(
        color: appColors.background,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
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
              color: appColors.textMuted.withOpacity(0.3),
              borderRadius: BorderRadius.circular(10),
            ),
          ),
          const SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                l10n.settingsAndUtilities,
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: appColors.primaryDark,
                ),
              ),
              IconButton(
                onPressed: () => Navigator.of(context).pop(),
                icon: const Icon(Icons.close_rounded),
                color: appColors.primaryDark,
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
                    title: l10n.language,
                    subtitle: currentLocale.languageCode == 'en'
                        ? l10n.english
                        : l10n.vietnamese,
                    appColors: appColors,
                    trailing: Switch(
                      value: currentLocale.languageCode == 'en',
                      activeColor: appColors.primary,
                      onChanged: (_) =>
                          ref.read(localeProvider.notifier).toggleLocale(),
                    ),
                  ),

                  _buildSettingItem(
                    icon: Icons.monetization_on_rounded,
                    title: l10n.currencyUnit,
                    subtitle: '${l10n.currentlyUsing}: $currentCurrency',
                    appColors: appColors,
                    trailing: PopupMenuButton<String>(
                      initialValue: currentCurrency,
                      position: PopupMenuPosition.under,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                      color: appColors.cardBackground,
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
                                      ? appColors.primary
                                      : appColors.primaryDark,
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
                          color: appColors.primary.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              currentCurrency,
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: appColors.primary,
                                fontSize: 14,
                              ),
                            ),
                            const SizedBox(width: 4),
                            Icon(
                              Icons.keyboard_arrow_down_rounded,
                              color: appColors.primary,
                              size: 18,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),

                  _buildSettingItem(
                    icon: Icons.dark_mode_rounded,
                    title: l10n.darkMode,
                    subtitle: isDark ? "Giao diện tối" : l10n.lightTheme,
                    appColors: appColors,
                    trailing: Switch(
                      value: isDark,
                      activeColor: appColors.primary,
                      onChanged: (val) {
                        // 🔥 Gọi hàm toggle ở đây
                        ref.read(themeModeProvider.notifier).toggleTheme();
                      },
                    ),
                    onTap: () {
                      // ✨ Bấm vào nguyên cả hàng cũng sẽ tự đổi luôn
                      ref.read(themeModeProvider.notifier).toggleTheme();
                    },
                  ),

                  _buildSettingItem(
                    icon: Icons.notifications_active_rounded,
                    title: l10n.notificationSettingsTitle,
                    subtitle: l10n.notificationSettingsSubtitle,
                    appColors: appColors,
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
                    title: l10n.changePassword,
                    subtitle: l10n.changePasswordSubtitle,
                    appColors: appColors,
                    onTap: () {
                      Navigator.of(context).pop();
                      _showUpdatePasswordDialog(context);
                    },
                  ),

                  _buildSettingItem(
                    icon: Icons.help_outline_rounded,
                    title: l10n.helpCenter,
                    subtitle: l10n.helpCenterSubtitle,
                    appColors: appColors,
                    onTap: () {},
                  ),

                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8.0),
                    child: Divider(
                      thickness: 0.5,
                      color: appColors.textMuted.withOpacity(0.2),
                    ),
                  ),

                  ListTile(
                    contentPadding: EdgeInsets.zero,
                    leading: Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: Colors.redAccent.withOpacity(
                          0.12,
                        ), // Đổi từ sắc trắng hồng cố định sang mờ dynamic
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.logout_rounded,
                        color: Colors.redAccent,
                        size: 22,
                      ),
                    ),
                    title: Text(
                      l10n.logout,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Colors.redAccent,
                        fontSize: 15,
                      ),
                    ),
                    subtitle: Text(
                      l10n.logoutSubtitle,
                      style: TextStyle(
                        fontSize: 12,
                        color: appColors.textMuted,
                      ),
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

  // ✨ Đã thêm tham số `AppColorTheme appColors` để đồng bộ màu sắc các dòng cài đặt
  Widget _buildSettingItem({
    required IconData icon,
    required String title,
    required String subtitle,
    required AppColorTheme appColors,
    Widget? trailing,
    VoidCallback? onTap,
  }) {
    return ListTile(
      contentPadding: EdgeInsets.zero,
      leading: Container(
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: appColors.primary.withOpacity(0.1),
          shape: BoxShape.circle,
        ),
        child: Icon(icon, color: appColors.primary, size: 22),
      ),
      title: Text(
        title,
        style: TextStyle(
          fontWeight: FontWeight.w600,
          fontSize: 15,
          color: appColors.primaryDark,
        ),
      ),
      subtitle: Text(
        subtitle,
        style: TextStyle(color: appColors.textMuted, fontSize: 13),
      ),
      trailing:
          trailing ??
          Icon(
            Icons.arrow_forward_ios_rounded,
            size: 16,
            color: appColors.textMuted,
          ),
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
          final l10n = AppLocalizations.of(context)!;
          // ✨ Lấy bộ màu dynamic cho Dialog chống mù chữ khi ở Dark mode
          final dialogColors = ref.watch(appColorsProvider);

          return AlertDialog(
            backgroundColor: dialogColors.background,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
            ),
            title: Text(
              l10n.newPasswordTitle,
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: dialogColors.primaryDark,
              ),
            ),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: oldPasswordController,
                  obscureText: true,
                  style: TextStyle(color: dialogColors.text),
                  decoration: InputDecoration(
                    labelText: l10n.currentPassword,
                    labelStyle: TextStyle(color: dialogColors.textMuted),
                  ),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: newPasswordController,
                  obscureText: true,
                  style: TextStyle(color: dialogColors.text),
                  decoration: InputDecoration(
                    labelText: l10n.newPassword,
                    labelStyle: TextStyle(color: dialogColors.textMuted),
                  ),
                ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: Text(
                  l10n.cancel,
                  style: TextStyle(color: dialogColors.textMuted),
                ),
              ),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: dialogColors.primary,
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
                          content: Text(l10n.updatePasswordSuccess),
                          backgroundColor: dialogColors.success,
                        ),
                      );
                    } else {
                      scaffoldMessenger.showSnackBar(
                        SnackBar(
                          content: Text(l10n.updatePasswordError),
                          backgroundColor: dialogColors.error,
                        ),
                      );
                    }
                  }
                },
                child: Text(
                  l10n.update,
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
