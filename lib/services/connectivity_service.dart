// ignore_for_file: unrelated_type_equality_checks

import 'dart:io';
import 'dart:async';
import 'package:connectivity_plus/connectivity_plus.dart';

class ConnectivityService {
  final Connectivity _connectivity = Connectivity();
  StreamSubscription<ConnectivityResult>? _connectivitySubscription;
  
  // State tracking
  bool _isConnected = true;
  DateTime? _lastOnlineTime;
  
  /// Stream controller for connectivity state changes
  final StreamController<bool> _connectivityStateController = 
      StreamController<bool>.broadcast();
      
  /// Get connectivity state stream
  Stream<bool> get connectivityStateStream => _connectivityStateController.stream;
  
  /// Get current connectivity state
  bool get isConnected => _isConnected;
  
  /// Get last online time
  DateTime? get lastOnlineTime => _lastOnlineTime;

  /// Expose the underlying `onConnectivityChanged` stream directly.
  /// This keeps behavior consistent with the package and avoids
  /// attempting to normalize non-standard payload shapes.
  Stream<ConnectivityResult> get connectivityStream =>
      _connectivity.onConnectivityChanged.asyncExpand((dynamic event) {
    try {
      if (event is ConnectivityResult) return Stream.value(event);
      if (event is Iterable) return Stream.fromIterable(event.whereType<ConnectivityResult>());
    } catch (_) {
      // fall through to empty
    }
    return const Stream.empty();
  });

  /// Initialize continuous connectivity monitoring
  void initialize() {
    _startMonitoring();
  }

  /// Start monitoring connectivity changes
  void _startMonitoring() {
    _connectivitySubscription = connectivityStream.listen(_handleConnectivityChange);
    // Initial check
    _checkConnectivity();
  }

  /// Handle connectivity state changes
  void _handleConnectivityChange(ConnectivityResult result) {
    final wasConnected = _isConnected;
    _isConnected = result != ConnectivityResult.none;
    
    if (wasConnected != _isConnected) {
      if (_isConnected) {
        _lastOnlineTime = DateTime.now();
        if (DateTime.now().difference(_lastOnlineTime!).inMinutes > 1) {
          // Was offline for more than a minute
          _notifyOnline();
        }
      } else {
        _notifyOffline();
      }
      _connectivityStateController.add(_isConnected);
    }
  }

  /// Notify when going offline
  void _notifyOffline() {
    // This can be used to show offline messages or disable features
  }

  /// Notify when coming back online
  void _notifyOnline() {
    // This can be used to re-enable buttons and show online messages
    // "Çevrimiçi oldunuz, akışı yeniden deneyebilirsiniz"
  }

  /// Check current connectivity status
  Future<void> _checkConnectivity() async {
    _isConnected = await checkConnectivity();
    if (_isConnected) {
      _lastOnlineTime = DateTime.now();
    }
    _connectivityStateController.add(_isConnected);
  }

  /// Check basic connectivity
  Future<bool> checkConnectivity() async {
    try {
      final result = await _connectivity.checkConnectivity();
      return result != ConnectivityResult.none;
    } catch (e) {
      return false;
    }
  }

  /// Enhanced connectivity check with internet reachability test
  Future<bool> hasInternetConnection() async {
    try {
      // First check basic connectivity
      final connectivityResult = await _connectivity.checkConnectivity();
      if (connectivityResult == ConnectivityResult.none) {
        return false;
      }

      // Test actual internet reachability
      final result = await InternetAddress.lookup('google.com')
          .timeout(const Duration(seconds: 3));
      
      return result.isNotEmpty && result[0].rawAddress.isNotEmpty;
    } catch (e) {
      return false;
    }
  }

  /// Retry connectivity check (for "Tekrar Dene" functionality)
  Future<bool> retryConnectivity() async {
    await _checkConnectivity();
    return _isConnected;
  }

  /// Get formatted last online time for display
  String getLastOnlineTimeFormatted() {
    if (_lastOnlineTime == null) {
      return 'Hiçbir zaman';
    }
    
    final now = DateTime.now();
    final difference = now.difference(_lastOnlineTime!);
    
    if (difference.inMinutes < 1) {
      return 'Az önce';
    } else if (difference.inHours < 1) {
      return '${difference.inMinutes} dakika önce';
    } else if (difference.inDays < 1) {
      return '${difference.inHours} saat önce';
    } else {
      return '${difference.inDays} gün önce';
    }
  }

  /// Clean up resources
  void dispose() {
    _connectivitySubscription?.cancel();
    _connectivityStateController.close();
  }
}