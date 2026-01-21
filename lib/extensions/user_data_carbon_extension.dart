// lib/extensions/user_data_carbon_extension.dart
// UserData Extension - Carbon footprint related utilities

import 'package:karbonson/models/user_data.dart';
import 'package:karbonson/models/carbon_footprint_data.dart';

extension UserDataCarbonExtension on UserData {
  /// Validate if user has selected a valid class
  bool hasValidClassSelection() {
    if (classLevel == null || classSection == null) {
      return false;
    }
    
    // Validate class level
    if (classLevel! < 9 || classLevel! > 12) {
      return false;
    }
    
    // Validate section based on class level
    if (classLevel == 9) {
      return ['A', 'B', 'C', 'D'].contains(classSection);
    } else {
      return ['A', 'B', 'C', 'D', 'E', 'F'].contains(classSection);
    }
  }

  /// Get valid sections for this user's class level
  List<String> getValidSections() {
    if (classLevel == null) return [];
    
    if (classLevel == 9) {
      return ['A', 'B', 'C', 'D'];
    } else if (classLevel! >= 10 && classLevel! <= 12) {
      return ['A', 'B', 'C', 'D', 'E', 'F'];
    }
    
    return [];
  }

  /// Get class identifier string
  String? getClassIdentifier() {
    if (classLevel == null || classSection == null) {
      return null;
    }
    return '$classLevel$classSection';
  }

  /// Check if class level allows plants
  bool classLevelAllowsPlants() {
    return classLevel != null && classLevel! <= 10;
  }

  /// Get user-friendly class name
  String getClassDisplayName() {
    if (classLevel == null || classSection == null) {
      return 'Sınıf Seçilmedi';
    }
    
    final levelName = {
      9: 'Dokuzuncu',
      10: 'Onuncu',
      11: 'On Birinci',
      12: 'On İkinci',
    }[classLevel];
    
    return '$levelName Sınıf $classSection Şubesi';
  }
}
