import 'dart:convert';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:frontend/features/transaction/presentation/controllers/transaction_timeline_controller.dart';
import 'package:frontend/features/transaction/presentation/transaction_provider.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

enum AuthState {
  initial,
  loading,
  loginSuccess,
  loginError,
  registerSuccess,
  emailAlreadyExists,
  registerError,
  googleLoginError,
}

// Model nhỏ để quản lý thông tin User tiện lợi hơn
class UserInfoState {
  final String email;
  final bool isEmailVerified;
  UserInfoState({required this.email, required this.isEmailVerified});
}

// Provider quản lý thông tin User độc lập để HomeScreen lắng nghe Banner
class userInformationProvider extends StateNotifier<UserInfoState?> {
  userInformationProvider() : super(null);

  void updateUserInfo(String email, bool isVerified) {
    state = UserInfoState(email: email, isEmailVerified: isVerified);
  }

  void clearUserInfo() {
    state = null;
  }
}

final userInfoProvider =
    StateNotifierProvider<userInformationProvider, UserInfoState?>((ref) {
      return userInformationProvider();
    });

// AuthNotifier chính phục vụ ứng dụng Moment U Payment
class AuthNotifier extends StateNotifier<AuthState> {
  final Ref ref;
  final _secureStorage = const FlutterSecureStorage();

  // Đọc giá trị động từ file .env. Nếu không tìm thấy sẽ fallback về cổng 8001 làm dự phòng
  final String _baseUrl = dotenv.env['API_BASE_URL'] ?? 'http://localhost:8001';

  AuthNotifier(this.ref) : super(AuthState.initial);

  void resetState() => state = AuthState.initial;

  /// Luồng Login bằng Email thường
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

        // Kiên quyết xóa token cũ trước khi ghi đè token mới để tránh xung đột cache bộ nhớ
        await _secureStorage.delete(key: 'access_token');
        await _secureStorage.write(
          key: 'access_token',
          value: data['backend_jwt_token'],
        );

        // Đồng bộ dữ liệu sang User Info Provider
        ref
            .read(userInfoProvider.notifier)
            .updateUserInfo(
              data['user']['email'],
              data['user']['isEmailVerified'] ?? false,
            );

        // ✨ ĐÃ THÊM: Đập bỏ hoàn toàn trạng thái cũ kẹt trên RAM khi đăng nhập thành công
        ref.invalidate(transactionTimelineProvider);
        ref.invalidate(transactionProvider);

        state = AuthState.loginSuccess;
      } else {
        state = AuthState.loginError;
      }
    } catch (_) {
      state = AuthState.loginError;
    }
  }

  /// 🌟 LUỒNG MỚI: Đăng nhập bằng Google tích hợp hệ thống
  Future<void> loginWithGoogle() async {
    state = AuthState.loading;
    try {
      final GoogleSignIn googleSignIn = GoogleSignIn(
        scopes: ['email', 'profile'],
      );
      final GoogleSignInAccount? googleUser = await googleSignIn.signIn();

      if (googleUser == null) {
        state = AuthState.initial; // User hủy bấm đăng nhập Google
        return;
      }

      final GoogleSignInAuthentication googleAuth =
          await googleUser.authentication;
      final String? accessToken = googleAuth.accessToken;

      if (accessToken == null) {
        state = AuthState.googleLoginError;
        return;
      }

      // Gửi accessToken của Google lên NestJS xác thực chéo
      final response = await http.post(
        Uri.parse('$_baseUrl/auth/google-login'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'accessToken': accessToken}),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        final data = jsonDecode(response.body);

        await _secureStorage.delete(key: 'access_token');
        await _secureStorage.write(
          key: 'access_token',
          value: data['backend_jwt_token'],
        );

        // Đồng bộ dữ liệu sang User Info Provider (Google mặc định verified = true)
        ref
            .read(userInfoProvider.notifier)
            .updateUserInfo(
              data['user']['email'],
              data['user']['isEmailVerified'] ?? true,
            );

        // ✨ ĐÃ THÊM: Dọn sạch bộ nhớ cache ngay khi login bằng Google thành công
        ref.invalidate(transactionTimelineProvider);
        ref.invalidate(transactionProvider);

        state = AuthState.loginSuccess;
      } else {
        state = AuthState.googleLoginError;
      }
    } catch (e) {
      state = AuthState.googleLoginError;
    }
  }

  /// Gửi lại email xác thực (Lazy Verification)
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

  /// Đồng bộ thủ công hoặc đồng bộ tự động trạng thái email từ DB
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
        ref
            .read(userInfoProvider.notifier)
            .updateUserInfo(
              data['user']['email'],
              data['user']['isEmailVerified'] ?? false,
            );
      }
    } catch (_) {}
  }

  /// Luồng Đăng ký tài khoản thường
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
    // 1. Xóa token bảo mật
    await _secureStorage.delete(key: 'access_token');

    // 2. Ngắt kết nối Google Sign In
    try {
      final GoogleSignIn googleSignIn = GoogleSignIn(
        scopes: ['email', 'profile'],
      );
      await googleSignIn.signOut();
      await googleSignIn.disconnect();
    } catch (_) {}

    // 3. Xóa thông tin user cục bộ
    ref.read(userInfoProvider.notifier).clearUserInfo();
    state = AuthState.initial;

    // 4. ✨ ĐÃ SỬA: Invalidate triệt để tất cả các Provider lưu trữ dữ liệu giao dịch trên RAM
    ref.invalidate(transactionTimelineProvider);
    ref.invalidate(transactionProvider);
  }
}

// Khai báo Provider dùng chung toàn hệ thống
final authProvider = StateNotifierProvider<AuthNotifier, AuthState>((ref) {
  return AuthNotifier(ref);
});
