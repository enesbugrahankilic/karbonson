// lib/services/carbon_ai_recommendation_service.dart
// AI Recommendation Service for Carbon Footprint - Generate eco-conscious recommendations

import 'package:karbonson/models/carbon_footprint_data.dart';
import 'package:karbonson/models/user_data.dart';

class CarbonAIRecommendationService {
  
  /// Generate AI recommendations based on carbon data and user class level
  Future<List<String>> generateCarbonRecommendations({
    required CarbonFootprintData carbonData,
    required UserData userData,
    required int? averageCarbon,
  }) async {
    try {
      final recommendations = <String>[];
      
      // Recommendation based on carbon value
      if (carbonData.carbonValue > (averageCarbon ?? 0) * 1.2) {
        recommendations.add(
          '⚠️ Sınıfınızın karbon ayak izi ortalamanın ${((carbonData.carbonValue / (averageCarbon ?? 1) - 1) * 100).toStringAsFixed(1)}% üzerinde. '
          'Enerji tasarrufu önlemleri alınması önerilir.'
        );
      }
      
      // Recommendation for students (class level specific)
      if (userData.classLevel != null && userData.classLevel! <= 9) {
        recommendations.add(
          '🌱 ${userData.classLevel} sınıf öğrencileri olarak, sınıfınıza bitkiler eklenmesi '
          'karbon değerini azaltmaya yardımcı olabilir.'
        );
      }
      
      // Plant-based recommendation
      if (!carbonData.hasPlants && carbonData.classLevel <= 10) {
        recommendations.add(
          '🌿 Bitkisiz bir sınıf. İçeride bitkiler yetiştirilmesi karbon absorpsiyonunu artırabilir. '
          'Başlamak için 5-10 bitki yeterli olabilir.'
        );
      }
      
      // Orientation-based recommendation
      if (carbonData.classOrientation.name == 'north') {
        recommendations.add(
          '🧭 Kuzey yönlü sınıflar daha az doğal ışık alır ve enerji tüketimi artar. '
          'LED ışıklandırmaya geçiş yapılması önerilir.'
        );
      } else {
        recommendations.add(
          '☀️ Güney yönlü sınıfınız doğal ışık avantajı sunuyor. Perdeleri açık tutmak enerji tasarrufu sağlayabilir.'
        );
      }
      
      // Class level specific tasks
      if (userData.classLevel != null) {
        switch (userData.classLevel) {
          case 9:
            recommendations.add(
              '📚 9. sınıflar için enerji tasarrufu quiz\'i çözerek karbon farkındalığını artırın.'
            );
            break;
          case 10:
            recommendations.add(
              '🔬 10. sınıflar için laboratuvardaki kimyasal atık yönetimi hakkında bilgilendirme alın.'
            );
            break;
          case 11:
            recommendations.add(
              '💡 11. sınıflar için yenilenebilir enerji kaynakları konusunda derinlemesine araştırma yapın.'
            );
            break;
          case 12:
            recommendations.add(
              '🌍 12. sınıflar için iklim değişikliği ve karbon nötralizasyon stratejileri üzerine proje hazırlayın.'
            );
            break;
        }
      }
      
      // General eco-friendly tips
      recommendations.addAll(_getGeneralEcoTips(carbonData));
      
      return recommendations;
    } catch (e) {
      print('Error generating recommendations: $e');
      return ['Öneriler yüklenirken hata oluştu.'];
    }
  }

