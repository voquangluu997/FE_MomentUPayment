import 'dart:math';
import 'package:moment_u_payment/core/features/badges/badge_model.dart';

class GamificationUtils {
  /// Lấy danh sách tất cả các huy hiệu được cấu hình trong hệ thống
  static List<UserBadge> get allBadges => BadgeRegistry.badges.values.toList();

  /// -------------------------------------------------------------------------
  /// [HÀM MỚI] TÍNH TOÁN % TIẾN ĐỘ CHO TẤT CẢ HUY HIỆU
  /// Trả về Map với Key là BadgeType, Value là double (0.0 -> 1.0 tương ứng 0% -> 100%)
  /// -------------------------------------------------------------------------
  static Map<BadgeType, double> calculateBadgeProgress(
    List<dynamic> allTimeData,
    List<dynamic> thisMonthData,
    double thisMonthTotalSpent, {
    String currencyCode = 'VND',
  }) {
    Map<BadgeType, double> progress = {};

    // Khởi tạo mặc định 0.0 cho tất cả badge
    for (var type in BadgeType.values) {
      progress[type] = 0.0;
    }

    final bool isVND = currencyCode.toUpperCase() == 'VND';
    final double whaleLimit = isVND ? 10000000 : 500;
    final double survivalLimit = isVND ? 2000000 : 100;
    final double bigTicketLimit = isVND ? 5000000 : 250;
    final double paydayLimit = isVND ? 1000000 : 200;

    final DateTime now = DateTime.now();

    // ============================================================================
    // 1. LOGIC THÀNH TỰU VĨNH VIỄN (ALL-TIME DATA)
    // ============================================================================

    // First Blood: Chỉ cần 1 giao dịch
    progress[BadgeType.firstBlood] = allTimeData.isNotEmpty ? 1.0 : 0.0;

    // Centurion: 100 giao dịch
    progress[BadgeType.centurion] = (allTimeData.length / 100).clamp(0.0, 1.0);

    // Ghost: Không thể hiện progress dần đều, chỉ có 0% hoặc 100%
    DateTime joinDate = now;
    int last30DaysCount = 0;
    DateTime thirtyDaysAgo = now.subtract(const Duration(days: 30));

    if (allTimeData.isNotEmpty) {
      for (var item in allTimeData) {
        if (item is! Map) continue;
        final tx = Map<String, dynamic>.from(item);
        final String timeString =
            tx['dateTime']?.toString() ??
            tx['date']?.toString() ??
            tx['created_at']?.toString() ??
            '';
        final DateTime? time = DateTime.tryParse(timeString);

        if (time != null) {
          if (time.isBefore(joinDate)) joinDate = time;
          if (time.isAfter(thirtyDaysAgo) &&
              time.isBefore(now.add(const Duration(days: 1)))) {
            last30DaysCount++;
          }
        }
      }
    }
    bool isOldUser = now.difference(joinDate).inDays >= 30;
    if (isOldUser && last30DaysCount < 10) {
      progress[BadgeType.ghost] = 1.0;
    }

    // ============================================================================
    // 2. LOGIC THEO THÁNG (MONTHLY DATA)
    // ============================================================================

    List<Map<String, dynamic>> validMonthlyData = [];
    for (var item in thisMonthData) {
      if (item is! Map) continue;
      final tx = Map<String, dynamic>.from(item);
      final String timeString =
          tx['dateTime']?.toString() ??
          tx['date']?.toString() ??
          tx['created_at']?.toString() ??
          '';
      final DateTime time = DateTime.tryParse(timeString) ?? now;

      if (time.year == now.year && time.month == now.month) {
        validMonthlyData.add(tx);
      }
    }

    int count = validMonthlyData.length;
    int foodCount = 0;
    int smallTxCount = 0;
    int backdateCount = 0;

    // Các biến theo dõi cho tiến độ đặc biệt
    double maxSingleAmount = 0.0;
    double maxPaydayAmount = 0.0;
    bool hasNightTx = false;
    bool hasWeekendTx = false;

    for (var tx in validMonthlyData) {
      final double amount =
          double.tryParse(tx['amount']?.toString() ?? '0') ?? 0.0;
      final String timeString =
          tx['dateTime']?.toString() ??
          tx['date']?.toString() ??
          tx['created_at']?.toString() ??
          '';
      final DateTime time = DateTime.tryParse(timeString) ?? now;
      final String category =
          tx['category']?.toString() ?? tx['category_id']?.toString() ?? '';
      final dynamic backdateRaw = tx['isBackdated'] ?? tx['is_backdated'];
      final bool isBackdated =
          backdateRaw == true || backdateRaw == 1 || backdateRaw == 'true';

      // Cập nhật Max Amount cho Big Ticket
      if (amount > maxSingleAmount) maxSingleAmount = amount;

      // Cập nhật Max Amount cho Payday Flash
      if (time.day >= 1 && time.day <= 5) {
        if (amount > maxPaydayAmount) maxPaydayAmount = amount;
      }

      // Check Night & Weekend
      if (time.hour >= 0 && time.hour < 4) hasNightTx = true;
      if (time.weekday == DateTime.saturday || time.weekday == DateTime.sunday) {
        hasWeekendTx = true;
      }

      // Đếm số liệu
      if (category.toLowerCase().contains('food') ||
          category.toLowerCase().contains('ăn uống')) {
        foodCount++;
      }
      if (amount < (isVND ? 10000 : 0.5)) smallTxCount++;
      if (isBackdated) backdateCount++;
    }

    // --- CẬP NHẬT TIẾN ĐỘ VÀO MAP ---

    // NHÓM A: Độc lập
    progress[BadgeType.bigTicket] = (maxSingleAmount / bigTicketLimit).clamp(
      0.0,
      1.0,
    );
    progress[BadgeType.paydayFlash] = (maxPaydayAmount / paydayLimit).clamp(
      0.0,
      1.0,
    );

    // NHÓM B: Cần >= 10 giao dịch
    // Nếu có giao dịch đêm/cuối tuần, tiến độ phụ thuộc vào việc họ có đủ 10 đơn chưa
    progress[BadgeType.nightOwl] = hasNightTx
        ? (count / 10).clamp(0.0, 1.0)
        : 0.0;
    progress[BadgeType.weekendStorm] = hasWeekendTx
        ? (count / 10).clamp(0.0, 1.0)
        : 0.0;

    progress[BadgeType.shopaholic] = (count / 40).clamp(0.0, 1.0);
    progress[BadgeType.whale] = (thisMonthTotalSpent / whaleLimit).clamp(
      0.0,
      1.0,
    );

    // Survivalist: Chỉ tính tiến độ khi tổng tiêu <= mốc sinh tồn
    progress[BadgeType.survivalist] = (thisMonthTotalSpent <= survivalLimit)
        ? (count / 10).clamp(0.0, 1.0)
        : 0.0;

    // Food Destroyer: Số lượng món ăn phải > 50% tổng đơn (Tối thiểu 6 đơn ăn / 10 tổng đơn)
    double targetFood = max(6.0, (count * 0.5).floor() + 1.0);
    progress[BadgeType.foodDestroyer] = (foodCount / targetFood).clamp(
      0.0,
      1.0,
    );

    // Broke AF: Cần > 10 đơn nhỏ (tức là 11)
    progress[BadgeType.brokeAF] = (smallTxCount / 11).clamp(0.0, 1.0);

    // Goldfish: Cần 5 đơn backdate
    progress[BadgeType.goldfish] = (backdateCount / 5).clamp(0.0, 1.0);

    // Balanced
    final double balancedUpperLimit = isVND ? 7000000 : 350;
    if (thisMonthTotalSpent > survivalLimit &&
        thisMonthTotalSpent <= balancedUpperLimit &&
        foodCount <= (count * 0.35)) {
      progress[BadgeType.balanced] = (count / 10).clamp(0.0, 1.0);
    }

    return progress;
  }

  /// -------------------------------------------------------------------------
  /// [HÀM CŨ ĐƯỢC GIỮ LẠI] Đảm bảo ứng dụng không bị lỗi ở các Provider khác
  /// Tự động lấy danh sách huy hiệu từ hàm calculateBadgeProgress có giá trị == 1.0
  /// -------------------------------------------------------------------------
  static List<BadgeType> calculateBadges(
    List<dynamic> allTimeData,
    List<dynamic> thisMonthData,
    double thisMonthTotalSpent, {
    String currencyCode = 'VND',
  }) {
    final progressMap = calculateBadgeProgress(
      allTimeData,
      thisMonthData,
      thisMonthTotalSpent,
      currencyCode: currencyCode,
    );

    // Lọc ra các huy hiệu đã đạt 100% (1.0)
    return progressMap.entries
        .where((entry) => entry.value >= 1.0)
        .map((entry) => entry.key)
        .toList();
  }
}
