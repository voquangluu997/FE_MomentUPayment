import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:moment_u_payment/core/utils/app_logger.dart';
import 'package:share_plus/share_plus.dart';
import 'package:moment_u_payment/core/constants/app_colors.dart';
import 'package:moment_u_payment/core/features/badges/screens/badge_gallery_page.dart';
import 'package:moment_u_payment/core/providers/currency_provider.dart';
import 'package:moment_u_payment/core/providers/locale_provider.dart';
import 'package:moment_u_payment/core/providers/theme_provider.dart';
import 'package:moment_u_payment/core/utils/app_toast.dart';
import 'package:moment_u_payment/features/auth/presentation/auth_provider.dart';
import 'package:moment_u_payment/features/notification/presentation/screens/notification_settings_screen.dart';
import 'package:moment_u_payment/features/profile/presentation/screens/profile_settings_screen.dart';
import 'package:moment_u_payment/l10n/app_localizations.dart';

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
    final themeMode = ref.watch(themeModeProvider);
    final appColors = ref.watch(appColorsProvider);
    final l10n = AppLocalizations.of(context)!;
    final currentLocale = ref.watch(localeProvider);
    final currentCurrency = ref.watch(currencyProvider);
    final isDark = themeMode == ThemeMode.dark;

    return Container(
      constraints: BoxConstraints(
        maxHeight: MediaQuery.of(context).size.height * 0.85,
      ),
      child: Material(
        color: appColors.background,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
        clipBehavior: Clip.antiAlias,
        child: Padding(
          padding: const EdgeInsets.only(
            top: 12,
            bottom: 24,
            left: 24,
            right: 24,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // THANH KÉO (HANDLE)
              Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: appColors.textMuted.withValues(alpha: 0.3),
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              const SizedBox(height: 20),

              // TIÊU ĐỀ & NÚT ĐÓNG
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
                    icon: const Icon(CupertinoIcons.xmark),
                    color: appColors.primaryDark,
                  ),
                ],
              ),
              const SizedBox(height: 12),

              // PHẦN NỘI DUNG CUỘN ĐƯỢC
              Flexible(
                child: SingleChildScrollView(
                  physics: const BouncingScrollPhysics(),
                  child: Column(
                    children: [
                      // ==========================================
                      // PHÂN NHÓM 1: CẤU HÌNH ỨNG DỤNG & HỆ THỐNG
                      // ==========================================
                      _buildSettingItem(
                        icon: CupertinoIcons.rosette,
                        title: l10n.badgesTitle,
                        subtitle: l10n.badgesSubtitle,
                        appColors: appColors,
                        onTap: () {
                          HapticFeedback.lightImpact();
                          Navigator.of(context).pop();
                          Navigator.of(context).push(
                            CupertinoPageRoute(
                              builder: (_) => const BadgeGalleryPage(),
                            ),
                          );
                        },
                      ),

                      _buildSettingItem(
                        icon: CupertinoIcons.moon,
                        title: l10n.darkMode,
                        subtitle: isDark ? l10n.darkTheme : l10n.lightTheme,
                        appColors: appColors,
                        trailing: Switch(
                          value: isDark,
                          activeThumbColor: appColors.primary,
                          onChanged: (val) {
                            HapticFeedback.lightImpact();
                            ref.read(themeModeProvider.notifier).toggleTheme();
                          },
                        ),
                        onTap: () {
                          HapticFeedback.lightImpact();
                          ref.read(themeModeProvider.notifier).toggleTheme();
                        },
                      ),

                      _buildSettingItem(
                        icon: CupertinoIcons.globe,
                        title: l10n.language,
                        subtitle: currentLocale.languageCode == 'en'
                            ? l10n.english
                            : l10n.vietnamese,
                        appColors: appColors,
                        trailing: Switch(
                          value: currentLocale.languageCode == 'en',
                          activeThumbColor: appColors.primary,
                          onChanged: (_) {
                            HapticFeedback.lightImpact();
                            ref.read(localeProvider.notifier).toggleLocale();
                          },
                        ),
                        onTap: () {
                          HapticFeedback.lightImpact();
                          ref.read(localeProvider.notifier).toggleLocale();
                        },
                      ),

                      _buildSettingItem(
                        icon: CupertinoIcons.money_dollar_circle,
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
                            HapticFeedback.lightImpact();
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
                              color: appColors.primary.withValues(alpha: 0.1),
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
                                  CupertinoIcons.chevron_down,
                                  color: appColors.primary,
                                  size: 14,
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),

                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 4.0),
                        child: Divider(
                          thickness: 0.5,
                          color: appColors.textMuted.withValues(alpha: 0.15),
                        ),
                      ),

                      // ==========================================
                      // PHÂN NHÓM 2: HỖ TRỢ & CHIA SẺ
                      // ==========================================
                      _buildSettingItem(
                        icon: CupertinoIcons.question_circle,
                        title: l10n.helpCenter,
                        subtitle: l10n.helpCenterSubtitle,
                        appColors: appColors,
                        onTap: () {
                          HapticFeedback.lightImpact();
                          Navigator.of(context).pop();
                          _showHelpCenterDialog(context, appColors, l10n);
                        },
                      ),

                      _buildSettingItem(
                        icon: CupertinoIcons.share,
                        title: l10n.shareNow,
                        subtitle: l10n.shareAppPromoMessageSubTitle,
                        appColors: appColors,
                        onTap: () {
                          HapticFeedback.lightImpact();
                          final String textToShare = l10n.shareAppPromoMessage(
                            "Moments U Payment",
                          );
                          // ignore: deprecated_member_use
                          Share.share(textToShare);
                        },
                      ),

                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 4.0),
                        child: Divider(
                          thickness: 0.5,
                          color: appColors.textMuted.withValues(alpha: 0.15),
                        ),
                      ),

                      // ==========================================
                      // PHÂN NHÓM 3: QUẢN LÝ CÁ NHÂN & THÔNG BÁO
                      // ==========================================
                      _buildSettingItem(
                        icon: CupertinoIcons.person,
                        title: l10n.accountSettings,
                        subtitle: l10n.accountSettingsSubtitle,
                        appColors: appColors,
                        onTap: () {
                          HapticFeedback.lightImpact();
                          Navigator.of(context).pop();
                          Navigator.of(context).push(
                            CupertinoPageRoute(
                              builder: (_) => const ProfileSettingsScreen(),
                            ),
                          );
                        },
                      ),
                      _buildSettingItem(
                        icon: CupertinoIcons.bell,
                        title: l10n.notificationSettingsTitle,
                        subtitle: l10n.notificationSettingsSubtitle,
                        appColors: appColors,
                        onTap: () {
                          HapticFeedback.lightImpact();
                          Navigator.of(context).pop();
                          Navigator.of(context).push(
                            CupertinoPageRoute(
                              builder: (_) =>
                                  const NotificationSettingsScreen(),
                            ),
                          );
                        },
                      ),

                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 4.0),
                        child: Divider(
                          thickness: 0.5,
                          color: appColors.textMuted.withValues(alpha: 0.2),
                        ),
                      ),

                      // ==========================================
                      // PHÂN NHÓM 4: THAO TÁC TÀI KHOẢN (LOGOUT & DELETE)
                      // ==========================================

                      // NÚT ĐĂNG XUẤT
                      ListTile(
                        contentPadding: EdgeInsets.zero,
                        leading: Container(
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: Colors.orange.withValues(alpha: 0.12),
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            CupertinoIcons.square_arrow_right,
                            color: Colors.orange,
                            size: 22,
                          ),
                        ),
                        title: Text(
                          l10n.logout,
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Colors.orange,
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
                          HapticFeedback.lightImpact();
                          Navigator.of(context).pop();
                          await ref.read(authProvider.notifier).logout();
                          if (!context.mounted) return;
                          Navigator.of(
                            context,
                          ).pushNamedAndRemoveUntil('/login', (route) => false);
                        },
                      ),

                      // NÚT XÓA TÀI KHOẢN
                      ListTile(
                        contentPadding: EdgeInsets.zero,
                        leading: Container(
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: Colors.red.withValues(alpha: 0.12),
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            CupertinoIcons.trash,
                            color: Colors.red,
                            size: 22,
                          ),
                        ),
                        title: Text(
                          l10n.deleteAccount,
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Colors.red,
                            fontSize: 15,
                          ),
                        ),
                        onTap: () {
                          HapticFeedback.heavyImpact(); // Rung mạnh cảnh báo
                          Navigator.of(context).pop(); // Đóng BottomSheet
                          _showDeleteAccountDialog(
                            context,
                            ref,
                            appColors,
                            l10n,
                          );
                        },
                      ),
                    ],
                  ),
                ),
              ),

              // ==========================================
              // PHẦN CỐ ĐỊNH Ở ĐÁY (KHÔNG CUỘN)
              // ==========================================
              Container(
                margin: const EdgeInsets.only(top: 12),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    _buildDonationBanner(context, appColors, l10n),
                    _buildPremiumBanner(context, appColors, l10n),
                  ],
                ),
              ),
            ],
          ),
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
          color: appColors.primary.withValues(alpha: 0.1),
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
            CupertinoIcons.chevron_forward,
            size: 16,
            color: appColors.textMuted,
          ),
      onTap: onTap,
    );
  }

  Widget _buildDonationBanner(
    BuildContext context,
    AppColorTheme appColors,
    AppLocalizations l10n,
  ) {
    return InkWell(
      onTap: () {
        HapticFeedback.lightImpact();
        _showDonationDialog(context, appColors, l10n);
      },
      borderRadius: BorderRadius.circular(20),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              appColors.primary.withValues(alpha: 0.15),
              appColors.primary.withValues(alpha: 0.05),
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: appColors.primary.withValues(alpha: 0.2),
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
                    color: appColors.primary.withValues(alpha: 0.3),
                    blurRadius: 8,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: const Icon(
                CupertinoIcons.heart,
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
            Icon(CupertinoIcons.heart_fill, color: appColors.primary, size: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildPremiumBanner(
    BuildContext context,
    AppColorTheme appColors,
    AppLocalizations l10n,
  ) {
    return Container(
      margin: const EdgeInsets.only(top: 12),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      decoration: BoxDecoration(
        color: const Color(0xFFFFB800).withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: const Color(0xFFFFB800).withValues(alpha: 0.3),
          width: 1,
        ),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: const Color(0xFFFFB800),
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFFFFB800).withValues(alpha: 0.3),
                  blurRadius: 8,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: const Icon(
              CupertinoIcons.star_fill,
              color: Colors.white,
              size: 24,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      l10n.premiumGroupMomentsTitle,
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 15,
                        color: appColors.primaryDark,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 6,
                        vertical: 2,
                      ),
                      decoration: BoxDecoration(
                        color: const Color(0xFFFFB800).withValues(alpha: 0.2),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Icon(
                        CupertinoIcons.lock_fill,
                        size: 12,
                        color: Color(0xFFD99B00),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  l10n.premiumGroupMomentsSubtitle,
                  style: TextStyle(
                    fontSize: 12,
                    color: appColors.primaryDark.withValues(alpha: 0.6),
                    height: 1.3,
                  ),
                ),
              ],
            ),
          ),
        ],
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
                color: const Color(0xFFA50064).withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                CupertinoIcons.qrcode,
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
                    color: Colors.black.withValues(alpha: 0.05),
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
                      color: appColors.primary.withValues(alpha: 0.1),
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
              onPressed: () {
                HapticFeedback.lightImpact();
                Navigator.of(context).pop();
              },
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
                color: appColors.primary.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                CupertinoIcons.chat_bubble_2,
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
            InkWell(
              onTap: () async {
                HapticFeedback.lightImpact();
                await Clipboard.setData(ClipboardData(text: l10n.contactEmail));
                if (context.mounted) {
                  AppToast.showSuccess(
                    context,
                    'Đã sao chép email: ${l10n.contactEmail}',
                    appColors,
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
                  border: Border.all(
                    color: appColors.primary.withValues(alpha: 0.2),
                  ),
                ),
                child: Row(
                  children: [
                    Icon(
                      CupertinoIcons.mail,
                      color: appColors.primary,
                      size: 20,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        physics: const BouncingScrollPhysics(),
                        child: Text(
                          l10n.contactEmail,
                          style: TextStyle(
                            color: appColors.primaryDark,
                            fontWeight: FontWeight.bold,
                            fontSize: 14,
                          ),
                          maxLines: 1,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Icon(
                      CupertinoIcons.doc_on_doc,
                      color: appColors.textMuted,
                      size: 18,
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            Text(
              '${l10n.appVersionTitle}: ${l10n.appVersion}',
              style: TextStyle(
                fontSize: 12,
                color: appColors.textMuted,
                fontWeight: FontWeight.w500,
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
              onPressed: () {
                HapticFeedback.lightImpact();
                Navigator.of(context).pop();
              },
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

  // 💡 HÀM MỚI: HIỂN THỊ DIALOG XÁC NHẬN XÓA TÀI KHOẢN
  void _showDeleteAccountDialog(
    BuildContext context,
    WidgetRef ref, // ref cũ này ta sẽ không dùng cho các tác vụ async nữa
    AppColorTheme appColors,
    AppLocalizations l10n,
  ) {
    showDialog(
      context: context,
      barrierDismissible: false, // Ngăn người dùng bấm ra ngoài khi đang xử lý
      builder: (dialogContext) => AlertDialog(
        backgroundColor: appColors.background,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        contentPadding: const EdgeInsets.all(24),
        content: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.red.withValues(alpha: 0.1),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  CupertinoIcons.exclamationmark_triangle_fill,
                  color: Colors.red,
                  size: 40,
                ),
              ),
              const SizedBox(height: 16),
              Text(
                l10n.deleteAccountTitle,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: appColors.primaryDark,
                ),
              ),
              const SizedBox(height: 12),
              Text(
                l10n.deleteAccountWarning,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 14,
                  color: appColors.textMuted,
                  height: 1.4,
                ),
              ),
              const SizedBox(height: 24),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      style: OutlinedButton.styleFrom(
                        foregroundColor: appColors.textMuted,
                        side: BorderSide(
                          color: appColors.textMuted.withValues(alpha: 0.3),
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        padding: const EdgeInsets.symmetric(
                          vertical: 14,
                          horizontal: 8,
                        ),
                      ),
                      onPressed: () {
                        HapticFeedback.lightImpact();
                        Navigator.of(
                          dialogContext,
                        ).pop(); // Sử dụng đúng context của dialog
                      },
                      child: FittedBox(
                        fit: BoxFit.scaleDown,
                        child: Text(
                          l10n.cancel,
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    // 🚀 GIẢI PHÁP: Sử dụng Consumer để tạo ra một 'ref' mới tinh,
                    // thuộc về Dialog chứ không liên quan đến BottomSheet đã bị đóng.
                    child: Consumer(
                      builder: (context, dialogRef, child) {
                        return ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.red,
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            padding: const EdgeInsets.symmetric(
                              vertical: 14,
                              horizontal: 8,
                            ),
                            elevation: 0,
                          ),
                          onPressed: () async {
                            HapticFeedback.heavyImpact();
                            try {
                              // 🚀 SỬ DỤNG dialogRef thay vì ref cũ
                              await dialogRef
                                  .read(authProvider.notifier)
                                  .deleteAccount();
                              AppToast.showSuccess(
                                context,
                                l10n.accountDeleted,
                                appColors,
                              );
                              if (!context.mounted) return;
                              Navigator.of(context).pushNamedAndRemoveUntil(
                                '/login',
                                (route) => false,
                              );
                            } catch (e) {
                              if (!context.mounted) return;
                              Navigator.of(context).pop(); // Đóng dialog
                              AppToast.showError(
                                context,
                                l10n.deleteAccountError,
                                appColors,
                              );
                            }
                          },
                          child: FittedBox(
                            fit: BoxFit.scaleDown,
                            child: Text(
                              l10n.deleteButton,
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
