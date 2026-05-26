import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
import 'app_localizations_vi.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
    : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
        delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('en'),
    Locale('vi'),
  ];

  /// No description provided for @appName.
  ///
  /// In en, this message translates to:
  /// **'Moment u Payment'**
  String get appName;

  /// No description provided for @login.
  ///
  /// In en, this message translates to:
  /// **'Login'**
  String get login;

  /// No description provided for @register.
  ///
  /// In en, this message translates to:
  /// **'Register'**
  String get register;

  /// No description provided for @email.
  ///
  /// In en, this message translates to:
  /// **'Email Address'**
  String get email;

  /// No description provided for @password.
  ///
  /// In en, this message translates to:
  /// **'Password'**
  String get password;

  /// No description provided for @name.
  ///
  /// In en, this message translates to:
  /// **'Full Name'**
  String get name;

  /// No description provided for @welcomeBack.
  ///
  /// In en, this message translates to:
  /// **'Welcome Back! ✨'**
  String get welcomeBack;

  /// No description provided for @subTitle.
  ///
  /// In en, this message translates to:
  /// **'Moment u Payment - Sweet Expense Diary'**
  String get subTitle;

  /// No description provided for @emailHint.
  ///
  /// In en, this message translates to:
  /// **'Your email... ✨'**
  String get emailHint;

  /// No description provided for @passwordHint.
  ///
  /// In en, this message translates to:
  /// **'Secret password... 🔑'**
  String get passwordHint;

  /// No description provided for @nameHint.
  ///
  /// In en, this message translates to:
  /// **'Your cute name... ✨'**
  String get nameHint;

  /// No description provided for @loginButton.
  ///
  /// In en, this message translates to:
  /// **'Let\'s Go Inside ✨'**
  String get loginButton;

  /// No description provided for @registerButton.
  ///
  /// In en, this message translates to:
  /// **'Sign Up Account ✨'**
  String get registerButton;

  /// No description provided for @dontHaveAccount.
  ///
  /// In en, this message translates to:
  /// **'Don\'t have an account? Sign up now! 💕'**
  String get dontHaveAccount;

  /// No description provided for @emptyFieldsWarning.
  ///
  /// In en, this message translates to:
  /// **'Please don\'t leave any fields empty! 💕'**
  String get emptyFieldsWarning;

  /// No description provided for @loginSuccess.
  ///
  /// In en, this message translates to:
  /// **'Logged in successfully! ✨'**
  String get loginSuccess;

  /// No description provided for @loginCreateAccountTitle.
  ///
  /// In en, this message translates to:
  /// **'Create Account 🌸'**
  String get loginCreateAccountTitle;

  /// No description provided for @loginCreateAccountSub.
  ///
  /// In en, this message translates to:
  /// **'Join the lovely expense management world'**
  String get loginCreateAccountSub;

  /// No description provided for @newMomentTitle.
  ///
  /// In en, this message translates to:
  /// **'New Moment 📸'**
  String get newMomentTitle;

  /// No description provided for @amountHint.
  ///
  /// In en, this message translates to:
  /// **'0.00 🪙'**
  String get amountHint;

  /// No description provided for @uploadPhotoPlaceholder.
  ///
  /// In en, this message translates to:
  /// **'Take a photo of invoice / Cute moment 🌸'**
  String get uploadPhotoPlaceholder;

  /// No description provided for @categorySectionTitle.
  ///
  /// In en, this message translates to:
  /// **'Category'**
  String get categorySectionTitle;

  /// No description provided for @noteHint.
  ///
  /// In en, this message translates to:
  /// **'Short note... ✨'**
  String get noteHint;

  /// No description provided for @saveMomentButton.
  ///
  /// In en, this message translates to:
  /// **'Save Expense Moment ✨'**
  String get saveMomentButton;

  /// No description provided for @txSuccessMessage.
  ///
  /// In en, this message translates to:
  /// **'Recorded this cute expense moment! 🌸'**
  String get txSuccessMessage;

  /// No description provided for @txErrorMessage.
  ///
  /// In en, this message translates to:
  /// **'Could not save your moment, please try again! 😢'**
  String get txErrorMessage;

  /// No description provided for @catFood.
  ///
  /// In en, this message translates to:
  /// **'Food 🍰'**
  String get catFood;

  /// No description provided for @catShopping.
  ///
  /// In en, this message translates to:
  /// **'Shopping 🛍️'**
  String get catShopping;

  /// No description provided for @catTransport.
  ///
  /// In en, this message translates to:
  /// **'Transport 🚗'**
  String get catTransport;

  /// No description provided for @catEntertainment.
  ///
  /// In en, this message translates to:
  /// **'Entertainment 🎮'**
  String get catEntertainment;

  /// No description provided for @categoryOther.
  ///
  /// In en, this message translates to:
  /// **'Uncategorized'**
  String get categoryOther;

  /// No description provided for @emptyTransactionNote.
  ///
  /// In en, this message translates to:
  /// **'Nameless spending moment...'**
  String get emptyTransactionNote;

  /// No description provided for @homeGreetingDeveloper.
  ///
  /// In en, this message translates to:
  /// **'Hello, Developer! 👋'**
  String get homeGreetingDeveloper;

  /// No description provided for @homeSubGreeting.
  ///
  /// In en, this message translates to:
  /// **'How is your spending status today?'**
  String get homeSubGreeting;

  /// No description provided for @spendingMomentsTitle.
  ///
  /// In en, this message translates to:
  /// **'Your Spending Moments'**
  String get spendingMomentsTitle;

  /// No description provided for @budgetThisMonthLabel.
  ///
  /// In en, this message translates to:
  /// **'Budget This Month'**
  String get budgetThisMonthLabel;

  /// No description provided for @budgetRemainingStatus.
  ///
  /// In en, this message translates to:
  /// **'Remaining 600.000 ₫ of 1.000.000 ₫'**
  String get budgetRemainingStatus;

  /// No description provided for @budgetHealthyFeedback.
  ///
  /// In en, this message translates to:
  /// **'🎉 Awesome! You are managing your budget safely.'**
  String get budgetHealthyFeedback;

  /// No description provided for @loadingData.
  ///
  /// In en, this message translates to:
  /// **'Loading spending moments...'**
  String get loadingData;

  /// No description provided for @errorLoadData.
  ///
  /// In en, this message translates to:
  /// **'Failed to load data. Please try again!'**
  String get errorLoadData;

  /// No description provided for @retryButton.
  ///
  /// In en, this message translates to:
  /// **'Retry'**
  String get retryButton;

  /// No description provided for @emptyTransactionList.
  ///
  /// In en, this message translates to:
  /// **'No spending moments this month. Tap + to add one! 🌸'**
  String get emptyTransactionList;

  /// No description provided for @deleteDialogTitle.
  ///
  /// In en, this message translates to:
  /// **'Delete this moment?'**
  String get deleteDialogTitle;

  /// No description provided for @deleteDialogContent.
  ///
  /// In en, this message translates to:
  /// **'This action will permanently delete your spending moment and the attached receipt stored on Cloudinary.'**
  String get deleteDialogContent;

  /// No description provided for @deleteDialogCancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get deleteDialogCancel;

  /// No description provided for @deleteDialogConfirm.
  ///
  /// In en, this message translates to:
  /// **'Delete'**
  String get deleteDialogConfirm;

  /// No description provided for @deleteSuccessSnackbar.
  ///
  /// In en, this message translates to:
  /// **'Your moment and receipt image have been successfully cleaned up! ✨'**
  String get deleteSuccessSnackbar;

  /// No description provided for @deleteErrorSnackbar.
  ///
  /// In en, this message translates to:
  /// **'Failed to delete. Please check your network connection!'**
  String get deleteErrorSnackbar;

  /// No description provided for @analyticsTitle.
  ///
  /// In en, this message translates to:
  /// **'Spending Moments Analytics'**
  String get analyticsTitle;

  /// No description provided for @emptyAnalyticsData.
  ///
  /// In en, this message translates to:
  /// **'No spending moments found for this month! 📝'**
  String get emptyAnalyticsData;

  /// No description provided for @totalLabel.
  ///
  /// In en, this message translates to:
  /// **'Total'**
  String get totalLabel;

  /// No description provided for @loginErrorNotification.
  ///
  /// In en, this message translates to:
  /// **'Incorrect email or password, please try again! 😢'**
  String get loginErrorNotification;

  /// No description provided for @googleLoginErrorNotification.
  ///
  /// In en, this message translates to:
  /// **'Google sign-in failed! Please try again 🌸'**
  String get googleLoginErrorNotification;

  /// No description provided for @loginButtonText.
  ///
  /// In en, this message translates to:
  /// **'Let\'s Go inside ✨'**
  String get loginButtonText;

  /// No description provided for @loginGGButtonText.
  ///
  /// In en, this message translates to:
  /// **'Let\'s Go By Google 🚀'**
  String get loginGGButtonText;

  /// No description provided for @emailNotVerifiedAlert.
  ///
  /// In en, this message translates to:
  /// **'Email {email} is not verified yet! 🔑'**
  String emailNotVerifiedAlert(Object email);
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['en', 'vi'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en':
      return AppLocalizationsEn();
    case 'vi':
      return AppLocalizationsVi();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
