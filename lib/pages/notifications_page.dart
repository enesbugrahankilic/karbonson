// lib/pages/notifications_page.dart
// Hesap Bazlı Bildirimler Sayfası - Real-time updates ile

import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart' show kDebugMode, debugPrint;
import 'package:firebase_auth/firebase_auth.dart';
import '../services/notification_service.dart';
import '../services/firestore_service.dart';
import '../models/notification_data.dart';
import '../l10n/app_localizations.dart';
import '../utils/datetime_parser.dart';
import '../core/navigation/navigation_service.dart';
import '../core/navigation/app_router.dart';
import '../theme/design_system.dart';
import '../widgets/page_templates.dart';
import '../theme/theme_colors.dart';

class NotificationsPage extends StatefulWidget {
  const NotificationsPage({super.key});

  @override
  State<NotificationsPage> createState() => _NotificationsPageState();
}

class _NotificationsPageState extends State<NotificationsPage> {
  List<NotificationData> _notifications = [];
  List<NotificationData> _unreadNotifications = [];
  bool _isLoading = true;
  bool _showUnreadOnly = false;
  String? _currentUserId;
  int _unreadCount = 0;
  StreamSubscription? _notificationSubscription;

  @override
  void initState() {
    super.initState();
    _loadNotifications();
    _listenToNotifications();
  }

  @override
  void dispose() {
    _notificationSubscription?.cancel();
    super.dispose();
  }

  /// Listen to real-time notification updates (Account-Based)
  void _listenToNotifications() {
    final userId = FirebaseAuth.instance.currentUser?.uid;
    if (userId == null) return;

    _notificationSubscription = NotificationService()
        .listenToNotifications(userId)
        .listen((notifications) {
      if (mounted) {
        setState(() {
          _notifications = notifications;
          _unreadNotifications = notifications.where((n) => !n.isRead).toList();
          _unreadCount = _unreadNotifications.length;
          _isLoading = false;
        });
      }
    }, onError: (error) {
      if (kDebugMode) debugPrint('🚨 Notification stream error: $error');
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    });
  }

  Future<void> _loadNotifications() async {
    try {
      final currentUser = FirebaseAuth.instance.currentUser;
      
      if (currentUser == null) {
        if (kDebugMode) debugPrint('Kullanıcı giriş yapmamış');
        if (mounted) {
          setState(() {
            _isLoading = false;
          });
        }
        return;
      }

      if (mounted) {
        setState(() {
          _currentUserId = currentUser.uid;
        });
      }

      // Get unread count for badge
      final unreadCount = await NotificationService()
          .getUnreadCount(currentUser.uid);
      
      if (mounted) {
        setState(() {
          _unreadCount = unreadCount;
        });
      }

      // Firestore'dan bildirimleri getir (fallback if stream fails)
      final notifications = await FirestoreService().getNotifications(currentUser.uid);
      
      if (mounted) {
        setState(() {
          _notifications = notifications;
          _unreadNotifications = notifications.where((n) => !n.isRead).toList();
          _isLoading = false;
        });
      }
    } catch (e) {
      if (kDebugMode) debugPrint('Bildirimler yüklenirken hata: $e');
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _markAsRead(String notificationId) async {
    if (_currentUserId == null) return;

    try {
      await NotificationService().markAsRead(_currentUserId!, notificationId);
      
      setState(() {
        _notifications = _notifications.map((n) {
          if (n.id == notificationId) {
            return n.copyWith(isRead: true);
          }
          return n;
        }).toList();
        
        _unreadNotifications = _notifications.where((n) => !n.isRead).toList();
        _unreadCount = _unreadNotifications.length;
      });
    } catch (e) {
      if (kDebugMode) debugPrint('Bildirim okundu işaretlenirken hata: $e');
    }
  }

  Future<void> _markAllAsRead() async {
    if (_currentUserId == null || _unreadNotifications.isEmpty) return;

    try {
      await NotificationService().markAllAsRead(_currentUserId!);
      
      setState(() {
        _notifications = _notifications.map((n) => n.copyWith(isRead: true)).toList();
        _unreadNotifications = [];
        _unreadCount = 0;
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(AppLocalizations.of(context)?.markAllAsRead ?? 'All marked as read'),
            duration: const Duration(seconds: 2),
          ),
        );
      }
    } catch (e) {
      if (kDebugMode) debugPrint('Tüm bildirimler okundu yapılırken hata: $e');
    }
  }

  Future<void> _deleteNotification(String notificationId) async {
    if (_currentUserId == null) return;

    try {
      await NotificationService().deleteNotification(_currentUserId!, notificationId);
      
      setState(() {
        _notifications.removeWhere((n) => n.id == notificationId);
        _unreadNotifications.removeWhere((n) => n.id == notificationId);
        _unreadCount = _unreadNotifications.length;
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Notification deleted'),
            duration: Duration(seconds: 2),
          ),
        );
      }
    } catch (e) {
      if (kDebugMode) debugPrint('Bildirim silinirken hata: $e');
    }
  }

