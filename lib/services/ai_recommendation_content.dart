// lib/services/ai_recommendation_content.dart
// AI Recommendation Content Service - Eco-themed quiz recommendations
// This file provides comprehensive content for AI recommendations page

import 'dart:math';
import 'package:flutter/foundation.dart';

/// Quiz categories for AI recommendations
enum QuizCategory {
  energy,
  water,
  recycling,
  forest,
  consumption,
  transportation,
  climate,
  biodiversity,
  sustainability,
  pollution,
}

/// AI Recommendation Content Models
class AIRecommendationContent {
  final String id;
  final String title;
  final String description;
  final String reason;
  final QuizCategory category;
  final int difficulty;
  final int estimatedTime; // in minutes
  final int questionCount;
  final double confidenceScore;
  final List<String> tags;
  final String icon;

  const AIRecommendationContent({
    required this.id,
    required this.title,
    required this.description,
    required this.reason,
    required this.category,
    required this.difficulty,
    required this.estimatedTime,
    required this.questionCount,
    required this.confidenceScore,
    required this.tags,
    required this.icon,
  });

  /// Convert to AIRecommendation format
  Map<String, dynamic> toAIRecommendationMap() {
    return {
      'quizId': id,
      'quizTitle': title,
      'category': category.name,
      'confidenceScore': confidenceScore,
      'reason': reason,
    };
  }
}

/// Comprehensive recommendation content database
class AIRecommendationDatabase {
  static final AIRecommendationDatabase _instance =
      AIRecommendationDatabase._internal();
  factory AIRecommendationDatabase() => _instance;
  AIRecommendationDatabase._internal();

