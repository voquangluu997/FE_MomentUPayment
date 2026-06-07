// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appName => 'Moments u Payment';

  @override
  String get login => 'Login';

  @override
  String get register => 'Register';

  @override
  String get email => 'Email Address';

  @override
  String get password => 'Password';

  @override
  String get name => 'Username';

  @override
  String get welcomeBack => 'Welcome Back! ✨';

  @override
  String get subTitle => 'Moments U Payment - Sweet Expense Diary';

  @override
  String get subTitle1 => 'Moments U Payment';

  @override
  String get subTitle2 => 'Sweet Expense Diary';

  @override
  String get emailHint => 'Your email... ✨';

  @override
  String get passwordHint => 'Secret password... 🔑';

  @override
  String get nameHint => 'Your cute name... ✨';

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
  String get loginButtonText => 'Let\'s Go Inside ✨';

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
  String get spendingMomentsTitle => 'Moments U Payment';

  @override
  String get loadingData => 'Loading payment moments...';

  @override
  String get errorLoadData => 'Error loading data';

  @override
  String get retryButton => 'Give it another push 🚀';

  @override
  String get emptyTransactionList => 'No moments yet';

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
  String get cameraPickActionShort => 'Take a photo';

  @override
  String get galleryChangeAction => 'Change photo from your collection 🌸';

  @override
  String get galleryChangeActionShort => 'Gallery';

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
  String get budgetStatusWarning => 'S.O.S!';

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
    return 'Wallet $budgetName has $count new moment changes aggregated.';
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
  String get darkMode => 'Night owl mode';

  @override
  String get lightTheme => 'Light Theme';

  @override
  String get darkTheme => 'Dark Theme';

  @override
  String get notificationSettingsSubtitle => 'Manage alerts & expenses';

  @override
  String get changePasswordSubtitle => 'Change current account password';

  @override
  String get helpCenter => 'Help Center';

  @override
  String get helpCenterSubtitle => 'FAQ & Support Contact';

  @override
  String get logout => 'Catch ya later!';

  @override
  String get logoutSubtitle => 'Leave the current login session';

  @override
  String get newPasswordTitle => 'New Password';

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
  String get analyticsTitle => 'Wallet X-Ray 🔍';

  @override
  String get spendingTrend => 'Trend';

  @override
  String get spendingStructure => 'Where did my money go? 🥧';

  @override
  String get customDate => 'Custom';

  @override
  String get totalLabel => 'Total Spending';

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
  String get emptyAnalyticsData =>
      'Nothing here! Your wallet is safely untouched 🐥';

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
  String get helpCenterDialogTitle => 'Lost? Let me help! 🎧';

  @override
  String get helpCenterDialogMessage =>
      'If you encounter any bugs or have brilliant ideas to make Moment U better, drop us an email! We\'re all ears. 🥰';

  @override
  String get contactEmail => 'momentupayment.support@gmail.com';

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
  String get emptyFilterTransaction => 'No moments found for this period';

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

  @override
  String get accountSettings => 'Your Little Corner ✨';

  @override
  String get accountSettingsSubtitle =>
      'Tweak your name, fresh pic & lock the safe';

  @override
  String get fullName => 'Your cool name';

  @override
  String get save => 'Save it!';

  @override
  String get changePassword => 'Change Password';

  @override
  String get currentPassword => 'Current Password';

  @override
  String get updateError => 'Oops, something went wrong...';

  @override
  String get changeAvatar => 'Change avatar';

  @override
  String get saveSettingsSuccess => 'Profile updated!';

  @override
  String get personalInfo => 'Personal information';

  @override
  String get security => 'Security';

  @override
  String get updateProfile => 'Update profile';

  @override
  String get updatePassword => 'Update password';

  @override
  String get updateSuccess => 'Update successful!';

  @override
  String get updateFailed => 'Update failed!';

  @override
  String get nameEmptyError => 'Name cannot be empty!';

  @override
  String get passwordLengthError =>
      'Password must be at least 4 characters long!';

  @override
  String get systemError => 'System error!';

  @override
  String get incorrectPassword => 'Current password is incorrect!';

  @override
  String get maxOneYearWarning =>
      'Moment U only supports viewing up to 1 year! 🗓️';

  @override
  String get wrongOldPassword => 'Incorrect current password.';

  @override
  String get userNotFoundError => 'User not found.';

  @override
  String get weakPasswordError => 'The new password is too weak.';

  @override
  String get noChangeWarning => 'Your information has not changed! ✨';

  @override
  String get fillPasswordFieldsError => 'Please enter all password fields.';

  @override
  String get samePasswordError =>
      'New password cannot be the same as old password.';

  @override
  String get addSuccessMessage => 'Added successfully! ✨';

  @override
  String get updateSuccessMessage => 'Updated successfully! ✨';

  @override
  String get futureDateError => 'You cannot add moments for future dates!';

  @override
  String get deleteSuccessMessage => 'Deleted successfully!';

  @override
  String get deleteErrorMessage => 'An error occurred while deleting';

  @override
  String get premiumGroupMomentsTitle => 'Group Moments 👑';

  @override
  String get premiumGroupMomentsSubtitle =>
      'Group wallet feature is temporarily locked in beta.';

  @override
  String get navHome => 'Home';

  @override
  String get navBudget => 'Budget';

  @override
  String get navAnalytics => 'Analytics';

  @override
  String get navPremium => 'Premium';

  @override
  String get navMenu => 'Menu';

  @override
  String get setBudgetTitle => 'Set Budget';

  @override
  String get monthlyBudgetLimit => 'Monthly spending limit';

  @override
  String get saveConfiguration => 'Save Configuration';

  @override
  String get premiumFeatureTitle => 'Premium Feature';

  @override
  String get premiumFeatureDesc =>
      'Group Moments shared wallet is currently locked. Upgrade to Premium to unlock shared cash flow and real-time co-management with your partner and family.';

  @override
  String get unlockPremiumNow => 'Unlock Premium Now';

  @override
  String get budgetLoadError => 'Failed to load budget';

  @override
  String get budgetOverspentLabel => 'Overspent';

  @override
  String get budgetRemainingLabel => 'Remaining';

  @override
  String get budgetLastDay => 'Today is the final day!';

  @override
  String budgetRemainingDays(int days) {
    return '$days days left';
  }

  @override
  String get budgetStatusReasonable => 'Looking good';

  @override
  String get budgetStatusNotSet => 'Not set yet';

  @override
  String get budgetStatusOvertarget => 'Wallet\'s crying';

  @override
  String get budgetStatusHalfSpent => 'Halfway there';

  @override
  String get budgetDailyNotSet => 'Set a limit so I can guard your wallet! 🥺';

  @override
  String get budgetDailyOvertarget =>
      'Out of quota! Time for a breath-of-air diet... 💸';

  @override
  String budgetDailySafeLimit(String amount) {
    return 'Keep it steady! Spend max $amount per day, okay? 🥰';
  }

  @override
  String get emptyTransactionSubtitle =>
      'Log your first expense now so your wallet stays perfectly in check! ✨';

  @override
  String get deleteActionLabel => 'Delete';

  @override
  String transactionCount(int count) {
    return '$count transactions';
  }

  @override
  String get transactionTime => 'Time';

  @override
  String get addMomentTooltip => 'Quickly create a payment moment ✨';

  @override
  String get notificationListTitle => 'Notifications';

  @override
  String get allNotifications => 'All';

  @override
  String get unreadNotifications => 'Unread';

  @override
  String get emptyNotificationsTitle => 'Inbox is empty';

  @override
  String get allReadNotificationsTitle => 'You\'ve read all notifications! 🎉';

  @override
  String get markAsReadSuccess => 'Marked as read successfully! 💌';

  @override
  String get markAllAsRead => 'Mark all as read';

  @override
  String get allReadSuccess => 'All notifications marked as read!';

  @override
  String get obTitle1 => 'Smart Tracking';

  @override
  String get obDesc1 =>
      'Log your daily expenses in seconds with an intuitive and cute interface.';

  @override
  String get obTitle2 => 'Budget Management';

  @override
  String get obDesc2 =>
      'No more empty wallets. Set goals and effortlessly track your spending progress.';

  @override
  String get obTitle3 => 'Absolute Privacy';

  @override
  String get obDesc3 =>
      'Your data belongs to you. 100% private and secure cloud synchronization.';

  @override
  String get obSkip => 'Skip';

  @override
  String get obNext => 'Next';

  @override
  String get obStart => 'Get Started';

  @override
  String get dayLabel => 'day';

  @override
  String get spentLabel => 'Spent';

  @override
  String budgetWarningLow(String amountSpent) {
    return 'Uh-oh, this new limit is even lower than the amount you\'ve already spent this month ($amountSpent)! 🚨🥺';
  }

  @override
  String get analyticsSwitchPeriod => 'By Period';

  @override
  String get analyticsSwitchMonthly => 'Monthly Summary';

  @override
  String analyticsMonthlyHonor(String month) {
    return 'Honor of Month $month';
  }

  @override
  String get analyticsLastMonthReview => 'Last Month Review';

  @override
  String get analyticsAchievement => 'Your Achievement';

  @override
  String get analyticsTitleThrifty => 'Thrifty Ninja 🌿';

  @override
  String get analyticsDescThrifty =>
      'Great management, your wallet is very happy!';

  @override
  String get analyticsTitleSpender => 'Big Spender 🔥';

  @override
  String get analyticsDescSpender =>
      'You spent quite heavily this month, be careful!';

  @override
  String get analyticsTitleConsistent => 'Discipline Master 🛡️';

  @override
  String get analyticsDescConsistent =>
      'Diligent tracking, you are mastering your finances!';

  @override
  String get chooseMonthYear => 'Choose Month / Year';

  @override
  String get badgeTabTitle => 'My Badges';

  @override
  String get badgeUnlocked => 'Unlocked';

  @override
  String get badgeLocked => 'Locked';

  @override
  String get badgeGhostTitle => 'The Ultimate Sloth';

  @override
  String get badgeGhostDesc =>
      'Didn\'t log a single transaction all month. Talk about lazy!';

  @override
  String get badgeShopaholicTitle => 'Checkout Tornado';

  @override
  String get badgeShopaholicDesc =>
      'Logged over 40 transactions this month. The delivery guy probably knows you by name now!';

  @override
  String get badgeWhaleTitle => 'The Great Whale';

  @override
  String get badgeWhaleDesc =>
      'Casually dropped over \$500 this month. Mind if we become friends, boss?';

  @override
  String get badgeSurvivalistTitle => 'Survival God';

  @override
  String get badgeSurvivalistDesc =>
      'Spent under \$100 this month. Iron discipline or just eating instant noodles everyday?';

  @override
  String get badgeNightOwlTitle => 'Midnight Burner';

  @override
  String get badgeNightOwlDesc =>
      'Made a transaction between 12 AM and 4 AM. 2 AM sale hunting again, huh?';

  @override
  String get badgePaydayFlashTitle => 'Payday Evaporator';

  @override
  String get badgePaydayFlashDesc =>
      'Spent heavily between the 1st and 5th of the month. Money is just an illusion!';

  @override
  String get badgeFoodDestroyerTitle => 'Foodie Destroyer';

  @override
  String get badgeFoodDestroyerDesc =>
      'Over 50% of your transactions went to food. The true path to happiness!';

  @override
  String get badgeWeekendStormTitle => 'Weekend Hurricane';

  @override
  String get badgeWeekendStormDesc =>
      'Held back all week just to go wild on Saturday or Sunday. A true party animal!';

  @override
  String get badgeGoldfishTitle => 'Goldfish Brain';

  @override
  String get badgeGoldfishDesc =>
      'Logged 5 or more backdated expenses. Did you forget your phone password too?';

  @override
  String get badgeBrokeAFTitle => 'Broke AF';

  @override
  String get badgeBrokeAFDesc =>
      'Logged over 10 tiny transactions under \$0.5. Every penny counts, keep it up!';

  @override
  String get badgeBigTicketTitle => 'Swiped & Scorched';

  @override
  String get badgeBigTicketDesc =>
      'One giant transaction over \$250! Even looking at the bank notification hurts.';

  @override
  String get badgeFirstBloodTitle => 'First Blood';

  @override
  String get badgeFirstBloodDesc =>
      'Logged your very first transaction. Welcome to the club!';

  @override
  String get badgeCenturionTitle => 'The Centurion';

  @override
  String get badgeCenturionDesc =>
      'Reached 100 total transactions. What a dedication!';

  @override
  String get badgeBalancedTitle => 'Zen Master';

  @override
  String get badgeBalancedDesc =>
      'Kept your monthly spending perfectly balanced between \$100 and \$350.';

  @override
  String notiMonthlySummaryTitle(String month) {
    return 'Spending Report: Month $month 📊';
  }

  @override
  String notiMonthlySummaryBody(String total, String category, String emoji) {
    return 'You spent $total last month. $category $emoji was your biggest expense.';
  }

  @override
  String get notiBadgeUnlockedTitle => 'New Achievement Unlocked! 🏆';

  @override
  String notiBadgeUnlockedBody(String badgeName) {
    return 'Awesome! You have earned the \"$badgeName\" badge.';
  }

  @override
  String get notiBadgeResetTitle => 'Monthly Badges Reset 🔄';

  @override
  String get notiBadgeResetBody =>
      'A new month begins! Monthly rankings have been reset. Time to conquer them again!';

  @override
  String get congratsSingleTitle => 'Boom! New Badge on the Block! 🏆';

  @override
  String get congratsMultipleTitle =>
      'Look at You! Catching a Shower of Badges! ⛈️🏆';

  @override
  String get congratsSingleSub => 'Absolute legend! You just conquered:';

  @override
  String get congratsMultipleSub =>
      'Unstoppable! Your collection just welcomed a fresh squad:';

  @override
  String get congratsButton => 'Sweet! Let\'s gooo! 😎';

  @override
  String get homeBadgeTitle => 'Flex Zone';

  @override
  String get emptyBadgeText =>
      'No badges yet? Time to flex your financial superpowers! 👀';

  @override
  String get defaultUser => 'User';

  @override
  String get congratsTitle => 'Wonderful! 🎉';

  @override
  String badgeOwnedMessage(String badgeName) {
    return 'You own an exclusive badge:\n$badgeName';
  }

  @override
  String get exploreCollection => 'Explore Collection';

  @override
  String get later => 'Later';

  @override
  String get badgesTitle => 'Badges';

  @override
  String get badgesSubtitle => 'Collect and display your achievements';

  @override
  String get badgeTagMonthly => 'MONTHLY';

  @override
  String get badgeTagElite => 'ELITE';

  @override
  String get badgeTypeMonthly => 'MONTHLY BADGE';

  @override
  String get badgeTypeElite => 'ELITE ACHIEVEMENT';

  @override
  String get badgeLockedTitle => 'Mysterious Relic';

  @override
  String get badgeLockedSecretDesc =>
      'Energy is building up. Ready to explode...';

  @override
  String get badgeLockedDialogDesc =>
      'This entity is currently sealed! Maintain your transaction streak and break your spending limits to awaken this dormant power. 💥';

  @override
  String get myCollectionButton => 'My Collection';

  @override
  String get badgeHintAlmost => 'You are halfway there! Keep it up...';

  @override
  String get badgeHintStart =>
      'A journey of a thousand miles begins with a single step...';

  @override
  String get shareBadgeMessage => 'Awesome! I just unlocked the badge';

  @override
  String get shareBadgeAction => 'Share Achievement ✨';

  @override
  String get hintFirstBlood =>
      'Every great journey begins with a single step...';

  @override
  String get hintCenturion =>
      'Persistence creates legends. Keep recording those moments...';

  @override
  String get hintGhost =>
      'Sometimes silence is the loudest sound. How long has it been since you last visited?';

  @override
  String get hintBigTicket =>
      'Don\'t hesitate to splurge on those worthy big decisions...';

  @override
  String get hintPaydayFlash =>
      'Payday is the time to treat yourself to a little indulgence...';

  @override
  String get hintNightOwl =>
      'Darkness is your ally. Try making a transaction while the city sleeps...';

  @override
  String get hintWeekendStorm =>
      'Weekends are for unwinding. Are you ready for a shopping storm?';

  @override
  String get hintShopaholic =>
      'Passion has no limits. Sometimes quantity trumps everything...';

  @override
  String get hintWhale =>
      'The vast ocean needs kings. Where\'s your spending record?';

  @override
  String get hintSurvivalist =>
      'The art of saving is just as great as earning. Stay frugal...';

  @override
  String get hintFoodDestroyer =>
      'Your stomach is an endless universe. Fill it with something delicious...';

  @override
  String get hintBrokeAF =>
      'Small expenses add up. Watch those tiny costs that drain your wallet...';

  @override
  String get hintGoldfish =>
      'The past needs to be recorded. Do you often forget to enter transactions and have to backdate them?';

  @override
  String get hintBalanced =>
      'Perfection lies in balance. Not too extravagant, not too frugal...';

  @override
  String get hintDefault =>
      'Secrets await those patient enough to discover them...';

  @override
  String get markAllAsReadSuccess => 'All notifications marked as read';

  @override
  String get readMore => 'Read more...';

  @override
  String get collapse => 'Collapse';

  @override
  String get hintSecret =>
      'Secrets await those who are patient enough to explore...';

  @override
  String progressTitle(String percent) {
    return 'Progress: $percent%';
  }

  @override
  String get boastAchievement => 'Show off ✨';

  @override
  String get creatingImage => 'Creating image...';

  @override
  String get shareNow => 'Share now';

  @override
  String get achievementUnlocked => 'ACHIEVEMENT UNLOCKED';

  @override
  String shareAppPromoMessage(String badgeTitle) {
    return 'Awesome! I just unlocked the \'$badgeTitle\' badge on Moments U Payment! 🏆✨\n\nTracking expenses has never been this fun. Download the app and let\'s set new records together! 🚀\n#MomentsUPayment #Achievement';
  }

  @override
  String get shareAppPromoMessageSubTitle =>
      'I\'ve been using Moment U to track my moments and spending. Thought you might like it too.';

  @override
  String get registerSuccessMsg =>
      'Registration successful! Time to log in and start! 💕';

  @override
  String get emailExistsError =>
      'This email has already been registered, friend! 🌸';

  @override
  String get registerFailedError =>
      'Registration failed! Please check your network connection 😢';
}
