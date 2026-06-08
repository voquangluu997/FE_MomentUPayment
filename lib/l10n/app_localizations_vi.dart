// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Vietnamese (`vi`).
class AppLocalizationsVi extends AppLocalizations {
  AppLocalizationsVi([String locale = 'vi']) : super(locale);

  @override
  String get appName => 'Moments U Payment';

  @override
  String get login => 'Đăng nhập';

  @override
  String get register => 'Đăng ký';

  @override
  String get email => 'Địa chỉ Email';

  @override
  String get password => 'Mật khẩu';

  @override
  String get name => 'Tên hiển thị';

  @override
  String get welcomeBack => 'Welcome Back! ✨';

  @override
  String get subTitle => 'Moments U Payment - Nhật ký chi tiêu ngọt ngào';

  @override
  String get subTitle1 => 'Moments U Payment';

  @override
  String get subTitle2 => 'Nhật ký chi tiêu ngọt ngào';

  @override
  String get emailHint => 'Email của bạn... ✨';

  @override
  String get passwordHint => 'Mật khẩu bí mật... 🔑';

  @override
  String get nameHint => 'Tên dễ thương của bạn... ✨';

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
  String get loginButtonText => 'Đi vào thuiii ✨';

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
  String get noteHint => 'Ghi chú...';

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
  String get spendingMomentsTitle => 'Khoảnh khắc chi tiêu nè';

  @override
  String get loadingData => 'Đang tải danh sách khoảnh khắc...';

  @override
  String get errorLoadData => 'Úi, dữ liệu bị vấp cục đá ngã rồi, xu ghê 🥺';

  @override
  String get retryButton => 'Lấy đà thử lại nghen 🚀';

  @override
  String get emptyTransactionList => 'Chưa có khoảnh khắc nào được ghi lại';

  @override
  String get catFood => 'Ăn uống 🍰';

  @override
  String get catShopping => 'Mua sắm 🛍️';

  @override
  String get catTransport => 'Di chuyển 🚗';

  @override
  String get catEntertainment => 'Giải trí 🎮';

  @override
  String get categoryOther => 'Khác';

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
  String get cameraPickActionShort => 'Chụp ảnh';

  @override
  String get galleryChangeAction => 'Đổi ảnh khác từ bộ sưu tập nha 🌸';

  @override
  String get galleryChangeActionShort => 'Thư viện';

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
  String get budgetStatusWarning => 'Vùng nguy hiểm! 🚨';

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
    return 'Ví $budgetName có $count thay đổi khoảnh khắc mới được gộp lại.';
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
      'Ví đã sẵn sàng! Cùng ghi lại khoản chi tiêu (Moment) đầu tiên của bạn ngay hôm nay nhé. Chạm vào đây nào! 👇💸';

  @override
  String get notiSetBudgetTitle => 'Lập khiên bảo vệ ví! 🛡️';

  @override
  String get notiSetBudgetBody =>
      'Cài đặt hạn mức ngay để tớ nhắc bạn mỗi khi lỡ \'vung tay quá trán\' nha. Chạm để thiết lập! 🎯💖';

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
  String get lightTheme => 'Chế độ sáng';

  @override
  String get darkTheme => 'Chế độ tối';

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
  String get analyticsTitle => 'Thống kê';

  @override
  String get spendingTrend => 'Xu hướng';

  @override
  String get spendingStructure => 'Cơ cấu \'bay màu\' của ví 🥧';

  @override
  String get customDate => 'Tùy chỉnh';

  @override
  String get totalLabel => 'Tổng thiệt hại 💸';

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
  String get fromDate => 'Từ';

  @override
  String get toDate => 'Đến';

  @override
  String get repeatCycle => 'Vòng lặp ⏳';

  @override
  String get days => 'ngày';

  @override
  String get emptyAnalyticsData =>
      'Hộp tiết kiệm đang trống trơn nè~ Chưa tiêu đồng nào luôn á 🐥';

  @override
  String get buyDevCoffeeTitle => 'Tiếp thêm cafein cho dev ☕';

  @override
  String get buyDevCoffeeSubtitle =>
      'Ủng hộ ly cà phê để dev code không quạo nha! 🥰';

