// lib/models/carbon_footprint_data.dart
// Carbon Footprint Data Model - Class/Section based carbon measurement

import 'package:cloud_firestore/cloud_firestore.dart';

/// Valid class levels in the school system
enum ClassLevel { nine, ten, eleven, twelve }

/// Class section identifiers
enum ClassSection { A, B, C, D, E, F }

/// Location orientation
enum ClassOrientation { north, south }

/// Main Carbon Footprint Data Model
/// Maps to Firestore collection: carbon_footprints
class CarbonFootprintData {
  final String id; // Document ID (can be class identifier like "9A", "10F")
  final int classLevel; // 9, 10, 11, 12
  final String classSection; // A, B, C, D, E, F
  final ClassOrientation classOrientation; // north or south
  final bool hasPlants; // true only for grades 9-10
  final int carbonValue; // 400-4000 range
  final DateTime? measuredAt;
  final DateTime? updatedAt;
  final bool isActive;

  const CarbonFootprintData({
    required this.id,
    required this.classLevel,
    required this.classSection,
    required this.classOrientation,
    required this.hasPlants,
    required this.carbonValue,
    this.measuredAt,
    this.updatedAt,
    this.isActive = true,
  });

  /// Class identifier like "9A", "10F", etc.
  String get classIdentifier => '${classLevel}$classSection';

  /// Validate class level and section combination
  bool isValidClassSection() {
    if (classLevel == 9) {
      return ['A', 'B', 'C', 'D'].contains(classSection);
    } else if (classLevel >= 10 && classLevel <= 12) {
      return ['A', 'B', 'C', 'D', 'E', 'F'].contains(classSection);
    }
    return false;
  }

  /// Validate carbon value is within acceptable range
  bool isValidCarbonValue() => carbonValue >= 400 && carbonValue <= 4000;

  /// Validate hasPlants is only true for grades 9-10
  bool isValidPlantStatus() {
    if (classLevel >= 11) {
      return !hasPlants;
    }
    return true;
  }

  /// Check if all validation rules pass
  bool isValid() {
    return isValidClassSection() && isValidCarbonValue() && isValidPlantStatus();
  }

  /// Convert to Firestore document
  Map<String, dynamic> toFirestore() {
    return {
      'classLevel': classLevel,
      'classSection': classSection,
      'classOrientation': classOrientation.name,
      'hasPlants': hasPlants,
      'carbonValue': carbonValue,
      'measuredAt': measuredAt?.toIso8601String() ?? DateTime.now().toIso8601String(),
      'updatedAt': updatedAt?.toIso8601String() ?? DateTime.now().toIso8601String(),
      'isActive': isActive,
    };
  }

  /// Create from Firestore document
  factory CarbonFootprintData.fromFirestore(
    DocumentSnapshot doc,
  ) {
    final data = doc.data() as Map<String, dynamic>;
    return CarbonFootprintData(
      id: doc.id,
      classLevel: data['classLevel'] as int? ?? 9,
      classSection: data['classSection'] as String? ?? 'A',
      classOrientation: (data['classOrientation'] as String? ?? 'south') == 'north'
          ? ClassOrientation.north
          : ClassOrientation.south,
      hasPlants: data['hasPlants'] as bool? ?? false,
      carbonValue: data['carbonValue'] as int? ?? 500,
      measuredAt: data['measuredAt'] != null ? DateTime.parse(data['measuredAt'] as String) : null,
      updatedAt: data['updatedAt'] != null ? DateTime.parse(data['updatedAt'] as String) : null,
      isActive: data['isActive'] as bool? ?? true,
    );
  }

  factory CarbonFootprintData.fromMap(Map<String, dynamic> data) {
    return CarbonFootprintData(
      id: data['id'] as String? ?? '',
      classLevel: data['classLevel'] as int? ?? 9,
      classSection: data['classSection'] as String? ?? 'A',
      classOrientation: (data['classOrientation'] as String? ?? 'south') == 'north'
          ? ClassOrientation.north
          : ClassOrientation.south,
      hasPlants: data['hasPlants'] as bool? ?? false,
      carbonValue: data['carbonValue'] as int? ?? 500,
      measuredAt: data['measuredAt'] != null ? DateTime.parse(data['measuredAt'] as String) : null,
      updatedAt: data['updatedAt'] != null ? DateTime.parse(data['updatedAt'] as String) : null,
      isActive: data['isActive'] as bool? ?? true,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'classLevel': classLevel,
      'classSection': classSection,
      'classOrientation': classOrientation.name,
      'hasPlants': hasPlants,
      'carbonValue': carbonValue,
      'measuredAt': measuredAt?.toIso8601String(),
      'updatedAt': updatedAt?.toIso8601String(),
      'isActive': isActive,
    };
  }

