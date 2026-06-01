// import 'package:flutter/material.dart';
// import 'package:flutter/rendering.dart';
// import 'package:flutter_riverpod/flutter_riverpod.dart';
// import 'package:moment_u_payment/core/constants/app_colors.dart';

// import 'package:moment_u_payment/features/home/presentation/screens/home_screen.dart';
// import 'package:moment_u_payment/features/transaction/presentation/screens/analytics_screen.dart';

// class MainLayoutScreen extends ConsumerStatefulWidget {
//   const MainLayoutScreen({super.key});

//   @override
//   ConsumerState<MainLayoutScreen> createState() => _MainLayoutScreenState();
// }

// class _MainLayoutScreenState extends ConsumerState<MainLayoutScreen> {
//   int _currentIndex = 0;
//   bool _isNavbarVisible = true; // Trạng thái ẩn/hiện của Thanh điều hướng

//   // Danh sách các màn hình chính trong App
//   final List<Widget> _screens = [
//     const HomeScreen(), // Index 0: Trang chủ (chứa HomeBudgetCard của bạn)
//     const AnalyticsScreen(), // Index 1: Phân tích chi tiêu
//     const Center(child: Text('Lịch sử')), // Index 2: Placeholder Lịch sử
//     const Center(child: Text('Cài đặt')), // Index 3: Placeholder Cài đặt
//   ];

//   @override
//   Widget build(BuildContext context) {
//     final appColors = ref.watch(appColorsProvider);

//     return Scaffold(
//       // LƯU Ý: extendBody = true giúp nội dung màn hình tràn xuống dưới BottomNav,
//       // khi ẩn thanh điều hướng đi sẽ không để lại khoảng trắng (vùng trống màu đen/trắng).
//       extendBody: true,

//       // 🟢 BỌC BODY TRONG NotificationListener để bắt sự kiện cuộn từ mọi màn hình con
//       body: NotificationListener<UserScrollNotification>(
//         onNotification: (notification) {
//           if (notification.direction == ScrollDirection.reverse) {
//             // Khi người dùng vuốt lên để cuộn xuống xem thêm dữ liệu -> ẨN thanh điều hướng
//             if (_isNavbarVisible) {
//               setState(() {
//                 _isNavbarVisible = false;
//               });
//             }
//           } else if (notification.direction == ScrollDirection.forward) {
//             // Khi người dùng vuốt xuống để cuộn ngược lên trên đầu -> HIỆN thanh điều hướng
//             if (!_isNavbarVisible) {
//               setState(() {
//                 _isNavbarVisible = true;
//               });
//             }
//           }
//           return true;
//         },
//         child: IndexedStack(index: _currentIndex, children: _screens),
//       ),

//       // 🛑 BOTTOM NAVIGATION BAR PHÁT SÁNG & CÓ HIỆU ỨNG TRƯỢT ẨN/HIỆN
//       bottomNavigationBar: AnimatedSlide(
//         duration: const Duration(milliseconds: 250),
//         curve: Curves.easeInOut,
//         // Nếu hiện tại: Offset(0,0) nằm đúng vị trí. Nếu ẩn: Offset(0, 2) đẩy tuột xuống dưới màn hình.
//         offset: _isNavbarVisible ? Offset.zero : const Offset(0, 2),
//         child: Container(
//           margin: const EdgeInsets.fromLTRB(
//             20,
//             0,
//             20,
//             24,
//           ), // Cách điệu dạng Floating bo góc lơ lửng
//           height: 68,
//           decoration: BoxDecoration(
//             color: appColors.cardBackground.withOpacity(
//               0.96,
//             ), // Hơi trong suốt nhẹ premium
//             borderRadius: BorderRadius.circular(24),
//             border: Border.all(
//               color: appColors.primary.withOpacity(0.08),
//               width: 1,
//             ),
//             boxShadow: [
//               BoxShadow(
//                 color: appColors.primaryDark.withOpacity(0.06),
//                 blurRadius: 20,
//                 offset: const Offset(0, -4),
//               ),
//             ],
//           ),
//           child: Row(
//             mainAxisAlignment: MainAxisAlignment.spaceAround,
//             children: [
//               _buildNavItem(
//                 index: 0,
//                 icon: Icons.wb_sunny_rounded,
//                 activeIcon: Icons.wb_sunny_rounded,
//                 label: 'Home',
//                 appColors: appColors,
//               ),
//               _buildNavItem(
//                 index: 1,
//                 icon: Icons.analytics_outlined,
//                 activeIcon: Icons.analytics_rounded,
//                 label: 'Thống kê',
//                 appColors: appColors,
//               ),
//               _buildNavItem(
//                 index: 2,
//                 icon: Icons.history_toggle_off_rounded,
//                 activeIcon: Icons.history_rounded,
//                 label: 'Lịch sử',
//                 appColors: appColors,
//               ),
//               _buildNavItem(
//                 index: 3,
//                 icon: Icons.person_outline_rounded,
//                 activeIcon: Icons.person_rounded,
//                 label: 'Cá nhân',
//                 appColors: appColors,
//               ),
//             ],
//           ),
//         ),
//       ),
//     );
//   }

//   // Widget dựng từng nút Item điều hướng tùy biến (Custom) cho đẹp và mượt hơn gốc
//   Widget _buildNavItem({
//     required int index,
//     required IconData icon,
//     required IconData activeIcon,
//     required String label,
//     required dynamic appColors,
//   }) {
//     final bool isSelected = _currentIndex == index;
//     final Color activeColor = appColors.primary;
//     final Color inactiveColor = appColors.primaryDark.withOpacity(0.4);

//     return InkWell(
//       onTap: () {
//         setState(() {
//           _currentIndex = index;
//         });
//       },
//       splashColor: Colors.transparent,
//       highlightColor: Colors.transparent,
//       child: AnimatedContainer(
//         duration: const Duration(milliseconds: 200),
//         padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
//         decoration: BoxDecoration(
//           color: isSelected
//               ? activeColor.withOpacity(0.08)
//               : Colors.transparent,
//           borderRadius: BorderRadius.circular(16),
//         ),
//         child: Row(
//           children: [
//             Icon(
//               isSelected ? activeIcon : icon,
//               color: isSelected ? activeColor : inactiveColor,
//               size: 24,
//             ),
//             if (isSelected) ...[
//               const SizedBox(width: 6),
//               Text(
//                 label,
//                 style: TextStyle(
//                   color: activeColor,
//                   fontSize: 12,
//                   fontWeight: FontWeight.w700,
//                 ),
//               ),
//             ],
//           ],
//         ),
//       ),
//     );
//   }
// }