  @override
  String get scanToSpreadLoveTitle => 'Đa tạ đại hiệp búng xu! 🥰';

  @override
  String get scanToSpreadLoveSubtitle =>
      'Mỗi ly cà phê của bạn là một chiếc bug bị tiêu diệt! Cảm ơn nhà tài trợ kim cương đã yêu thương Moments U Payment nhé! 💎✨';

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
  String get contactEmail => 'momentupayment.support@gmail.com';

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
      'Không có khoảnh khắc nào trong khoảng thời gian này';

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
  String get updateSuccess => 'Cập nhật thành công!';

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

  @override
  String get addSuccessMessage => 'Thêm khoảnh khắc mới thành công rùi! ✨';

  @override
  String get updateSuccessMessage =>
      'Cập nhật khoảnh khắc thành công rùi nha! 🥰';

  @override
  String get futureDateError =>
      'Bạn không thể thêm khoảnh khắc cho ngày tương lai! 🫣';

  @override
  String get deleteSuccessMessage =>
      'Đã xoá khoảnh khắc thành công rùi bạn ơi! 🌸';

  @override
  String get deleteErrorMessage =>
      'Có lỗi xảy ra khi xoá mất rồi, thử lại nhé! 😢';

  @override
  String get premiumGroupMomentsTitle => 'Group Moments 👑';

  @override
  String get premiumGroupMomentsSubtitle =>
      'Tính năng ví nhóm đang tạm khóa ở bản thử nghiệm.';

  @override
  String get navHome => 'Trang chủ';

  @override
  String get navBudget => 'Ngân sách';

  @override
  String get navAnalytics => 'Thống kê';

  @override
  String get navPremium => 'Premium';

  @override
  String get navMenu => 'Menu';

  @override
  String get setBudgetTitle => 'Thiết lập ngân sách';

  @override
  String get monthlyBudgetLimit => 'Hạn mức chi tiêu tháng này';

  @override
  String get saveConfiguration => 'Lưu cấu hình';

  @override
  String get premiumFeatureTitle => 'Tính năng Premium';

  @override
  String get premiumFeatureDesc =>
      'Chức năng ví nhóm \"Group Moments\" hiện đang được khóa. Nâng cấp lên tài khoản Premium để mở khóa tính năng chia sẻ dòng tiền, quản lý tài chính chung cùng người yêu và gia đình trong thời gian thực.';

  @override
  String get unlockPremiumNow => 'Mở khóa Premium ngay';

  @override
  String get budgetLoadError => 'Không thể tải ngân sách';

  @override
  String get budgetOverspentLabel => 'Vượt mức';

  @override
  String get budgetRemainingLabel => 'Đánh giá trạng thái';

  @override
  String get budgetLastDay => 'Hôm nay là ngày cuối!';

  @override
  String budgetRemainingDays(int days) {
    return '$days ngày nữa';
  }

  @override
  String get budgetStatusReasonable => 'Ổn áp ghê';

  @override
  String get budgetStatusNotSet => 'Cét-ting đi';

  @override
  String get budgetStatusOvertarget => 'Ví khóc á';

  @override
  String get budgetStatusHalfSpent => 'Nửa cây kem';

  @override
  String get budgetDailyNotSet =>
      'Thiết lập hạn mức đi để ví còn biết đường cứu chủ! 🥺';

  @override
  String get budgetDailyOvertarget =>
      'Hết quota rồi, hôm nay ăn mầm đá hít khí trời nha... 💸';

  @override
  String budgetDailySafeLimit(String amount) {
    return 'Tém tém lại, mỗi ngày tiêu tối đa $amount thui nha sen! 🥰';
  }

  @override
  String get emptyTransactionSubtitle =>
      'Ghi chép khoản chi đầu tiên ngay đi nè, để ví tiền luôn ngoan ngoãn nằm trong tầm tay bạn nha! ✨';

  @override
  String get deleteActionLabel => 'Xóa';

  @override
  String transactionCount(int count) {
    return '$count giao dịch';
  }

  @override
  String get transactionTime => 'Thời gian';

  @override
  String get addMomentTooltip => 'Thêm nhanh khoảnh khắc chi tiêu ✨';

  @override
  String get notificationListTitle => 'Danh sách thông báo';

  @override
  String get allNotifications => 'Tất cả';