  CarbonFootprintData copyWith({
    String? id,
    int? classLevel,
    String? classSection,
    ClassOrientation? classOrientation,
    bool? hasPlants,
    int? carbonValue,
    DateTime? measuredAt,
    DateTime? updatedAt,
    bool? isActive,
  }) {
    return CarbonFootprintData(
      id: id ?? this.id,
      classLevel: classLevel ?? this.classLevel,
      classSection: classSection ?? this.classSection,
      classOrientation: classOrientation ?? this.classOrientation,
      hasPlants: hasPlants ?? this.hasPlants,
      carbonValue: carbonValue ?? this.carbonValue,
      measuredAt: measuredAt ?? this.measuredAt,
      updatedAt: updatedAt ?? this.updatedAt,
      isActive: isActive ?? this.isActive,
    );
  }

  @override
  String toString() => 'CarbonFootprintData(id: $id, classIdentifier: $classIdentifier, carbonValue: $carbonValue)';

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is CarbonFootprintData &&
          runtimeType == other.runtimeType &&
          id == other.id &&
          classLevel == other.classLevel &&
          classSection == other.classSection &&
          carbonValue == other.carbonValue;

  @override
  int get hashCode =>
      id.hashCode ^ classLevel.hashCode ^ classSection.hashCode ^ carbonValue.hashCode;
}

/// Carbon Report Data - for displaying reports
class CarbonReport {
  final CarbonFootprintData carbonData;
  final double percentage; // percentage of total carbon
  final int? averageCarbonForClassLevel;
  final int? averageCarbonForClassSection;
  final bool isAboveAverage;

  const CarbonReport({
    required this.carbonData,
    required this.percentage,
    this.averageCarbonForClassLevel,
    this.averageCarbonForClassSection,
    this.isAboveAverage = false,
  });

  factory CarbonReport.fromData(
    CarbonFootprintData data, {
    required double percentage,
    int? averageClassLevel,
    int? averageClassSection,
  }) {
    final avg = averageClassLevel ?? 0;
    return CarbonReport(
      carbonData: data,
      percentage: percentage,
      averageCarbonForClassLevel: averageClassLevel,
      averageCarbonForClassSection: averageClassSection,
      isAboveAverage: data.carbonValue > avg,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'carbonData': carbonData.toMap(),
      'percentage': percentage,
      'averageCarbonForClassLevel': averageCarbonForClassLevel,
      'averageCarbonForClassSection': averageCarbonForClassSection,
      'isAboveAverage': isAboveAverage,
    };
  }
}

/// Statistics for carbon data grouping
class CarbonStatistics {
  final List<CarbonFootprintData> allData;
  final double totalCarbon;
  final double averageCarbon;
  final int maxCarbon;
  final int minCarbon;

  const CarbonStatistics({
    required this.allData,
    required this.totalCarbon,
    required this.averageCarbon,
    required this.maxCarbon,
    required this.minCarbon,
  });

  factory CarbonStatistics.fromList(List<CarbonFootprintData> data) {
    if (data.isEmpty) {
      return const CarbonStatistics(
        allData: [],
        totalCarbon: 0,
        averageCarbon: 0,
        maxCarbon: 0,
        minCarbon: 0,
      );
    }

    final total = data.fold<int>(0, (sum, item) => sum + item.carbonValue);
    final average = total / data.length;
    final max = data.map((e) => e.carbonValue).reduce((a, b) => a > b ? a : b);
    final min = data.map((e) => e.carbonValue).reduce((a, b) => a < b ? a : b);

    return CarbonStatistics(
      allData: data,
      totalCarbon: total.toDouble(),
      averageCarbon: average,
      maxCarbon: max,
      minCarbon: min,
    );
  }
}
