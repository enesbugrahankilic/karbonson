// lib/widgets/global_error_states.dart
// Global error and empty state screens for the entire application

import 'package:flutter/material.dart';
import '../theme/design_system.dart';
import '../theme/theme_colors.dart';

/// Global error and empty state screens that can be used across the application
class GlobalErrorStates {
  // ===========================================================================
  // ERROR SCREENS
  // ===========================================================================

  /// Generic error screen with retry functionality
  static Widget errorScreen({
    required BuildContext context,
    required String title,
    required String message,
    VoidCallback? onRetry,
    String? retryText,
    IconData? icon,
    Color? iconColor,
  }) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(DesignSystem.spacingL),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Error Icon
            Icon(
              icon ?? Icons.error_outline,
              size: 80,
              color: iconColor ?? ThemeColors.getErrorColor(context),
            ),
            const SizedBox(height: DesignSystem.spacingL),

            // Title
            Text(
              title,
              style: DesignSystem.getHeadlineSmall(context).copyWith(
                color: ThemeColors.getErrorColor(context),
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: DesignSystem.spacingM),

            // Message
            Text(
              message,
              style: DesignSystem.getBodyLarge(context).copyWith(
                color: ThemeColors.getSecondaryText(context),
              ),
              textAlign: TextAlign.center,
            ),

            // Retry Button
            if (onRetry != null) ...[
              const SizedBox(height: DesignSystem.spacingXl),
              DesignSystem.card(
                context,
                child: ElevatedButton.icon(
                  onPressed: onRetry,
                  icon: const Icon(Icons.refresh),
                  label: Text(retryText ?? 'Tekrar Dene'),
                  style: DesignSystem.getPrimaryButtonStyle(context),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  /// Network error screen
  static Widget networkErrorScreen({
    required BuildContext context,
    VoidCallback? onRetry,
    String? customMessage,
  }) {
    return errorScreen(
      context: context,
      title: 'İnternet Bağlantısı Yok',
      message: customMessage ??
          'İnternet bağlantınızı kontrol edin ve tekrar deneyin. Çevrimdışı modda bazı özellikler kullanılamayabilir.',
      onRetry: onRetry,
      retryText: 'Yeniden Bağlan',
      icon: Icons.wifi_off,
      iconColor: Colors.orange,
    );
  }

  /// Server error screen
  static Widget serverErrorScreen({
    required BuildContext context,
    VoidCallback? onRetry,
    String? customMessage,
  }) {
    return errorScreen(
      context: context,
      title: 'Sunucu Hatası',
      message: customMessage ??
          'Sunucuda bir sorun oluştu. Lütfen daha sonra tekrar deneyin.',
      onRetry: onRetry,
      retryText: 'Tekrar Dene',
      icon: Icons.cloud_off,
      iconColor: ThemeColors.getErrorColor(context),
    );
  }

  /// Authentication error screen
  static Widget authErrorScreen({
    required BuildContext context,
    VoidCallback? onRetry,
    VoidCallback? onLogin,
    String? customMessage,
  }) {
    return errorScreen(
      context: context,
      title: 'Oturum Hatası',
      message: customMessage ??
          'Oturumunuz sona erdi veya geçersiz. Lütfen tekrar giriş yapın.',
      onRetry: onLogin ?? onRetry,
      retryText: onLogin != null ? 'Giriş Yap' : 'Tekrar Dene',
      icon: Icons.lock_outline,
      iconColor: Colors.amber,
    );
  }

  /// Permission denied error screen
  static Widget permissionErrorScreen({
    required BuildContext context,
    VoidCallback? onRequestPermission,
    String? customMessage,
  }) {
    return errorScreen(
      context: context,
      title: 'İzin Gerekli',
      message: customMessage ??
          'Bu özelliği kullanabilmek için gerekli izinleri vermeniz gerekiyor.',
      onRetry: onRequestPermission,
      retryText: 'İzin Ver',
      icon: Icons.lock_person,
      iconColor: Colors.blueGrey,
    );
  }

  /// Data loading error screen
  static Widget dataErrorScreen({
    required BuildContext context,
    VoidCallback? onRetry,
    String? customMessage,
  }) {
    return errorScreen(
      context: context,
      title: 'Veri Yüklenemedi',
      message: customMessage ??
          'Veriler yüklenirken bir hata oluştu. Lütfen tekrar deneyin.',
      onRetry: onRetry,
      retryText: 'Yeniden Yükle',
      icon: Icons.data_object,
      iconColor: ThemeColors.getErrorColor(context),
    );
  }

  // ===========================================================================
  // EMPTY STATE SCREENS
  // ===========================================================================

  /// Generic empty state screen
  static Widget emptyStateScreen({
    required BuildContext context,
    required String title,
    required String message,
    Widget? action,
    IconData? icon,
    Color? iconColor,
    bool showActionButton = true,
  }) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(DesignSystem.spacingL),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Empty State Icon
            Icon(
              icon ?? Icons.inbox_outlined,
              size: 80,
              color: iconColor ?? ThemeColors.getSecondaryText(context).withOpacity(0.5),
            ),
            const SizedBox(height: DesignSystem.spacingL),

            // Title
            Text(
              title,
              style: DesignSystem.getHeadlineSmall(context).copyWith(
                color: ThemeColors.getText(context),
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: DesignSystem.spacingM),

            // Message
            Text(
              message,
              style: DesignSystem.getBodyLarge(context).copyWith(
                color: ThemeColors.getSecondaryText(context),
              ),
              textAlign: TextAlign.center,
            ),

            // Action Button
            if (action != null && showActionButton) ...[
              const SizedBox(height: DesignSystem.spacingXl),
              action,
            ],
          ],
        ),
      ),
    );
  }

