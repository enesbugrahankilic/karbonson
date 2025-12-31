import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
import 'app_localizations_tr.dart';

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
    Locale('tr'),
    Locale('en')
  ];

  /// No description provided for @appName.
  ///
  /// In en, this message translates to:
  /// **'Eco Game'**
  String get appName;

  /// No description provided for @appNameHighContrast.
  ///
  /// In en, this message translates to:
  /// **'Eco Game - High Contrast'**
  String get appNameHighContrast;

  /// No description provided for @loading.
  ///
  /// In en, this message translates to:
  /// **'Loading...'**
  String get loading;

  /// No description provided for @pleaseWait.
  ///
  /// In en, this message translates to:
  /// **'Please wait'**
  String get pleaseWait;

  /// No description provided for @startupError.
  ///
  /// In en, this message translates to:
  /// **'Startup Error'**
  String get startupError;

  /// No description provided for @startupErrorDescription.
  ///
  /// In en, this message translates to:
  /// **'An error occurred while starting the application.'**
  String get startupErrorDescription;

  /// No description provided for @retry.
  ///
  /// In en, this message translates to:
  /// **'Retry'**
  String get retry;

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
  /// **'Email'**
  String get email;

  /// No description provided for @password.
  ///
  /// In en, this message translates to:
  /// **'Password'**
  String get password;

  /// No description provided for @confirmPassword.
  ///
  /// In en, this message translates to:
  /// **'Confirm Password'**
  String get confirmPassword;

  /// No description provided for @nickname.
  ///
  /// In en, this message translates to:
  /// **'Nickname'**
  String get nickname;

  /// No description provided for @forgotPassword.
  ///
  /// In en, this message translates to:
  /// **'Forgot Password'**
  String get forgotPassword;

  /// No description provided for @resetPassword.
  ///
  /// In en, this message translates to:
  /// **'Reset Password'**
  String get resetPassword;

  /// No description provided for @twoFactorAuth.
  ///
  /// In en, this message translates to:
  /// **'Two-Factor Authentication'**
  String get twoFactorAuth;

  /// No description provided for @enable2FA.
  ///
  /// In en, this message translates to:
  /// **'Enable 2FA'**
  String get enable2FA;

  /// No description provided for @disable2FA.
  ///
  /// In en, this message translates to:
  /// **'Disable 2FA'**
  String get disable2FA;

  /// No description provided for @enterVerificationCode.
  ///
  /// In en, this message translates to:
  /// **'Enter verification code'**
  String get enterVerificationCode;

  /// No description provided for @biometricLogin.
  ///
  /// In en, this message translates to:
  /// **'Biometric Login'**
  String get biometricLogin;

  /// No description provided for @faceId.
  ///
  /// In en, this message translates to:
  /// **'Face ID'**
  String get faceId;

  /// No description provided for @touchId.
  ///
  /// In en, this message translates to:
  /// **'Touch ID'**
  String get touchId;

  /// No description provided for @fingerprint.
  ///
  /// In en, this message translates to:
  /// **'Fingerprint'**
  String get fingerprint;

  /// No description provided for @home.
  ///
  /// In en, this message translates to:
  /// **'Home'**
  String get home;

  /// No description provided for @profile.
  ///
  /// In en, this message translates to:
  /// **'Profile'**
  String get profile;

  /// No description provided for @settings.
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get settings;

  /// No description provided for @friends.
  ///
  /// In en, this message translates to:
  /// **'Friends'**
  String get friends;

  /// No description provided for @achievements.
  ///
  /// In en, this message translates to:
  /// **'Achievements'**
  String get achievements;

  /// No description provided for @leaderboard.
  ///
  /// In en, this message translates to:
  /// **'Leaderboard'**
  String get leaderboard;

  /// No description provided for @quiz.
  ///
  /// In en, this message translates to:
  /// **'Quiz'**
  String get quiz;

  /// No description provided for @dailyChallenge.
  ///
  /// In en, this message translates to:
  /// **'Daily Challenge'**
  String get dailyChallenge;

  /// No description provided for @gameMode.
  ///
  /// In en, this message translates to:
  /// **'Game Mode'**
  String get gameMode;

  /// No description provided for @difficulty.
  ///
  /// In en, this message translates to:
  /// **'Difficulty'**
  String get difficulty;

  /// No description provided for @easy.
  ///
  /// In en, this message translates to:
  /// **'Easy'**
  String get easy;

  /// No description provided for @medium.
  ///
  /// In en, this message translates to:
  /// **'Medium'**
  String get medium;

  /// No description provided for @hard.
  ///
  /// In en, this message translates to:
  /// **'Hard'**
  String get hard;

  /// No description provided for @multiplayer.
  ///
  /// In en, this message translates to:
  /// **'Multiplayer'**
  String get multiplayer;

  /// No description provided for @duel.
  ///
  /// In en, this message translates to:
  /// **'Duel'**
  String get duel;

  /// No description provided for @inviteFriend.
  ///
  /// In en, this message translates to:
  /// **'Invite Friend'**
  String get inviteFriend;

  /// No description provided for @friendRequest.
  ///
  /// In en, this message translates to:
  /// **'Friend Request'**
  String get friendRequest;

  /// No description provided for @accept.
  ///
  /// In en, this message translates to:
  /// **'Accept'**
  String get accept;

  /// No description provided for @decline.
  ///
  /// In en, this message translates to:
  /// **'Decline'**
  String get decline;

  /// No description provided for @logout.
  ///
  /// In en, this message translates to:
  /// **'Logout'**
  String get logout;

  /// No description provided for @language.
  ///
  /// In en, this message translates to:
  /// **'Language'**
  String get language;

  /// No description provided for @theme.
  ///
  /// In en, this message translates to:
  /// **'Theme'**
  String get theme;

  /// No description provided for @darkMode.
  ///
  /// In en, this message translates to:
  /// **'Dark Mode'**
  String get darkMode;

  /// No description provided for @lightMode.
  ///
  /// In en, this message translates to:
  /// **'Light Mode'**
  String get lightMode;

  /// No description provided for @highContrast.
  ///
  /// In en, this message translates to:
  /// **'High Contrast'**
  String get highContrast;

  /// No description provided for @notifications.
  ///
  /// In en, this message translates to:
  /// **'Notifications'**
  String get notifications;

  /// No description provided for @privacy.
  ///
  /// In en, this message translates to:
  /// **'Privacy'**
  String get privacy;

  /// No description provided for @about.
  ///
  /// In en, this message translates to:
  /// **'About'**
  String get about;

  /// No description provided for @version.
  ///
  /// In en, this message translates to:
  /// **'Version'**
  String get version;

  /// No description provided for @tutorial.
  ///
  /// In en, this message translates to:
  /// **'Tutorial'**
  String get tutorial;

  /// No description provided for @skip.
  ///
  /// In en, this message translates to:
  /// **'Skip'**
  String get skip;

  /// No description provided for @next.
  ///
  /// In en, this message translates to:
  /// **'Next'**
  String get next;

  /// No description provided for @finish.
  ///
  /// In en, this message translates to:
  /// **'Finish'**
  String get finish;

  /// No description provided for @error.
  ///
  /// In en, this message translates to:
  /// **'Error'**
  String get error;

  /// No description provided for @success.
  ///
  /// In en, this message translates to:
  /// **'Success'**
  String get success;

  /// No description provided for @warning.
  ///
  /// In en, this message translates to:
  /// **'Warning'**
  String get warning;

  /// No description provided for @info.
  ///
  /// In en, this message translates to:
  /// **'Information'**
  String get info;

  /// No description provided for @ok.
  ///
  /// In en, this message translates to:
  /// **'OK'**
  String get ok;

  /// No description provided for @cancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get cancel;

  /// No description provided for @yes.
  ///
  /// In en, this message translates to:
  /// **'Yes'**
  String get yes;

  /// No description provided for @no.
  ///
  /// In en, this message translates to:
  /// **'No'**
  String get no;

  /// No description provided for @save.
  ///
  /// In en, this message translates to:
  /// **'Save'**
  String get save;

  /// No description provided for @delete.
  ///
  /// In en, this message translates to:
  /// **'Delete'**
  String get delete;

  /// No description provided for @edit.
  ///
  /// In en, this message translates to:
  /// **'Edit'**
  String get edit;

  /// No description provided for @add.
  ///
  /// In en, this message translates to:
  /// **'Add'**
  String get add;

  /// No description provided for @remove.
  ///
  /// In en, this message translates to:
  /// **'Remove'**
  String get remove;

  /// No description provided for @update.
  ///
  /// In en, this message translates to:
  /// **'Update'**
  String get update;

  /// No description provided for @refresh.
  ///
  /// In en, this message translates to:
  /// **'Refresh'**
  String get refresh;

  /// No description provided for @back.
  ///
  /// In en, this message translates to:
  /// **'Back'**
  String get back;

  /// No description provided for @forward.
  ///
  /// In en, this message translates to:
  /// **'Forward'**
  String get forward;

  /// No description provided for @close.
  ///
  /// In en, this message translates to:
  /// **'Close'**
  String get close;

  /// No description provided for @open.
  ///
  /// In en, this message translates to:
  /// **'Open'**
  String get open;

  /// No description provided for @select.
  ///
  /// In en, this message translates to:
  /// **'Select'**
  String get select;

  /// No description provided for @upload.
  ///
  /// In en, this message translates to:
  /// **'Upload'**
  String get upload;

  /// No description provided for @download.
  ///
  /// In en, this message translates to:
  /// **'Download'**
  String get download;

  /// No description provided for @share.
  ///
  /// In en, this message translates to:
  /// **'Share'**
  String get share;

  /// No description provided for @copy.
  ///
  /// In en, this message translates to:
  /// **'Copy'**
  String get copy;

  /// No description provided for @paste.
  ///
  /// In en, this message translates to:
  /// **'Paste'**
  String get paste;

  /// No description provided for @cut.
  ///
  /// In en, this message translates to:
  /// **'Cut'**
  String get cut;

  /// No description provided for @undo.
  ///
  /// In en, this message translates to:
  /// **'Undo'**
  String get undo;

  /// No description provided for @redo.
  ///
  /// In en, this message translates to:
  /// **'Redo'**
  String get redo;

  /// No description provided for @search.
  ///
  /// In en, this message translates to:
  /// **'Search'**
  String get search;

  /// No description provided for @filter.
  ///
  /// In en, this message translates to:
  /// **'Filter'**
  String get filter;

  /// No description provided for @sort.
  ///
  /// In en, this message translates to:
  /// **'Sort'**
  String get sort;

  /// No description provided for @ascending.
  ///
  /// In en, this message translates to:
  /// **'Ascending'**
  String get ascending;

  /// No description provided for @descending.
  ///
  /// In en, this message translates to:
  /// **'Descending'**
  String get descending;

  /// No description provided for @name.
  ///
  /// In en, this message translates to:
  /// **'Name'**
  String get name;

  /// No description provided for @date.
  ///
  /// In en, this message translates to:
  /// **'Date'**
  String get date;

  /// No description provided for @time.
  ///
  /// In en, this message translates to:
  /// **'Time'**
  String get time;

  /// No description provided for @score.
  ///
  /// In en, this message translates to:
  /// **'Score'**
  String get score;

  /// No description provided for @points.
  ///
  /// In en, this message translates to:
  /// **'Points'**
  String get points;

  /// No description provided for @level.
  ///
  /// In en, this message translates to:
  /// **'Level'**
  String get level;

  /// No description provided for @progress.
  ///
  /// In en, this message translates to:
  /// **'Progress'**
  String get progress;

  /// No description provided for @completed.
  ///
  /// In en, this message translates to:
  /// **'Completed'**
  String get completed;

  /// No description provided for @pending.
  ///
  /// In en, this message translates to:
  /// **'Pending'**
  String get pending;

  /// No description provided for @processing.
  ///
  /// In en, this message translates to:
  /// **'Processing'**
  String get processing;

  /// No description provided for @sending.
  ///
  /// In en, this message translates to:
  /// **'Sending'**
  String get sending;

  /// No description provided for @receiving.
  ///
  /// In en, this message translates to:
  /// **'Receiving'**
  String get receiving;

  /// No description provided for @syncing.
  ///
  /// In en, this message translates to:
  /// **'Syncing'**
  String get syncing;

  /// No description provided for @connecting.
  ///
  /// In en, this message translates to:
  /// **'Connecting'**
  String get connecting;

  /// No description provided for @disconnected.
  ///
  /// In en, this message translates to:
  /// **'Disconnected'**
  String get disconnected;

  /// No description provided for @noInternetConnection.
  ///
  /// In en, this message translates to:
  /// **'No internet connection'**
  String get noInternetConnection;

  /// No description provided for @offline.
  ///
  /// In en, this message translates to:
  /// **'Offline'**
  String get offline;

  /// No description provided for @online.
  ///
  /// In en, this message translates to:
  /// **'Online'**
  String get online;

  /// No description provided for @connectionError.
  ///
  /// In en, this message translates to:
  /// **'Connection error'**
  String get connectionError;

  /// No description provided for @timeout.
  ///
  /// In en, this message translates to:
  /// **'Timeout'**
  String get timeout;

  /// No description provided for @retrying.
  ///
  /// In en, this message translates to:
  /// **'Retrying'**
  String get retrying;

  /// No description provided for @networkError.
  ///
  /// In en, this message translates to:
  /// **'Network error'**
  String get networkError;

  /// No description provided for @serverError.
  ///
  /// In en, this message translates to:
  /// **'Server error'**
  String get serverError;

  /// No description provided for @notFound.
  ///
  /// In en, this message translates to:
  /// **'Not found'**
  String get notFound;

  /// No description provided for @accessDenied.
  ///
  /// In en, this message translates to:
  /// **'Access denied'**
  String get accessDenied;

  /// No description provided for @unauthorized.
  ///
  /// In en, this message translates to:
  /// **'Unauthorized'**
  String get unauthorized;

  /// No description provided for @forbidden.
  ///
  /// In en, this message translates to:
  /// **'Forbidden'**
  String get forbidden;

  /// No description provided for @badRequest.
  ///
  /// In en, this message translates to:
  /// **'Bad request'**
  String get badRequest;

  /// No description provided for @validationError.
  ///
  /// In en, this message translates to:
  /// **'Validation error'**
  String get validationError;

  /// No description provided for @invalidInput.
  ///
  /// In en, this message translates to:
  /// **'Invalid input'**
  String get invalidInput;

  /// No description provided for @requiredField.
  ///
  /// In en, this message translates to:
  /// **'Required field'**
  String get requiredField;

  /// No description provided for @invalidEmail.
  ///
  /// In en, this message translates to:
  /// **'Invalid email address'**
  String get invalidEmail;

  /// No description provided for @passwordTooShort.
  ///
  /// In en, this message translates to:
  /// **'Password too short'**
  String get passwordTooShort;

  /// No description provided for @passwordMismatch.
  ///
  /// In en, this message translates to:
  /// **'Passwords do not match'**
  String get passwordMismatch;

  /// No description provided for @nicknameTooShort.
  ///
  /// In en, this message translates to:
  /// **'Nickname too short'**
  String get nicknameTooShort;

  /// No description provided for @nicknameTooLong.
  ///
  /// In en, this message translates to:
  /// **'Nickname too long'**
  String get nicknameTooLong;

  /// No description provided for @nicknameInvalid.
  ///
  /// In en, this message translates to:
  /// **'Invalid nickname'**
  String get nicknameInvalid;

  /// No description provided for @emailAlreadyExists.
  ///
  /// In en, this message translates to:
  /// **'Email already exists'**
  String get emailAlreadyExists;

  /// No description provided for @nicknameAlreadyExists.
  ///
  /// In en, this message translates to:
  /// **'Nickname already exists'**
  String get nicknameAlreadyExists;

  /// No description provided for @accountNotFound.
  ///
  /// In en, this message translates to:
  /// **'Account not found'**
  String get accountNotFound;

  /// No description provided for @incorrectPassword.
  ///
  /// In en, this message translates to:
  /// **'Incorrect password'**
  String get incorrectPassword;

  /// No description provided for @tooManyAttempts.
  ///
  /// In en, this message translates to:
  /// **'Too many attempts'**
  String get tooManyAttempts;

  /// No description provided for @accountLocked.
  ///
  /// In en, this message translates to:
  /// **'Account locked'**
  String get accountLocked;

  /// No description provided for @emailNotVerified.
  ///
  /// In en, this message translates to:
  /// **'Email not verified'**
  String get emailNotVerified;

  /// No description provided for @verificationEmailSent.
  ///
  /// In en, this message translates to:
  /// **'Verification email sent'**
  String get verificationEmailSent;

  /// No description provided for @checkEmail.
  ///
  /// In en, this message translates to:
  /// **'Please check your email'**
  String get checkEmail;

  /// No description provided for @verificationLinkExpired.
  ///
  /// In en, this message translates to:
  /// **'Verification link expired'**
  String get verificationLinkExpired;

  /// No description provided for @resendEmail.
  ///
  /// In en, this message translates to:
  /// **'Resend email'**
  String get resendEmail;

  /// No description provided for @changeEmail.
  ///
  /// In en, this message translates to:
  /// **'Change email'**
  String get changeEmail;

  /// No description provided for @updateProfile.
  ///
  /// In en, this message translates to:
  /// **'Update Profile'**
  String get updateProfile;

  /// No description provided for @changePassword.
  ///
  /// In en, this message translates to:
  /// **'Change Password'**
  String get changePassword;

  /// No description provided for @deleteAccount.
  ///
  /// In en, this message translates to:
  /// **'Delete Account'**
  String get deleteAccount;

  /// No description provided for @areYouSure.
  ///
  /// In en, this message translates to:
  /// **'Are you sure?'**
  String get areYouSure;

  /// No description provided for @confirmAction.
  ///
  /// In en, this message translates to:
  /// **'Confirm action'**
  String get confirmAction;

  /// No description provided for @thisActionCannotBeUndone.
  ///
  /// In en, this message translates to:
  /// **'This action cannot be undone'**
  String get thisActionCannotBeUndone;

  /// No description provided for @dataWillBeLost.
  ///
  /// In en, this message translates to:
  /// **'All your data will be lost'**
  String get dataWillBeLost;

  /// No description provided for @keep.
  ///
  /// In en, this message translates to:
  /// **'Keep'**
  String get keep;

  /// No description provided for @discard.
  ///
  /// In en, this message translates to:
  /// **'Discard'**
  String get discard;

  /// No description provided for @apply.
  ///
  /// In en, this message translates to:
  /// **'Apply'**
  String get apply;

  /// No description provided for @discardChanges.
  ///
  /// In en, this message translates to:
  /// **'Discard changes'**
  String get discardChanges;

  /// No description provided for @saveChanges.
  ///
  /// In en, this message translates to:
  /// **'Save changes'**
  String get saveChanges;

  /// No description provided for @unsavedChanges.
  ///
  /// In en, this message translates to:
  /// **'Unsaved changes'**
  String get unsavedChanges;

  /// No description provided for @changesNotSaved.
  ///
  /// In en, this message translates to:
  /// **'Changes not saved'**
  String get changesNotSaved;

  /// No description provided for @profileUpdated.
  ///
  /// In en, this message translates to:
  /// **'Profile updated successfully'**
  String get profileUpdated;

  /// No description provided for @passwordChanged.
  ///
  /// In en, this message translates to:
  /// **'Password changed successfully'**
  String get passwordChanged;

  /// No description provided for @emailSent.
  ///
  /// In en, this message translates to:
  /// **'Email sent successfully'**
  String get emailSent;

  /// No description provided for @verificationRequired.
  ///
  /// In en, this message translates to:
  /// **'Verification required'**
  String get verificationRequired;

  /// No description provided for @twoFactorRequired.
  ///
  /// In en, this message translates to:
  /// **'Two-factor authentication required'**
  String get twoFactorRequired;

  /// No description provided for @setup2FA.
  ///
  /// In en, this message translates to:
  /// **'Setup two-factor authentication'**
  String get setup2FA;

  /// No description provided for @scanQRCode.
  ///
  /// In en, this message translates to:
  /// **'Scan QR code'**
  String get scanQRCode;

  /// No description provided for @enterSecretKey.
  ///
  /// In en, this message translates to:
  /// **'Enter secret key manually'**
  String get enterSecretKey;

  /// No description provided for @backupCodes.
  ///
  /// In en, this message translates to:
  /// **'Backup codes'**
  String get backupCodes;

  /// No description provided for @generateNewCodes.
  ///
  /// In en, this message translates to:
  /// **'Generate new codes'**
  String get generateNewCodes;

  /// No description provided for @downloadCodes.
  ///
  /// In en, this message translates to:
  /// **'Download codes'**
  String get downloadCodes;

  /// No description provided for @codesGenerated.
  ///
  /// In en, this message translates to:
  /// **'New backup codes generated'**
  String get codesGenerated;

  /// No description provided for @backupCodesSaved.
  ///
  /// In en, this message translates to:
  /// **'Backup codes saved securely'**
  String get backupCodesSaved;

  /// No description provided for @enableBiometricAuth.
  ///
  /// In en, this message translates to:
  /// **'Enable biometric authentication'**
  String get enableBiometricAuth;

  /// No description provided for @biometricEnabled.
  ///
  /// In en, this message translates to:
  /// **'Biometric authentication enabled'**
  String get biometricEnabled;

  /// No description provided for @biometricDisabled.
  ///
  /// In en, this message translates to:
  /// **'Biometric authentication disabled'**
  String get biometricDisabled;

  /// No description provided for @faceIdNotAvailable.
  ///
  /// In en, this message translates to:
  /// **'Face ID not available'**
  String get faceIdNotAvailable;

  /// No description provided for @touchIdNotAvailable.
  ///
  /// In en, this message translates to:
  /// **'Touch ID not available'**
  String get touchIdNotAvailable;

  /// No description provided for @fingerprintNotAvailable.
  ///
  /// In en, this message translates to:
  /// **'Fingerprint not available'**
  String get fingerprintNotAvailable;

  /// No description provided for @biometricNotEnrolled.
  ///
  /// In en, this message translates to:
  /// **'Biometric authentication not enrolled'**
  String get biometricNotEnrolled;

  /// No description provided for @setupBiometric.
  ///
  /// In en, this message translates to:
  /// **'Setup biometric authentication'**
  String get setupBiometric;

  /// No description provided for @goToSettings.
  ///
  /// In en, this message translates to:
  /// **'Go to Settings'**
  String get goToSettings;

  /// No description provided for @biometricError.
  ///
  /// In en, this message translates to:
  /// **'Biometric authentication error'**
  String get biometricError;

  /// No description provided for @biometricCanceled.
  ///
  /// In en, this message translates to:
  /// **'Biometric authentication canceled'**
  String get biometricCanceled;

  /// No description provided for @biometricFailed.
  ///
  /// In en, this message translates to:
  /// **'Biometric authentication failed'**
  String get biometricFailed;

  /// No description provided for @enableNotifications.
  ///
  /// In en, this message translates to:
  /// **'Enable notifications'**
  String get enableNotifications;

  /// No description provided for @notificationsEnabled.
  ///
  /// In en, this message translates to:
  /// **'Notifications enabled'**
  String get notificationsEnabled;

  /// No description provided for @notificationsDisabled.
  ///
  /// In en, this message translates to:
  /// **'Notifications disabled'**
  String get notificationsDisabled;

  /// No description provided for @dailyReminder.
  ///
  /// In en, this message translates to:
  /// **'Daily quiz reminder'**
  String get dailyReminder;

  /// No description provided for @achievementUnlocked.
  ///
  /// In en, this message translates to:
  /// **'Achievement unlocked!'**
  String get achievementUnlocked;

  /// No description provided for @newLevel.
  ///
  /// In en, this message translates to:
  /// **'New level reached!'**
  String get newLevel;

  /// No description provided for @highScore.
  ///
  /// In en, this message translates to:
  /// **'New high score!'**
  String get highScore;

  /// No description provided for @friendAdded.
  ///
  /// In en, this message translates to:
  /// **'Friend added successfully'**
  String get friendAdded;

  /// No description provided for @friendRemoved.
  ///
  /// In en, this message translates to:
  /// **'Friend removed successfully'**
  String get friendRemoved;

  /// No description provided for @friendRequestSent.
  ///
  /// In en, this message translates to:
  /// **'Friend request sent'**
  String get friendRequestSent;

  /// No description provided for @friendRequestAccepted.
  ///
  /// In en, this message translates to:
  /// **'Friend request accepted'**
  String get friendRequestAccepted;

  /// No description provided for @friendRequestDeclined.
  ///
  /// In en, this message translates to:
  /// **'Friend request declined'**
  String get friendRequestDeclined;

  /// No description provided for @waitingForFriend.
  ///
  /// In en, this message translates to:
  /// **'Waiting for friend response'**
  String get waitingForFriend;

  /// No description provided for @friendOffline.
  ///
  /// In en, this message translates to:
  /// **'Friend is offline'**
  String get friendOffline;

  /// No description provided for @friendOnline.
  ///
  /// In en, this message translates to:
  /// **'Friend is online'**
  String get friendOnline;

  /// No description provided for @inviteToGame.
  ///
  /// In en, this message translates to:
  /// **'Invite to game'**
  String get inviteToGame;

  /// No description provided for @gameInvitation.
  ///
  /// In en, this message translates to:
  /// **'Game invitation'**
  String get gameInvitation;

  /// No description provided for @joinGame.
  ///
  /// In en, this message translates to:
  /// **'Join game'**
  String get joinGame;

  /// No description provided for @declineInvitation.
  ///
  /// In en, this message translates to:
  /// **'Decline invitation'**
  String get declineInvitation;

  /// No description provided for @acceptInvitation.
  ///
  /// In en, this message translates to:
  /// **'Accept invitation'**
  String get acceptInvitation;

  /// No description provided for @roomCode.
  ///
  /// In en, this message translates to:
  /// **'Room code'**
  String get roomCode;

  /// No description provided for @createRoom.
  ///
  /// In en, this message translates to:
  /// **'Create room'**
  String get createRoom;

  /// No description provided for @joinRoom.
  ///
  /// In en, this message translates to:
  /// **'Join room'**
  String get joinRoom;

  /// No description provided for @leaveRoom.
  ///
  /// In en, this message translates to:
  /// **'Leave room'**
  String get leaveRoom;

  /// No description provided for @waitingForPlayers.
  ///
  /// In en, this message translates to:
  /// **'Waiting for players'**
  String get waitingForPlayers;

  /// No description provided for @gameStarting.
  ///
  /// In en, this message translates to:
  /// **'Game starting...'**
  String get gameStarting;

  /// No description provided for @gameInProgress.
  ///
  /// In en, this message translates to:
  /// **'Game in progress'**
  String get gameInProgress;

  /// No description provided for @gameFinished.
  ///
  /// In en, this message translates to:
  /// **'Game finished'**
  String get gameFinished;

  /// No description provided for @youWon.
  ///
  /// In en, this message translates to:
  /// **'You won!'**
  String get youWon;

  /// No description provided for @youLost.
  ///
  /// In en, this message translates to:
  /// **'You lost!'**
  String get youLost;

  /// No description provided for @draw.
  ///
  /// In en, this message translates to:
  /// **'It is a draw'**
  String get draw;

  /// No description provided for @correctAnswer.
  ///
  /// In en, this message translates to:
  /// **'Correct answer'**
  String get correctAnswer;

  /// No description provided for @wrongAnswer.
  ///
  /// In en, this message translates to:
  /// **'Wrong answer'**
  String get wrongAnswer;

  /// No description provided for @timeUp.
  ///
  /// In en, this message translates to:
  /// **'Time is up'**
  String get timeUp;

  /// No description provided for @nextQuestion.
  ///
  /// In en, this message translates to:
  /// **'Next question'**
  String get nextQuestion;

  /// No description provided for @finalScore.
  ///
  /// In en, this message translates to:
  /// **'Final score'**
  String get finalScore;

  /// No description provided for @playAgain.
  ///
  /// In en, this message translates to:
  /// **'Play again'**
  String get playAgain;

  /// No description provided for @returnToMenu.
  ///
  /// In en, this message translates to:
  /// **'Return to menu'**
  String get returnToMenu;

  /// No description provided for @question.
  ///
  /// In en, this message translates to:
  /// **'Question'**
  String get question;

  /// No description provided for @loadingQuestions.
  ///
  /// In en, this message translates to:
  /// **'Loading questions...'**
  String get loadingQuestions;

  /// No description provided for @questionsLoaded.
  ///
  /// In en, this message translates to:
  /// **'Questions loaded successfully'**
  String get questionsLoaded;

  /// No description provided for @questionError.
  ///
  /// In en, this message translates to:
  /// **'Error loading questions'**
  String get questionError;

  /// No description provided for @noQuestions.
  ///
  /// In en, this message translates to:
  /// **'No questions available'**
  String get noQuestions;

  /// No description provided for @networkRequired.
  ///
  /// In en, this message translates to:
  /// **'Network connection required'**
  String get networkRequired;

  /// No description provided for @downloadQuestions.
  ///
  /// In en, this message translates to:
  /// **'Download questions'**
  String get downloadQuestions;

  /// No description provided for @cachedQuestions.
  ///
  /// In en, this message translates to:
  /// **'Using cached questions'**
  String get cachedQuestions;

  /// No description provided for @questionCategory.
  ///
  /// In en, this message translates to:
  /// **'Category'**
  String get questionCategory;

  /// No description provided for @questionDifficulty.
  ///
  /// In en, this message translates to:
  /// **'Difficulty'**
  String get questionDifficulty;

  /// No description provided for @eco.
  ///
  /// In en, this message translates to:
  /// **'Eco'**
  String get eco;

  /// No description provided for @sustainability.
  ///
  /// In en, this message translates to:
  /// **'Sustainability'**
  String get sustainability;

  /// No description provided for @recycling.
  ///
  /// In en, this message translates to:
  /// **'Recycling'**
  String get recycling;

  /// No description provided for @energy.
  ///
  /// In en, this message translates to:
  /// **'Energy'**
  String get energy;

  /// No description provided for @transportation.
  ///
  /// In en, this message translates to:
  /// **'Transportation'**
  String get transportation;

  /// No description provided for @water.
  ///
  /// In en, this message translates to:
  /// **'Water'**
  String get water;

  /// No description provided for @forest.
  ///
  /// In en, this message translates to:
  /// **'Forest'**
  String get forest;

  /// No description provided for @waste.
  ///
  /// In en, this message translates to:
  /// **'Waste'**
  String get waste;

  /// No description provided for @climate.
  ///
  /// In en, this message translates to:
  /// **'Climate'**
  String get climate;

  /// No description provided for @carbon.
  ///
  /// In en, this message translates to:
  /// **'Carbon'**
  String get carbon;

  /// No description provided for @pollution.
  ///
  /// In en, this message translates to:
  /// **'Pollution'**
  String get pollution;

  /// No description provided for @conservation.
  ///
  /// In en, this message translates to:
  /// **'Conservation'**
  String get conservation;

  /// No description provided for @renewable.
  ///
  /// In en, this message translates to:
  /// **'Renewable'**
  String get renewable;

  /// No description provided for @green.
  ///
  /// In en, this message translates to:
  /// **'Green'**
  String get green;

  /// No description provided for @nature.
  ///
  /// In en, this message translates to:
  /// **'Nature'**
  String get nature;

  /// No description provided for @environment.
  ///
  /// In en, this message translates to:
  /// **'Environment'**
  String get environment;

  /// No description provided for @earth.
  ///
  /// In en, this message translates to:
  /// **'Earth'**
  String get earth;

  /// No description provided for @science.
  ///
  /// In en, this message translates to:
  /// **'Science'**
  String get science;

  /// No description provided for @technology.
  ///
  /// In en, this message translates to:
  /// **'Technology'**
  String get technology;

  /// No description provided for @innovation.
  ///
  /// In en, this message translates to:
  /// **'Innovation'**
  String get innovation;

  /// No description provided for @developerTools.
  ///
  /// In en, this message translates to:
  /// **'Developer Tools'**
  String get developerTools;

  /// No description provided for @debugAndTestTools.
  ///
  /// In en, this message translates to:
  /// **'Debug and test tools'**
  String get debugAndTestTools;

  /// No description provided for @accessibilitySettings.
  ///
  /// In en, this message translates to:
  /// **'Accessibility Settings'**
  String get accessibilitySettings;

  /// No description provided for @highContrastMode.
  ///
  /// In en, this message translates to:
  /// **'High Contrast'**
  String get highContrastMode;

  /// No description provided for @textScaling.
  ///
  /// In en, this message translates to:
  /// **'Text Scaling'**
  String get textScaling;

  /// No description provided for @touchTargets.
  ///
  /// In en, this message translates to:
  /// **'Touch Targets'**
  String get touchTargets;

  /// No description provided for @followSystemSettings.
  ///
  /// In en, this message translates to:
  /// **'Follow system settings'**
  String get followSystemSettings;

  /// No description provided for @activeWCAGCompliant.
  ///
  /// In en, this message translates to:
  /// **'Active - WCAG AA compliant colors'**
  String get activeWCAGCompliant;

  /// No description provided for @inactiveStandardColors.
  ///
  /// In en, this message translates to:
  /// **'Inactive - Standard colors'**
  String get inactiveStandardColors;

  /// No description provided for @minTouchArea.
  ///
  /// In en, this message translates to:
  /// **'48dp minimum touch area'**
  String get minTouchArea;

  /// No description provided for @notificationSettings.
  ///
  /// In en, this message translates to:
  /// **'Notification Settings'**
  String get notificationSettings;

  /// No description provided for @gameStartNotifications.
  ///
  /// In en, this message translates to:
  /// **'Game start'**
  String get gameStartNotifications;

  /// No description provided for @turnNotifications.
  ///
  /// In en, this message translates to:
  /// **'Turn notifications'**
  String get turnNotifications;

  /// No description provided for @friendRequests.
  ///
  /// In en, this message translates to:
  /// **'Friend requests'**
  String get friendRequests;

  /// No description provided for @dailyReminders.
  ///
  /// In en, this message translates to:
  /// **'Daily reminders'**
  String get dailyReminders;

  /// No description provided for @securitySettings.
  ///
  /// In en, this message translates to:
  /// **'Security Settings'**
  String get securitySettings;

  /// No description provided for @twoFactorAuthTitle.
  ///
  /// In en, this message translates to:
  /// **'Two-Factor Authentication'**
  String get twoFactorAuthTitle;

  /// No description provided for @addSecurityLayer.
  ///
  /// In en, this message translates to:
  /// **'Add an extra layer of security to your account'**
  String get addSecurityLayer;

  /// No description provided for @securityTips.
  ///
  /// In en, this message translates to:
  /// **'Security tips:'**
  String get securityTips;

  /// No description provided for @useStrongPasswords.
  ///
  /// In en, this message translates to:
  /// **'Use strong passwords'**
  String get useStrongPasswords;

  /// No description provided for @updatePasswordRegularly.
  ///
  /// In en, this message translates to:
  /// **'Update your password regularly'**
  String get updatePasswordRegularly;

  /// No description provided for @enableTwoFactor.
  ///
  /// In en, this message translates to:
  /// **'Enable two-factor authentication'**
  String get enableTwoFactor;

  /// No description provided for @reportSuspiciousActivity.
  ///
  /// In en, this message translates to:
  /// **'Report suspicious activity'**
  String get reportSuspiciousActivity;

  /// No description provided for @primaryColor.
  ///
  /// In en, this message translates to:
  /// **'Primary Color'**
  String get primaryColor;

  /// No description provided for @secondaryColor.
  ///
  /// In en, this message translates to:
  /// **'Secondary Color'**
  String get secondaryColor;

  /// No description provided for @surfaceColor.
  ///
  /// In en, this message translates to:
  /// **'Surface Color'**
  String get surfaceColor;
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
      <String>['en', 'tr'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en':
      return AppLocalizationsEn();
    case 'tr':
      return AppLocalizationsTr();
  }

  throw FlutterError(
      'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
      'an issue with the localizations generation tool. Please file an issue '
      'on GitHub with a reproducible sample app and the gen-l10n configuration '
      'that was used.');
}
