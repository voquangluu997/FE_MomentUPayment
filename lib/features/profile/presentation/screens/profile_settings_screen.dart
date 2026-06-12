import 'dart:io';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:moment_u_payment/core/constants/app_colors.dart';
import 'package:moment_u_payment/core/widgets/app_network_image.dart';
import 'package:moment_u_payment/l10n/app_localizations.dart';
import 'package:moment_u_payment/features/auth/presentation/auth_provider.dart';
import 'package:moment_u_payment/features/transaction/data/transaction_repository.dart';
import 'package:moment_u_payment/core/utils/app_toast.dart';

class ProfileSettingsScreen extends ConsumerStatefulWidget {
  const ProfileSettingsScreen({super.key});

  @override
  ConsumerState<ProfileSettingsScreen> createState() =>
      _ProfileSettingsScreenState();
}

class _ProfileSettingsScreenState extends ConsumerState<ProfileSettingsScreen> {
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _oldPwController = TextEditingController();
  final _newPwController = TextEditingController();

  File? _selectedImage;
  final ImagePicker _picker = ImagePicker();
  bool _isLoading = false;

  final List<IconData> _avatarIcons = [
    CupertinoIcons.paw,
    CupertinoIcons.smiley,
    CupertinoIcons.person_alt,
    CupertinoIcons.person_crop_circle,
    CupertinoIcons.lightbulb,
    CupertinoIcons.heart_fill,
  ];

