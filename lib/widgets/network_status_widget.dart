// lib/widgets/network_status_widget.dart
// Network connectivity status widget with continuous monitoring and offline-to-online recovery

import 'dart:async';
import 'package:flutter/material.dart';
import '../services/connectivity_service.dart';
import '../theme/theme_colors.dart';

/// Network status widget that shows connectivity state and provides retry functionality
/// 
/// Features:
/// - Shows offline status with Turkish message: "Çevrimdışı durumdasınız. Lütfen internet bağlantınızı kontrol edin."
/// - Continuous connectivity monitoring
/// - Offline-to-online state recovery
/// - Retry functionality
/// - Proper disposal of resources
class NetworkStatusWidget extends StatefulWidget {
  final ConnectivityService connectivityService;
  final VoidCallback? onRetry;
  final bool showWhenOnline;
  final Widget? onlineWidget;
  final EdgeInsets padding;

  const NetworkStatusWidget({
    super.key,
    required this.connectivityService,
    this.onRetry,
    this.showWhenOnline = false,
    this.onlineWidget,
    this.padding = const EdgeInsets.all(16),
  });

  @override
  State<NetworkStatusWidget> createState() => _NetworkStatusWidgetState();
}

class _NetworkStatusWidgetState extends State<NetworkStatusWidget>
    with TickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;
  
  bool _wasOffline = false;
  StreamSubscription<bool>? _connectivitySubscription;

  @override
  void initState() {
    super.initState();
    _initializeAnimations();
    _startMonitoring();
  }

  void _initializeAnimations() {
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeIn,
    ));
    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, -0.1),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeOut,
    ));
  }

  void _startMonitoring() {
    _connectivitySubscription = widget.connectivityService.connectivityStateStream
        .listen(_handleConnectivityChange);
  }

  void _handleConnectivityChange(bool isConnected) {
    if (mounted) {
      setState(() {
        if (!isConnected && _wasOffline) {
          // Still offline, keep showing status
          _wasOffline = true;
        } else if (!isConnected) {
          // Just went offline
          _wasOffline = true;
          _animationController.forward();
        } else if (isConnected && _wasOffline) {
          // Just came back online
          _wasOffline = false;
          _animationController.reverse().then((_) {
            if (mounted) {
              // Show success message or enable functionality
              _showOnlineRecoveryMessage();
            }
          });
        }
      });
    }
  }

  void _showOnlineRecoveryMessage() {
    if (widget.onRetry != null) {
      // Show a success message and enable retry functionality
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              Icon(
                Icons.wifi,
                color: Colors.white,
                size: 20,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  'Çevrimiçi oldunuz! Akışı yeniden deneyebilirsiniz.',
                  style: const TextStyle(color: Colors.white),
                ),
              ),
            ],
          ),
          backgroundColor: Colors.green,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          margin: widget.padding,
          action: SnackBarAction(
            label: 'Yenile',
            textColor: Colors.white,
            onPressed: widget.onRetry!,
          ),
        ),
      );
    }
  }

  Future<void> _handleRetry() async {
    final success = await widget.connectivityService.retryConnectivity();
    if (success && widget.onRetry != null) {
      widget.onRetry!();
    }
  }

  @override
  void dispose() {
    _connectivitySubscription?.cancel();
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isConnected = widget.connectivityService.isConnected;

    // Show online status widget if requested and connected
    if (isConnected && widget.showWhenOnline && widget.onlineWidget != null) {
      return FadeTransition(
        opacity: _fadeAnimation,
        child: SlideTransition(
          position: _slideAnimation,
          child: widget.onlineWidget!,
        ),
      );
    }

    // Show offline status widget
    if (!isConnected) {
      return FadeTransition(
        opacity: _fadeAnimation,
        child: SlideTransition(
          position: _slideAnimation,
          child: Container(
            padding: widget.padding,
            decoration: BoxDecoration(
              color: Colors.red.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.red.withValues(alpha: 0.3)),
            ),
            child: Row(
              children: [
                Icon(
                  Icons.wifi_off,
                  color: Colors.red,
                  size: 24,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        'Çevrimdışı Durumdasınız',
                        style: TextStyle(
                          color: Colors.red,
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Lütfen internet bağlantınızı kontrol edin.',
                        style: TextStyle(
                          color: Colors.red.withValues(alpha: 0.8),
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
                TextButton(
                  onPressed: _handleRetry,
                  style: TextButton.styleFrom(
                    foregroundColor: Colors.red,
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    minimumSize: Size.zero,
                    tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.refresh,
                        size: 16,
                        color: Colors.red,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        'Tekrar Dene',
                        style: TextStyle(
                          color: Colors.red,
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    }

    // Return empty container if connected and not showing online widget
    return const SizedBox.shrink();
  }
}

/// Simplified network status widget for forms
class FormNetworkStatusWidget extends StatelessWidget {
  final ConnectivityService connectivityService;
  final VoidCallback? onRetry;
  final bool enabled;

  const FormNetworkStatusWidget({
    super.key,
    required this.connectivityService,
    this.onRetry,
    this.enabled = true,
  });

  @override
  Widget build(BuildContext context) {
    final isConnected = connectivityService.isConnected;

    if (!isConnected) {
      return Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.red.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: Colors.red.withValues(alpha: 0.3)),
        ),
        child: Row(
          children: [
            Icon(
              Icons.wifi_off,
              color: Colors.red,
              size: 20,
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                'İnternet bağlantısı yok',
                style: TextStyle(
                  color: Colors.red,
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
            TextButton(
              onPressed: enabled ? onRetry : null,
              child: Text(
                'Tekrar Dene',
                style: TextStyle(
                  color: enabled ? Colors.red : Colors.grey,
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
      );
    }

    return const SizedBox.shrink();
  }
}