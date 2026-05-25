import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart'; // ✨ Thêm import này để lưu token
import '../../../../core/network/api_client.dart';

enum AuthState {
  initial,
  loading,
  loginSuccess,
  loginError,
  registerSuccess,
  registerError,
  emailAlreadyExists,
}

class AuthNotifier extends StateNotifier<AuthState> {
  AuthNotifier() : super(AuthState.initial);

  // 🔐 Xử lý Đăng nhập & Lưu trữ Token thực tế từ NestJS
  Future<void> login(String email, String password) async {
    state = AuthState.loading;
    try {
      final response = await dioClient.post(
        'auth/login',
        data: {'email': email, 'password': password},
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        // ✨ BƯỚC QUAN TRỌNG: Đọc token từ dữ liệu trả về của NestJS
        // Giả sử cấu hình BE của bạn trả về JSON có cấu trúc dạng: { "access_token": "ey..." }
        final token = response.data['access_token'] ?? response.data['token'];

        if (token != null) {
          final prefs = await SharedPreferences.getInstance();
          // 🔥 Ghi nhớ token vào bộ nhớ máy thật dưới key 'access_token'
          await prefs.setString('access_token', token as String);
          print(
            '✅ [AuthNotifier]: Đã lưu access_token thành công vào SharedPreferences!',
          );
          state = AuthState.loginSuccess;
        } else {
          print(
            '⚠️ [AuthNotifier]: Login thành công nhưng không tìm thấy key "access_token" trong Response của BE!',
          );
          state = AuthState.loginError;
        }
      } else {
        state = AuthState.loginError;
      }
    } catch (e) {
      print('🔴 [API Login Error]: $e');
      state = AuthState.loginError;
    }
  }

  // 📝 Xử lý Đăng ký
  Future<void> register(String name, String email, String password) async {
    state = AuthState.loading;
    try {
      final response = await dioClient.post(
        'auth/register',
        data: {'name': name, 'email': email, 'password': password},
      );

      if (response.statusCode == 201 || response.statusCode == 200) {
        state = AuthState.registerSuccess;
      } else {
        state = AuthState.registerError;
      }
    } catch (e) {
      print('🔴 [API Register Error]: $e');
      state = AuthState.registerError;
    }
  }

  void resetState() => state = AuthState.initial;
}

final authProvider = StateNotifierProvider<AuthNotifier, AuthState>((ref) {
  return AuthNotifier();
});
