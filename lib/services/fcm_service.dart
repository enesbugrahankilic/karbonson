// lib/services/fcm_service.dart
// Specification: Firebase Cloud Messaging Service for Push Notifications
// Handles FCM initialization, token management, and message handling

import 'dart:async';
import 'package:flutter/foundation.dart' show kDebugMode, debugPrint;
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:uuid/uuid.dart';
import 'device_token_service.dart';

/// Background message handler (must be top-level function)
@pragma('vm:entry-point')
Future<void> firebaseBackgroundMessageHandler(RemoteMessage message) async {
  if (kDebugMode) {
    debugPrint('🌙 Background message received: ${message.notification?.title ?? 'no title'}');
  }
}

/// FCM Service for handling push notifications
/// Manages Firebase Messaging initialization, token refresh, and message handling
class FCMService {
  static final FCMService _instance = FCMService._internal();
  factory FCMService() => _instance;
  FCMService._internal();

  final FirebaseMessaging _messaging = FirebaseMessaging.instance;
  final FlutterLocalNotificationsPlugin _localNotifications = FlutterLocalNotificationsPlugin();

  bool _isInitialized = false;
  String? _currentToken;
  String? _currentDeviceId;

  // Stream controllers for message handling
  final StreamController<RemoteMessage> _onMessageStream = StreamController<RemoteMessage>.broadcast();
  final StreamController<RemoteMessage> _onMessageOpenedStream = StreamController<RemoteMessage>.broadcast();

  // Token refresh callback
  Function(String)? _onTokenRefresh;

  /// Initialize FCM service
  Future<bool> initialize({
    Function(String)? onTokenRefresh,
    Function(RemoteMessage)? onForegroundMessage,
    Function(RemoteMessage)? onMessageOpened,
  }) async {
    if (_isInitialized) {
      if (kDebugMode) debugPrint('ℹ️ FCMService already initialized');
      return true;
    }

    try {
      _onTokenRefresh = onTokenRefresh;

      // Request notification permissions
      final settings = await _requestPermissions();
      if (kDebugMode) {
        debugPrint('🔔 Notification permission status: ${settings.authorizationStatus}');
      }

      // Get current FCM token
      _currentToken = await _messaging.getToken();
      if (kDebugMode) {
        debugPrint('🔑 FCM Token obtained: ${_currentToken?.substring(0, 20)}...');
      }

      // Set up token refresh listener
      _messaging.onTokenRefresh.listen((newToken) async {
        if (kDebugMode) debugPrint('🔄 FCM Token refreshed');
        _currentToken = newToken;
        _onTokenRefresh?.call(newToken);
        
        // Update token in Firestore
        await _updateDeviceToken(newToken);
      });

      // Set up message handlers
      await _setupMessageHandlers(
        onForegroundMessage: onForegroundMessage,
        onMessageOpened: onMessageOpened,
      );

      // Initialize local notifications
      await _initializeLocalNotifications();

      _isInitialized = true;
      if (kDebugMode) debugPrint('✅ FCMService initialized successfully');
      return true;
    } catch (e) {
      if (kDebugMode) debugPrint('❌ Failed to initialize FCMService: $e');
      return false;
    }
  }

  /// Request notification permissions
  Future<NotificationSettings> _requestPermissions() async {
    try {
      return await _messaging.requestPermission(
        alert: true,
        announcement: false,
        badge: true,
        carPlay: false,
        criticalAlert: false,
        sound: true,
      );
    } catch (e) {
      if (kDebugMode) debugPrint('⚠️ Failed to request permissions: $e');
      // Return authorized as fallback
      return NotificationSettings(
        authorizationStatus: AuthorizationStatus.authorized,
        alert: AppleNotificationSetting.enabled,
        announcement: AppleNotificationSetting.disabled,
        badge: AppleNotificationSetting.enabled,
        carPlay: AppleNotificationSetting.disabled,
        criticalAlert: AppleNotificationSetting.disabled,
        lockScreen: AppleNotificationSetting.enabled,
        notificationCenter: AppleNotificationSetting.enabled,
        showPreviews: AppleShowPreviewSetting.always,
        sound: AppleNotificationSetting.enabled,
        timeSensitive: AppleNotificationSetting.enabled,
        providesAppNotificationSettings: AppleNotificationSetting.enabled,
      );
    }
  }