  /// Generate daily micro-tasks based on carbon data
  Future<List<Map<String, dynamic>>> generateCarbonMicroTasks({
    required CarbonFootprintData carbonData,
    required UserData userData,
  }) async {
    try {
      final tasks = <Map<String, dynamic>>[];

      // Base tasks - always include some
      tasks.addAll([
        {
          'id': 'carbon_observation',
          'title': 'Karbon Gözlemi',
          'description': 'Sınıfında enerji tüketim kaynaklarını tanımla (5 adet).',
          'reward': 30,
          'difficulty': 'easy',
          'category': 'carbon',
        },
        {
          'id': 'carbon_share_report',
          'title': 'Rapor Paylaş',
          'description': 'Karbon raporunu arkadaşlarınla paylaş.',
          'reward': 25,
          'difficulty': 'easy',
          'category': 'carbon',
        },
      ]);

      // Task based on high carbon value
      if (carbonData.carbonValue > 2000) {
        tasks.add({
          'id': 'carbon_energy_quiz',
          'title': 'Enerji Tasarrufu Quizi',
          'description': 'Sınıfında enerji tasarrufu ile ilgili mini quiz\'i tamamla.',
          'reward': 50,
          'difficulty': 'medium',
          'category': 'carbon',
        });
      }

      // Plant-related task if applicable
      if (!carbonData.hasPlants && carbonData.classLevel <= 10) {
        tasks.add({
          'id': 'carbon_plant_proposal',
          'title': 'Bitki Önerisi',
          'description': 'Sınıfı için uygun bir bitki türü araştır ve öner.',
          'reward': 40,
          'difficulty': 'medium',
          'category': 'carbon',
        });
      }

      // Random additional tasks based on class level and orientation
      final randomTasks = <Map<String, dynamic>>[];

      if (userData.classLevel != null) {
        switch (userData.classLevel) {
          case 9:
            randomTasks.addAll([
              {
                'id': 'carbon_9_energy_audit',
                'title': 'Enerji Denetimi',
                'description': '9. sınıf için sınıfın enerji kullanımını incele.',
                'reward': 35,
                'difficulty': 'easy',
                'category': 'carbon',
              },
              {
                'id': 'carbon_9_recycling',
                'title': 'Geri Dönüşüm Projesi',
                'description': 'Sınıfınızda geri dönüşüm kutusu oluştur.',
                'reward': 45,
                'difficulty': 'medium',
                'category': 'carbon',
              },
            ]);
            break;
          case 10:
            randomTasks.addAll([
              {
                'id': 'carbon_10_lab_safety',
                'title': 'Laboratuvar Güvenliği',
                'description': 'Laboratuvardaki atık yönetimi prosedürlerini öğren.',
                'reward': 40,
                'difficulty': 'medium',
                'category': 'carbon',
              },
              {
                'id': 'carbon_10_measurement',
                'title': 'Karbon Ölçümü',
                'description': 'Sınıfın haftalık enerji tüketimini ölç.',
                'reward': 50,
                'difficulty': 'hard',
                'category': 'carbon',
              },
            ]);
            break;
          case 11:
            randomTasks.addAll([
              {
                'id': 'carbon_11_renewable',
                'title': 'Yenilenebilir Enerji',
                'description': 'Yenilenebilir enerji kaynakları hakkında araştırma yap.',
                'reward': 55,
                'difficulty': 'medium',
                'category': 'carbon',
              },
              {
                'id': 'carbon_11_efficiency',
                'title': 'Verimlilik Analizi',
                'description': 'Sınıf cihazlarının enerji verimliliğini değerlendir.',
                'reward': 45,
                'difficulty': 'hard',
                'category': 'carbon',
              },
            ]);
            break;
          case 12:
            randomTasks.addAll([
              {
                'id': 'carbon_12_project',
                'title': 'Karbon Projesi',
                'description': 'Karbon nötralizasyon projesi hazırla.',
                'reward': 70,
                'difficulty': 'hard',
                'category': 'carbon',
              },
              {
                'id': 'carbon_12_presentation',
                'title': 'Sunum Hazırla',
                'description': 'Çevre bilinci sunumu hazırla ve arkadaşlarına sun.',
                'reward': 60,
                'difficulty': 'medium',
                'category': 'carbon',
              },
            ]);
            break;
        }
      }

      // Orientation-based tasks
      if (carbonData.classOrientation.name == 'north') {
        randomTasks.add({
          'id': 'carbon_north_lighting',
          'title': 'Işık Optimizasyonu',
          'description': 'Kuzey yönlü sınıf için doğal ışık kullanımını optimize et.',
          'reward': 35,
          'difficulty': 'easy',
          'category': 'carbon',
        });
      } else {
        randomTasks.add({
          'id': 'carbon_south_shading',
          'title': 'Gölgeleme Sistemi',
          'description': 'Güney yönlü sınıf için ısıyı azaltacak çözümler öner.',
          'reward': 40,
          'difficulty': 'medium',
          'category': 'carbon',
        });
      }

      // Shuffle and add 2-3 random tasks
      randomTasks.shuffle();
      tasks.addAll(randomTasks.take(3));

      return tasks;
    } catch (e) {
      print('Error generating micro tasks: $e');
      return [];
    }
  }

  /// Get general eco-friendly tips
  List<String> _getGeneralEcoTips(CarbonFootprintData carbonData) {
    return [
      '💚 Sınıfta kağıt kullanımını azalt: Dijital notlar tutmayı tercih et.',
      '🔌 Elektroniği kapatırken çık: Bilgisayar ve cihazları şarj olunca çıkar.',
      '🚴 Okula bisiklet veya yürüyerek gel: Bunu yap ve karbon ayak izini azalt.',
      '🥗 Okulda getirilen yemekleri tüket: Plastik ambalaj kullanımını azalt.',
      '♻️ Sınıfta geri dönüşüm yapıl: Kağıt, plastik ve metal ayrı topla.',
      '🌱 Ağaç dikimi kampanyasına katıl: Okul öncesinde bir ağaç dik.',
    ];
  }

