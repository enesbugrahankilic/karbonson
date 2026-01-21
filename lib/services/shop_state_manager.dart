// lib/services/shop_state_manager.dart
// Manage shop and loot box state to prevent duplicates and data loss

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart' show kDebugMode, debugPrint;
import 'dart:async';
import 'analytics_service.dart';

class ShopStateManager {
  static final ShopStateManager _instance = ShopStateManager._internal();
  factory ShopStateManager() => _instance;
  ShopStateManager._internal();

  late FirebaseFirestore _firestore;
  late FirebaseAuth _auth;

  // Track in-flight operations
  final Set<String> _inFlightTransactions = {};
  final StreamController<bool> _shopStateController = StreamController<bool>.broadcast();

  /// Initialize shop state manager