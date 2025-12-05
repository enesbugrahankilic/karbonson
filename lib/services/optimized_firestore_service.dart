// lib/services/optimized_firestore_service.dart
// Performance-optimized Firestore service with caching, batching, and lazy loading

import 'dart:async';
import 'dart:isolate';
import 'package:flutter/foundation.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Performance metrics for database operations
class DatabaseMetrics {
  final Duration totalDuration;
  final int queryCount;
  final int bytesRead;
  final int bytesWritten;
  final List<String> slowQueries;

  const DatabaseMetrics({
    required this.totalDuration,
    required this.queryCount,
    required this.bytesRead,
    required this.bytesWritten,
    required this.slowQueries,
  });

  Map<String, dynamic> toJson() => {
    'total_duration_ms': totalDuration.inMilliseconds,
    'query_count': queryCount,
    'bytes_read': bytesRead,
    'bytes_written': bytesWritten,
    'slow_queries_count': slowQueries.length,
    'slow_queries': slowQueries,
  };
}

/// Cache entry with TTL
class CacheEntry<T> {
  final T data;
  final DateTime expiresAt;
  final int size;

  CacheEntry({
    required this.data,
    required this.expiresAt,
    required this.size,
  });

  bool get isExpired => DateTime.now().isAfter(expiresAt);

  int get ageInSeconds => DateTime.now().difference(expiresAt).inSeconds.abs();
}

/// Query optimization options
class QueryOptions {
  final int? limit;
  final List<String>? selectFields;
  final Duration? timeout;
  final bool enableCache;
  final bool enableBatch;

  const QueryOptions({
    this.limit,
    this.selectFields,
    this.timeout,
    this.enableCache = true,
    this.enableBatch = false,
  });
}

/// Performance-optimized Firestore service
class OptimizedFirestoreService {
  static final OptimizedFirestoreService _instance = OptimizedFirestoreService._internal();
  factory OptimizedFirestoreService() => _instance;
  OptimizedFirestoreService._internal();

  final FirebaseFirestore _db = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // Cache management
  static const Duration _defaultCacheTTL = Duration(minutes: 5);
  static const int _maxCacheEntries = 1000;
  static const int _maxCacheSizeBytes = 50 * 1024 * 1024; // 50MB

  final Map<String, CacheEntry> _cache = {};
  int _currentCacheSize = 0;

  // Performance tracking
  DatabaseMetrics? _lastMetrics;
  final List<String> _slowQueries = [];
  int _queryCount = 0;
  int _bytesRead = 0;
  int _bytesWritten = 0;

  // Connection pooling
  static const int _maxConcurrentQueries = 10;
  final List<Future> _activeQueries = [];

  /// Execute query with performance optimization
  Future<List<QuerySnapshot<Map<String, dynamic>>>> executeBatchQueries({
    required List<Query<Map<String, dynamic>>> queries,
    QueryOptions options = const QueryOptions(),
  }) async {
    final stopwatch = Stopwatch()..start();

    try {
      // Rate limiting - limit concurrent queries
      await _enforceConcurrencyLimit();

      // Execute queries in parallel with timeout
      final futures = queries.map((query) async {
        return await _executeOptimizedQuery(
          query: query,
          options: options,
        );
      }).toList();

      final results = await Future.wait(futures);
      
      stopwatch.stop();
      _updateMetrics(stopwatch.elapsed, results.length);

      return results;
    } catch (e) {
      if (kDebugMode) {
        debugPrint('❌ Batch query execution failed: $e');
      }
      rethrow;
    }
  }

  /// Get cached user profile with automatic refresh
  Future<UserData?> getCachedUserProfile(String uid) async {
    final cacheKey = 'user_profile_$uid';
    
    // Check cache first
    final cached = _cache[cacheKey];
    if (cached != null && !cached.isExpired) {
      return cached.data as UserData?;
    }

    try {
      // Fetch from database with timeout
      final query = _db.collection('users').doc(uid);
      final doc = await query.get().timeout(const Duration(seconds: 3));

      if (doc.exists) {
        final userData = UserData.fromMap(doc.data()!, doc.id);
        
        // Cache the result
        _cacheResult(cacheKey, userData, _defaultCacheTTL);
        
        return userData;
      }
      
      return null;
    } catch (e) {
      if (kDebugMode) {
        debugPrint('❌ Failed to fetch user profile: $e');
      }
      
      // Return expired cache if available as fallback
      return cached?.data as UserData?;
    }
  }