  @override
  void initState() {
    super.initState();
    final user = ref.read(userInfoProvider);
    if (user != null) {
      _nameController.text = user.name;
      _emailController.text = user.email;
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _oldPwController.dispose();
    _newPwController.dispose();
    super.dispose();
  }

  IconData _getAvatarIcon(String userId) {
    return _avatarIcons[userId.hashCode % _avatarIcons.length];
  }

  Future<void> _pickImage() async {
    final XFile? image = await _picker.pickImage(source: ImageSource.gallery);
    if (image != null) setState(() => _selectedImage = File(image.path));
  }

  String _getLocalizedErrorMessage(String error, AppLocalizations l10n) {
    final lowerError = error.toLowerCase();
    if (lowerError.contains('wrong password') ||
        lowerError.contains('incorrect password') ||
        lowerError.contains('mật khẩu không đúng')) {
      return l10n.wrongOldPassword;
    }
    if (lowerError.contains('user not found') ||
        lowerError.contains('invalid user')) {
      return l10n.userNotFoundError;
    }
    if (lowerError.contains('weak password')) {
      return l10n.weakPasswordError;
    }
    return error;
  }

  Future<void> _handleUpdateProfile(AppLocalizations l10n) async {
    final appColors = ref.read(appColorsProvider);
    final user = ref.read(userInfoProvider);

    final hasNameChanged = _nameController.text.trim() != (user?.name ?? '');
    final hasImageChanged = _selectedImage != null;

    if (!hasNameChanged && !hasImageChanged) {
      AppToast.showInfo(context, l10n.noChangeWarning, appColors);
      return;
    }

    if (_nameController.text.trim().isEmpty) {
      AppToast.showError(context, l10n.nameEmptyError, appColors);
      return;
    }

    setState(() => _isLoading = true);
    try {
      String? imageUrl = user?.avatar;
      if (_selectedImage != null) {
        imageUrl = await ref
            .read(transactionRepositoryProvider)
            .uploadInvoiceImage(_selectedImage!.path);
      }

      final errorMessage = await ref
          .read(authProvider.notifier)
          .updateProfile(_nameController.text.trim(), imageUrl);

      if (errorMessage == null) {
        if (mounted) {
          AppToast.showSuccess(context, l10n.updateSuccess, appColors);
        }
        setState(() => _selectedImage = null);
      } else {
        if (mounted) {
          AppToast.showError(
            context,
            _getLocalizedErrorMessage(errorMessage, l10n),
            appColors,
          );
        }
      }
    } catch (e) {
      if (mounted) {
        AppToast.showError(context, l10n.systemError, appColors);
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _handleUpdatePassword(AppLocalizations l10n) async {
    final appColors = ref.read(appColorsProvider);

    if (_oldPwController.text.isEmpty || _newPwController.text.isEmpty) {
      AppToast.showError(context, l10n.fillPasswordFieldsError, appColors);
      return;
    }

    if (_oldPwController.text.length < 4 || _newPwController.text.length < 4) {
      AppToast.showError(context, l10n.passwordLengthError, appColors);
      return;
    }

    if (_oldPwController.text == _newPwController.text) {
      AppToast.showError(context, l10n.samePasswordError, appColors);
      return;
    }

    setState(() => _isLoading = true);
    try {
      final errorMessage = await ref
          .read(authProvider.notifier)
          .updatePassword(_oldPwController.text, _newPwController.text);

      if (errorMessage == null) {
        if (mounted) {
          AppToast.showSuccess(context, l10n.updateSuccess, appColors);
        }
        _oldPwController.clear();
        _newPwController.clear();
      } else {
        if (mounted) {
          AppToast.showError(
            context,
            _getLocalizedErrorMessage(errorMessage, l10n),
            appColors,
          );
        }
      }
    } catch (e) {
      if (mounted) {
        AppToast.showError(context, l10n.systemError, appColors);
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  // ✨ Đã sửa lại thành pop() thông thường để không làm mất data màn hình Home
  void _navigateToHome() {
    FocusScope.of(context).unfocus(); // Đóng bàn phím trước khi lùi về
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final appColors = ref.watch(appColorsProvider);
    final l10n = AppLocalizations.of(context)!;
    final user = ref.watch(userInfoProvider);
    final userId = user?.email ?? "default_user";
    final userIcon = _getAvatarIcon(userId);

    // ✨ Bọc GestureDetector toàn màn hình để chạm ra ngoài tự đóng bàn phím
    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: Scaffold(
        backgroundColor: appColors.background,
        appBar: AppBar(
          centerTitle: true,
          leading: IconButton(
            icon: Icon(CupertinoIcons.back, color: appColors.primaryDark),
            onPressed: _navigateToHome,
          ),
          title: Text(
            l10n.accountSettings,
            style: TextStyle(
              color: appColors.primaryDark,
              fontSize: 18,
              fontWeight: FontWeight.w700,
              letterSpacing: 0.5,
            ),
          ),
          backgroundColor: appColors.background,
          elevation: 0,
          scrolledUnderElevation: 0,
        ),
        body: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              _buildAvatarSection(appColors, user, userIcon),
              const SizedBox(height: 32),

              _buildModernCard(
                appColors: appColors,
                title: l10n.personalInfo.toUpperCase(),
                icon: CupertinoIcons.person_crop_square,
                children: [
                  _buildModernTextField(
                    label: l10n.email,
                    controller: _emailController,
                    appColors: appColors,
                    icon: CupertinoIcons.mail,
                    enabled: false,
                  ),
                  const SizedBox(height: 16),
                  _buildModernTextField(
                    label: l10n.fullName,
                    controller: _nameController,
                    appColors: appColors,
                    icon: CupertinoIcons.person,
                  ),
                  const SizedBox(height: 24),
                  _buildPrimaryButton(
                    text: l10n.updateProfile,
                    onPressed: () => _handleUpdateProfile(l10n),
                    appColors: appColors,
                  ),
                ],
              ),
              const SizedBox(height: 24),

              _buildModernCard(
                appColors: appColors,
                title: l10n.security.toUpperCase(),
                icon: CupertinoIcons.lock_shield,
                children: [
                  _buildModernTextField(
                    label: l10n.currentPassword,
                    controller: _oldPwController,
                    appColors: appColors,
                    icon: CupertinoIcons.lock,
                    isPassword: true,
                  ),
                  const SizedBox(height: 16),
                  _buildModernTextField(
                    label: l10n.newPassword,
                    controller: _newPwController,
                    appColors: appColors,
                    icon: CupertinoIcons.lock_rotation,
                    isPassword: true,
                  ),
                  const SizedBox(height: 24),
                  _buildPrimaryButton(
                    text: l10n.updatePassword,
                    onPressed: () => _handleUpdatePassword(l10n),
                    appColors: appColors,
                    isSecondary: true,
                  ),
                ],
              ),
              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAvatarSection(
    AppColorTheme appColors,
    dynamic user,
    IconData userIcon,
  ) {
    return Column(
      children: [
        GestureDetector(
          onTap: _pickImage,
          child: Stack(
            alignment: Alignment.bottomRight,
            children: [
              Container(
                width: 110,
                height: 110,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: appColors.primary.withOpacity(0.1),
                  boxShadow: [
                    BoxShadow(
                      color: appColors.primary.withOpacity(0.15),
                      blurRadius: 20,
                      offset: const Offset(0, 10),
                    ),
                  ],
                  border: Border.all(color: appColors.background, width: 4),
                ),
                child: _selectedImage != null
                    ? ClipOval(
                        child: Image.file(
                          _selectedImage!,
                          fit: BoxFit.cover,
                          width: 110,
                          height: 110,
                        ),
                      )
                    : (user?.avatar != null && user!.avatar!.isNotEmpty)
                    ? ClipOval(
                        child: AppNetworkImage(
                          imageUrl: user.avatar,
                          width: 110,
                          height: 110,
                          fit: BoxFit.cover,
                          // 🔥 Đưa logic hiển thị Icon mặc định vào làm customErrorWidget
                          customErrorWidget: Container(
                            width: 110,
                            height: 110,
                            decoration: BoxDecoration(
                              color: appColors.primary.withOpacity(
                                0.1,
                              ), // Màu nền nhẹ cho avatar lỗi
                              shape:
                                  BoxShape.circle, // Giữ hình tròn cho avatar
                            ),
                            child: Icon(
                              userIcon,
                              size: 50,
                              color: appColors.primary,
                            ),
                          ),
                        ),
                      )
                    : Icon(userIcon, size: 50, color: appColors.primary),
              ),
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: appColors.primary,
                  shape: BoxShape.circle,
                  border: Border.all(color: appColors.background, width: 3),
                  boxShadow: [
                    BoxShadow(
                      color: appColors.primaryDark.withOpacity(0.3),
                      blurRadius: 8,
                      offset: const Offset(0, 3),
                    ),
                  ],
                ),
                child: const Icon(
                  CupertinoIcons.camera_fill,
                  color: Colors.white,
                  size: 18,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        Text(
          user?.name ?? 'Người dùng Moment',
          style: TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.bold,
            color: appColors.primaryDark,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          'Thay đổi ảnh đại diện',
          style: TextStyle(
            fontSize: 13,
            color: appColors.textMuted,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }

  Widget _buildModernCard({
    required AppColorTheme appColors,
    required String title,
    required IconData icon,
    required List<Widget> children,
  }) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: appColors.cardBackground,
        borderRadius: BorderRadius.circular(28),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: appColors.primary, size: 20),
              const SizedBox(width: 8),
              Text(
                title,
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 1.2,
                  color: appColors.primary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          ...children,
        ],
      ),
    );
  }

  Widget _buildModernTextField({
    required String label,
    required TextEditingController controller,
    required AppColorTheme appColors,
    required IconData icon,
    bool isPassword = false,
    bool enabled = true,
  }) {
    return TextField(
      controller: controller,
      obscureText: isPassword,
      enabled: enabled,
      style: TextStyle(
        color: enabled ? appColors.text : appColors.textMuted,
        fontWeight: FontWeight.w500,
      ),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: TextStyle(
          color: appColors.textMuted.withOpacity(0.8),
          fontWeight: FontWeight.w500,
        ),
        prefixIcon: Icon(
          icon,
          color: enabled
              ? appColors.primaryDark.withOpacity(0.5)
              : appColors.textMuted.withOpacity(0.4),
          size: 22,
        ),
        filled: true,
        fillColor: enabled
            ? appColors.background.withOpacity(0.5)
            : appColors.background.withOpacity(0.2),
        contentPadding: const EdgeInsets.symmetric(
          vertical: 18,
          horizontal: 20,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(color: appColors.primary, width: 1.5),
        ),
      ),
    );
  }

  Widget _buildPrimaryButton({
    required String text,
    required VoidCallback onPressed,
    required AppColorTheme appColors,
    bool isSecondary = false,
  }) {
    return SizedBox(
      width: double.infinity,
      height: 54,
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: isSecondary
              ? appColors.primary.withOpacity(0.1)
              : appColors.primary,
          foregroundColor: isSecondary ? appColors.primary : Colors.white,
          elevation: isSecondary ? 0 : 4,
          shadowColor: appColors.primary.withOpacity(0.4),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(18),
          ),
        ),
        onPressed: _isLoading ? null : onPressed,
        child: _isLoading
            ? SizedBox(
                width: 24,
                height: 24,
                child: CircularProgressIndicator(
                  color: isSecondary ? appColors.primary : Colors.white,
                  strokeWidth: 2.5,
                ),
              )
            : Text(
                text,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 0.5,
                ),
              ),
      ),
    );
  }
}
