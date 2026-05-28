// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Vietnamese (`vi`).
class AppLocalizationsVi extends AppLocalizations {
  AppLocalizationsVi([String locale = 'vi']) : super(locale);

  @override
  String get appName => 'Moment u Payment';

  @override
  String get login => 'Đăng nhập';

  @override
  String get register => 'Đăng ký';

  @override
  String get email => 'Địa chỉ Email';

  @override
  String get password => 'Mật khẩu';

  @override
  String get name => 'Họ và tên';

  @override
  String get welcomeBack => 'Welcome Back! ✨';

  @override
  String get subTitle => 'Moment u Payment - Nhật ký chi tiêu ngọt ngào';

  @override
  String get emailHint => 'Email của bạn... ✨';

  @override
  String get passwordHint => 'Mật khẩu bí mật... 🔑';

  @override
  String get nameHint => 'Tên dễ thương của bạn... ✨';

  @override
  String get loginButton => 'Đi vào thuiii ✨';

  @override
  String get registerButton => 'Đăng ký tài khoản ✨';

  @override
  String get dontHaveAccount => 'Chưa có tài khoản ư? Đăng ký liền nè! 💕';

  @override
  String get emptyFieldsWarning => 'Đừng để trống ô nào nhé bạn ơi! 💕';

  @override
  String get loginSuccess => 'Đăng nhập thành công rùi nè! ✨';

  @override
  String get loginCreateAccountTitle => 'Create Account 🌸';

  @override
  String get loginCreateAccountSub =>
      'Tham gia vào thế giới quản lý chi tiêu đáng yêu';

  @override
  String get loginErrorNotification =>
      'Tài khoản hoặc mật khẩu không chính xác bạn ơi! 😢';

  @override
  String get googleLoginErrorNotification =>
      'Đăng nhập bằng Google thất bại mất rồi! Thử lại nha 🌸';

  @override
  String get loginButtonText => 'Đi vào thuiiii ✨';

  @override
  String get loginGGButtonText => 'Vào bằng google nè 🚀';

  @override
  String emailNotVerifiedAlert(String email) {
    return 'Nhớ xác thực email $email bạn nhé! 🔑';
  }

  @override
  String get newMomentTitle => 'Khoảnh khắc mới 📸';

  @override
  String get amountHint => '0.00 🪙';

  @override
  String get uploadPhotoPlaceholder =>
      'Chụp ảnh hóa đơn / Khoảnh khắc chi tiêu 🌸';

  @override
  String get categorySectionTitle => 'Danh mục chi tiêu';

  @override
  String get noteHint => 'Ghi chú ngắn gọn... ✨';

  @override
  String get saveMomentButton => 'Lưu Moment Chi Tiêu ✨';

  @override
  String get txSuccessMessage => 'Đã ghi chép khoảnh khắc chi tiêu này rùi! 🌸';

  @override
  String get txErrorMessage => 'Không lưu được khoảnh khắc này rồi bạn ơi! 😢';

  @override
  String get emptyTransactionNote => 'Khoảnh khắc chi tiêu không tên...';

  @override
  String get homeGreetingDeveloper => 'Xin chào, Developer! 👋';

  @override
  String get homeSubGreeting => 'Hôm nay tình hình chi tiêu thế nào?';

  @override
  String get spendingMomentsTitle => 'Khoảnh khắc chi tiêu của bạn';

  @override
  String get loadingData => 'Đang tải danh sách khoảnh khắc...';

  @override
  String get errorLoadData => 'Không thể tải dữ liệu. Vui lòng thử lại!';

  @override
  String get retryButton => 'Thử lại';

  @override
  String get emptyTransactionList =>
      'Chưa có khoảnh khắc chi tiêu nào trong tháng này. Ấn + để thêm nhé! 🌸';

  @override
  String get catFood => 'Ăn uống 🍰';

  @override
  String get catShopping => 'Mua sắm 🛍️';

  @override
  String get catTransport => 'Di chuyển 🚗';

  @override
  String get catEntertainment => 'Giải trí 🎮';

  @override
  String get categoryOther => 'Chưa phân loại';

  @override
  String get catCustom => 'Khác nè... 📝';

  @override
  String get customCategoryHint =>
      'Đặt tên cho danh mục bí mật của bạn nha... ✨';

  @override
  String get deleteDialogTitle => 'Xóa khoảnh khắc này?';

  @override
  String get deleteDialogContent =>
      'Hành động này sẽ xóa vĩnh viễn lịch sử khoảnh khắc này và ảnh chứng từ lưu trữ trên Cloudinary.';

  @override
  String get deleteDialogCancel => 'Hủy';

  @override
  String get deleteDialogConfirm => 'Xóa sạch';

  @override
  String get deleteSuccessSnackbar =>
      'Đã dọn dẹp sạch sẽ khoảnh khắc và ảnh hóa đơn đi kèm rùi! ✨';

  @override
  String get deleteErrorSnackbar =>
      'Không thể xóa. Vui lòng kiểm tra lại kết nối mạng!';

  @override
  String get analyticsTitle => 'Chi tiết đây nèe!!';

  @override
  String get emptyAnalyticsData =>
      'Chưa có nhật ký khoảnh khắc nào trong tháng này! 📝';

  @override
  String get totalLabel => 'Tổng chi';

  @override
  String get today => 'Hôm nay';

