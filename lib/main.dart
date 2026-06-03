import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_native_splash/flutter_native_splash.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:moment_u_payment/core/providers/currency_provider.dart';
import 'package:moment_u_payment/core/services/notification_service.dart';
import 'package:moment_u_payment/features/auth/auth_checker.dart';
import 'package:moment_u_payment/features/splash/presentation/screens/splash_screen.dart';
import 'package:moment_u_payment/firebase_options.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'core/constants/app_colors.dart';
import 'core/providers/locale_provider.dart';
import 'features/auth/presentation/screens/login_screen.dart';
import 'l10n/app_localizations.dart';

final rootScaffoldMessengerKey = GlobalKey<ScaffoldMessengerState>();

void main() async {
  // 1. Đảm bảo Flutter bindings được khởi tạo trước
  WidgetsBinding widgetsBinding = WidgetsFlutterBinding.ensureInitialized();

  // 2. Giữ màn hình Splash Native không bị tắt sớm trong lúc chờ init hệ thống
  FlutterNativeSplash.preserve(widgetsBinding: widgetsBinding);

  // 3. Tải biến môi trường an toàn (Tránh Crash Isolate nếu thiếu file)
  try {
    await dotenv.load(fileName: '.env');
  } catch (e) {
    debugPrint('⚠️ Không tìm thấy hoặc lỗi load file .env: $e');
  }

  // 4. Khởi tạo Firebase an toàn
  try {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
  } catch (e) {
    debugPrint('⚠️ Firebase initialization error: $e');
  }

  // 5. Khởi tạo dịch vụ thông báo
  try {
    await NotificationService.initNotifications();
  } catch (e) {
    debugPrint('⚠️ Notification init error: $e');
  }

  // 6. Khởi tạo SharedPreferences cho Riverpod
  final prefs = await SharedPreferences.getInstance();

  // 7. Chạy ứng dụng
  runApp(
    ProviderScope(
      // Bơm instance của prefs vào Riverpod để các chỗ khác có thể lấy dùng ngay lập tức
      overrides: [sharedPreferencesProvider.overrideWithValue(prefs)],
      child: const MyApp(),
    ),
  );
}

class MyApp extends ConsumerWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentLocale = ref.watch(localeProvider);

    return MaterialApp(
      title: 'Moments U Payment',
      debugShowCheckedModeBanner: false,
      scaffoldMessengerKey: rootScaffoldMessengerKey,

      theme: ThemeData(
        useMaterial3: true,
        scaffoldBackgroundColor: AppColors.background,
        colorScheme: ColorScheme.fromSeed(
          seedColor: AppColors.primary,
          surface: AppColors.background,
        ),
      ),
      localizationsDelegates: const [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: const [Locale('en'), Locale('vi')],
      locale: currentLocale,

      // 🟢 Điểm chạm đầu tiên: Gọi SplashScreen để chạy hiệu ứng intro ban đầu khi mở app
      home: const SplashScreen(),

      routes: {
        '/login': (context) => const LoginScreen(),
        '/auth_check': (context) => const AuthChecker(),
      },
    );
  }
}
