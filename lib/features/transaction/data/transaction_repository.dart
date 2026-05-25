import 'dart:io';
import 'package:dio/dio.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart'; // ✨ THÊM: Thư viện phục vụ Provider toàn cục
import '../../../core/utils/app_logger.dart';

class TransactionRepository {
  final Dio _dio;

  // Khởi tạo và nạp tự động Base URL từ khóa cấu hình nội bộ API_BASE_URL trong file .env
  TransactionRepository({Dio? dio})
    : _dio =
          dio ??
          Dio(
            BaseOptions(
              baseUrl:
                  dotenv.env['API_BASE_URL'] ?? 'http://192.168.13.125:8001/',
              connectTimeout: const Duration(seconds: 10),
              receiveTimeout: const Duration(seconds: 10),
            ),
          );

  /// 🔥 BƯỚC 1: Hàm upload ảnh hóa đơn / chứng từ lên Server
  Future<String> uploadInvoiceImage(String localImagePath) async {
    try {
      // 1. Lấy Access Token đã lưu từ SharedPreferences để chứng minh danh tính
      final prefs = await SharedPreferences.getInstance();
      final String? token = prefs.getString('access_token');

      if (token == null || token.isEmpty) {
        throw Exception("401 - Chưa đăng nhập hoặc mất token rồi!");
      }

      // 2. Chuẩn bị file từ đường dẫn local trên iPhone
      File file = File(localImagePath);
      String fileName = localImagePath.split('/').last;

      // 3. Đóng gói dữ liệu dạng FormData
      FormData formData = FormData.fromMap({
        'file': await MultipartFile.fromFile(file.path, filename: fileName),
      });

      // 4. Bắn Request kèm Header Authorization
      final response = await _dio.post(
        '/upload', // Endpoint xử lý upload file trên NestJS
        data: formData,
        options: Options(headers: {'Authorization': 'Bearer $token'}),
      );

      // Nhận về chuỗi URL ảnh từ server sau khi upload thành công
      if (response.statusCode == 200 || response.statusCode == 201) {
        return response.data['url'] as String;
      } else {
        throw Exception("Upload thất bại với status: ${response.statusCode}");
      }
    } on DioException catch (e) {
      AppLogger.e('TransactionRepo.upload', e, e.stackTrace);
      rethrow;
    }
  }

  /// 🔥 BƯỚC 2: Tạo giao dịch chính thức (Lưu thông tin vào Database)
  Future<void> createTransaction({
    required double amount,
    required String category,
    String? note,
    String? imageUrl,
    String? emoji,
  }) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final String? token = prefs.getString('access_token');

      if (token == null || token.isEmpty) {
        throw Exception("401 - Chưa đăng nhập hoặc mất token quyền truy cập!");
      }

      // Gửi toàn bộ thông tin văn bản + URL ảnh đã có từ Bước 1 lên DB
      final response = await _dio.post(
        '/transactions',
        data: {
          'amount': amount,
          'category': category,
          'note': note,
          'imageUrl': imageUrl, // Chuỗi string text, không phải file nữa
          'emoji': emoji,
        },
        options: Options(
          headers: {
            'Authorization': 'Bearer $token',
            'Content-Type': 'application/json',
          },
        ),
      );

      if (response.statusCode != 200 && response.statusCode != 201) {
        throw Exception("Không thể tạo transaction");
      }
    } on DioException catch (e) {
      AppLogger.e('TransactionRepo.create', e, e.stackTrace);
      rethrow;
    }
  }

  /// 🔥 BƯỚC 3: Lấy danh sách lịch sử giao dịch động (Đồng bộ Token & Logging)
  Future<List<Map<String, dynamic>>> getTransactions() async {
    try {
      // 1. Lấy token để xác thực người dùng hiện tại
      final prefs = await SharedPreferences.getInstance();
      final String? token = prefs.getString('access_token');

      if (token == null || token.isEmpty) {
        throw Exception("401 - Chưa đăng nhập hoặc phiên làm việc đã hết hạn!");
      }

      // 2. Gửi request GET kèm token bảo mật lên endpoint NestJS
      final response = await _dio.get(
        '/transactions',
        options: Options(headers: {'Authorization': 'Bearer $token'}),
      );

      // 3. Ép kiểu dữ liệu trả về từ Backend thành List<Map<String, dynamic>>
      if (response.statusCode == 200) {
        final List<dynamic> data = response.data;
        return data.map((e) => e as Map<String, dynamic>).toList();
      } else {
        throw Exception(
          'Failed to load transactions with status: ${response.statusCode}',
        );
      }
    } on DioException catch (e) {
      // Ghi nhận lỗi mạng hoặc lỗi API đồng bộ qua AppLogger để dễ debug log
      AppLogger.e('TransactionRepo.getTransactions', e, e.stackTrace);
      rethrow;
    }
  }

  Future<void> deleteTransaction(String id) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final String? token = prefs.getString('access_token');

      if (token == null || token.isEmpty) {
        throw Exception("401 - Chưa đăng nhập hoặc phiên làm việc đã hết hạn!");
      }

      // Gửi request DELETE tới endpoint /transactions/:id
      final response = await _dio.delete(
        '/transactions/$id',
        options: Options(headers: {'Authorization': 'Bearer $token'}),
      );

      if (response.statusCode != 200 && response.statusCode != 201) {
        throw Exception("Xóa giao dịch thất bại từ phía Server");
      }
    } on DioException catch (e) {
      AppLogger.e('TransactionRepo.deleteTransaction', e, e.stackTrace);
      rethrow;
    }
  }
}

// ✨ THÊM KHAI BÁO PROVIDER TOÀN CỤC CHO REPOSITORY:
final transactionRepositoryProvider = Provider<TransactionRepository>((ref) {
  return TransactionRepository();
});
