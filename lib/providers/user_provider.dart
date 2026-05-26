import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class UserProvider extends ChangeNotifier {
  final String _baseUrl = dotenv.env['API_BASE_URL'] ?? 'http://localhost:8001';
  final _secureStorage = const FlutterSecureStorage();

  String? _email;
  bool _isEmailVerified = false;
  bool _isLoadingResend = false;

  // Getters
  String? get email => _email;
  bool get isEmailVerified => _isEmailVerified;
  bool get isLoadingResend => _isLoadingResend;

  /// Cập nhật thông tin User sau khi Đăng ký / Đăng nhập thành công
  void setUser(String email, bool isEmailVerified) {
    _email = email;
    _isEmailVerified = isEmailVerified;
    notifyListeners(); // Báo cho các UI đang nghe cập nhật giao diện
  }

  /// Gọi API kiểm tra lại trạng thái Email mới nhất từ Backend (Sync trạng thái)
  Future<void> checkEmailVerificationStatus() async {
    try {
      String? token = await _secureStorage.read(key: 'access_token');
      if (token == null) return;

      // Giả định bạn có 1 endpoint GET /auth/me hoặc GET /users/profile để lấy thông tin cá nhân hiện tại
      final url = Uri.parse('$_baseUrl/auth/me');
      final response = await http.get(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        // Cập nhật lại trạng thái verified từ DB
        _isEmailVerified = data['user']['isEmailVerified'] ?? false;
        notifyListeners();
      }
    } catch (e) {
      print('❌ Lỗi khi đồng bộ trạng thái Email: $e');
    }
  }

  /// Gọi API yêu cầu Resend gửi lại mail kích hoạt
  Future<bool> resendVerificationEmail() async {
    if (_email == null) return false;

    _isLoadingResend = true;
    notifyListeners();

    try {
      final url = Uri.parse('$_baseUrl/auth/resend-verification');
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'email': _email}),
      );

      _isLoadingResend = false;
      notifyListeners();

      if (response.statusCode == 201 || response.statusCode == 200) {
        return true;
      }
      return false;
    } catch (e) {
      _isLoadingResend = false;
      notifyListeners();
      return false;
    }
  }
}
