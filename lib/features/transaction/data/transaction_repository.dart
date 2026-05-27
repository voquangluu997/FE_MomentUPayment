import 'dart:io';
import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/utils/app_logger.dart';

class TransactionRepository {
  final Dio _dio;
  final _secureStorage = const FlutterSecureStorage();

  TransactionRepository({Dio? dio})
    : _dio =
          dio ??
          Dio(
            BaseOptions(
              baseUrl:
                  dotenv.env['API_BASE_URL'] ?? 'http://192.168.13.125:8001',
              connectTimeout: const Duration(seconds: 10),
              receiveTimeout: const Duration(seconds: 10),
            ),
          );

  Future<String?> _getAuthToken() async {
    return await _secureStorage.read(key: 'access_token');
  }

  /// 🔥 BƯỚC 1: Hàm upload ảnh hóa đơn / chứng từ lên Server
  Future<String> uploadInvoiceImage(String localImagePath) async {
    try {
      final String? token = await _getAuthToken();
      if (token == null || token.isEmpty) {
        throw Exception("401 - Chưa đăng nhập hoặc mất token rồi!");
      }

      File file = File(localImagePath);
      String fileName = localImagePath.split('/').last;

      FormData formData = FormData.fromMap({
        'file': await MultipartFile.fromFile(file.path, filename: fileName),
      });

      final response = await _dio.post(
        '/upload',
        data: formData,
        options: Options(headers: {'Authorization': 'Bearer $token'}),
      );

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
      final String? token = await _getAuthToken();
      if (token == null || token.isEmpty) {
        throw Exception("401 - Chưa đăng nhập hoặc mất token quyền truy cập!");
      }

      final response = await _dio.post(
        '/transactions',
        data: {
          'amount': amount,
          'category': category,
          'note': note,
          'imageUrl': imageUrl,
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

  /// 🔥 BƯỚC 3: Cập nhật thông tin giao dịch (Sửa đổi / Update)
  Future<void> updateTransaction({
    required String id,
    required double amount,
    required String category,
    String? note,
    String? imageUrl,
    String? emoji,
  }) async {
    try {
      final String? token = await _getAuthToken();
      if (token == null || token.isEmpty) {
        throw Exception("401 - Chưa đăng nhập hoặc phiên làm việc đã hết hạn!");
      }

      // Gửi request PUT lên route /transactions/:id của NestJS
      final response = await _dio.put(
        '/transactions/$id',
        data: {
          'amount': amount,
          'category': category,
          'note': note,
          if (imageUrl != null)
            'imageUrl':
                imageUrl, // Chỉ đè link ảnh nếu có upload ảnh mới thành công
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
        throw Exception("Cập nhật giao dịch thất bại từ phía Server!");
      }
    } on DioException catch (e) {
      AppLogger.e('TransactionRepo.updateTransaction', e, e.stackTrace);
      rethrow;
    }
  }

  /// 🔥 BƯỚC 4: Lấy danh sách lịch sử giao dịch động (Lazy Load)
  Future<List<Map<String, dynamic>>> getTransactions({
    required int page,
    required int limit,
  }) async {
    try {
      final String? token = await _getAuthToken();
      if (token == null || token.isEmpty) {
        throw Exception("401 - Chưa đăng nhập hoặc phiên làm việc đã hết hạn!");
      }

      final response = await _dio.get(
        '/transactions',
        queryParameters: {'page': page, 'limit': limit},
        options: Options(headers: {'Authorization': 'Bearer $token'}),
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = response.data;
        return data.map((e) => e as Map<String, dynamic>).toList();
      } else {
        throw Exception(
          'Failed to load transactions with status: ${response.statusCode}',
        );
      }
    } on DioException catch (e) {
      AppLogger.e('TransactionRepo.getTransactions', e, e.stackTrace);
      rethrow;
    }
  }

  /// 🔥 BƯỚC 5: Xóa giao dịch
  Future<void> deleteTransaction(String id) async {
    try {
      final String? token = await _getAuthToken();
      if (token == null || token.isEmpty) {
        throw Exception("401 - Chưa đăng nhập hoặc phiên làm việc đã hết hạn!");
      }

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

  /// 📊 BƯỚC 6: Lấy dữ liệu thống kê chi tiêu theo danh mục
  Future<List<Map<String, dynamic>>> getTransactionAnalytics() async {
    try {
      final String? token = await _getAuthToken();
      if (token == null || token.isEmpty) {
        throw Exception("401 - Chưa đăng nhập hoặc phiên làm việc đã hết hạn!");
      }

      final response = await _dio.get(
        '/transactions/analytics',
        options: Options(headers: {'Authorization': 'Bearer $token'}),
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = response.data;
        return data.map((item) => Map<String, dynamic>.from(item)).toList();
      } else {
        throw Exception("Không thể lấy dữ liệu phân tích từ Server");
      }
    } on DioException catch (e) {
      AppLogger.e(
        'TransactionRepository.getTransactionAnalytics',
        e,
        e.stackTrace,
      );
      rethrow;
    }
  }
}

final transactionRepositoryProvider = Provider<TransactionRepository>((ref) {
  return TransactionRepository();
});
