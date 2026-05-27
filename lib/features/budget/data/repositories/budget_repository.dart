// features/budget/data/repositories/budget_repository.dart
import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:moment_u_payment/core/utils/app_logger.dart';
import 'package:moment_u_payment/features/budget/data/models/budget_summary.dart';
import '../../../../core/network/api_client.dart'; // Import dioClient toàn cục vừa sửa

class BudgetRepository {
  final Dio _dio;

  BudgetRepository({Dio? dio})
    : _dio = dio ?? dioClient; // Tự động xài bản có Interceptor xịn

  /// 🎯 Giờ đây hàm gọi API ngắn gọn và tập trung hoàn toàn vào nghiệp vụ
  Future<double> updateBudgetLimit(double limit) async {
    try {
      // 🚀 Không cần lấy token, không cần bọc Options headers nữa! Interceptor đã lo hết.
      final response = await _dio.patch(
        '/users/budget',
        data: {'budgetLimit': limit},
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        final data = response.data;
        return (data['budgetLimit'] as num).toDouble();
      } else {
        throw DioException(
          requestOptions: response.requestOptions,
          response: response,
          type: DioExceptionType.badResponse,
        );
      }
    } on DioException catch (e) {
      AppLogger.e('BudgetRepository.updateBudgetLimit', e, e.stackTrace);
      if (e.response != null) {
        final statusCode = e.response!.statusCode;
        final serverMessage = e.response!.data?['message'];

        if (statusCode == 401)
          throw 'Phiên đăng nhập đã hết hạn, vui lòng đăng nhập lại nhen! 🔑';
        if (statusCode == 404) throw 'Không tìm thấy tài khoản! 😿';
        if (serverMessage != null) {
          throw serverMessage is List
              ? serverMessage.first.toString()
              : serverMessage.toString();
        }
      }
      throw 'Không kết nối được tới máy chủ rồi u là trời! 🌐';
    } catch (e) {
      throw 'Đã xảy ra sự cố không mong muốn rồi! 😿';
    }
  }

  Future<BudgetSummary> getBudgetSummary() async {
    try {
      final response = await _dio.get('/users/budget/summary');
      return BudgetSummary.fromJson(response.data);
    } catch (e) {
      throw Exception('Không thể tải thông tin tổng hợp ngân sách: $e');
    }
  }
}

final budgetRepositoryProvider = Provider<BudgetRepository>((ref) {
  return BudgetRepository();
});