  /// Optimized friend requests query with batching
  Future<Map<String, List<FriendRequest>>> getFriendRequestsOptimized(String uid) async {
    try {
      final futures = await executeBatchQueries(
        queries: [
          _db
              .collection('friend_requests')
              .where('toUserId', isEqualTo: uid)
              .where('status', isEqualTo: 'pending')
              .orderBy('createdAt', descending: true)
              .limit(50),
          _db
              .collection('friend_requests')
              .where('fromUserId', isEqualTo: uid)
              .where('status', isEqualTo: 'pending')
              .orderBy('createdAt', descending: true)
              .limit(50),
        ],
        options: QueryOptions(
          enableCache: true,
          timeout: const Duration(seconds: 5),
        ),
      );

      return {
        'received': futures[0].docs.map((doc) => FriendRequest.fromMap(doc.data())).toList(),
        'sent': futures[1].docs.map((doc) => FriendRequest.fromMap(doc.data())).toList(),
      };
    } catch (e) {
      if (kDebugMode) {
        debugPrint('❌ Failed to fetch friend requests: $e');
      }
      return {'received': [], 'sent': []};
    }
  }

  /// Optimized friends list query
  Future<List<Friend>> getCachedFriendsList(String uid) async {
    final cacheKey = 'friends_list_$uid';
    
    // Check cache first
    final cached = _cache[cacheKey];
    if (cached != null && !cached.isExpired) {
      return cached.data as List<Friend>;
    }

    try {
      final querySnapshot = await _db
          .collection('users')
          .doc(uid)
          .collection('friends')
          .orderBy('addedAt', descending: true)
          .limit(100)
          .get();

      final friends = querySnapshot.docs.map((doc) {
        final data = doc.data();
        return Friend(
          id: data['uid'],
          nickname: data['nickname'],
          addedAt: (data['addedAt'] as Timestamp).toDate(),
        );
      }).toList();

      // Cache the result
      _cacheResult(cacheKey, friends, _defaultCacheTTL);
      
      return friends;
    } catch (e) {
      if (kDebugMode) {
        debugPrint('❌ Failed to fetch friends list: $e');
      }
      
      // Return expired cache if available as fallback
      return cached?.data as List<Friend> ?? [];
    }
  }

  /// Atomic friend request operation with batch
  Future<bool> sendFriendRequestAtomic(String fromUid, String toUid) async {
    try {
      final batch = _db.batch();

      // Create friend request document
      final requestRef = _db.collection('friend_requests').doc();
      batch.set(requestRef, {
        'id': requestRef.id,
        'fromUserId': fromUid,
        'toUserId': toUid,
        'status': 'pending',
        'createdAt': FieldValue.serverTimestamp(),
      });

      // Add notification
      final notificationRef = _db
          .collection('notifications')
          .doc(toUid)
          .collection('notifications')
          .doc();
      
      batch.set(notificationRef, {
        'id': notificationRef.id,
        'type': 'friend_request',
        'title': 'New Friend Request',
        'message': 'Someone sent you a friend request',
        'senderId': fromUid,
        'createdAt': FieldValue.serverTimestamp(),
        'isRead': false,
      });

      // Execute batch with timeout
      await batch.commit().timeout(const Duration(seconds: 10));

      // Invalidate related caches
      _invalidateCachePattern('friend_requests_');
      _invalidateCachePattern('notifications_$toUid');

      return true;
    } catch (e) {
      if (kDebugMode) {
        debugPrint('❌ Failed to send friend request: $e');
      }
      return false;
    }
  }

  /// Background cache cleanup (should be called periodically)
  Future<void> cleanupCache() async {
    try {
      final expiredKeys = <String>[];
      
      for (final entry in _cache.entries) {
        if (entry.value.isExpired) {
          expiredKeys.add(entry.key);
          _currentCacheSize -= entry.value.size;
        }
      }

      for (final key in expiredKeys) {
        _cache.remove(key);
      }

      // If still over size limit, remove oldest entries
      if (_currentCacheSize > _maxCacheSizeBytes) {
        final sortedEntries = _cache.entries.toList()
          ..sort((a, b) => a.value.expiresAt.compareTo(b.value.expiresAt));

        while (_currentCacheSize > _maxCacheSizeBytes && sortedEntries.isNotEmpty) {
          final entry = sortedEntries.removeAt(0);
          _currentCacheSize -= entry.value.size;
          _cache.remove(entry.key);
        }
      }

      if (kDebugMode) {
        debugPrint('🧹 Cache cleanup completed: removed ${expiredKeys.length} expired entries');
      }
    } catch (e) {
      if (kDebugMode) {
        debugPrint('❌ Cache cleanup failed: $e');
      }
    }
  }

