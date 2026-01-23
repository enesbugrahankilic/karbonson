// lib/models/leaderboard_category.dart
// Model for dynamic leaderboard categories

import 'package:flutter/material.dart';

/// Represents a leaderboard category with its configuration
class LeaderboardCategory {
  final String id;
  final String name;
  final String description;
  final String iconKey;
  final Color color;
  final String sortField;
  final String categoryType;
  final bool isEnabled;
  final int priority; // For ordering categories

  const LeaderboardCategory({
    required this.id,
    required this.name,
    required this.description,
    required this.iconKey,
    required this.color,
    required this.sortField,
    required this.categoryType,
    this.isEnabled = true,
    this.priority = 0,
  });

  /// Get the IconData for this category
  IconData get icon => _getIconFromKey(iconKey);

  /// Convert icon key to IconData
  static IconData _getIconFromKey(String key) {
    switch (key) {
      case 'quiz':
        return Icons.quiz;
      case 'sports_esports':
        return Icons.sports_esports;
      case 'people':
        return Icons.people;
      case 'local_fire_department':
        return Icons.local_fire_department;
      default:
        return Icons.help; // Fallback icon
    }
  }

  /// Create a copy with modified fields
  LeaderboardCategory copyWith({
    String? id,
    String? name,
    String? description,
    String? iconKey,
    Color? color,
    String? sortField,
    String? categoryType,
    bool? isEnabled,
    int? priority,
  }) {
    return LeaderboardCategory(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      iconKey: iconKey ?? this.iconKey,
      color: color ?? this.color,
      sortField: sortField ?? this.sortField,
      categoryType: categoryType ?? this.categoryType,
      isEnabled: isEnabled ?? this.isEnabled,
      priority: priority ?? this.priority,
    );
  }

  /// Convert to JSON for storage
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'icon': iconKey, // Store icon key as string
      'color': color.value, // Store color as int value
      'sortField': sortField,
      'categoryType': categoryType,
      'isEnabled': isEnabled,
      'priority': priority,
    };
  }

  /// Create from JSON
  factory LeaderboardCategory.fromJson(Map<String, dynamic> json) {
    return LeaderboardCategory(
      id: json['id'] as String,
      name: json['name'] as String,
      description: json['description'] as String,
      iconKey: json['icon'] as String,
      color: Color(json['color'] as int),
      sortField: json['sortField'] as String,
      categoryType: json['categoryType'] as String,
      isEnabled: json['isEnabled'] as bool? ?? true,
      priority: json['priority'] as int? ?? 0,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is LeaderboardCategory && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
}