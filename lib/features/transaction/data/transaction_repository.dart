// features/transaction/data/transaction_repository.dart
import 'dart:io';
import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:moment_u_payment/core/utils/datetime_helper.dart';
import 'package:moment_u_payment/core/widgets/analytics_components.dart';
import '../../../core/network/api_client.dart';
import '../../../core/utils/app_logger.dart';

class TransactionRepository {
  final Dio _dio;

  // Constructor tinh gọn: Mặc định xài luôn dioClient có interceptor của hệ thống
  TransactionRepository({Dio? dio}) : _dio = dio ?? dioClient;

  /// 🔥 BƯỚC 1: Hàm upload ảnh hóa đơn / chứng từ lên Server
  Future<String> uploadInvoiceImage(String localImagePath) async {
    try {
      File file = File(localImagePath);
      String fileName = localImagePath.split('/').last;

      FormData formData = FormData.fromMap({
        'file': await MultipartFile.fromFile(file.path, filename: fileName),
      });

      // 🚀 Interceptor tự động chèn Token Bearer vào đây
      final response = await _dio.post('/upload', data: formData);

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

  /// 🧹 BƯỚC MỚI: Xóa ảnh rác trên Cloudinary khi người dùng Hủy
  Future<void> deleteImage(String imageUrl) async {
    try {
      // Gọi lên backend để xóa ảnh (Giả định backend của bạn cấu hình DELETE /upload)
      final response = await _dio.delete(
        '/upload',
        data: {
          'imageUrl': imageUrl, // Truyền URL của ảnh cần xóa vào body
        },
      );

      if (response.statusCode != 200 && response.statusCode != 201) {
        throw Exception(
          "Xóa ảnh rác thất bại với status: ${response.statusCode}",
        );
      }

      AppLogger.i(
        'TransactionRepo.deleteImage',
        'Đã dọn dẹp thành công ảnh rác $imageUrl',
      );
    } on DioException catch (e) {
      AppLogger.e('TransactionRepo.deleteImage', e, e.stackTrace);
      // Cố ý KHÔNG rethrow lỗi ở đây để tránh làm gián đoạn luồng đóng giao diện của người dùng
    }
  }

  /// 🔥 BƯỚC 2: Tạo giao dịch chính thức (Lưu thông tin vào Database)
  Future<void> createTransaction({
    required double amount,
    required String category,
    String? note,
    String? imageUrl,
    String? emoji,
    DateTime? spentAt, // ✨ Đã thêm tham số
  }) async {
    try {
      final response = await _dio.post(
        '/transactions',
        data: {
          'amount': amount,
          'category': category,
          'note': note,
          'imageUrl': imageUrl,
          'emoji': emoji,
          // ✨ Gửi ngày lên server (mặc định hiện tại nếu null)
          'spentAt': (spentAt ?? DateTime.now()).toIso8601String(),
        },
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
    DateTime? spentAt, // ✨ Đã thêm tham số
  }) async {
    try {
      final response = await _dio.put(
        '/transactions/$id',
        data: {
          'amount': amount,
          'category': category,
          'note': note,
          if (imageUrl != null) 'imageUrl': imageUrl,
          'emoji': emoji,
          // ✨ Cập nhật ngày nếu được cung cấp
          if (spentAt != null) 'spentAt': spentAt.toIso8601String(),
        },
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
      final response = await _dio.get(
        '/transactions',
        queryParameters: {'page': page, 'limit': limit},
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
      final response = await _dio.delete('/transactions/$id');

      if (response.statusCode != 200 && response.statusCode != 201) {
        throw Exception("Xóa giao dịch thất bại từ phía Server");
      }
    } on DioException catch (e) {
      AppLogger.e('TransactionRepo.deleteTransaction', e, e.stackTrace);
      rethrow;
    }
  }

  /// 📊 BƯỚC 6: LẤY DỮ LIỆU THỐNG KÊ CHI TIÊU
  /// ⚠️ Đã đổi kiểu trả về thành Map<String, dynamic> để đồng bộ với Backend mới
  Future<Map<String, dynamic>> getTransactionAnalytics({
    required DateTime startDate,
    required DateTime endDate,
  }) async {
    try {
      // 🚀 Sử dụng Helper để lấy timezone chuẩn xác
      final String timezoneParam = DateTimeHelper.getTimezoneOffsetString();

      final response = await _dio.get(
        '/transactions/analytics',
        queryParameters: {
          // Ép chuỗi ISO8601 để giữ nguyên thông tin giờ phút giây
          'startDate': startDate.toIso8601String(),
          'endDate': endDate.toIso8601String(),
          // Gửi thêm Múi giờ để DB của backend Group By không bị lệch ngày
          'timezone': timezoneParam,
        },
      );

      if (response.statusCode == 200) {
        // Backend mới trả về một Object chứa { categories, biggestSplurges, diaryInsight }
        return response.data as Map<String, dynamic>;
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

  // Thêm hàm này vào class TransactionRepository của bạn
Future<List<SplurgeInfo>> getAllSplurges({
  required DateTime startDate,
  required DateTime endDate,
  int page = 1,
  int limit = 20,
}) async {
  try {
    // Thay đổi cú pháp tương ứng với HTTP client bạn đang dùng (Dio / http)
    final response = await _dio.get(
      '/transactions/splurges',
      queryParameters: {
        'startDate': startDate.toIso8601String(),
        'endDate': endDate.toIso8601String(),
        'page': page,
        'limit': limit,
      },
    );

    final List<dynamic> data = response.data; // Tuỳ cấu trúc response backend trả về
    return data.map((json) => SplurgeInfo.fromJson(json)).toList();
  } catch (e) {
    throw Exception('Lỗi khi tải danh sách splurges: $e');
  }
}
}

// Cung cấp instance của Repository thông qua Riverpod Provider
final transactionRepositoryProvider = Provider<TransactionRepository>((ref) {
  return TransactionRepository();
});
