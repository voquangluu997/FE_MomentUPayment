import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/network/api_client.dart'; // Giữ nguyên import của dự án bạn

class AuthRepository {
  // Sử dụng trực tiếp dioClient toàn cục của bạn
  final Dio _dio = dioClient;

  /// Gọi API Đăng ký
  Future<Response> register(String email, String password, String name) async {
    try {
      return await _dio.post(
        '/auth/register',
        data: {'email': email, 'password': password, 'name': name},
      );
    } catch (e) {
      rethrow;
    }
  }

  /// Gọi API Đăng nhập
  Future<Response> login(String email, String password) async {
    try {
      return await _dio.post(
        '/auth/login',
        data: {'email': email, 'password': password},
      );
    } catch (e) {
      rethrow;
    }
  }

  /// Gọi API Cập nhật hồ sơ
  Future<Response> updateProfile(String name, String? avatarUrl) async {
    try {
      return await _dio.post(
        '/auth/update-profile',
        data: {'name': name, 'avatar': ?avatarUrl},
      );
    } catch (e) {
      rethrow;
    }
  }
}

final authRepositoryProvider = Provider<AuthRepository>((ref) {
  return AuthRepository();
});