  @override
  String get yesterday => 'Hôm qua';

  @override
  String get thisMonth => 'Tháng này';

  @override
  String get unknownMonth => 'Tháng không xác định';

  @override
  String get noMomentsAvailable => 'Không có khoảnh khắc nào';

  @override
  String get cameraTapInstruction =>
      'Nhấn nhẹ vào đây để chụp choẹt hóa đơn nhen! 📸';

  @override
  String get galleryPickAction => 'Hoặc ghé tiệm ảnh chọn hình có sẵn nè ✨';

  @override
  String get galleryChangeAction => 'Đổi ảnh khác từ bộ sưu tập nha 🌸';

  @override
  String get amountSectionTitle => 'TỔNG THIỆT HẠI ĐỢT NÀY 💰';

  @override
  String get noteSectionTitle => 'TÂM SỰ MỎNG VỀ KHOẢNH KHẮC 💬';

  @override
  String monthLabel(String month, String year) {
    return 'Tháng $month/$year';
  }

  @override
  String get budgetTitle => 'Ví Ngoan Đặt Mục Tiêu 🎯';

  @override
  String get budgetSectionTitle => 'HẠN MỨC CHI TIÊU THÁNG NÀY 🌟';

  @override
  String get budgetHint => 'Ví dụ: 5.000.000';

  @override
  String get budgetSaveButton => 'Chốt Ngưỡng Chi Tiêu Thôi! 🚀';

  @override
  String get budgetSuccessMessage =>
      'Đã ghi nhận hạn mức mới, cùng chi tiêu thông thái nha! 🥰';

  @override
  String get budgetErrorMessage =>
      'Hệ thống nấc cụt rồi, không lưu được ngưỡng đâu khóc mất thôi! 😿';

  @override
  String get monthBudget => 'Ngân sách tháng này';

  @override
  String get changeLimit => 'Sửa hạn mức';

  @override
  String get budgetMenuTitle => 'Thiết lập hạn mức chi tiêu 🎯';

  @override
  String get budgetThisMonthLabel => 'Ngân sách tháng này';

  @override
  String get budgetNotSetStatus => 'Chưa thiết lập mục tiêu chi tiêu';

  @override
  String get budgetNotSetFeedback =>
      'Bạn chưa cài đặt ngân sách nè, đặt ngay thôi! 🎯✨';

  @override
  String get budgetHealthyFeedback => 'Ví đang rủng rỉnh nha! 💖';

  @override
  String get budgetHalfSpentFeedback =>
      'Tiêu hết hơn nửa rồi đó nghen, khéo léo một chút nào! ⏳✨';

  @override
  String get budgetWarningFeedback =>
      'Úi úi, ví sắp gầy trơ xương rồi, tém tém lại xíu nhen! 🥺💸';

  @override
  String get budgetOverBudgetFeedback =>
      'Toang rồi ông giáo ạ, vung tay quá trán lố mất tiêu rồi! 🚨😭';

  @override
  String get budgetStatusGood =>
      'Tình hình chi tiêu tháng này rất hợp lý luôn! 👍';

  @override
  String get budgetStatusWarning =>
      'Ví của bạn còn chưa tới 15%. Thắt lưng buộc bụng thôi nào! 💸';

  @override
  String get budgetStatusOver =>
      'Ôi không! Bạn đã tiêu vượt quá hạn mức rồi! 🚨';

  @override
  String get budgetStatusHalf =>
      'Bạn đã tiêu hết hơn nửa số tiền rồi, cẩn thận chút nha! ⏳';

  @override
  String remainingAmount(String amount) {
    return 'Còn lại: $amountđ';
  }

  @override
  String dailySuggestion(String money) {
    return '💡 Gợi ý: Hôm nay bạn chỉ nên chi tiêu tối đa $moneyđ để giữ an toàn nha.';
  }

  @override
  String budgetOverspentStatus(String overspent, String limit) {
    return 'Vượt hạn mức $overspent (Hạn mức $limit). 🥺💸';
  }

  @override
  String budgetSpentStatus(String spent, String limit) {
    return 'Đã tiêu $spent trong tổng số $limit';
  }

  @override
  String budgetDetailedStatus(String spent, String remaining, String days) {
    return 'Đã vung tay $spent 💸 • Còn $remaining để sinh tồn $days ngày 🏕️';
  }

  @override
  String budgetDetailedStatusToday(String spent, String remaining) {
    return 'Đã vung tay $spent 💸 • Gồng nốt hôm nay với $remaining thui! 🥺';
  }

  @override
  String budgetOverspentDetailedStatus(
    String spent,
    String overspent,
    String days,
  ) {
    return 'Bay màu $spent 💸 • Âm quỹ $overspent mà còn tới $days ngày sinh tồn! 🚨';
  }

  @override
  String budgetOverspentDetailedStatusToday(String spent, String overspent) {
    return 'Bay màu $spent 💸 • Chốt sổ tháng lố mất $overspent rùi 😭';
  }

  @override
  String budgetSafeDaily(String amount) {
    return '💡 Mẹo sinh tồn: Mỗi ngày tiêu cỡ $amount là an toàn hạ cánh! 🪂';
  }

  @override
  String budgetSafeToday(String amount) {
    return '💡 Mẹo sinh tồn: Nay rón rén tiêu tối đa $amount thui nha! 🥺';
  }
}
