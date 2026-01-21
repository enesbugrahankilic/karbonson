import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart' show kDebugMode, debugPrint;
import 'package:firebase_auth/firebase_auth.dart';
import '../core/navigation/app_router.dart';
import '../services/notification_service.dart';

class HomeButton extends StatefulWidget {
  final bool showNotificationBadge;
  final VoidCallback? onNotificationsTap;

  const HomeButton({
    super.key,
    this.showNotificationBadge = true,
    this.onNotificationsTap,
  });

  @override
  State<HomeButton> createState() => _HomeButtonState();
}

class _HomeButtonState extends State<HomeButton> {
  int _unreadCount = 0;
  StreamSubscription? _notificationSubscription;

  @override
  void initState() {
    super.initState();
    _listenToNotifications();
  }

  @override
  void dispose() {
    _notificationSubscription?.cancel();
    super.dispose();
  }

  void _listenToNotifications() {
    final userId = FirebaseAuth.instance.currentUser?.uid;
    if (userId == null) return;

    _notificationSubscription = NotificationService()
        .listenToNotifications(userId)
        .listen((notifications) {
      final unreadCount = notifications.where((n) => !n.isRead).length;
      if (mounted) {
        setState(() {
          _unreadCount = unreadCount;
        });
      }
    }, onError: (error) {
      if (kDebugMode) debugPrint('🚨 Notification stream error: $error');
    });
  }

  void _handlePressed() {
    if (kDebugMode) {
      debugPrint('HomeButton pressed - navigating to home');
    }
    Navigator.of(context).pushNamedAndRemoveUntil(
      AppRoutes.home,
      (route) => false,
    );
  }

  void _handleNotificationsTap() {
    if (kDebugMode) {
      debugPrint('Notifications icon pressed - navigating to notifications');
    }
    if (widget.onNotificationsTap != null) {
      widget.onNotificationsTap!();
    } else {
      Navigator.of(context).pushNamed(AppRoutes.notifications);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Home Icon Button
        IconButton(
          icon: Icon(
            Icons.home,
            color: Theme.of(context).colorScheme.primary,
            size: 24,
          ),
          onPressed: _handlePressed,
          tooltip: 'Ana Sayfa',
        ),
        
        // Notification Bell Icon Button with Badge
        if (widget.showNotificationBadge)
          _buildNotificationBadgeButton(),
      ],
    );
  }

  Widget _buildNotificationBadgeButton() {
    return Stack(
      clipBehavior: Clip.none,
      children: [
        IconButton(
          icon: Icon(
            Icons.notifications,
            color: _unreadCount > 0 
                ? Theme.of(context).colorScheme.primary 
                : Theme.of(context).colorScheme.onSurfaceVariant,
            size: 24,
          ),
          onPressed: _handleNotificationsTap,
          tooltip: 'Bildirimlerim',
        ),
        
        // Red badge for unread notifications
        if (_unreadCount > 0)
          Positioned(
            top: 4,
            right: 4,
            child: Container(
              padding: const EdgeInsets.all(4),
              decoration: BoxDecoration(
                color: Colors.red,
                shape: BoxShape.circle,
                border: Border.all(
                  color: Theme.of(context).colorScheme.surface,
                  width: 1.5,
                ),
              ),
              constraints: const BoxConstraints(
                minWidth: 16,
                minHeight: 16,
              ),
              child: Text(
                _unreadCount > 99 ? '99+' : _unreadCount.toString(),
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 9,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
            ),
          ),
      ],
    );
  }
}

