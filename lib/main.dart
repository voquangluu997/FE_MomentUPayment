import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_native_splash/flutter_native_splash.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:moment_u_payment/core/features/badges/screens/badge_gallery_page.dart';
import 'package:moment_u_payment/core/providers/currency_provider.dart';
import 'package:moment_u_payment/core/screens/main_layout_screen.dart';
import 'package:moment_u_payment/core/services/notification_service.dart';
import 'package:moment_u_payment/core/theme/app_theme.dart';
import 'package:moment_u_payment/core/utils/app_logger.dart';
import 'package:moment_u_payment/features/auth/auth_checker.dart';
import 'package:moment_u_payment/features/budget/presentation/screens/set_budget_screen.dart';
import 'package:moment_u_payment/features/splash/presentation/screens/splash_screen.dart';
import 'package:moment_u_payment/features/onboarding/presentation/onboarding_screen.dart';
import 'package:moment_u_payment/features/transaction/presentation/screens/add_transaction_screen.dart';
import 'package:moment_u_payment/features/transaction/presentation/screens/analytics_screen.dart';
import 'package:moment_u_payment/firebase_options.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'core/constants/app_colors.dart';
import 'core/providers/locale_provider.dart';
import 'package:moment_u_payment/core/providers/theme_provider.dart';

import 'features/auth/presentation/screens/login_screen.dart';
import 'l10n/app_localizations.dart';

final rootScaffoldMessengerKey = GlobalKey<ScaffoldMessengerState>();

void main() async {
  // 1. Đảm bảo Flutter bindings được khởi tạo trước
  WidgetsBinding widgetsBinding = WidgetsFlutterBinding.ensureInitialized();

  // 2. Giữ màn hình Splash Native không bị tắt sớm
  FlutterNativeSplash.preserve(widgetsBinding: widgetsBinding);

  // 3. Tải biến môi trường an toàn
  try {
    await dotenv.load(fileName: '.env');
  } catch (e) {
    AppLogger.i('i', '⚠️ Không tìm thấy hoặc lỗi load file .env: $e');
  }

  // 4. Khởi tạo Firebase an toàn
  try {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
  } catch (e) {
    AppLogger.e('e', '⚠️ Firebase initialization error: $e');
  }

  // 5. Khởi tạo dịch vụ thông báo
  try {
    await NotificationService.initNotifications();
  } catch (e) {
    AppLogger.e('e', '⚠️ Notification init error: $e');
  }

  // 6. Khởi tạo SharedPreferences cho Riverpod
  final prefs = await SharedPreferences.getInstance();

  // 👇 Đọc trạng thái xem user đã xem Onboarding chưa
  // final hasSeenOnboarding = prefs.getBool('has_seen_onboarding') ?? false;
  final hasSeenOnboarding = false;

  // 7. Chạy ứng dụng
  runApp(
    ProviderScope(
      overrides: [sharedPreferencesProvider.overrideWithValue(prefs)],
      child: MyApp(hasSeenOnboarding: hasSeenOnboarding),
    ),
  );
}

class MyApp extends ConsumerWidget {
  final bool hasSeenOnboarding;

  const MyApp({super.key, required this.hasSeenOnboarding});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Lắng nghe ngôn ngữ
    final currentLocale = ref.watch(localeProvider);

    // 🌟 ĐĂNG KÝ LẮNG NGHE BỘ MÀU VÀ CHẾ ĐỘ SÁNG TỐI
    final appColors = ref.watch(appColorsProvider);
    final themeMode = ref.watch(themeModeProvider);

    return MaterialApp(
      title: 'Moments U Payment',
      debugShowCheckedModeBanner: false,
      scaffoldMessengerKey: rootScaffoldMessengerKey,

      // 🌟 KÍCH HOẠT APP THEME (Tích hợp Font chữ thời thượng & Tự động Sáng/Tối)
      themeMode: themeMode,
      theme: AppTheme.buildTheme(appColors, false), // Giao diện Light Mode
      darkTheme: AppTheme.buildTheme(appColors, true), // Giao diện Dark Mode

      localizationsDelegates: const [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: const [Locale('en'), Locale('vi')],
      locale: currentLocale,

      home: SplashScreen(hasSeenOnboarding: hasSeenOnboarding),

      routes: {
        '/onboarding': (context) => const OnboardingScreen(),
        '/login': (context) => const LoginScreen(),
        '/auth_check': (context) => const AuthChecker(),
        '/main': (context) => const MainLayoutScreen(),
        '/badge_gallery': (context) => const BadgeGalleryPage(),
        '/budget_analytics': (context) => const AnalyticsScreen(),
        '/create_transaction': (context) => const AddTransactionScreen(),
        '/budget_settings': (context) => const SetBudgetScreen(),
      },
    );
  }
}
