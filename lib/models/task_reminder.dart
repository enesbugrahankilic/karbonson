// lib/models/task_reminder.dart
// SMS Reminder sistemi için veri modelleri

import 'package:cloud_firestore/cloud_firestore.dart';

/// Görev durumları
enum TaskStatus {
  pending, // Görev beklemede
  completed, // Görev tamamlandı
  missed, // Görev kaçırıldı
  snoozed, // Görev ertelendi
}

/// Hatırlatma türleri
enum ReminderType {
  daily, // Günlük hatırlatma
  weekly, // Haftalık hatırlatma
  streak, // Seri hatırlatması
  missed, // Kaçırılan görev hatırlatması
  weeklyReport, // Haftalık rapor
}

/// Günlük görev modeli
class TaskReminder {
  final String id;
  final String userId;
  final String title;
  final String description;
  final String category;
  final DateTime scheduledTime;
  final TaskStatus status;
  final ReminderType reminderType;
  final bool isRecurring;
  final int streakCount;
  final DateTime createdAt;
  final DateTime? completedAt;
  final DateTime? snoozedUntil;
  final String? notes;

  TaskReminder({
    required this.id,
    required this.userId,
    required this.title,
    required this.description,
    required this.category,
    required this.scheduledTime,
    required this.status,
    required this.reminderType,
    this.isRecurring = false,
    this.streakCount = 0,
    required this.createdAt,
    this.completedAt,
    this.snoozedUntil,
    this.notes,
  });

  /// Firestore'dan map oluştur
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'userId': userId,
      'title': title,
      'description': description,
      'category': category,
      'scheduledTime': scheduledTime.millisecondsSinceEpoch,
      'status': status.name,
      'reminderType': reminderType.name,
      'isRecurring': isRecurring,
      'streakCount': streakCount,
      'createdAt': createdAt.millisecondsSinceEpoch,
      'completedAt': completedAt?.millisecondsSinceEpoch,
      'snoozedUntil': snoozedUntil?.millisecondsSinceEpoch,
      'notes': notes,
    };
  }

  /// Firestore'dan model oluştur
  factory TaskReminder.fromMap(Map<String, dynamic> map) {
    return TaskReminder(
      id: map['id'] ?? '',
      userId: map['userId'] ?? '',
      title: map['title'] ?? '',
      description: map['description'] ?? '',
      category: map['category'] ?? '',
      scheduledTime: DateTime.fromMillisecondsSinceEpoch(map['scheduledTime'] ?? 0),
      status: TaskStatus.values.firstWhere(
        (e) => e.name == map['status'],
        orElse: () => TaskStatus.pending,
      ),
      reminderType: ReminderType.values.firstWhere(
        (e) => e.name == map['reminderType'],
        orElse: () => ReminderType.daily,
      ),
      isRecurring: map['isRecurring'] ?? false,
      streakCount: map['streakCount'] ?? 0,
      createdAt: DateTime.fromMillisecondsSinceEpoch(map['createdAt'] ?? 0),
      completedAt: map['completedAt'] != null
          ? DateTime.fromMillisecondsSinceEpoch(map['completedAt'])
          : null,
      snoozedUntil: map['snoozedUntil'] != null
          ? DateTime.fromMillisecondsSinceEpoch(map['snoozedUntil'])
          : null,
      notes: map['notes'],
    );
  }

  /// Görev tamamlandı mı?
  bool get isCompleted => status == TaskStatus.completed;

  /// Görev kaçırıldı mı?
  bool get isMissed => status == TaskStatus.missed;

  /// Görev ertelendi mi?
  bool get isSnoozed => status == TaskStatus.snoozed;

  /// Yeni bir görev örneği oluştur (kopyalama için)
  TaskReminder copyWith({
    String? id,
    String? userId,
    String? title,
    String? description,
    String? category,
    DateTime? scheduledTime,
    TaskStatus? status,
    ReminderType? reminderType,
    bool? isRecurring,
    int? streakCount,
    DateTime? createdAt,
    DateTime? completedAt,
    DateTime? snoozedUntil,
    String? notes,
  }) {
    return TaskReminder(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      title: title ?? this.title,
      description: description ?? this.description,
      category: category ?? this.category,
      scheduledTime: scheduledTime ?? this.scheduledTime,
      status: status ?? this.status,
      reminderType: reminderType ?? this.reminderType,
      isRecurring: isRecurring ?? this.isRecurring,
      streakCount: streakCount ?? this.streakCount,
      createdAt: createdAt ?? this.createdAt,
      completedAt: completedAt ?? this.completedAt,
      snoozedUntil: snoozedUntil ?? this.snoozedUntil,
      notes: notes ?? this.notes,
    );
  }

  @override
  String toString() {
    return 'TaskReminder{id: $id, title: $title, status: $status, scheduledTime: $scheduledTime}';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is TaskReminder && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
}