  /// No data available empty state
  static Widget noDataScreen({
    required BuildContext context,
    String? customTitle,
    String? customMessage,
    Widget? action,
  }) {
    return emptyStateScreen(
      context: context,
      title: customTitle ?? 'Henüz Veri Yok',
      message: customMessage ??
          'Burada henüz herhangi bir veri bulunmuyor. İleride burada içerik görünecek.',
      action: action,
      icon: Icons.inbox_outlined,
    );
  }

  /// No search results empty state
  static Widget noResultsScreen({
    required BuildContext context,
    String? searchQuery,
    Widget? action,
  }) {
    return emptyStateScreen(
      context: context,
      title: 'Sonuç Bulunamadı',
      message: searchQuery != null
          ? '"$searchQuery" için sonuç bulunamadı. Farklı anahtar kelimeler deneyin.'
          : 'Aradığınız kriterlere uygun sonuç bulunamadı. Farklı bir arama deneyin.',
      action: action ??
          ElevatedButton.icon(
            onPressed: () {
              // Clear search or go back
              Navigator.of(context).pop();
            },
            icon: const Icon(Icons.arrow_back),
            label: const Text('Geri Dön'),
            style: DesignSystem.getSecondaryButtonStyle(context),
          ),
      icon: Icons.search_off,
    );
  }

  /// No friends empty state
  static Widget noFriendsScreen({
    required BuildContext context,
    Widget? action,
  }) {
    return emptyStateScreen(
      context: context,
      title: 'Henüz Arkadaşın Yok',
      message: 'Arkadaş ekleyerek birlikte oyun oynayabilir, birbirinizle yarışabilirsiniz.',
      action: action ??
          ElevatedButton.icon(
            onPressed: () {
              // Navigate to add friends
            },
            icon: const Icon(Icons.person_add),
            label: const Text('Arkadaş Ekle'),
            style: DesignSystem.getPrimaryButtonStyle(context),
          ),
      icon: Icons.people_outline,
    );
  }

  /// No achievements empty state
  static Widget noAchievementsScreen({
    required BuildContext context,
    Widget? action,
  }) {
    return emptyStateScreen(
      context: context,
      title: 'Henüz Başarı Yok',
      message: 'Oyun oynayarak başarılar kazanabilir ve rozetlerinizi toplayabilirsiniz.',
      action: action ??
          ElevatedButton.icon(
            onPressed: () {
              // Navigate to quiz or games
            },
            icon: const Icon(Icons.play_arrow),
            label: const Text('Oyun Oyna'),
            style: DesignSystem.getPrimaryButtonStyle(context),
          ),
      icon: Icons.emoji_events_outlined,
    );
  }

  /// No notifications empty state
  static Widget noNotificationsScreen({
    required BuildContext context,
    Widget? action,
  }) {
    return emptyStateScreen(
      context: context,
      title: 'Bildirim Yok',
      message: 'Yeni bir bildirim geldiğinde burada görünecek.',
      action: action,
      icon: Icons.notifications_none,
      showActionButton: false,
    );
  }

  /// No quiz history empty state
  static Widget noQuizHistoryScreen({
    required BuildContext context,
    Widget? action,
  }) {
    return emptyStateScreen(
      context: context,
      title: 'Henüz Quiz Oynamadınız',
      message: 'İlk quizinizi oynayarak puan kazanmaya başlayın!',
      action: action ??
          ElevatedButton.icon(
            onPressed: () {
              // Navigate to quiz
            },
            icon: const Icon(Icons.quiz),
            label: const Text('Quiz Oyna'),
            style: DesignSystem.getPrimaryButtonStyle(context),
          ),
      icon: Icons.quiz_outlined,
    );
  }

