import 'dart:convert';

import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:http/http.dart' as http;
import 'package:moment_u_payment/core/utils/app_logger.dart';
import 'package:moment_u_payment/features/auth/data/auth_repository.dart';
import 'package:sign_in_with_apple/sign_in_with_apple.dart';

enum AuthState {
  initial,
  loading,
  authenticated,
  unauthenticated,
  loginSuccess,
  loginError,
  registerSuccess,
  emailAlreadyExists,
  registerError,
  googleLoginError,
  appleLoginError,
}

class UserInfoState {
  final String name;
  final String email;
  final bool isEmailVerified;
  final String? avatar;

  UserInfoState({
    required this.name,
    required this.email,
    required this.isEmailVerified,
    this.avatar,
  });
}

class UserInformationProvider extends StateNotifier<UserInfoState?> {
  UserInformationProvider() : super(null);

  void updateUserInfo(
    String name,
    String email,
    bool isVerified,
    String? avatar,
  ) {
    state = UserInfoState(
      name: name,
      email: email,
      isEmailVerified: isVerified,
      avatar: avatar,
    );
  }

  void clearUserInfo() {
    state = null;
  }
}

final userInfoProvider =
    StateNotifierProvider<UserInformationProvider, UserInfoState?>((ref) {
      return UserInformationProvider();
    });

class AuthNotifier extends StateNotifier<AuthState> {
  final Ref ref;
  final _secureStorage = const FlutterSecureStorage();
  final String _baseUrl = dotenv.env['API_BASE_URL'] ?? 'http://localhost:8001';

  AuthNotifier(this.ref) : super(AuthState.initial) {
    checkAuthStatus();
  }

  void resetState() => state = AuthState.initial;

  void completeLoginTransition() {
    state = AuthState.authenticated;
  }

