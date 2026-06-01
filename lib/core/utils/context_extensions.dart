import 'package:flutter/material.dart';
import 'package:moment_u_payment/l10n/app_localizations.dart';

extension LocalizedNotificationExtension on BuildContext {
  String getLocalizedBody(String bodyKey, List<String> arguments) {
    final l10n = AppLocalizations.of(this)!;

    // Ánh xạ các key động từ Backend sang l10n thuộc tính
    List<String> translatedArgs = arguments.map((arg) {
      if (arg == 'monthBudget') return l10n.monthBudget;
      return arg; // Giữ nguyên nếu là số (ví dụ: "80", "100")
    }).toList();

    // Khớp mã câu
    if (bodyKey == 'notiBudgetWarningBody') {
      return l10n.notiBudgetWarningBody(translatedArgs[0], translatedArgs[1]);
    }
    if (bodyKey == 'notiBudgetExceededBody') {
      return l10n.notiBudgetExceededBody(translatedArgs[0], translatedArgs[1]);
    }

    return '';
  }
}
