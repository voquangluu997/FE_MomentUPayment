import 'dart:convert';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:moment_u_payment/core/utils/app_logger.dart';
import 'package:sign_in_with_apple/sign_in_with_apple.dart';

class AuthService {
  // 1. Lấy API_BASE_URL từ file .env (Mặc định fallback về localhost nếu trống)
  final String _baseUrl = dotenv.env['API_BASE_URL'] ?? 'http://localhost:8001';

  // 2. Cấu hình Google Sign-In với các quyền truy cập cơ bản (Email, Profile)
  final GoogleSignIn _googleSignIn = GoogleSignIn(scopes: ['email', 'profile']);

  // 3. Khởi tạo bộ lưu trữ bảo mật cục bộ để lưu JWT Token
  final _secureStorage = const FlutterSecureStorage();

  static const String _logTag = 'AuthService';

  /// **Hàm xử lý Đăng nhập bằng Google**
  /// Trả về `true` nếu đăng nhập và xác thực với Backend thành công.
  Future<bool> signInWithGoogle() async {
    try {
      // Bước 1: Hiển thị hộp thoại chọn tài khoản Google hệ thống
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
      if (googleUser == null) {
        AppLogger.i(
          _logTag,
          '🚪 Người dùng đã hủy bỏ tiến trình đăng nhập Google.',
        );
        return false;
      }

      // Bước 2: Lấy thông tin chứng thực (Tokens) từ tài khoản Google
      final GoogleSignInAuthentication googleAuth =
          await googleUser.authentication;
      final String? accessToken = googleAuth.accessToken;

      if (accessToken == null) {
        AppLogger.e(_logTag, '❌ Không lấy được Access Token từ Google.');
        return false;
      }

      AppLogger.i(
        _logTag,
        '📡 Đang gửi Google Access Token lên NestJS Gateway: $_baseUrl',
      );

      // Bước 3: Gửi Access Token lên endpoint của Backend NestJS
      final url = Uri.parse('$_baseUrl/auth/google-login');
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'accessToken': accessToken}),
      );

      // Bước 4: Kiểm tra kết quả phản hồi từ Backend
      if (response.statusCode == 201 || response.statusCode == 200) {
        final data = jsonDecode(response.body);
        String backendToken = data['backend_jwt_token'];

        // Lưu JWT Token của hệ thống vào bộ nhớ bảo mật để sử dụng lâu dài
        await _secureStorage.write(key: 'access_token', value: backendToken);

        AppLogger.i(
          _logTag,
          '🔑 Đăng nhập Google thành công! Đã đồng bộ và lưu JWT Hệ thống.',
        );
        return true;
      } else {
        AppLogger.e(
          _logTag,
          '❌ Backend từ chối xác thực tài khoản: ${response.body}',
        );
        return false;
      }
    } catch (error, stackTrace) {
      AppLogger.e(
        _logTag,
        '❌ Lỗi nghiêm trọng xảy ra trong quá trình Đăng nhập Google: $error',
        stackTrace,
      );
      return false;
    }
  }

  Future<bool> signInWithApple() async {
    try {
      // Bước 1: Yêu cầu Apple cấp quyền và lấy Identity Token
      final credential = await SignInWithApple.getAppleIDCredential(
        scopes: [
          AppleIDAuthorizationScopes.email,
          AppleIDAuthorizationScopes.fullName,
        ],
      );

      if (credential.identityToken == null) {
        AppLogger.e(_logTag, '❌ Không lấy được Identity Token từ Apple.');
        return false;
      }

      AppLogger.i(
        _logTag,
        '📡 Đang gửi Apple Identity Token lên NestJS Gateway: $_baseUrl',
      );

      // Bước 2: Đóng gói dữ liệu gửi lên Backend (Lưu ý gộp FullName cho lần đầu)
      final Map<String, dynamic> body = {
        'identityToken': credential.identityToken,
      };

      // Apple chỉ trả về tên ở lần đăng nhập ĐẦU TIÊN
      if (credential.givenName != null || credential.familyName != null) {
        body['name'] = {
          'firstName': credential.givenName ?? '',
          'lastName': credential.familyName ?? '',
        };
      }

      // Bước 3: Gửi request lên endpoint /auth/apple-login
      final url = Uri.parse('$_baseUrl/auth/apple-login');
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(body),
      );

      // Bước 4: Xử lý phản hồi
      if (response.statusCode == 201 || response.statusCode == 200) {
        final data = jsonDecode(response.body);
        String backendToken = data['backend_jwt_token'];

        await _secureStorage.write(key: 'access_token', value: backendToken);
        AppLogger.i(_logTag, '🔑 Đăng nhập Apple thành công! Đã lưu JWT.');
        return true;
      } else {
        AppLogger.e(
          _logTag,
          '❌ Backend từ chối xác thực Apple: ${response.body}',
        );
        return false;
      }
    } catch (error, stackTrace) {
      AppLogger.e(
        _logTag,
        '❌ Lỗi trong quá trình Đăng nhập Apple: $error',
        stackTrace,
      );
      return false;
    }
  }

  /// **Hàm lấy mã xác thực JWT đã lưu**
  /// Dùng để đính kèm vào header `Authorization: Bearer <token>` khi gọi các API cần bảo mật khác.
  Future<String?> getStoredToken() async {
    return await _secureStorage.read(key: 'access_token');
  }

  /// **Hàm Đăng xuất tài khoản**
  /// Xóa trạng thái đăng nhập Google và giải phóng token trên thiết bị.
  Future<void> signOut() async {
    try {
      await _googleSignIn.signOut();
      await _secureStorage.delete(key: 'access_token');
      AppLogger.i(
        _logTag,
        '🚪 Đã đăng xuất hoàn toàn và xóa sạch Token bảo mật.',
      );
    } catch (error, stackTrace) {
      AppLogger.e(_logTag, '❌ Lỗi khi thực hiện đăng xuất: $error', stackTrace);
    }
  }
}
