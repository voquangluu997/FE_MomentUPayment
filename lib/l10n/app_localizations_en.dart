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
  String get emptyTransactionNote => 'No note';

  @override
  String get homeGreetingDeveloper => 'Hello, Developer! 👋';

  @override
  String get homeSubGreeting => 'How is your payment status today?';

  @override
  String get spendingMomentsTitle => 'Your Payment Moments';

  @override
  String get budgetThisMonthLabel => 'Budget This Month';

  @override
  String get budgetRemainingStatus => 'Remaining 600.000 ₫ of 1.000.000 ₫';

  @override
  String get budgetHealthyFeedback =>
      '🎉 Awesome! You are managing your budget safely.';

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
  String get analyticsTitle => 'Payment Moments Analytics';

  @override
  String get emptyAnalyticsData =>
      'No payment moments found for this month! 📝';

  @override
  String get totalLabel => 'Total';

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
  String emailNotVerifiedAlert(Object email) {
    return 'Email $email is not verified yet! 🔑';
  }

  @override
  String get today => 'Today';

  @override
  String get yesterday => 'Yesterday';

  @override
  String monthLabel(Object month, Object year) {
    return '$month/$year';
  }

  @override
  String get thisMonth => 'This month';

  @override
  String get unknownMonth => 'Unknown month';

  @override
  String get noMomentsAvailable => 'No moments available';
}
