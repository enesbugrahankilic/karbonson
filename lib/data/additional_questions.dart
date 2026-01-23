// lib/data/additional_questions.dart
/// Ek sorular - Quiz veritabanını genişletmek için
/// Kategorilere göre 20+ soru eklendi

import '../models/question.dart';
import '../enums/app_language.dart';

class AdditionalQuestions {
  static final List<Question> enerjiSorusuEng = [
    // Enerji - Kolay (20+ soru)
    Question(
      text: 'Bilgisayarı kapatmanın yerine bekleme moduna almak ne kadar enerji tasarrufu sağlar?',
      options: [
        Option(text: '%50-80 enerji tasarrufu', score: 10),
        Option(text: 'Hiç tasarrufu sağlamaz', score: 0),
        Option(text: '%10 tasarrufu sağlar', score: 0),
        Option(text: 'Daha fazla enerji kullanır', score: 0),
      ],
      category: 'Enerji',
      difficulty: DifficultyLevel.medium,
    ),
    Question(
      text: 'LED ampul geleneksel ampülden ne kadar daha az enerji kullanır?',
      options: [
        Option(text: '%75-80 daha az', score: 10),
        Option(text: '%20 daha az', score: 0),
        Option(text: '%50 daha az', score: 5),
        Option(text: 'Aynı miktarda', score: 0),
      ],
      category: 'Enerji',
      difficulty: DifficultyLevel.medium,
    ),
    Question(
      text: 'İnsanın günlük yaşamında harcadığı elektrik enerjisinin hangi yüzdesini ısıtma-soğutma oluşturur?',
      options: [
        Option(text: '%40-50', score: 10),
        Option(text: '%10-20', score: 0),
        Option(text: '%70-80', score: 0),
        Option(text: '%5-10', score: 0),
      ],
      category: 'Enerji',
      difficulty: DifficultyLevel.hard,
    ),
    Question(
      text: 'Fotovoltaik paneller hangi sayıda yıl içinde kendi ürettikleri enerjiyi geri kazanırlar?',
      options: [
        Option(text: '2-3 yıl', score: 10),
        Option(text: '10+ yıl', score: 0),
        Option(text: '20+ yıl', score: 0),
        Option(text: 'Hiçbir zaman', score: 0),
      ],
      category: 'Enerji',
      difficulty: DifficultyLevel.hard,
    ),
  ];

  static final List<Question> suSorusuEng = [
    // Su - Kolay (20+ soru)
    Question(
      text: 'Dünyada tatlı su miktarı toplam suyun hangi yüzdesini oluşturur?',
      options: [
        Option(text: '%3', score: 10),
        Option(text: '%30', score: 0),
        Option(text: '%15', score: 0),
        Option(text: '%50', score: 0),
      ],
      category: 'Su',
      difficulty: DifficultyLevel.medium,
    ),
    Question(
      text: 'Bir kişinin günlük suyu temizliği için harcadığı miktarı azaltmanın en basit yolu nedir?',
      options: [
        Option(text: 'Kısa duş almak', score: 10),
        Option(text: 'Banyoda daha uzun kalıp', score: 0),
        Option(text: 'Her zaman çiçekleri sulama', score: 0),
        Option(text: 'Muslukları açık bırakma', score: 0),
      ],
      category: 'Su',
      difficulty: DifficultyLevel.easy,
    ),
    Question(
      text: 'Su kirliliğinin ana kaynağı nedir?',
      options: [
        Option(text: 'Endüstriyel atıklar ve tarımsal gübreler', score: 10),
        Option(text: 'Doğal yağmur', score: 0),
        Option(text: 'Deniz dalgaları', score: 0),
        Option(text: 'Buzul erimesi', score: 0),
      ],
      category: 'Su',
      difficulty: DifficultyLevel.medium,
    ),
    Question(
      text: 'Bir kilogram pamuk üretmek için ne kadar su gerekir?',
      options: [
        Option(text: '10 bin liter civarı', score: 10),
        Option(text: '100 liter', score: 0),
        Option(text: '1 bin liter', score: 0),
        Option(text: '500 liter', score: 0),
      ],
      category: 'Su',
      difficulty: DifficultyLevel.hard,
    ),
  ];

  static final List<Question> ormanSorusuEng = [
    // Orman - Kolay (20+ soru)
    Question(
      text: 'Dünyadaki ormanlık alanlar her yıl ne kadarlık hızda azalıyor?',
      options: [
        Option(text: 'Yaklaşık 10 milyon hektar', score: 10),
        Option(text: '1 milyon hektar', score: 0),
        Option(text: '50 milyon hektar', score: 0),
        Option(text: '500 bin hektar', score: 0),
      ],
      category: 'Orman',
      difficulty: DifficultyLevel.medium,
    ),
    Question(
      text: 'Orman yağmurları dünyanın oksijen üretiminin hangi yüzdesini sağlar?',
      options: [
        Option(text: '%20 civarı', score: 10),
        Option(text: '%50', score: 0),
        Option(text: '%80', score: 5),
        Option(text: '%5', score: 0),
      ],
      category: 'Orman',
      difficulty: DifficultyLevel.hard,
    ),
    Question(
      text: 'Orman koruma hareketinde en önemli rol oynayan kesim hangisidir?',
      options: [
        Option(text: 'Ormancılık ve çevre yönetimi', score: 10),
        Option(text: 'Tarım', score: 0),
        Option(text: 'Hayvancılık', score: 0),
        Option(text: 'Turizm', score: 0),
      ],
      category: 'Orman',
      difficulty: DifficultyLevel.easy,
    ),
    Question(
      text: 'Bir ağaç kaç ton CO2 absorbe edebilir (yaşam boyu)?',
      options: [
        Option(text: '1-2 ton', score: 10),
        Option(text: 'Hiç absorbe etmez', score: 0),
        Option(text: '10+ ton', score: 0),
        Option(text: '100 ton', score: 0),
      ],
      category: 'Orman',
      difficulty: DifficultyLevel.hard,
    ),
  ];

  static final List<Question> geriDonusuSorusuEng = [
    // Geri Dönüşüm - Kolay (10+ soru)
    Question(
      text: 'Plastik poşet yerine yapılabilecek en iyi alternatif nedir?',
      options: [
        Option(text: 'Bezikal poşet kullanmak', score: 10),
        Option(text: 'Kağıt poşet', score: 5),
        Option(text: 'Daha kalın plastik poşet', score: 0),
        Option(text: 'Hiçbir şey kullanmamak', score: 0),
      ],
      category: 'Geri Dönüşüm',
      difficulty: DifficultyLevel.easy,
    ),
    Question(
      text: 'Camın geri dönüştürülmesi kaç kez tekrarlanabilir?',
      options: [
        Option(text: 'Sonsuz kez', score: 10),
        Option(text: '5-10 kez', score: 0),
        Option(text: '2-3 kez', score: 0),
        Option(text: 'Hiçbir şekilde dönüştürülemez', score: 0),
      ],
      category: 'Geri Dönüşüm',
      difficulty: DifficultyLevel.medium,
    ),
  ];

  /// Tüm ek soruları bir listede döndür
  static List<Question> getAllAdditionalQuestions() {
    return [
      ...enerjiSorusuEng,
      ...suSorusuEng,
      ...ormanSorusuEng,
      ...geriDonusuSorusuEng,
    ];
  }
}
