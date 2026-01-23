#!/bin/bash
# Comprehensive script to fix all remaining Flutter build errors

set -e

echo "Starting comprehensive error fix..."

# Fix 1: Missing closing braces in constructor declarations
echo "Fixing missing braces in constructor declarations..."
find lib/pages -name "*.dart" -type f -exec sed -i '' 's/({super\.key);/({super.key});/g' {} \;
find lib/widgets -name "*.dart" -type f -exec sed -i '' 's/({super\.key);/({super.key});/g' {} \;
find lib -name "*.dart" -type f -exec sed -i '' 's/({super\.key);/({super.key});/g' {} \;

# Fix 2: Remove const from non-const constructors in app_router.dart
echo "Fixing const constructors in app_router.dart..."
sed -i '' 's/const LoginPage()/LoginPage()/g' lib/core/navigation/app_router.dart
sed -i '' 's/const TutorialPage()/TutorialPage()/g' lib/core/navigation/app_router.dart
sed -i '' 's/const RegisterPage()/RegisterPage()/g' lib/core/navigation/app_router.dart
sed -i '' 's/const RegisterPageRefactored()/RegisterPageRefactored()/g' lib/core/navigation/app_router.dart
sed -i '' 's/const EmailVerificationPage()/EmailVerificationPage()/g' lib/core/navigation/app_router.dart
sed -i '' 's/const ForgotPasswordPage()/ForgotPasswordPage()/g' lib/core/navigation/app_router.dart
sed -i '' 's/const ForgotPasswordPageEnhanced()/ForgotPasswordPageEnhanced()/g' lib/core/navigation/app_router.dart
sed -i '' 's/const TwoFactorAuthSetupPage()/TwoFactorAuthSetupPage()/g' lib/core/navigation/app_router.dart
sed -i '' 's/const EnhancedTwoFactorAuthSetupPage()/EnhancedTwoFactorAuthSetupPage()/g' lib/core/navigation/app_router.dart
sed -i '' 's/const ComprehensiveTwoFactorAuthSetupPage()/ComprehensiveTwoFactorAuthSetupPage()/g' lib/core/navigation/app_router.dart
sed -i '' 's/const HomeDashboard()/HomeDashboard()/g' lib/core/navigation/app_router.dart
sed -i '' 's/const ProfilePage()/ProfilePage()/g' lib/core/navigation/app_router.dart
sed -i '' 's/const LeaderboardPage()/LeaderboardPage()/g' lib/core/navigation/app_router.dart
sed -i '' 's/const DuelInvitationPage()/DuelInvitationPage()/g' lib/core/navigation/app_router.dart
sed -i '' 's/const SettingsPage()/SettingsPage()/g' lib/core/navigation/app_router.dart
sed -i '' 's/const AIRecommendationsPage()/AIRecommendationsPage()/g' lib/core/navigation/app_router.dart
sed -i '' 's/const AchievementPage()/AchievementPage()/g' lib/core/navigation/app_router.dart
sed -i '' 's/const DailyChallengePage()/DailyChallengePage()/g' lib/core/navigation/app_router.dart
sed -i '' 's/const AchievementsGalleryPage()/AchievementsGalleryPage()/g' lib/core/navigation/app_router.dart
sed -i '' 's/const RewardsMainPage()/RewardsMainPage()/g' lib/core/navigation/app_router.dart
sed -i '' 's/const RewardsShopPage()/RewardsShopPage()/g' lib/core/navigation/app_router.dart
sed -i '' 's/const WonBoxesPage()/WonBoxesPage()/g' lib/core/navigation/app_router.dart
sed -i '' 's/const NotificationsPage()/NotificationsPage()/g' lib/core/navigation/app_router.dart
sed -i '' 's/const HowToPlayPage()/HowToPlayPage()/g' lib/core/navigation/app_router.dart
sed -i '' 's/const EmailVerificationRedirectPage()/EmailVerificationRedirectPage()/g' lib/core/navigation/app_router.dart
sed -i '' 's/const SpectatorModePage()/SpectatorModePage()/g' lib/core/navigation/app_router.dart

# Fix 3: Remove const from other files
echo "Fixing const constructors in other files..."
sed -i '' 's/const GuestHomePage()/GuestHomePage()/g' lib/pages/welcome_page.dart
sed -i '' 's/const ProfilePage()/ProfilePage()/g' lib/pages/welcome_page.dart
sed -i '' 's/const RegisterPage()/RegisterPage()/g' lib/pages/login_page.dart
sed -i '' 's/const LanguageSelectorButton()/LanguageSelectorButton()/g' lib/pages/register_page.dart
sed -i '' 's/const ProfilePage()/ProfilePage()/g' lib/pages/register_page.dart
sed -i '' 's/const ProfilePage()/ProfilePage()/g' lib/pages/register_page_refactored.dart
sed -i '' 's/const LoginPage()/LoginPage()/g' lib/pages/register_page_refactored.dart
sed -i '' 's/const TwoFactorAuthSetupPage()/TwoFactorAuthSetupPage()/g' lib/pages/settings_page.dart
sed -i '' 's/const GameInvitationList()/GameInvitationList()/g' lib/pages/room_management_page.dart
sed -i '' 's/const SpectatorModePage()/SpectatorModePage()/g' lib/pages/multiplayer_lobby_page.dart
sed -i '' 's/const ProfileContent()/ProfileContent()/g' lib/pages/profile_page.dart

# Fix 4: Fix app_router.dart extra const issues
sed -i '' 's/return _createRoute(const LoginPage()/return _createRoute(LoginPage()/g' lib/core/navigation/app_router.dart
sed -i '' 's/return _createProtectedRoute(const ProfilePage/return _createProtectedRoute(ProfilePage/g' lib/core/navigation/app_router.dart

echo "All fixes applied!"
echo "Now run: flutter pub get && flutter build apk"

