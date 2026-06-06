import 'package:moment_u_payment/l10n/app_localizations.dart';

class NotificationTranslator {
  /// 1. Chỉ dùng để dịch các giá trị biến (Arguments)
  static String _translateArgument(String arg, AppLocalizations l10n) {
    switch (arg) {
      case 'monthBudget':
        return l10n.monthBudget;
      case 'savingsGoal':
        return 'Savings Goal';
      case 'dailyLimit':
        return 'Daily Limit';

      // Map Badge ID
      case 'ghost':
        return l10n.badgeGhostTitle;
      case 'shopaholic':
        return l10n.badgeShopaholicTitle;
      case 'whale':
        return l10n.badgeWhaleTitle;
      case 'survivalist':
        return l10n.badgeSurvivalistTitle;
      case 'nightOwl':
        return l10n.badgeNightOwlTitle;
      case 'paydayFlash':
        return l10n.badgePaydayFlashTitle;
      case 'foodDestroyer':
        return l10n.badgeFoodDestroyerTitle;
      case 'weekendStorm':
        return l10n.badgeWeekendStormTitle;
      case 'goldfish':
        return l10n.badgeGoldfishTitle;
      case 'brokeAF':
        return l10n.badgeBrokeAFTitle;
      case 'bigTicket':
        return l10n.badgeBigTicketTitle;
      case 'firstBlood':
        return l10n.badgeFirstBloodTitle;
      case 'centurion':
        return l10n.badgeCenturionTitle;
      case 'balanced':
        return l10n.badgeBalancedTitle;

      default:
        return arg; // Giữ nguyên nếu không tìm thấy
    }
  }

  /// 2. Hàm dịch chính
  static String translate(
    String key,
    List<String> args,
    AppLocalizations l10n,
  ) {
    // Dịch danh sách các arguments trước (ví dụ: dịch ID badge -> Tên badge)
    final translatedArgs = args
        .map((arg) => _translateArgument(arg, l10n))
        .toList();

    String getArg(int index) =>
        translatedArgs.length > index ? translatedArgs[index] : '';

    // Route Key từ BE sang nội dung trong .arb
    switch (key) {
      // --- NGÂN SÁCH ---
      case 'notiBudgetExceededTitle':
        return l10n.notiBudgetExceededTitle;
      case 'notiBudgetExceededBody':
        return l10n.notiBudgetExceededBody(getArg(0), getArg(1));

      case 'notiBudgetWarningTitle':
        return l10n.notiBudgetWarningTitle;
      case 'notiBudgetWarningBody':
        return l10n.notiBudgetWarningBody(getArg(0), getArg(1));

      case 'notiMonthlySummaryTitle':
        return l10n.notiMonthlySummaryTitle(getArg(0));
      case 'notiMonthlySummaryBody':
        return l10n.notiMonthlySummaryBody(getArg(0), getArg(1), getArg(2));

      // --- HUY HIỆU ---
      case 'NOTI_BADGE_UNLOCKED_TITLE':
        return l10n.notiBadgeUnlockedTitle;
      case 'NOTI_BADGE_UNLOCKED_BODY':
        return l10n.notiBadgeUnlockedBody(getArg(0));

      case 'NOTI_BADGE_RESET_TITLE':
        return l10n.notiBadgeResetTitle;
      case 'NOTI_BADGE_RESET_BODY':
        return l10n.notiBadgeResetBody;

      // --- ONBOARDING & WELCOME (ĐÃ FIX) ---
      case 'notiFirstLoginReminderTitle':
        return l10n.notiFirstLoginReminderTitle;
      case 'notiFirstLoginReminderBody':
        return l10n.notiFirstLoginReminderBody(getArg(0));

      case 'notiFirstTxnTitle':
        return l10n.notiFirstTxnTitle;
      case 'notiFirstTxnBody':
        return l10n.notiFirstTxnBody;

      case 'notiSetBudgetTitle':
        return l10n.notiSetBudgetTitle;
      case 'notiSetBudgetBody':
        return l10n.notiSetBudgetBody;

      // Fallback
      default:
        return key;
    }
  }
}
