// lib/data/quiz_questions.dart
// Organized Quiz Questions Database by Category and Difficulty

import '../models/question.dart';

/// Ana quiz soruları veritabanı
class QuizQuestionsDatabase {
  // Enerji kategorisi soruları
  static final List<Question> energyQuestions = [
    Question(
      id: 'energy_1',
      text: 'Güneş enerjisi aşağıdakilerden hangisini kullanır?',
      options: [
        Option(text: 'Güneş ışınlarını', score: 1),
        Option(text: 'Rüzgarı', score: 0),
        Option(text: 'Su akışını', score: 0),
        Option(text: 'Jeotermal ısıyı', score: 0),
      ],
      category: 'Enerji',
      difficulty: DifficultyLevel.easy,
      timeLimit: 25,
      explanation: 'Güneş panelleri, güneş ışınlarını doğrudan elektriğe dönüştürür.',
      tags: ['temel', 'yenilenebilir', 'güneş'],
    ),
    Question(
      id: 'energy_2',
      text: 'Aşağıdakilerden hangisi yenilenebilir enerji kaynağı değildir?',
      options: [
        Option(text: 'Güneş enerjisi', score: 0),
        Option(text: 'Kömür', score: 1),
        Option(text: 'Rüzgar enerjisi', score: 0),
        Option(text: 'Hidroelektrik', score: 0),
      ],
      category: 'Enerji',
      difficulty: DifficultyLevel.easy,
      timeLimit: 25,
      explanation: 'Kömür fosil yakıt kategorisindedir ve yenilenebilir değildir.',
      tags: ['temel', 'yenilenebilir', 'fosil'],
    ),
    Question(
      id: 'energy_3',
      text: 'Bir LED ampul, geleneksel ampule göre ne kadar daha az enerji tüketir?',
      options: [
        Option(text: '%50 daha az', score: 0),
        Option(text: '%75-80 daha az', score: 1),
        Option(text: '%10 daha az', score: 0),
        Option(text: '%25 daha az', score: 0),
      ],
      category: 'Enerji',
      difficulty: DifficultyLevel.medium,
      timeLimit: 30,
      explanation: 'LED ampuller geleneksel ampullere göre %75-80 daha az enerji tüketir.',
      tags: ['verimlilik', 'led', 'tasarruf'],
    ),
    Question(
      id: 'energy_4',
      text: 'Türkiye\'de güneş enerjisi potansiyeli en yüksek olan bölge hangisidir?',
      options: [
        Option(text: 'Karadeniz Bölgesi', score: 0),
        Option(text: 'Güneydoğu Anadolu', score: 1),
        Option(text: 'Marmara Bölgesi', score: 0),
        Option(text: 'Ege Bölgesi', score: 0),
      ],
      category: 'Enerji',
      difficulty: DifficultyLevel.medium,
      timeLimit: 30,
      explanation: 'Güneydoğu Anadolu, Türkiye\'de en yüksek güneşlenme süresine sahip bölgedir.',
      tags: ['türkiye', 'coğrafya', 'güneş'],
    ),
    Question(
      id: 'energy_5',
      text: 'Rüzgar türbinlerinin verimliliğini sınırlayan temel fiziksel yasa hangisidir?',
      options: [
        Option(text: 'Ohm yasası', score: 0),
        Option(text: 'Betz yasası', score: 1),
        Option(text: 'Newton\'un hareket yasaları', score: 0),
        Option(text: 'Termodinamiğin 1. yasası', score: 0),
      ],
      category: 'Enerji',
      difficulty: DifficultyLevel.hard,
      timeLimit: 35,
      explanation: 'Betz yasası, bir rüzgar türbininin maksimum %59.3 enerji çıkarabileceğini belirler.',
      tags: ['fizik', 'rüzgar', 'verimlilik'],
    ),
  ];

