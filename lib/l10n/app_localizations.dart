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
  /// **'Moments u Payment'**
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
  /// **'Username'**
  String get name;

  /// No description provided for @welcomeBack.
  ///
  /// In en, this message translates to:
  /// **'Welcome Back! ✨'**
  String get welcomeBack;

  /// No description provided for @subTitle.
  ///
  /// In en, this message translates to:
  /// **'Moments U Payment - Sweet Expense Diary'**
  String get subTitle;

  /// No description provided for @subTitle1.
  ///
  /// In en, this message translates to:
  /// **'Moments U Payment'**
  String get subTitle1;

  /// No description provided for @subTitle2.
  ///
  /// In en, this message translates to:
  /// **'Sweet Expense Diary'**
  String get subTitle2;

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
  /// **'Let\'s Go Inside ✨'**
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
  /// **'Just a small thing...'**
  String get emptyTransactionNote;

  /// No description provided for @homeSubGreeting.
  ///
  /// In en, this message translates to:
  /// **'How is your payment status today?'**
  String get homeSubGreeting;

  /// No description provided for @spendingMomentsTitle.
  ///
  /// In en, this message translates to:
  /// **'My Lovely Moments'**
  String get spendingMomentsTitle;

  /// No description provided for @loadingData.
  ///
  /// In en, this message translates to:
  /// **'Loading payment moments...'**
  String get loadingData;

  /// No description provided for @retryButton.
  ///
  /// In en, this message translates to:
  /// **'Retry'**
  String get retryButton;

  /// No description provided for @emptyTransactionList.
  ///
  /// In en, this message translates to:
  /// **'No moments yet'**
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
  /// **'Other'**
  String get categoryOther;

  /// No description provided for @food.
  ///
  /// In en, this message translates to:
  /// **'Food'**
  String get food;

  /// No description provided for @shopping.
  ///
  /// In en, this message translates to:
  /// **'Shopping'**
  String get shopping;

  /// No description provided for @transport.
  ///
  /// In en, this message translates to:
  /// **'Transport'**
  String get transport;

  /// No description provided for @entertainment.
  ///
  /// In en, this message translates to:
  /// **'Entertainment'**
  String get entertainment;

  /// No description provided for @other.
  ///
  /// In en, this message translates to:
  /// **'Other'**
  String get other;

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

  /// No description provided for @cameraPickActionShort.
  ///
  /// In en, this message translates to:
  /// **'Take a photo'**
  String get cameraPickActionShort;

  /// No description provided for @galleryChangeAction.
  ///
  /// In en, this message translates to:
  /// **'Change photo from your collection 🌸'**
  String get galleryChangeAction;

  /// No description provided for @galleryChangeActionShort.
  ///
  /// In en, this message translates to:
  /// **'Gallery'**
  String get galleryChangeActionShort;

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
  /// **'Danger Zone! 🚨'**
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
  /// **'Remaining: {amount}'**
  String remainingAmount(String amount);

  /// No description provided for @dailySuggestion.
  ///
  /// In en, this message translates to:
  /// **'💡 Suggestion: You should spend a maximum of {money} today to stay safe.'**
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
  /// **'Wallet {budgetName} has {count} new moment changes aggregated.'**
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

  /// No description provided for @darkTheme.
  ///
  /// In en, this message translates to:
  /// **'Dark Theme'**
  String get darkTheme;

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

  /// No description provided for @analyticsTitle.
  ///
  /// In en, this message translates to:
  /// **'Spending Analytics'**
  String get analyticsTitle;

  /// No description provided for @spendingTrend.
  ///
  /// In en, this message translates to:
  /// **'Trend'**
  String get spendingTrend;

  /// No description provided for @spendingStructure.
  ///
  /// In en, this message translates to:
  /// **'Wallet \'burn\' structure 🥧'**
  String get spendingStructure;

  /// No description provided for @customDate.
  ///
  /// In en, this message translates to:
  /// **'Custom'**
  String get customDate;

  /// No description provided for @totalLabel.
  ///
  /// In en, this message translates to:
  /// **'Total Damage 💸'**
  String get totalLabel;

  /// No description provided for @avgPerDay.
  ///
  /// In en, this message translates to:
  /// **'Avg daily burn 🕊️'**
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
  /// **'From'**
  String get fromDate;

  /// No description provided for @toDate.
  ///
  /// In en, this message translates to:
  /// **'To'**
  String get toDate;

  /// No description provided for @repeatCycle.
  ///
  /// In en, this message translates to:
  /// **'Cycle ⏳'**
  String get repeatCycle;

  /// No description provided for @days.
  ///
  /// In en, this message translates to:
  /// **'days'**
  String get days;

  /// No description provided for @emptyAnalyticsData.
  ///
  /// In en, this message translates to:
  /// **'No analytics data available for this period.'**
  String get emptyAnalyticsData;

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
  /// **'momentupayment.support@gmail.com'**
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
  /// **'No moments found for this period'**
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
  /// **'Save'**
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

  /// No description provided for @updateSuccess.
  ///
  /// In en, this message translates to:
  /// **'Update successful!'**
  String get updateSuccess;

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

  /// No description provided for @maxOneYearWarning.
  ///
  /// In en, this message translates to:
  /// **'Moment U only supports viewing up to 1 year! 🗓️'**
  String get maxOneYearWarning;

  /// No description provided for @wrongOldPassword.
  ///
  /// In en, this message translates to:
  /// **'Incorrect current password.'**
  String get wrongOldPassword;

  /// No description provided for @userNotFoundError.
  ///
  /// In en, this message translates to:
  /// **'User not found.'**
  String get userNotFoundError;

  /// No description provided for @weakPasswordError.
  ///
  /// In en, this message translates to:
  /// **'The new password is too weak.'**
  String get weakPasswordError;

  /// No description provided for @noChangeWarning.
  ///
  /// In en, this message translates to:
  /// **'Your information has not changed! ✨'**
  String get noChangeWarning;

  /// No description provided for @fillPasswordFieldsError.
  ///
  /// In en, this message translates to:
  /// **'Please enter all password fields.'**
  String get fillPasswordFieldsError;

  /// No description provided for @samePasswordError.
  ///
  /// In en, this message translates to:
  /// **'New password cannot be the same as old password.'**
  String get samePasswordError;

  /// No description provided for @addSuccessMessage.
  ///
  /// In en, this message translates to:
  /// **'Added successfully! ✨'**
  String get addSuccessMessage;

  /// No description provided for @updateSuccessMessage.
  ///
  /// In en, this message translates to:
  /// **'Updated successfully! ✨'**
  String get updateSuccessMessage;

  /// No description provided for @futureDateError.
  ///
  /// In en, this message translates to:
  /// **'You cannot add moments for future dates!'**
  String get futureDateError;

  /// No description provided for @deleteSuccessMessage.
  ///
  /// In en, this message translates to:
  /// **'Deleted successfully!'**
  String get deleteSuccessMessage;

  /// No description provided for @deleteErrorMessage.
  ///
  /// In en, this message translates to:
  /// **'An error occurred while deleting'**
  String get deleteErrorMessage;

  /// No description provided for @premiumGroupMomentsTitle.
  ///
  /// In en, this message translates to:
  /// **'Group Moments 👑'**
  String get premiumGroupMomentsTitle;

  /// No description provided for @premiumGroupMomentsSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Group wallet feature is temporarily locked in beta.'**
  String get premiumGroupMomentsSubtitle;

  /// No description provided for @navHome.
  ///
  /// In en, this message translates to:
  /// **'Home'**
  String get navHome;

  /// No description provided for @navBudget.
  ///
  /// In en, this message translates to:
  /// **'Budget'**
  String get navBudget;

  /// No description provided for @navAnalytics.
  ///
  /// In en, this message translates to:
  /// **'Analytics'**
  String get navAnalytics;

  /// No description provided for @navPremium.
  ///
  /// In en, this message translates to:
  /// **'Premium'**
  String get navPremium;

  /// No description provided for @navMenu.
  ///
  /// In en, this message translates to:
  /// **'Menu'**
  String get navMenu;

  /// No description provided for @setBudgetTitle.
  ///
  /// In en, this message translates to:
  /// **'Set Budget'**
  String get setBudgetTitle;

  /// No description provided for @monthlyBudgetLimit.
  ///
  /// In en, this message translates to:
  /// **'Monthly spending limit'**
  String get monthlyBudgetLimit;

  /// No description provided for @saveConfiguration.
  ///
  /// In en, this message translates to:
  /// **'Save Configuration'**
  String get saveConfiguration;

  /// No description provided for @premiumFeatureTitle.
  ///
  /// In en, this message translates to:
  /// **'Premium Feature'**
  String get premiumFeatureTitle;

  /// No description provided for @premiumFeatureDesc.
  ///
  /// In en, this message translates to:
  /// **'Group Moments shared wallet is currently locked. Upgrade to Premium to unlock shared cash flow and real-time co-management with your partner and family.'**
  String get premiumFeatureDesc;

  /// No description provided for @unlockPremiumNow.
  ///
  /// In en, this message translates to:
  /// **'Unlock Premium Now'**
  String get unlockPremiumNow;

  /// No description provided for @budgetLoadError.
  ///
  /// In en, this message translates to:
  /// **'Failed to load budget'**
  String get budgetLoadError;

  /// No description provided for @budgetOverspentLabel.
  ///
  /// In en, this message translates to:
  /// **'Overspent'**
  String get budgetOverspentLabel;

  /// No description provided for @budgetRemainingLabel.
  ///
  /// In en, this message translates to:
  /// **'Status Review'**
  String get budgetRemainingLabel;

  /// No description provided for @budgetLastDay.
  ///
  /// In en, this message translates to:
  /// **'Today is the final day!'**
  String get budgetLastDay;

  /// No description provided for @budgetRemainingDays.
  ///
  /// In en, this message translates to:
  /// **'{days} days left'**
  String budgetRemainingDays(int days);

  /// No description provided for @budgetStatusReasonable.
  ///
  /// In en, this message translates to:
  /// **'Looking good'**
  String get budgetStatusReasonable;

  /// No description provided for @budgetStatusNotSet.
  ///
  /// In en, this message translates to:
  /// **'Not set yet'**
  String get budgetStatusNotSet;

  /// No description provided for @budgetStatusOvertarget.
  ///
  /// In en, this message translates to:
  /// **'Wallet\'s crying'**
  String get budgetStatusOvertarget;

  /// No description provided for @budgetStatusHalfSpent.
  ///
  /// In en, this message translates to:
  /// **'Halfway there'**
  String get budgetStatusHalfSpent;

  /// No description provided for @budgetDailyNotSet.
  ///
  /// In en, this message translates to:
  /// **'Set a limit so I can guard your wallet! 🥺'**
  String get budgetDailyNotSet;

  /// No description provided for @budgetDailyOvertarget.
  ///
  /// In en, this message translates to:
  /// **'Out of quota! Time for a breath-of-air diet... 💸'**
  String get budgetDailyOvertarget;

  /// No description provided for @budgetDailySafeLimit.
  ///
  /// In en, this message translates to:
  /// **'Keep it steady! Spend max {amount} per day, okay? 🥰'**
  String budgetDailySafeLimit(String amount);

  /// No description provided for @emptyTransactionSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Log your first expense now so your wallet stays perfectly in check! ✨'**
  String get emptyTransactionSubtitle;

  /// No description provided for @deleteActionLabel.
  ///
  /// In en, this message translates to:
  /// **'Delete'**
  String get deleteActionLabel;

  /// No description provided for @transactionCount.
  ///
  /// In en, this message translates to:
  /// **'{count} moments'**
  String transactionCount(int count);

  /// No description provided for @transactionTime.
  ///
  /// In en, this message translates to:
  /// **'Time'**
  String get transactionTime;

  /// No description provided for @addMomentTooltip.
  ///
  /// In en, this message translates to:
  /// **'Quickly create a payment moment ✨'**
  String get addMomentTooltip;

  /// No description provided for @notificationListTitle.
  ///
  /// In en, this message translates to:
  /// **'Notifications'**
  String get notificationListTitle;

  /// No description provided for @allNotifications.
  ///
  /// In en, this message translates to:
  /// **'All'**
  String get allNotifications;

  /// No description provided for @unreadNotifications.
  ///
  /// In en, this message translates to:
  /// **'Unread'**
  String get unreadNotifications;

  /// No description provided for @emptyNotificationsTitle.
  ///
  /// In en, this message translates to:
  /// **'Inbox is empty'**
  String get emptyNotificationsTitle;

  /// No description provided for @allReadNotificationsTitle.
  ///
  /// In en, this message translates to:
  /// **'You\'ve read all notifications! 🎉'**
  String get allReadNotificationsTitle;

  /// No description provided for @markAsReadSuccess.
  ///
  /// In en, this message translates to:
  /// **'Marked as read successfully! 💌'**
  String get markAsReadSuccess;

  /// No description provided for @markAllAsRead.
  ///
  /// In en, this message translates to:
  /// **'Mark all as read'**
  String get markAllAsRead;

  /// No description provided for @allReadSuccess.
  ///
  /// In en, this message translates to:
  /// **'All notifications marked as read!'**
  String get allReadSuccess;

  /// No description provided for @obTitle1.
  ///
  /// In en, this message translates to:
  /// **'Capture your spending moments.'**
  String get obTitle1;

  /// No description provided for @obDesc1.
  ///
  /// In en, this message translates to:
  /// **'Log every expense through photos. Streamlined, fast, and delightfully text-free!'**
  String get obDesc1;

  /// No description provided for @obTitle2.
  ///
  /// In en, this message translates to:
  /// **'See through your wallet.'**
  String get obTitle2;

  /// No description provided for @obDesc2.
  ///
  /// In en, this message translates to:
  /// **'Beautiful and intuitive reports. Instantly know where your cash vanished.'**
  String get obDesc2;

  /// No description provided for @obTitle3.
  ///
  /// In en, this message translates to:
  /// **'Your secure vault.'**
  String get obTitle3;

  /// No description provided for @obDesc3.
  ///
  /// In en, this message translates to:
  /// **'Absolute privacy. Your spending secrets are for your eyes only.'**
  String get obDesc3;

  /// No description provided for @obSkip.
  ///
  /// In en, this message translates to:
  /// **'Skip'**
  String get obSkip;

  /// No description provided for @obNext.
  ///
  /// In en, this message translates to:
  /// **'Next'**
  String get obNext;

  /// No description provided for @obStart.
  ///
  /// In en, this message translates to:
  /// **'Get Started'**
  String get obStart;

  /// No description provided for @dayLabel.
  ///
  /// In en, this message translates to:
  /// **'day'**
  String get dayLabel;

  /// No description provided for @spentLabel.
  ///
  /// In en, this message translates to:
  /// **'Spent'**
  String get spentLabel;

  /// No description provided for @budgetWarningLow.
  ///
  /// In en, this message translates to:
  /// **'Uh-oh, this new limit is even lower than the amount you\'ve already spent this month ({amountSpent})! 🚨🥺'**
  String budgetWarningLow(String amountSpent);

  /// No description provided for @analyticsSwitchPeriod.
  ///
  /// In en, this message translates to:
  /// **'Period'**
  String get analyticsSwitchPeriod;

  /// No description provided for @analyticsSwitchMonthly.
  ///
  /// In en, this message translates to:
  /// **'Monthly'**
  String get analyticsSwitchMonthly;

  /// No description provided for @analyticsMonthlyHonor.
  ///
  /// In en, this message translates to:
  /// **'{month} {year}'**
  String analyticsMonthlyHonor(String month, Object year);

  /// No description provided for @analyticsLastMonthReview.
  ///
  /// In en, this message translates to:
  /// **'Change Month'**
  String get analyticsLastMonthReview;

  /// No description provided for @analyticsAchievement.
  ///
  /// In en, this message translates to:
  /// **'Your Achievement'**
  String get analyticsAchievement;

  /// No description provided for @analyticsTitleThrifty.
  ///
  /// In en, this message translates to:
  /// **'Thrifty Ninja 🌿'**
  String get analyticsTitleThrifty;

  /// No description provided for @analyticsDescThrifty.
  ///
  /// In en, this message translates to:
  /// **'Great management, your wallet is very happy!'**
  String get analyticsDescThrifty;

  /// No description provided for @analyticsTitleSpender.
  ///
  /// In en, this message translates to:
  /// **'Big Spender 🔥'**
  String get analyticsTitleSpender;

  /// No description provided for @analyticsDescSpender.
  ///
  /// In en, this message translates to:
  /// **'You spent quite heavily this month, be careful!'**
  String get analyticsDescSpender;

  /// No description provided for @analyticsTitleConsistent.
  ///
  /// In en, this message translates to:
  /// **'Discipline Master 🛡️'**
  String get analyticsTitleConsistent;

  /// No description provided for @analyticsDescConsistent.
  ///
  /// In en, this message translates to:
  /// **'Diligent tracking, you are mastering your finances!'**
  String get analyticsDescConsistent;

  /// No description provided for @chooseMonthYear.
  ///
  /// In en, this message translates to:
  /// **'Select Month & Year'**
  String get chooseMonthYear;

  /// No description provided for @badgeTabTitle.
  ///
  /// In en, this message translates to:
  /// **'My Badges'**
  String get badgeTabTitle;

  /// No description provided for @badgeUnlocked.
  ///
  /// In en, this message translates to:
  /// **'Unlocked'**
  String get badgeUnlocked;

  /// No description provided for @badgeLocked.
  ///
  /// In en, this message translates to:
  /// **'Locked'**
  String get badgeLocked;

  /// No description provided for @badgeGhostTitle.
  ///
  /// In en, this message translates to:
  /// **'The Ultimate Sloth'**
  String get badgeGhostTitle;

  /// No description provided for @badgeGhostDesc.
  ///
  /// In en, this message translates to:
  /// **'Didn\'t log a single transaction all month. Talk about lazy!'**
  String get badgeGhostDesc;

  /// No description provided for @badgeShopaholicTitle.
  ///
  /// In en, this message translates to:
  /// **'Checkout Tornado'**
  String get badgeShopaholicTitle;

  /// No description provided for @badgeShopaholicDesc.
  ///
  /// In en, this message translates to:
  /// **'Logged over 40 transactions this month. The delivery guy probably knows you by name now!'**
  String get badgeShopaholicDesc;

  /// No description provided for @badgeWhaleTitle.
  ///
  /// In en, this message translates to:
  /// **'The Great Whale'**
  String get badgeWhaleTitle;

  /// No description provided for @badgeWhaleDesc.
  ///
  /// In en, this message translates to:
  /// **'Casually dropped over \$500 this month. Mind if we become friends, boss?'**
  String get badgeWhaleDesc;

  /// No description provided for @badgeSurvivalistTitle.
  ///
  /// In en, this message translates to:
  /// **'Survival God'**
  String get badgeSurvivalistTitle;

  /// No description provided for @badgeSurvivalistDesc.
  ///
  /// In en, this message translates to:
  /// **'Spent under \$100 this month. Iron discipline or just eating instant noodles everyday?'**
  String get badgeSurvivalistDesc;

  /// No description provided for @badgeNightOwlTitle.
  ///
  /// In en, this message translates to:
  /// **'Midnight Burner'**
  String get badgeNightOwlTitle;

  /// No description provided for @badgeNightOwlDesc.
  ///
  /// In en, this message translates to:
  /// **'Made a transaction between 12 AM and 4 AM. 2 AM sale hunting again, huh?'**
  String get badgeNightOwlDesc;

  /// No description provided for @badgePaydayFlashTitle.
  ///
  /// In en, this message translates to:
  /// **'Payday Evaporator'**
  String get badgePaydayFlashTitle;

  /// No description provided for @badgePaydayFlashDesc.
  ///
  /// In en, this message translates to:
  /// **'Spent heavily between the 1st and 5th of the month. Money is just an illusion!'**
  String get badgePaydayFlashDesc;

  /// No description provided for @badgeFoodDestroyerTitle.
  ///
  /// In en, this message translates to:
  /// **'Foodie Destroyer'**
  String get badgeFoodDestroyerTitle;

  /// No description provided for @badgeFoodDestroyerDesc.
  ///
  /// In en, this message translates to:
  /// **'Over 50% of your transactions went to food. The true path to happiness!'**
  String get badgeFoodDestroyerDesc;

  /// No description provided for @badgeWeekendStormTitle.
  ///
  /// In en, this message translates to:
  /// **'Weekend Hurricane'**
  String get badgeWeekendStormTitle;

  /// No description provided for @badgeWeekendStormDesc.
  ///
  /// In en, this message translates to:
  /// **'Held back all week just to go wild on Saturday or Sunday. A true party animal!'**
  String get badgeWeekendStormDesc;

  /// No description provided for @badgeGoldfishTitle.
  ///
  /// In en, this message translates to:
  /// **'Goldfish Brain'**
  String get badgeGoldfishTitle;

  /// No description provided for @badgeGoldfishDesc.
  ///
  /// In en, this message translates to:
  /// **'Logged 5 or more backdated expenses. Did you forget your phone password too?'**
  String get badgeGoldfishDesc;

  /// No description provided for @badgeBrokeAFTitle.
  ///
  /// In en, this message translates to:
  /// **'Broke AF'**
  String get badgeBrokeAFTitle;

  /// No description provided for @badgeBrokeAFDesc.
  ///
  /// In en, this message translates to:
  /// **'Logged over 10 tiny transactions under \$0.5. Every penny counts, keep it up!'**
  String get badgeBrokeAFDesc;

  /// No description provided for @badgeBigTicketTitle.
  ///
  /// In en, this message translates to:
  /// **'Swiped & Scorched'**
  String get badgeBigTicketTitle;

  /// No description provided for @badgeBigTicketDesc.
  ///
  /// In en, this message translates to:
  /// **'One giant transaction over \$250! Even looking at the bank notification hurts.'**
  String get badgeBigTicketDesc;

  /// No description provided for @badgeFirstBloodTitle.
  ///
  /// In en, this message translates to:
  /// **'First Blood'**
  String get badgeFirstBloodTitle;

  /// No description provided for @badgeFirstBloodDesc.
  ///
  /// In en, this message translates to:
  /// **'Logged your very first transaction. Welcome to the club!'**
  String get badgeFirstBloodDesc;

  /// No description provided for @badgeCenturionTitle.
  ///
  /// In en, this message translates to:
  /// **'The Centurion'**
  String get badgeCenturionTitle;

  /// No description provided for @badgeCenturionDesc.
  ///
  /// In en, this message translates to:
  /// **'Reached 100 total transactions. What a dedication!'**
  String get badgeCenturionDesc;

  /// No description provided for @badgeBalancedTitle.
  ///
  /// In en, this message translates to:
  /// **'Zen Master'**
  String get badgeBalancedTitle;

  /// No description provided for @badgeBalancedDesc.
  ///
  /// In en, this message translates to:
  /// **'Kept your monthly spending perfectly balanced between \$100 and \$350.'**
  String get badgeBalancedDesc;

  /// No description provided for @notiMonthlySummaryTitle.
  ///
  /// In en, this message translates to:
  /// **'Spending Report: Month {month} 📊'**
  String notiMonthlySummaryTitle(String month);

  /// No description provided for @notiMonthlySummaryBody.
  ///
  /// In en, this message translates to:
  /// **'You spent {total} last month. {category} {emoji} was your biggest expense.'**
  String notiMonthlySummaryBody(String total, String category, String emoji);

  /// No description provided for @notiBadgeUnlockedTitle.
  ///
  /// In en, this message translates to:
  /// **'New Achievement Unlocked! 🏆'**
  String get notiBadgeUnlockedTitle;

  /// No description provided for @notiBadgeUnlockedBody.
  ///
  /// In en, this message translates to:
  /// **'Awesome! You have earned the \"{badgeName}\" badge.'**
  String notiBadgeUnlockedBody(String badgeName);

  /// No description provided for @notiBadgeResetTitle.
  ///
  /// In en, this message translates to:
  /// **'Monthly Badges Reset 🔄'**
  String get notiBadgeResetTitle;

  /// No description provided for @notiBadgeResetBody.
  ///
  /// In en, this message translates to:
  /// **'A new month begins! Monthly rankings have been reset. Time to conquer them again!'**
  String get notiBadgeResetBody;

  /// No description provided for @congratsSingleTitle.
  ///
  /// In en, this message translates to:
  /// **'Boom! New Badge on the Block! 🏆'**
  String get congratsSingleTitle;

  /// No description provided for @congratsMultipleTitle.
  ///
  /// In en, this message translates to:
  /// **'Look at You! Catching a Shower of Badges! ⛈️🏆'**
  String get congratsMultipleTitle;

  /// No description provided for @congratsSingleSub.
  ///
  /// In en, this message translates to:
  /// **'Absolute legend! You just conquered:'**
  String get congratsSingleSub;

  /// No description provided for @congratsMultipleSub.
  ///
  /// In en, this message translates to:
  /// **'Unstoppable! Your collection just welcomed a fresh squad:'**
  String get congratsMultipleSub;

  /// No description provided for @congratsButton.
  ///
  /// In en, this message translates to:
  /// **'Sweet! Let\'s gooo! 😎'**
  String get congratsButton;

  /// No description provided for @homeBadgeTitle.
  ///
  /// In en, this message translates to:
  /// **'Flex Zone'**
  String get homeBadgeTitle;

  /// No description provided for @emptyBadgeText.
  ///
  /// In en, this message translates to:
  /// **'No badges yet? Time to flex your financial superpowers! 👀'**
  String get emptyBadgeText;

  /// No description provided for @defaultUser.
  ///
  /// In en, this message translates to:
  /// **'User'**
  String get defaultUser;

  /// No description provided for @congratsTitle.
  ///
  /// In en, this message translates to:
  /// **'Wonderful! 🎉'**
  String get congratsTitle;

  /// No description provided for @badgeOwnedMessage.
  ///
  /// In en, this message translates to:
  /// **'You own an exclusive badge:\n{badgeName}'**
  String badgeOwnedMessage(String badgeName);

  /// No description provided for @exploreCollection.
  ///
  /// In en, this message translates to:
  /// **'Explore Collection'**
  String get exploreCollection;

  /// No description provided for @later.
  ///
  /// In en, this message translates to:
  /// **'Later'**
  String get later;

  /// No description provided for @badgesTitle.
  ///
  /// In en, this message translates to:
  /// **'Badges'**
  String get badgesTitle;

  /// No description provided for @badgesSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Collect and display your achievements'**
  String get badgesSubtitle;

  /// No description provided for @badgeTagMonthly.
  ///
  /// In en, this message translates to:
  /// **'MONTHLY'**
  String get badgeTagMonthly;

  /// No description provided for @badgeTagElite.
  ///
  /// In en, this message translates to:
  /// **'ELITE'**
  String get badgeTagElite;

  /// No description provided for @badgeTypeMonthly.
  ///
  /// In en, this message translates to:
  /// **'MONTHLY BADGE'**
  String get badgeTypeMonthly;

  /// No description provided for @badgeTypeElite.
  ///
  /// In en, this message translates to:
  /// **'ELITE ACHIEVEMENT'**
  String get badgeTypeElite;

  /// No description provided for @badgeLockedTitle.
  ///
  /// In en, this message translates to:
  /// **'Mysterious Relic'**
  String get badgeLockedTitle;

  /// No description provided for @badgeLockedSecretDesc.
  ///
  /// In en, this message translates to:
  /// **'Energy is building up. Ready to explode...'**
  String get badgeLockedSecretDesc;

  /// No description provided for @badgeLockedDialogDesc.
  ///
  /// In en, this message translates to:
  /// **'This entity is currently sealed! Maintain your transaction streak and break your spending limits to awaken this dormant power. 💥'**
  String get badgeLockedDialogDesc;

  /// No description provided for @myCollectionButton.
  ///
  /// In en, this message translates to:
  /// **'My Collection'**
  String get myCollectionButton;

  /// No description provided for @badgeHintAlmost.
  ///
  /// In en, this message translates to:
  /// **'You are halfway there! Keep it up...'**
  String get badgeHintAlmost;

  /// No description provided for @badgeHintStart.
  ///
  /// In en, this message translates to:
  /// **'A journey of a thousand miles begins with a single step...'**
  String get badgeHintStart;

  /// No description provided for @shareBadgeMessage.
  ///
  /// In en, this message translates to:
  /// **'Awesome! I just unlocked the badge'**
  String get shareBadgeMessage;

  /// No description provided for @shareBadgeAction.
  ///
  /// In en, this message translates to:
  /// **'Share Achievement ✨'**
  String get shareBadgeAction;

  /// No description provided for @hintFirstBlood.
  ///
  /// In en, this message translates to:
  /// **'Every great journey begins with a single step...'**
  String get hintFirstBlood;

  /// No description provided for @hintCenturion.
  ///
  /// In en, this message translates to:
  /// **'Persistence creates legends. Keep recording those moments...'**
  String get hintCenturion;

  /// No description provided for @hintGhost.
  ///
  /// In en, this message translates to:
  /// **'Sometimes silence is the loudest sound. How long has it been since you last visited?'**
  String get hintGhost;

  /// No description provided for @hintBigTicket.
  ///
  /// In en, this message translates to:
  /// **'Don\'t hesitate to splurge on those worthy big decisions...'**
  String get hintBigTicket;

  /// No description provided for @hintPaydayFlash.
  ///
  /// In en, this message translates to:
  /// **'Payday is the time to treat yourself to a little indulgence...'**
  String get hintPaydayFlash;

  /// No description provided for @hintNightOwl.
  ///
  /// In en, this message translates to:
  /// **'Darkness is your ally. Try making a transaction while the city sleeps...'**
  String get hintNightOwl;

  /// No description provided for @hintWeekendStorm.
  ///
  /// In en, this message translates to:
  /// **'Weekends are for unwinding. Are you ready for a shopping storm?'**
  String get hintWeekendStorm;

  /// No description provided for @hintShopaholic.
  ///
  /// In en, this message translates to:
  /// **'Passion has no limits. Sometimes quantity trumps everything...'**
  String get hintShopaholic;

  /// No description provided for @hintWhale.
  ///
  /// In en, this message translates to:
  /// **'The vast ocean needs kings. Where\'s your spending record?'**
  String get hintWhale;

  /// No description provided for @hintSurvivalist.
  ///
  /// In en, this message translates to:
  /// **'The art of saving is just as great as earning. Stay frugal...'**
  String get hintSurvivalist;

  /// No description provided for @hintFoodDestroyer.
  ///
  /// In en, this message translates to:
  /// **'Your stomach is an endless universe. Fill it with something delicious...'**
  String get hintFoodDestroyer;

  /// No description provided for @hintBrokeAF.
  ///
  /// In en, this message translates to:
  /// **'Small expenses add up. Watch those tiny costs that drain your wallet...'**
  String get hintBrokeAF;

  /// No description provided for @hintGoldfish.
  ///
  /// In en, this message translates to:
  /// **'The past needs to be recorded. Do you often forget to enter transactions and have to backdate them?'**
  String get hintGoldfish;

  /// No description provided for @hintBalanced.
  ///
  /// In en, this message translates to:
  /// **'Perfection lies in balance. Not too extravagant, not too frugal...'**
  String get hintBalanced;

  /// No description provided for @hintDefault.
  ///
  /// In en, this message translates to:
  /// **'Secrets await those patient enough to discover them...'**
  String get hintDefault;

  /// No description provided for @markAllAsReadSuccess.
  ///
  /// In en, this message translates to:
  /// **'All notifications marked as read'**
  String get markAllAsReadSuccess;

  /// No description provided for @readMore.
  ///
  /// In en, this message translates to:
  /// **'Read more...'**
  String get readMore;

  /// No description provided for @collapse.
  ///
  /// In en, this message translates to:
  /// **'Collapse'**
  String get collapse;

  /// No description provided for @hintSecret.
  ///
  /// In en, this message translates to:
  /// **'Secrets await those who are patient enough to explore...'**
  String get hintSecret;

  /// No description provided for @progressTitle.
  ///
  /// In en, this message translates to:
  /// **'Progress: {percent}%'**
  String progressTitle(String percent);

  /// No description provided for @boastAchievement.
  ///
  /// In en, this message translates to:
  /// **'Show off ✨'**
  String get boastAchievement;

  /// No description provided for @creatingImage.
  ///
  /// In en, this message translates to:
  /// **'Creating image...'**
  String get creatingImage;

  /// No description provided for @shareNow.
  ///
  /// In en, this message translates to:
  /// **'Share now'**
  String get shareNow;

  /// No description provided for @achievementUnlocked.
  ///
  /// In en, this message translates to:
  /// **'ACHIEVEMENT UNLOCKED'**
  String get achievementUnlocked;

  /// No description provided for @shareAppPromoMessage.
  ///
  /// In en, this message translates to:
  /// **'Awesome! I just unlocked the \'{badgeTitle}\' badge on Moments U Payment! 🏆✨\n\nTracking expenses has never been this fun. Download the app and let\'s set new records together! 🚀\n#MomentsUPayment #Achievement'**
  String shareAppPromoMessage(String badgeTitle);

  /// No description provided for @shareAppPromoMessageSubTitle.
  ///
  /// In en, this message translates to:
  /// **'I\'ve been using Moment U to track my moments and spending. Thought you might like it too.'**
  String get shareAppPromoMessageSubTitle;

  /// No description provided for @registerSuccessMsg.
  ///
  /// In en, this message translates to:
  /// **'Registration successful! Time to log in and start! 💕'**
  String get registerSuccessMsg;

  /// No description provided for @emailExistsError.
  ///
  /// In en, this message translates to:
  /// **'This email has already been registered, friend! 🌸'**
  String get emailExistsError;

  /// No description provided for @registerFailedError.
  ///
  /// In en, this message translates to:
  /// **'Registration failed! Please check your network connection 😢'**
  String get registerFailedError;

  /// No description provided for @errorEmailNotFound.
  ///
  /// In en, this message translates to:
  /// **'This email isn\'t registered yet! 😢'**
  String get errorEmailNotFound;

  /// No description provided for @errorInvalidAccount.
  ///
  /// In en, this message translates to:
  /// **'Invalid account credentials! ❌'**
  String get errorInvalidAccount;

  /// No description provided for @errorInvalidOtp.
  ///
  /// In en, this message translates to:
  /// **'The OTP code is incorrect or has expired! ❌'**
  String get errorInvalidOtp;

  /// No description provided for @errorMissingPassword.
  ///
  /// In en, this message translates to:
  /// **'Please provide a new password!'**
  String get errorMissingPassword;

  /// No description provided for @errorDefault.
  ///
  /// In en, this message translates to:
  /// **'An error occurred. Please try again later!'**
  String get errorDefault;

  /// No description provided for @errorIncorrectOldPassword.
  ///
  /// In en, this message translates to:
  /// **'Oops! That\'s not your old password. Double-check it! 🧐'**
  String get errorIncorrectOldPassword;

  /// No description provided for @errorUserNotFound.
  ///
  /// In en, this message translates to:
  /// **'We couldn\'t find this account. Are you sure the email is correct? 🕵️‍♀️'**
  String get errorUserNotFound;

  /// No description provided for @errorEmailAlreadyExists.
  ///
  /// In en, this message translates to:
  /// **'This email is already taken! Try another one or log in instead. 🌸'**
  String get errorEmailAlreadyExists;

  /// No description provided for @errorInvalidCredentials.
  ///
  /// In en, this message translates to:
  /// **'Incorrect email or password. Give it another try! 🐾'**
  String get errorInvalidCredentials;

  /// No description provided for @errorGoogleLinked.
  ///
  /// In en, this message translates to:
  /// **'This account is linked with Google. Just sign in with Google! 🚀'**
  String get errorGoogleLinked;

  /// No description provided for @selectStartDate.
  ///
  /// In en, this message translates to:
  /// **'Select start date'**
  String get selectStartDate;

  /// No description provided for @selectEndDate.
  ///
  /// In en, this message translates to:
  /// **'Select end date'**
  String get selectEndDate;

  /// No description provided for @applyButtonTitle.
  ///
  /// In en, this message translates to:
  /// **'Apply'**
  String get applyButtonTitle;

  /// No description provided for @monthShort.
  ///
  /// In en, this message translates to:
  /// **'M'**
  String get monthShort;

  /// No description provided for @todayChip.
  ///
  /// In en, this message translates to:
  /// **'Today ☀️'**
  String get todayChip;

  /// No description provided for @pastWeekChip.
  ///
  /// In en, this message translates to:
  /// **'Past week 🌷'**
  String get pastWeekChip;

  /// No description provided for @pastMonthChip.
  ///
  /// In en, this message translates to:
  /// **'Past month 🌙'**
  String get pastMonthChip;

  /// No description provided for @threeMonthsChip.
  ///
  /// In en, this message translates to:
  /// **'3 months 🍄'**
  String get threeMonthsChip;

  /// No description provided for @sixMonthsChip.
  ///
  /// In en, this message translates to:
  /// **'Half a year 🐢'**
  String get sixMonthsChip;

  /// No description provided for @errorLoadData.
  ///
  /// In en, this message translates to:
  /// **'Oops, the data tripped on a rock, so unlucky 🥺'**
  String get errorLoadData;

  /// No description provided for @filterActiveTitle.
  ///
  /// In en, this message translates to:
  /// **'Time Filter'**
  String get filterActiveTitle;

  /// No description provided for @selectMonthLabel.
  ///
  /// In en, this message translates to:
  /// **'Summary Period'**
  String get selectMonthLabel;

  /// No description provided for @monthlySummaryTab.
  ///
  /// In en, this message translates to:
  /// **'Monthly Summary 🌙'**
  String get monthlySummaryTab;

  /// No description provided for @todayOnly.
  ///
  /// In en, this message translates to:
  /// **'Today only ☀️'**
  String get todayOnly;

  /// Display the duration of the journey
  ///
  /// In en, this message translates to:
  /// **'{count} days journey 🚀'**
  String journeyDuration(String count);

  /// No description provided for @survivalStateNotSetBadge.
  ///
  /// In en, this message translates to:
  /// **'NOT SET'**
  String get survivalStateNotSetBadge;

  /// No description provided for @survivalStateNotSetHeading.
  ///
  /// In en, this message translates to:
  /// **'Budget not set'**
  String get survivalStateNotSetHeading;

  /// No description provided for @survivalStateNotSetPunchline.
  ///
  /// In en, this message translates to:
  /// **'Set up a budget so Moment u Payment can help you track your spending!'**
  String get survivalStateNotSetPunchline;

  /// No description provided for @survivalStateGodModeBadge.
  ///
  /// In en, this message translates to:
  /// **'COMFORTABLE'**
  String get survivalStateGodModeBadge;

  /// No description provided for @survivalStateGodModeHeading.
  ///
  /// In en, this message translates to:
  /// **'Up to {amount}/day'**
  String survivalStateGodModeHeading(String amount);

  /// No description provided for @survivalStateGodModePunchline.
  ///
  /// In en, this message translates to:
  /// **'Your spending pace is perfect. Keep up this great form!'**
  String get survivalStateGodModePunchline;

  /// No description provided for @survivalStateDangerBadge.
  ///
  /// In en, this message translates to:
  /// **'YELLOW ALERT'**
  String get survivalStateDangerBadge;

  /// No description provided for @survivalStateDangerHeading.
  ///
  /// In en, this message translates to:
  /// **'Spending {amount}/day'**
  String survivalStateDangerHeading(String amount);

  /// No description provided for @survivalStateDangerPunchline.
  ///
  /// In en, this message translates to:
  /// **'Budget is draining. Stick to this daily limit to survive the month!'**
  String get survivalStateDangerPunchline;

  /// No description provided for @survivalStateApocalypseBadge.
  ///
  /// In en, this message translates to:
  /// **'RED ALERT'**
  String get survivalStateApocalypseBadge;

  /// No description provided for @survivalStateApocalypseHeading.
  ///
  /// In en, this message translates to:
  /// **'Survive on {amount}/day'**
  String survivalStateApocalypseHeading(String amount);

  /// No description provided for @survivalStateApocalypsePunchline.
  ///
  /// In en, this message translates to:
  /// **'SOS! Your wallet is crying for help. Activate austerity mode immediately!'**
  String get survivalStateApocalypsePunchline;

  /// No description provided for @survivalStateWastedBadge.
  ///
  /// In en, this message translates to:
  /// **'OVERSPENT'**
  String get survivalStateWastedBadge;

  /// No description provided for @survivalStateWastedHeading.
  ///
  /// In en, this message translates to:
  /// **'Budget Depleted'**
  String get survivalStateWastedHeading;

  /// No description provided for @survivalStateWastedPunchline.
  ///
  /// In en, this message translates to:
  /// **'You have exceeded this month\'s budget. Safe daily limit is 0!'**
  String get survivalStateWastedPunchline;

  /// No description provided for @setupRadarNow.
  ///
  /// In en, this message translates to:
  /// **'Set up now to activate radar'**
  String get setupRadarNow;

  /// No description provided for @spentOutOffLimit.
  ///
  /// In en, this message translates to:
  /// **'Spent: {spent} / {limit}'**
  String spentOutOffLimit(String spent, String limit);

  /// No description provided for @budgetCardCosmicMessage.
  ///
  /// In en, this message translates to:
  /// **'Cosmic message:'**
  String get budgetCardCosmicMessage;

  /// No description provided for @budgetCardTapToView.
  ///
  /// In en, this message translates to:
  /// **'Tap to view reminder...'**
  String get budgetCardTapToView;

  /// No description provided for @budgetHeaderSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Set up your financial shield to keep your wallet safe.'**
  String get budgetHeaderSubtitle;

  /// No description provided for @budgetDailySafeLimitTitle.
  ///
  /// In en, this message translates to:
  /// **'Daily Safe Limit'**
  String get budgetDailySafeLimitTitle;

  /// No description provided for @budgetStatusSafe.
  ///
  /// In en, this message translates to:
  /// **'Perfect Safe ✨'**
  String get budgetStatusSafe;

  /// No description provided for @invalidAmountMessage.
  ///
  /// In en, this message translates to:
  /// **'Please enter a valid amount! 💸'**
  String get invalidAmountMessage;

  /// No description provided for @budgetLifestyleTitle.
  ///
  /// In en, this message translates to:
  /// **'Daily Lifestyle'**
  String get budgetLifestyleTitle;

  /// No description provided for @budgetLifestyleStart.
  ///
  /// In en, this message translates to:
  /// **'Let\'s start planning! 🎯'**
  String get budgetLifestyleStart;

  /// No description provided for @blessingMessage.
  ///
  /// In en, this message translates to:
  /// **'God bless you 🫨'**
  String get blessingMessage;

  /// No description provided for @budgetLifestyleLow.
  ///
  /// In en, this message translates to:
  /// **'Broke \'n\' Poor 💸'**
  String get budgetLifestyleLow;

  /// No description provided for @budgetLifestyleMedium.
  ///
  /// In en, this message translates to:
  /// **'Living on a budget 🥂'**
  String get budgetLifestyleMedium;

  /// No description provided for @budgetLifestyleHigh.
  ///
  /// In en, this message translates to:
  /// **'Living like royalty 👑'**
  String get budgetLifestyleHigh;

  /// No description provided for @budgetLifestyleActive.
  ///
  /// In en, this message translates to:
  /// **'Enjoy your active life! ✨'**
  String get budgetLifestyleActive;

  /// No description provided for @chooseCurrencyTitle.
  ///
  /// In en, this message translates to:
  /// **'Select Currency'**
  String get chooseCurrencyTitle;

  /// No description provided for @currencyVND.
  ///
  /// In en, this message translates to:
  /// **'Vietnam Dong (VND)'**
  String get currencyVND;

  /// No description provided for @budgetUpdateSuccess.
  ///
  /// In en, this message translates to:
  /// **'Budget updated successfully!'**
  String get budgetUpdateSuccess;

  /// No description provided for @budgetUpdateError.
  ///
  /// In en, this message translates to:
  /// **'Update failed, please try again!'**
  String get budgetUpdateError;

  /// No description provided for @momentCreatorTitle.
  ///
  /// In en, this message translates to:
  /// **'MOMENT CREATOR'**
  String get momentCreatorTitle;

  /// No description provided for @editPhotoDone.
  ///
  /// In en, this message translates to:
  /// **'Done'**
  String get editPhotoDone;

  /// No description provided for @editPhotoCancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get editPhotoCancel;

  /// No description provided for @editPhotoApply.
  ///
  /// In en, this message translates to:
  /// **'Apply'**
  String get editPhotoApply;

  /// No description provided for @editPhotoFilter.
  ///
  /// In en, this message translates to:
  /// **'Filter'**
  String get editPhotoFilter;

  /// No description provided for @editPhotoCrop.
  ///
  /// In en, this message translates to:
  /// **'Crop'**
  String get editPhotoCrop;

  /// No description provided for @editPhotoBeauty.
  ///
  /// In en, this message translates to:
  /// **'Beauty'**
  String get editPhotoBeauty;

  /// No description provided for @editPhotoSticker.
  ///
  /// In en, this message translates to:
  /// **'Sticker'**
  String get editPhotoSticker;

  /// No description provided for @filterPortrait.
  ///
  /// In en, this message translates to:
  /// **'👤 PORTRAIT'**
  String get filterPortrait;

  /// No description provided for @filterFood.
  ///
  /// In en, this message translates to:
  /// **'🍳 FOODIE'**
  String get filterFood;

  /// No description provided for @cropInstruction.
  ///
  /// In en, this message translates to:
  /// **'Drag the corners to adjust the frame.\nTap \'Apply\' to crop the image.'**
  String get cropInstruction;

  /// No description provided for @beautyGlow.
  ///
  /// In en, this message translates to:
  /// **'✨ Brighten'**
  String get beautyGlow;

  /// No description provided for @beautySmooth.
  ///
  /// In en, this message translates to:
  /// **'🧼 Smooth'**
  String get beautySmooth;

  /// No description provided for @beautyPop.
  ///
  /// In en, this message translates to:
  /// **'💥 Vivid'**
  String get beautyPop;

  /// No description provided for @stickerCute.
  ///
  /// In en, this message translates to:
  /// **'🧸 ICONS'**
  String get stickerCute;

  /// No description provided for @stickerText.
  ///
  /// In en, this message translates to:
  /// **'✍️ TEXT'**
  String get stickerText;

  /// No description provided for @stickerSize.
  ///
  /// In en, this message translates to:
  /// **'📐 Size:'**
  String get stickerSize;

  /// No description provided for @editStickerTitle.
  ///
  /// In en, this message translates to:
  /// **'Edit Sticker Text'**
  String get editStickerTitle;

  /// No description provided for @filterOriginal.
  ///
  /// In en, this message translates to:
  /// **'Original'**
  String get filterOriginal;

  /// No description provided for @filterCreamy.
  ///
  /// In en, this message translates to:
  /// **'Creamy'**
  String get filterCreamy;

  /// No description provided for @filterPink.
  ///
  /// In en, this message translates to:
  /// **'Pinkish'**
  String get filterPink;

  /// No description provided for @filterVintage.
  ///
  /// In en, this message translates to:
  /// **'Vintage'**
  String get filterVintage;

  /// No description provided for @filterPoetic.
  ///
  /// In en, this message translates to:
  /// **'Poetic'**
  String get filterPoetic;

  /// No description provided for @filterFoodFresh.
  ///
  /// In en, this message translates to:
  /// **'Fresh'**
  String get filterFoodFresh;

  /// No description provided for @filterFoodJuicy.
  ///
  /// In en, this message translates to:
  /// **'Juicy'**
  String get filterFoodJuicy;

  /// No description provided for @filterFoodSweet.
  ///
  /// In en, this message translates to:
  /// **'Sweet'**
  String get filterFoodSweet;

  /// No description provided for @filterFoodGold.
  ///
  /// In en, this message translates to:
  /// **'Gold'**
  String get filterFoodGold;

  /// No description provided for @filterFoodForest.
  ///
  /// In en, this message translates to:
  /// **'Forest'**
  String get filterFoodForest;

  /// No description provided for @tapToCapture.
  ///
  /// In en, this message translates to:
  /// **'Tap to capture'**
  String get tapToCapture;

  /// No description provided for @exit.
  ///
  /// In en, this message translates to:
  /// **'Exit'**
  String get exit;

  /// No description provided for @editPhotoTitle.
  ///
  /// In en, this message translates to:
  /// **'Edit'**
  String get editPhotoTitle;

  /// No description provided for @filterNameOriginal.
  ///
  /// In en, this message translates to:
  /// **'ORIGINAL'**
  String get filterNameOriginal;

  /// No description provided for @filterNameCream.
  ///
  /// In en, this message translates to:
  /// **'CREAMY VINTAGE'**
  String get filterNameCream;

  /// No description provided for @filterNameAesthetic.
  ///
  /// In en, this message translates to:
  /// **'SOFT AESTHETIC'**
  String get filterNameAesthetic;

  /// No description provided for @filterNameMoody.
  ///
  /// In en, this message translates to:
  /// **'MOODY CINEMA'**
  String get filterNameMoody;

  /// No description provided for @filterNameNoir.
  ///
  /// In en, this message translates to:
  /// **'NOIR ELEGANCE (B&W)'**
  String get filterNameNoir;

  /// No description provided for @filterNameGourmet.
  ///
  /// In en, this message translates to:
  /// **'GOURMET VIVID'**
  String get filterNameGourmet;

  /// No description provided for @filterNameWarm.
  ///
  /// In en, this message translates to:
  /// **'WARM CAFE'**
  String get filterNameWarm;

  /// No description provided for @filterNameFresh.
  ///
  /// In en, this message translates to:
  /// **'FRESH ORGANIC'**
  String get filterNameFresh;

  /// Tab or button to switch to text sticker mode
  ///
  /// In en, this message translates to:
  /// **'Text Sticker'**
  String get stickerAddText;

  /// Instruction for editing and transforming stickers using gestures
  ///
  /// In en, this message translates to:
  /// **'Tap text on the image to edit\nUse two fingers to rotate & zoom'**
  String get stickerInstruction;

  /// Hint text inside the text input field for custom text stickers
  ///
  /// In en, this message translates to:
  /// **'Type something cute...'**
  String get stickerTextHint;

  /// Sub-tab label for fashion portrait filters
  ///
  /// In en, this message translates to:
  /// **'Fashion Portrait'**
  String get filterFashionPortrait;

  /// Sub-tab label for food filters
  ///
  /// In en, this message translates to:
  /// **'Moment Food'**
  String get filterMomentFood;

  /// Button to rotate image by 90 degrees
  ///
  /// In en, this message translates to:
  /// **'Rotate 90°'**
  String get cropRotate90;

  /// Button to reset crop or rotation settings
  ///
  /// In en, this message translates to:
  /// **'Reset'**
  String get cropReset;

  /// Text showing instructions to drag a sticker to the delete zone
  ///
  /// In en, this message translates to:
  /// **'Drag here to delete 🗑️'**
  String get stickerDeleteDrag;

  /// Text showing instructions when a sticker is hovering right over the delete zone
  ///
  /// In en, this message translates to:
  /// **'Release to delete 🔥'**
  String get stickerDeleteDrop;

  /// No description provided for @mySpendingSafeZone.
  ///
  /// In en, this message translates to:
  /// **'My spending safe-zone'**
  String get mySpendingSafeZone;

  /// Title for the budget status section
  ///
  /// In en, this message translates to:
  /// **'BUDGET STATUS'**
  String get budgetStatusTitle;

  /// Title for the budget status section when not set
  ///
  /// In en, this message translates to:
  /// **'Budget status'**
  String get budgetStatusTitleNotSet;

  /// Advice shown when budget is zero or negative
  ///
  /// In en, this message translates to:
  /// **'You have exhausted or exceeded your budget limit for this month! 😰'**
  String get budgetAdviceExceeded;

  /// Advice for daily safe spending limit
  ///
  /// In en, this message translates to:
  /// **'{days} days left in the month. You should spend an average of max {amount}/day to keep your budget safe.'**
  String budgetAdviceSafeDaily(int days, String amount);

  /// Label for remaining amount on the progress bar
  ///
  /// In en, this message translates to:
  /// **'Left: {amount}'**
  String budgetBarLeft(String amount);

  /// Label for remaining amount when budget is not set
  ///
  /// In en, this message translates to:
  /// **'Left: --'**
  String get budgetBarLeftNotSet;

  /// Label for total limit on the progress bar
  ///
  /// In en, this message translates to:
  /// **'Limit: {amount}'**
  String budgetBarLimit(String amount);

  /// Date format for the day details bottom sheet
  ///
  /// In en, this message translates to:
  /// **'{day}{suffix} {month}, {year}'**
  String dayDetailsFormat(String day, String suffix, String month, String year);

  /// No description provided for @year.
  ///
  /// In en, this message translates to:
  /// **'Year'**
  String get year;

  /// No description provided for @diaryInsightTitle.
  ///
  /// In en, this message translates to:
  /// **'Diary Insight'**
  String get diaryInsightTitle;

  /// No description provided for @biggestSplurgesTitle.
  ///
  /// In en, this message translates to:
  /// **'My Biggest Splurges'**
  String get biggestSplurgesTitle;

  /// Text for See all button
  ///
  /// In en, this message translates to:
  /// **'See all'**
  String get seeAll;

  /// Dynamic text for diary insights
  ///
  /// In en, this message translates to:
  /// **'{percent}% of your budget went into \'{category1}\' & \'{category2}\' on {time}! Your happiest moments (🥰) were spent at {location}.'**
  String diaryInsightDynamicBody(
    String percent,
    String category1,
    String category2,
    String time,
    String location,
  );

  /// No description provided for @allSplurgesTitle.
  ///
  /// In en, this message translates to:
  /// **'Hall of Fame 🏆'**
  String get allSplurgesTitle;

  /// No description provided for @allSplurgesSubtitle.
  ///
  /// In en, this message translates to:
  /// **'A look back at your deepest splurges. Don\'t regret the experience! ✨'**
  String get allSplurgesSubtitle;

  /// No description provided for @errorOccurred.
  ///
  /// In en, this message translates to:
  /// **'An error occurred! Please try again.'**
  String get errorOccurred;

  /// No description provided for @noSplurgesYet.
  ///
  /// In en, this message translates to:
  /// **'No massive splurges yet ✨'**
  String get noSplurgesYet;

  /// No description provided for @dashboardTotalSpent.
  ///
  /// In en, this message translates to:
  /// **'Total Spent'**
  String get dashboardTotalSpent;

  /// No description provided for @dashboardHighestSpent.
  ///
  /// In en, this message translates to:
  /// **'Highest'**
  String get dashboardHighestSpent;

  /// No description provided for @dashboardQuantity.
  ///
  /// In en, this message translates to:
  /// **'Quantity'**
  String get dashboardQuantity;

  /// No description provided for @filterAll.
  ///
  /// In en, this message translates to:
  /// **'All Time'**
  String get filterAll;

  /// No description provided for @filterMonth.
  ///
  /// In en, this message translates to:
  /// **'This Month'**
  String get filterMonth;

  /// No description provided for @filterWeek.
  ///
  /// In en, this message translates to:
  /// **'Last 7 Days'**
  String get filterWeek;

  /// No description provided for @displayCountItem.
  ///
  /// In en, this message translates to:
  /// **'items'**
  String get displayCountItem;

  /// No description provided for @recapTitleMonthly.
  ///
  /// In en, this message translates to:
  /// **'MONTHLY RECAP • {month}'**
  String recapTitleMonthly(String month);

  /// No description provided for @recapTitleYearly.
  ///
  /// In en, this message translates to:
  /// **'YEARLY RECAP • {year}'**
  String recapTitleYearly(String year);

  /// No description provided for @recapIntroMain.
  ///
  /// In en, this message translates to:
  /// **'This month,\nyou were brilliant!'**
  String get recapIntroMain;

  /// No description provided for @recapIntroSub.
  ///
  /// In en, this message translates to:
  /// **'Moment U has captured your personal financial journey.'**
  String get recapIntroSub;

  /// No description provided for @recapSwipeCountMain.
  ///
  /// In en, this message translates to:
  /// **'You\'ve recorded \n{count} spending moments'**
  String recapSwipeCountMain(int count);

  /// No description provided for @recapSwipeCountSub.
  ///
  /// In en, this message translates to:
  /// **'Extremely active in optimizing your personal cash flow!'**
  String get recapSwipeCountSub;

  /// No description provided for @recapSavingsMain.
  ///
  /// In en, this message translates to:
  /// **'Saved\n{amount}'**
  String recapSavingsMain(String amount);

  /// No description provided for @recapSavingsSub.
  ///
  /// In en, this message translates to:
  /// **'Outstanding job cutting back expenses and managing money wisely!'**
  String get recapSavingsSub;

  /// No description provided for @recapShareMessage.
  ///
  /// In en, this message translates to:
  /// **'Looking back at my financial journey this month with Moments U Payment! 🎉'**
  String get recapShareMessage;

  /// No description provided for @recapComparisonMore.
  ///
  /// In en, this message translates to:
  /// **'Spent {amount} more than the month before'**
  String recapComparisonMore(String amount);

  /// No description provided for @recapComparisonLess.
  ///
  /// In en, this message translates to:
  /// **'Saved {amount} compared to the month before'**
  String recapComparisonLess(String amount);

  /// No description provided for @recapComparisonEqual.
  ///
  /// In en, this message translates to:
  /// **'Spending remained stable compared to the month before'**
  String get recapComparisonEqual;

  /// No description provided for @recapOverBudget.
  ///
  /// In en, this message translates to:
  /// **'Over budget by {amount} 🤯'**
  String recapOverBudget(String amount);

  /// No description provided for @recapUnderBudget.
  ///
  /// In en, this message translates to:
  /// **'Saved {amount} from your budget ✨'**
  String recapUnderBudget(String amount);

  /// No description provided for @recapBadgeResetNotice.
  ///
  /// In en, this message translates to:
  /// **'Monthly badges will be reset this month, ready for your next challenge!'**
  String get recapBadgeResetNotice;

  /// No description provided for @recapViewAnalytics.
  ///
  /// In en, this message translates to:
  /// **'Explore in-depth analytics'**
  String get recapViewAnalytics;

  /// No description provided for @recapEarnedBadges.
  ///
  /// In en, this message translates to:
  /// **'Achievements you\'ve earned'**
  String get recapEarnedBadges;
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
