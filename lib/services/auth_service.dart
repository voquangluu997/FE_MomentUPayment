import 'dart:convert';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

class AuthService {
  // 1. Lấy API_BASE_URL từ file .env (Mặc định fallback về localhost nếu trống)
  final String _baseUrl = dotenv.env['API_BASE_URL'] ?? 'http://localhost:8001';

  // 2. Cấu hình Google Sign-In với các quyền truy cập cơ bản (Email, Profile)
  final GoogleSignIn _googleSignIn = GoogleSignIn(scopes: ['email', 'profile']);

  // 3. Khởi tạo bộ lưu trữ bảo mật cục bộ để lưu JWT Token
  final _secureStorage = const FlutterSecureStorage();

  /// **Hàm xử lý Đăng nhập bằng Google**
  /// Trả về `true` nếu đăng nhập và xác thực với Backend thành công.
  Future<bool> signInWithGoogle() async {
    try {
      // Bước 1: Hiển thị hộp thoại chọn tài khoản Google hệ thống
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
      if (googleUser == null) {
        print('🚪 Người dùng đã hủy bỏ tiến trình đăng nhập Google.');
        return false;
      }

      // Bước 2: Lấy thông tin chứng thực (Tokens) từ tài khoản Google
      final GoogleSignInAuthentication googleAuth =
          await googleUser.authentication;
      final String? accessToken = googleAuth.accessToken;

      if (accessToken == null) {
        print('❌ Không lấy được Access Token từ Google.');
        return false;
      }

      print('📡 Đang gửi Google Access Token lên NestJS Gateway: $_baseUrl');

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
        String accessToken = data['backend_jwt_token'];

        // Lưu JWT Token của hệ thống vào bộ nhớ bảo mật để sử dụng lâu dài
        await _secureStorage.write(key: 'access_token', value: accessToken);

        print(
          '🔑 Đăng nhập Google thành công! Đã đồng bộ và lưu JWT Hệ thống.',
        );
        return true;
      } else {
        print('❌ Backend từ chối xác thực tài khoản: ${response.body}');
        return false;
      }
    } catch (error) {
      print(
        '❌ Lỗi nghiêm trọng xảy ra trong quá trình Đăng nhập Google: $error',
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
      print('🚪 Đã đăng xuất hoàn toàn và xóa sạch Token bảo mật.');
    } catch (error) {
      print('❌ Lỗi khi thực hiện đăng xuất: $error');
    }
  }
}
