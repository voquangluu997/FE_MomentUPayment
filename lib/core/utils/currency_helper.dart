import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:moment_u_payment/core/constants/app_colors.dart';

class CurrencyHelper {
  // Pattern chuẩn: dấu phẩy phân cách hàng nghìn, dấu chấm cho số thập phân
  static final _formatter = NumberFormat('#,##0.##', 'en_US');

  /// 1. Hàm rút gọn (K, M, B)
  static String formatCompactAmount(dynamic numValue, {String symbol = '₫'}) {
    if (numValue == null) return '0';

    final double value = double.tryParse(numValue.toString()) ?? 0.0;
    final double absValue = value.abs();
    final bool isNegative = value < 0;

    String numberStr = '';
    String unit = '';

    if (absValue >= 1000000000) {
      numberStr = _formatter.format(absValue / 1000000000);
      unit = 'B';
    } else if (absValue >= 1000000) {
      numberStr = _formatter.format(absValue / 1000000);
      unit = 'M';
    } else {
      numberStr = _formatter.format(absValue);
      unit = '';
    }

    String formattedResult = '$numberStr$unit $symbol'.trim();
    return isNegative ? '-$formattedResult' : formattedResult;
  }

  /// 2. Hàm đầy đủ (Không rút gọn)
  static String formatFullAmount(dynamic numValue, {String symbol = '₫'}) {
    if (numValue == null) return '0';

    final double value = double.tryParse(numValue.toString()) ?? 0.0;
    final bool isNegative = value < 0;

    String s = _formatter.format(value.abs());

    String result = '$s $symbol'.trim();
    return isNegative ? '-$result' : result;
  }
}

// 🚀 THÀNH PHẦN ĐƯỢC DI CHUYỂN VÀO ĐÂY ĐỂ TÁI SỬ DỤNG TOÀN HỆ THỐNG
class CurrencyPickerUtil {
  /// Hiển thị BottomSheet chọn tiền tệ chuẩn phong cách Cozy Hàn Quốc
  static void showCurrencyBottomSheet({
    required BuildContext context,
    required WidgetRef ref,
    required AppColorTheme appColors,
    required String currentSymbol,
    required ValueChanged<String> onCurrencyChanged,
  }) {
    HapticFeedback.mediumImpact();
    final List<Map<String, String>> currencyList = [
      {'symbol': '₫', 'name': 'Việt Nam Đồng (VND)'},
      {'symbol': '\$', 'name': 'Đô la Mỹ (USD)'},
      {'symbol': '€', 'name': 'Euro (EUR)'},
      {'symbol': '¥', 'name': 'Yên Nhật (JPY)'},
    ];

    showModalBottomSheet(
      context: context,
      backgroundColor: appColors.cardBackground,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Container(
                    width: 38,
                    height: 4.5,
                    decoration: BoxDecoration(
                      color: appColors.textMuted.withValues(alpha: 0.2),
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                ),
                const SizedBox(height: 18),
                Text(
                  "Đơn vị tiền tệ".toUpperCase(),
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w800,
                    color: appColors.primaryDark.withValues(alpha: 0.6),
                    letterSpacing: 0.6,
                  ),
                ),
                const SizedBox(height: 10),
                Column(
                  children: currencyList.map((currency) {
                    final isSelected = currentSymbol == currency['symbol'];
                    return InkWell(
                      onTap: () {
                        HapticFeedback.lightImpact();
                        Navigator.pop(context);
                        onCurrencyChanged(currency['symbol']!);
                      },
                      borderRadius: BorderRadius.circular(14),
                      child: Container(
                        margin: const EdgeInsets.symmetric(vertical: 4),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 12,
                        ),
                        decoration: BoxDecoration(
                          color: isSelected
                              ? appColors.primary.withValues(alpha: 0.06)
                              : Colors.transparent,
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(
                            color: isSelected
                                ? appColors.primary.withValues(alpha: 0.15)
                                : Colors.transparent,
                          ),
                        ),
                        child: Row(
                          children: [
                            Container(
                              width: 32,
                              height: 32,
                              decoration: BoxDecoration(
                                color: isSelected
                                    ? appColors.primary
                                    : appColors.primary.withValues(alpha: 0.1),
                                shape: BoxShape.circle,
                              ),
                              alignment: Alignment.center,
                              child: Text(
                                currency['symbol']!,
                                style: TextStyle(
                                  color: isSelected
                                      ? Colors.white
                                      : appColors.primary,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 14,
                                ),
                              ),
                            ),
                            const SizedBox(width: 14),
                            Text(
                              currency['name']!,
                              style: TextStyle(
                                color: appColors.text,
                                fontWeight: isSelected
                                    ? FontWeight.w700
                                    : FontWeight.w500,
                                fontSize: 14,
                              ),
                            ),
                            const Spacer(),
                            if (isSelected)
                              Icon(
                                CupertinoIcons.checkmark_alt_circle_fill,
                                color: appColors.primary,
                                size: 20,
                              ),
                          ],
                        ),
                      ),
                    );
                  }).toList(),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
