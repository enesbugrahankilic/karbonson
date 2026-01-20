// lib/pages/notifications_page.dart
// Bildirimler Sayfası - Kullanıcının tüm bildirimlerini gösterir

import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart' show kDebugMode, debugPrint;
import 'package:firebase_auth/firebase_auth.dart';
import '../services/firestore_service.dart';
import '../models/notification_data.dart';
import '../l10n/app_localizations.dart';
import '../widgets/home_button.dart';
import '../utils/datetime_parser.dart';

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

  @override
  void initState() {
    super.initState();
    _loadNotifications();
  }

  Future<void> _loadNotifications() async {
    try {
      final currentUser = FirebaseAuth.instance.currentUser;
      
      if (currentUser == null) {
        if (kDebugMode) debugPrint('Kullanıcı giriş yapmamış');
        setState(() {
          _isLoading = false;
        });
        return;
      }

      setState(() {
        _currentUserId = currentUser.uid;
      });

      // Firestore'dan bildirimleri getir
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
      await FirestoreService().markNotificationAsRead(_currentUserId!, notificationId);
      
      setState(() {
        _notifications = _notifications.map((n) {
          if (n.id == notificationId) {
            return n.copyWith(isRead: true);
          }
          return n;
        }).toList();
        
        _unreadNotifications = _notifications.where((n) => !n.isRead).toList();
      });
    } catch (e) {
      if (kDebugMode) debugPrint('Bildirim okundu işaretlenirken hata: $e');
    }
  }

  Future<void> _markAllAsRead() async {
    if (_currentUserId == null || _unreadNotifications.isEmpty) return;

    try {
      for (final notification in _unreadNotifications) {
        await FirestoreService().markNotificationAsRead(_currentUserId!, notification.id);
      }

      setState(() {
        _notifications = _notifications.map((n) => n.copyWith(isRead: true)).toList();
        _unreadNotifications = [];
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
        return await showDialog<bool>(
          context: context,
          builder: (context) => AlertDialog(
            title: Text(l10n?.close ?? 'Delete'),
            content: Text(l10n?.cancel ?? 'Are you sure you want to delete this notification?'),
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
      },
      onDismissed: (direction) {
        setState(() {
          _notifications.remove(notification);
          _unreadNotifications.remove(notification);
        });
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
          onTap: () => _markAsRead(notification.id),
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
        title: Text(
          l10n?.notifications ?? 'Notifications',
          style: TextStyle(fontSize: titleFontSize),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
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
        ],
      ),
      body: _isLoading
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const CircularProgressIndicator(),
                  const SizedBox(height: 16),
                  Text(
                    l10n?.loadingData ?? 'Loading data...',
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                ],
              ),
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
                          label: Text(l10n?.unreadNotifications ?? 'Unread'),
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
                if (_unreadNotifications.isNotEmpty)
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
                          if (_showUnreadOnly)
                            TextButton(
                              onPressed: () {
                                setState(() {
                                  _showUnreadOnly = false;
                                });
                              },
                              child: Text(l10n?.viewNotifications ?? 'View All'),
                            ),
                        ],
                      ),
                    ),
                  ),

                // Bildirim listesi
                Expanded(
                  child: displayedNotifications.isEmpty
                      ? Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.notifications_none,
                                size: 64,
                                color: Theme.of(context).colorScheme.onSurfaceVariant,
                              ),
                              const SizedBox(height: 16),
                              Text(
                                l10n?.noNotifications ?? 'No notifications yet',
                                style: Theme.of(context).textTheme.titleMedium,
                              ),
                              const SizedBox(height: 8),
                              Padding(
                                padding: const EdgeInsets.symmetric(horizontal: 32),
                                child: Text(
                                  l10n?.noNotificationsDescription ??
                                      'Your notifications will appear here when you receive them',
                                  style: TextStyle(
                                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                              ),
                            ],
                          ),
                        )
                      : ListView.builder(
                          padding: const EdgeInsets.symmetric(vertical: 8),
                          itemCount: displayedNotifications.length,
                          itemBuilder: (context, index) {
                            final notification = displayedNotifications[index];
                            return _buildNotificationItem(notification);
                          },
                        ),
                ),
              ],
            ),
    );
  }
}