  // Su kategorisi soruları
  static final List<Question> waterQuestions = [
    Question(
      id: 'water_1',
      text: 'Dünya üzerindeki suyun yaklaşık yüzde kaçı tatlı sudur?',
      options: [
        Option(text: '%97', score: 0),
        Option(text: '%75', score: 0),
        Option(text: '%2.5', score: 1),
        Option(text: '%50', score: 0),
      ],
      category: 'Su',
      difficulty: DifficultyLevel.easy,
      timeLimit: 25,
      explanation: 'Dünya üzerindeki suyun sadece yaklaşık %2.5\'i tatlı sudur ve bunun çoğu buzullardadır.',
      tags: ['temel', 'tatlı su', 'küresel'],
    ),
    Question(
      id: 'water_2',
      text: 'Aşağıdakilerden hangisi su tasarrufu için önerilmez?',
      options: [
        Option(text: 'Kısa duş almak', score: 0),
        Option(text: 'Muslukları açık bırakmak', score: 1),
        Option(text: 'Çamaşır makinesini tam dolu çalıştırmak', score: 0),
        Option(text: 'Yağmur suyu toplamak', score: 0),
      ],
      category: 'Su',
      difficulty: DifficultyLevel.easy,
      timeLimit: 25,
      explanation: 'Muslukları açık bırakmak gereksiz su israfına neden olur.',
      tags: ['temel', 'tasarruf', 'günlük'],
    ),
    Question(
      id: 'water_3',
      text: 'Bir kişinin günlük ortalama su tüketimi (içme, hijyen ve yemek için) yaklaşık ne kadardır?',
      options: [
        Option(text: '20 litre', score: 0),
        Option(text: '100 litre', score: 0),
        Option(text: '3.000-5.000 litre', score: 1),
        Option(text: '500 litre', score: 0),
      ],
      category: 'Su',
      difficulty: DifficultyLevel.medium,
      timeLimit: 30,
      explanation: 'Gıda üretimi dahil edildiğinde, bir kişinin günlük su ayak izi 3.000-5.000 litre civarındadır.',
      tags: ['tüketim', 'günlük', 'gıda'],
    ),
    Question(
      id: 'water_4',
      text: 'Türkiye\'nin su stresi düzeyi ne durumdadır?',
      options: [
        Option(text: 'Su zengini bir ülke', score: 0),
        Option(text: 'Orta düzeyde su stresi', score: 1),
        Option(text: 'Çok düşük su stresi', score: 0),
        Option(text: 'Su kıtlığı yaşayan ülke', score: 0),
      ],
      category: 'Su',
      difficulty: DifficultyLevel.medium,
      timeLimit: 30,
      explanation: 'Türkiye, yıllık kişi başı 1.519 m³ su potansiyeli ile orta düzeyde su stresi altındadır.',
      tags: ['türkiye', 'su stresi', 'kaynak'],
    ),
  ];

  // Orman kategorisi soruları
  static final List<Question> forestQuestions = [
    Question(
      id: 'forest_1',
      text: 'Bir ağaç yılda ortalama ne kadar CO2 emer?',
      options: [
        Option(text: '50 kg', score: 0),
        Option(text: '10 kg', score: 0),
        Option(text: '22 kg', score: 1),
        Option(text: '100 kg', score: 0),
      ],
      category: 'Orman',
      difficulty: DifficultyLevel.medium,
      timeLimit: 30,
      explanation: 'Orta boy bir ağaç, yılda yaklaşık 22 kg CO2 emer.',
      tags: ['co2', 'emisyon', 'iklim'],
    ),
    Question(
      id: 'forest_2',
      text: 'Orman yangınlarının en yaygın nedeni nedir?',
      options: [
        Option(text: 'Yıldırım düşmesi', score: 0),
        Option(text: 'İnsan kaynaklı nedenler', score: 1),
        Option(text: 'Volkanik patlamalar', score: 0),
        Option(text: 'Yüksek sıcaklık', score: 0),
      ],
      category: 'Orman',
      difficulty: DifficultyLevel.easy,
      timeLimit: 25,
      explanation: 'Orman yangınlarının %90\'ından fazlası insan kaynaklıdır.',
      tags: ['yangın', 'güvenlik', 'insan'],
    ),
    Question(
      id: 'forest_3',
      text: 'Amazon yağmur ormanları Dünya\'daki oksijenin yaklaşık yüzde kaçını üretir?',
      options: [
        Option(text: '%50', score: 0),
        Option(text: '%20', score: 1),
        Option(text: '%5', score: 0),
        Option(text: '%75', score: 0),
      ],
      category: 'Orman',
      difficulty: DifficultyLevel.hard,
      timeLimit: 35,
      explanation: 'Amazon, Dünya\'daki oksijenin yaklaşık %20\'sini üretir.',
      tags: ['oksijen', 'amazon', 'iklim'],
    ),
  ];