  /// Get recommendations for class-based carbon comparison
  Future<Map<String, dynamic>> getClassComparisonInsights({
    required CarbonFootprintData userClass,
    required List<CarbonFootprintData> allClassData,
    required int averageCarbon,
  }) async {
    try {
      // Sort by carbon value (ascending)
      final sortedClasses = [...allClassData]..sort((a, b) => a.carbonValue.compareTo(b.carbonValue));
      
      // Find rank
      final rank = sortedClasses.indexWhere((c) => c.id == userClass.id) + 1;
      final totalClasses = sortedClasses.length;
      
      // Get better performing classes
      final betterClasses = sortedClasses
          .where((c) => c.carbonValue < userClass.carbonValue)
          .toList();
      
      // Get worse performing classes
      final worseClasses = sortedClasses
          .where((c) => c.carbonValue > userClass.carbonValue)
          .toList();
      
      return {
        'rank': rank,
        'totalClasses': totalClasses,
        'percentile': (rank / totalClasses * 100),
        'status': rank <= (totalClasses / 3) ? 'İyi' : rank <= (totalClasses * 2 / 3) ? 'Orta' : 'Zayıf',
        'betterCount': betterClasses.length,
        'worseCount': worseClasses.length,
        'topPerformer': sortedClasses.isNotEmpty ? sortedClasses.first.classIdentifier : null,
        'recommendation': _getComparisonRecommendation(rank, totalClasses, userClass, betterClasses),
      };
    } catch (e) {
      print('Error getting class comparison insights: $e');
      return {};
    }
  }

  /// Get recommendation based on comparison
  String _getComparisonRecommendation(
    int rank,
    int total,
    CarbonFootprintData userClass,
    List<CarbonFootprintData> betterClasses,
  ) {
    if (rank <= 3) {
      return '🏆 Harika! Sınıfınız karbon ayak izi konusunda en iyi sınıflar arasında. '
             'Başka sınıflara örnek olabilirsiniz.';
    }
    
    if (betterClasses.isNotEmpty) {
      final bestClass = betterClasses.first;
      final difference = userClass.carbonValue - bestClass.carbonValue;
      return '📈 ${bestClass.classIdentifier} sınıfı daha iyi durumda. '
             'Yaklaşık $difference g CO₂ fark azaltabilirseniz, onlara erişebilirsiniz.';
    }
    
    return '💪 Karbon ayak izinizi azaltmak için adımlar atın. '
           'Bitkiler eklemek, enerji tasarrufu ve atık yönetimi önemli alanlar.';
  }

  /// Get achievement suggestions based on carbon data
  Future<List<Map<String, dynamic>>> getCarbonAchievementSuggestions({
    required CarbonFootprintData carbonData,
    required UserData userData,
    required int? averageCarbon,
  }) async {
    try {
      final suggestions = <Map<String, dynamic>>[];
      
      // Achievement for low carbon
      if (carbonData.carbonValue < (averageCarbon ?? 1000) * 0.7) {
        suggestions.add({
          'id': 'eco_leader',
          'title': 'Çevre Lider',
          'description': 'Sınıfın karbon ayak izi ortalamanın 30% altında.',
          'icon': '🌿',
          'points': 100,
        });
      }
      
      // Achievement for having plants
      if (carbonData.hasPlants) {
        suggestions.add({
          'id': 'green_class',
          'title': 'Yeşil Sınıf',
          'description': 'Sınıfta bitkiler var.',
          'icon': '🌱',
          'points': 50,
        });
      }
      
      // Achievement for completing carbon report
      suggestions.add({
        'id': 'carbon_report_viewer',
        'title': 'Karbon Rapor Izci',
        'description': 'Karbon raporunu görüntüle ve indir.',
        'icon': '📊',
        'points': 25,
      });
      
      // Achievement for participation
      suggestions.add({
        'id': 'carbon_aware',
        'title': 'Karbon Farkında',
        'description': 'Karbon Ayak İzi ekranını ziyaret et.',
        'icon': '🌍',
        'points': 10,
      });
      
      return suggestions;
    } catch (e) {
      print('Error getting achievement suggestions: $e');
      return [];
    }
  }

  /// Format recommendations for display
  List<Map<String, String>> formatRecommendationsForDisplay(
    List<String> recommendations,
  ) {
    return recommendations
        .asMap()
        .entries
        .map((entry) => {
          'id': entry.key.toString(),
          'text': entry.value,
          'priority': entry.key < 2 ? 'high' : entry.key < 4 ? 'medium' : 'low',
        })
        .toList();
  }

  /// Get school-wide carbon statistics context
  Future<Map<String, dynamic>> getSchoolCarbonContext({
    required List<CarbonFootprintData> allClasses,
  }) async {
    try {
      final stats = CarbonStatistics.fromList(allClasses);
      
      // Separate by grade level
      final grade9 = allClasses.where((c) => c.classLevel == 9).toList();
      final grade10 = allClasses.where((c) => c.classLevel == 10).toList();
      final grade11 = allClasses.where((c) => c.classLevel == 11).toList();
      final grade12 = allClasses.where((c) => c.classLevel == 12).toList();
      
      // Count plants
      final classesWithPlants = allClasses.where((c) => c.hasPlants).length;
      
      return {
        'totalClasses': allClasses.length,
        'totalCarbon': stats.totalCarbon,
        'averageCarbon': stats.averageCarbon,
        'maxCarbon': stats.maxCarbon,
        'minCarbon': stats.minCarbon,
        'gradeDistribution': {
          '9': grade9.length,
          '10': grade10.length,
          '11': grade11.length,
          '12': grade12.length,
        },
        'classesWithPlants': classesWithPlants,
        'plantPercentage': (classesWithPlants / allClasses.length * 100).toStringAsFixed(1),
      };
    } catch (e) {
      print('Error getting school carbon context: $e');
      return {};
    }
  }
}