  Future<void> _deleteAllNotifications() async {
    if (_currentUserId == null || _notifications.isEmpty) return;

    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete All'),
        content: const Text('Are you sure you want to delete all notifications?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('Delete', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );

    if (confirm != true) return;

    try {
      await NotificationService().deleteAllNotifications(_currentUserId!);

      setState(() {
        _notifications = [];
        _unreadNotifications = [];
        _unreadCount = 0;
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('All notifications deleted'),
            duration: Duration(seconds: 2),
          ),
        );
      }
    } catch (e) {
      if (kDebugMode) debugPrint('Tüm bildirimler silinirken hata: $e');
    }
  }

  /// Navigate to related page based on notification type
  Future<void> _navigateToRelatedPage(NotificationData notification) async {
    String? routeName;

    switch (notification.type) {
      case NotificationType.friendRequestAccepted:
      case NotificationType.friendRequestRejected:
        routeName = AppRoutes.friends;
        break;
      case NotificationType.gameInvite:
      case NotificationType.gameInviteAccepted:
        routeName = AppRoutes.duel;
        break;
      case NotificationType.dailyTaskCompleted:
        routeName = AppRoutes.dailyChallenge;
        break;
      case NotificationType.rewardBoxEarned:
      case NotificationType.boxOpened:
        routeName = AppRoutes.rewards;
        break;
      case NotificationType.achievementEarned:
        routeName = AppRoutes.achievementsGallery;
        break;
      case NotificationType.general:
        // No navigation for general notifications
        return;
    }

    try {
      await NavigationService.navigatorKey.currentState?.pushNamed(routeName);
    } catch (e) {
      if (kDebugMode) debugPrint('Navigation error: $e');
    }
  }

