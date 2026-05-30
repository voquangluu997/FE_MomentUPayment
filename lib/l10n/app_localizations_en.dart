// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appName => 'Moment u Payment';

  @override
  String get login => 'Login';

  @override
  String get register => 'Register';

  @override
  String get email => 'Email Address';

  @override
  String get password => 'Password';

  @override
  String get name => 'Full Name';

  @override
  String get welcomeBack => 'Welcome Back! ✨';

  @override
  String get subTitle => 'Moment u Payment - Sweet Expense Diary';

  @override
  String get emailHint => 'Your email... ✨';

  @override
  String get passwordHint => 'Secret password... 🔑';

  @override
  String get nameHint => 'Your cute name... ✨';

  @override
  String get loginButton => 'Let\'s Go Inside ✨';

  @override
  String get registerButton => 'Sign Up Account ✨';

  @override
  String get dontHaveAccount => 'Don\'t have an account? Sign up now! 💕';

  @override
  String get emptyFieldsWarning => 'Please don\'t leave any fields empty! 💕';

  @override
  String get loginSuccess => 'Logged in successfully! ✨';

  @override
  String get loginCreateAccountTitle => 'Create Account 🌸';

  @override
  String get loginCreateAccountSub =>
      'Join the lovely expense management world';

  @override
  String get loginErrorNotification =>
      'Incorrect email or password, please try again! 😢';

  @override
  String get googleLoginErrorNotification =>
      'Google sign-in failed! Please try again 🌸';

  @override
  String get loginButtonText => 'Let\'s Go inside ✨';

  @override
  String get loginGGButtonText => 'Let\'s Go By Google 🚀';

  @override
  String emailNotVerifiedAlert(String email) {
    return 'Email $email is not verified yet! 🔑';
  }

  @override
  String get newMomentTitle => 'New Moment 📸';

  @override
  String get amountHint => '0.00 🪙';

  @override
  String get uploadPhotoPlaceholder =>
      'Take a photo of invoice / Cute moment 🌸';

  @override
  String get categorySectionTitle => 'Category';

  @override
  String get noteHint => 'Short note... ✨';

  @override
  String get saveMomentButton => 'Save Expense Moment ✨';

  @override
  String get txSuccessMessage => 'Recorded this cute expense moment! 🌸';

  @override
  String get txErrorMessage =>
      'Could not save your moment, please try again! 😢';

  @override
  String get emptyTransactionNote => 'Nameless payment moment...';

  @override
  String get homeSubGreeting => 'How is your payment status today?';

  @override
  String get spendingMomentsTitle => 'Your Payment Moments';

  @override
  String get loadingData => 'Loading payment moments...';

  @override
  String get errorLoadData => 'Oopsie, the data tripped and fell 🥺';

  @override
  String get retryButton => 'Give it another push 🚀';

  @override
  String get emptyTransactionList =>
      'No payment moments this month. Tap + to add one! 🌸';

  @override
  String get catFood => 'Food 🍰';

  @override
  String get catShopping => 'Shopping 🛍️';

  @override
  String get catTransport => 'Transport 🚗';

  @override
  String get catEntertainment => 'Entertainment 🎮';

  @override
  String get categoryOther => 'Uncategorized';

  @override
  String get catCustom => 'Custom... 📝';

  @override
  String get customCategoryHint => 'Name your secret category... ✨';

  @override
  String get deleteDialogTitle => 'Delete this moment?';

  @override
  String get deleteDialogContent =>
      'This action will permanently delete your payment moment and the attached receipt stored on Cloudinary.';

  @override
  String get deleteDialogCancel => 'Cancel';

  @override
  String get deleteDialogConfirm => 'Delete';

  @override
  String get deleteSuccessSnackbar =>
      'Your moment and receipt image have been successfully cleaned up! ✨';

  @override
  String get deleteErrorSnackbar =>
      'Failed to delete. Please check your network connection!';

  @override
  String get analyticsTitle => 'Wallet X-Ray 🔍';

  @override
  String get emptyAnalyticsData =>
      'Nothing here! Your wallet is safely untouched 🐥';

  @override
  String get totalLabel => 'Total Damage 💸';

  @override
  String get today => 'Today';

  @override
  String get yesterday => 'Yesterday';

  @override
  String get thisMonth => 'This month';

  @override
  String get unknownMonth => 'Unknown month';

  @override
  String get noMomentsAvailable => 'No moments available';

  @override
  String get cameraTapInstruction => 'Tap here to snap your receipt! 📸';

  @override
  String get galleryPickAction => 'Or pick a cute photo from your gallery ✨';

  @override
  String get galleryChangeAction => 'Change photo from your collection 🌸';

  @override
  String get amountSectionTitle => 'TOTAL DAMAGE THIS TIME 💰';

  @override
  String get noteSectionTitle => 'A LITTLE CHITCHAT ABOUT THIS 💬';

  @override
  String monthLabel(String month, String year) {
    return '$month/$year';
  }

  @override
  String get budgetTitle => 'Smart Wallet Goals 🎯';

  @override
  String get budgetSectionTitle => 'THIS MONTH BUDGET LIMIT 🌟';

  @override
  String get budgetHint => 'e.g., 5.000.000';

  @override
  String get budgetSaveButton => 'Lock This Budget! 🚀';

  @override
  String get budgetSuccessMessage =>
      'New limit saved! Let\'s spend wisely together! 🥰';

  @override
  String get budgetErrorMessage =>
      'Oops, something went wrong. Couldn\'t save your budget! 😿';

  @override
  String get monthBudget => 'This Month\'s Budget';

  @override
  String get changeLimit => 'Edit Limit';

  @override
  String get budgetMenuTitle => 'Set Budget Limit 🎯';

  @override
  String get budgetThisMonthLabel => 'This month\'s budget';

  @override
  String get budgetNotSetStatus => 'No spending limit set yet';

  @override
  String get budgetNotSetFeedback =>
      'You haven\'t set a budget yet, let\'s set one! 🎯✨';

  @override
  String get budgetHealthyFeedback => 'Your wallet is in good shape! 💖';

  @override
  String get budgetHalfSpentFeedback =>
      'You\'ve spent more than half, be a bit more careful! ⏳✨';

  @override
  String get budgetWarningFeedback =>
      'Oops, your wallet is getting thin, slow down a bit! 🥺💸';

  @override
  String get budgetOverBudgetFeedback =>
      'Oh no! You have exceeded your budget limit! 🚨😭';

  @override
  String get budgetStatusGood =>
      'Your spending this month is very reasonable! 👍';

  @override
  String get budgetStatusWarning =>
      'Your wallet has less than 15% left. Time to tighten your belt! 💸';

  @override
  String get budgetStatusOver =>
      'Oh no! You have exceeded your budget limit! 🚨';

  @override
  String get budgetStatusHalf =>
      'You\'ve spent more than half, be a bit more careful! ⏳';

  @override
  String remainingAmount(String amount) {
    return 'Remaining: $amountđ';
  }

  @override
  String dailySuggestion(String money) {
    return '💡 Suggestion: You should spend a maximum of $moneyđ today to stay safe.';
  }

  @override
  String budgetOverspentStatus(String overspent, String limit) {
    return 'Over budget by $overspent (Limit: $limit). 🥺💸';
  }

  @override
  String budgetSpentStatus(String spent, String limit) {
    return 'Spent $spent out of $limit';
  }

  @override
  String budgetDetailedStatus(String spent, String remaining, String days) {
    return 'Splurged $spent 💸 • $remaining left to survive $days days 🏕️';
  }

  @override
  String budgetDetailedStatusToday(String spent, String remaining) {
    return 'Splurged $spent 💸 • Survive today with $remaining left! 🥺';
  }

  @override
  String budgetOverspentDetailedStatus(
    String spent,
    String overspent,
    String days,
  ) {
    return 'Burnt $spent 💸 • In the red $overspent with $days days to survive! 🚨';
  }

  @override
  String budgetOverspentDetailedStatusToday(String spent, String overspent) {
    return 'Burnt $spent 💸 • Ended the month $overspent over budget 😭';
  }

  @override
  String budgetSafeDaily(String amount) {
    return '💡 Survival tip: Spend around $amount/day to land safely! 🪂';
  }

  @override
  String budgetSafeToday(String amount) {
    return '💡 Survival tip: Keep it under $amount for today! 🥺';
  }

  @override
  String get hello => 'Hello,';

  @override
  String get notificationSettingsTitle => 'Notification Settings';

  @override
  String get notiCategoryBudget => 'Budget Alerts';

  @override
  String get notiCategoryReminder => 'Recurring Reminders';

  @override
  String get notiCategorySecurity => 'System & Security';

  @override
  String get notiCategorySharedWallet => 'Shared Wallet Activities';

  @override
  String get notiBudgetWarningTitle => 'Budget Warning! 🚨';

  @override
  String notiBudgetWarningBody(String wallet, String percent) {
    return 'Heads up: Your $wallet has reached $percent%. Time to slow down!';
  }

  @override
  String get notiBudgetExceededTitle => 'Budget Exceeded! 💸';

  @override
  String notiBudgetExceededBody(String wallet, String percent) {
    return 'Red alert: Your $wallet is at $percent%. Survival mode activated!';
  }

  @override
  String get notiEmailVerifiedTitle => 'Verification successful! 🛡️';

  @override
  String get notiEmailVerifiedBody =>
      'Your account is now secure. Let\'s start managing your budget!';

  @override
  String notiAggregatedTxBody(String budgetName, String count) {
    return 'Wallet $budgetName has $count new transaction changes aggregated.';
  }

  @override
  String get notiFirstLoginReminderTitle => 'A tiny tap to secure our bond! 💖';

  @override
  String notiFirstLoginReminderBody(String name) {
    return 'Hey $name, please check your inbox and verify your email! After 30 days without verification, your account will go into \'hibernation\' mode, and we\'d miss you so much! 🥺🌱';
  }

  @override
  String get notiFirstTxnTitle => 'Your first Moment awaits! 🪄';

  @override
  String get notiFirstTxnBody =>
      'Your wallet is ready! Let\'s record your very first expense (Moment) today. Tap here! 👇💸';

  @override
  String get notiSetBudgetTitle => 'Shield your wallet! 🛡️';

  @override
  String get notiSetBudgetBody =>
      'Set a budget limit so I can gently warn you before overspending. Tap to set it up! 🎯💖';

  @override
  String get forgotPasswordDialogTitle => 'Recover Password';

  @override
  String get forgotPasswordDialogDesc =>
      'We will send an authentication code (OTP) or a reset link to your email.';

  @override
  String get accountEmail => 'Account Email';

  @override
  String get cancel => 'Cancel';

  @override
  String get sendCode => 'Send Code';

  @override
  String forgotPwSuccess(String email) {
    return 'Recovery code sent to: $email';
  }

  @override
  String get forgotPwError => 'Failed to send recovery code. Please try again.';

  @override
  String get resetPwDialogTitle => 'Reset New Password';

  @override
  String get authEmail => 'Authentication Email';

  @override
  String get otpCode => 'Authentication Code (OTP / Token)';

  @override
  String get newPassword => 'New Password';

  @override
  String get confirm => 'Confirm';

  @override
  String get resetPwSuccess =>
      'Your password has been successfully reset! Please login.';

  @override
  String get resetPwError => 'Invalid or expired authentication code.';

  @override
  String get settingsAndUtilities => 'Settings & Utilities';

  @override
  String get language => 'Language';

  @override
  String get english => 'English';

  @override
  String get vietnamese => 'Vietnamese';

  @override
  String get currencyUnit => 'Currency Unit';

  @override
  String get currentlyUsing => 'Currently using';

  @override
  String get darkMode => 'Dark Mode';

  @override
  String get lightTheme => 'Light Theme';

  @override
  String get notificationSettingsSubtitle => 'Manage alerts & expenses';

  @override
  String get changePassword => 'Change Password';

  @override
  String get changePasswordSubtitle => 'Change current account password';

  @override
  String get helpCenter => 'Help Center';

  @override
  String get helpCenterSubtitle => 'FAQ & Support Contact';

  @override
  String get logout => 'Logout';

  @override
  String get logoutSubtitle => 'Leave the current login session';

  @override
  String get newPasswordTitle => 'New Password';

  @override
  String get currentPassword => 'Current Password';

  @override
  String get update => 'Update';

  @override
  String get updatePasswordSuccess => 'Password updated successfully!';

  @override
  String get updatePasswordError =>
      'Incorrect current password or connection error.';

  @override
  String get forgotPasswordText => 'Forgot password?';

  @override
  String get resetPasswordText => 'Reset password';

  @override
  String get forgotPasswordTitle => 'Recover Password';

  @override
  String get forgotPasswordSubtitle =>
      'The system will send a verification code (OTP) or reset link to your Email.';

  @override
  String get emailAccountLabel => 'Account Email';

  @override
  String get cancelButton => 'Cancel';

  @override
  String get sendCodeButton => 'Send Code';

  @override
  String get sendCodeSuccess => 'Recovery code sent to email:';

  @override
  String get resetPasswordTitle => 'Reset New Password';

  @override
  String get emailVerificationLabel => 'Verification Email';

  @override
  String get otpLabel => 'Verification Code (OTP / Token)';

  @override
  String get newPasswordLabel => 'New Password';

  @override
  String get confirmButton => 'Confirm';

  @override
  String get resetPasswordSuccess =>
      'Your password has been changed successfully! Please log in.';

  @override
  String get spendingTrend => 'Trend';

  @override
  String get spendingStructure => 'Where did my money go? 🥧';

  @override
  String get customDate => 'Custom';

  @override
  String get avgPerDay => 'Daily Poof 🕊️';

  @override
  String get timeFrame => 'Days';

  @override
  String get pastWeek => 'Past Week 🌷';

  @override
  String get pastMonth => 'Past Month 🌙';

  @override
  String get threeMonths => '3 Months 🍄';

  @override
  String get sixMonths => 'Half a Year 🐢';

  @override
  String get pastYear => 'Past Year 🌟';

  @override
  String get fromDate => 'From when 🐾';

  @override
  String get toDate => 'To when 🌿';

  @override
  String get repeatCycle => 'Time Loop ⏳';

  @override
  String get days => 'days';

  @override
  String get buyDevCoffeeTitle => 'Buy the Dev a Coffee ☕';

  @override
  String get buyDevCoffeeSubtitle => 'Keep the dev awake & coding happily! 🥰';

  @override
  String get scanToSpreadLoveTitle => 'Scan to spread love 💖';

  @override
  String get scanToSpreadLoveSubtitle =>
      'Every coffee you send mercilessly destroys a bug! Thank you for being Moment U\'s absolute MVP! ✨';

  @override
  String get missingQrMessage =>
      'Please add QR image to:\nassets/images/momo_qr.png';

  @override
  String get closeButton => 'Close';

  @override
  String get buyMeACoffeeBtn => 'Or via Buy Me a Coffee ☕';

  @override
  String get helpCenterDialogTitle => 'Help Center 🎧';

  @override
  String get helpCenterDialogMessage =>
      'If you encounter any bugs or have brilliant ideas to make Moment U better, drop us an email! We\'re all ears. 🥰';

  @override
  String get contactEmail => 'momentu.support@gmail.com';

  @override
  String get appVersionTitle => 'Version';

  @override
  String get appVersion => 'v1.0.0';

  @override
  String get dailyAllowance => 'Daily average';

  @override
  String get quickSuggestions => 'Quick suggestions';

  @override
  String get budgetTip =>
      'Tip: Set your budget about 20% lower than your actual income to ensure you always have savings! 🌟';

  @override
  String get emptyFilterTransaction => 'No transactions in this date range 🌸';

  @override
  String get from => 'From';

  @override
  String get to => 'to';

  @override
  String get month => 'Month';

  @override
  String get day => 'Day';

  @override
  String get mon => 'Mon';

  @override
  String get tue => 'Tue';

  @override
  String get wed => 'Wed';

  @override
  String get thu => 'Thu';

  @override
  String get fri => 'Fri';

  @override
  String get sat => 'Sat';

  @override
  String get sun => 'Sun';
}
