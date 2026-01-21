// lib/tests/carbon_footprint_service_test.dart
// Tests for Carbon Footprint Service

import 'package:flutter_test/flutter_test.dart';
import 'package:karbonson/models/carbon_footprint_data.dart';
import 'package:karbonson/services/carbon_footprint_service.dart';

void main() {
  group('CarbonFootprintData Model Tests', () {
    test('Create valid CarbonFootprintData for grade 9', () {
      final data = CarbonFootprintData(
        id: '9A',
        classLevel: 9,
        classSection: 'A',
        classOrientation: ClassOrientation.south,
        hasPlants: true,
        carbonValue: 620,
      );

      expect(data.classIdentifier, '9A');
      expect(data.isValid(), true);
      expect(data.carbonValue, 620);
    });

    test('Create valid CarbonFootprintData for grade 12', () {
      final data = CarbonFootprintData(
        id: '12F',
        classLevel: 12,
        classSection: 'F',
        classOrientation: ClassOrientation.north,
        hasPlants: false,
        carbonValue: 3600,
      );

      expect(data.classIdentifier, '12F');
      expect(data.isValid(), true);
      expect(data.hasPlants, false);
    });

    test('Invalid class section for grade 9 (E is not valid)', () {
      final data = CarbonFootprintData(
        id: '9E',
        classLevel: 9,
        classSection: 'E',
        classOrientation: ClassOrientation.south,
        hasPlants: false,
        carbonValue: 700,
      );

      expect(data.isValidClassSection(), false);
      expect(data.isValid(), false);
    });

    test('Invalid carbon value (below minimum)', () {
      final data = CarbonFootprintData(
        id: '10A',
        classLevel: 10,
        classSection: 'A',
        classOrientation: ClassOrientation.south,
        hasPlants: true,
        carbonValue: 350, // Below 400
      );

      expect(data.isValidCarbonValue(), false);
      expect(data.isValid(), false);
    });

    test('Invalid carbon value (above maximum)', () {
      final data = CarbonFootprintData(
        id: '12A',
        classLevel: 12,
        classSection: 'A',
        classOrientation: ClassOrientation.north,
        hasPlants: false,
        carbonValue: 4500, // Above 4000
      );

      expect(data.isValidCarbonValue(), false);
      expect(data.isValid(), false);
    });

    test('Plants in grade 11 should be invalid', () {
      final data = CarbonFootprintData(
        id: '11A',
        classLevel: 11,
        classSection: 'A',
        classOrientation: ClassOrientation.south,
        hasPlants: true, // Should be false for grade 11
        carbonValue: 2100,
      );

      expect(data.isValidPlantStatus(), false);
      expect(data.isValid(), false);
    });

    test('Grade 9 with plants is valid', () {
      final data = CarbonFootprintData(
        id: '9B',
        classLevel: 9,
        classSection: 'B',
        classOrientation: ClassOrientation.north,
        hasPlants: true,
        carbonValue: 740,
      );

      expect(data.isValidPlantStatus(), true);
      expect(data.isValid(), true);
    });

    test('Firestore serialization and deserialization', () {
      final originalData = CarbonFootprintData(
        id: '10C',
        classLevel: 10,
        classSection: 'C',
        classOrientation: ClassOrientation.south,
        hasPlants: true,
        carbonValue: 880,
      );

      final firestore = originalData.toFirestore();
      final recreated = CarbonFootprintData.fromMap({
        'id': '10C',
        ...firestore,
      });

      expect(recreated.classLevel, originalData.classLevel);
      expect(recreated.classSection, originalData.classSection);
      expect(recreated.carbonValue, originalData.carbonValue);
      expect(recreated.hasPlants, originalData.hasPlants);
    });

    test('copyWith creates modified copy', () {
      final original = CarbonFootprintData(
        id: '9A',
        classLevel: 9,
        classSection: 'A',
        classOrientation: ClassOrientation.south,
        hasPlants: true,
        carbonValue: 620,
      );

      final modified = original.copyWith(carbonValue: 650);

      expect(modified.carbonValue, 650);
      expect(modified.classLevel, original.classLevel);
      expect(original.carbonValue, 620); // Original unchanged
    });

    test('Equality operator works correctly', () {
      final data1 = CarbonFootprintData(
        id: '9A',
        classLevel: 9,
        classSection: 'A',
        classOrientation: ClassOrientation.south,
        hasPlants: true,
        carbonValue: 620,
      );

      final data2 = CarbonFootprintData(
        id: '9A',
        classLevel: 9,
        classSection: 'A',
        classOrientation: ClassOrientation.south,
        hasPlants: true,
        carbonValue: 620,
      );

      expect(data1, data2);
    });
  });

  group('CarbonStatistics Tests', () {
    test('Empty list statistics', () {
      final stats = CarbonStatistics.fromList([]);

      expect(stats.allData.isEmpty, true);
      expect(stats.totalCarbon, 0);
      expect(stats.averageCarbon, 0);
    });

    test('Single item statistics', () {
      final data = [
        CarbonFootprintData(
          id: '9A',
          classLevel: 9,
          classSection: 'A',
          classOrientation: ClassOrientation.south,
          hasPlants: true,
          carbonValue: 620,
        ),
      ];

      final stats = CarbonStatistics.fromList(data);

      expect(stats.allData.length, 1);
      expect(stats.totalCarbon, 620);
      expect(stats.averageCarbon, 620);
      expect(stats.maxCarbon, 620);
      expect(stats.minCarbon, 620);
    });

    test('Multiple items statistics', () {
      final data = [
        CarbonFootprintData(
          id: '9A',
          classLevel: 9,
          classSection: 'A',
          classOrientation: ClassOrientation.south,
          hasPlants: true,
          carbonValue: 600,
        ),
        CarbonFootprintData(
          id: '9B',
          classLevel: 9,
          classSection: 'B',
          classOrientation: ClassOrientation.north,
          hasPlants: true,
          carbonValue: 800,
        ),
        CarbonFootprintData(
          id: '9C',
          classLevel: 9,
          classSection: 'C',
          classOrientation: ClassOrientation.south,
          hasPlants: true,
          carbonValue: 700,
        ),
      ];

      final stats = CarbonStatistics.fromList(data);

      expect(stats.allData.length, 3);
      expect(stats.totalCarbon, 2100);
      expect(stats.averageCarbon, 700);
      expect(stats.maxCarbon, 800);
      expect(stats.minCarbon, 600);
    });
  });

  group('CarbonReport Tests', () {
    test('Create CarbonReport from data', () {
      final data = CarbonFootprintData(
        id: '10A',
        classLevel: 10,
        classSection: 'A',
        classOrientation: ClassOrientation.south,
        hasPlants: true,
        carbonValue: 900,
      );

      final report = CarbonReport.fromData(
        data,
        percentage: 12.5,
        averageClassLevel: 1000,
      );

      expect(report.carbonData, data);
      expect(report.percentage, 12.5);
      expect(report.isAboveAverage, false);
    });

    test('Report shows above average correctly', () {
      final data = CarbonFootprintData(
        id: '11A',
        classLevel: 11,
        classSection: 'A',
        classOrientation: ClassOrientation.north,
        hasPlants: false,
        carbonValue: 2350,
      );

      final report = CarbonReport.fromData(
        data,
        percentage: 15.0,
        averageClassLevel: 2000,
      );

      expect(report.isAboveAverage, true);
    });
  });

  group('Grade Validation Tests', () {
    test('Grade 9 valid sections', () {
      for (final section in ['A', 'B', 'C', 'D']) {
        final data = CarbonFootprintData(
          id: '9$section',
          classLevel: 9,
          classSection: section,
          classOrientation: ClassOrientation.south,
          hasPlants: true,
          carbonValue: 700,
        );

        expect(data.isValidClassSection(), true);
      }
    });

    test('Grade 10-12 valid sections', () {
      for (final grade in [10, 11, 12]) {
        for (final section in ['A', 'B', 'C', 'D', 'E', 'F']) {
          final data = CarbonFootprintData(
            id: '$grade$section',
            classLevel: grade,
            classSection: section,
            classOrientation: ClassOrientation.south,
            hasPlants: grade < 11,
            carbonValue: 1500,
          );

          expect(data.isValidClassSection(), true);
        }
      }
    });

    test('Invalid grade', () {
      final data = CarbonFootprintData(
        id: '8A',
        classLevel: 8,
        classSection: 'A',
        classOrientation: ClassOrientation.south,
        hasPlants: false,
        carbonValue: 700,
      );

      expect(data.isValidClassSection(), false);
    });
  });

  group('Carbon Value Range Tests', () {
    test('Carbon values at boundaries', () {
      final minData = CarbonFootprintData(
        id: '9A',
        classLevel: 9,
        classSection: 'A',
        classOrientation: ClassOrientation.south,
        hasPlants: true,
        carbonValue: 400, // Minimum valid
      );

      final maxData = CarbonFootprintData(
        id: '12F',
        classLevel: 12,
        classSection: 'F',
        classOrientation: ClassOrientation.north,
        hasPlants: false,
        carbonValue: 4000, // Maximum valid
      );

      expect(minData.isValidCarbonValue(), true);
      expect(maxData.isValidCarbonValue(), true);
    });

    test('Carbon values outside boundaries', () {
      final belowMin = CarbonFootprintData(
        id: '9A',
        classLevel: 9,
        classSection: 'A',
        classOrientation: ClassOrientation.south,
        hasPlants: true,
        carbonValue: 399,
      );

      final aboveMax = CarbonFootprintData(
        id: '12F',
        classLevel: 12,
        classSection: 'F',
        classOrientation: ClassOrientation.north,
        hasPlants: false,
        carbonValue: 4001,
      );

      expect(belowMin.isValidCarbonValue(), false);
      expect(aboveMax.isValidCarbonValue(), false);
    });
  });

  group('Orientation Tests', () {
    test('North orientation class', () {
      final northClass = CarbonFootprintData(
        id: '9B',
        classLevel: 9,
        classSection: 'B',
        classOrientation: ClassOrientation.north,
        hasPlants: true,
        carbonValue: 740, // Higher than south
      );

      expect(northClass.classOrientation, ClassOrientation.north);
      expect(northClass.isValid(), true);
    });

    test('South orientation class', () {
      final southClass = CarbonFootprintData(
        id: '9C',
        classLevel: 9,
        classSection: 'C',
        classOrientation: ClassOrientation.south,
        hasPlants: true,
        carbonValue: 580, // Lower than north
      );

      expect(southClass.classOrientation, ClassOrientation.south);
      expect(southClass.isValid(), true);
    });
  });
}