  final List<AIRecommendationContent> _allRecommendations = [
    // ========== ENERGY CATEGORY ==========
    AIRecommendationContent(
      id: 'energy_basics_001',
      title: 'Enerji Tasarrufunun Temelleri',
      description:
          'Günlük hayatta enerji tasarrufu yapmanın pratik yollarını öğrenin. Evinizde ve iş yerinizde küçük değişikliklerle büyük tasarruflar sağlayabilirsiniz.',
      reason:
          'Geçmiş quizlerinizde enerji kategorisinde yüksek performans gösterdiniz. Bu seviyeye uygun yeni içerikler öneriyoruz.',
      category: QuizCategory.energy,
      difficulty: 2,
      estimatedTime: 10,
      questionCount: 10,
      confidenceScore: 0.95,
      tags: ['energy', 'saving', 'home', 'electricity'],
      icon: '⚡',
    ),
    AIRecommendationContent(
      id: 'energy_renewable_002',
      title: 'Yenilenebilir Enerji Kaynakları',
      description:
          'Güneş, rüzgar ve hidroelektrik enerji hakkında kapsamlı bilgiler. Yenilenebilir enerjinin geleceği ve avantajları.',
      reason:
          'Enerji konusundaki bilginizi derinleştirmek için ileri düzey bir quiz öneriyoruz.',
      category: QuizCategory.energy,
      difficulty: 3,
      estimatedTime: 15,
      questionCount: 15,
      confidenceScore: 0.88,
      tags: ['renewable', 'solar', 'wind', 'future'],
      icon: '☀️',
    ),
    AIRecommendationContent(
      id: 'energy_climate_003',
      title: 'Enerji ve İklim Değişikliği',
      description:
          'Enerji tüketimi ile iklim değişikliği arasındaki ilişki. Karbon ayak izinizi azaltmanın yolları.',
      reason:
          'İklim değişikliği konusundaki farkındalığınızı artıracak bu quizi öneriyoruz.',
      category: QuizCategory.energy,
      difficulty: 4,
      estimatedTime: 12,
      questionCount: 12,
      confidenceScore: 0.82,
      tags: ['climate', 'carbon', 'footprint', 'global'],
      icon: '🌍',
    ),

    // ========== WATER CATEGORY ==========
    AIRecommendationContent(
      id: 'water_conservation_001',
      title: 'Su Tasarrufu Sanatı',
      description:
          'Su kaynaklarının önemi ve günlük hayatta su tasarrufu yapmanın pratik yöntemleri. Sürdürülebilir su kullanımı.',
      reason:
          'Su tasarrufu konusunda farkındalık oluşturmak için bu temel quizi öneriyoruz.',
      category: QuizCategory.water,
      difficulty: 1,
      estimatedTime: 8,
      questionCount: 8,
      confidenceScore: 0.92,
      tags: ['water', 'saving', 'conservation', 'life'],
      icon: '💧',
    ),
    AIRecommendationContent(
      id: 'water_quality_002',
      title: 'Su Kalitesi ve Kirlilik',
      description:
          'Su kirliliğinin nedenleri, etkileri ve önleme yöntemleri. Temiz su kaynaklarının korunması.',
      reason:
          'Su kalitesi konusundaki bilginizi artırmak için bu kapsamlı quizi öneriyoruz.',
      category: QuizCategory.water,
      difficulty: 3,
      estimatedTime: 12,
      questionCount: 12,
      confidenceScore: 0.85,
      tags: ['pollution', 'quality', 'clean', 'rivers'],
      icon: '🌊',
    ),
    AIRecommendationContent(
      id: 'water_marine_003',
      title: 'Deniz ve Okyanus Ekosistemi',
      description:
          'Deniz canlıları, okyanusların önemi ve deniz kirliliğinin etkileri. Mavi ekonomi ve sürdürülebilir balıkçılık.',
      reason:
          'Deniz ekosistemi hakkında derinlemesine bilgi edinmek için bu quizi öneriyoruz.',
      category: QuizCategory.water,
      difficulty: 4,
      estimatedTime: 15,
      questionCount: 15,
      confidenceScore: 0.78,
      tags: ['ocean', 'marine', 'fish', 'ecosystem'],
      icon: '🐠',
    ),

    // ========== RECYCLING CATEGORY ==========
    AIRecommendationContent(
      id: 'recycling_basics_001',
      title: 'Geri Dönüşümün Temelleri',
      description:
          'Geri dönüşümün önemi, doğru ayrıştırma yöntemleri ve geri dönüşümün çevresel etkileri.',
      reason:
          'Geri dönüşüm konusunda temel bilgilerinizi pekiştirmek için bu quizi öneriyoruz.',
      category: QuizCategory.recycling,
      difficulty: 1,
      estimatedTime: 8,
      questionCount: 8,
      confidenceScore: 0.94,
      tags: ['recycle', 'sorting', 'plastic', 'paper'],
      icon: '♻️',
    ),
    AIRecommendationContent(
      id: 'recycling_advanced_002',
      title: 'İleri Düzey Geri Dönüşüm',
      description:
          'Elektronik atıklar, tehlikeli maddeler ve özel geri dönüşüm süreçleri. Sıfır atık yaşam tarzı.',
      reason:
          'Geri dönüşüm konusundaki uzmanlığınızı artırmak için ileri düzey içerik.',
      category: QuizCategory.recycling,
      difficulty: 4,
      estimatedTime: 15,
      questionCount: 15,
      confidenceScore: 0.80,
      tags: ['ewaste', 'zero-waste', 'special', 'chemicals'],
      icon: '🔋',
    ),
    AIRecommendationContent(
      id: 'recycling_economy_003',
      title: 'Döngüsel Ekonomi',
      description:
          'Döngüsel ekonomi kavramı, sürdürülebilir üretim ve tüketim modelleri. Atık azaltma stratejileri.',
      reason:
          'Sürdürülebilir ekonomi konusundaki bilginizi genişletmek için bu quizi öneriyoruz.',
      category: QuizCategory.recycling,
      difficulty: 3,
      estimatedTime: 12,
      questionCount: 12,
      confidenceScore: 0.86,
      tags: ['circular', 'economy', 'sustainable', 'production'],
      icon: '🔄',
    ),

    // ========== FOREST CATEGORY ==========
    AIRecommendationContent(
      id: 'forest_importance_001',
      title: 'Ormanların Önemi',
      description:
          'Ormanların ekosistemdeki rolü, karbon tutumu ve biyoçeşitlilik için önemi. Orman yangınları ve koruma.',
      reason:
          'Orman ekosistemi konusundaki farkındalığınızı artırmak için bu temel quizi öneriyoruz.',
      category: QuizCategory.forest,
      difficulty: 2,
      estimatedTime: 10,
      questionCount: 10,
      confidenceScore: 0.90,
      tags: ['forest', 'trees', 'carbon', 'biodiversity'],
      icon: '🌲',
    ),
    AIRecommendationContent(
      id: 'forest_rainforest_002',
      title: 'Yağmur Ormanları ve Biyoçeşitlilik',
      description:
          'Amazon ve diğer yağmur ormanları, endemik türler ve orman tahribatının etkileri.',
      reason:
          'Yağmur ormanları ve biyoçeşitlilik konusunda derinlemesine bilgi için bu quizi öneriyoruz.',
      category: QuizCategory.forest,
      difficulty: 4,
      estimatedTime: 15,
      questionCount: 15,
      confidenceScore: 0.77,
      tags: ['rainforest', 'amazon', 'species', 'deforestation'],
      icon: '🌴',
    ),
    AIRecommendationContent(
      id: 'forest_afforestation_003',
      title: 'Ağaçlandırma ve Orman Yönetimi',
      description:
          'Sürdürülebilir orman yönetimi, ağaçlandırma projeleri ve orman ürünlerinin sınırlı kullanımı.',
      reason:
          'Orman yönetimi konusundaki bilginizi artırmak için bu quizi öneriyoruz.',
      category: QuizCategory.forest,
      difficulty: 3,
      estimatedTime: 12,
      questionCount: 12,
      confidenceScore: 0.83,
      tags: ['planting', 'management', 'sustainable', 'timber'],
      icon: '🌱',
    ),

    // ========== CONSUMPTION CATEGORY ==========
    AIRecommendationContent(
      id: 'consumption_sustainable_001',
      title: 'Sürdürülebilir Tüketim',
      description:
          'Sürdürülebilir tüketim alışkanlıkları, bilinçli satın alma ve çevre dostu ürün seçimi.',
      reason:
          'Bilinçli tüketim konusundaki farkındalığınızı artırmak için bu quizi öneriyoruz.',
      category: QuizCategory.consumption,
      difficulty: 2,
      estimatedTime: 10,
      questionCount: 10,
      confidenceScore: 0.91,
      tags: ['sustainable', 'shopping', 'eco-friendly', 'conscious'],
      icon: '🛒',
    ),
    AIRecommendationContent(
      id: 'consumption_fast_002',
      title: 'Hızlı Tüketim ve Etkileri',
      description:
          'Fast fashion, tek kullanımlık ürünler ve aşırı tüketimin çevresel maliyetleri.',
      reason:
          'Hızlı tüketimin etkilerini anlamak için bu önemli quizi öneriyoruz.',
      category: QuizCategory.consumption,
      difficulty: 3,
      estimatedTime: 12,
      questionCount: 12,
      confidenceScore: 0.87,
      tags: ['fast-fashion', 'single-use', 'overconsumption', 'impact'],
      icon: '👕',
    ),
    AIRecommendationContent(
      id: 'consumption_local_003',
      title: 'Yerel Üretim ve Tüketim',
      description:
          'Yerel ürünlerin avantajları, kısa tedarik zincirleri ve yerel ekonomilerin desteklenmesi.',
      reason:
          'Yerel üretim ve tüketim konusundaki bilginizi artırmak için bu quizi öneriyoruz.',
      category: QuizCategory.consumption,
      difficulty: 2,
      estimatedTime: 10,
      questionCount: 10,
      confidenceScore: 0.89,
      tags: ['local', 'farmers', 'short-chain', 'support'],
      icon: '🏪',
    ),

    // ========== TRANSPORTATION CATEGORY ==========
    AIRecommendationContent(
      id: 'transport_eco_001',
      title: 'Çevre Dostu Ulaşım',
      description:
          'Bisiklet, yürüyüş ve toplu taşıma kullanımının faydaları. Düşük karbonlu ulaşım alternatifleri.',
      reason:
          'Çevre dostu ulaşım konusundaki farkındalığınızı artırmak için bu quizi öneriyoruz.',
      category: QuizCategory.transportation,
      difficulty: 1,
      estimatedTime: 8,
      questionCount: 8,
      confidenceScore: 0.93,
      tags: ['bike', 'walk', 'public-transit', 'low-carbon'],
      icon: '🚲',
    ),
    AIRecommendationContent(
      id: 'transport_electric_002',
      title: 'Elektrikli Araçlar ve Gelecek',
      description:
          'Elektrikli araçların çevresel etkileri, şarj altyapısı ve sürdürülebilir ulaşım teknolojileri.',
      reason:
          'Elektrikli araçlar ve geleceğin ulaşımı konusundaki bilginizi artırmak için bu quizi öneriyoruz.',
      category: QuizCategory.transportation,
      difficulty: 3,
      estimatedTime: 12,
      questionCount: 12,
      confidenceScore: 0.85,
      tags: ['electric', 'ev', 'charging', 'future'],
      icon: '🚗',
    ),
    AIRecommendationContent(
      id: 'transport_aviation_003',
      title: 'Havacılık ve Çevre',
      description:
          'Havacılık sektörünün karbon ayak izi, uçuş emisyonları ve sürdürülebilir havacılık yakıtları.',
      reason:
          'Havacılık ve çevre ilişkisi konusunda bilgi edinmek için bu quizi öneriyoruz.',
      category: QuizCategory.transportation,
      difficulty: 4,
      estimatedTime: 15,
      questionCount: 15,
      confidenceScore: 0.76,
      tags: ['aviation', 'flights', 'emissions', 'saf'],
      icon: '✈️',
    ),

    // ========== CLIMATE CATEGORY ==========
    AIRecommendationContent(
      id: 'climate_basics_001',
      title: 'İklim Değişikliği Temelleri',
      description:
          'İklim değişikliğinin nedenleri, etkileri ve küresel mücadele yöntemleri. Paris Anlaşması ve hedefler.',
      reason:
          'İklim değişikliği konusundaki temel bilginizi pekiştirmek için bu quizi öneriyoruz.',
      category: QuizCategory.climate,
      difficulty: 2,
      estimatedTime: 10,
      questionCount: 10,
      confidenceScore: 0.92,
      tags: ['climate', 'change', 'global-warming', 'paris'],
      icon: '🌡️',
    ),
    AIRecommendationContent(
      id: 'climate_extreme_002',
      title: 'Aşırı Hava Olayları',
      description:
          'İklim değişikliğinin neden olduğu aşırı hava olayları, kuraklık, sel ve fırtınaların etkileri.',
      reason:
          'İklim değişikliğinin somut etkilerini anlamak için bu quizi öneriyoruz.',
      category: QuizCategory.climate,
      difficulty: 3,
      estimatedTime: 12,
      questionCount: 12,
      confidenceScore: 0.88,
      tags: ['extreme', 'weather', 'drought', 'flood'],
      icon: '⛈️',
    ),
    AIRecommendationContent(
      id: 'climate_solutions_003',
      title: 'İklim Değişikliği Çözümleri',
      description:
          'Bireysel ve toplumsal düzeyde iklim değişikliğiyle mücadele yöntemleri. İklim aktivizmi ve politika.',
      reason:
          'Çözüm odaklı bilgi edinmek için bu motivasyon dolu quizi öneriyoruz.',
      category: QuizCategory.climate,
      difficulty: 4,
      estimatedTime: 15,
      questionCount: 15,
      confidenceScore: 0.84,
      tags: ['solutions', 'action', 'activism', 'policy'],
      icon: '🌱',
    ),

    // ========== BIODIVERSITY CATEGORY ==========
    AIRecommendationContent(
      id: 'bio_basics_001',
      title: 'Biyoçeşitlilik Temelleri',
      description:
          'Biyoçeşitliliğin önemi, ekosistem hizmetleri ve türlerin korunması. Nesli tehlike altındaki türler.',
      reason:
          'Biyoçeşitlilik konusundaki farkındalığınızı artırmak için bu temel quizi öneriyoruz.',
      category: QuizCategory.biodiversity,
      difficulty: 2,
      estimatedTime: 10,
      questionCount: 10,
      confidenceScore: 0.91,
      tags: ['biodiversity', 'species', 'ecosystem', 'endangered'],
      icon: '🦋',
    ),
    AIRecommendationContent(
      id: 'bio_extinction_002',
      title: 'Türlerin Yok Oluşu',
      description:
          'Altıncı kitlesel yok oluş, habitat kaybı ve türlerin korunması için yapılan çalışmalar.',
      reason:
          'Türlerin korunması konusundaki bilginizi derinleştirmek için bu quizi öneriyoruz.',
      category: QuizCategory.biodiversity,
      difficulty: 4,
      estimatedTime: 15,
      questionCount: 15,
      confidenceScore: 0.79,
      tags: ['extinction', 'habitat', 'conservation', 'endangered'],
      icon: '🐼',
    ),
    AIRecommendationContent(
      id: 'bio_coral_003',
      title: 'Mercan Resifleri ve Deniz Yaşamı',
      description:
          'Mercan resiflerinin önemi, beyaz leke hastalığı ve deniz biyoçeşitliliğinin korunması.',
      reason:
          'Mercan resifleri ve deniz yaşamı konusunda bilgi edinmek için bu quizi öneriyoruz.',
      category: QuizCategory.biodiversity,
      difficulty: 3,
      estimatedTime: 12,
      questionCount: 12,
      confidenceScore: 0.82,
      tags: ['coral', 'reef', 'marine', 'ocean'],
      icon: '🪸',
    ),

    // ========== SUSTAINABILITY CATEGORY ==========
    AIRecommendationContent(
      id: 'sustain_basics_001',
      title: 'Sürdürülebilirlik Temelleri',
      description:
          'Sürdürülebilirlik kavramı, Birleşmiş Milletler Sürdürülebilir Kalkınma Hedefleri ve bireysel katkılar.',
      reason:
          'Sürdürülebilirlik konusundaki temel bilginizi pekiştirmek için bu quizi öneriyoruz.',
      category: QuizCategory.sustainability,
      difficulty: 2,
      estimatedTime: 10,
      questionCount: 10,
      confidenceScore: 0.93,
      tags: ['sustainability', 'sdgs', 'goals', 'future'],
      icon: '🎯',
    ),
    AIRecommendationContent(
      id: 'sustain_green_002',
      title: 'Yeşil Teknoloji ve İnovasyon',
      description:
          'Sürdürülebilir teknolojiler, yeşil inovasyon ve geleceğin çevre dostu çözümleri.',
      reason:
          'Yeşil teknoloji konusundaki bilginizi artırmak için bu ileri düzey quizi öneriyoruz.',
      category: QuizCategory.sustainability,
      difficulty: 3,
      estimatedTime: 12,
      questionCount: 12,
      confidenceScore: 0.86,
      tags: ['green-tech', 'innovation', 'future', 'solutions'],
      icon: '💡',
    ),
    AIRecommendationContent(
      id: 'sustain_community_003',
      title: 'Sürdürülebilir Topluluklar',
      description:
          'Sürdürülebilir şehirler, yeşil alanlar ve topluluk düzeyinde çevre koruma projeleri.',
      reason:
          'Topluluk düzeyinde sürdürülebilirlik konusundaki bilginizi artırmak için bu quizi öneriyoruz.',
      category: QuizCategory.sustainability,
      difficulty: 3,
      estimatedTime: 12,
      questionCount: 12,
      confidenceScore: 0.84,
      tags: ['community', 'cities', 'green-spaces', 'local'],
      icon: '🏘️',
    ),

    // ========== POLLUTION CATEGORY ==========
    AIRecommendationContent(
      id: 'pollution_air_001',
      title: 'Hava Kirliliği',
      description:
          'Hava kirliliğinin kaynakları, sağlık etkileri ve önleme yöntemleri. Temiz hava hakkı.',
      reason:
          'Hava kirliliği konusundaki farkındalığınızı artırmak için bu önemli quizi öneriyoruz.',
      category: QuizCategory.pollution,
      difficulty: 2,
      estimatedTime: 10,
      questionCount: 10,
      confidenceScore: 0.92,
      tags: ['air', 'pollution', 'health', 'smog'],
      icon: '🌫️',
    ),
    AIRecommendationContent(
      id: 'pollution_plastic_002',
      title: 'Plastik Kirliliği',
      description:
          'Plastik atıkların okyanuslara etkisi, mikroplastikler ve plastik kirliliğiyle mücadele yöntemleri.',
      reason:
          'Plastik kirliliği konusundaki bilginizi derinleştirmek için bu quizi öneriyoruz.',
      category: QuizCategory.pollution,
      difficulty: 3,
      estimatedTime: 12,
      questionCount: 12,
      confidenceScore: 0.89,
      tags: ['plastic', 'ocean', 'microplastics', 'waste'],
      icon: '🛍️',
    ),
    AIRecommendationContent(
      id: 'pollution_soil_003',
      title: 'Toprak Kirliliği',
      description:
          'Toprak kirliliğinin nedenleri, pestisitler ve ağır metallerin etkileri. Toprak sağlığı ve koruma.',
      reason:
          'Toprak kirliliği ve sağlığı konusunda bilgi edinmek için bu quizi öneriyoruz.',
      category: QuizCategory.pollution,
      difficulty: 4,
      estimatedTime: 15,
      questionCount: 15,
      confidenceScore: 0.78,
      tags: ['soil', 'pollution', 'pesticides', 'heavy-metals'],
      icon: '🪴',
    ),
  ];

