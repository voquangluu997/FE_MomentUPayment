import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart'; // ✨ Bổ sung import thư viện dotenv để không bị lỗi build
import '../../../../l10n/app_localizations.dart'; // ✨ Cấu hình lại đường dẫn l10n tự động sinh chuẩn của Flutter
import 'core/constants/app_colors.dart';
import 'features/auth/presentation/screens/login_screen.dart';

void main() async {
  // Đảm bảo các dịch vụ nền của Flutter được khởi tạo hoàn chỉnh trước khi nạp file cấu hình
  WidgetsFlutterBinding.ensureInitialized();
  
  // ✨ Nạp file cấu hình môi trường chứa IP máy Mac hoặc link Render
  await dotenv.load(fileName: ".env");
  
  runApp(
    const ProviderScope(
      child: MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Moment u Payment',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        scaffoldBackgroundColor: AppColors.background,
        colorScheme: ColorScheme.fromSeed(
          seedColor: AppColors.primary,
          // Sửa deprecated 'background' sang 'surface' theo chuẩn Material 3 mới nhất
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
      supportedLocales: const [
        Locale('en'), 
        Locale('vi'),
      ],
      // Mặc định ép ứng dụng chạy tiếng Việt, bạn có thể đổi thành null để tự động nhận diện theo máy
      locale: const Locale('vi'), 
      home: const LoginScreen(),
    );
  }
}