  /// Stream with automatic cleanup and error handling
  Stream<List<T>> createOptimizedStream<T>({
    required Query<T> query,
    int? limit,
    bool Function(T)? filter,
  }) {
    try {
      Query<T> streamQuery = query;
      
      if (limit != null) {
        streamQuery = streamQuery.limit(limit);
      }

      return streamQuery.snapshots().map((snapshot) {
        try {
          List<T> documents = snapshot.docs
              .map((doc) => doc.data())
              .where((data) => filter == null || filter(data))
              .toList();

          // Cache frequently accessed data
          if (documents.isNotEmpty && documents.first is UserData) {
            for (final doc in snapshot.docs) {
              if (doc.exists && doc.data() is UserData) {
                final cacheKey = 'user_profile_${doc.id}';
                _cacheResult(cacheKey, doc.data()!, _defaultCacheTTL);
              }
            }
          }

          return documents;
        } catch (e) {
          if (kDebugMode) {
            debugPrint('⚠️ Stream mapping error: $e');
          }
          return <T>[];
        }
      }).handleError((error) {
        if (kDebugMode) {
          debugPrint('🚨 Stream error: $error');
        }
      });
    } catch (e) {
      if (kDebugMode) {
        debugPrint('❌ Stream creation failed: $e');
      }
      return const Stream.empty();
    }
  }

  /// Execute individual optimized query
  Future<QuerySnapshot<T>> _executeOptimizedQuery<T>({
    required Query<T> query,
    QueryOptions options = const QueryOptions(),
  }) async {
    final stopwatch = Stopwatch()..start();

    try {
      // Add selective field retrieval if specified
      Query<T> optimizedQuery = query;
      
      if (options.selectFields != null) {
        // Note: Firestore doesn't support select() on client side
        // This is a placeholder for potential server-side optimization
      }

      if (options.limit != null) {
        optimizedQuery = optimizedQuery.limit(options.limit!);
      }

      // Execute query with timeout
      final result = await optimizedQuery.get().timeout(
        options.timeout ?? const Duration(seconds: 10),
      );

      stopwatch.stop();
      _updateMetrics(stopwatch.elapsed, 1);

      // Track slow queries
      if (stopwatch.elapsed.inMilliseconds > 1000) {
        _slowQueries.add('Query took ${stopwatch.elapsed.inMilliseconds}ms');
        if (kDebugMode) {
          debugPrint('🐌 Slow query detected: ${stopwatch.elapsed.inMilliseconds}ms');
        }
      }

      return result;
    } catch (e) {
      stopwatch.stop();
      if (kDebugMode) {
        debugPrint('❌ Query execution failed: $e');
      }
      rethrow;
    }
  }

  /// Cache result with size management
  void _cacheResult<T>(String key, T data, Duration ttl) {
    try {
      final size = _calculateSize(data);
      final entry = CacheEntry(
        data: data,
        expiresAt: DateTime.now().add(ttl),
        size: size,
      );

      // Remove existing entry if present
      final existing = _cache[key];
      if (existing != null) {
        _currentCacheSize -= existing.size;
      }

      // Add new entry
      _cache[key] = entry;
      _currentCacheSize += size;

      // Evict oldest entries if cache is full
      _evictCacheIfNeeded();
    } catch (e) {
      if (kDebugMode) {
        debugPrint('⚠️ Failed to cache result: $e');
      }
    }
  }

  /// Calculate approximate size of data
  int _calculateSize<T>(T data) {
    try {
      final jsonString = data.toString();
      return jsonString.length * 2; // Rough estimate in bytes
    } catch (e) {
      return 100; // Default size estimate
    }
  }

