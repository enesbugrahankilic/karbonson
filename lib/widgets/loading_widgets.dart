import 'package:flutter/material.dart';
import '../themes/app_theme.dart';

/// Loading widget sınıfları
class LoadingWidget extends StatelessWidget {
  const LoadingWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: CircularProgressIndicator(),
    );
  }
}

class LoadingDialog extends StatelessWidget {
  final String? message;
  
  const LoadingDialog({super.key, this.message});

  @override
  Widget build(BuildContext context) {
    return Dialog(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const CircularProgressIndicator(),
            if (message != null) ...[
              const SizedBox(height: 16),
              Text(
                message!,
                style: AppTheme.textTheme.bodyMedium,
                textAlign: TextAlign.center,
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class LoadingShimmer extends StatelessWidget {
  final double width;
  final double height;
  final BorderRadius borderRadius;
  
  const LoadingShimmer({
    super.key,
    this.width = 200,
    this.height = 16,
    this.borderRadius = BorderRadius.zero,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: AppTheme.colors.surfaceContainerHighest.withValues(alpha:0.3),
        borderRadius: borderRadius,
      ),
      child: const CircularProgressIndicator(
        strokeWidth: 2,
      ),
    );
  }
}

class LoadingOverlay extends StatelessWidget {
  final bool isLoading;
  final Widget child;
  final String? loadingMessage;
  
  const LoadingOverlay({
    super.key,
    required this.isLoading,
    required this.child,
    this.loadingMessage,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        child,
        if (isLoading)
          Container(
            color: Colors.black54,
            child: Center(
              child: LoadingDialog(message: loadingMessage),
            ),
          ),
      ],
    );
  }
}

class LoadingButton extends StatefulWidget {
  final Widget child;
  final VoidCallback? onPressed;
  final bool isLoading;
  final Color? backgroundColor;
  
  const LoadingButton({
    super.key,
    required this.child,
    this.onPressed,
    this.isLoading = false,
    this.backgroundColor,
  });

  @override
  State<LoadingButton> createState() => _LoadingButtonState();
}

class _LoadingButtonState extends State<LoadingButton> {
  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: widget.isLoading ? null : widget.onPressed,
      style: ElevatedButton.styleFrom(
        backgroundColor: widget.backgroundColor ?? AppTheme.colors.primary,
        foregroundColor: AppTheme.colors.onPrimary,
      ),
      child: widget.isLoading 
        ? const SizedBox(
            width: 20,
            height: 20,
            child: CircularProgressIndicator(strokeWidth: 2),
          )
        : widget.child,
    );
  }
}

class LoadingCard extends StatelessWidget {
  final Widget child;
  final bool isLoading;
  final EdgeInsetsGeometry? padding;
  
  const LoadingCard({
    super.key,
    required this.child,
    this.isLoading = false,
    this.padding,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: padding ?? const EdgeInsets.all(16),
        child: isLoading 
          ? const LoadingWidget()
          : child,
      ),
    );
  }
}