  /// Set up message handlers for different app states
  Future<void> _setupMessageHandlers({
    Function(RemoteMessage)? onForegroundMessage,
    Function(RemoteMessage)? onMessageOpened,
  }) async {
    // Handle messages when app is in foreground
    FirebaseMessaging.onMessage.listen((message) {
      if (kDebugMode) {
        debugPrint('📨 Foreground message received: ${message.notification?.title ?? 'no title'}');
      }
      
      // Show local notification for foreground messages
      _showLocalNotification(message);
      
      // Add to stream
      _onMessageStream.add(message);
      onForegroundMessage?.call(message);
    });

    // Handle messages when app is opened from notification
    FirebaseMessaging.onMessageOpenedApp.listen((message) {
      if (kDebugMode) {
        debugPrint('🔓 Message opened from notification: ${message.notification?.title ?? 'no title'}');
      }
      _onMessageOpenedStream.add(message);
      onMessageOpened?.call(message);
    });

    // Handle initial notification when app is launched from terminated state
    final initialMessage = await _messaging.getInitialMessage();
    if (initialMessage != null) {
      if (kDebugMode) {
        debugPrint('🚀 Initial message received (app was terminated): ${initialMessage.notification?.title}');
      }
      _onMessageOpenedStream.add(initialMessage);
      onMessageOpened?.call(initialMessage);
    }
  }

  /// Initialize local notifications plugin
  Future<void> _initializeLocalNotifications() async {
    try {
      // Android-specific settings
      const androidSettings = AndroidInitializationSettings('@mipmap/ic_launcher');
      
      // iOS-specific settings
      const iosSettings = DarwinInitializationSettings(
        requestAlertPermission: true,
        requestBadgePermission: true,
        requestSoundPermission: true,
      );

      const settings = InitializationSettings(
        android: androidSettings,
        iOS: iosSettings,
      );

      await _localNotifications.initialize(
        settings,
        onDidReceiveNotificationResponse: _onNotificationResponse,
      );

      if (kDebugMode) debugPrint('✅ Local notifications initialized');
    } catch (e) {
      if (kDebugMode) debugPrint('⚠️ Failed to initialize local notifications: $e');
    }
  }

  /// Handle notification response (when user taps notification)
  void _onNotificationResponse(NotificationResponse response) {
    if (kDebugMode) {
      debugPrint('👆 Notification tapped: ${response.payload}');
    }
    // The navigation will be handled by the deep link service
    // based on the payload
  }

  /// Show local notification from FCM message
  Future<void> _showLocalNotification(RemoteMessage message) async {
    try {
      const androidDetails = AndroidNotificationDetails(
        'high_priority_notifications',
        'High Priority Notifications',
        channelDescription: 'Important notifications that require immediate attention',
        importance: Importance.max,
        priority: Priority.high,
        showWhen: true,
        enableLights: true,
        enableVibration: true,
      );

      const iosDetails = DarwinNotificationDetails(
        presentAlert: true,
        presentBadge: true,
        presentSound: true,
      );

      const details = NotificationDetails(
        android: androidDetails,
        iOS: iosDetails,
      );

      await _localNotifications.show(
        message.hashCode,
        message.notification?.title ?? '',
        message.notification?.body ?? '',
        details,
        payload: message.data['deep_link'] ?? '',
      );

      if (kDebugMode) debugPrint('🔔 Local notification shown');
    } catch (e) {
      if (kDebugMode) debugPrint('⚠️ Failed to show local notification: $e');
    }
  }

  /// Update device token in Firestore
  Future<void> _updateDeviceToken(String newToken) async {
    try {
      final deviceTokenService = DeviceTokenService();
      await deviceTokenService.initialize();
      _currentDeviceId = await deviceTokenService.registerDeviceToken(newToken);
      if (kDebugMode) debugPrint('✅ Device token updated in Firestore');
    } catch (e) {
      if (kDebugMode) debugPrint('⚠️ Failed to update device token: $e');
    }
  }

