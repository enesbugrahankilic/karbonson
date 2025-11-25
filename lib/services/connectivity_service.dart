// ignore_for_file: unrelated_type_equality_checks

import 'dart:async';
import 'package:connectivity_plus/connectivity_plus.dart';

class ConnectivityService {
  final Connectivity _connectivity = Connectivity();

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

  Future<bool> isConnected() async {
    final result = await _connectivity.checkConnectivity();
    return result != ConnectivityResult.none;
  }

  void dispose() {
    // No-op: we don't own the connectivity stream controller.
  }
}