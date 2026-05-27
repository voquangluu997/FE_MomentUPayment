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
  String get homeGreetingDeveloper => 'Hello, Developer! 👋';

  @override
  String get homeSubGreeting => 'How is your payment status today?';

  @override
  String get spendingMomentsTitle => 'Your Payment Moments';

  @override
  String get loadingData => 'Loading payment moments...';

  @override
  String get errorLoadData => 'Failed to load data. Please try again!';

  @override
  String get retryButton => 'Retry';

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
  String get analyticsTitle => 'Details here!!';

  @override
  String get emptyAnalyticsData =>
      'No payment moments found for this month! 📝';

  @override
  String get totalLabel => 'Total';

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
}
