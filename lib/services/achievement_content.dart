// lib/services/achievement_content.dart
// Achievement Content Service - Eco-themed achievements

import 'package:flutter/foundation.dart';

enum AchievementCategory {
  quiz, duel, multiplayer, social, streak, special,
  environmental, energy, water, recycling, forest,
  biodiversity, climate, consumption, transportation,
}

enum AchievementRarity {
  common, uncommon, rare, epic, legendary, mythic,
}

class AchievementContent {
  final String id;
  final String title;
  final String description;
  final String longDescription;
  final String icon;
  final AchievementCategory category;
  final int points;
  final Map<String, dynamic> requirements;
  final AchievementRarity rarity;
  final List<String> tips;
  final String fact;
  final List<String> relatedAchievements;

  const AchievementContent({
    required this.id,
    required this.title,
    required this.description,
    required this.longDescription,
    required this.icon,
    required this.category,
    required this.points,
    required this.requirements,
    required this.rarity,
    required this.tips,
    required this.fact,
    required this.relatedAchievements,
  });

  String get rarityColor {
    switch (rarity) {
      case AchievementRarity.common: return '#8B8B8B';
      case AchievementRarity.uncommon: return '#4CAF50';
      case AchievementRarity.rare: return '#2196F3';
      case AchievementRarity.epic: return '#9C27B0';
      case AchievementRarity.legendary: return '#FF9800';
      case AchievementRarity.mythic: return '#F44336';
    }
  }

  String get rarityName {
    switch (rarity) {
      case AchievementRarity.common: return 'Sıradan';
      case AchievementRarity.uncommon: return 'Nadir';
      case AchievementRarity.rare: return 'Nadir';
      case AchievementRarity.epic: return 'Destansı';
      case AchievementRarity.legendary: return 'Efsanevi';
      case AchievementRarity.mythic: return 'Mitolojik';
    }
  }

  String get categoryName {
    switch (category) {
      case AchievementCategory.quiz: return 'Quiz';
      case AchievementCategory.duel: return 'Düello';
      case AchievementCategory.multiplayer: return 'Çok Oyunculu';
      case AchievementCategory.social: return 'Sosyal';
      case AchievementCategory.streak: return 'Seri';
      case AchievementCategory.special: return 'Özel';
      case AchievementCategory.environmental: return 'Çevre';
      case AchievementCategory.energy: return 'Enerji';
      case AchievementCategory.water: return 'Su';
      case AchievementCategory.recycling: return 'Geri Dönüşüm';
      case AchievementCategory.forest: return 'Orman';
      case AchievementCategory.biodiversity: return 'Biyoçeşitlilik';
      case AchievementCategory.climate: return 'İklim';
      case AchievementCategory.consumption: return 'Tüketim';
      case AchievementCategory.transportation: return 'Ulaşım';
    }
  }
}

class AchievementContentDatabase {
  static final AchievementContentDatabase _instance = AchievementContentDatabase._internal();
  factory AchievementContentDatabase() => _instance;
  AchievementContentDatabase._internal();

