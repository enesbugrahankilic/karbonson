import 'package:flutter/material.dart';
import '../themes/app_theme.dart';

/// Hata widget sınıfları
class ErrorWidget extends StatelessWidget {
  final String message;
  final VoidCallback? onRetry;
  final IconData? icon;
  final Color? iconColor;
  final String? buttonText;
  
  const ErrorWidget({
    super.key,
    required this.message,
    this.onRetry,
    this.icon,
    this.iconColor,
    this.buttonText,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon ?? Icons.error_outline,
              size: 64,
              color: iconColor ?? AppTheme.colors.error,
            ),
            const SizedBox(height: 16),
            Text(
              message,
              style: AppTheme.textTheme.bodyLarge?.copyWith(
                color: AppTheme.colors.onSurface.withOpacity(0.7),
              ),
              textAlign: TextAlign.center,
            ),
            if (onRetry != null) ...[
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: onRetry,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.colors.primary,
                  foregroundColor: AppTheme.colors.onPrimary,
                ),
                child: Text(buttonText ?? 'Tekrar Dene'),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class NetworkErrorWidget extends StatelessWidget {
  final VoidCallback? onRetry;
  final String? customMessage;
  
  const NetworkErrorWidget({
    super.key,
    this.onRetry,
    this.customMessage,
  });

  @override
  Widget build(BuildContext context) {
    return ErrorWidget(
      message: customMessage ?? 'Bağlantı hatası oluştu. İnternet bağlantınızı kontrol edin.',
      onRetry: onRetry,
      icon: Icons.wifi_off,
      iconColor: AppTheme.colors.error,
      buttonText: 'Tekrar Bağlan',
    );
  }
}

class NotFoundErrorWidget extends StatelessWidget {
  final String? customMessage;
  final VoidCallback? onRetry;
  
  const NotFoundErrorWidget({
    super.key,
    this.customMessage,
    this.onRetry,
  });

  @override
  Widget build(BuildContext context) {
    return ErrorWidget(
      message: customMessage ?? 'Aradığınız içerik bulunamadı.',
      onRetry: onRetry,
      icon: Icons.search_off,
      iconColor: AppTheme.colors.tertiary,
      buttonText: 'Geri Dön',
    );
  }
}

class PermissionErrorWidget extends StatelessWidget {
  final VoidCallback? onRequestPermission;
  final String? customMessage;
  
  const PermissionErrorWidget({
    super.key,
    this.onRequestPermission,
    this.customMessage,
  });

  @override
  Widget build(BuildContext context) {
    return ErrorWidget(
      message: customMessage ?? 'Bu özellik için izin gerekli.',
      onRetry: onRequestPermission,
      icon: Icons.lock_outline,
      iconColor: AppTheme.colors.secondary,
      buttonText: 'İzin Ver',
    );
  }
}

class ServerErrorWidget extends StatelessWidget {
  final VoidCallback? onRetry;
  final String? customMessage;
  
  const ServerErrorWidget({
    super.key,
    this.onRetry,
    this.customMessage,
  });

  @override
  Widget build(BuildContext context) {
    return ErrorWidget(
      message: customMessage ?? 'Sunucu hatası oluştu. Lütfen daha sonra tekrar deneyin.',
      onRetry: onRetry,
      icon: Icons.cloud_off,
      iconColor: AppTheme.colors.error,
      buttonText: 'Tekrar Dene',
    );
  }
}

class GenericErrorWidget extends StatelessWidget {
  final String? customMessage;
  final VoidCallback? onRetry;
  final IconData? icon;
  
  const GenericErrorWidget({
    super.key,
    this.customMessage,
    this.onRetry,
    this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return ErrorWidget(
      message: customMessage ?? 'Beklenmeyen bir hata oluştu.',
      onRetry: onRetry,
      icon: icon ?? Icons.error_outline,
      iconColor: AppTheme.colors.error,
      buttonText: 'Tekrar Dene',
    );
  }
}

class ErrorSnackBar extends SnackBar {
  ErrorSnackBar({
    super.key,
    required String message,
    VoidCallback? onAction,
    String? actionLabel,
  }) : super(
    content: Text(message),
    backgroundColor: AppTheme.colors.error,
    action: onAction != null 
      ? SnackBarAction(
          label: actionLabel ?? 'Tamam',
          onPressed: onAction,
          textColor: AppTheme.colors.onError,
        )
      : null,
  );
}

class SuccessSnackBar extends SnackBar {
  SuccessSnackBar({
    super.key,
    required String message,
    VoidCallback? onAction,
    String? actionLabel,
  }) : super(
    content: Text(message),
    backgroundColor: AppTheme.colors.tertiary,
    action: onAction != null 
      ? SnackBarAction(
          label: actionLabel ?? 'Tamam',
          onPressed: onAction,
          textColor: AppTheme.colors.onTertiary,
        )
      : null,
  );
}

class WarningSnackBar extends SnackBar {
  WarningSnackBar({
    super.key,
    required String message,
    VoidCallback? onAction,
    String? actionLabel,
  }) : super(
    content: Text(message),
    backgroundColor: AppTheme.colors.secondary,
    action: onAction != null 
      ? SnackBarAction(
          label: actionLabel ?? 'Tamam',
          onPressed: onAction,
          textColor: AppTheme.colors.onSecondary,
        )
      : null,
  );
}

class InfoSnackBar extends SnackBar {
  InfoSnackBar({
    super.key,
    required String message,
    VoidCallback? onAction,
    String? actionLabel,
  }) : super(
    content: Text(message),
    backgroundColor: AppTheme.colors.primaryContainer,
    action: onAction != null 
      ? SnackBarAction(
          label: actionLabel ?? 'Tamam',
          onPressed: onAction,
          textColor: AppTheme.colors.onPrimaryContainer,
        )
      : null,
  );
}

class EmptyStateWidget extends StatelessWidget {
  final String message;
  final IconData? icon;
  final Widget? action;
  final EdgeInsetsGeometry? padding;
  
  const EmptyStateWidget({
    super.key,
    required this.message,
    this.icon,
    this.action,
    this.padding,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: padding ?? const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (icon != null) ...[
              Icon(
                icon!,
                size: 64,
                color: AppTheme.colors.onSurface.withOpacity( 0.4),
              ),
              const SizedBox(height: 16),
            ],
            Text(
              message,
              style: AppTheme.textTheme.bodyLarge?.copyWith(
                color: AppTheme.colors.onSurface.withOpacity(0.7),
              ),
              textAlign: TextAlign.center,
            ),
            if (action != null) ...[
              const SizedBox(height: 24),
              action!,
            ],
          ],
        ),
      ),
    );
  }
}

