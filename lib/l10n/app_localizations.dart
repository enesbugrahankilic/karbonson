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

  /// No description provided for @quickMenu.
  ///
  /// In en, this message translates to:
  /// **'Quick Menu'**
  String get quickMenu;

  /// No description provided for @quickMenuDescription.
  ///
  /// In en, this message translates to:
  /// **'Access all features quickly'**
  String get quickMenuDescription;

  /// No description provided for @gameModes.
  ///
  /// In en, this message translates to:
  /// **'Game Modes'**
  String get gameModes;

  /// No description provided for @social.
  ///
  /// In en, this message translates to:
  /// **'Social'**
  String get social;

  /// No description provided for @tools.
  ///
  /// In en, this message translates to:
  /// **'Tools'**
  String get tools;

  /// No description provided for @boardGame.
  ///
  /// In en, this message translates to:
  /// **'Board Game'**
  String get boardGame;

  /// No description provided for @multiplayerLobby.
  ///
  /// In en, this message translates to:
  /// **'Multiplayer'**
  String get multiplayerLobby;

  /// No description provided for @rewardsShop.
  ///
  /// In en, this message translates to:
  /// **'Rewards Shop'**
  String get rewardsShop;

  /// No description provided for @aiRecommendations.
  ///
  /// In en, this message translates to:
  /// **'AI Recommendations'**
  String get aiRecommendations;

  /// No description provided for @howToPlay.
  ///
  /// In en, this message translates to:
  /// **'How to Play'**
  String get howToPlay;

  /// No description provided for @profile.
  ///
  /// In en, this message translates to:
  /// **'Profile'**
  String get profile;

  /// No description provided for @statistics.
  ///
  /// In en, this message translates to:
  /// **'Statistics'**
  String get statistics;

  /// No description provided for @quickDuel.
  ///
  /// In en, this message translates to:
  /// **'Quick Duel'**
  String get quickDuel;

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

  /// No description provided for @activeRooms.
  ///
  /// In en, this message translates to:
  /// **'Active Rooms'**
  String get activeRooms;

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

  /// No description provided for @streak.
  ///
  /// In en, this message translates to:
  /// **'Streak'**
  String get streak;

  /// No description provided for @newFeature.
  ///
  /// In en, this message translates to:
  /// **'NEW'**
  String get newFeature;

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

  // Home Dashboard Strings
  /// No description provided for @welcomeBack.
  ///
  /// In en, this message translates to:
  /// **'Welcome Back'**
  String get welcomeBack;

  /// No description provided for @helloEmoji.
  ///
  /// In en, this message translates to:
  /// **'Hello 👋'**
  String get helloEmoji;

  /// No description provided for @loadingData.
  ///
  /// In en, this message translates to:
  /// **'Loading data...'**
  String get loadingData;

  /// No description provided for @totalPoints.
  ///
  /// In en, this message translates to:
  /// **'Total Points'**
  String get totalPoints;

  /// No description provided for @achievementCount.
  ///
  /// In en, this message translates to:
  /// **'Achievement Count'**
  String get achievementCount;

  /// No description provided for @quickAccess.
  ///
  /// In en, this message translates to:
  /// **'Quick Access'**
  String get quickAccess;

  /// No description provided for @progressAndAchievements.
  ///
  /// In en, this message translates to:
  /// **'Progress & Achievements'**
  String get progressAndAchievements;

  /// No description provided for @startQuiz.
  ///
  /// In en, this message translates to:
  /// **'Start Quiz'**
  String get startQuiz;

  /// No description provided for @duelMode.
  ///
  /// In en, this message translates to:
  /// **'Duel Mode'**
  String get duelMode;

  /// No description provided for @teamPlay.
  ///
  /// In en, this message translates to:
  /// **'Team Play'**
  String get teamPlay;

  /// No description provided for @dailyChallenges.
  ///
  /// In en, this message translates to:
  /// **'Daily Challenges'**
  String get dailyChallenges;

  /// No description provided for @statisticsSummary.
  ///
  /// In en, this message translates to:
  /// **'Statistics Summary'**
  String get statisticsSummary;

  /// No description provided for @recentActivity.
  ///
  /// In en, this message translates to:
  /// **'Recent Activities'**
  String get recentActivity;

  /// No description provided for @play.
  ///
  /// In en, this message translates to:
  /// **'Play'**
  String get play;

  /// No description provided for @start.
  ///
  /// In en, this message translates to:
  /// **'Start'**
  String get start;

  /// No description provided for @create.
  ///
  /// In en, this message translates to:
  /// **'Create'**
  String get create;

  /// No description provided for @join.
  ///
  /// In en, this message translates to:
  /// **'Join'**
  String get join;

  /// No description provided for @badges.
  ///
  /// In en, this message translates to:
  /// **'Badges'**
  String get badges;

  /// No description provided for @homePageTitle.
  ///
  /// In en, this message translates to:
  /// **'Home'**
  String get homePageTitle;

  /// No description provided for @quickAccessTitle.
  ///
  /// In en, this message translates to:
  /// **'Quick Access'**
  String get quickAccessTitle;

  /// No description provided for @quizInfoTitle.
  ///
  /// In en, this message translates to:
  /// **'Start Quick Quiz'**
  String get quizInfoTitle;

  /// No description provided for @ecoQuizTitle.
  ///
  /// In en, this message translates to:
  /// **'Eco Knowledge Quiz'**
  String get ecoQuizTitle;

  /// No description provided for @startQuizAction.
  ///
  /// In en, this message translates to:
  /// **'Start Now'**
  String get startQuizAction;

  /// No description provided for @increaseAwareness.
  ///
  /// In en, this message translates to:
  /// **'Increase eco awareness, earn points!'**
  String get increaseAwareness;

  /// No description provided for @quickAccessSettings.
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get quickAccessSettings;

  /// No description provided for @quickAccessProfile.
  ///
  /// In en, this message translates to:
  /// **'Profile'**
  String get quickAccessProfile;

  /// No description provided for @noActivities.
  ///
  /// In en, this message translates to:
  /// **'No activities yet'**
  String get noActivities;

  /// No description provided for @activityHint.
  ///
  /// In en, this message translates to:
  /// **'See your activities'**
  String get activityHint;

  /// No description provided for @daysAgo.
  ///
  /// In en, this message translates to:
  /// **'days ago'**
  String get daysAgo;

  /// No description provided for @hoursAgo.
  ///
  /// In en, this message translates to:
  /// **'hours ago'**
  String get hoursAgo;

  /// No description provided for @minutesAgo.
  ///
  /// In en, this message translates to:
  /// **'minutes ago'**
  String get minutesAgo;

  /// No description provided for @justNow.
  ///
  /// In en, this message translates to:
  /// **'Just now'**
  String get justNow;

  /// No description provided for @levelProgress.
  ///
  /// In en, this message translates to:
  /// **'Level Progress'**
  String get levelProgress;

  /// No description provided for @quizStatistics.
  ///
  /// In en, this message translates to:
  /// **'Quiz Statistics'**
  String get quizStatistics;

  /// No description provided for @totalQuizzes.
  ///
  /// In en, this message translates to:
  /// **'Total Quizzes'**
  String get totalQuizzes;

  /// No description provided for @correctRate.
  ///
  /// In en, this message translates to:
  /// **'Correct Rate'**
  String get correctRate;

  /// No description provided for @averageTime.
  ///
  /// In en, this message translates to:
  /// **'Avg. Time'**
  String get averageTime;

  /// No description provided for @recentAchievements.
  ///
  /// In en, this message translates to:
  /// **'Recent Achievements'**
  String get recentAchievements;

  /// No description provided for @noAchievements.
  ///
  /// In en, this message translates to:
  /// **'No achievements yet'**
  String get noAchievements;

  /// No description provided for @achievementsHint.
  ///
  /// In en, this message translates to:
  /// **'Earn achievements by taking quizzes!'**
  String get achievementsHint;

  /// No description provided for @totalTime.
  ///
  /// In en, this message translates to:
  /// **'Total Time'**
  String get totalTime;

  /// No description provided for @longestStreak.
  ///
  /// In en, this message translates to:
  /// **'Longest Streak'**
  String get longestStreak;

  /// No description provided for @loginStreak.
  ///
  /// In en, this message translates to:
  /// **'Login Streak'**
  String get loginStreak;

  /// No description provided for @highestScore.
  ///
  /// In en, this message translates to:
  /// **'Highest Score'**
  String get highestScore;

  /// No description provided for @quizScore.
  ///
  /// In en, this message translates to:
  /// **'Quiz score'**
  String get quizScore;

  /// No description provided for @duelWinRate.
  ///
  /// In en, this message translates to:
  /// **'Duel Win Rate'**
  String get duelWinRate;

  /// No description provided for @totalDuels.
  ///
  /// In en, this message translates to:
  /// **'duels'**
  String get totalDuels;

  /// No description provided for @weeklyActivity.
  ///
  /// In en, this message translates to:
  /// **'Weekly Activity'**
  String get weeklyActivity;

  /// No description provided for @noDailyChallenges.
  ///
  /// In en, this message translates to:
  /// **'No challenges for today'**
  String get noDailyChallenges;

  /// No description provided for @newChallengesTomorrow.
  ///
  /// In en, this message translates to:
  /// **'New challenges tomorrow!'**
  String get newChallengesTomorrow;

  /// No description provided for @challengeReward.
  ///
  /// In en, this message translates to:
  /// **'Reward:'**
  String get challengeReward;

  /// No description provided for @challengePoints.
  ///
  /// In en, this message translates to:
  /// **'Points'**
  String get challengePoints;

  // Quiz Page Strings
  /// No description provided for @quizSettings.
  ///
  /// In en, this message translates to:
  /// **'Quiz Settings'**
  String get quizSettings;

  /// No description provided for @selectCategory.
  ///
  /// In en, this message translates to:
  /// **'Select Category:'**
  String get selectCategory;

  /// No description provided for @selectDifficulty.
  ///
  /// In en, this message translates to:
  /// **'Select Difficulty Level:'**
  String get selectDifficulty;

  /// No description provided for @selectQuestionCount.
  ///
  /// In en, this message translates to:
  /// **'Select Question Count:'**
  String get selectQuestionCount;

  /// No description provided for @questionCount.
  ///
  /// In en, this message translates to:
  /// **'Question Count'**
  String get questionCount;

  /// No description provided for @fiveQuestions.
  ///
  /// In en, this message translates to:
  /// **'5 Questions (2-3 minutes)'**
  String get fiveQuestions;

  /// No description provided for @tenQuestions.
  ///
  /// In en, this message translates to:
  /// **'10 Questions (~5 minutes)'**
  String get tenQuestions;

  /// No description provided for @fifteenQuestions.
  ///
  /// In en, this message translates to:
  /// **'15 Questions (~7-8 minutes)'**
  String get fifteenQuestions;

  /// No description provided for @twentyQuestions.
  ///
  /// In en, this message translates to:
  /// **'20 Questions (~10-12 minutes)'**
  String get twentyQuestions;

  /// No description provided for @twentyFiveQuestions.
  ///
  /// In en, this message translates to:
  /// **'25 Questions (~12-15 minutes)'**
  String get twentyFiveQuestions;

  /// No description provided for @pleaseSelectCategory.
  ///
  /// In en, this message translates to:
  /// **'Please select a category'**
  String get pleaseSelectCategory;

  /// No description provided for @begin.
  ///
  /// In en, this message translates to:
  /// **'Begin'**
  String get begin;

  /// No description provided for @quizExit.
  ///
  /// In en, this message translates to:
  /// **'Exit Quiz'**
  String get quizExit;

  /// No description provided for @exitWarning.
  ///
  /// In en, this message translates to:
  /// **'If you exit the quiz, your progress will not be saved.'**
  String get exitWarning;

  /// No description provided for @continueQuestion.
  ///
  /// In en, this message translates to:
  /// **'Do you want to continue?'**
  String get continueQuestion;

  /// No description provided for @yesExit.
  ///
  /// In en, this message translates to:
  /// **'Yes, Exit'**
  String get yesExit;

  /// No description provided for @questionNumber.
  ///
  /// In en, this message translates to:
  /// **'Question'**
  String get questionNumber;

  /// No description provided for @quizCompletedTitle.
  ///
  /// In en, this message translates to:
  /// **'Quiz Completed'**
  String get quizCompletedTitle;

  /// No description provided for @totalScore.
  ///
  /// In en, this message translates to:
  /// **'Total Score'**
  String get totalScore;

  /// No description provided for @backToHome.
  ///
  /// In en, this message translates to:
  /// **'Back to Home'**
  String get backToHome;

  /// No description provided for @errorLoading.
  ///
  /// In en, this message translates to:
  /// **'Error: '**
  String get errorLoading;

  /// No description provided for @questionOf.
  ///
  /// In en, this message translates to:
  /// **'Question {current}/{total}'**
  String get questionOf;

  // Duel Page Strings
  /// No description provided for @duelModeTitle.
  ///
  /// In en, this message translates to:
  /// **'Duel Mode'**
  String get duelModeTitle;

  /// No description provided for @roomCreated.
  ///
  /// In en, this message translates to:
  /// **'Room created! Room Code: '**
  String get roomCreated;

  /// No description provided for @roomCodeCopied.
  ///
  /// In en, this message translates to:
  /// **'Room code copied!'**
  String get roomCodeCopied;

  /// No description provided for @enterRoomCode.
  ///
  /// In en, this message translates to:
  /// **'Room Code'**
  String get enterRoomCode;

  /// No description provided for @inviteFriends.
  ///
  /// In en, this message translates to:
  /// **'Invite Friends'**
  String get inviteFriends;

  /// No description provided for @twoPlayersRequired.
  ///
  /// In en, this message translates to:
  /// **'2 players required'**
  String get twoPlayersRequired;

  /// No description provided for @fiveQuestionsPrompt.
  ///
  /// In en, this message translates to:
  /// **'5 questions will be asked'**
  String get fiveQuestionsPrompt;

  /// No description provided for @mostCorrectWins.
  ///
  /// In en, this message translates to:
  /// **'Most correct answers win'**
  String get mostCorrectWins;

  /// No description provided for @speedBonus.
  ///
  /// In en, this message translates to:
  /// **'Earn points with speed bonus'**
  String get speedBonus;

  /// No description provided for @timeLimit.
  ///
  /// In en, this message translates to:
  /// **'15 second time limit'**
  String get timeLimit;

  /// No description provided for @duelOptions.
  ///
  /// In en, this message translates to:
  /// **'Duel Options'**
  String get duelOptions;

  /// No description provided for @chooseDuelType.
  ///
  /// In en, this message translates to:
  /// **'Which duel type do you prefer?'**
  String get chooseDuelType;

  /// No description provided for @quickDuelDesc.
  ///
  /// In en, this message translates to:
  /// **'5 questions, 15 seconds time'**
  String get quickDuelDesc;

  /// No description provided for @roomDuelDesc.
  ///
  /// In en, this message translates to:
  /// **'Play with friend in permanent room'**
  String get roomDuelDesc;

  /// No description provided for @yourAnswer.
  ///
  /// In en, this message translates to:
  /// **'Your Answer'**
  String get yourAnswer;

  /// No description provided for @send.
  ///
  /// In en, this message translates to:
  /// **'Send'**
  String get send;

  /// No description provided for @scoreboard.
  ///
  /// In en, this message translates to:
  /// **'Scoreboard'**
  String get scoreboard;

  /// No description provided for @pointsValue.
  ///
  /// In en, this message translates to:
  /// **'points'**
  String get pointsValue;

  /// No description provided for @roomJoinFeature.
  ///
  /// In en, this message translates to:
  /// **'Room join feature under development...'**
  String get roomJoinFeature;

  /// No description provided for @quizLoading.
  ///
  /// In en, this message translates to:
  /// **'Quiz is loading...'**
  String get quizLoading;

  /// No description provided for @roomDuel.
  ///
  /// In en, this message translates to:
  /// **'Room Duel'**
  String get roomDuel;

  /// No description provided for @permanentRoom.
  ///
  /// In en, this message translates to:
  /// **'Permanent room'**
  String get permanentRoom;

  /// No description provided for @playWithFriend.
  ///
  /// In en, this message translates to:
  /// **'Play with friend'**
  String get playWithFriend;

  /// No description provided for @secondsTime.
  ///
  /// In en, this message translates to:
  /// **'seconds time'**
  String get secondsTime;

  /// No description provided for @questions.
  ///
  /// In en, this message translates to:
  /// **'questions'**
  String get questions;

  // Quick Menu Strings
  /// No description provided for @featuresCount.
  ///
  /// In en, this message translates to:
  /// **'features to explore'**
  String get featuresCount;

  /// No description provided for @boardGameSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Strategy based'**
  String get boardGameSubtitle;

  /// No description provided for @multiplayerSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Up to 4 players'**
  String get multiplayerSubtitle;

  /// No description provided for @friendsSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Add and see friends'**
  String get friendsSubtitle;

  /// No description provided for @leaderboardSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Top players'**
  String get leaderboardSubtitle;

  /// No description provided for @dailySubtitle.
  ///
  /// In en, this message translates to:
  /// **'Today's challenges'**
  String get dailySubtitle;

  /// No description provided for @achievementsSubtitle.
  ///
  /// In en, this message translates to:
  /// **'See your badges'**
  String get achievementsSubtitle;

  /// No description provided for @rewardsSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Gifts for you'**
  String get rewardsSubtitle;

  /// No description provided for @aiSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Personalized'**
  String get aiSubtitle;

  /// No description provided for @howToPlaySubtitle.
  ///
  /// In en, this message translates to:
  /// **'Rules and tips'**
  String get howToPlaySubtitle;

  /// No description provided for @settingsSubtitle.
  ///
  /// In en, this message translates to:
  /// **'App settings'**
  String get settingsSubtitle;

  /// No description provided for @profileSubtitle.
  ///
  /// In en, this message translates to:
  /// **'User info'**
  String get profileSubtitle;

  /// No description provided for @featured.
  ///
  /// In en, this message translates to:
  /// **'FEATURED'**
  String get featured;

  /// No description provided for @gameModesCategory.
  ///
  /// In en, this message translates to:
  /// **'Game Modes'**
  String get gameModesCategory;

  /// No description provided for @socialCategory.
  ///
  /// In en, this message translates to:
  /// **'Social'**
  String get socialCategory;

  /// No description provided for @toolsCategory.
  ///
  /// In en, this message translates to:
  /// **'Tools'**
  String get toolsCategory;

  /// No description provided for @statsDays.
  ///
  /// In en, this message translates to:
  /// **'Days'**
  String get statsDays;

  // Theme descriptions
  /// No description provided for @allTopics.
  ///
  /// In en, this message translates to:
  /// **'All Topics'**
  String get allTopics;

  /// No description provided for @allDescription.
  ///
  /// In en, this message translates to:
  /// **'Mixed questions from all eco topics'**
  String get allDescription;

  /// No description provided for @energyDescription.
  ///
  /// In en, this message translates to:
  /// **'Energy conservation and sustainable energy'**
  String get energyDescription;

  /// No description provided for @waterDescription.
  ///
  /// In en, this message translates to:
  /// **'Water conservation and water resources management'**
  String get waterDescription;

  /// No description provided for @forestDescription.
  ///
  /// In en, this message translates to:
  /// **'Forest protection and afforestation'**
  String get forestDescription;

  /// No description provided for @recyclingDescription.
  ///
  /// In en, this message translates to:
  /// **'Waste management and recycling'**
  String get recyclingDescription;

  /// No description provided for @transportationDescription.
  ///
  /// In en, this message translates to:
  /// **'Eco-friendly transportation'**
  String get transportationDescription;

  /// No description provided for @consumptionDescription.
  ///
  /// In en, this message translates to:
  /// **'Sustainable consumption'**
  String get consumptionDescription;

  /// No description provided for @rememberTheme.
  ///
  /// In en, this message translates to:
  /// **'Remember this theme'**
  String get rememberTheme;

  /// No description provided for @themeDescription.
  ///
  /// In en, this message translates to:
  /// **'Theme Description'**
  String get themeDescription;

  // Help & Info
  /// No description provided for @helpInfo.
  ///
  /// In en, this message translates to:
  /// **'Help & Info'**
  String get helpInfo;

  /// No description provided for @aboutApp.
  ///
  /// In en, this message translates to:
  /// **'About App'**
  String get aboutApp;

  /// No description provided for @appDescription.
  ///
  /// In en, this message translates to:
  /// **'Eco Game is a fun quiz app designed to increase environmental awareness. Test your knowledge on energy, water, forest, recycling and more!'**
  String get appDescription;

  /// No description provided for @quizMode.
  ///
  /// In en, this message translates to:
  /// **'Quiz Mode'**
  String get quizMode;

  /// No description provided for @duelModeInfo.
  ///
  /// In en, this message translates to:
  /// **'Duel Mode'**
  String get duelModeInfo;

  /// No description provided for @teamGame.
  ///
  /// In en, this message translates to:
  /// **'Team Game'**
  String get teamGame;

  /// No description provided for @achievementsBadges.
  ///
  /// In en, this message translates to:
  /// **'Achievements & Badges'**
  String get achievementsBadges;

  /// No description provided for @understood.
  ///
  /// In en, this message translates to:
  /// **'Understood'**
  String get understood;

  /// No description provided for @supportEmail.
  ///
  /// In en, this message translates to:
  /// **'Support:'**
  String get supportEmail;

  // Additional
  /// No description provided for @quickQuiz.
  ///
  /// In en, this message translates to:
  /// **'Quick Quiz'**
  String get quickQuiz;

  /// No description provided for @user.
  ///
  /// In en, this message translates to:
  /// **'User'**
  String get user;
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