  /// Get all recommendations
  List<AIRecommendationContent> getAllRecommendations() {
    return _allRecommendations;
  }

  /// Get recommendations by category
  List<AIRecommendationContent> getRecommendationsByCategory(
      QuizCategory category) {
    return _allRecommendations
        .where((rec) => rec.category == category)
        .toList();
  }

  /// Get personalized recommendations based on user history
  List<AIRecommendationContent> getPersonalizedRecommendations({
    required Map<String, int> categoryPerformance,
    required int totalQuizzesCompleted,
    required double averageScore,
    required List<String> completedQuizIds,
    int limit = 5,
  }) {
    final recommendations = <AIRecommendationContent>[];

    // Filter out already completed quizzes
    final availableQuizzes = _allRecommendations
        .where((rec) => !completedQuizIds.contains(rec.id))
        .toList();

    // Score each recommendation
    final scoredRecommendations = availableQuizzes.map((rec) {
      double score = rec.confidenceScore;

      // Boost score for categories where user performs well
      if (categoryPerformance.containsKey(rec.category.name)) {
        final performance = categoryPerformance[rec.category.name]!;
        if (performance > 70) {
          score += 0.1; // Boost for strong categories
        } else if (performance < 40) {
          score -= 0.05; // Slight reduction for weak categories
        }
      }

      // Adjust difficulty based on total quizzes
      if (totalQuizzesCompleted < 10) {
        // New user - prefer easier quizzes
        if (rec.difficulty > 3) {
          score -= 0.15;
        }
      } else if (totalQuizzesCompleted > 50) {
        // Experienced user - include harder quizzes
        if (rec.difficulty <= 2) {
          score -= 0.05;
        } else if (rec.difficulty >= 4) {
          score += 0.1;
        }
      }

      // Boost for high average scores
      if (averageScore > 0.8) {
        score += 0.05;
      }

      // Add some randomness to prevent repetition
      score += Random().nextDouble() * 0.1 - 0.05;

      return _ScoredRecommendation(rec, score);
    }).toList();

    // Sort by score descending
    scoredRecommendations.sort((a, b) => b.score.compareTo(a.score));

    // Return top recommendations
    return scoredRecommendations
        .take(limit)
        .map((item) => item.recommendation)
        .toList();
  }

