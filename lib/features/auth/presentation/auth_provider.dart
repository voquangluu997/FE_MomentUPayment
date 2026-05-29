import 'dart:convert';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:moment_u_payment/features/transaction/presentation/controllers/transaction_timeline_controller.dart';
import 'package:moment_u_payment/features/transaction/presentation/transaction_provider.dart';

enum AuthState {
  initial,
  loading,
  authenticated, // ✨ ĐÃ THÊM: Trạng thái tự động vào thẳng Home khi token hợp lệ
  unauthenticated, // ✨ ĐÃ THÊM: Trạng thái chưa đăng nhập hoặc token hết hạn
  loginSuccess,
  loginError,
  registerSuccess,
  emailAlreadyExists,
  registerError,
  googleLoginError,
}

// Model nhỏ để quản lý thông tin User tiện lợi hơn
class UserInfoState {
  final String name;
  final String email;
  final bool isEmailVerified;

  UserInfoState({
    required this.name,
    required this.email,
    required this.isEmailVerified,
  });
}

// Provider quản lý thông tin User độc lập để HomeScreen lắng nghe Banner
class userInformationProvider extends StateNotifier<UserInfoState?> {
  userInformationProvider() : super(null);

  void updateUserInfo(String name, String email, bool isVerified) {
    state = UserInfoState(
      name: name,
      email: email,
      isEmailVerified: isVerified,
    );
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
  final String _baseUrl = dotenv.env['API_BASE_URL'] ?? 'http://localhost:8001';

  // 🔑 TỰ ĐỘNG CHẠY: Khởi chạy hàm check token ngay khi notifier được tạo ra
  AuthNotifier(this.ref) : super(AuthState.initial) {
    checkAuthStatus();
  }

  void resetState() => state = AuthState.initial;

  /// 🔑 HÀM MỚI: Thẩm định token cũ nằm trong máy xem còn hạn hay không
  Future<void> checkAuthStatus() async {
    state = AuthState.loading;
    try {
      String? token = await _secureStorage.read(key: 'access_token');
      if (token == null) {
        state = AuthState.unauthenticated;
        return;
      }

      // Gọi API /auth/me để kiểm tra tính hợp lệ của token phía NestJS
      final response = await http.get(
        Uri.parse('$_baseUrl/auth/me'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);

        final email = data['user']['email'] ?? '';
        final name = data['user']['name'] ?? email.split('@').first;

        ref
            .read(userInfoProvider.notifier)
            .updateUserInfo(
              name,
              email,
              data['user']['isEmailVerified'] ?? false,
            );

        // Làm sạch RAM bộ nhớ đệm
        ref.invalidate(transactionTimelineProvider);
        ref.invalidate(transactionProvider);

        state = AuthState.authenticated; // Kích hoạt vào thẳng Home
      } else {
        // Token hết hạn hoặc không hợp lệ -> Xóa bỏ token rác
        await _secureStorage.delete(key: 'access_token');
        state = AuthState.unauthenticated;
      }
    } catch (_) {
      // Trường hợp lỗi kết nối hoặc server sập, giữ an toàn đẩy ra màn login
      state = AuthState.unauthenticated;
    }
  }

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

        await _secureStorage.delete(key: 'access_token');
        await _secureStorage.write(
          key: 'access_token',
          value: data['backend_jwt_token'],
        );

        final userEmail = data['user']['email'] ?? email;
        final userName = data['user']['name'] ?? userEmail.split('@').first;

        ref
            .read(userInfoProvider.notifier)
            .updateUserInfo(
              userName,
              userEmail,
              data['user']['isEmailVerified'] ?? false,
            );

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

  /// Luồng Đăng nhập bằng Google
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

        await _secureStorage.delete(key: 'access_token');
        await _secureStorage.write(
          key: 'access_token',
          value: data['backend_jwt_token'],
        );

        final email = data['user']['email'] ?? '';
        final name = data['user']['name'] ?? email.split('@').first;

        ref
            .read(userInfoProvider.notifier)
            .updateUserInfo(
              name,
              email,
              data['user']['isEmailVerified'] ?? true,
            );

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

  /// Gửi lại email xác thực
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
        final userEmail = data['user']['email'] ?? '';
        final userName = data['user']['name'] ?? userEmail.split('@').first;

        ref
            .read(userInfoProvider.notifier)
            .updateUserInfo(
              userName,
              userEmail,
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
    await _secureStorage.delete(key: 'access_token');

    try {
      final GoogleSignIn googleSignIn = GoogleSignIn(
        scopes: ['email', 'profile'],
      );
      await googleSignIn.signOut();
      await googleSignIn.disconnect();
    } catch (_) {}

    ref.read(userInfoProvider.notifier).clearUserInfo();

    // 🔑 CẬP NHẬT: Trả về trạng thái chưa đăng nhập để AuthChecker tự bốc user ra ngoài màn Login
    state = AuthState.unauthenticated;

    ref.invalidate(transactionTimelineProvider);
    ref.invalidate(transactionProvider);
  }
}

final authProvider = StateNotifierProvider<AuthNotifier, AuthState>((ref) {
  return AuthNotifier(ref);
});
