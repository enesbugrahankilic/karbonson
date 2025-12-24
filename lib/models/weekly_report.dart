// lib/models/weekly_report.dart
// Haftalık rapor modeli

/// Haftalık rapor verisi
class WeeklyReport {
  final String userId;
  final int totalTasks;
  final int completedTasks;
  final int missedTasks;
  final int currentStreak;
  final int longestStreak;
  final double completionRate;
  final List<String> completedCategories;
  final DateTime weekStartDate;
  final DateTime weekEndDate;

  WeeklyReport({
    required this.userId,
    required this.totalTasks,
    required this.completedTasks,
    required this.missedTasks,
    required this.currentStreak,
    required this.longestStreak,
    required this.completionRate,
    required this.completedCategories,
    required this.weekStartDate,
    required this.weekEndDate,
  });

  Map<String, dynamic> toMap() {
    return {
      'userId': userId,
      'totalTasks': totalTasks,
      'completedTasks': completedTasks,
      'missedTasks': missedTasks,
      'currentStreak': currentStreak,
      'longestStreak': longestStreak,
      'completionRate': completionRate,
      'completedCategories': completedCategories,
      'weekStartDate': weekStartDate.millisecondsSinceEpoch,
      'weekEndDate': weekEndDate.millisecondsSinceEpoch,
    };
  }

  factory WeeklyReport.fromMap(Map<String, dynamic> map) {
    return WeeklyReport(
      userId: map['userId'] ?? '',
      totalTasks: map['totalTasks'] ?? 0,
      completedTasks: map['completedTasks'] ?? 0,
      missedTasks: map['missedTasks'] ?? 0,
      currentStreak: map['currentStreak'] ?? 0,
      longestStreak: map['longestStreak'] ?? 0,
      completionRate: (map['completionRate'] ?? 0).toDouble(),
      completedCategories: List<String>.from(map['completedCategories'] ?? []),
      weekStartDate: DateTime.fromMillisecondsSinceEpoch(map['weekStartDate'] ?? 0),
      weekEndDate: DateTime.fromMillisecondsSinceEpoch(map['weekEndDate'] ?? 0),
    );
  }

  @override
  String toString() {
    return 'WeeklyReport{userId: $userId, completed: $completedTasks/$totalTasks, streak: $currentStreak}';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is WeeklyReport && 
           other.userId == userId && 
           other.weekStartDate == weekStartDate &&
           other.weekEndDate == weekEndDate;
  }

  @override
  int get hashCode => userId.hashCode ^ weekStartDate.hashCode ^ weekEndDate.hashCode;
}