  // Geri dönüşüm kategorisi soruları
  static final List<Question> recyclingQuestions = [
    Question(
      id: 'recycling_1',
      text: 'Bir aluminyum kutunun geri dönüşümü ne kadar enerji tasarrufu sağlar?',
      options: [
        Option(text: '%30', score: 0),
        Option(text: '%95', score: 1),
        Option(text: '%50', score: 0),
        Option(text: '%75', score: 0),
      ],
      category: 'Geri Dönüşüm',
      difficulty: DifficultyLevel.medium,
      timeLimit: 30,
      explanation: 'Bir aluminyum kutunun geri dönüşümü, yeni kutu üretimine göre %95 enerji tasarrufu sağlar.',
      tags: ['alüminyum', 'enerji', 'tasarruf'],
    ),
    Question(
      id: 'recycling_2',
      text: 'Plastik şişenin doğada tamamen yok olması ne kadar sürer?',
      options: [
        Option(text: '10 yıl', score: 0),
        Option(text: '100-200 yıl', score: 1),
        Option(text: '50 yıl', score: 0),
        Option(text: '500 yıl', score: 0),
      ],
      category: 'Geri Dönüşüm',
      difficulty: DifficultyLevel.medium,
      timeLimit: 30,
      explanation: 'Plastik şişelerin doğada tamamen yok olması 100-200 yıl arasında sürebilir.',
      tags: ['plastik', 'çevre', 'atık'],
    ),
    Question(
      id: 'recycling_3',
      text: 'Geri dönüşüm için plastiğin kaç ana türü vardır?',
      options: [
        Option(text: '3', score: 0),
        Option(text: '7', score: 1),
        Option(text: '10', score: 0),
        Option(text: '5', score: 0),
      ],
      category: 'Geri Dönüşüm',
      difficulty: DifficultyLevel.hard,
      timeLimit: 35,
      explanation: 'Geri dönüşüm için plastiklerin 7 ana türü (PET, HDPE, PVC, LDPE, PP, PS, diğerleri) vardır.',
      tags: ['plastik', 'sınıflandırma', 'ayrıştırma'],
    ),
  ];

  // Ulaşım kategorisi soruları
  static final List<Question> transportationQuestions = [
    Question(
      id: 'transport_1',
      text: 'Elektrikli araçların egzoz emisyonu hakkında hangisi doğrudur?',
      options: [
        Option(text: 'Sıfır emisyon', score: 1),
        Option(text: 'Benzinli araçlardan fazla emisyon', score: 0),
        Option(text: 'Hiç emisyon üretmez', score: 0),
        Option(text: 'Dizel araçlarla aynı emisyon', score: 0),
      ],
      category: 'Ulaşım',
      difficulty: DifficultyLevel.easy,
      timeLimit: 25,
      explanation: 'Elektrikli araçlar egzozdan sıfır emisyon üretir, ancak şarj için üretilen elektriğe bağlı dolaylı emisyon vardır.',
      tags: ['elektrikli', 'emisyon', 'temiz'],
    ),
    Question(
      id: 'transport_2',
      text: 'Karbon ayak izi en düşük ulaşım yöntemi hangisidir?',
      options: [
        Option(text: 'Uçak', score: 0),
        Option(text: 'Otomobil', score: 0),
        Option(text: 'Yürüyüş veya bisiklet', score: 1),
        Option(text: 'Otobüs', score: 0),
      ],
      category: 'Ulaşım',
      difficulty: DifficultyLevel.easy,
      timeLimit: 25,
      explanation: 'Yürüyüş ve bisiklet, sıfır karbon ayak izine sahip ulaşım yöntemleridir.',
      tags: ['karbon', 'temiz', 'sağlık'],
    ),
    Question(
      id: 'transport_3',
      text: 'Bir Boeing 747 uçağın yakıt tüketimi saatte yaklaşık ne kadardır?',
      options: [
        Option(text: '2.000 litre', score: 0),
        Option(text: '10.000-12.000 litre', score: 1),
        Option(text: '5.000 litre', score: 0),
        Option(text: '20.000 litre', score: 0),
      ],
      category: 'Ulaşım',
      difficulty: DifficultyLevel.hard,
      timeLimit: 35,
      explanation: 'Bir Boeing 747, uçuş sırasında saatte yaklaşık 10.000-12.000 litre yakıt tüketir.',
      tags: ['uçak', 'yakıt', 'emisyon'],
    ),
  ];

