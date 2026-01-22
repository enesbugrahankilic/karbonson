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

  /// No description provided for @hello.
  ///
  /// In en, this message translates to:
  /// **'Hello'**
  String get hello;

  /// No description provided for @world.
  ///
  /// In en, this message translates to:
  /// **'World'**
  String get world;

  /// No description provided for @notifications.
  ///
  /// In en, this message translates to:
  /// **'Notifications'**
  String get notifications;

  /// No description provided for @noNotifications.
  ///
  /// In en, this message translates to:
  /// **'No notifications yet'**
  String get noNotifications;

  /// No description provided for @notificationSettings.
  ///
  /// In en, this message translates to:
  /// **'Notification Settings'**
  String get notificationSettings;

  /// No description provided for @markAllAsRead.
  ///
  /// In en, this message translates to:
  /// **'Mark All as Read'**
  String get markAllAsRead;

  /// No description provided for @unreadNotifications.
  ///
  /// In en, this message translates to:
  /// **'Unread Notifications'**
  String get unreadNotifications;

  /// No description provided for @allNotifications.
  ///
  /// In en, this message translates to:
  /// **'All Notifications'**
  String get allNotifications;

  /// No description provided for @friendRequest.
  ///
  /// In en, this message translates to:
  /// **'Friend Request'**
  String get friendRequest;

  /// No description provided for @friendRequestAccepted.
  ///
  /// In en, this message translates to:
  /// **'Friend Request Accepted'**
  String get friendRequestAccepted;

  /// No description provided for @friendRequestRejected.
  ///
  /// In en, this message translates to:
  /// **'Friend Request Rejected'**
  String get friendRequestRejected;

  /// No description provided for @gameInvitation.
  ///
  /// In en, this message translates to:
  /// **'Game Invitation'**
  String get gameInvitation;

  /// No description provided for @duelInvitation.
  ///
  /// In en, this message translates to:
  /// **'Duel Invitation'**
  String get duelInvitation;

  /// No description provided for @viewNotifications.
  ///
  /// In en, this message translates to:
  /// **'View Notifications'**
  String get viewNotifications;

  /// No description provided for @notificationDescription.
  ///
  /// In en, this message translates to:
  /// **'You have {count} unread notifications'**
  String notificationDescription(Object count);

  /// No description provided for @noNotificationsDescription.
  ///
  /// In en, this message translates to:
  /// **'Your notifications will appear here when you receive them'**
  String get noNotificationsDescription;

  /// No description provided for @justNow.
  ///
  /// In en, this message translates to:
  /// **'Just now'**
  String get justNow;

  /// No description provided for @minutesAgo.
  ///
  /// In en, this message translates to:
  /// **'minutes ago'**
  String minutesAgo(Object count);

  /// No description provided for @hoursAgo.
  ///
  /// In en, this message translates to:
  /// **'hours ago'**
  String hoursAgo(Object count);

  /// No description provided for @daysAgo.
  ///
  /// In en, this message translates to:
  /// **'days ago'**
  String daysAgo(Object count);

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

  /// No description provided for @loading.
  ///
  /// In en, this message translates to:
  /// **'Loading...'**
  String get loading;

  /// No description provided for @startupError.
  ///
  /// In en, this message translates to:
  /// **'Startup Error'**
  String get startupError;

  /// No description provided for @startupErrorDescription.
  ///
  /// In en, this message translates to:
  /// **'An error occurred during startup. Please try again.'**
  String get startupErrorDescription;

  /// No description provided for @retry.
  ///
  /// In en, this message translates to:
  /// **'Retry'**
  String get retry;

  /// No description provided for @appNameHighContrast.
  ///
  /// In en, this message translates to:
  /// **'KarbonSon'**
  String get appNameHighContrast;

  /// No description provided for @appName.
  ///
  /// In en, this message translates to:
  /// **'KarbonSon'**
  String get appName;

  /// No description provided for @settings.
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get settings;

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

  /// No description provided for @language.
  ///
  /// In en, this message translates to:
  /// **'Language'**
  String get language;

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

  /// No description provided for @twoFactorAuth.
  ///
  /// In en, this message translates to:
  /// **'Two-Factor Authentication'**
  String get twoFactorAuth;

  /// No description provided for @close.
  ///
  /// In en, this message translates to:
  /// **'Close'**
  String get close;

  /// No description provided for @cancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get cancel;
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
