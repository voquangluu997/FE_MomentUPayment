import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:moment_u_payment/core/constants/app_colors.dart';
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
        maxHeight: MediaQuery.of(context).size.height * 0.85,
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
                        ref.read(themeModeProvider.notifier).toggleTheme();
                      },
                    ),
                    onTap: () {
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

                  // ✨ CẬP NHẬT TRUNG TÂM TRỢ GIÚP
                  _buildSettingItem(
                    icon: Icons.help_outline_rounded,
                    title: l10n.helpCenter,
                    subtitle: l10n.helpCenterSubtitle,
                    appColors: appColors,
                    onTap: () {
                      Navigator.of(context).pop();
                      _showHelpCenterDialog(context, appColors, l10n);
                    },
                  ),

                  const SizedBox(height: 16),

                  // ✨ BANNER DONATE
                  _buildDonationBanner(context, appColors, l10n),

                  const SizedBox(height: 8),

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
                        color: Colors.redAccent.withOpacity(0.12),
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

  Widget _buildDonationBanner(
    BuildContext context,
    AppColorTheme appColors,
    AppLocalizations l10n,
  ) {
    return InkWell(
      onTap: () => _showDonationDialog(context, appColors, l10n),
      borderRadius: BorderRadius.circular(20),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              appColors.primary.withOpacity(0.15),
              appColors.primary.withOpacity(0.05),
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: appColors.primary.withOpacity(0.2),
            width: 1,
          ),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: appColors.primary,
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: appColors.primary.withOpacity(0.3),
                    blurRadius: 8,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: const Icon(
                Icons.coffee_rounded,
                color: Colors.white,
                size: 24,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    l10n.buyDevCoffeeTitle,
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 15,
                      color: appColors.primaryDark,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    l10n.buyDevCoffeeSubtitle,
                    style: TextStyle(fontSize: 12, color: appColors.textMuted),
                  ),
                ],
              ),
            ),
            Icon(Icons.favorite_rounded, color: appColors.primary, size: 20),
          ],
        ),
      ),
    );
  }

  void _showDonationDialog(
    BuildContext context,
    AppColorTheme appColors,
    AppLocalizations l10n,
  ) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: appColors.background,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        contentPadding: const EdgeInsets.all(24),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: const Color(0xFFA50064).withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.qr_code_2_rounded,
                color: Color(0xFFA50064),
                size: 40,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              l10n.scanToSpreadLoveTitle,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: appColors.primaryDark,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              l10n.scanToSpreadLoveSubtitle,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 14,
                color: appColors.textMuted,
                height: 1.4,
              ),
            ),
            const SizedBox(height: 24),

            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: appColors.cardBackground,
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: Image.asset(
                  'assets/images/momo_qr.png',
                  width: 180,
                  height: 180,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) {
                    return Container(
                      width: 180,
                      height: 180,
                      color: appColors.primary.withOpacity(0.1),
                      alignment: Alignment.center,
                      child: Text(
                        l10n.missingQrMessage,
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: appColors.primary,
                          fontWeight: FontWeight.bold,
                          fontSize: 12,
                        ),
                      ),
                    );
                  },
                ),
              ),
            ),

            const SizedBox(height: 24),

            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: appColors.primary,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                minimumSize: const Size(double.infinity, 48),
                elevation: 0,
              ),
              onPressed: () => Navigator.of(context).pop(),
              child: Text(
                l10n.closeButton,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ✨ DIALOG TRUNG TÂM TRỢ GIÚP
  void _showHelpCenterDialog(
    BuildContext context,
    AppColorTheme appColors,
    AppLocalizations l10n,
  ) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: appColors.background,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        contentPadding: const EdgeInsets.all(24),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: appColors.primary.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.support_agent_rounded,
                color: appColors.primary,
                size: 40,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              l10n.helpCenterDialogTitle,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: appColors.primaryDark,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              l10n.helpCenterDialogMessage,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 14,
                color: appColors.textMuted,
                height: 1.4,
              ),
            ),
            const SizedBox(height: 24),

            // Box chứa Email hỗ trợ có thể copy
            InkWell(
              onTap: () async {
                await Clipboard.setData(ClipboardData(text: l10n.contactEmail));
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Đã sao chép email: ${l10n.contactEmail}'),
                      backgroundColor: appColors.primary,
                      duration: const Duration(seconds: 2),
                    ),
                  );
                }
              },
              borderRadius: BorderRadius.circular(16),
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 12,
                ),
                decoration: BoxDecoration(
                  color: appColors.cardBackground,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: appColors.primary.withOpacity(0.2)),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.email_outlined,
                      color: appColors.primary,
                      size: 20,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        l10n.contactEmail,
                        style: TextStyle(
                          color: appColors.primaryDark,
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                        ),
                      ),
                    ),
                    Icon(
                      Icons.copy_rounded,
                      color: appColors.textMuted,
                      size: 18,
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 16),

            // Phiên bản app
            Text(
              '${l10n.appVersionTitle}: ${l10n.appVersion}',
              style: TextStyle(
                fontSize: 12,
                color: appColors.textMuted,
                fontWeight: FontWeight.w500,
              ),
            ),

            const SizedBox(height: 24),

            // Nút đóng
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: appColors.primary,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                minimumSize: const Size(double.infinity, 48),
                elevation: 0,
              ),
              onPressed: () => Navigator.of(context).pop(),
              child: Text(
                l10n.closeButton,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

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