  @override
  String get unreadNotifications => 'Chưa đọc';

  @override
  String get emptyNotificationsTitle => 'Hộp thư trống';

  @override
  String get allReadNotificationsTitle => 'Bạn đã đọc hết thông báo rồi! 🎉';

  @override
  String get markAsReadSuccess => 'Đã đọc thông báo rùi nha! 💌';

  @override
  String get markAllAsRead => 'Đánh dấu tất cả đã đọc';

  @override
  String get allReadSuccess => 'Đã đánh dấu tất cả thông báo!';

  @override
  String get obTitle1 => 'Ghi chép thông minh';

  @override
  String get obDesc1 =>
      'Lưu lại mọi khoảnh khắc chi tiêu chỉ trong vài giây với giao diện trực quan, dễ thương.';

  @override
  String get obTitle2 => 'Quản lý ngân sách';

  @override
  String get obDesc2 =>
      'Không lo rỗng ví vào cuối tháng. Đặt mục tiêu và theo dõi tiến độ chi tiêu cực dễ.';

  @override
  String get obTitle3 => 'Bảo mật tuyệt đối';

  @override
  String get obDesc3 =>
      'Dữ liệu của bạn là của bạn. Đồng bộ đám mây an toàn và riêng tư 100%.';

  @override
  String get obSkip => 'Bỏ qua';

  @override
  String get obNext => 'Tiếp tục';

  @override
  String get obStart => 'Bắt đầu ngay';

  @override
  String get dayLabel => 'ngày';

  @override
  String get spentLabel => 'Đã tiêu';

  @override
  String budgetWarningLow(String amountSpent) {
    return 'Úi úi, hạn mức mới này còn thấp hơn cả số tiền bạn đã vung tay trong tháng ($amountSpent) đó nha! 🚨🥺';
  }

  @override
  String get analyticsSwitchPeriod => 'Giai đoạn';

  @override
  String get analyticsSwitchMonthly => 'Từng tháng';

  @override
  String analyticsMonthlyHonor(String month) {
    return 'Tháng $month';
  }

  @override
  String get analyticsLastMonthReview => 'Đổi tháng';

  @override
  String get analyticsAchievement => 'Thành Tích Của Bạn';

  @override
  String get analyticsTitleThrifty => 'Thánh Tiết Kiệm 🌿';

  @override
  String get analyticsDescThrifty =>
      'Quản lý tuyệt vời, ví tiền của bạn đang rất hạnh phúc!';

  @override
  String get analyticsTitleSpender => 'Tay Chơi Thứ Thiệt 🔥';

  @override
  String get analyticsDescSpender =>
      'Tháng này bạn đã vung tay khá mạnh, hãy cẩn thận nhé!';

  @override
  String get analyticsTitleConsistent => 'Người Kỷ Luật 🛡️';

  @override
  String get analyticsDescConsistent =>
      'Chăm chỉ ghi chép, bạn đang làm chủ tài chính rất tốt!';

  @override
  String get chooseMonthYear => 'Chọn Tháng & Năm';

  @override
  String get badgeTabTitle => 'Bộ sưu tập';

  @override
  String get badgeUnlocked => 'Đã mở khóa';

  @override
  String get badgeLocked => 'Chưa mở khóa';

  @override
  String get badgeGhostTitle => 'Chúa Tể Lười Biếng';

  @override
  String get badgeGhostDesc =>
      'Nguyên 1 tháng trời không ghi chép bất kỳ giao dịch nào. Lười thế là cùng!';

  @override
  String get badgeShopaholicTitle => 'Cơn Lốc Chốt Đơn';

  @override
  String get badgeShopaholicDesc =>
      'Vung tiền hơn 40 lần trong tháng. Shipper chắc nhẵn mặt bạn rồi!';

  @override
  String get badgeWhaleTitle => 'Đại Gia Bạo Chi';

  @override
  String get badgeWhaleDesc =>
      'Tiêu sương sương hơn 10 triệu đồng. Cho xin một vé làm quen đi sếp!';

  @override
  String get badgeSurvivalistTitle => 'Chiến Thần Sinh Tồn';

