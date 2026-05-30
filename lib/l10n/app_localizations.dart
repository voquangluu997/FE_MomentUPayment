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
  String emailNotVerifiedAlert(String email);

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

  /// No description provided for @emptyTransactionNote.
  ///
  /// In en, this message translates to:
  /// **'Nameless payment moment...'**
  String get emptyTransactionNote;

  /// No description provided for @homeSubGreeting.
  ///
  /// In en, this message translates to:
  /// **'How is your payment status today?'**
  String get homeSubGreeting;

  /// No description provided for @spendingMomentsTitle.
  ///
  /// In en, this message translates to:
  /// **'Your Payment Moments'**
  String get spendingMomentsTitle;

  /// No description provided for @loadingData.
  ///
  /// In en, this message translates to:
  /// **'Loading payment moments...'**
  String get loadingData;

  /// No description provided for @errorLoadData.
  ///
  /// In en, this message translates to:
  /// **'Oopsie, the data tripped and fell 🥺'**
  String get errorLoadData;

  /// No description provided for @retryButton.
  ///
  /// In en, this message translates to:
  /// **'Give it another push 🚀'**
  String get retryButton;

  /// No description provided for @emptyTransactionList.
  ///
  /// In en, this message translates to:
  /// **'No payment moments this month. Tap + to add one! 🌸'**
  String get emptyTransactionList;

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

  /// No description provided for @catCustom.
  ///
  /// In en, this message translates to:
  /// **'Custom... 📝'**
  String get catCustom;

  /// No description provided for @customCategoryHint.
  ///
  /// In en, this message translates to:
  /// **'Name your secret category... ✨'**
  String get customCategoryHint;

  /// No description provided for @deleteDialogTitle.
  ///
  /// In en, this message translates to:
  /// **'Delete this moment?'**
  String get deleteDialogTitle;

  /// No description provided for @deleteDialogContent.
  ///
  /// In en, this message translates to:
  /// **'This action will permanently delete your payment moment and the attached receipt stored on Cloudinary.'**
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
  /// **'Wallet X-Ray 🔍'**
  String get analyticsTitle;

  /// No description provided for @emptyAnalyticsData.
  ///
  /// In en, this message translates to:
  /// **'Nothing here! Your wallet is safely untouched 🐥'**
  String get emptyAnalyticsData;

  /// No description provided for @totalLabel.
  ///
  /// In en, this message translates to:
  /// **'Total Damage 💸'**
  String get totalLabel;

  /// No description provided for @today.
  ///
  /// In en, this message translates to:
  /// **'Today'**
  String get today;

  /// No description provided for @yesterday.
  ///
  /// In en, this message translates to:
  /// **'Yesterday'**
  String get yesterday;

  /// No description provided for @thisMonth.
  ///
  /// In en, this message translates to:
  /// **'This month'**
  String get thisMonth;

  /// No description provided for @unknownMonth.
  ///
  /// In en, this message translates to:
  /// **'Unknown month'**
  String get unknownMonth;

  /// No description provided for @noMomentsAvailable.
  ///
  /// In en, this message translates to:
  /// **'No moments available'**
  String get noMomentsAvailable;

  /// No description provided for @cameraTapInstruction.
  ///
  /// In en, this message translates to:
  /// **'Tap here to snap your receipt! 📸'**
  String get cameraTapInstruction;

  /// No description provided for @galleryPickAction.
  ///
  /// In en, this message translates to:
  /// **'Or pick a cute photo from your gallery ✨'**
  String get galleryPickAction;

  /// No description provided for @galleryChangeAction.
  ///
  /// In en, this message translates to:
  /// **'Change photo from your collection 🌸'**
  String get galleryChangeAction;

  /// No description provided for @amountSectionTitle.
  ///
  /// In en, this message translates to:
  /// **'TOTAL DAMAGE THIS TIME 💰'**
  String get amountSectionTitle;

  /// No description provided for @noteSectionTitle.
  ///
  /// In en, this message translates to:
  /// **'A LITTLE CHITCHAT ABOUT THIS 💬'**
  String get noteSectionTitle;

  /// No description provided for @monthLabel.
  ///
  /// In en, this message translates to:
  /// **'{month}/{year}'**
  String monthLabel(String month, String year);

  /// No description provided for @budgetTitle.
  ///
  /// In en, this message translates to:
  /// **'Smart Wallet Goals 🎯'**
  String get budgetTitle;

  /// No description provided for @budgetSectionTitle.
  ///
  /// In en, this message translates to:
  /// **'THIS MONTH BUDGET LIMIT 🌟'**
  String get budgetSectionTitle;

  /// No description provided for @budgetHint.
  ///
  /// In en, this message translates to:
  /// **'e.g., 5.000.000'**
  String get budgetHint;

  /// No description provided for @budgetSaveButton.
  ///
  /// In en, this message translates to:
  /// **'Lock This Budget! 🚀'**
  String get budgetSaveButton;

  /// No description provided for @budgetSuccessMessage.
  ///
  /// In en, this message translates to:
  /// **'New limit saved! Let\'s spend wisely together! 🥰'**
  String get budgetSuccessMessage;

  /// No description provided for @budgetErrorMessage.
  ///
  /// In en, this message translates to:
  /// **'Oops, something went wrong. Couldn\'t save your budget! 😿'**
  String get budgetErrorMessage;

  /// No description provided for @monthBudget.
  ///
  /// In en, this message translates to:
  /// **'This Month\'s Budget'**
  String get monthBudget;

  /// No description provided for @changeLimit.
  ///
  /// In en, this message translates to:
  /// **'Edit Limit'**
  String get changeLimit;

  /// No description provided for @budgetMenuTitle.
  ///
  /// In en, this message translates to:
  /// **'Set Budget Limit 🎯'**
  String get budgetMenuTitle;

  /// No description provided for @budgetThisMonthLabel.
  ///
  /// In en, this message translates to:
  /// **'This month\'s budget'**
  String get budgetThisMonthLabel;

  /// No description provided for @budgetNotSetStatus.
  ///
  /// In en, this message translates to:
  /// **'No spending limit set yet'**
  String get budgetNotSetStatus;

  /// No description provided for @budgetNotSetFeedback.
  ///
  /// In en, this message translates to:
  /// **'You haven\'t set a budget yet, let\'s set one! 🎯✨'**
  String get budgetNotSetFeedback;

  /// No description provided for @budgetHealthyFeedback.
  ///
  /// In en, this message translates to:
  /// **'Your wallet is in good shape! 💖'**
  String get budgetHealthyFeedback;

  /// No description provided for @budgetHalfSpentFeedback.
  ///
  /// In en, this message translates to:
  /// **'You\'ve spent more than half, be a bit more careful! ⏳✨'**
  String get budgetHalfSpentFeedback;

  /// No description provided for @budgetWarningFeedback.
  ///
  /// In en, this message translates to:
  /// **'Oops, your wallet is getting thin, slow down a bit! 🥺💸'**
  String get budgetWarningFeedback;

  /// No description provided for @budgetOverBudgetFeedback.
  ///
  /// In en, this message translates to:
  /// **'Oh no! You have exceeded your budget limit! 🚨😭'**
  String get budgetOverBudgetFeedback;

  /// No description provided for @budgetStatusGood.
  ///
  /// In en, this message translates to:
  /// **'Your spending this month is very reasonable! 👍'**
  String get budgetStatusGood;

  /// No description provided for @budgetStatusWarning.
  ///
  /// In en, this message translates to:
  /// **'Your wallet has less than 15% left. Time to tighten your belt! 💸'**
  String get budgetStatusWarning;

  /// No description provided for @budgetStatusOver.
  ///
  /// In en, this message translates to:
  /// **'Oh no! You have exceeded your budget limit! 🚨'**
  String get budgetStatusOver;

  /// No description provided for @budgetStatusHalf.
  ///
  /// In en, this message translates to:
  /// **'You\'ve spent more than half, be a bit more careful! ⏳'**
  String get budgetStatusHalf;

  /// No description provided for @remainingAmount.
  ///
  /// In en, this message translates to:
  /// **'Remaining: {amount}đ'**
  String remainingAmount(String amount);

  /// No description provided for @dailySuggestion.
  ///
  /// In en, this message translates to:
  /// **'💡 Suggestion: You should spend a maximum of {money}đ today to stay safe.'**
  String dailySuggestion(String money);

  /// No description provided for @budgetOverspentStatus.
  ///
  /// In en, this message translates to:
  /// **'Over budget by {overspent} (Limit: {limit}). 🥺💸'**
  String budgetOverspentStatus(String overspent, String limit);

  /// No description provided for @budgetSpentStatus.
  ///
  /// In en, this message translates to:
  /// **'Spent {spent} out of {limit}'**
  String budgetSpentStatus(String spent, String limit);

  /// No description provided for @budgetDetailedStatus.
  ///
  /// In en, this message translates to:
  /// **'Splurged {spent} 💸 • {remaining} left to survive {days} days 🏕️'**
  String budgetDetailedStatus(String spent, String remaining, String days);

  /// No description provided for @budgetDetailedStatusToday.
  ///
  /// In en, this message translates to:
  /// **'Splurged {spent} 💸 • Survive today with {remaining} left! 🥺'**
  String budgetDetailedStatusToday(String spent, String remaining);

  /// No description provided for @budgetOverspentDetailedStatus.
  ///
  /// In en, this message translates to:
  /// **'Burnt {spent} 💸 • In the red {overspent} with {days} days to survive! 🚨'**
  String budgetOverspentDetailedStatus(
    String spent,
    String overspent,
    String days,
  );

  /// No description provided for @budgetOverspentDetailedStatusToday.
  ///
  /// In en, this message translates to:
  /// **'Burnt {spent} 💸 • Ended the month {overspent} over budget 😭'**
  String budgetOverspentDetailedStatusToday(String spent, String overspent);

  /// No description provided for @budgetSafeDaily.
  ///
  /// In en, this message translates to:
  /// **'💡 Survival tip: Spend around {amount}/day to land safely! 🪂'**
  String budgetSafeDaily(String amount);

  /// No description provided for @budgetSafeToday.
  ///
  /// In en, this message translates to:
  /// **'💡 Survival tip: Keep it under {amount} for today! 🥺'**
  String budgetSafeToday(String amount);

  /// No description provided for @hello.
  ///
  /// In en, this message translates to:
  /// **'Hello,'**
  String get hello;

  /// No description provided for @notificationSettingsTitle.
  ///
  /// In en, this message translates to:
  /// **'Notification Settings'**
  String get notificationSettingsTitle;

  /// No description provided for @notiCategoryBudget.
  ///
  /// In en, this message translates to:
  /// **'Budget Alerts'**
  String get notiCategoryBudget;

  /// No description provided for @notiCategoryReminder.
  ///
  /// In en, this message translates to:
  /// **'Recurring Reminders'**
  String get notiCategoryReminder;

  /// No description provided for @notiCategorySecurity.
  ///
  /// In en, this message translates to:
  /// **'System & Security'**
  String get notiCategorySecurity;

  /// No description provided for @notiCategorySharedWallet.
  ///
  /// In en, this message translates to:
  /// **'Shared Wallet Activities'**
  String get notiCategorySharedWallet;

  /// No description provided for @notiBudgetWarningTitle.
  ///
  /// In en, this message translates to:
  /// **'Budget Warning! 🚨'**
  String get notiBudgetWarningTitle;

  /// No description provided for @notiBudgetWarningBody.
  ///
  /// In en, this message translates to:
  /// **'Heads up: Your {wallet} has reached {percent}%. Time to slow down!'**
  String notiBudgetWarningBody(String wallet, String percent);

  /// No description provided for @notiBudgetExceededTitle.
  ///
  /// In en, this message translates to:
  /// **'Budget Exceeded! 💸'**
  String get notiBudgetExceededTitle;

  /// No description provided for @notiBudgetExceededBody.
  ///
  /// In en, this message translates to:
  /// **'Red alert: Your {wallet} is at {percent}%. Survival mode activated!'**
  String notiBudgetExceededBody(String wallet, String percent);

  /// No description provided for @notiEmailVerifiedTitle.
  ///
  /// In en, this message translates to:
  /// **'Verification successful! 🛡️'**
  String get notiEmailVerifiedTitle;

  /// No description provided for @notiEmailVerifiedBody.
  ///
  /// In en, this message translates to:
  /// **'Your account is now secure. Let\'s start managing your budget!'**
  String get notiEmailVerifiedBody;

  /// No description provided for @notiAggregatedTxBody.
  ///
  /// In en, this message translates to:
  /// **'Wallet {budgetName} has {count} new transaction changes aggregated.'**
  String notiAggregatedTxBody(String budgetName, String count);

  /// No description provided for @notiFirstLoginReminderTitle.
  ///
  /// In en, this message translates to:
  /// **'A tiny tap to secure our bond! 💖'**
  String get notiFirstLoginReminderTitle;

  /// No description provided for @notiFirstLoginReminderBody.
  ///
  /// In en, this message translates to:
  /// **'Hey {name}, please check your inbox and verify your email! After 30 days without verification, your account will go into \'hibernation\' mode, and we\'d miss you so much! 🥺🌱'**
  String notiFirstLoginReminderBody(String name);

  /// No description provided for @notiFirstTxnTitle.
  ///
  /// In en, this message translates to:
  /// **'Your first Moment awaits! 🪄'**
  String get notiFirstTxnTitle;

  /// No description provided for @notiFirstTxnBody.
  ///
  /// In en, this message translates to:
  /// **'Your wallet is ready! Let\'s record your very first expense (Moment) today. Tap here! 👇💸'**
  String get notiFirstTxnBody;

  /// No description provided for @notiSetBudgetTitle.
  ///
  /// In en, this message translates to:
  /// **'Shield your wallet! 🛡️'**
  String get notiSetBudgetTitle;

  /// No description provided for @notiSetBudgetBody.
  ///
  /// In en, this message translates to:
  /// **'Set a budget limit so I can gently warn you before overspending. Tap to set it up! 🎯💖'**
  String get notiSetBudgetBody;

  /// No description provided for @forgotPasswordDialogTitle.
  ///
  /// In en, this message translates to:
  /// **'Recover Password'**
  String get forgotPasswordDialogTitle;

  /// No description provided for @forgotPasswordDialogDesc.
  ///
  /// In en, this message translates to:
  /// **'We will send an authentication code (OTP) or a reset link to your email.'**
  String get forgotPasswordDialogDesc;

  /// No description provided for @accountEmail.
  ///
  /// In en, this message translates to:
  /// **'Account Email'**
  String get accountEmail;

  /// No description provided for @cancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get cancel;

  /// No description provided for @sendCode.
  ///
  /// In en, this message translates to:
  /// **'Send Code'**
  String get sendCode;

  /// No description provided for @forgotPwSuccess.
  ///
  /// In en, this message translates to:
  /// **'Recovery code sent to: {email}'**
  String forgotPwSuccess(String email);

  /// No description provided for @forgotPwError.
  ///
  /// In en, this message translates to:
  /// **'Failed to send recovery code. Please try again.'**
  String get forgotPwError;

  /// No description provided for @resetPwDialogTitle.
  ///
  /// In en, this message translates to:
  /// **'Reset New Password'**
  String get resetPwDialogTitle;

  /// No description provided for @authEmail.
  ///
  /// In en, this message translates to:
  /// **'Authentication Email'**
  String get authEmail;

  /// No description provided for @otpCode.
  ///
  /// In en, this message translates to:
  /// **'Authentication Code (OTP / Token)'**
  String get otpCode;

  /// No description provided for @newPassword.
  ///
  /// In en, this message translates to:
  /// **'New Password'**
  String get newPassword;

  /// No description provided for @confirm.
  ///
  /// In en, this message translates to:
  /// **'Confirm'**
  String get confirm;

  /// No description provided for @resetPwSuccess.
  ///
  /// In en, this message translates to:
  /// **'Your password has been successfully reset! Please login.'**
  String get resetPwSuccess;

  /// No description provided for @resetPwError.
  ///
  /// In en, this message translates to:
  /// **'Invalid or expired authentication code.'**
  String get resetPwError;

  /// No description provided for @settingsAndUtilities.
  ///
  /// In en, this message translates to:
  /// **'Settings & Utilities'**
  String get settingsAndUtilities;

  /// No description provided for @language.
  ///
  /// In en, this message translates to:
  /// **'Language'**
  String get language;

  /// No description provided for @english.
  ///
  /// In en, this message translates to:
  /// **'English'**
  String get english;

  /// No description provided for @vietnamese.
  ///
  /// In en, this message translates to:
  /// **'Vietnamese'**
  String get vietnamese;

  /// No description provided for @currencyUnit.
  ///
  /// In en, this message translates to:
  /// **'Currency Unit'**
  String get currencyUnit;

  /// No description provided for @currentlyUsing.
  ///
  /// In en, this message translates to:
  /// **'Currently using'**
  String get currentlyUsing;

  /// No description provided for @darkMode.
  ///
  /// In en, this message translates to:
  /// **'Night owl mode'**
  String get darkMode;

  /// No description provided for @lightTheme.
  ///
  /// In en, this message translates to:
  /// **'Light Theme'**
  String get lightTheme;

  /// No description provided for @notificationSettingsSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Manage alerts & expenses'**
  String get notificationSettingsSubtitle;

  /// No description provided for @changePasswordSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Change current account password'**
  String get changePasswordSubtitle;

  /// No description provided for @helpCenter.
  ///
  /// In en, this message translates to:
  /// **'Help Center'**
  String get helpCenter;

  /// No description provided for @helpCenterSubtitle.
  ///
  /// In en, this message translates to:
  /// **'FAQ & Support Contact'**
  String get helpCenterSubtitle;

  /// No description provided for @logout.
  ///
  /// In en, this message translates to:
  /// **'Catch ya later!'**
  String get logout;

  /// No description provided for @logoutSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Leave the current login session'**
  String get logoutSubtitle;

  /// No description provided for @newPasswordTitle.
  ///
  /// In en, this message translates to:
  /// **'New Password'**
  String get newPasswordTitle;

  /// No description provided for @update.
  ///
  /// In en, this message translates to:
  /// **'Update'**
  String get update;

  /// No description provided for @updatePasswordSuccess.
  ///
  /// In en, this message translates to:
  /// **'Password updated successfully!'**
  String get updatePasswordSuccess;

  /// No description provided for @updatePasswordError.
  ///
  /// In en, this message translates to:
  /// **'Incorrect current password or connection error.'**
  String get updatePasswordError;

  /// No description provided for @forgotPasswordText.
  ///
  /// In en, this message translates to:
  /// **'Forgot password?'**
  String get forgotPasswordText;

  /// No description provided for @resetPasswordText.
  ///
  /// In en, this message translates to:
  /// **'Reset password'**
  String get resetPasswordText;

  /// No description provided for @forgotPasswordTitle.
  ///
  /// In en, this message translates to:
  /// **'Recover Password'**
  String get forgotPasswordTitle;

  /// No description provided for @forgotPasswordSubtitle.
  ///
  /// In en, this message translates to:
  /// **'The system will send a verification code (OTP) or reset link to your Email.'**
  String get forgotPasswordSubtitle;

  /// No description provided for @emailAccountLabel.
  ///
  /// In en, this message translates to:
  /// **'Account Email'**
  String get emailAccountLabel;

  /// No description provided for @cancelButton.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get cancelButton;

  /// No description provided for @sendCodeButton.
  ///
  /// In en, this message translates to:
  /// **'Send Code'**
  String get sendCodeButton;

  /// No description provided for @sendCodeSuccess.
  ///
  /// In en, this message translates to:
  /// **'Recovery code sent to email:'**
  String get sendCodeSuccess;

  /// No description provided for @resetPasswordTitle.
  ///
  /// In en, this message translates to:
  /// **'Reset New Password'**
  String get resetPasswordTitle;

  /// No description provided for @emailVerificationLabel.
  ///
  /// In en, this message translates to:
  /// **'Verification Email'**
  String get emailVerificationLabel;

  /// No description provided for @otpLabel.
  ///
  /// In en, this message translates to:
  /// **'Verification Code (OTP / Token)'**
  String get otpLabel;

  /// No description provided for @newPasswordLabel.
  ///
  /// In en, this message translates to:
  /// **'New Password'**
  String get newPasswordLabel;

  /// No description provided for @confirmButton.
  ///
  /// In en, this message translates to:
  /// **'Confirm'**
  String get confirmButton;

  /// No description provided for @resetPasswordSuccess.
  ///
  /// In en, this message translates to:
  /// **'Your password has been changed successfully! Please log in.'**
  String get resetPasswordSuccess;

  /// No description provided for @spendingTrend.
  ///
  /// In en, this message translates to:
  /// **'Trend'**
  String get spendingTrend;

  /// No description provided for @spendingStructure.
  ///
  /// In en, this message translates to:
  /// **'Where did my money go? 🥧'**
  String get spendingStructure;

  /// No description provided for @customDate.
  ///
  /// In en, this message translates to:
  /// **'Custom'**
  String get customDate;

  /// No description provided for @avgPerDay.
  ///
  /// In en, this message translates to:
  /// **'Daily Poof 🕊️'**
  String get avgPerDay;

  /// No description provided for @timeFrame.
  ///
  /// In en, this message translates to:
  /// **'Days'**
  String get timeFrame;

  /// No description provided for @pastWeek.
  ///
  /// In en, this message translates to:
  /// **'Past Week 🌷'**
  String get pastWeek;

  /// No description provided for @pastMonth.
  ///
  /// In en, this message translates to:
  /// **'Past Month 🌙'**
  String get pastMonth;

  /// No description provided for @threeMonths.
  ///
  /// In en, this message translates to:
  /// **'3 Months 🍄'**
  String get threeMonths;

  /// No description provided for @sixMonths.
  ///
  /// In en, this message translates to:
  /// **'Half a Year 🐢'**
  String get sixMonths;

  /// No description provided for @pastYear.
  ///
  /// In en, this message translates to:
  /// **'Past Year 🌟'**
  String get pastYear;

  /// No description provided for @fromDate.
  ///
  /// In en, this message translates to:
  /// **'From when 🐾'**
  String get fromDate;

  /// No description provided for @toDate.
  ///
  /// In en, this message translates to:
  /// **'To when 🌿'**
  String get toDate;

  /// No description provided for @repeatCycle.
  ///
  /// In en, this message translates to:
  /// **'Time Loop ⏳'**
  String get repeatCycle;

  /// No description provided for @days.
  ///
  /// In en, this message translates to:
  /// **'days'**
  String get days;

  /// No description provided for @buyDevCoffeeTitle.
  ///
  /// In en, this message translates to:
  /// **'Buy the Dev a Coffee ☕'**
  String get buyDevCoffeeTitle;

  /// No description provided for @buyDevCoffeeSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Keep the dev awake & coding happily! 🥰'**
  String get buyDevCoffeeSubtitle;

  /// No description provided for @scanToSpreadLoveTitle.
  ///
  /// In en, this message translates to:
  /// **'Scan to spread love 💖'**
  String get scanToSpreadLoveTitle;

  /// No description provided for @scanToSpreadLoveSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Every coffee you send mercilessly destroys a bug! Thank you for being Moment U\'s absolute MVP! ✨'**
  String get scanToSpreadLoveSubtitle;

  /// No description provided for @missingQrMessage.
  ///
  /// In en, this message translates to:
  /// **'Please add QR image to:\nassets/images/momo_qr.png'**
  String get missingQrMessage;

  /// No description provided for @closeButton.
  ///
  /// In en, this message translates to:
  /// **'Close'**
  String get closeButton;

  /// No description provided for @buyMeACoffeeBtn.
  ///
  /// In en, this message translates to:
  /// **'Or via Buy Me a Coffee ☕'**
  String get buyMeACoffeeBtn;

  /// No description provided for @helpCenterDialogTitle.
  ///
  /// In en, this message translates to:
  /// **'Lost? Let me help! 🎧'**
  String get helpCenterDialogTitle;

  /// No description provided for @helpCenterDialogMessage.
  ///
  /// In en, this message translates to:
  /// **'If you encounter any bugs or have brilliant ideas to make Moment U better, drop us an email! We\'re all ears. 🥰'**
  String get helpCenterDialogMessage;

  /// No description provided for @contactEmail.
  ///
  /// In en, this message translates to:
  /// **'momentu.support@gmail.com'**
  String get contactEmail;

  /// No description provided for @appVersionTitle.
  ///
  /// In en, this message translates to:
  /// **'Version'**
  String get appVersionTitle;

  /// No description provided for @appVersion.
  ///
  /// In en, this message translates to:
  /// **'v1.0.0'**
  String get appVersion;

  /// No description provided for @dailyAllowance.
  ///
  /// In en, this message translates to:
  /// **'Daily average'**
  String get dailyAllowance;

  /// No description provided for @quickSuggestions.
  ///
  /// In en, this message translates to:
  /// **'Quick suggestions'**
  String get quickSuggestions;

  /// No description provided for @budgetTip.
  ///
  /// In en, this message translates to:
  /// **'Tip: Set your budget about 20% lower than your actual income to ensure you always have savings! 🌟'**
  String get budgetTip;

  /// No description provided for @emptyFilterTransaction.
  ///
  /// In en, this message translates to:
  /// **'No transactions in this date range 🌸'**
  String get emptyFilterTransaction;

  /// No description provided for @from.
  ///
  /// In en, this message translates to:
  /// **'From'**
  String get from;

  /// No description provided for @to.
  ///
  /// In en, this message translates to:
  /// **'to'**
  String get to;

  /// No description provided for @month.
  ///
  /// In en, this message translates to:
  /// **'Month'**
  String get month;

  /// No description provided for @day.
  ///
  /// In en, this message translates to:
  /// **'Day'**
  String get day;

  /// No description provided for @mon.
  ///
  /// In en, this message translates to:
  /// **'Mon'**
  String get mon;

  /// No description provided for @tue.
  ///
  /// In en, this message translates to:
  /// **'Tue'**
  String get tue;

  /// No description provided for @wed.
  ///
  /// In en, this message translates to:
  /// **'Wed'**
  String get wed;

  /// No description provided for @thu.
  ///
  /// In en, this message translates to:
  /// **'Thu'**
  String get thu;

  /// No description provided for @fri.
  ///
  /// In en, this message translates to:
  /// **'Fri'**
  String get fri;

  /// No description provided for @sat.
  ///
  /// In en, this message translates to:
  /// **'Sat'**
  String get sat;

  /// No description provided for @sun.
  ///
  /// In en, this message translates to:
  /// **'Sun'**
  String get sun;

  /// No description provided for @accountSettings.
  ///
  /// In en, this message translates to:
  /// **'Your Little Corner ✨'**
  String get accountSettings;

  /// No description provided for @accountSettingsSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Tweak your name, fresh pic & lock the safe'**
  String get accountSettingsSubtitle;

  /// No description provided for @fullName.
  ///
  /// In en, this message translates to:
  /// **'Your cool name'**
  String get fullName;

  /// No description provided for @save.
  ///
  /// In en, this message translates to:
  /// **'Save it!'**
  String get save;

  /// No description provided for @changePassword.
  ///
  /// In en, this message translates to:
  /// **'Change Password'**
  String get changePassword;

  /// No description provided for @currentPassword.
  ///
  /// In en, this message translates to:
  /// **'Current Password'**
  String get currentPassword;

  /// No description provided for @updateSuccess.
  ///
  /// In en, this message translates to:
  /// **'Update successful!'**
  String get updateSuccess;

  /// No description provided for @updateError.
  ///
  /// In en, this message translates to:
  /// **'Oops, something went wrong...'**
  String get updateError;

  /// No description provided for @changeAvatar.
  ///
  /// In en, this message translates to:
  /// **'Change avatar'**
  String get changeAvatar;

  /// No description provided for @saveSettingsSuccess.
  ///
  /// In en, this message translates to:
  /// **'Profile updated!'**
  String get saveSettingsSuccess;

  /// No description provided for @personalInfo.
  ///
  /// In en, this message translates to:
  /// **'Personal information'**
  String get personalInfo;

  /// No description provided for @security.
  ///
  /// In en, this message translates to:
  /// **'Security'**
  String get security;

  /// No description provided for @updateProfile.
  ///
  /// In en, this message translates to:
  /// **'Update profile'**
  String get updateProfile;

  /// No description provided for @updatePassword.
  ///
  /// In en, this message translates to:
  /// **'Update password'**
  String get updatePassword;

  /// No description provided for @updateFailed.
  ///
  /// In en, this message translates to:
  /// **'Update failed!'**
  String get updateFailed;

  /// No description provided for @nameEmptyError.
  ///
  /// In en, this message translates to:
  /// **'Name cannot be empty!'**
  String get nameEmptyError;

  /// No description provided for @passwordLengthError.
  ///
  /// In en, this message translates to:
  /// **'Password must be at least 4 characters long!'**
  String get passwordLengthError;

  /// No description provided for @systemError.
  ///
  /// In en, this message translates to:
  /// **'System error!'**
  String get systemError;

  /// No description provided for @incorrectPassword.
  ///
  /// In en, this message translates to:
  /// **'Current password is incorrect!'**
  String get incorrectPassword;
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
