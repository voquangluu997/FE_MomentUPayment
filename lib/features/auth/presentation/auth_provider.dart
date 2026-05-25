import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:dio/dio.dart';
import '../../../../core/network/api_client.dart';

enum AuthState {
  initial,
  loading,
  // ✨ Tách biệt trạng thái rõ ràng
  loginSuccess,
  loginError,
  registerSuccess,
  registerError,
  emailAlreadyExists,
}

class AuthNotifier extends StateNotifier<AuthState> {
  AuthNotifier() : super(AuthState.initial);

  // 🔐 Xử lý Đăng nhập
  Future<void> login(String email, String password) async {
    state = AuthState.loading;
    try {
      final response = await dioClient.post(
        'auth/login',
        data: {'email': email, 'password': password},
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        state = AuthState.loginSuccess;
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
    } on DioException catch (e) {
      // ✨ Chi tiết hóa lỗi từ Backend để dễ debug máy thật
      print(
        '🔴 [API Register DioError]: ${e.response?.statusCode} - ${e.response?.data}',
      );

      if (e.response?.statusCode == 409) {
        state = AuthState.emailAlreadyExists;
      } else {
        state = AuthState.registerError;
      }
    } catch (e) {
      print('🔴 [API Register Unexpected Error]: $e');
      state = AuthState.registerError;
    }
  }

  void resetState() => state = AuthState.initial;
}

final authProvider = StateNotifierProvider<AuthNotifier, AuthState>((ref) {
  return AuthNotifier();
});
