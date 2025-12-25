// lib/models/user_preferences.dart
// SMS Reminder sistemi için kullanıcı tercihleri modeli


/// Zamanı parse etmek için yardımcı sınıf
class TimeOfDay {
  final int hour;
  final int minute;

  const TimeOfDay({required this.hour, required this.minute});

  @override
  String toString() {
    return '${hour.toString().padLeft(2, '0')}:${minute.toString().padLeft(2, '0')}';
  }

  /// String'den TimeOfDay oluştur
  factory TimeOfDay.fromString(String timeStr) {
    final parts = timeStr.split(':');
    if (parts.length != 2) {
      throw FormatException('Invalid time format: $timeStr');
    }
    return TimeOfDay(
      hour: int.parse(parts[0]),
      minute: int.parse(parts[1]),
    );
  }

  /// TimeOfDay'i DateTime'e dönüştür
  DateTime toDateTime({DateTime? baseDate}) {
    final date = baseDate ?? DateTime.now();
    return DateTime(date.year, date.month, date.day, hour, minute);
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is TimeOfDay && other.hour == hour && other.minute == minute;
  }

  @override
  int get hashCode => hour.hashCode ^ minute.hashCode;
}

/// SMS bildirim tercihleri
class UserPreferences {
  final String userId;
  final bool smsNotificationsEnabled;
  final bool dailyRemindersEnabled;
  final bool weeklyReportsEnabled;
  final bool streakRemindersEnabled;
  final TimeOfDay? preferredReminderTime;
  final List<String> reminderCategories;
  final int snoozeDuration; // dakika cinsinden
  final bool weekendReminders;
  final bool missedTaskReminders;
  final String language; // tr, en vs.
  final DateTime createdAt;
  final DateTime updatedAt;

  UserPreferences({
    required this.userId,
    this.smsNotificationsEnabled = true,
    this.dailyRemindersEnabled = true,
    this.weeklyReportsEnabled = true,
    this.streakRemindersEnabled = true,
    this.preferredReminderTime,
    this.reminderCategories = const [],
    this.snoozeDuration = 30, // 30 dakika varsayılan
    this.weekendReminders = false,
    this.missedTaskReminders = true,
    this.language = 'tr',
    required this.createdAt,
    required this.updatedAt,
  });

  /// Firestore'dan map oluştur
  Map<String, dynamic> toMap() {
    return {
      'userId': userId,
      'smsNotificationsEnabled': smsNotificationsEnabled,
      'dailyRemindersEnabled': dailyRemindersEnabled,
      'weeklyReportsEnabled': weeklyReportsEnabled,
      'streakRemindersEnabled': streakRemindersEnabled,
      'preferredReminderTime': preferredReminderTime != null
          ? '${preferredReminderTime!.hour.toString().padLeft(2, '0')}:${preferredReminderTime!.minute.toString().padLeft(2, '0')}'
          : null,
      'reminderCategories': reminderCategories,
      'snoozeDuration': snoozeDuration,
      'weekendReminders': weekendReminders,
      'missedTaskReminders': missedTaskReminders,
      'language': language,
      'createdAt': createdAt.millisecondsSinceEpoch,
      'updatedAt': updatedAt.millisecondsSinceEpoch,
    };
  }

  /// Firestore'dan model oluştur
  factory UserPreferences.fromMap(Map<String, dynamic> map) {
    TimeOfDay? parseTimeOfDay(String? timeStr) {
      if (timeStr == null) return null;
      final parts = timeStr.split(':');
      if (parts.length != 2) return null;
      return TimeOfDay(
        hour: int.parse(parts[0]),
        minute: int.parse(parts[1]),
      );
    }

    return UserPreferences(
      userId: map['userId'] ?? '',
      smsNotificationsEnabled: map['smsNotificationsEnabled'] ?? true,
      dailyRemindersEnabled: map['dailyRemindersEnabled'] ?? true,
      weeklyReportsEnabled: map['weeklyReportsEnabled'] ?? true,
      streakRemindersEnabled: map['streakRemindersEnabled'] ?? true,
      preferredReminderTime: parseTimeOfDay(map['preferredReminderTime']),
      reminderCategories: List<String>.from(map['reminderCategories'] ?? []),
      snoozeDuration: map['snoozeDuration'] ?? 30,
      weekendReminders: map['weekendReminders'] ?? false,
      missedTaskReminders: map['missedTaskReminders'] ?? true,
      language: map['language'] ?? 'tr',
      createdAt: DateTime.fromMillisecondsSinceEpoch(map['createdAt'] ?? 0),
      updatedAt: DateTime.fromMillisecondsSinceEpoch(map['updatedAt'] ?? 0),
    );
  }

  /// Tercihleri güncelle
  UserPreferences copyWith({
    String? userId,
    bool? smsNotificationsEnabled,
    bool? dailyRemindersEnabled,
    bool? weeklyReportsEnabled,
    bool? streakRemindersEnabled,
    TimeOfDay? preferredReminderTime,
    List<String>? reminderCategories,
    int? snoozeDuration,
    bool? weekendReminders,
    bool? missedTaskReminders,
    String? language,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return UserPreferences(
      userId: userId ?? this.userId,
      smsNotificationsEnabled: smsNotificationsEnabled ?? this.smsNotificationsEnabled,
      dailyRemindersEnabled: dailyRemindersEnabled ?? this.dailyRemindersEnabled,
      weeklyReportsEnabled: weeklyReportsEnabled ?? this.weeklyReportsEnabled,
      streakRemindersEnabled: streakRemindersEnabled ?? this.streakRemindersEnabled,
      preferredReminderTime: preferredReminderTime ?? this.preferredReminderTime,
      reminderCategories: reminderCategories ?? this.reminderCategories,
      snoozeDuration: snoozeDuration ?? this.snoozeDuration,
      weekendReminders: weekendReminders ?? this.weekendReminders,
      missedTaskReminders: missedTaskReminders ?? this.missedTaskReminders,
      language: language ?? this.language,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  String toString() {
    return 'UserPreferences{userId: $userId, smsEnabled: $smsNotificationsEnabled, reminderTime: $preferredReminderTime}';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is UserPreferences && other.userId == userId;
  }

  @override
  int get hashCode => userId.hashCode;
}