  @override
  String get badgeSurvivalistDesc =>
      'Tháng này tiêu dưới 2 triệu đồng. Kỷ luật thép hay đang húp mì tôm qua ngày vậy?';

  @override
  String get badgeNightOwlTitle => 'Cú Đêm Cháy Ví';

  @override
  String get badgeNightOwlDesc =>
      'Chốt đơn vào khung giờ thiêng từ 0h - 4h sáng. Lại lướt săn sale đúng không?';

  @override
  String get badgePaydayFlashTitle => 'Máy Xúc Ngày Lương';

  @override
  String get badgePaydayFlashDesc =>
      'Mới ngày 1 đến ngày 5 đầu tháng mà tiền đã bay màu. Tiền đúng là phù du!';

  @override
  String get badgeFoodDestroyerTitle => 'Thực Thần Càn Quét';

  @override
  String get badgeFoodDestroyerDesc =>
      'Hơn 50% số đơn là dành cho việc ăn uống. Đạo hàm của hạnh phúc là đồ ăn!';

  @override
  String get badgeWeekendStormTitle => 'Bão Táp Cuối Tuần';

  @override
  String get badgeWeekendStormDesc =>
      'Cả tuần nhịn nhục, Thứ 7 Chủ Nhật xõa tung nóc. Dân chơi thứ thiệt đây rồi!';

  @override
  String get badgeGoldfishTitle => 'Não Cá Vàng';

  @override
  String get badgeGoldfishDesc =>
      'Có tới 5 lần trở lên phải ghi bù lùi ngày cũ. Có quên mật khẩu két sắt không đấy?';

  @override
  String get badgeBrokeAFTitle => 'Đỗ Nghèo Khỉ';

  @override
  String get badgeBrokeAFDesc =>
      'Chuyên gia ghi chép hơn 10 món lắt nhắt dưới 10.000đ. Tích tiểu thành đại ráng lên!';

  @override
  String get badgeBigTicketTitle => 'Quẹt Thẻ Khét Lẹt';

  @override
  String get badgeBigTicketDesc =>
      'Một phát chốt đơn siêu to khổng lồ trị giá hơn 5 triệu đồng! Nhìn thông báo trừ tiền mà xót giùm.';

  @override
  String get badgeFirstBloodTitle => 'Khởi Đầu Mới';

  @override
  String get badgeFirstBloodDesc =>
      'Tạo thành công giao dịch đầu tiên trên ứng dụng. Chào mừng bạn!';

  @override
  String get badgeCenturionTitle => 'Trăm Trận Trăm Thắng';

  @override
  String get badgeCenturionDesc =>
      'Đạt cột mốc 100 giao dịch trọn đời. Sự kiên trì đáng kinh ngạc!';

  @override
  String get badgeBalancedTitle => 'Bậc Thầy Cân Bằng';

  @override
  String get badgeBalancedDesc =>
      'Kiểm soát chi tiêu hoàn hảo trong mức 2 đến 7 triệu đồng. Không hoang phí cũng không túng thiếu!';

  @override
  String notiMonthlySummaryTitle(String month) {
    return 'Báo cáo chi tiêu tháng $month 📊';
  }

  @override
  String notiMonthlySummaryBody(String total, String category, String emoji) {
    return 'Bạn đã tiêu $total tháng qua. $category $emoji là thủ phạm lớn nhất.';
  }

  @override
  String get notiBadgeUnlockedTitle => 'Mở khóa thành tựu mới! 🏆';

  @override
  String notiBadgeUnlockedBody(String badgeName) {
    return 'Đỉnh quá! Bạn vừa nhận được huy hiệu \"$badgeName\".';
  }

  @override
  String get notiBadgeResetTitle => 'Làm mới huy hiệu tháng 🔄';

  @override
  String get notiBadgeResetBody =>
      'Tháng mới đã sang! Các huy hiệu đua top đã được reset. Chinh phục lại nào!';

  @override
  String get congratsSingleTitle => 'Đỉnh chóp! Huy hiệu mới trình làng! 🏆';

  @override
  String get congratsMultipleTitle =>
      'Úi chà chà! Đợt này \'trúng mánh\' danh hiệu rồi! ⛈️🏆';

  @override
  String get congratsSingleSub =>
      'Hào quang rực rỡ! Bạn vừa chính thức chinh phục thành tựu:';