  // ===========================================================================
  // OFFLINE SCREENS
  // ===========================================================================

  /// Offline screen for when internet is not available
  static Widget offlineScreen({
    required BuildContext context,
    VoidCallback? onRetry,
    String? customMessage,
  }) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(DesignSystem.spacingL),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Offline Icon
            Icon(
              Icons.wifi_off,
              size: 80,
              color: Colors.grey[400],
            ),
            const SizedBox(height: DesignSystem.spacingL),

            // Title
            Text(
              'Çevrimdışısınız',
              style: DesignSystem.getHeadlineSmall(context).copyWith(
                color: ThemeColors.getText(context),
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: DesignSystem.spacingM),

            // Message
            Text(
              customMessage ??
                  'İnternet bağlantınız yok. Bazı özellikler kullanılamayabilir. Bağlantınızı kontrol edin.',
              style: DesignSystem.getBodyLarge(context).copyWith(
                color: ThemeColors.getSecondaryText(context),
              ),
              textAlign: TextAlign.center,
            ),

            // Retry Button
            if (onRetry != null) ...[
              const SizedBox(height: DesignSystem.spacingXl),
              DesignSystem.card(
                context,
                child: ElevatedButton.icon(
                  onPressed: onRetry,
                  icon: const Icon(Icons.refresh),
                  label: const Text('Yeniden Dene'),
                  style: DesignSystem.getPrimaryButtonStyle(context),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  /// Offline with cached data screen
  static Widget offlineWithCacheScreen({
    required BuildContext context,
    String? cachedDataInfo,
    VoidCallback? onRetry,
  }) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(DesignSystem.spacingL),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Cached Data Icon
            Icon(
              Icons.cloud_off,
              size: 80,
              color: Colors.blueGrey[400],
            ),
            const SizedBox(height: DesignSystem.spacingL),

            // Title
            Text(
              'Çevrimdışı Mod',
              style: DesignSystem.getHeadlineSmall(context).copyWith(
                color: ThemeColors.getText(context),
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: DesignSystem.spacingM),

            // Message
            Text(
              'İnternet bağlantınız yok, ancak kaydedilmiş verilerle devam edebilirsiniz.',
              style: DesignSystem.getBodyLarge(context).copyWith(
                color: ThemeColors.getSecondaryText(context),
              ),
              textAlign: TextAlign.center,
            ),

            // Cached Data Info
            if (cachedDataInfo != null) ...[
              const SizedBox(height: DesignSystem.spacingM),
              Container(
                padding: const EdgeInsets.all(DesignSystem.spacingM),
                decoration: BoxDecoration(
                  color: ThemeColors.getCardBackgroundLight(context),
                  borderRadius: BorderRadius.circular(DesignSystem.radiusM),
                ),
                child: Text(
                  cachedDataInfo,
                  style: DesignSystem.getBodyMedium(context).copyWith(
                    color: ThemeColors.getText(context),
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
            ],

            // Retry Button
            if (onRetry != null) ...[
              const SizedBox(height: DesignSystem.spacingXl),
              DesignSystem.card(
                context,
                child: ElevatedButton.icon(
                  onPressed: onRetry,
                  icon: const Icon(Icons.wifi),
                  label: const Text('Bağlanmayı Dene'),
                  style: DesignSystem.getSecondaryButtonStyle(context),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  // ===========================================================================
  // LOADING SCREENS
  // ===========================================================================

  /// Full screen loading indicator
  static Widget loadingScreen({
    required BuildContext context,
    String? message,
    bool showMessage = true,
  }) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          DesignSystem.loadingIndicator(
            context,
            message: message,
            size: 48,
          ),
          if (showMessage && message != null) ...[
            const SizedBox(height: DesignSystem.spacingM),
            Text(
              message,
              style: DesignSystem.getBodyMedium(context).copyWith(
                color: ThemeColors.getSecondaryText(context),
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ],
      ),
    );
  }

  /// Loading overlay for existing content
  static Widget loadingOverlay({
    required BuildContext context,
    required Widget child,
    bool isLoading = true,
    String? loadingMessage,
  }) {
    if (!isLoading) return child;

    return Stack(
      children: [
        child,
        Container(
          color: ThemeColors.getOverlayColor(context),
          child: Center(
            child: DesignSystem.card(
              context,
              child: Padding(
                padding: const EdgeInsets.all(DesignSystem.spacingL),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    DesignSystem.loadingIndicator(context),
                    if (loadingMessage != null) ...[
                      const SizedBox(height: DesignSystem.spacingM),
                      Text(
                        loadingMessage,
                        style: DesignSystem.getBodyMedium(context),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ],
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}