import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:moment_u_payment/core/providers/currency_provider.dart';
import 'package:moment_u_payment/core/services/notification_service.dart';
import 'package:moment_u_payment/features/auth/auth_checker.dart';
import 'package:moment_u_payment/firebase_options.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'core/constants/app_colors.dart';
import 'core/providers/locale_provider.dart';
import 'features/auth/presentation/screens/login_screen.dart';
import 'l10n/app_localizations.dart';

void main() async {
  // Đảm bảo các dịch vụ nền của Flutter được khởi tạo hoàn chỉnh trước khi nạp file cấu hình
  WidgetsFlutterBinding.ensureInitialized();
  // await Firebase.initializeApp(); // Khởi tạo Firebase trước
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  await NotificationService.initNotifications();

  // Nạp file cấu hình môi trường chứa IP máy Mac hoặc link Render
  await dotenv.load(fileName: ".env");

  // Khởi tạo SharedPreferences sớm ngay khi app bật lên
  final prefs = await SharedPreferences.getInstance();

  runApp(
    ProviderScope(
      overrides: [
        // Bơm thực thể SharedPreferences vào hệ thống Riverpod
        sharedPreferencesProvider.overrideWithValue(prefs),
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends ConsumerWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Lắng nghe trạng thái ngôn ngữ thay đổi trực tiếp từ Riverpod
    final currentLocale = ref.watch(localeProvider);

    return MaterialApp(
      title: 'Moment u Payment',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        scaffoldBackgroundColor: AppColors.background,
        colorScheme: ColorScheme.fromSeed(
          seedColor: AppColors.primary,
          surface: AppColors.background,
        ),
      ),
      // Cấu hình đa ngôn ngữ hệ thống (l10n)
      localizationsDelegates: const [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: const [Locale('en'), Locale('vi')],

      // Cập nhật động theo provider khi gạt Switch ngôn ngữ
      locale: currentLocale,

      // 🔑 THAY ĐỔI CHI THUẬT: Chuyển từ LoginScreen() sang AuthChecker() làm màn hình gốc ban đầu
      home: const AuthChecker(),

      // BẢNG ĐIỀU HƯỚNG ROUTE: Giải quyết triệt để lỗi "Could not find a generator for route"
      routes: {'/login': (context) => const LoginScreen()},
    );
  }
}
