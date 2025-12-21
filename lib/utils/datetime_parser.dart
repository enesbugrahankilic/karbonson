// lib/utils/datetime_parser.dart
// Shared utility for parsing datetime values from Firestore

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';

/// Shared utility class for parsing datetime values from Firestore
/// Handles both Timestamp and String types to prevent casting errors
class DateTimeParser {
  /// Parse date/time from both String and Timestamp types
  /// Returns null if parsing fails or value is null
  static DateTime? parse(dynamic value) {
    if (value == null) return null;

    try {
      if (value is Timestamp) {
        return value.toDate();
      } else if (value is String) {
        return DateTime.parse(value);
      } else if (value is int) {
        // Handle Unix timestamp (milliseconds)
        return DateTime.fromMillisecondsSinceEpoch(value);
      }
    } catch (e) {
      if (kDebugMode) {
        debugPrint(
            '⚠️ Error parsing datetime: $e, value: $value, type: ${value.runtimeType}');
      }
    }
    return null;
  }

  /// Convert DateTime to Firestore Timestamp for storage
  static Timestamp? toTimestamp(DateTime? dateTime) {
    if (dateTime == null) return null;
    return Timestamp.fromDate(dateTime);
  }
}
