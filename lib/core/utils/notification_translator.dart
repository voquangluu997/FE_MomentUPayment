class NotificationTranslator {
  // 1. Từ điển nội dung thông báo
  static final Map<String, Map<String, String>> _templates = {
    'en': {
      'notiBudgetExceededTitle': 'The Beggar Era Begins! 💸',
      'notiBudgetExceededBody': '{0} is empty. You overspent by {1}%',
      'notiBudgetWarningTitle': 'Red Alert: Wallet on ICU! 🚨',
      'notiBudgetWarningBody': '{0} is at {1}% usage. SOS!',
      'notiMonthlySummaryTitle': 'Spending Report: Month {0} 📊',
      'notiMonthlySummaryBody':
          'You spent {1} last month. {2} {3} was your biggest expense.',
    },
    'vi': {
      'notiBudgetExceededTitle': 'Kỷ nguyên Cái Bang! 💸',
      'notiBudgetExceededBody': '{0} đã hết. Bạn đã tiêu lố {1}%!',
      'notiBudgetWarningTitle': 'Báo động đỏ: Ví thở oxy! 🚨',
      'notiBudgetWarningBody': '{0} đã chạm {1}% ngân sách. SOS!',
      'notiMonthlySummaryTitle': 'Báo cáo chi tiêu tháng {0} 📊',
      'notiMonthlySummaryBody':
          'Bạn đã tiêu {1} tháng qua. {2} {3} là "thủ phạm" lớn nhất.',
    },
  };

  // 2. Từ điển dịch thuật cho các ARGUMENTS (biến)
  static final Map<String, Map<String, String>> _argDictionary = {
    'monthBudget': {'en': 'Monthly Budget', 'vi': 'Ngân sách tháng'},
    'savingsGoal': {'en': 'Savings Goal', 'vi': 'Mục tiêu tiết kiệm'},
    'dailyLimit': {'en': 'Daily Limit', 'vi': 'Hạn mức hàng ngày'},
    // Thêm các biến khác vào đây khi cần
  };

  static String translate(String key, List<String> args, String langCode) {
    // 1. Dịch các arguments trước
    final List<String> translatedArgs = args.map((arg) {
      // Nếu arg nằm trong từ điển, lấy giá trị đã dịch
      if (_argDictionary.containsKey(arg)) {
        return _argDictionary[arg]![langCode] ?? _argDictionary[arg]!['en']!;
      }
      // Nếu không (hoặc là số như '80', '100'), giữ nguyên
      return arg;
    }).toList();

    // 2. Lấy template
    final Map<String, String> langDict =
        _templates[langCode] ?? _templates['en']!;
    String template = langDict[key] ?? key;

    // 3. Thay thế {0}, {1}... bằng các arguments đã dịch
    for (int i = 0; i < translatedArgs.length; i++) {
      template = template.replaceAll('{$i}', translatedArgs[i]);
    }

    return template;
  }
}