  Future<void> checkAuthStatus() async {
    state = AuthState.loading;
    try {
      String? token = await _secureStorage.read(key: 'access_token');

      if (token == null) {
        state = AuthState.unauthenticated;
        return;
      }

      state = AuthState.authenticated;

      final response = await http
          .get(
            Uri.parse('$_baseUrl/auth/me'),
            headers: {
              'Content-Type': 'application/json',
              'Authorization': 'Bearer $token',
            },
          )
          .timeout(const Duration(seconds: 8));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final user = data['user'];

        if (user != null) {
          ref
              .read(userInfoProvider.notifier)
              .updateUserInfo(
                user['name']?.toString() ?? '',
                user['email']?.toString() ?? '',
                user['isEmailVerified'] as bool? ?? false,
                user['avatar'] as String?,
              );
        }
      } else if (response.statusCode == 401 || response.statusCode == 403) {
        await _secureStorage.delete(key: 'access_token');
        ref.read(userInfoProvider.notifier).clearUserInfo();
        state = AuthState.unauthenticated;
      }
    } catch (_) {
      String? token = await _secureStorage.read(key: 'access_token');
      if (token == null) {
        state = AuthState.unauthenticated;
      } else {
        state = AuthState.authenticated;
      }
    }
  }

  Future<void> login(String email, String password) async {
    state = AuthState.loading;
    try {
      final response = await http.post(
        Uri.parse('$_baseUrl/auth/login'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'email': email, 'password': password}),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        final data = jsonDecode(response.body);
        await _secureStorage.write(
          key: 'access_token',
          value: data['backend_jwt_token'],
        );

        final user = data['user'];

        if (user != null) {
          ref
              .read(userInfoProvider.notifier)
              .updateUserInfo(
                user['name']?.toString() ?? '',
                user['email']?.toString() ?? email,
                user['isEmailVerified'] as bool? ?? false,
                user['avatar'] as String?,
              );
        }
        state = AuthState.loginSuccess;
      } else {
        state = AuthState.loginError;
      }
    } catch (e) {
      state = AuthState.loginError;
    }
  }

  Future<void> loginWithGoogle() async {
    state = AuthState.loading;
    try {
      final GoogleSignIn googleSignIn = GoogleSignIn(
        scopes: ['email', 'profile'],
      );
      final GoogleSignInAccount? googleUser = await googleSignIn.signIn();

      if (googleUser == null) {
        state = AuthState.initial;
        return;
      }

      final GoogleSignInAuthentication googleAuth =
          await googleUser.authentication;
      final String? accessToken = googleAuth.accessToken;

      if (accessToken == null) {
        state = AuthState.googleLoginError;
        return;
      }

      final response = await http.post(
        Uri.parse('$_baseUrl/auth/google-login'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'accessToken': accessToken}),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        final data = jsonDecode(response.body);
        await _secureStorage.write(
          key: 'access_token',
          value: data['backend_jwt_token'],
        );

        final user = data['user'];

        if (user != null) {
          ref
              .read(userInfoProvider.notifier)
              .updateUserInfo(
                user['name']?.toString() ?? '',
                user['email']?.toString() ?? '',
                user['isEmailVerified'] as bool? ?? true,
                user['avatar'] as String?,
              );
        }
        state = AuthState.loginSuccess;
      } else {
        state = AuthState.googleLoginError;
      }
    } catch (e) {
      state = AuthState.googleLoginError;
    }
  }

  Future<void> loginWithApple() async {
    state = AuthState.loading;
    try {
      final credential = await SignInWithApple.getAppleIDCredential(
        scopes: [
          AppleIDAuthorizationScopes.email,
          AppleIDAuthorizationScopes.fullName,
        ],
      );

      if (credential.identityToken == null) {
        state = AuthState.appleLoginError;
        return;
      }

      final Map<String, dynamic> body = {
        'identityToken': credential.identityToken,
      };
      if (credential.givenName != null || credential.familyName != null) {
        body['name'] = {
          'firstName': credential.givenName ?? '',
          'lastName': credential.familyName ?? '',
        };
      }

      final response = await http.post(
        Uri.parse('$_baseUrl/auth/apple-login'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(body),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        final data = jsonDecode(response.body);
        await _secureStorage.write(
          key: 'access_token',
          value: data['backend_jwt_token'],
        );

        final user = data['user'];

        if (user != null) {
          ref
              .read(userInfoProvider.notifier)
              .updateUserInfo(
                user['name']?.toString() ?? '',
                user['email']?.toString() ?? '',
                user['isEmailVerified'] as bool? ?? true,
                user['avatar'] as String?,
              );
        }
        state = AuthState.loginSuccess;
      } else {
        state = AuthState.appleLoginError;
      }
    } catch (e) {
      AppLogger.d('d', "====== [DEBUG APPLE LOGIN] ERROR: $e ======");
      state = AuthState.appleLoginError;
    }
  }

  Future<bool> resendVerificationEmail(String email) async {
    try {
      final response = await http.post(
        Uri.parse('$_baseUrl/auth/resend-verification'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'email': email}),
      );
      return response.statusCode == 200 || response.statusCode == 201;
    } catch (_) {
      return false;
    }
  }

  Future<void> syncEmailVerificationStatus() async {
    try {
      String? token = await _secureStorage.read(key: 'access_token');
      if (token == null) return;

      final response = await http.get(
        Uri.parse('$_baseUrl/auth/me'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final user = data['user'];

        if (user != null) {
          ref
              .read(userInfoProvider.notifier)
              .updateUserInfo(
                user['name']?.toString() ?? '',
                user['email']?.toString() ?? '',
                user['isEmailVerified'] as bool? ?? false,
                user['avatar'] as String?,
              );
        }
      }
    } catch (_) {}
  }

  Future<void> register(String name, String email, String password) async {
    state = AuthState.loading;
    try {
      final response = await http.post(
        Uri.parse('$_baseUrl/auth/register'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'name': name, 'email': email, 'password': password}),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        state = AuthState.registerSuccess;
      } else if (response.statusCode == 400) {
        state = AuthState.emailAlreadyExists;
      } else {
        state = AuthState.registerError;
      }
    } catch (_) {
      state = AuthState.registerError;
    }
  }

  Future<void> logout() async {
    await _secureStorage.delete(key: 'access_token');
    try {
      final GoogleSignIn googleSignIn = GoogleSignIn();
      await googleSignIn.signOut();
    } catch (_) {}

    ref.read(userInfoProvider.notifier).clearUserInfo();
    state = AuthState.unauthenticated;
  }

  /// 🚀 HÀM MỚI ĐƯỢC THÊM VÀO: Xóa vĩnh viễn tài khoản người dùng khỏi hệ thống
  Future<void> deleteAccount() async {
    state = AuthState.loading;
    try {
      String? token = await _secureStorage.read(key: 'access_token');
      if (token == null) {
        state = AuthState.unauthenticated;
        throw Exception("Không tìm thấy mã xác thực (Token not found)");
      }

      // Gọi API DELETE tới backend NestJS
      final response = await http.delete(
        Uri.parse('$_baseUrl/auth/delete-account'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        // 1. Xóa JWT Token lưu cục bộ
        await _secureStorage.delete(key: 'access_token');

        // 2. Hủy phiên đăng nhập Google nếu có
        try {
          final GoogleSignIn googleSignIn = GoogleSignIn();
          await googleSignIn.signOut();
        } catch (_) {}

        // 3. Xóa thông tin User Info State và chuyển trạng thái về chưa đăng nhập
        ref.read(userInfoProvider.notifier).clearUserInfo();
        state = AuthState.unauthenticated;
      } else {
        // Hoàn tác lại trạng thái đã xác thực nếu API báo lỗi
        state = AuthState.authenticated;
        throw Exception("Xóa tài khoản không thành công từ phía máy chủ");
      }
    } catch (e) {
      // Hoàn tác trạng thái nếu xảy ra lỗi kết nối hoặc lỗi bất định
      state = AuthState.authenticated;
      rethrow; // Ném tiếp lỗi ra ngoài để khối try-catch trong SettingsBottomSheet nhận diện
    }
  }

  Future<String?> forgotPassword(String email) async {
    state = AuthState.loading;
    try {
      final response = await http.post(
        Uri.parse('$_baseUrl/auth/forgot-password'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'email': email}),
      );
      state = AuthState.initial;

      if (response.statusCode == 200 || response.statusCode == 201) {
        return null;
      } else {
        final data = jsonDecode(response.body);
        return data['message'] ?? "Lỗi gửi yêu cầu";
      }
    } catch (e) {
      state = AuthState.initial;
      return "Lỗi kết nối mạng";
    }
  }

  Future<String?> resetPasswordWithOtp(
    String email,
    String otp,
    String newPassword,
  ) async {
    state = AuthState.loading;
    try {
      final response = await http.post(
        Uri.parse('$_baseUrl/auth/reset-password'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'email': email,
          'otp': otp,
          'newPassword': newPassword,
        }),
      );
      state = AuthState.initial;

      if (response.statusCode == 200 || response.statusCode == 201) {
        return null;
      } else {
        final data = jsonDecode(response.body);
        return data['message'] ?? "Mã OTP không hợp lệ";
      }
    } catch (e) {
      state = AuthState.initial;
      return "Lỗi kết nối mạng";
    }
  }

  Future<String?> updatePassword(String oldPassword, String newPassword) async {
    try {
      String? token = await _secureStorage.read(key: 'access_token');
      if (token == null) {
        return "Lỗi xác thực, vui lòng đăng nhập lại";
      }

      final response = await http.post(
        Uri.parse('$_baseUrl/auth/update-password'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode({
          'oldPassword': oldPassword,
          'newPassword': newPassword,
        }),
      );

      state = AuthState.authenticated;

      if (response.statusCode == 200 || response.statusCode == 201) {
        return null;
      } else {
        final data = jsonDecode(response.body);
        return data['message'] ?? "Cập nhật thất bại. Vui lòng thử lại.";
      }
    } catch (e) {
      state = AuthState.authenticated;
      return "Lỗi kết nối máy chủ";
    }
  }

  Future<String?> updateProfile(String name, String? avatarUrl) async {
    try {
      final response = await ref
          .read(authRepositoryProvider)
          .updateProfile(name, avatarUrl);

      if (response.statusCode == 200 || response.statusCode == 201) {
        final data = response.data;
        final userResponse = data['user'];

        final String newName = userResponse?['name']?.toString() ?? name;
        final String? newAvatar = userResponse?['avatar'] as String?;

        final currentUser = ref.read(userInfoProvider);
        final currentEmail = currentUser?.email ?? "";
        final isVerified = currentUser?.isEmailVerified ?? false;

        ref
            .read(userInfoProvider.notifier)
            .updateUserInfo(newName, currentEmail, isVerified, newAvatar);

        state = AuthState.authenticated;
        return null;
      }

      state = AuthState.authenticated;
      final data = response.data;
      return data['message'] ?? "Cập nhật hồ sơ thất bại";
    } catch (e) {
      state = AuthState.authenticated;
      return "Lỗi kết nối máy chủ";
    }
  }

  void completeLogin() {
    state = AuthState.authenticated;
  }
}

final authProvider = StateNotifierProvider<AuthNotifier, AuthState>((ref) {
  return AuthNotifier(ref);
});
