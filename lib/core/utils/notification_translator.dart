class NotificationTranslator {
  // Từ điển nội dung (Phải khớp với titleKey/bodyKey của Backend)
  static final Map<String, Map<String, String>> _dictionary = {
    'en': {
      'notiBudgetExceededTitle': 'The Beggar Era Begins! 💸',
      'notiBudgetExceededBody': '{0} is empty. You overspent by {1}!',
      'notiBudgetWarningTitle': 'Red Alert: Wallet on ICU! 🚨',
      'notiBudgetWarningBody': '{0} is at {1}% usage. SOS!',
      'notiMonthlySummaryTitle': 'Spending Report: Month {0} 📊',
      'notiMonthlySummaryBody':
          'You spent {1} last month. {2} {3} was your biggest expense.',
      // Thêm các key khác nếu cần
    },
    'vi': {
      'notiBudgetExceededTitle': 'Kỷ nguyên Cái Bang! 💸',
      'notiBudgetExceededBody': '{0} đã hết. Bạn đã tiêu lố {1}!',
      'notiBudgetWarningTitle': 'Báo động đỏ: Ví thở oxy! 🚨',
      'notiBudgetWarningBody': '{0} đã chạm {1}% ngân sách. SOS!',
      'notiMonthlySummaryTitle': 'Báo cáo chi tiêu tháng {0} 📊',
      'notiMonthlySummaryBody':
          'Bạn đã tiêu {1} tháng qua. {2} {3} là "thủ phạm" lớn nhất.',
    },
  };

  static String translate(String key, List<String> args, String langCode) {
    // Lấy template, fallback về English nếu không tìm thấy
    final Map<String, String> langDict =
        _dictionary[langCode] ?? _dictionary['en']!;
    String template =
        langDict[key] ?? key; // Nếu không có key, trả về chính cái key đó

    // Thay thế {0}, {1}, {2}... bằng giá trị trong args
    for (int i = 0; i < args.length; i++) {
      template = template.replaceAll('{$i}', args[i]);
    }
    return template;
  }
}