  @override
  String get congratsMultipleSub =>
      'Quá gke gớm! Bộ sưu tập vinh danh của bạn vừa kết nạp thêm:';

  @override
  String get congratsButton => 'Chốt luôn, quá đã! 😎';

  @override
  String get homeBadgeTitle => 'Huy chương khoe khéo';

  @override
  String get emptyBadgeText =>
      'Chưa có huy hiệu nào? Thử thách bản thân ngay đi bạn ơi! 👀';

  @override
  String get defaultUser => 'Người dùng';

  @override
  String get congratsTitle => 'Tuyệt vời! 🎉';

  @override
  String badgeOwnedMessage(String badgeName) {
    return 'Bạn đang sở hữu huy hiệu đặc quyền:\n$badgeName';
  }

  @override
  String get exploreCollection => 'Khám phá Bộ sưu tập';

  @override
  String get later => 'Để sau';

  @override
  String get badgesTitle => 'Huy hiệu';

  @override
  String get badgesSubtitle => 'Thu thập và hiển thị các thành tựu của bạn';

  @override
  String get badgeTagMonthly => 'THÁNG';

  @override
  String get badgeTagElite => 'ĐẲNG CẤP';

  @override
  String get badgeTypeMonthly => 'DANH HIỆU THÁNG';

  @override
  String get badgeTypeElite => 'THÀNH TỰU ĐẲNG CẤP';

  @override
  String get badgeLockedTitle => 'Thành Tựu Bí Ẩn';

  @override
  String get badgeLockedSecretDesc => 'Năng lượng đang tích tụ. Sắp bùng nổ...';

  @override
  String get badgeLockedDialogDesc =>
      'Thực thể này đang bị phong ấn! Hãy duy trì chuỗi giao dịch và phá vỡ giới hạn chi tiêu để kích hoạt sức mạnh đang ngủ yên này nhé. 💥';

  @override
  String get myCollectionButton => 'Bộ sưu tập của tôi';

  @override
  String get badgeHintAlmost =>
      'Bạn đã đi được hơn nửa chặng đường! Sắp thành công rồi...';

  @override
  String get badgeHintStart =>
      'Hành trình ngàn dặm bắt đầu từ một bước chân...';

  @override
  String get shareBadgeMessage =>
      'Tuyệt vời! Tôi vừa xuất sắc mở khóa huy hiệu';

  @override
  String get shareBadgeAction => 'Khoe chiến tích ✨';

  @override
  String get hintFirstBlood =>
      'Mọi hành trình vĩ đại đều bắt đầu từ một bước chân đầu tiên...';

  @override
  String get hintCenturion =>
      'Sự bền bỉ tạo nên huyền thoại. Hãy tiếp tục ghi lại những khoảnh khắc...';

  @override
  String get hintGhost =>
      'Đôi khi sự im lặng lại là âm thanh lớn nhất. Đã bao lâu rồi bạn chưa ghé thăm?';

  @override
  String get hintBigTicket =>
      'Đừng ngại chi tiêu cho những quyết định lớn xứng đáng...';

  @override
  String get hintPaydayFlash =>
      'Ngày lương về là lúc tự thưởng cho bản thân một chút nuông chiều...';

  @override
  String get hintNightOwl =>
      'Bóng tối là đồng minh của bạn. Hãy thử thanh toán khi thành phố đã ngủ say...';

  @override
  String get hintWeekendStorm =>
      'Cuối tuần là để xả hơi. Bạn đã chuẩn bị cho một cơn bão mua sắm chưa?';

  @override
  String get hintShopaholic =>
      'Đam mê không giới hạn. Đôi khi số lượng áp đảo tất cả...';

  @override
  String get hintWhale =>
      'Đại dương mênh mông cần những vị vua. Kỷ lục chi tiêu của bạn ở đâu?';

  @override
  String get hintSurvivalist =>
      'Nghệ thuật giữ tiền vĩ đại không kém việc kiếm tiền. Hãy thật tiết kiệm...';

  @override
  String get hintFoodDestroyer =>
      'Dạ dày của bạn là một vũ trụ vô tận. Hãy lấp đầy nó bằng những món ngon...';

