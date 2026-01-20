// lib/services/daily_task_content.dart
// Daily Tasks Content Service - Eco-themed daily challenges

enum ChallengeType {
  quiz, duel, multiplayer, social, special, weekly, seasonal,
  friendship, streak, energy, water, recycling, forest, climate,
  transportation, biodiversity, consumption,
}

enum ChallengeDifficulty { easy, medium, hard, expert, legendary }

enum RewardType { points, avatar, theme, feature, badge, title, lootbox }

class DailyTaskContent {
  final String id;
  final String title;
  final String description;
  final String category;
  final ChallengeType type;
  final int targetValue;
  final int rewardPoints;
  final RewardType rewardType;
  final String? rewardItem;
  final ChallengeDifficulty difficulty;
  final String icon;
  final List<String> tips;
  final String environmentalImpact;
  final int estimatedTime;

  const DailyTaskContent({
    required this.id,
    required this.title,
    required this.description,
    required this.category,
    required this.type,
    required this.targetValue,
    required this.rewardPoints,
    required this.rewardType,
    this.rewardItem,
    required this.difficulty,
    required this.icon,
    required this.tips,
    required this.environmentalImpact,
    required this.estimatedTime,
  });

  String get difficultyColor {
    switch (difficulty) {
      case ChallengeDifficulty.easy: return '#4CAF50';
      case ChallengeDifficulty.medium: return '#FF9800';
      case ChallengeDifficulty.hard: return '#F44336';
      case ChallengeDifficulty.expert: return '#9C27B0';
      case ChallengeDifficulty.legendary: return '#FFD700';
    }
  }

  String get difficultyName {
    switch (difficulty) {
      case ChallengeDifficulty.easy: return 'Kolay';
      case ChallengeDifficulty.medium: return 'Orta';
      case ChallengeDifficulty.hard: return 'Zor';
      case ChallengeDifficulty.expert: return 'Uzman';
      case ChallengeDifficulty.legendary: return 'Efsanevi';
    }
  }

  String get rewardTypeName {
    switch (rewardType) {
      case RewardType.points: return 'Puan';
      case RewardType.avatar: return 'Avatar';
      case RewardType.theme: return 'Tema';
      case RewardType.feature: return 'Özellik';
      case RewardType.badge: return 'Rozet';
      case RewardType.title: return 'Unvan';
      case RewardType.lootbox: return 'Kutu';
    }
  }

  String get typeName {
    switch (type) {
      case ChallengeType.quiz: return 'Quiz';
      case ChallengeType.duel: return 'Düello';
      case ChallengeType.multiplayer: return 'Çok Oyunculu';
      case ChallengeType.social: return 'Sosyal';
      case ChallengeType.special: return 'Özel';
      case ChallengeType.weekly: return 'Haftalık';
      case ChallengeType.seasonal: return 'Mevsimlik';
      case ChallengeType.friendship: return 'Arkadaşlık';
      case ChallengeType.streak: return 'Seri';
      case ChallengeType.energy: return 'Enerji';
      case ChallengeType.water: return 'Su';
      case ChallengeType.recycling: return 'Geri Dönüşüm';
      case ChallengeType.forest: return 'Orman';
      case ChallengeType.climate: return 'İklim';
      case ChallengeType.transportation: return 'Ulaşım';
      case ChallengeType.biodiversity: return 'Biyoçeşitlilik';
      case ChallengeType.consumption: return 'Tüketim';
    }
  }
}

class DailyTaskContentDatabase {
  static final DailyTaskContentDatabase _instance = DailyTaskContentDatabase._internal();
  factory DailyTaskContentDatabase() => _instance;
  DailyTaskContentDatabase._internal();