  final List<AchievementContent> _allAchievements = [
    // Quiz Achievements
    AchievementContent(
      id: 'quiz_first_steps',
      title: 'İlk Adımlar',
      description: 'İlk quizini tamamla',
      longDescription: 'KarbonSon yolculuğun başladı! Quiz dünyasına ilk adımını attın.',
      icon: '🎯',
      category: AchievementCategory.quiz,
      points: 10,
      requirements: {'completedQuizzes': 1},
      rarity: AchievementRarity.common,
      tips: ['Hangi kategoride daha güçlüsün?', 'Zorlandığın konularda tekrar quiz çözmek faydalıdır.'],
      fact: 'Dünya genelinde her yıl yaklaşık 100 milyon quiz oynanıyor!',
      relatedAchievements: ['quiz_explorer', 'quiz_master'],
    ),
    AchievementContent(
      id: 'quiz_explorer',
      title: 'Quiz Kaşifi',
      description: '10 farklı quiz kategorisinde quiz tamamla',
      longDescription: 'Keşfetmeyi seviyorsun! Farklı kategorilerde bilgi edinmek, çevre sorunlarını daha iyi anlamanı sağlar.',
      icon: '🗺️',
      category: AchievementCategory.quiz,
      points: 50,
      requirements: {'uniqueCategories': 10},
      rarity: AchievementRarity.uncommon,
      tips: ['Her gün farklı bir kategori dene', 'Zayıf olduğun kategorilere odaklan'],
      fact: 'KarbonSon uygulamasında 10 farklı ana kategori bulunuyor!',
      relatedAchievements: ['quiz_first_steps', 'quiz_master'],
    ),
    AchievementContent(
      id: 'quiz_master',
      title: 'Quiz Ustası',
      description: '50 quiz tamamla',
      longDescription: 'Artık bir quiz ustasısın! 50 quiz tamamlamak, önemli bir kararlılık ve öğrenme tutkusu gerektirir.',
      icon: '🏆',
      category: AchievementCategory.quiz,
      points: 150,
      requirements: {'completedQuizzes': 50},
      rarity: AchievementRarity.rare,
      tips: ['Düzenli quiz çalışması, alışkanlık oluşturur', 'Arkadaşlarınla yarışarak daha motive olabilirsin'],
      fact: '50 quiz tamamlamak, yaklaşık 500 soru yanıtlamak demek!',
      relatedAchievements: ['quiz_explorer', 'quiz_legend'],
    ),
    AchievementContent(
      id: 'quiz_legend',
      title: 'Quiz Efsanesi',
      description: '200 quiz tamamla',
      longDescription: 'Sen bir efsanesin! 200 quiz tamamlamak olağanüstü bir başarı.',
      icon: '🌟',
      category: AchievementCategory.quiz,
      points: 500,
      requirements: {'completedQuizzes': 200},
      rarity: AchievementRarity.legendary,
      tips: ['Günde en az 1-2 quiz çözmeyi hedefle', 'Zor kategorilerde uzmanlaşarak fark yarat'],
      fact: '200 quiz tamamlamak, bir üniversite dersinin içeriğini öğrenmek gibi!',
      relatedAchievements: ['quiz_master', 'perfect_score'],
    ),
    AchievementContent(
      id: 'perfect_score',
      title: 'Mükemmeliyetçi',
      description: 'Bir quizde %100 doğruluk oranı yakala',
      longDescription: 'Mükemmel bir performans! Bir quizde tüm soruları doğru cevaplamak, gerçek ustalık işaretidir.',
      icon: '💎',
      category: AchievementCategory.quiz,
      points: 100,
      requirements: {'perfectScore': 1},
      rarity: AchievementRarity.epic,
      tips: ['Quizden önce konuyu iyi çalış', 'Acele etme, her soruyu dikkatlice oku'],
      fact: 'Dünya genelinde quiz oyuncularının sadece %3ü hiç hata yapmadan tamamlar!',
      relatedAchievements: ['quiz_master', 'speed_demon'],
    ),
    // Streak Achievements
    AchievementContent(
      id: 'streak_7_days',
      title: 'Haftalık Seri',
      description: '7 gün üst üste quiz çöz',
      longDescription: 'Harika bir seri başlattın! 7 gün üst üste quiz çökmek, gerçek bir öğrenme alışkanlığı oluşturduğunu gösterir.',
      icon: '🔥',
      category: AchievementCategory.streak,
      points: 75,
      requirements: {'dailyStreak': 7},
      rarity: AchievementRarity.rare,
      tips: ['Her gün aynı saatte quiz çözmeyi dene', 'Hatırlatma bildirimlerini açık tut'],
      fact: '7 günlük seri oluşturan kullanıcılar, 30 günü tamamlama olasılığı %60 daha yüksek!',
      relatedAchievements: ['streak_30_days', 'consistent_player'],
    ),
    AchievementContent(
      id: 'streak_30_days',
      title: 'Aylık Şampiyon',
      description: '30 gün üst üste quiz çöz',
      longDescription: 'Bir ay boyunca hiç ara vermeden çalışmak inanılmaz! Bu başarı, senin kararlılığının ve çevre eğitimine olan bağlılığının kanıtı.',
      icon: '⚡',
      category: AchievementCategory.streak,
      points: 300,
      requirements: {'dailyStreak': 30},
      rarity: AchievementRarity.legendary,
      tips: ['Quiz çözmeyi günlük rutininin parçası yap', 'Başarısız olursan hemen tekrar başla'],
      fact: '30 günlük seri oluşturmak, yeni bir alışkanlık oluşturmanın kritik eşiğidir!',
      relatedAchievements: ['streak_7_days', 'streak_100_days'],
    ),
    AchievementContent(
      id: 'streak_100_days',
      title: 'Yüz Gün Ustası',
      description: '100 gün üst üste quiz çöz',
      longDescription: 'Yüz gün! Bu sadece bir sayı değil, senin kararlılığının, tutkunun ve çevre eğitimine olan derin bağlılığının simgesi.',
      icon: '👑',
      category: AchievementCategory.streak,
      points: 1000,
      requirements: {'dailyStreak': 100},
      rarity: AchievementRarity.mythic,
      tips: ['Bu yolda ilerlemek için kendini ödüllendir', 'Başkalarını da quiz çözmeye teşvik et'],
      fact: 'Dünya genelinde sadece %1 kullanıcı 100 günlük seriye ulaşabiliyor!',
      relatedAchievements: ['streak_30_days', 'consistent_player'],
    ),
    // Energy Achievements
    AchievementContent(
      id: 'energy_saver',
      title: 'Enerji Tasarruf Ustası',
      description: 'Enerji kategorisinde 10 quiz tamamla',
      longDescription: 'Enerji konusunda ciddi bir bilgi birikimi oluşturdun!',
      icon: '⚡',
      category: AchievementCategory.energy,
      points: 75,
      requirements: {'energyQuizzes': 10},
      rarity: AchievementRarity.uncommon,
      tips: ['Günlük hayatta enerji tasarrufu ipuçlarını uygula', 'Güneş ve rüzgar enerjisi hakkında daha fazla bilgi edin'],
      fact: 'Bir LED ampul, geleneksel ampulden %75 daha az enerji tüketir!',
      relatedAchievements: ['energy_expert', 'green_warrior'],
    ),
    AchievementContent(
      id: 'energy_expert',
      title: 'Enerji Uzmanı',
      description: 'Enerji kategorisinde 30 quiz tamamla',
      longDescription: 'Artık enerji konusunda gerçek bir uzmansın!',
      icon: '🔋',
      category: AchievementCategory.energy,
      points: 200,
      requirements: {'energyQuizzes': 30},
      rarity: AchievementRarity.rare,
      tips: ['Evindeki enerji tüketimini analiz et', 'Güneş paneli kurulumu hakkında bilgi edin'],
      fact: 'Dünya enerji tüketiminin %80i hâlâ fosil yakıtlardan geliyor!',
      relatedAchievements: ['energy_saver', 'renewable_champion'],
    ),
    // Water Achievements
    AchievementContent(
      id: 'water_guardian',
      title: 'Su Koruyucusu',
      description: 'Su kategorisinde 10 quiz tamamla',
      longDescription: 'Su kaynaklarının korunması konusunda bilinçli bir vatandaş oldun!',
      icon: '💧',
      category: AchievementCategory.water,
      points: 75,
      requirements: {'waterQuizzes': 10},
      rarity: AchievementRarity.uncommon,
      tips: ['Duş süreni kısaltarak günde 40 litre su tasarruf et', 'Yağmur suyu toplama sistemi kurmayı düşün'],
      fact: 'Dünya nüfusunun %2si temiz suya erişemiyor!',
      relatedAchievements: ['water_expert', 'ocean_protector'],
    ),
    // Recycling Achievements
    AchievementContent(
      id: 'recycling_hero',
      title: 'Geri Dönüşüm Kahramanı',
      description: 'Geri dönüşüm kategorisinde 10 quiz tamamla',
      longDescription: 'Atık yönetimi konusunda bilinçli bir vatandaş oldun!',
      icon: '♻️',
      category: AchievementCategory.recycling,
      points: 75,
      requirements: {'recyclingQuizzes': 10},
      rarity: AchievementRarity.uncommon,
      tips: ['Evinizde farklı renklerde çöp kutuları kullanın', 'Kompost yapmayı öğrenin'],
      fact: 'Bir alüminyum kutuyu geri dönüştürmek, yenisini üretmekten %95 daha az enerji gerektirir!',
      relatedAchievements: ['recycling_expert', 'zero_waste'],
    ),
    // Forest Achievements
    AchievementContent(
      id: 'forest_friend',
      title: 'Orman Dostu',
      description: 'Orman kategorisinde 10 quiz tamamla',
      longDescription: 'Ormanların önemi konusunda bilinçli oldun!',
      icon: '🌲',
      category: AchievementCategory.forest,
      points: 75,
      requirements: {'forestQuizzes': 10},
      rarity: AchievementRarity.uncommon,
      tips: ['Bir ağaç dikmeyi planla', 'Orman yangınları konusunda bilinçli ol'],
      fact: 'Bir büyük ağaç, günde yaklaşık 1 kg CO2 emer!',
      relatedAchievements: ['forest_guardian', 'tree_planter'],
    ),
    // Duel Achievements
    AchievementContent(
      id: 'duel_first_blood',
      title: 'İlk Zafer',
      description: 'İlk düelloyu kazan',
      longDescription: 'Arena tarihin! İlk düello zaferin, rekabetçi ruhunun ilk kanıtı.',
      icon: '⚔️',
      category: AchievementCategory.duel,
      points: 25,
      requirements: {'duelWins': 1},
      rarity: AchievementRarity.common,
      tips: ['Rakibinden önce doğru cevap vermeye odaklan', 'Hızlı düşünme pratiği yap'],
      fact: 'Düellolar, öğrenmeyi %40 daha eğlenceli hale getiriyor!',
      relatedAchievements: ['duel_warrior', 'duel_master'],
    ),
    AchievementContent(
      id: 'duel_warrior',
      title: 'Düello Savaşçısı',
      description: '10 düello kazan',
      longDescription: 'On düello, on zafer! Rekabetçi arena da gerçek bir savaşçısın.',
      icon: '🗡️',
      category: AchievementCategory.duel,
      points: 100,
      requirements: {'duelWins': 10},
      rarity: AchievementRarity.rare,
      tips: ['Farklı kategorilerde uzmanlaş', 'Rakibin zayıf olduğu konuları tespit et'],
      fact: 'Düellolarda kazananlar, konularında %30 daha fazla bilgi tutuyor!',
      relatedAchievements: ['duel_first_blood', 'duel_master'],
    ),
    AchievementContent(
      id: 'duel_master',
      title: 'Düello Ustası',
      description: '50 düello kazan',
      longDescription: 'Efsanevi bir düellocu oldun! 50 galibiyet, olağanüstü bir beceri ve kararlılık gerektirir.',
      icon: '👑',
      category: AchievementCategory.duel,
      points: 400,
      requirements: {'duelWins': 50},
      rarity: AchievementRarity.legendary,
      tips: ['Düzenli pratik yaparak hızını artır', 'Zor konulara yoğunlaş'],
      fact: '50 düello kazanmak, yaklaşık 500 soru doğru cevaplamak demek!',
      relatedAchievements: ['duel_warrior', 'duel_legend'],
    ),
    // Social Achievements
    AchievementContent(
      id: 'social_butterfly',
      title: 'Sosyal Kelebek',
      description: '5 arkadaş ekle',
      longDescription: 'Sosyal ağını genişletmeye başladın!',
      icon: '🦋',
      category: AchievementCategory.social,
      points: 30,
      requirements: {'friendsCount': 5},
      rarity: AchievementRarity.uncommon,
      tips: ['Quiz sonuçlarını arkadaşlarınla paylaş', 'Düello teklif et'],
      fact: 'Sosyal öğrenme, bireysel öğrenmeden %20 daha etkili!',
      relatedAchievements: ['social_connector', 'community_builder'],
    ),
    AchievementContent(
      id: 'social_connector',
      title: 'Sosyal Bağlayıcı',
      description: '20 arkadaş ekle',
      longDescription: 'Gerçek bir sosyal kelebeksin!',
      icon: '🕸️',
      category: AchievementCategory.social,
      points: 100,
      requirements: {'friendsCount': 20},
      rarity: AchievementRarity.rare,
      tips: ['Aile üyelerini de uygulamaya davet et', 'Sosyal medyada paylaş'],
      fact: '20 arkadaşla etkileşim, öğrenme motivasyonunu %50 artırır!',
      relatedAchievements: ['social_butterfly', 'community_builder'],
    ),
    // Climate Achievements
    AchievementContent(
      id: 'climate_warrior',
      title: 'İklim Savaşçısı',
      description: 'İklim değişikliği konusunda 15 quiz tamamla',
      longDescription: 'İklim kriziyle mücadelenin ön saflarında yer alıyorsun!',
      icon: '🌍',
      category: AchievementCategory.climate,
      points: 150,
      requirements: {'climateQuizzes': 15},
      rarity: AchievementRarity.epic,
      tips: ['Karbon ayak izini hesapla ve azalt', 'İklim dostu ürünleri tercih et'],
      fact: 'Sıcaklıklar sanayi öncesi döneme göre 1.1°C arttı!',
      relatedAchievements: ['carbon_neutral', 'climate_activist'],
    ),
    // Biodiversity Achievements
    AchievementContent(
      id: 'biodiversity_hero',
      title: 'Biyoçeşitlilik Kahramanı',
      description: 'Biyoçeşitlilik kategorisinde 15 quiz tamamla',
      longDescription: 'Türlerin korunmasının savunucusu oldun!',
      icon: '🦋',
      category: AchievementCategory.biodiversity,
      points: 150,
      requirements: {'biodiversityQuizzes': 15},
      rarity: AchievementRarity.epic,
      tips: ['Yaban hayatı koruma alanlarını ziyaret et', 'Evcil hayvan ticaretinden kaçın'],
      fact: 'Dünya üzerinde tahmin edilen 8.7 milyon tür var ve çoğu henüz keşfedilmedi!',
      relatedAchievements: ['species_saver', 'nature_lover'],
    ),
  ];

  List<AchievementContent> getAllAchievements() => _allAchievements;
  List<AchievementContent> getAchievementsByCategory(AchievementCategory category) =>
      _allAchievements.where((a) => a.category == category).toList();
  List<AchievementContent> getAchievementsByRarity(AchievementRarity rarity) =>
      _allAchievements.where((a) => a.rarity == rarity).toList();
}