  /// Register device and get device ID
  Future<String?> registerDevice() async {
    try {
      if (_currentToken == null) {
        _currentToken = await _messaging.getToken();
      }
      
      if (_currentToken != null) {
        final deviceTokenService = DeviceTokenService();
        await deviceTokenService.initialize();
        _currentDeviceId = await deviceTokenService.registerDeviceToken(_currentToken!);
        return _currentDeviceId;
      }
      
      return null;
    } catch (e) {
      if (kDebugMode) debugPrint('❌ Failed to register device: $e');
      return null;
    }
  }

  /// Get current FCM token
  String? get currentToken => _currentToken;

  /// Get current device ID
  String? get currentDeviceId => _currentDeviceId;

  /// Get message streams
  Stream<RemoteMessage> get onMessage => _onMessageStream.stream;
  Stream<RemoteMessage> get onMessageOpened => _onMessageOpenedStream.stream;

  /// Check if notifications are enabled
  Future<bool> areNotificationsEnabled() async {
    try {
      final settings = await _messaging.getNotificationSettings();
      return settings.authorizationStatus == AuthorizationStatus.authorized;
    } catch (e) {
      if (kDebugMode) debugPrint('⚠️ Failed to check notification settings: $e');
      return false;
    }
  }

  /// Show local notification (manual)
  Future<void> showLocalNotification({
    required String title,
    required String body,
    String? payload,
  }) async {
    try {
      const androidDetails = AndroidNotificationDetails(
        'general_notifications',
        'General Notifications',
        channelDescription: 'General app notifications',
        importance: Importance.defaultImportance,
        priority: Priority.defaultPriority,
      );

      const iosDetails = DarwinNotificationDetails(
        presentAlert: true,
        presentBadge: true,
        presentSound: true,
      );

      const details = NotificationDetails(
        android: androidDetails,
        iOS: iosDetails,
      );

      await _localNotifications.show(
        const Uuid().v4().hashCode,
        title,
        body,
        details,
        payload: payload ?? '',
      );

      if (kDebugMode) debugPrint('🔔 Local notification shown: $title');
    } catch (e) {
      if (kDebugMode) debugPrint('⚠️ Failed to show local notification: $e');
    }
  }

  /// Cancel all local notifications
  Future<void> cancelAllNotifications() async {
    try {
      await _localNotifications.cancelAll();
      if (kDebugMode) debugPrint('✅ All notifications cancelled');
    } catch (e) {
      if (kDebugMode) debugPrint('❌ Failed to cancel notifications: $e');
    }
  }

  /// Cancel specific notification
  Future<void> cancelNotification(int id) async {
    try {
      await _localNotifications.cancel(id);
      if (kDebugMode) debugPrint('✅ Notification cancelled: $id');
    } catch (e) {
      if (kDebugMode) debugPrint('❌ Failed to cancel notification: $e');
    }
  }

  /// Cleanup on logout
  Future<void> cleanup() async {
    try {
      if (_currentDeviceId != null) {
        final deviceTokenService = DeviceTokenService();
        await deviceTokenService.initialize();
        await deviceTokenService.deactivateDeviceToken(_currentDeviceId!);
      }
      
      await cancelAllNotifications();
      _onMessageStream.close();
      _onMessageOpenedStream.close();
      
      _isInitialized = false;
      _currentToken = null;
      _currentDeviceId = null;
      
      if (kDebugMode) debugPrint('🧹 FCMService cleaned up');
    } catch (e) {
      if (kDebugMode) debugPrint('⚠️ Failed to cleanup FCMService: $e');
    }
  }

  /// Get debug info
  Map<String, dynamic> getDebugInfo() {
    return {
      'isInitialized': _isInitialized,
      'hasToken': _currentToken != null,
      'deviceId': _currentDeviceId,
    };
  }
}