  @override
  String get hintBrokeAF =>
      'Tích tiểu thành đại, hay nhiều khoản nhỏ làm cạn ví? Hãy chú ý những chi phí vụn vặt...';

  @override
  String get hintGoldfish =>
      'Quá khứ cần được ghi lại. Bạn có thường quên nhập giao dịch rồi phải ghi lùi ngày không?';

  @override
  String get hintBalanced =>
      'Sự hoàn hảo nằm ở điểm cân bằng. Không quá phung phí, không quá tằn tiện...';

  @override
  String get hintDefault =>
      'Bí mật đang chờ đợi những người kiên nhẫn khám phá...';

  @override
  String get markAllAsReadSuccess => 'Đã đánh dấu đọc tất cả thông báo';

  @override
  String get readMore => 'Xem thêm...';

  @override
  String get collapse => 'Thu gọn';

  @override
  String get hintSecret =>
      'Bí mật đang chờ đợi những người kiên nhẫn khám phá...';

  @override
  String progressTitle(String percent) {
    return 'Tiến độ: $percent%';
  }

  @override
  String get boastAchievement => 'Khoe chiến tích ✨';

  @override
  String get creatingImage => 'Đang tạo ảnh...';

  @override
  String get shareNow => 'Chia sẻ ngay';

  @override
  String get achievementUnlocked => 'ACHIEVEMENT UNLOCKED';

  @override
  String shareAppPromoMessage(String badgeTitle) {
    return 'Tuyệt đỉnh! Tôi vừa mở khoá huy hiệu \'$badgeTitle\' trên ứng dụng Moments U Payment! 🏆✨\n\nQuản lý chi tiêu chưa bao giờ thú vị đến thế. Cùng tải app và thiết lập kỷ lục mới nhé! 🚀\n#MomentsUPayment #Achievement';
  }

  @override
  String get shareAppPromoMessageSubTitle =>
      'trải nghiệm quản lý chi tiêu nhẹ nhàng hơn với Moments U Payment nè';

  @override
  String get registerSuccessMsg =>
      'Đăng ký tài khoản thành công rùi! Đăng nhập thui nào 💕';

  @override
  String get emailExistsError =>
      'Email này đã được đăng ký trước đó rồi bạn ơi! 🌸';

  @override
  String get registerFailedError =>
      'Đăng ký thất bại! Vui lòng kiểm tra kết nối mạng 😢';

  @override
  String get errorEmailNotFound =>
      'Email này chưa được đăng ký tài khoản rùi! 😢';

  @override
  String get errorInvalidAccount =>
      'Thông tin xác thực tài khoản không hợp lệ! ❌';

  @override
  String get errorInvalidOtp =>
      'Mã OTP không chính xác hoặc đã hết hạn mất rồi! ❌';

  @override
  String get errorMissingPassword => 'Vui lòng cung cấp mật khẩu mới!';

  @override
  String get errorDefault => 'Đã có lỗi xảy ra. Vui lòng thử lại sau!';

  @override
  String get errorIncorrectOldPassword =>
      'Ơ kìa, mật khẩu cũ chưa đúng rồi nè! Kiểm tra lại xíu nha! 🧐';

  @override
  String get errorUserNotFound =>
      'Tìm mãi không thấy tài khoản này đâu cả, bạn kiểm tra lại email xem đúng chưa nhen! 🕵️‍♀️';

  @override
  String get errorEmailAlreadyExists =>
      'Email này có chủ nhân rồi nè, thử cái khác hoặc đăng nhập đi bạn ơi! 🌸';

  @override
  String get errorInvalidCredentials =>
      'Sai mật khẩu hoặc email rồi, làm lại lần nữa là đúng nè! 🐾';

  @override
  String get errorGoogleLinked =>
      'Tài khoản này đang dùng Google rồi, đăng nhập bằng Google cho nhanh nè! 🚀';

  @override
  String get selectStartDate => 'Chọn ngày bắt đầu';

  @override
  String get selectEndDate => 'Chọn ngày kết thúc';

  @override
  String get applyButtonTitle => 'Áp dụng';

  @override
  String get monthShort => 'Th';

  @override
  String get todayChip => 'Hôm nay ☀️';

  @override
  String get pastWeekChip => 'Tuần qua 🌷';

