import 'package:dio/dio.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

final dioClient = Dio(
  BaseOptions(
    baseUrl: dotenv.env['API_BASE_URL'] ?? 'http://192.168.13.125:8001/',
    connectTimeout: const Duration(seconds: 5),
    receiveTimeout: const Duration(seconds: 3),
  ),
);