  /// Evict cache entries if over limits
  void _evictCacheIfNeeded() {
    // Remove expired entries first
    final expiredKeys = _cache.entries
        .where((entry) => entry.value.isExpired)
        .map((entry) => entry.key)
        .toList();

    for (final key in expiredKeys) {
      final entry = _cache[key]!;
      _currentCacheSize -= entry.size;
      _cache.remove(key);
    }

    // If still over size limit, remove oldest entries
    if (_currentCacheSize > _maxCacheSizeBytes || _cache.length > _maxCacheEntries) {
      final sortedEntries = _cache.entries.toList()
        ..sort((a, b) => a.value.expiresAt.compareTo(b.value.expiresAt));

      while ((_currentCacheSize > _maxCacheSizeBytes || _cache.length > _maxCacheEntries) 
             && sortedEntries.isNotEmpty) {
        final entry = sortedEntries.removeAt(0);
        _currentCacheSize -= entry.value.size;
        _cache.remove(entry.key);
      }
    }
  }

  /// Invalidate cache entries matching pattern
  void _invalidateCachePattern(String pattern) {
    final keysToRemove = _cache.keys.where((key) => key.contains(pattern)).toList();
    for (final key in keysToRemove) {
      final entry = _cache[key];
      if (entry != null) {
        _currentCacheSize -= entry.size;
      }
      _cache.remove(key);
    }
  }

  /// Enforce concurrency limit
  Future<void> _enforceConcurrencyLimit() async {
    while (_activeQueries.length >= _maxConcurrentQueries) {
      await Future.wait(_activeQueries);
      _activeQueries.removeAt(0);
    }
  }

  /// Update performance metrics
  void _updateMetrics(Duration duration, int queryCount) {
    _queryCount += queryCount;
    _lastMetrics = DatabaseMetrics(
      totalDuration: Duration(milliseconds: 
        (_lastMetrics?.totalDuration.inMilliseconds ?? 0) + duration.inMilliseconds),
      queryCount: _queryCount,
      bytesRead: _bytesRead,
      bytesWritten: _bytesWritten,
      slowQueries: List.from(_slowQueries),
    );
  }

  /// Get performance metrics
  DatabaseMetrics? get metrics => _lastMetrics;

  /// Get performance recommendations
  List<String> getPerformanceRecommendations() {
    final recommendations = <String>[];
    
    if (_lastMetrics == null) return recommendations;

    final metrics = _lastMetrics!;
    
    if (metrics.queryCount > 100) {
      recommendations.add('📊 High query count detected - consider implementing pagination');
    }
    
    if (metrics.slowQueries.isNotEmpty) {
      recommendations.add('🐌 Slow queries detected - check database indexes');
      recommendations.add('📈 Consider query optimization or caching frequently accessed data');
    }

    if (_cache.length > 500) {
      recommendations.add('🧠 Large cache detected - consider reducing TTL or cache size');
    }

    return recommendations;
  }

  /// Clear all metrics and cache
  void clearMetrics() {
    _lastMetrics = null;
    _queryCount = 0;
    _bytesRead = 0;
    _bytesWritten = 0;
    _slowQueries.clear();
    _cache.clear();
    _currentCacheSize = 0;
  }
}

// Import required models (these would need to be created/imported)
class UserData {
  final String uid;
  final String nickname;
  final String? profilePictureUrl;
  final DateTime? lastLogin;

  UserData({
    required this.uid,
    required this.nickname,
    this.profilePictureUrl,
    this.lastLogin,
  });

  factory UserData.fromMap(Map<String, dynamic> map, String docId) {
    return UserData(
      uid: map['uid'] ?? docId,
      nickname: map['nickname'] ?? '',
      profilePictureUrl: map['profilePictureUrl'],
      lastLogin: map['lastLogin']?.toDate(),
    );
  }
}

class FriendRequest {
  final String id;
  final String fromUserId;
  final String toUserId;
  final String status;
  final DateTime createdAt;

  FriendRequest({
    required this.id,
    required this.fromUserId,
    required this.toUserId,
    required this.status,
    required this.createdAt,
  });

  factory FriendRequest.fromMap(Map<String, dynamic> map) {
    return FriendRequest(
      id: map['id'] ?? '',
      fromUserId: map['fromUserId'] ?? '',
      toUserId: map['toUserId'] ?? '',
      status: map['status'] ?? 'pending',
      createdAt: (map['createdAt'] as Timestamp).toDate(),
    );
  }
}

class Friend {
  final String id;
  final String nickname;
  final DateTime addedAt;

  Friend({
    required this.id,
    required this.nickname,
    required this.addedAt,
  });

  factory Friend.fromMap(Map<String, dynamic> map) {
    return Friend(
      id: map['uid'] ?? '',
      nickname: map['nickname'] ?? '',
      addedAt: (map['addedAt'] as Timestamp).toDate(),
    );
  }
}