import 'dart:convert';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

import 'package:moment_u_payment/core/features/badges/badge_model.dart';
import 'package:moment_u_payment/core/utils/app_logger.dart';
import 'package:moment_u_payment/core/utils/gamification_utils.dart';

// ============================================================================
// --- MODEL TRẠNG THÁI (BADGE STATE) ---
// ============================================================================
class BadgeState {
  final List<BadgeType> unlockedBadges;
  final List<BadgeType>
  newlyUnlocked; // 🌟 Đã Đổi thành List để gom nhiều thành tựu cùng lúc
  final bool isLoading;

  BadgeState({
    this.unlockedBadges = const [],
    this.newlyUnlocked = const [], // Mặc định là mảng rỗng
    this.isLoading = false,
  });

  BadgeState copyWith({
    List<BadgeType>? unlockedBadges,
    List<BadgeType>? newlyUnlocked,
    bool? isLoading,
    bool clearNewlyUnlocked = false,
  }) {
    return BadgeState(
      unlockedBadges: unlockedBadges ?? this.unlockedBadges,
      newlyUnlocked: clearNewlyUnlocked
          ? const []
          : (newlyUnlocked ?? this.newlyUnlocked),
      isLoading: isLoading ?? this.isLoading,
    );
  }
}

// ============================================================================
// --- SERVICE ĐIỀU PHỐI (BADGE NOTIFIER) ---
// ============================================================================
class BadgeNotifier extends StateNotifier<BadgeState> {
  final _secureStorage = const FlutterSecureStorage();
  final String _baseUrl = dotenv.env['API_BASE_URL'] ?? 'http://localhost:8001';

  BadgeNotifier() : super(BadgeState()) {
    _loadBadgesFromBackend();
  }

  Future<void> _loadBadgesFromBackend() async {
    state = state.copyWith(isLoading: true);
    try {
      String? token = await _secureStorage.read(key: 'access_token');

      if (token == null) {
        state = state.copyWith(isLoading: false);
        return;
      }

      final response = await http
          .get(
            Uri.parse('$_baseUrl/badges'),
            headers: {
              'Content-Type': 'application/json',
              'Authorization': 'Bearer $token',
            },
          )
          .timeout(const Duration(seconds: 8));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final List<dynamic> badgeStrings = data['badges'] ?? [];

        final List<BadgeType> fetchedBadges = [];

        for (var nameStr in badgeStrings) {
          String name = nameStr.toString();

          if (name == 'budgetMaster') name = 'balanced';
          if (name == 'topSpender') name = 'whale';
          if (name == 'savingsKing') name = 'survivalist';

          try {
            final type = BadgeType.values.firstWhere((e) => e.name == name);
            fetchedBadges.add(type);
          } catch (e) {
            AppLogger.e(
              'e',
              "⚠️ [Badge] Bỏ qua huy hiệu không xác định từ Backend: $name",
            );
          }
        }

        final uniqueBadges = fetchedBadges.toSet().toList();
        state = state.copyWith(unlockedBadges: uniqueBadges, isLoading: false);
      } else {
        state = state.copyWith(isLoading: false);
        AppLogger.e('e', "💥 [Badge] API trả về lỗi: ${response.statusCode}");
      }
    } catch (e) {
      state = state.copyWith(isLoading: false);
      AppLogger.e('e', "💥 Lỗi đồng bộ danh sách huy hiệu từ Backend: $e");
    }
  }

  Future<void> refreshBadges() async {
    await _loadBadgesFromBackend();
  }

  // 🌟 ĐÃ CẬP NHẬT: Gửi toàn bộ danh sách huy hiệu mới mở khóa ra ngoài UI cùng lúc
  Future<void> evaluateTransactions(
    List<dynamic> allTimeData,
    List<dynamic> thisMonthData,
    double thisMonthTotal,
  ) async {
    final evaluatedBadges = GamificationUtils.calculateBadges(
      allTimeData,
      thisMonthData,
      thisMonthTotal,
    );

    final List<BadgeType> currentUnlocked = List.from(state.unlockedBadges);
    List<BadgeType> newlyFound = [];

    for (var badge in evaluatedBadges) {
      if (!currentUnlocked.contains(badge)) {
        newlyFound.add(badge);
        currentUnlocked.add(badge);
      }
    }

    if (newlyFound.isNotEmpty) {
      // Đã loại bỏ .first -> Truyền thẳng toàn bộ danh sách `newlyFound` vào state
      state = state.copyWith(
        unlockedBadges: currentUnlocked,
        newlyUnlocked: newlyFound,
      );

      _saveNewBadgesToBackend(newlyFound);
    }
  }

  Future<void> _saveNewBadgesToBackend(List<BadgeType> newBadges) async {
    try {
      String? token = await _secureStorage.read(key: 'access_token');
      if (token == null) return;

      final badgeNames = newBadges.map((e) => e.name).toList();

      final response = await http.post(
        Uri.parse('$_baseUrl/badges/unlock'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode({"badges": badgeNames}),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        AppLogger.i(
          'i',
          "🚀 [Badge] Đã đồng bộ Backend thành công: $badgeNames",
        );
      } else {
        AppLogger.e(
          'e',
          "💥 [Badge] Lỗi lưu Backend (Code: ${response.statusCode}): ${response.body}",
        );
      }
    } catch (e) {
      AppLogger.e('i', "💥 [Badge] Lỗi kết nối khi lưu Backend: $e");
    }
  }

  void clearNewlyUnlocked() {
    state = state.copyWith(clearNewlyUnlocked: true);
  }
}

// ============================================================================
// --- RIVERPOD PROVIDERS ĐĂNG KÝ TOÀN CỤC ---
// ============================================================================

final badgeServiceProvider = StateNotifierProvider<BadgeNotifier, BadgeState>((
  ref,
) {
  return BadgeNotifier();
});

final unlockedBadgesProvider = Provider<List<BadgeType>>((ref) {
  return ref.watch(badgeServiceProvider).unlockedBadges;
});

// 🌟 ĐÃ CẬP NHẬT: Trả về một List danh sách huy hiệu mới thay vì một item lẻ lẻ
final newlyUnlockedBadgeProvider = Provider<List<UserBadge>>((ref) {
  final newlyUnlockedTypes = ref.watch(badgeServiceProvider).newlyUnlocked;

  if (newlyUnlockedTypes.isEmpty) {
    return const [];
  }

  return newlyUnlockedTypes
      .map((type) => BadgeRegistry.badges[type])
      .where((badge) => badge != null)
      .cast<UserBadge>()
      .toList();
});

final currentMonthBadgeProvider = Provider<UserBadge?>((ref) {
  final unlockedTypes = ref.watch(unlockedBadgesProvider);
  if (unlockedTypes.isEmpty) return null;

  final unlockedBadgesList = unlockedTypes
      .map((type) => BadgeRegistry.badges[type])
      .where((badge) => badge != null)
      .cast<UserBadge>()
      .toList();

  if (unlockedBadgesList.isEmpty) return null;

  try {
    return unlockedBadgesList.firstWhere((b) => b.isRare);
  } catch (e) {
    return unlockedBadgesList.first;
  }
});