  /// Get daily recommendation
  AIRecommendationContent getDailyRecommendation({
    required String userId,
    required Map<String, int> categoryPerformance,
  }) {
    // Use userId to create consistent daily rotation
    final random = Random(userId.hashCode);
    final availableQuizzes = _allRecommendations.toList()..shuffle(random);

    // Prioritize categories with lower performance
    final sortedCategories = categoryPerformance.entries
        .toList()
      ..sort((a, b) => a.value.compareTo(b.value));

    if (sortedCategories.isNotEmpty) {
      final weakestCategoryName = sortedCategories.first.key;
      try {
        final weakestCategory = QuizCategory.values
            .firstWhere((c) => c.name == weakestCategoryName);
        final categoryQuizzes =
            getRecommendationsByCategory(weakestCategory);
        if (categoryQuizzes.isNotEmpty) {
          return categoryQuizzes[random.nextInt(categoryQuizzes.length)];
        }
      } catch (e) {
        if (kDebugMode) debugPrint('Category not found: $weakestCategoryName');
      }
    }

    return availableQuizzes.first;
  }

  /// Get recommendations for specific difficulty
  List<AIRecommendationContent> getRecommendationsByDifficulty(int difficulty) {
    return _allRecommendations
        .where((rec) => rec.difficulty == difficulty)
        .toList();
  }

  /// Get trending recommendations
  List<AIRecommendationContent> getTrendingRecommendations() {
    // In a real app, this would be based on analytics data
    // For now, return random selections as "trending"
    final random = Random();
    final shuffled = [..._allRecommendations]..shuffle(random);
    return shuffled.take(5).toList();
  }
}

/// Scored recommendation pair for internal use
class _ScoredRecommendation {
  final AIRecommendationContent recommendation;
  final double score;

  _ScoredRecommendation(this.recommendation, this.score);
}