  // Tüketim kategorisi soruları
  static final List<Question> consumptionQuestions = [
    Question(
      id: 'consumption_1',
      text: 'Sürdürülebilir beslenme için hangi et tüketimi önerilir?',
      options: [
        Option(text: 'Kırmızı et ağırlıklı', score: 0),
        Option(text: 'Beyaz et ağırlıklı', score: 0),
        Option(text: 'Daha az et, daha çok bitkisel', score: 1),
        Option(text: 'Sadece vejeteryan', score: 0),
      ],
      category: 'Tüketim',
      difficulty: DifficultyLevel.easy,
      timeLimit: 25,
      explanation: 'Daha az et tüketimi ve bitkisel beslenme, çevresel sürdürülebilirlik için önerilir.',
      tags: ['beslenme', 'et', 'bitkisel'],
    ),
    Question(
      id: 'consumption_2',
      text: 'Bir kıyafetin üretimi için ortalama ne kadar su harcanır?',
      options: [
        Option(text: '100 litre', score: 0),
        Option(text: '2.700 litre', score: 1),
        Option(text: '500 litre', score: 0),
        Option(text: '10.000 litre', score: 0),
      ],
      category: 'Tüketim',
      difficulty: DifficultyLevel.medium,
      timeLimit: 30,
      explanation: 'Bir pamuklu tişörtün üretimi için yaklaşık 2.700 litre su harcanır.',
      tags: ['tekstil', 'su', 'moda'],
    ),
    Question(
      id: 'consumption_3',
      text: 'Gıda israfının küresel karbon ayak izi hangi ülkenin emisyonlarına eşdeğerdir?',
      options: [
        Option(text: 'Almanya', score: 0),
        Option(text: 'ABD', score: 0),
        Option(text: 'Hindistan', score: 0),
        Option(text: 'Çin', score: 1),
      ],
      category: 'Tüketim',
      difficulty: DifficultyLevel.hard,
      timeLimit: 35,
      explanation: 'Küresel gıda israfının yıllık karbon ayak izi, Çin\'in toplam emisyonlarına eşdeğerdir.',
      tags: ['gıda', 'israf', 'karbon'],
    ),
  ];

  /// Tüm soruları getir
  static List<Question> getAllQuestions() {
    return [
      ...energyQuestions,
      ...waterQuestions,
      ...forestQuestions,
      ...recyclingQuestions,
      ...transportationQuestions,
      ...consumptionQuestions,
    ];
  }

  /// Kategoriye göre soruları getir
  static List<Question> getQuestionsByCategory(String category) {
    switch (category.toLowerCase()) {
      case 'enerji':
        return energyQuestions;
      case 'su':
        return waterQuestions;
      case 'orman':
        return forestQuestions;
      case 'geridönüşüm':
      case 'geri dönüşüm':
        return recyclingQuestions;
      case 'ulaşım':
      case 'ulasim':
        return transportationQuestions;
      case 'tüketim':
      case 'tuketim':
        return consumptionQuestions;
      default:
        return getAllQuestions();
    }
  }

  /// Zorluk seviyesine göre soruları getir
  static List<Question> getQuestionsByDifficulty(DifficultyLevel difficulty) {
    final allQuestions = getAllQuestions();
    return allQuestions.where((q) => q.difficulty == difficulty).toList();
  }

  /// Kategori ve zorluk seviyesine göre soruları getir
  static List<Question> getQuestions({
    String? category,
    DifficultyLevel? difficulty,
    int? limit,
  }) {
    List<Question> questions = getAllQuestions();

    if (category != null && category != 'Tümü') {
      questions = questions
          .where((q) => q.category.toLowerCase() == category.toLowerCase())
          .toList();
    }

    if (difficulty != null) {
      questions = questions.where((q) => q.difficulty == difficulty).toList();
    }

    // Soruları karıştır
    questions.shuffle();

    if (limit != null && limit > 0) {
      questions = questions.take(limit).toList();
    }

    return questions;
  }

  /// Rastgele sorular getir
  static List<Question> getRandomQuestions({
    required String category,
    required DifficultyLevel difficulty,
    required int count,
  }) {
    final filtered = getAllQuestions().where((q) {
      final categoryMatch = category == 'Tümü' || 
          q.category.toLowerCase() == category.toLowerCase();
      final difficultyMatch = q.difficulty == difficulty;
      return categoryMatch && difficultyMatch;
    }).toList();

    filtered.shuffle();
    return filtered.take(count).toList();
  }

  /// Kategoriye göre soru sayısı
  static int getQuestionCount(String category) {
    return getQuestionsByCategory(category).length;
  }

  /// Toplam soru sayısı
  static int get totalQuestionCount => getAllQuestions().length;
}
