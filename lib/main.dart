import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import '../../../../l10n/app_localizations.dart';
import 'core/constants/app_colors.dart';
import 'core/providers/locale_provider.dart'; // 🌸 THÊM IMPORT NÀY (Đường dẫn tới file locale_provider của bạn)
import 'features/auth/presentation/screens/login_screen.dart';

void main() async {
  // Đảm bảo các dịch vụ nền của Flutter được khởi tạo hoàn chỉnh trước khi nạp file cấu hình
  WidgetsFlutterBinding.ensureInitialized();

  // Nạp file cấu hình môi trường chứa IP máy Mac hoặc link Render
  await dotenv.load(fileName: ".env");

  runApp(const ProviderScope(child: MyApp()));
}

// 🌸 ĐÃ SỬA: Chuyển từ StatelessWidget sang ConsumerWidget để dùng được 'WidgetRef ref'
class MyApp extends ConsumerWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // 🌸 ĐÃ SỬA: Lắng nghe trạng thái ngôn ngữ thay đổi trực tiếp từ Riverpod
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

      // 🌸 ĐÃ SỬA: Không gán cứng nữa mà cập nhật động theo provider khi gạt Switch
      locale: currentLocale,

      // Màn hình khởi chạy ban đầu mặc định là Login
      home: const LoginScreen(),

      // 🌸 THÊM BẢNG ĐIỀU HƯỚNG ROUTE: Giải quyết triệt để lỗi "Could not find a generator for route"
      routes: {
        '/login': (context) => const LoginScreen(),
        // Nếu sau này bạn có HomeScreen, hãy bổ sung thêm một dòng ở đây:
        // '/home': (context) => const HomeScreen(),
      },
    );
  }
}