class NoDataWidget extends StatelessWidget {
  final String? customMessage;
  final Widget? action;
  
  const NoDataWidget({
    super.key,
    this.customMessage,
    this.action,
  });

  @override
  Widget build(BuildContext context) {
    return EmptyStateWidget(
      message: customMessage ?? 'Henüz veri bulunmuyor.',
      icon: Icons.inbox_outlined,
      action: action,
    );
  }
}

class OfflineWidget extends StatelessWidget {
  final VoidCallback? onRetry;
  
  const OfflineWidget({
    super.key,
    this.onRetry,
  });

  @override
  Widget build(BuildContext context) {
    return EmptyStateWidget(
      message: 'Çevrimdışısınız. İnternet bağlantınızı kontrol edin.',
      icon: Icons.wifi_off,
      action: onRetry != null 
        ? ElevatedButton.icon(
            onPressed: onRetry,
            icon: const Icon(Icons.refresh),
            label: const Text('Yenile'),
          )
        : null,
    );
  }
}

class LoadingErrorWidget extends StatelessWidget {
  final String errorMessage;
  final VoidCallback? onRetry;
  final String? loadingMessage;
  
  const LoadingErrorWidget({
    super.key,
    required this.errorMessage,
    this.onRetry,
    this.loadingMessage,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const SizedBox(
          width: 48,
          height: 48,
          child: CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation<Color>(Colors.red),
            strokeWidth: 3,
          ),
        ),
        if (loadingMessage != null) ...[
          const SizedBox(height: 16),
          Text(
            loadingMessage!,
            style: AppTheme.textTheme.bodyMedium,
            textAlign: TextAlign.center,
          ),
        ],
        const SizedBox(height: 24),
        Text(
          errorMessage,
          style: AppTheme.textTheme.bodyMedium?.copyWith(
            color: AppTheme.colors.error,
          ),
          textAlign: TextAlign.center,
        ),
        if (onRetry != null) ...[
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: onRetry,
            child: const Text('Tekrar Dene'),
          ),
        ],
      ],
    );
  }
}