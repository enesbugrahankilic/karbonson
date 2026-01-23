// lib/services/leaderboard_category_service.dart
// Service for managing dynamic leaderboard categories

import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/leaderboard_category.dart';

class LeaderboardCategoryService {
  static const String _categoriesKey = 'leaderboard_categories';

  /// Default categories - can be overridden by stored configuration
  final List<LeaderboardCategory> _defaultCategories = [
    LeaderboardCategory(
      id: 'quiz_masters',
      name: 'Quiz Uzmanları',
      description: 'En çok quiz tamamlayanlar',
      iconKey: 'quiz',
      color: Colors.blue,
      sortField: 'quizCount',
      categoryType: 'quiz',
      priority: 1,
    ),
    LeaderboardCategory(
      id: 'duel_champions',
      name: 'Düello Şampiyonları',
      description: 'En çok düello kazananlar',
      iconKey: 'sports_esports',
      color: Colors.red,
      sortField: 'duelWins',
      categoryType: 'duel',
      priority: 2,
    ),
    LeaderboardCategory(
      id: 'social_butterflies',
      name: 'Sosyal Kelebekler',
      description: 'En çok arkadaş edinenler',
      iconKey: 'people',
      color: Colors.green,
      sortField: 'friendCount',
      categoryType: 'social',
      priority: 3,
    ),
    LeaderboardCategory(
      id: 'streak_kings',
      name: 'Seri Kralları',
      description: 'En uzun seri yakalayanlar',
      iconKey: 'local_fire_department',
      color: Colors.orange,
      sortField: 'longestStreak',
      categoryType: 'streak',
      priority: 4,
    ),
  ];

  /// Get all enabled categories, sorted by priority
  Future<List<LeaderboardCategory>> getEnabledCategories() async {
    final categories = await getAllCategories();
    return categories
        .where((category) => category.isEnabled)
        .toList()
      ..sort((a, b) => a.priority.compareTo(b.priority));
  }

  /// Get all categories (enabled and disabled)
  Future<List<LeaderboardCategory>> getAllCategories() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final stored = prefs.getString(_categoriesKey);
      if (stored != null) {
        final List<dynamic> jsonList = json.decode(stored);
        final categories = jsonList
            .map((json) => LeaderboardCategory.fromJson(json))
            .toList();
        // Merge with defaults to ensure all categories exist
        return _mergeWithDefaults(categories);
      }
    } catch (e) {
      // If loading fails, return defaults
    }
    return _defaultCategories;
  }

  /// Save categories configuration
  Future<void> saveCategories(List<LeaderboardCategory> categories) async {
    final prefs = await SharedPreferences.getInstance();
    final jsonList = categories.map((cat) => cat.toJson()).toList();
    await prefs.setString(_categoriesKey, json.encode(jsonList));
  }

  /// Reset to default categories
  Future<void> resetToDefaults() async {
    await saveCategories(_defaultCategories);
  }

  /// Enable/disable a category
  Future<void> setCategoryEnabled(String categoryId, bool enabled) async {
    final categories = await getAllCategories();
    final updatedCategories = categories.map((cat) {
      if (cat.id == categoryId) {
        return cat.copyWith(isEnabled: enabled);
      }
      return cat;
    }).toList();
    await saveCategories(updatedCategories);
  }

  /// Update category priority
  Future<void> updateCategoryPriority(String categoryId, int priority) async {
    final categories = await getAllCategories();
    final updatedCategories = categories.map((cat) {
      if (cat.id == categoryId) {
        return cat.copyWith(priority: priority);
      }
      return cat;
    }).toList();
    await saveCategories(updatedCategories);
  }

  /// Get category by ID
  Future<LeaderboardCategory?> getCategoryById(String id) async {
    final categories = await getAllCategories();
    return categories.where((cat) => cat.id == id).firstOrNull;
  }

  /// Add a new custom category
  Future<void> addCategory(LeaderboardCategory category) async {
    final categories = await getAllCategories();
    // Check if category with same ID already exists
    if (categories.any((cat) => cat.id == category.id)) {
      throw Exception('Category with ID ${category.id} already exists');
    }
    categories.add(category);
    await saveCategories(categories);
  }

  /// Remove a category
  Future<void> removeCategory(String categoryId) async {
    final categories = await getAllCategories();
    // Don't allow removing default categories
    if (_defaultCategories.any((cat) => cat.id == categoryId)) {
      throw Exception('Cannot remove default category: $categoryId');
    }
    categories.removeWhere((cat) => cat.id == categoryId);
    await saveCategories(categories);
  }

  /// Merge stored categories with defaults to ensure all defaults exist
  List<LeaderboardCategory> _mergeWithDefaults(List<LeaderboardCategory> stored) {
    final merged = List<LeaderboardCategory>.from(stored);

    for (final defaultCat in _defaultCategories) {
      if (!merged.any((cat) => cat.id == defaultCat.id)) {
        merged.add(defaultCat);
      }
    }

    return merged;
  }

  /// Get categories for multiplayer lobby display (limited number)
  Future<List<LeaderboardCategory>> getLobbyCategories({int limit = 4}) async {
    final enabled = await getEnabledCategories();
    return enabled.take(limit).toList();
  }
}