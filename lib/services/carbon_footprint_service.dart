// lib/services/carbon_footprint_service.dart
// Carbon Footprint Service - Firebase integration and data management

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:karbonson/models/carbon_footprint_data.dart';

class CarbonFootprintService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  static const String _collection = 'carbon_footprints';
  static const String _seedDataCollection = 'carbon_seed_data';

  /// Get carbon data for a specific class
  Future<CarbonFootprintData?> getCarbonDataByClass(
    int classLevel,
    String classSection,
  ) async {
    try {
      final docId = '${classLevel}$classSection';
      final doc = await _firestore.collection(_collection).doc(docId).get();

      if (doc.exists) {
        return CarbonFootprintData.fromFirestore(doc);
      }

      // If not found in main collection, check seed data
      return await _getCarbonDataFromSeedData(classLevel, classSection);
    } catch (e) {
      print('Error getting carbon data: $e');
      rethrow;
    }
  }

  /// Get all carbon data for a specific class level
  Future<List<CarbonFootprintData>> getCarbonDataByClassLevel(int classLevel) async {
    try {
      final query = await _firestore
          .collection(_collection)
          .where('classLevel', isEqualTo: classLevel)
          .where('isActive', isEqualTo: true)
          .get();

      if (query.docs.isNotEmpty) {
        return query.docs.map((doc) => CarbonFootprintData.fromFirestore(doc)).toList();
      }

      // Fallback to seed data
      return await _getCarbonDataFromSeedDataByLevel(classLevel);
    } catch (e) {
      print('Error getting carbon data by class level: $e');
      rethrow;
    }
  }

  /// Get all carbon data for a specific class section
  Future<List<CarbonFootprintData>> getCarbonDataByClassSection(String classSection) async {
    try {
      final query = await _firestore
          .collection(_collection)
          .where('classSection', isEqualTo: classSection)
          .where('isActive', isEqualTo: true)
          .get();

      return query.docs.map((doc) => CarbonFootprintData.fromFirestore(doc)).toList();
    } catch (e) {
      print('Error getting carbon data by class section: $e');
      rethrow;
    }
  }

  /// Get all carbon data
  Future<List<CarbonFootprintData>> getAllCarbonData() async {
    try {
      final query = await _firestore
          .collection(_collection)
          .where('isActive', isEqualTo: true)
          .get();

      if (query.docs.isNotEmpty) {
        return query.docs.map((doc) => CarbonFootprintData.fromFirestore(doc)).toList();
      }

      // Fallback to seed data
      return await _getAllSeedCarbonData();
    } catch (e) {
      print('Error getting all carbon data: $e');
      rethrow;
    }
  }

  /// Get carbon data filtered by plants
  Future<List<CarbonFootprintData>> getCarbonDataByPlantStatus(bool hasPlants) async {
    try {
      final query = await _firestore
          .collection(_collection)
          .where('hasPlants', isEqualTo: hasPlants)
          .where('isActive', isEqualTo: true)
          .get();

      return query.docs.map((doc) => CarbonFootprintData.fromFirestore(doc)).toList();
    } catch (e) {
      print('Error getting carbon data by plant status: $e');
      rethrow;
    }
  }

  /// Get carbon data filtered by orientation
  Future<List<CarbonFootprintData>> getCarbonDataByOrientation(
    String orientation, // 'north' or 'south'
  ) async {
    try {
      final query = await _firestore
          .collection(_collection)
          .where('classOrientation', isEqualTo: orientation)
          .where('isActive', isEqualTo: true)
          .get();

      return query.docs.map((doc) => CarbonFootprintData.fromFirestore(doc)).toList();
    } catch (e) {
      print('Error getting carbon data by orientation: $e');
      rethrow;
    }
  }

  /// Calculate average carbon for a class level
  Future<int> getAverageCarbonForClassLevel(int classLevel) async {
    try {
      final data = await getCarbonDataByClassLevel(classLevel);
      if (data.isEmpty) return 0;

      final sum = data.fold<int>(0, (total, item) => total + item.carbonValue);
      return (sum / data.length).toInt();
    } catch (e) {
      print('Error calculating average carbon for class level: $e');
      rethrow;
    }
  }

  /// Calculate average carbon for a class section
  Future<int> getAverageCarbonForClassSection(String classSection) async {
    try {
      final data = await getCarbonDataByClassSection(classSection);
      if (data.isEmpty) return 0;

      final sum = data.fold<int>(0, (total, item) => total + item.carbonValue);
      return (sum / data.length).toInt();
    } catch (e) {
      print('Error calculating average carbon for class section: $e');
      rethrow;
    }
  }

  /// Get carbon statistics
  Future<CarbonStatistics> getCarbonStatistics() async {
    try {
      final allData = await getAllCarbonData();
      return CarbonStatistics.fromList(allData);
    } catch (e) {
      print('Error getting carbon statistics: $e');
      rethrow;
    }
  }

  /// Create or update carbon data
  Future<void> setCarbonData(CarbonFootprintData data) async {
    try {
      if (!data.isValid()) {
        throw Exception('Invalid carbon data: Validation failed');
      }

      await _firestore.collection(_collection).doc(data.id).set(data.toFirestore());
    } catch (e) {
      print('Error setting carbon data: $e');
      rethrow;
    }
  }

  /// Update specific carbon data fields
  Future<void> updateCarbonData(
    String classIdentifier,
    Map<String, dynamic> updates,
  ) async {
    try {
      await _firestore.collection(_collection).doc(classIdentifier).update({
        ...updates,
        'updatedAt': DateTime.now().toIso8601String(),
      });
    } catch (e) {
      print('Error updating carbon data: $e');
      rethrow;
    }
  }

  /// Delete carbon data
  Future<void> deleteCarbonData(String classIdentifier) async {
    try {
      await _firestore.collection(_collection).doc(classIdentifier).delete();
    } catch (e) {
      print('Error deleting carbon data: $e');
      rethrow;
    }
  }

  /// Initialize seed data (run once for development/testing)
  Future<void> initializeSeedData() async {
    try {
      final seedData = _generateSeedData();

      for (var data in seedData) {
        if (data.isValid()) {
          await setCarbonData(data);
        }
      }

      print('Seed data initialized: ${seedData.length} records');
    } catch (e) {
      print('Error initializing seed data: $e');
      rethrow;
    }
  }

  /// Check if carbon data exists
  Future<bool> carbonDataExists(int classLevel, String classSection) async {
    try {
      final data = await getCarbonDataByClass(classLevel, classSection);
      return data != null;
    } catch (e) {
      print('Error checking carbon data existence: $e');
      return false;
    }
  }

  /// Generate seed data (example data for development)
  List<CarbonFootprintData> _generateSeedData() {
    return [
      // Grade 9 - with plants
      CarbonFootprintData(
        id: '9A',
        classLevel: 9,
        classSection: 'A',
        classOrientation: ClassOrientation.south,
        hasPlants: true,
        carbonValue: 620,
      ),
      CarbonFootprintData(
        id: '9B',
        classLevel: 9,
        classSection: 'B',
        classOrientation: ClassOrientation.north,
        hasPlants: true,
        carbonValue: 740,
      ),
      CarbonFootprintData(
        id: '9C',
        classLevel: 9,
        classSection: 'C',
        classOrientation: ClassOrientation.south,
        hasPlants: true,
        carbonValue: 580,
      ),
      CarbonFootprintData(
        id: '9D',
        classLevel: 9,
        classSection: 'D',
        classOrientation: ClassOrientation.north,
        hasPlants: true,
        carbonValue: 810,
      ),
      // Grade 10 - with plants
      CarbonFootprintData(
        id: '10A',
        classLevel: 10,
        classSection: 'A',
        classOrientation: ClassOrientation.south,
        hasPlants: true,
        carbonValue: 900,
      ),
      CarbonFootprintData(
        id: '10B',
        classLevel: 10,
        classSection: 'B',
        classOrientation: ClassOrientation.north,
        hasPlants: true,
        carbonValue: 1050,
      ),
      CarbonFootprintData(
        id: '10C',
        classLevel: 10,
        classSection: 'C',
        classOrientation: ClassOrientation.south,
        hasPlants: true,
        carbonValue: 880,
      ),
      CarbonFootprintData(
        id: '10D',
        classLevel: 10,
        classSection: 'D',
        classOrientation: ClassOrientation.north,
        hasPlants: true,
        carbonValue: 1120,
      ),
      CarbonFootprintData(
        id: '10E',
        classLevel: 10,
        classSection: 'E',
        classOrientation: ClassOrientation.south,
        hasPlants: true,
        carbonValue: 960,
      ),
      CarbonFootprintData(
        id: '10F',
        classLevel: 10,
        classSection: 'F',
        classOrientation: ClassOrientation.north,
        hasPlants: true,
        carbonValue: 1180,
      ),
      // Grade 11 - no plants
      CarbonFootprintData(
        id: '11A',
        classLevel: 11,
        classSection: 'A',
        classOrientation: ClassOrientation.south,
        hasPlants: false,
        carbonValue: 2100,
      ),
      CarbonFootprintData(
        id: '11B',
        classLevel: 11,
        classSection: 'B',
        classOrientation: ClassOrientation.north,
        hasPlants: false,
        carbonValue: 2350,
      ),
      CarbonFootprintData(
        id: '11C',
        classLevel: 11,
        classSection: 'C',
        classOrientation: ClassOrientation.south,
        hasPlants: false,
        carbonValue: 1980,
      ),
      CarbonFootprintData(
        id: '11D',
        classLevel: 11,
        classSection: 'D',
        classOrientation: ClassOrientation.north,
        hasPlants: false,
        carbonValue: 2600,
      ),
      CarbonFootprintData(
        id: '11E',
        classLevel: 11,
        classSection: 'E',
        classOrientation: ClassOrientation.south,
        hasPlants: false,
        carbonValue: 2250,
      ),
      CarbonFootprintData(
        id: '11F',
        classLevel: 11,
        classSection: 'F',
        classOrientation: ClassOrientation.north,
        hasPlants: false,
        carbonValue: 2750,
      ),
      // Grade 12 - no plants
      CarbonFootprintData(
        id: '12A',
        classLevel: 12,
        classSection: 'A',
        classOrientation: ClassOrientation.south,
        hasPlants: false,
        carbonValue: 3000,
      ),
      CarbonFootprintData(
        id: '12B',
        classLevel: 12,
        classSection: 'B',
        classOrientation: ClassOrientation.north,
        hasPlants: false,
        carbonValue: 3200,
      ),
      CarbonFootprintData(
        id: '12C',
        classLevel: 12,
        classSection: 'C',
        classOrientation: ClassOrientation.south,
        hasPlants: false,
        carbonValue: 2900,
      ),
      CarbonFootprintData(
        id: '12D',
        classLevel: 12,
        classSection: 'D',
        classOrientation: ClassOrientation.north,
        hasPlants: false,
        carbonValue: 3400,
      ),
      CarbonFootprintData(
        id: '12E',
        classLevel: 12,
        classSection: 'E',
        classOrientation: ClassOrientation.south,
        hasPlants: false,
        carbonValue: 3100,
      ),
      CarbonFootprintData(
        id: '12F',
        classLevel: 12,
        classSection: 'F',
        classOrientation: ClassOrientation.north,
        hasPlants: false,
        carbonValue: 3600,
      ),
    ];
  }

  /// Get carbon data from seed data (fallback when Firestore is empty)
  Future<CarbonFootprintData?> _getCarbonDataFromSeedData(
    int classLevel,
    String classSection,
  ) async {
    try {
      final seedData = _generateSeedData();
      final docId = '${classLevel}$classSection';

      for (var data in seedData) {
        if (data.id == docId) {
          return data;
        }
      }

      return null;
    } catch (e) {
      print('Error getting carbon data from seed data: $e');
      return null;
    }
  }

  /// Get seed data by class level
  Future<List<CarbonFootprintData>> _getCarbonDataFromSeedDataByLevel(
    int classLevel,
  ) async {
    try {
      final seedData = _generateSeedData();
      return seedData.where((data) => data.classLevel == classLevel).toList();
    } catch (e) {
      print('Error getting seed data by class level: $e');
      return [];
    }
  }

  /// Get all seed data
  Future<List<CarbonFootprintData>> _getAllSeedCarbonData() async {
    try {
      return _generateSeedData();
    } catch (e) {
      print('Error getting all seed data: $e');
      return [];
    }
  }

  /// Listen to real-time changes for a specific class
  Stream<CarbonFootprintData?> streamCarbonData(
    int classLevel,
    String classSection,
  ) {
    return _firestore
        .collection(_collection)
        .doc('${classLevel}$classSection')
        .snapshots()
        .map((snapshot) {
          if (snapshot.exists) {
            return CarbonFootprintData.fromFirestore(snapshot);
          }
          return null;
        });
  }

  /// Listen to all carbon data changes
  Stream<List<CarbonFootprintData>> streamAllCarbonData() {
    return _firestore
        .collection(_collection)
        .where('isActive', isEqualTo: true)
        .snapshots()
        .map((snapshot) {
          return snapshot.docs
              .map((doc) => CarbonFootprintData.fromFirestore(doc))
              .toList();
        });
  }
}