  @override
  String get pastMonthChip => 'Tháng qua 🌙';

  @override
  String get threeMonthsChip => '3 tháng 🍄';

  @override
  String get sixMonthsChip => 'Nửa năm 🐢';

  @override
  String get filterActiveTitle => 'Bộ lọc thời gian';

  @override
  String get selectMonthLabel => 'Thời gian tổng kết';

  @override
  String get monthlySummaryTab => 'Tổng kết tháng 🌙';

  @override
  String get todayOnly => 'Chỉ trong hôm nay ☀️';

  @override
  String journeyDuration(String count) {
    return 'Hành trình $count ngày 🚀';
  }

  @override
  String get survivalStateNotSetTitle => 'Hệ thống radar';

  @override
  String get survivalStateNotSetBadge => 'Chưa kích hoạt';

  @override
  String get survivalStateNotSetHeading => 'Chưa thiết lập ví?';

  @override
  String get survivalStateNotSetPunchline =>
      'Hãy cho ví một mục tiêu sinh tồn để kích hoạt đồng hồ đếm ngược bảo vệ tài chính của bạn! 🛡️';

  @override
  String get survivalStateGodModeTitle => 'Radar sinh tồn: An Toàn';

  @override
  String get survivalStateGodModeBadge => 'Chi Tiêu Đẹp ✨';

  @override
  String get survivalStateGodModeHeading => 'Sống sót qua tháng: Rất Dễ!';

  @override
  String get survivalStateGodModePunchline =>
      'Với tốc độ này, bạn dư sức sống thảnh thơi đến hết tháng. Thần tài đang mỉm cười với bạn đó! 😎';

  @override
  String get survivalStateDangerTitle => 'Cảnh báo tốc độ';

  @override
  String get survivalStateDangerBadge => 'Đốt Hơi Nhanh ⚠️';

  @override
  String survivalStateDangerHeading(String days) {
    return 'Dự kiến cạn ví trong $days ngày';
  }

  @override
  String survivalStateDangerPunchline(String days) {
    return 'Nhịp tim ví đang tăng! Bạn sẽ \'hết máu\' trước khi tháng kết thúc $days ngày nếu không giảm ga chi tiêu nhé! 🏎️💨';
  }

  @override
  String get survivalStateApocalypseTitle => 'Báo động đỏ nguy kịch';

  @override
  String get survivalStateApocalypseBadge => 'CHẠY BẰNG OXY! 🚨';

  @override
  String survivalStateApocalypseHeading(String days) {
    return 'Ví sẽ ĐÓNG BĂNG sau $days ngày!';
  }

  @override
  String get survivalStateApocalypsePunchline =>
      '🚨 SOS! Tốc độ đốt tiền chạm ngưỡng hủy diệt! Chế độ húp mì tôm đã tự động kích hoạt, bóp phanh ngay lập tức!';

  @override
  String get survivalStateWastedTitle => 'Hệ thống sập nguồn';

  @override
  String get survivalStateWastedBadge => 'WASTED 💀';

  @override
  String get survivalStateWastedHeading => 'Bạn đã cạn sạch ví! 💸';

  @override
  String get survivalStateWastedPunchline =>
      'Nhiệm vụ thất bại! Bạn đã tiêu quá hạn mức tháng này. Hãy bấm icon cây bút phía trên để hồi sinh/cấp cứu lại chiếc ví nhé! 🕊️';

  @override
  String get setupRadarNow => 'Thiết lập ngay để kích hoạt radar';

  @override
  String spentOutOffLimit(String spent, String limit) {
    return 'Đã tiêu: $spent / $limit';
  }

  @override
  String get budgetCardCosmicMessage => 'Thông điệp vũ trụ:';

  @override
  String get budgetCardTapToView => 'Nhấn để xem lời nhắc...';

  @override
  String get budgetHeaderSubtitle =>
      'Thiết lập tấm khiên bảo vệ hầu bao thông minh của bạn.';

  @override
  String get budgetDailySafeLimitTitle => 'Hạn mức tiêu mỗi ngày';

  @override
  String get budgetStatusSafe => 'An toàn lý tưởng ✨';

  @override
  String get invalidAmountMessage => 'Vui lòng nhập số tiền hợp lệ nha! 💸';
}