  final List<DailyTaskContent> _allTasks = [
    // Quiz Tasks
    DailyTaskContent(
      id: 'daily_quiz_easy',
      title: 'Günlük Bilgi',
      description: 'Bugün 3 quiz sorusu yanıtla',
      category: 'learning',
      type: ChallengeType.quiz,
      targetValue: 3,
      rewardPoints: 25,
      rewardType: RewardType.points,
      difficulty: ChallengeDifficulty.easy,
      icon: '🧠',
      tips: ['Hangi konuda iyisin?', 'Enerji quizlerini dene'],
      environmentalImpact: 'Öğrendiğin bilgiler çevre dostu kararlar almanı sağlar',
      estimatedTime: 5,
    ),
    DailyTaskContent(
      id: 'daily_quiz_medium',
      title: 'Quiz Ustası',
      description: 'Bugün 5 quiz sorusu yanıtla',
      category: 'learning',
      type: ChallengeType.quiz,
      targetValue: 5,
      rewardPoints: 50,
      rewardType: RewardType.points,
      difficulty: ChallengeDifficulty.medium,
      icon: '📚',
      tips: ['Farklı kategoriler dene', 'Zor konulara meydan oku'],
      environmentalImpact: 'Çevre bilincin artar, daha sürdürülebilir yaşam',
      estimatedTime: 8,
    ),
    DailyTaskContent(
      id: 'daily_quiz_hard',
      title: 'Bilgi Maratonu',
      description: 'Bugün 10 quiz sorusu yanıtla',
      category: 'learning',
      type: ChallengeType.quiz,
      targetValue: 10,
      rewardPoints: 100,
      rewardType: RewardType.points,
      difficulty: ChallengeDifficulty.hard,
      icon: '🏃',
      tips: ['Sabırlı ol', 'Doğru cevaplar için düşünmeden cevapla'],
      environmentalImpact: 'Derinlemesine çevre bilgisi edinirsin',
      estimatedTime: 15,
    ),
    DailyTaskContent(
      id: 'daily_quiz_perfect',
      title: 'Mükemmel Gün',
      description: 'Bir quizde %80 doğruluk oranı yakala',
      category: 'learning',
      type: ChallengeType.quiz,
      targetValue: 1,
      rewardPoints: 75,
      rewardType: RewardType.points,
      difficulty: ChallengeDifficulty.medium,
      icon: '💯',
      tips: ['Quizden önce konuyu çalış', 'Acele etme'],
      environmentalImpact: 'Doğru bilgi, doğru çevre kararları',
      estimatedTime: 10,
    ),
    // Energy Tasks
    DailyTaskContent(
      id: 'daily_energy_save',
      title: 'Enerji Tasarrufu',
      description: 'Gün içinde 2 enerji quizi çöz',
      category: 'energy',
      type: ChallengeType.energy,
      targetValue: 2,
      rewardPoints: 30,
      rewardType: RewardType.points,
      difficulty: ChallengeDifficulty.easy,
      icon: '⚡',
      tips: ['LED ampul kullanımı hakkında bilgi edin', 'Güneş enerjisi quizlerini dene'],
      environmentalImpact: 'Enerji tasarrufu, karbon ayak izini azaltır',
      estimatedTime: 5,
    ),
    DailyTaskContent(
      id: 'daily_energy_expert',
      title: 'Enerji Uzmanı',
      description: 'Yenilenebilir enerji konusunda 3 quiz çöz',
      category: 'energy',
      type: ChallengeType.energy,
      targetValue: 3,
      rewardPoints: 60,
      rewardType: RewardType.points,
      difficulty: ChallengeDifficulty.medium,
      icon: '☀️',
      tips: ['Güneş, rüzgar ve hidroelektrik hakkında öğren', 'Ülkenin enerji kaynaklarını araştır'],
      environmentalImpact: 'Temiz enerji geleceğine katkıda bulunursun',
      estimatedTime: 10,
    ),
    // Water Tasks
    DailyTaskContent(
      id: 'daily_water_save',
      title: 'Su Duyarlılığı',
      description: 'Su tasarrufu hakkında 2 quiz çöz',
      category: 'water',
      type: ChallengeType.water,
      targetValue: 2,
      rewardPoints: 30,
      rewardType: RewardType.points,
      difficulty: ChallengeDifficulty.easy,
      icon: '💧',
      tips: ['Duş süreni kısaltma hakkında bilgi edin', 'Yağmur suyu toplama sistemlerini öğren'],
      environmentalImpact: 'Su kıtlığına karşı farkındalık yaratırsın',
      estimatedTime: 5,
    ),
    // Recycling Tasks
    DailyTaskContent(
      id: 'daily_recycle',
      title: 'Geri Dönüşüm Elçisi',
      description: 'Geri dönüşüm konusunda 2 quiz çöz',
      category: 'recycling',
      type: ChallengeType.recycling,
      targetValue: 2,
      rewardPoints: 30,
      rewardType: RewardType.points,
      difficulty: ChallengeDifficulty.easy,
      icon: '♻️',
      tips: ['Plastik, kağıt ve cam ayrıştırmayı öğren', 'E-atık geri dönüşümü hakkında bilgi edin'],
      environmentalImpact: 'Atık miktarını azaltır, kaynakları korursun',
      estimatedTime: 5,
    ),
    // Forest Tasks
    DailyTaskContent(
      id: 'daily_forest_love',
      title: 'Orman Sever',
      description: 'Ormanlar hakkında 2 quiz çöz',
      category: 'forest',
      type: ChallengeType.forest,
      targetValue: 2,
      rewardPoints: 30,
      rewardType: RewardType.points,
      difficulty: ChallengeDifficulty.easy,
      icon: '🌲',
      tips: ['Ağaçların önemini öğren', 'Orman yangınlarını önleme yollarını keşfet'],
      environmentalImpact: 'Ormanları koruma bilinci kazanırsın',
      estimatedTime: 5,
    ),
    // Climate Tasks
    DailyTaskContent(
      id: 'daily_climate_aware',
      title: 'İklim Farkındalığı',
      description: 'İklim değişikliği konusunda 2 quiz çöz',
      category: 'climate',
      type: ChallengeType.climate,
      targetValue: 2,
      rewardPoints: 35,
      rewardType: RewardType.points,
      difficulty: ChallengeDifficulty.easy,
      icon: '🌍',
      tips: ['Sera gazlarının etkilerini öğren', 'Paris Anlaşması hakkında bilgi edin'],
      environmentalImpact: 'İklim değişikliğini anlar, çözümler üretirsin',
      estimatedTime: 6,
    ),
    // Duel Tasks
    DailyTaskContent(
      id: 'daily_duel_easy',
      title: 'Arena Meydan Okuma',
      description: 'Bugün 1 düello kazan',
      category: 'duel',
      type: ChallengeType.duel,
      targetValue: 1,
      rewardPoints: 40,
      rewardType: RewardType.points,
      difficulty: ChallengeDifficulty.medium,
      icon: '⚔️',
      tips: ['Hızlı düşün', 'Rakibin zayıf olduğu konuyu seç'],
      environmentalImpact: 'Rekabetçi öğrenme, bilgiyi pekiştirir',
      estimatedTime: 5,
    ),
    DailyTaskContent(
      id: 'daily_duel_hard',
      title: 'Arena Şampiyonu',
      description: 'Bugün 3 düello kazan',
      category: 'duel',
      type: ChallengeType.duel,
      targetValue: 3,
      rewardPoints: 120,
      rewardType: RewardType.points,
      difficulty: ChallengeDifficulty.hard,
      icon: '🏆',
      tips: ['Sabırlı ol', 'Her düelloda farklı konu dene'],
      environmentalImpact: 'Geniş çevre bilgisi edinirsin',
      estimatedTime: 15,
    ),
    // Social Tasks
    DailyTaskContent(
      id: 'daily_social_connect',
      title: 'Sosyal Bağ',
      description: 'Bugün 1 arkadaş ekle',
      category: 'social',
      type: ChallengeType.social,
      targetValue: 1,
      rewardPoints: 20,
      rewardType: RewardType.points,
      difficulty: ChallengeDifficulty.easy,
      icon: '👥',
      tips: ['Arkadaşlarını davet et', 'Profilini paylaş'],
      environmentalImpact: 'Birlikte öğrenmek daha etkilidir',
      estimatedTime: 2,
    ),
    DailyTaskContent(
      id: 'daily_streak',
      title: 'Seri Koruma',
      description: 'Bugün quiz çözerek serini koru',
      category: 'streak',
      type: ChallengeType.streak,
      targetValue: 1,
      rewardPoints: 15,
      rewardType: RewardType.points,
      difficulty: ChallengeDifficulty.easy,
      icon: '🔥',
      tips: ['Her gün quiz çöz', 'Hatırlatma kullan'],
      environmentalImpact: 'Düzenli öğrenme alışkanlığı',
      estimatedTime: 3,
    ),
    // Biodiversity Tasks
    DailyTaskContent(
      id: 'daily_bio_diverse',
      title: 'Biyoçeşitlilik',
      description: 'Türlerin korunması konusunda 2 quiz çöz',
      category: 'biodiversity',
      type: ChallengeType.biodiversity,
      targetValue: 2,
      rewardPoints: 40,
      rewardType: RewardType.points,
      difficulty: ChallengeDifficulty.medium,
      icon: '🦋',
      tips: ['Nesli tehlike altındaki türleri öğren', 'Habitat koruma hakkında bilgi edin'],
      environmentalImpact: 'Türlerin korunmasına katkıda bulunursun',
      estimatedTime: 8,
    ),
    // Transportation Tasks
    DailyTaskContent(
      id: 'daily_transport_eco',
      title: 'Çevre Dostu Ulaşım',
      description: 'Ulaşım ve karbon ayak izi konusunda 2 quiz çöz',
      category: 'transportation',
      type: ChallengeType.transportation,
      targetValue: 2,
      rewardPoints: 35,
      rewardType: RewardType.points,
      difficulty: ChallengeDifficulty.easy,
      icon: '🚲',
      tips: ['Bisiklet ve yürüyüşün faydalarını öğren', 'Toplu taşıma kullanımı hakkında bilgi edin'],
      environmentalImpact: 'Düşük karbonlu ulaşım tercihleri',
      estimatedTime: 6,
    ),
    // Weekly Challenge
    DailyTaskContent(
      id: 'weekly_quiz_marathon',
      title: 'Haftalık Quiz Maratonu',
      description: 'Bu hafta 20 quiz sorusu yanıtla',
      category: 'weekly',
      type: ChallengeType.weekly,
      targetValue: 20,
      rewardPoints: 300,
      rewardType: RewardType.points,
      difficulty: ChallengeDifficulty.medium,
      icon: '🎯',
      tips: ['Haftanın başında başla', 'Her gün düzenli çöz'],
      environmentalImpact: 'Kapsamlı çevre eğitimi',
      estimatedTime: 30,
    ),
    DailyTaskContent(
      id: 'weekly_duel_champion',
      title: 'Haftalık Düello Şampiyonu',
      description: 'Bu hafta 10 düello kazan',
      category: 'weekly',
      type: ChallengeType.weekly,
      targetValue: 10,
      rewardPoints: 500,
      rewardType: RewardType.lootbox,
      difficulty: ChallengeDifficulty.hard,
      icon: '👑',
      tips: ['Rakiplerini analiz et', 'Güçlü konularda düello teklif et'],
      environmentalImpact: 'Geniş bilgi yelpazesi',
      estimatedTime: 50,
    ),
    DailyTaskContent(
      id: 'weekly_social_network',
      title: 'Haftalık Sosyal Ağ',
      description: 'Bu hafta 5 yeni arkadaş ekle',
      category: 'weekly',
      type: ChallengeType.friendship,
      targetValue: 5,
      rewardPoints: 200,
      rewardType: RewardType.points,
      difficulty: ChallengeDifficulty.medium,
      icon: '🌐',
      tips: ['Arkadaşlarını davet et', 'Sosyal medyada paylaş'],
      environmentalImpact: 'Çevre bilincini yayıyorsun',
      estimatedTime: 10,
    ),
  ];

  List<DailyTaskContent> getAllTasks() => _allTasks;
  List<DailyTaskContent> getTasksByCategory(String category) =>
      _allTasks.where((t) => t.category == category).toList();
  List<DailyTaskContent> getTasksByType(ChallengeType type) =>
      _allTasks.where((t) => t.type == type).toList();
  List<DailyTaskContent> getDailyTasks() =>
      _allTasks.where((t) => t.type != ChallengeType.weekly).toList();
  List<DailyTaskContent> getWeeklyTasks() =>
      _allTasks.where((t) => t.type == ChallengeType.weekly).toList();
}
