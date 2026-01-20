// lib/utils/datetime_parser.dart
// Shared utility for parsing datetime values from Firestore

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../l10n/app_localizations.dart';

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

  /// Format relative time (e.g., "5 minutes ago", "Just now")
  /// Returns a localized string representation
  static String formatRelativeTime(DateTime dateTime, BuildContext context) {
    final l10n = AppLocalizations.of(context);
    if (l10n == null) return 'Unknown time';

    final now = DateTime.now();
    final difference = now.difference(dateTime);

    if (difference.inSeconds < 60) {
      return l10n.justNow;
    } else if (difference.inMinutes < 60) {
      final minutes = difference.inMinutes;
      return minutes == 1 ? '1 ${l10n.minutesAgo.replaceFirst('minutes', 'minute')}' : '$minutes ${l10n.minutesAgo}';
    } else if (difference.inHours < 24) {
      final hours = difference.inHours;
      return hours == 1 ? '1 ${l10n.hoursAgo.replaceFirst('hours', 'hour')}' : '$hours ${l10n.hoursAgo}';
    } else if (difference.inDays < 7) {
      final days = difference.inDays;
      return days == 1 ? '1 ${l10n.daysAgo.replaceFirst('days', 'day')}' : '$days ${l10n.daysAgo}';
    } else {
      // Format as date for older items
      final locale = Localizations.localeOf(context);
      final formatter = DateFormat('MMM d, yyyy', locale.languageCode);
      return formatter.format(dateTime);
    }
  }
}
