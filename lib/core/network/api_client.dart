// core/network/api_client.dart
import 'package:dio/dio.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

// 🔑 Dùng biến private để lưu instance ẩn
Dio? _dioInstance;

// 🚀 Chuyển thành GETTER để ép ứng dụng chạy Lazy Loading chống lỗi chu kỳ Dotenv
Dio get dioClient {
  _dioInstance ??= _initDioClient();
  return _dioInstance!;
}

Dio _initDioClient() {
  // 🧼 XÓA DẤU / Ở CUỐI: Đảm bảo không bị lỗi gộp chuỗi thành // bẻ gãy endpoint
  final String baseUrl =
      dotenv.env['API_BASE_URL'] ?? 'http://192.168.13.125:8001';

  final dio = Dio(
    BaseOptions(
      baseUrl: baseUrl,
      connectTimeout: const Duration(
        seconds: 10,
      ), // Tăng lên 10s cho kết nối ổn định
      receiveTimeout: const Duration(seconds: 10),
    ),
  );

  // Thêm bộ lọc đánh chặn Interceptor tự động
  dio.interceptors.add(
    InterceptorsWrapper(
      onRequest: (options, handler) async {
        const secureStorage = FlutterSecureStorage();
        final String? token = await secureStorage.read(key: 'access_token');

        if (token != null && token.isNotEmpty) {
          options.headers['Authorization'] = 'Bearer $token';
        }

        options.headers['Content-Type'] = 'application/json';

        // Cho phép request tiếp tục truyền đi
        return handler.next(options);
      },
      onError: (DioException e, handler) {
        // Tiếp tục ném lỗi ra cho tầng Repository xử lý bắt chuỗi thông điệp
        return handler.next(e);
      },
    ),
  );

  return dio;
}
