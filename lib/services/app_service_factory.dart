// lib/services/app_service_factory.dart
// Centralized service initialization and configuration

import 'package:shared_preferences/shared_preferences.dart';
import 'analytics_service.dart';
import 'session_management_service.dart';
import 'backend_validation_service.dart';

class AppServiceFactory {
  static final AppServiceFactory _instance = AppServiceFactory._internal();
  factory AppServiceFactory() => _instance;
  AppServiceFactory._internal();

  // Service instances
  late AnalyticsService _analyticsService;
  late SessionManagementService _sessionService;
  late BackendValidationService _validationService;

  bool _isInitialized = false;

  /// Initialize all services
  Future<void> initializeAll(SharedPreferences prefs) async {
    if (_isInitialized) return;

    // Initialize Analytics (must be first for crash reporting)
    _analyticsService = AnalyticsService();
    await _analyticsService.initialize();

    // Initialize Session Management
    _sessionService = SessionManagementService();
    await _sessionService.initialize(prefs);

    // Setup session callbacks
    _sessionService.onSessionExpired = (reason) {
      _analyticsService.logError('SessionExpired', reason);
      print('🚨 Session expired: $reason');
      // Trigger logout and navigate to login
    };

    _sessionService.onTokenRefreshed = (token) {
      _analyticsService.setUserProperty('token_status', 'valid');
      print('✅ Token refreshed');
    };

    _sessionService.onUserBanned = () {
      _analyticsService.logError('UserBanned', 'User account banned');
      print('🚨 User banned');
      // Show ban dialog and logout
    };

    // Initialize Backend Validation
    _validationService = BackendValidationService();
    await _validationService.initialize();

    _isInitialized = true;
    print('✅ All services initialized successfully');
  }

  // Getters for services
  AnalyticsService get analyticsService => _analyticsService;
  SessionManagementService get sessionService => _sessionService;
  BackendValidationService get validationService => _validationService;

  /// Dispose all services
  void disposeAll() {
    _analyticsService.dispose();
    _sessionService.dispose();
    _validationService.dispose();
    _isInitialized = false;
    print('🗑️ All services disposed');
  }
}
