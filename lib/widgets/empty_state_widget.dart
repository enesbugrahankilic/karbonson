// lib/widgets/empty_state_widget.dart
// Common Empty State Widget for all pages

import 'package:flutter/material.dart';
import '../theme/theme_colors.dart';

enum EmptyStateType {
  general,
  noData,
  noResults,
  loading,
  error,
  networkError,
  maintenance,
}

class EmptyStateWidget extends StatelessWidget {
  final EmptyStateType type;
  final String? title;
  final String? message;
  final Widget? icon;
  final VoidCallback? onRetry;
  final String? retryText;
  final bool showLoading;

  const EmptyStateWidget({
    super.key,
    this.type = EmptyStateType.general,
    this.title,
    this.message,
    this.icon,
    this.onRetry,
    this.retryText,
    this.showLoading = false,
  });

  @override
  Widget build(BuildContext context) {
    // Default titles and messages based on type
    final (defaultTitle, defaultMessage, defaultIcon, iconColor) = _getDefaults();

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Icon
            icon ?? defaultIcon,
            const SizedBox(height: 24),
            
            // Title
            Text(
              title ?? defaultTitle,
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: ThemeColors.getText(context),
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 12),
            
            // Message
            Text(
              message ?? defaultMessage,
              style: TextStyle(
                fontSize: 14,
                color: ThemeColors.getSecondaryText(context),
              ),
              textAlign: TextAlign.center,
            ),
            
            // Loading indicator
            if (showLoading) ...[
              const SizedBox(height: 24),
              const CircularProgressIndicator(),
            ],
            
            // Retry button
            if (onRetry != null) ...[
              const SizedBox(height: 24),
              ElevatedButton.icon(
                onPressed: onRetry,
                icon: const Icon(Icons.refresh),
                label: Text(retryText ?? 'Tekrar Dene'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: ThemeColors.getGreen(context),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 24,
                    vertical: 12,
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  (String, String, Widget, Color) _getDefaults() {
    switch (type) {
      case EmptyStateType.noData:
        return (
          'Veri Yok',
          'Henüz herhangi bir veri bulunmuyor. İleride burada içerik görünecek.',
          Icon(
            Icons.inbox_outlined,
            size: 64,
            color: Colors.grey[400],
          ),
          Colors.grey
        );
      
      case EmptyStateType.noResults:
        return (
          'Sonuç Bulunamadı',
          'Aradığınız kriterlere uygun sonuç bulunamadı. Farklı bir arama deneyin.',
          Icon(
            Icons.search_off,
            size: 64,
            color: Colors.grey[400],
          ),
          Colors.grey
        );
      
      case EmptyStateType.loading:
        return (
          'Yükleniyor',
          'Veriler yükleniyor, lütfen bekleyin...',
          SizedBox(
            width: 64,
            height: 64,
            child: const CircularProgressIndicator(),
          ),
          const Color(0xFF4CAF50)
        );
      
      case EmptyStateType.error:
        return (
          'Bir Hata Oluştu',
          'Veriler yüklenirken bir hata oluştu. Tekrar denemek için aşağıdaki butona tıklayın.',
          Icon(
            Icons.error_outline,
            size: 64,
            color: Colors.red[300],
          ),
          Colors.red
        );
      
      case EmptyStateType.networkError:
        return (
          'İnternet Bağlantısı Yok',
          'İnternet bağlantınızı kontrol edin ve tekrar deneyin.',
          Icon(
            Icons.wifi_off,
            size: 64,
            color: Colors.orange[300],
          ),
          Colors.orange
        );
      
      case EmptyStateType.maintenance:
        return (
          'Bakım Aşamasında',
          'Bu özellik şu anda geliştirme aşamasında. Yakında hizmetinizde olacak!',
          Icon(
            Icons.construction,
            size: 64,
            color: Colors.blue[300],
          ),
          Colors.blue
        );
      
      case EmptyStateType.general:
      default:
        return (
          'İçerik Yok',
          'Şu anda gösterilecek içerik bulunmuyor.',
          Icon(
            Icons.info_outline,
            size: 64,
            color: Colors.grey[400],
          ),
          Colors.grey
        );
    }
  }

  // Factory methods for common use cases
  factory EmptyStateWidget.noData({
    String? title,
    String? message,
    VoidCallback? onRetry,
  }) {
    return EmptyStateWidget(
      type: EmptyStateType.noData,
      title: title,
      message: message,
      onRetry: onRetry,
    );
  }

  factory EmptyStateWidget.noResults({
    String? title,
    String? message,
    VoidCallback? onRetry,
  }) {
    return EmptyStateWidget(
      type: EmptyStateType.noResults,
      title: title,
      message: message,
      onRetry: onRetry,
    );
  }

  factory EmptyStateWidget.error({
    String? message,
    VoidCallback? onRetry,
  }) {
    return EmptyStateWidget(
      type: EmptyStateType.error,
      message: message,
      onRetry: onRetry,
    );
  }

  factory EmptyStateWidget.loading({
    String? message,
  }) {
    return EmptyStateWidget(
      type: EmptyStateType.loading,
      message: message,
      showLoading: true,
    );
  }

  factory EmptyStateWidget.maintenance({
    String? message,
  }) {
    return EmptyStateWidget(
      type: EmptyStateType.maintenance,
      message: message,
    );
  }
}

// Extension for easy state management
extension EmptyStateExtension on EmptyStateWidget {
  static Widget fromState<T>({
    required bool isLoading,
    required bool hasError,
    required List<T> data,
    String? errorMessage,
    VoidCallback? onRetry,
  }) {
    if (isLoading) {
      return const EmptyStateWidget(
        type: EmptyStateType.loading,
        showLoading: true,
      );
    }
    
    if (hasError) {
      return EmptyStateWidget.error(
        message: errorMessage,
        onRetry: onRetry,
      );
    }
    
    if (data.isEmpty) {
      return EmptyStateWidget.noData(
        onRetry: onRetry,
      );
    }
    
    // Return empty container if data exists - won't be shown
    return const SizedBox.shrink();
  }
}

