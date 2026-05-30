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
  String get homeSubGreeting => 'Hôm nay tình hình chi tiêu thế nào?';

  @override
  String get spendingMomentsTitle => 'Khoảnh khắc chi tiêu của bạn';

  @override
  String get loadingData => 'Đang tải danh sách khoảnh khắc...';

  @override
  String get errorLoadData => 'Úi, dữ liệu bị vấp cục đá ngã rồi, xu ghê 🥺';

  @override
  String get retryButton => 'Lấy đà thử lại nghen 🚀';

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
  String get analyticsTitle => 'Phân tích giao dịch';

  @override
  String get emptyAnalyticsData =>
      'Hộp tiết kiệm đang trống trơn nè~ Chưa tiêu đồng nào luôn á 🐥';

  @override
  String get totalLabel => 'Tổng thiệt hại 💸';

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
  String get galleryPickAction => 'Chọn ảnh';

  @override
  String get galleryChangeAction => 'Đổi ảnh';

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

  @override
  String get hello => 'Xin chào,';

  @override
  String get notificationSettingsTitle => 'Cài đặt thông báo';

  @override
  String get notiCategoryBudget => 'Cảnh báo ngân sách';

  @override
  String get notiCategoryReminder => 'Nhắc nhở định kỳ';

  @override
  String get notiCategorySecurity => 'Hệ thống & Bảo mật';

  @override
  String get notiCategorySharedWallet => 'Hoạt động ví nhóm';

  @override
  String get notiBudgetWarningTitle => 'Cảnh báo ngân sách! 🚨';

  @override
  String notiBudgetWarningBody(String wallet, String percent) {
    return 'Chú ý: $wallet của bạn đã dùng hết $percent%. Hãy chi tiêu dè xẻn lại nhé!';
  }

  @override
  String get notiBudgetExceededTitle => 'Vượt quá ngân sách! 💸';

  @override
  String notiBudgetExceededBody(String wallet, String percent) {
    return 'Báo động đỏ: $wallet đã vượt mức an toàn ($percent%). Chuyển sang chế độ sinh tồn ngay!';
  }

  @override
  String get notiEmailVerifiedTitle => 'Xác thực thành công! 🛡️';

  @override
  String get notiEmailVerifiedBody =>
      'Tài khoản của bạn đã được bảo vệ an toàn. Bắt đầu quản lý chi tiêu thôi nào!';

  @override
  String notiAggregatedTxBody(String budgetName, String count) {
    return 'Ví $budgetName có $count thay đổi giao dịch mới được gộp lại.';
  }

  @override
  String get notiFirstLoginReminderTitle =>
      'Xác thực một xíu, yêu nhau lâu dài! 💖';

  @override
  String notiFirstLoginReminderBody(String name) {
    return '$name ơi, nhớ kiểm tra hòm thư và nhấn xác thực email liền nha! Sau 30 ngày nếu tụi mình chưa thấy bạn, tài khoản sẽ phải tự động \'ngủ đông\' mất tiêu á, thương lắm luôn! 🥺🌱';
  }

  @override
  String get notiFirstTxnTitle => 'Chạm ngõ Moment đầu tiên! 🪄';

  @override
  String get notiFirstTxnBody =>
      'Ví đã sẵn sàng! Cùng ghi lại khoản chi tiêu (Moment) đầu tiên của cậu ngay hôm nay nhé. Chạm vào đây nào! 👇💸';

  @override
  String get notiSetBudgetTitle => 'Lập khiên bảo vệ ví! 🛡️';

  @override
  String get notiSetBudgetBody =>
      'Cài đặt hạn mức ngay để tớ nhắc cậu mỗi khi lỡ \'vung tay quá trán\' nha. Chạm để thiết lập! 🎯💖';

  @override
  String get forgotPasswordDialogTitle => 'Khôi phục mật khẩu';

  @override
  String get forgotPasswordDialogDesc =>
      'Hệ thống sẽ gửi một mã xác thực (OTP) hoặc liên kết đặt lại vào Email của bạn.';

  @override
  String get accountEmail => 'Email tài khoản';

  @override
  String get cancel => 'Hủy';

  @override
  String get sendCode => 'Gửi mã';

  @override
  String forgotPwSuccess(String email) {
    return 'Đã gửi mã khôi phục đến email: $email';
  }

  @override
  String get forgotPwError => 'Không thể gửi mã khôi phục. Vui lòng thử lại.';

  @override
  String get resetPwDialogTitle => 'Đặt lại mật khẩu mới';

  @override
  String get authEmail => 'Email xác thực';

  @override
  String get otpCode => 'Mã xác thực (OTP / Token)';

  @override
  String get newPassword => 'Mật khẩu mới nè';

  @override
  String get confirm => 'Xác nhận';

  @override
  String get resetPwSuccess =>
      'Mật khẩu của bạn đã đổi thành công! Vui lòng đăng nhập.';

  @override
  String get resetPwError => 'Mã xác thực không hợp lệ hoặc đã hết hạn.';

  @override
  String get settingsAndUtilities => 'Cài đặt & Tiện ích';

  @override
  String get language => 'Ngôn ngữ (Language)';

  @override
  String get english => 'English';

  @override
  String get vietnamese => 'Tiếng Việt';

  @override
  String get currencyUnit => 'Đơn vị tiền tệ';

  @override
  String get currentlyUsing => 'Đang dùng';

  @override
  String get darkMode => 'Bật chế độ cú đêm';

  @override
  String get lightTheme => 'Giao diện sáng';

  @override
  String get notificationSettingsSubtitle => 'Quản lý cảnh báo & chi tiêu';

  @override
  String get changePasswordSubtitle => 'Thay đổi mật khẩu tài khoản hiện tại';

  @override
  String get helpCenter => 'Cần mình giúp gì hông? 🎧';

  @override
  String get helpCenterSubtitle => 'Hỏi đáp & Liên hệ hỗ trợ';

  @override
  String get logout => 'Thôi, tớ đi đây!';

  @override
  String get logoutSubtitle => 'Rời khỏi phiên đăng nhập hiện tại';

  @override
  String get newPasswordTitle => 'Đổi mật khẩu mới';

  @override
  String get update => 'Cập nhật';

  @override
  String get updatePasswordSuccess => 'Cập nhật mật khẩu thành công!';

  @override
  String get updatePasswordError =>
      'Mật khẩu hiện tại không đúng hoặc lỗi kết nối.';

  @override
  String get forgotPasswordText => 'Quên mật khẩu?';

  @override
  String get resetPasswordText => 'Đặt lại mật khẩu';

  @override
  String get forgotPasswordTitle => 'Khôi phục mật khẩu';

  @override
  String get forgotPasswordSubtitle =>
      'Hệ thống sẽ gửi một mã xác thực (OTP) hoặc liên kết đặt lại vào Email của bạn.';

  @override
  String get emailAccountLabel => 'Email tài khoản';

  @override
  String get cancelButton => 'Hủy';

  @override
  String get sendCodeButton => 'Gửi mã';

  @override
  String get sendCodeSuccess => 'Đã gửi mã khôi phục đến email:';

  @override
  String get resetPasswordTitle => 'Đặt lại mật khẩu mới';

  @override
  String get emailVerificationLabel => 'Email xác thực';

  @override
  String get otpLabel => 'Mã xác thực (OTP / Token)';

  @override
  String get newPasswordLabel => 'Mật khẩu mới';

  @override
  String get confirmButton => 'Xác nhận';

  @override
  String get resetPasswordSuccess =>
      'Mật khẩu của bạn đã đổi thành công! Vui lòng đăng nhập.';

  @override
  String get spendingTrend => 'Xu hướng';

  @override
  String get spendingStructure => 'Cơ cấu \'bay màu\' của ví 🥧';

  @override
  String get customDate => 'Tùy chỉnh';

  @override
  String get avgPerDay => 'Mỗi ngày \'bay\' cỡ 🕊️';

  @override
  String get timeFrame => 'Số ngày';

  @override
  String get pastWeek => 'Tuần qua 🌷';

  @override
  String get pastMonth => 'Tháng qua 🌙';

  @override
  String get threeMonths => '3 tháng 🍄';

  @override
  String get sixMonths => 'Nửa năm 🐢';

  @override
  String get pastYear => 'Năm qua 🌟';

  @override
  String get fromDate => 'Từ ngày nào 🐾';

  @override
  String get toDate => 'Đến ngày nao 🌿';

  @override
  String get repeatCycle => 'Vòng lặp ⏳';

  @override
  String get days => 'ngày';

  @override
  String get buyDevCoffeeTitle => 'Tiếp thêm cafein cho dev ☕';

  @override
  String get buyDevCoffeeSubtitle =>
      'Ủng hộ ly cà phê để dev code không quạo nha! 🥰';

  @override
  String get scanToSpreadLoveTitle => 'Đa tạ đại hiệp búng xu! 🥰';

  @override
  String get scanToSpreadLoveSubtitle =>
      'Mỗi ly cà phê của bạn là một chiếc bug bị tiêu diệt! Cảm ơn nhà tài trợ kim cương đã yêu thương Moment U Payment nhé! 💎✨';

  @override
  String get missingQrMessage =>
      'Hãy thêm ảnh QR vào:\nassets/images/momo_qr.png';

  @override
  String get closeButton => 'Đóng';

  @override
  String get buyMeACoffeeBtn => 'Hoặc tặng qua Buy Me a Coffee ☕';

  @override
  String get helpCenterDialogTitle => 'Trung tâm hỗ trợ 🎧';

  @override
  String get helpCenterDialogMessage =>
      'Nếu bạn chạm trán \'bug\' hay có bất kỳ ý tưởng nào để Moment U tuyệt vời hơn, đừng ngại email cho dev nhé! Tụi mình luôn lắng nghe bạn. 🥰';

  @override
  String get contactEmail => 'momentu.support@gmail.com';

  @override
  String get appVersionTitle => 'Phiên bản';

  @override
  String get appVersion => 'v1.0.0';

  @override
  String get dailyAllowance => 'Trung bình mỗi ngày';

  @override
  String get quickSuggestions => 'Gợi ý nhanh';

  @override
  String get budgetTip =>
      'Mẹo: Hãy đặt hạn mức thấp hơn thu nhập thực tế khoảng 20% để luôn có khoản tiết kiệm dự phòng nhé! 🌟';

  @override
  String get emptyFilterTransaction =>
      'Không có giao dịch nào trong khoảng ngày này 🌸';

  @override
  String get from => 'Từ';

  @override
  String get to => 'đến';

  @override
  String get month => 'Tháng';

  @override
  String get day => 'Ngày';

  @override
  String get mon => 'T2';

  @override
  String get tue => 'T3';

  @override
  String get wed => 'T4';

  @override
  String get thu => 'T5';

  @override
  String get fri => 'T6';

  @override
  String get sat => 'T7';

  @override
  String get sun => 'CN';

  @override
  String get accountSettings => 'Góc riêng của bạn ✨';

  @override
  String get accountSettingsSubtitle =>
      'Sửa tên, đổi ảnh xinh và khóa két cho xịn';

  @override
  String get fullName => 'Tên \'xịn\' của bạn';

  @override
  String get save => 'Lưu lẹ đi nè!';

  @override
  String get changePassword => 'Đổi mật khẩu';

  @override
  String get currentPassword => 'Mật khẩu cũ';

  @override
  String get updateSuccess => 'Cập nhật thành công!';

  @override
  String get updateError => 'Ối, có lỗi gì đó rồi...';

  @override
  String get changeAvatar => 'Thay ảnh xinh';

  @override
  String get saveSettingsSuccess => 'Cập nhật hồ sơ thành công!';

  @override
  String get personalInfo => 'Thông tin cá nhân';

  @override
  String get security => 'Bảo mật';

  @override
  String get updateProfile => 'Cập nhật hồ sơ';

  @override
  String get updatePassword => 'Đổi mật khẩu';

  @override
  String get updateFailed => 'Cập nhật thất bại!';

  @override
  String get nameEmptyError => 'Tên không được để trống!';

  @override
  String get passwordLengthError => 'Mật khẩu phải từ 4 ký tự trở lên!';

  @override
  String get systemError => 'Lỗi hệ thống!';

  @override
  String get incorrectPassword => 'Mật khẩu hiện tại không đúng!';

  @override
  String get maxOneYearWarning =>
      'Moment U chỉ hỗ trợ xem tối đa 1 năm thui nè! 🗓️';

  @override
  String get wrongOldPassword => 'Mật khẩu cũ không chính xác.';

  @override
  String get userNotFoundError => 'Không tìm thấy thông tin tài khoản.';

  @override
  String get weakPasswordError => 'Mật khẩu mới quá yếu.';

  @override
  String get noChangeWarning => 'Thông tin của bạn vẫn như cũ! ✨';

  @override
  String get fillPasswordFieldsError =>
      'Vui lòng nhập đầy đủ thông tin mật khẩu.';

  @override
  String get samePasswordError => 'Mật khẩu mới không được trùng mật khẩu cũ.';
}
