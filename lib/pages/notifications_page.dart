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
import '../widgets/home_button.dart';
import '../utils/datetime_parser.dart';
import '../core/navigation/navigation_service.dart';
import '../core/navigation/app_router.dart';
import '../theme/design_system.dart';

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
      default:
        // No navigation for general notifications
        return;
    }

    if (routeName != null) {
      try {
        await NavigationService.navigatorKey.currentState?.pushNamed(routeName);
      } catch (e) {
        if (kDebugMode) debugPrint('Navigation error: $e');
      }
    }
  }

  Widget _buildNotificationItem(NotificationData notification) {
    final l10n = AppLocalizations.of(context);
    
    return Dismissible(
      key: Key(notification.id),
      direction: DismissDirection.endToStart,
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 16),
        color: Colors.red.shade400,
        child: const Icon(
          Icons.delete,
          color: Colors.white,
        ),
      ),
      confirmDismiss: (direction) async {
        final confirm = await showDialog<bool>(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('Delete'),
            content: const Text('Are you sure you want to delete this notification?'),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(false),
                child: Text(l10n?.cancel ?? 'Cancel'),
              ),
              TextButton(
                onPressed: () => Navigator.of(context).pop(true),
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
      child: Card(
        color: notification.isRead 
            ? Theme.of(context).cardColor 
            : Theme.of(context).colorScheme.primaryContainer.withOpacity(0.3),
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
        child: ListTile(
          leading: CircleAvatar(
            backgroundColor: _getNotificationColor(notification.type),
            child: Icon(
              _getNotificationIcon(notification.type),
              color: Colors.white,
              size: 20,
            ),
          ),
          title: Text(
            notification.title,
            style: TextStyle(
              fontWeight: notification.isRead ? FontWeight.normal : FontWeight.bold,
            ),
          ),
          subtitle: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 4),
              Text(notification.message),
              const SizedBox(height: 4),
              Text(
                DateTimeParser.formatRelativeTime(notification.createdAt, context),
                style: TextStyle(
                  fontSize: 12,
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
              ),
            ],
          ),
          trailing: !notification.isRead
              ? Container(
                  width: 12,
                  height: 12,
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.primary,
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

  String _getNotificationTypeName(NotificationType type, BuildContext context) {
    final l10n = AppLocalizations.of(context);
    switch (type) {
      case NotificationType.friendRequestAccepted:
        return l10n?.friendRequestAccepted ?? 'Friend Request Accepted';
      case NotificationType.friendRequestRejected:
        return l10n?.friendRequestRejected ?? 'Friend Request Rejected';
      case NotificationType.gameInvite:
        return l10n?.gameInvitation ?? 'Game Invitation';
      case NotificationType.gameInviteAccepted:
        return l10n?.duelInvitation ?? 'Game Invite Accepted';
      case NotificationType.general:
      default:
        return l10n?.notifications ?? 'Notification';
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
    final screenWidth = MediaQuery.of(context).size.width;
    final isSmallScreen = screenWidth < 360;
    final titleFontSize = isSmallScreen ? 18.0 : 20.0;
    final l10n = AppLocalizations.of(context);

    final displayedNotifications = _showUnreadOnly 
        ? _unreadNotifications 
        : _notifications;

    return Scaffold(
      appBar: AppBar(
        leading: const HomeButton(),
        title: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              l10n?.notifications ?? 'Notifications',
              style: TextStyle(fontSize: titleFontSize),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(width: 8),
            _buildNotificationBadge(_unreadCount),
          ],
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
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
          : Column(
              children: [
                // Filtre bölümü
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  child: Row(
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
                        ),
                      ),
                    ],
                  ),
                ),

                // Okunmamış bildirim sayısı
                if (_unreadNotifications.isNotEmpty && !_showUnreadOnly)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    child: Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Theme.of(context).colorScheme.primaryContainer,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            Icons.info,
                            color: Theme.of(context).colorScheme.onPrimaryContainer,
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              '${_unreadNotifications.length} ${l10n?.unreadNotifications?.toLowerCase() ?? 'unread notifications'}',
                              style: TextStyle(
                                color: Theme.of(context).colorScheme.onPrimaryContainer,
                              ),
                            ),
                          ),
                          TextButton(
                            onPressed: () {
                              setState(() {
                                _showUnreadOnly = true;
                              });
                            },
                            child: Text(l10n?.viewNotifications ?? 'View Unread'),
                          ),
                        ],
                      ),
                    ),
                  ),

                // Bildirim listesi
                Expanded(
                  child: displayedNotifications.isEmpty
                      ? DesignSystem.globalNoNotificationsScreen(context)
                      : RefreshIndicator(
                          onRefresh: _loadNotifications,
                          child: ListView.builder(
                            padding: const EdgeInsets.symmetric(vertical: 8),
                            itemCount: displayedNotifications.length,
                            itemBuilder: (context, index) {
                              final notification = displayedNotifications[index];
                              return _buildNotificationItem(notification);
                            },
                          ),
                        ),
                ),
              ],
            ),
    );
  }
}