  Widget _buildNotificationItem(NotificationData notification) {
    final l10n = AppLocalizations.of(context);

    return Dismissible(
      key: Key(notification.id),
      direction: DismissDirection.endToStart,
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 20),
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: ThemeColors.getErrorColor(context),
          borderRadius: BorderRadius.circular(12),
        ),
        child: const Icon(
          Icons.delete,
          color: Colors.white,
          size: 28,
        ),
      ),
      confirmDismiss: (direction) async {
        final confirm = await showDialog<bool>(
          context: context,
          builder: (context) => AlertDialog(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            title: const Text('Delete'),
            content: const Text('Are you sure you want to delete this notification?'),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(false),
                child: Text(l10n?.cancel ?? 'Cancel'),
              ),
              TextButton(
                onPressed: () => Navigator.of(context).pop(true),
                style: TextButton.styleFrom(
                  foregroundColor: ThemeColors.getErrorColor(context),
                ),
                child: const Text('Delete'),
              ),
            ],
          ),
        );
        if (confirm == true) {
          await _deleteNotification(notification.id);
        }
        return false;
      },
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: notification.isRead
              ? ThemeColors.getCardBackground(context)
              : ThemeColors.getPrimaryButtonColor(context).withOpacity(0.05),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: notification.isRead
                ? ThemeColors.getBorder(context)
                : ThemeColors.getPrimaryButtonColor(context).withOpacity(0.2),
            width: 1,
          ),
          boxShadow: notification.isRead ? null : [
            BoxShadow(
              color: ThemeColors.getPrimaryButtonColor(context).withOpacity(0.1),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: ListTile(
          contentPadding: const EdgeInsets.all(16),
          leading: Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: _getNotificationColor(notification.type).withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(
              _getNotificationIcon(notification.type),
              color: _getNotificationColor(notification.type),
              size: 24,
            ),
          ),
          title: Text(
            notification.title,
            style: TextStyle(
              fontWeight: notification.isRead ? FontWeight.w500 : FontWeight.w700,
              fontSize: 16,
              color: ThemeColors.getText(context),
            ),
          ),
          subtitle: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 8),
              Text(
                notification.message,
                style: TextStyle(
                  color: ThemeColors.getSecondaryText(context),
                  fontSize: 14,
                  height: 1.4,
                ),
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  Icon(
                    Icons.access_time,
                    size: 14,
                    color: ThemeColors.getSecondaryText(context).withOpacity(0.7),
                  ),
                  const SizedBox(width: 4),
                  Text(
                    DateTimeParser.formatRelativeTime(notification.createdAt, context),
                    style: TextStyle(
                      fontSize: 12,
                      color: ThemeColors.getSecondaryText(context).withOpacity(0.7),
                    ),
                  ),
                ],
              ),
            ],
          ),
          trailing: !notification.isRead
              ? Container(
                  width: 10,
                  height: 10,
                  decoration: BoxDecoration(
                    color: ThemeColors.getPrimaryButtonColor(context),
                    shape: BoxShape.circle,
                  ),
                )
              : null,
          onTap: () async {
            await _markAsRead(notification.id);
            await _navigateToRelatedPage(notification);
          },
        ),
      ),
    );
  }

  IconData _getNotificationIcon(NotificationType type) {
    switch (type) {
      case NotificationType.friendRequestAccepted:
        return Icons.person_add;
      case NotificationType.friendRequestRejected:
        return Icons.person_remove;
      case NotificationType.gameInvite:
        return Icons.gamepad;
      case NotificationType.gameInviteAccepted:
        return Icons.check_circle;
      case NotificationType.general:
      default:
        return Icons.notifications;
    }
  }

  Color _getNotificationColor(NotificationType type) {
    switch (type) {
      case NotificationType.friendRequestAccepted:
        return Colors.green;
      case NotificationType.friendRequestRejected:
        return Colors.red;
      case NotificationType.gameInvite:
        return Colors.purple;
      case NotificationType.gameInviteAccepted:
        return Colors.blue;
      case NotificationType.general:
      default:
        return Colors.orange;
    }
  }

  /// Build notification badge widget
  Widget _buildNotificationBadge(int count) {
    if (count <= 0) return const SizedBox.shrink();
    
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: Colors.red,
        shape: BoxShape.circle,
      ),
      constraints: const BoxConstraints(
        minWidth: 18,
        minHeight: 18,
      ),
      child: Text(
        count > 99 ? '99+' : count.toString(),
        style: const TextStyle(
          color: Colors.white,
          fontSize: 11,
          fontWeight: FontWeight.bold,
        ),
        textAlign: TextAlign.center,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final displayedNotifications = _showUnreadOnly
        ? _unreadNotifications
        : _notifications;

    return Scaffold(
      appBar: StandardAppBar(
        title: Text('${l10n?.notifications ?? 'Notifications'} ${_unreadCount > 0 ? '($_unreadCount)' : ''}'),
        onBackPressed: () => Navigator.pop(context),
        actions: [
          if (_unreadNotifications.isNotEmpty)
            IconButton(
              icon: const Icon(Icons.done_all),
              tooltip: l10n?.markAllAsRead ?? 'Mark All as Read',
              onPressed: _markAllAsRead,
            ),
          if (_notifications.isNotEmpty)
            IconButton(
              icon: const Icon(Icons.delete_sweep),
              tooltip: 'Delete All',
              onPressed: _deleteAllNotifications,
            ),
        ],
      ),
      body: _isLoading
          ? DesignSystem.globalLoadingScreen(
              context,
              message: l10n?.loadingData ?? 'Loading data...',
            )
          : PageBody(
              scrollable: true,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Header section with filters
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: ThemeColors.getCardBackground(context),
                      borderRadius: const BorderRadius.only(
                        bottomLeft: Radius.circular(16),
                        bottomRight: Radius.circular(16),
                      ),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          l10n?.notifications ?? 'Notifications',
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.w700,
                            color: ThemeColors.getText(context),
                          ),
                        ),
                        const SizedBox(height: 16),
                        Row(
                          children: [
                            Expanded(
                              child: FilterChip(
                                label: Text(l10n?.allNotifications ?? 'All'),
                                selected: !_showUnreadOnly,
                                onSelected: (selected) {
                                  setState(() {
                                    _showUnreadOnly = false;
                                  });
                                },
                                avatar: const Icon(Icons.list, size: 18),
                                backgroundColor: ThemeColors.getCardBackground(context),
                                selectedColor: ThemeColors.getPrimaryButtonColor(context).withOpacity(0.1),
                              ),
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: FilterChip(
                                label: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Text(l10n?.unreadNotifications ?? 'Unread'),
                                    if (_unreadCount > 0) ...[
                                      const SizedBox(width: 4),
                                      _buildNotificationBadge(_unreadCount),
                                    ],
                                  ],
                                ),
                                selected: _showUnreadOnly,
                                onSelected: (selected) {
                                  setState(() {
                                    _showUnreadOnly = true;
                                  });
                                },
                                avatar: const Icon(Icons.mark_email_unread, size: 18),
                                backgroundColor: ThemeColors.getCardBackground(context),
                                selectedColor: ThemeColors.getPrimaryButtonColor(context).withOpacity(0.1),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),

                  // Unread notifications info
                  if (_unreadNotifications.isNotEmpty && !_showUnreadOnly)
                    Padding(
                      padding: const EdgeInsets.all(16),
                      child: Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: ThemeColors.getPrimaryButtonColor(context).withOpacity(0.1),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: ThemeColors.getPrimaryButtonColor(context).withOpacity(0.2),
                          ),
                        ),
                        child: Row(
                          children: [
                            Icon(
                              Icons.notifications_active,
                              color: ThemeColors.getPrimaryButtonColor(context),
                              size: 24,
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Text(
                                '${_unreadNotifications.length} ${(l10n?.unreadNotifications ?? 'unread notifications').toLowerCase()}',
                                style: TextStyle(
                                  color: ThemeColors.getText(context),
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ),
                            TextButton(
                              onPressed: () {
                                setState(() {
                                  _showUnreadOnly = true;
                                });
                              },
                              style: TextButton.styleFrom(
                                foregroundColor: ThemeColors.getPrimaryButtonColor(context),
                              ),
                              child: Text(l10n?.viewNotifications ?? 'View Unread'),
                            ),
                          ],
                        ),
                      ),
                    ),

                  // Notifications list
                  if (displayedNotifications.isEmpty)
                    Padding(
                      padding: const EdgeInsets.all(16),
                      child: DesignSystem.globalNoNotificationsScreen(context),
                    )
                  else
                    ...displayedNotifications.map((notification) {
                      return _buildNotificationItem(notification);
                    }).toList(),
                ],
              ),
            ),
    );
  }
}

