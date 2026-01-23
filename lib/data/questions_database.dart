// lib/data/questions_database.dart
import '../models/question.dart';

import '../enums/app_language.dart';
import 'additional_questions.dart';
import 'energy_questions_expansion.dart';
import 'water_questions_expansion_part2.dart';
import 'water_questions_expansion_part3.dart';
import 'forest_questions_expansion.dart';
import 'recycling_questions_expansion.dart';
import 'transportation_questions_expansion.dart';
import 'consumption_questions_expansion.dart';

class QuestionsDatabase {
  static final Map<AppLanguage, List<Question>> _questionsByLanguage = {
    AppLanguage.turkish: [
      // KOLAY SORULAR (8 soru)
      // Question 1 - Kolay
      Question(
        text: 'Karbon ayak izinizi azaltmanın en etkili yolu nedir?',
        options: [
          Option(text: 'Daha az et tüketmek', score: 10),
          Option(text: 'Gereksiz ışıkları kapatmak', score: 5),
          Option(text: 'Çok sıcak su ile duş almak', score: 0),
          Option(text: 'Eski gazeteleri atmak', score: 0),
        ],
        category: 'Enerji',
        difficulty: DifficultyLevel.easy,
      ),
      // Question 2 - Kolay
      Question(
        text: 'Yenilenebilir enerji kaynaklarından biri hangisidir?',
        options: [
          Option(text: 'Kömür', score: 0),
          Option(text: 'Güneş enerjisi', score: 10),
          Option(text: 'Doğal gaz', score: 0),
          Option(text: 'Petrol', score: 0),
        ],
        category: 'Enerji',
        difficulty: DifficultyLevel.easy,
      ),
      // Question 3 - Kolay
      Question(
        text: 'Sürdürülebilir ulaşım için en iyi seçenek nedir?',
        options: [
          Option(text: 'Uçakla seyahat', score: 0),
          Option(text: 'Bireysel araç kullanmak', score: 0),
          Option(text: 'Bisiklet kullanmak veya yürümek', score: 10),
          Option(text: 'Taksi kullanmak', score: 5),
        ],
        category: 'Ulaşım',
        difficulty: DifficultyLevel.easy,
      ),
      // Question 4 - Kolay
      Question(
        text: 'Aşağıdakilerden hangisi su tasarrufu sağlamaz?',
        options: [
          Option(text: 'Diş fırçalarken musluğu açık bırakmak', score: 0),
          Option(text: 'Duş süresini kısaltmak', score: 10),
          Option(text: 'Yağmur suyu toplamak', score: 10),
          Option(text: 'Çamaşır makinesini tam dolmadan çalıştırmak', score: 0),
        ],
        category: 'Su',
        difficulty: DifficultyLevel.easy,
      ),
      // Question 5 - Kolay
      Question(
        text: 'Geri dönüşüm kutularının amacı nedir?',
        options: [
          Option(text: 'Atıkları karıştırmak', score: 0),
          Option(text: 'Malzemeleri yeniden değerlendirmek', score: 10),
          Option(text: 'Çöpleri gizlemek', score: 0),
          Option(text: 'Enerji tüketimini artırmak', score: 0),
        ],
        category: 'Geri Dönüşüm',
        difficulty: DifficultyLevel.easy,
      ),
      // Question 6 - Kolay
      Question(
        text: 'Ağaç dikmenin çevreye katkısı nedir?',
        options: [
          Option(text: 'Hava kalitesini artırır', score: 10),
          Option(text: 'Toprak erozyonunu artırır', score: 0),
          Option(text: 'Karbondioksit miktarını artırır', score: 0),
          Option(text: 'Gürültü kirliliğini artırır', score: 0),
        ],
        category: 'Orman',
        difficulty: DifficultyLevel.easy,
      ),
      // Question 7 - Kolay
      Question(
        text: 'Atık piller nereye atılmalıdır?',
        options: [
          Option(text: 'Normal çöp kutusuna', score: 0),
          Option(text: 'Geri dönüşüm kutusuna', score: 10),
          Option(text: 'Lavaboya', score: 0),
          Option(text: 'Bahçeye gömülmeli', score: 0),
        ],
        category: 'Geri Dönüşüm',
        difficulty: DifficultyLevel.easy,
      ),
      // Question 8 - Kolay
      Question(
        text: 'Gıda israfını azaltmanın en iyi yolu nedir?',
        options: [
          Option(text: 'Daha fazla yemek sipariş etmek', score: 0),
          Option(text: 'Porsiyon kontrolü yapmak', score: 10),
          Option(text: 'Yemekleri çöpe atmak', score: 0),
          Option(text: 'Her zaman dışarıda yemek', score: 0),
        ],
        category: 'Tüketim',
        difficulty: DifficultyLevel.easy,
      ),

      // ORTA ZORLUKTA SORULAR (9 soru)
      // Question 9 - Orta
      Question(
        text: 'Evde enerji tasarrufu yapmanın en etkili yolu nedir?',
        options: [
          Option(text: 'Enerji verimli ampuller kullanmak', score: 10),
          Option(text: 'Televizyonu bekleme modunda bırakmak', score: 0),
          Option(text: 'Camları sürekli açık tutmak', score: 0),
          Option(text: 'Elektronik cihazları fişten çekmek', score: 5),
        ],
        category: 'Enerji',
        difficulty: DifficultyLevel.medium,
      ),
      // Question 10 - Orta
      Question(
        text: 'Hangisi sürdürülebilir tüketim alışkanlığıdır?',
        options: [
          Option(text: 'Yalnızca ihtiyaç kadar ürün almak', score: 10),
          Option(text: 'Sürekli yeni ürünler satın almak', score: 0),
          Option(text: 'Plastik poşetleri tek kullanmak', score: 0),
          Option(text: 'Kullanmadığı eşyaları çöpe atmak', score: 0),
        ],
        category: 'Tüketim',
        difficulty: DifficultyLevel.medium,
      ),
      // Question 11 - Orta
      Question(
        text: 'Plastik poşetlerin çevreye etkisi nedir?',
        options: [
          Option(text: 'Çok hızlı çözünür', score: 0),
          Option(text: 'Yüzlerce yıl çözünmeden kalır', score: 10),
          Option(text: 'Hiç etkisi yoktur', score: 0),
          Option(text: 'Sadece su kirliliğine sebep olur', score: 0),
        ],
        category: 'Geri Dönüşüm',
        difficulty: DifficultyLevel.medium,
      ),
      // Question 12 - Orta
      Question(
        text: 'Kompost yapmanın faydası nedir?',
        options: [
          Option(text: 'Atık miktarını artırır', score: 0),
          Option(text: 'Organik atıkları doğal gübreye dönüştürür', score: 10),
          Option(text: 'Kötü koku yaratır', score: 0),
          Option(text: 'Toprağı kirlenir', score: 0),
        ],
        category: 'Geri Dönüşüm',
        difficulty: DifficultyLevel.medium,
      ),
      // Question 13 - Orta
      Question(
        text: 'Hangi ulaşım aracı en az karbon emisyonu üretir?',
        options: [
          Option(text: 'Otomobil', score: 0),
          Option(text: 'Uçak', score: 0),
          Option(text: 'Elektrikli bisiklet', score: 10),
          Option(text: 'Motosiklet', score: 0),
        ],
        category: 'Ulaşım',
        difficulty: DifficultyLevel.medium,
      ),
      // Question 14 - Orta
      Question(
        text: 'Hangi ürün en çok su tüketir?',
        options: [
          Option(text: 'Domates', score: 0),
          Option(text: 'Pirinç', score: 10),
          Option(text: 'Elma', score: 0),
          Option(text: 'Havuç', score: 0),
        ],
        category: 'Su',
        difficulty: DifficultyLevel.medium,
      ),
      // Question 15 - Orta
      Question(
        text: 'Çevre dostu ambalaj hangisidir?',
        options: [
          Option(text: 'Plastik kaplar', score: 0),
          Option(text: 'Cam kavanozlar', score: 10),
          Option(text: 'Alüminyum folyo', score: 0),
          Option(text: 'Polistiren köpük', score: 0),
        ],
        category: 'Tüketim',
        difficulty: DifficultyLevel.medium,
      ),
      // Question 16 - Orta
      Question(
        text: 'Hangi davranış enerji tasarrufu sağlar?',
        options: [
          Option(text: 'Klima sistemini sürekli açık tutmak', score: 0),
          Option(text: 'Gereksiz cihazları kapatmak', score: 10),
          Option(text: 'Tüm ışıkları gün boyu açık bırakmak', score: 0),
          Option(
              text: 'Elektronik cihazları bekleme modunda bırakmak', score: 0),
        ],
        category: 'Enerji',
        difficulty: DifficultyLevel.medium,
      ),
      // Question 17 - Orta
      Question(
        text: 'Hangi davranış atık azaltımını destekler?',
        options: [
          Option(text: 'Tek kullanımlık ürünler tercih etmek', score: 0),
          Option(text: 'Geri dönüştürülebilir ürünler seçmek', score: 10),
          Option(text: 'Ambalajsız ürünleri reddetmek', score: 0),
          Option(text: 'Daha fazla alışveriş yapmak', score: 0),
        ],
        category: 'Tüketim',
        difficulty: DifficultyLevel.medium,
      ),

      // ZOR SORULAR (8 soru)
      // Question 18 - Zor
      Question(
        text: 'Küresel ısınmanın ana sebebi nedir?',
        options: [
          Option(text: 'Ağaç kesimi', score: 0),
          Option(text: 'Sera gazları', score: 10),
          Option(text: 'Volkan patlamaları', score: 0),
          Option(text: 'Okyanus dalgaları', score: 0),
        ],
        category: 'Orman',
        difficulty: DifficultyLevel.hard,
      ),
      // Question 19 - Zor
      Question(
        text: 'Biyoçeşitlilik nedir?',
        options: [
          Option(text: 'Sadece bitki türlerinin çeşitliliği', score: 0),
          Option(text: 'Tüm canlı türlerinin çeşitliliği', score: 10),
          Option(text: 'Sadece hayvan türlerinin çeşitliliği', score: 0),
          Option(text: 'İnsan nüfusunun çeşitliliği', score: 0),
        ],
        category: 'Orman',
        difficulty: DifficultyLevel.hard,
      ),
      // Question 20 - Zor
      Question(
        text: 'Hangi eylem ozon tabakasını korur?',
        options: [
          Option(text: 'Kloroflorokarbon kullanmak', score: 0),
          Option(text: 'Ozon dostu spreyler kullanmak', score: 10),
          Option(text: 'Endüstriyel atıkları havaya salmak', score: 0),
          Option(text: 'Aerosol ürünleri aşırı kullanmak', score: 0),
        ],
        category: 'Enerji',
        difficulty: DifficultyLevel.hard,
      ),
      // Question 21 - Zor
      Question(
        text: 'Sürdürülebilir tarım nedir?',
        options: [
          Option(text: 'Kimyasal gübrelerle besin üretimi', score: 0),
          Option(
              text: 'Çevreyi koruyarak uzun vadeli besin üretimi', score: 10),
          Option(text: 'Organik ürünleri dışlayan tarım', score: 0),
          Option(text: 'Hızlı büyüme odaklı tarım', score: 0),
        ],
        category: 'Tüketim',
        difficulty: DifficultyLevel.hard,
      ),
      // Question 22 - Zor
      Question(
        text: 'Hangi davranış su kirliliğini azaltır?',
        options: [
          Option(text: 'Deterjanları aşırı kullanmak', score: 0),
          Option(text: 'Biyolojik deterjanlar kullanmak', score: 10),
          Option(text: 'Atıkları suya atmak', score: 0),
          Option(text: 'Kanalizasyonu arıtmadan deşarj etmek', score: 0),
        ],
        category: 'Su',
        difficulty: DifficultyLevel.hard,
      ),
      // Question 23 - Zor
      Question(
        text: 'Çevre korumasında bireysel sorumluluk ne anlama gelir?',
        options: [
          Option(text: 'Sadece hükümetin sorumluluğu', score: 0),
          Option(text: 'Herkesin çevreye duyarlı davranması', score: 10),
          Option(text: 'Çevreye zarar vermek', score: 0),
          Option(text: 'Sadece büyük şirketlerin sorumluluğu', score: 0),
        ],
        category: 'Tüketim',
        difficulty: DifficultyLevel.hard,
      ),
      // Question 24 - Zor
      Question(
        text: 'Ekolojik ayak izi nedir?',
        options: [
          Option(text: 'Ayakkabı numarası', score: 0),
          Option(text: 'İnsanların doğal kaynak tüketiminin ölçüsü', score: 10),
          Option(text: 'Coğrafi sınırlar', score: 0),
          Option(text: 'Kentsel alan büyüklüğü', score: 0),
        ],
        category: 'Tüketim',
        difficulty: DifficultyLevel.hard,
      ),
    ],
    AppLanguage.english: [
      // KOLAY SORULAR (8 soru)
      // Question 1 - Easy
      Question(
        text: 'What is the most effective way to reduce your carbon footprint?',
        options: [
          Option(text: 'Eating less meat', score: 10),
          Option(text: 'Turning off unnecessary lights', score: 5),
          Option(text: 'Taking very hot showers', score: 0),
          Option(text: 'Throwing away old newspapers', score: 0),
        ],
        category: 'Energy',
        difficulty: DifficultyLevel.easy,
      ),
      // Question 2 - Easy
      Question(
        text: 'Which of the following is a renewable energy source?',
        options: [
          Option(text: 'Coal', score: 0),
          Option(text: 'Solar energy', score: 10),
          Option(text: 'Natural gas', score: 0),
          Option(text: 'Petroleum', score: 0),
        ],
        category: 'Energy',
        difficulty: DifficultyLevel.easy,
      ),
      // Question 3 - Easy
      Question(
        text: 'What is the best option for sustainable transportation?',
        options: [
          Option(text: 'Air travel', score: 0),
          Option(text: 'Using a private vehicle', score: 0),
          Option(text: 'Cycling or walking', score: 10),
          Option(text: 'Using taxis', score: 5),
        ],
        category: 'Transportation',
        difficulty: DifficultyLevel.easy,
      ),
      // Question 4 - Easy
      Question(
        text: 'Which of the following does NOT save water?',
        options: [
          Option(
              text: 'Leaving the tap running while brushing teeth', score: 0),
          Option(text: 'Taking shorter showers', score: 10),
          Option(text: 'Collecting rainwater', score: 10),
          Option(text: 'Running washing machine when not full', score: 0),
        ],
        category: 'Water',
        difficulty: DifficultyLevel.easy,
      ),
      // Question 5 - Easy
      Question(
        text: 'What is the purpose of recycling bins?',
        options: [
          Option(text: 'Mixing waste together', score: 0),
          Option(text: 'Reusing materials', score: 10),
          Option(text: 'Hiding trash', score: 0),
          Option(text: 'Increasing energy consumption', score: 0),
        ],
        category: 'Recycling',
        difficulty: DifficultyLevel.easy,
      ),
      // Question 6 - Easy
      Question(
        text: 'What is the environmental benefit of planting trees?',
        options: [
          Option(text: 'Improves air quality', score: 10),
          Option(text: 'Increases soil erosion', score: 0),
          Option(text: 'Increases carbon dioxide levels', score: 0),
          Option(text: 'Increases noise pollution', score: 0),
        ],
        category: 'Forest',
        difficulty: DifficultyLevel.easy,
      ),
      // Question 7 - Easy
      Question(
        text: 'Where should waste batteries be disposed of?',
        options: [
          Option(text: 'Regular trash bin', score: 0),
          Option(text: 'Recycling bin', score: 10),
          Option(text: 'Down the drain', score: 0),
          Option(text: 'Buried in the garden', score: 0),
        ],
        category: 'Recycling',
        difficulty: DifficultyLevel.easy,
      ),
      // Question 8 - Easy
      Question(
        text: 'What is the best way to reduce food waste?',
        options: [
          Option(text: 'Ordering more food', score: 0),
          Option(text: 'Controlling portion sizes', score: 10),
          Option(text: 'Throwing away food', score: 0),
          Option(text: 'Always eating out', score: 0),
        ],
        category: 'Consumption',
        difficulty: DifficultyLevel.easy,
      ),

      // ORTA ZORLUKTA SORULAR (9 soru)
      // Question 9 - Medium
      Question(
        text: 'What is the most effective way to save energy at home?',
        options: [
          Option(text: 'Using energy-efficient light bulbs', score: 10),
          Option(text: 'Leaving the TV on standby mode', score: 0),
          Option(text: 'Keeping windows open all the time', score: 0),
          Option(text: 'Unplugging electronic devices', score: 5),
        ],
        category: 'Energy',
        difficulty: DifficultyLevel.medium,
      ),
      // Question 10 - Medium
      Question(
        text: 'Which is a sustainable consumption habit?',
        options: [
          Option(text: 'Buying only what you need', score: 10),
          Option(text: 'Constantly buying new products', score: 0),
          Option(text: 'Using plastic bags only once', score: 0),
          Option(text: 'Throwing away unused items', score: 0),
        ],
        category: 'Consumption',
        difficulty: DifficultyLevel.medium,
      ),
      // Question 11 - Medium
      Question(
        text: 'What is the environmental impact of plastic bags?',
        options: [
          Option(text: 'They dissolve very quickly', score: 0),
          Option(text: 'They persist for hundreds of years', score: 10),
          Option(text: 'They have no impact', score: 0),
          Option(text: 'They only cause water pollution', score: 0),
        ],
        category: 'Recycling',
        difficulty: DifficultyLevel.medium,
      ),
      // Question 12 - Medium
      Question(
        text: 'What is the benefit of composting?',
        options: [
          Option(text: 'Increases waste volume', score: 0),
          Option(
              text: 'Converts organic waste into natural fertilizer',
              score: 10),
          Option(text: 'Creates bad odors', score: 0),
          Option(text: 'Pollutes the soil', score: 0),
        ],
        category: 'Recycling',
        difficulty: DifficultyLevel.medium,
      ),
      // Question 13 - Medium
      Question(
        text:
            'Which transportation vehicle produces the least carbon emissions?',
        options: [
          Option(text: 'Car', score: 0),
          Option(text: 'Airplane', score: 0),
          Option(text: 'Electric bicycle', score: 10),
          Option(text: 'Motorcycle', score: 0),
        ],
        category: 'Transportation',
        difficulty: DifficultyLevel.medium,
      ),
      // Question 14 - Medium
      Question(
        text: 'Which product consumes the most water?',
        options: [
          Option(text: 'Tomatoes', score: 0),
          Option(text: 'Rice', score: 10),
          Option(text: 'Apples', score: 0),
          Option(text: 'Carrots', score: 0),
        ],
        category: 'Water',
        difficulty: DifficultyLevel.medium,
      ),
      // Question 15 - Medium
      Question(
        text: 'Which packaging is environmentally friendly?',
        options: [
          Option(text: 'Plastic containers', score: 0),
          Option(text: 'Glass jars', score: 10),
          Option(text: 'Aluminum foil', score: 0),
          Option(text: 'Polystyrene foam', score: 0),
        ],
        category: 'Consumption',
        difficulty: DifficultyLevel.medium,
      ),
      // Question 16 - Medium
      Question(
        text: 'Which behavior saves energy?',
        options: [
          Option(text: 'Keeping air conditioning on all the time', score: 0),
          Option(text: 'Turning off unnecessary devices', score: 10),
          Option(text: 'Keeping all lights on during the day', score: 0),
          Option(text: 'Leaving electronic devices in standby mode', score: 0),
        ],
        category: 'Energy',
        difficulty: DifficultyLevel.medium,
      ),
      // Question 17 - Medium
      Question(
        text: 'Which behavior supports waste reduction?',
        options: [
          Option(text: 'Preferring single-use products', score: 0),
          Option(text: 'Choosing recyclable products', score: 10),
          Option(text: 'Rejecting unpackaged products', score: 0),
          Option(text: 'Shopping more', score: 0),
        ],
        category: 'Consumption',
        difficulty: DifficultyLevel.medium,
      ),

      // ZOR SORULAR (8 soru)
      // Question 18 - Hard
      Question(
        text: 'What is the main cause of global warming?',
        options: [
          Option(text: 'Deforestation', score: 0),
          Option(text: 'Greenhouse gases', score: 10),
          Option(text: 'Volcanic eruptions', score: 0),
          Option(text: 'Ocean waves', score: 0),
        ],
        category: 'Forest',
        difficulty: DifficultyLevel.hard,
      ),
      // Question 19 - Hard
      Question(
        text: 'What is biodiversity?',
        options: [
          Option(text: 'Only diversity of plant species', score: 0),
          Option(text: 'Diversity of all living species', score: 10),
          Option(text: 'Only diversity of animal species', score: 0),
          Option(text: 'Diversity of human population', score: 0),
        ],
        category: 'Forest',
        difficulty: DifficultyLevel.hard,
      ),
      // Question 20 - Hard
      Question(
        text: 'Which action protects the ozone layer?',
        options: [
          Option(text: 'Using chlorofluorocarbons', score: 0),
          Option(text: 'Using ozone-friendly sprays', score: 10),
          Option(text: 'Releasing industrial waste into air', score: 0),
          Option(text: 'Overusing aerosol products', score: 0),
        ],
        category: 'Energy',
        difficulty: DifficultyLevel.hard,
      ),
      // Question 21 - Hard
      Question(
        text: 'What is sustainable agriculture?',
        options: [
          Option(text: 'Food production with chemical fertilizers', score: 0),
          Option(
              text:
                  'Long-term food production while protecting the environment',
              score: 10),
          Option(text: 'Agriculture that excludes organic products', score: 0),
          Option(text: 'Agriculture focused on rapid growth', score: 0),
        ],
        category: 'Consumption',
        difficulty: DifficultyLevel.hard,
      ),
      // Question 22 - Hard
      Question(
        text: 'Which behavior reduces water pollution?',
        options: [
          Option(text: 'Using excessive detergents', score: 0),
          Option(text: 'Using biological detergents', score: 10),
          Option(text: 'Throwing waste into water', score: 0),
          Option(text: 'Discharging untreated sewage', score: 0),
        ],
        category: 'Water',
        difficulty: DifficultyLevel.hard,
      ),
      // Question 23 - Hard
      Question(
        text:
            'What does individual responsibility in environmental protection mean?',
        options: [
          Option(text: 'Only the government\'s responsibility', score: 0),
          Option(
              text: 'Everyone behaving environmentally conscious', score: 10),
          Option(text: 'Harming the environment', score: 0),
          Option(text: 'Only large companies\' responsibility', score: 0),
        ],
        category: 'Consumption',
        difficulty: DifficultyLevel.hard,
      ),
      // Question 24 - Hard
      Question(
        text: 'What is ecological footprint?',
        options: [
          Option(text: 'Shoe size', score: 0),
          Option(
              text: 'Measure of human natural resource consumption', score: 10),
          Option(text: 'Geographic boundaries', score: 0),
          Option(text: 'Size of urban areas', score: 0),
        ],
        category: 'Consumption',
        difficulty: DifficultyLevel.hard,
      ),
    ],
  };

  static List<Question> getQuestions(AppLanguage language) {
    final baseQuestions = List<Question>.from(_questionsByLanguage[language] ??
        _questionsByLanguage[AppLanguage.turkish]!);

    // ✅ Ek soruları da ekle
    if (language == AppLanguage.turkish) {
      baseQuestions.addAll(AdditionalQuestions.getAllAdditionalQuestions());
      baseQuestions.addAll(EnergyQuestionsExpansion.getTurkishEnergyQuestions());
      baseQuestions.addAll(WaterQuestionsExpansionPart2.getTurkishWaterQuestionsPart2());
      baseQuestions.addAll(WaterQuestionsExpansionPart3.getTurkishWaterQuestionsPart3());
      baseQuestions.addAll(ForestQuestionsExpansion.getTurkishForestQuestions());
      baseQuestions.addAll(RecyclingQuestionsExpansion.getTurkishRecyclingQuestions());
      baseQuestions.addAll(TransportationQuestionsExpansion.getTurkishTransportationQuestions());
      baseQuestions.addAll(ConsumptionQuestionsExpansion.getTurkishConsumptionQuestions());
    }

    return baseQuestions;
  }

  static List<Question> getAllQuestions() {
    return List.from(_questionsByLanguage[
        AppLanguage.turkish]!); // Return Turkish as default
  }

  static int getTotalQuestions(AppLanguage language) {
    return _questionsByLanguage[language]?.length ?? 0;
  }

  static List<Question> getRandomQuestions(AppLanguage language, int count) {
    final questions = getQuestions(language);
    questions.shuffle();
    return questions.take(count).toList();
  }

  // YENİ ZORLUK SEVİYESİ FİLTRELEME METHOD'LARI

  /// Belirli bir zorluk seviyesindeki soruları getirir
  static List<Question> getQuestionsByDifficulty(
      AppLanguage language, DifficultyLevel difficulty) {
    final allQuestions = getQuestions(language);
    return allQuestions
        .where((question) => question.difficulty == difficulty)
        .toList();
  }

  /// Belirli zorluk seviyesinden rastgele sorular getirir
  static List<Question> getRandomQuestionsByDifficulty(
      AppLanguage language, DifficultyLevel difficulty, int count) {
    final questions = getQuestionsByDifficulty(language, difficulty);
    questions.shuffle();
    return questions.take(count).toList();
  }

  /// Karışık zorluk seviyelerinde sorular getirir (kolay:orta:zor = 1:1:1 oranında)
  /// SORU SAYISI SENKRONİZASYONU DÜZELTİLDİ - Yuvarlama hatası giderildi
  static List<Question> getMixedDifficultyQuestions(
      AppLanguage language, int totalQuestions) {
    final easyQuestions = getQuestionsByDifficulty(language, DifficultyLevel.easy);
    final mediumQuestions =
        getQuestionsByDifficulty(language, DifficultyLevel.medium);
    final hardQuestions = getQuestionsByDifficulty(language, DifficultyLevel.hard);

    // Her seviyeden eşit sayıda soru al (yuvarlama hatası önlemek için floor kullan)
    final basePerLevel = totalQuestions ~/ 3;
    final remainder = totalQuestions % 3;
    
    // İlk seviyelere remainder kadar fazla soru ekle
    final easyCount = basePerLevel + (remainder > 0 ? 1 : 0);
    final mediumCount = basePerLevel + (remainder > 1 ? 1 : 0);
    final hardCount = basePerLevel;

    final selectedQuestions = <Question>[];

    // Kolay sorular
    final shuffledEasy = List<Question>.from(easyQuestions)..shuffle();
    final actualEasyCount = easyCount.clamp(0, shuffledEasy.length);
    selectedQuestions.addAll(shuffledEasy.take(actualEasyCount));

    // Orta sorular
    final shuffledMedium = List<Question>.from(mediumQuestions)..shuffle();
    final actualMediumCount = mediumCount.clamp(0, shuffledMedium.length);
    selectedQuestions.addAll(shuffledMedium.take(actualMediumCount));

    // Zor sorular
    final shuffledHard = List<Question>.from(hardQuestions)..shuffle();
    final actualHardCount = hardCount.clamp(0, shuffledHard.length);
    selectedQuestions.addAll(shuffledHard.take(actualHardCount));

    // Eğer toplam soru sayısı yeterli değilse, diğer seviyelerden ekle
    final allAvailableQuestions = [...easyQuestions, ...mediumQuestions, ...hardQuestions];
    final usedTexts = selectedQuestions.map((q) => q.text).toSet();
    
    while (selectedQuestions.length < totalQuestions) {
      final remaining = allAvailableQuestions
          .where((q) => !usedTexts.contains(q.text))
          .toList();
      
      if (remaining.isEmpty) break;
      
      remaining.shuffle();
      selectedQuestions.add(remaining.first);
      usedTexts.add(remaining.first.text);
    }

    selectedQuestions.shuffle();
    return selectedQuestions.take(totalQuestions).toList();
  }

  /// Her zorluk seviyesindeki soru sayısını getirir
  static Map<DifficultyLevel, int> getQuestionCountByDifficulty(
      AppLanguage language) {
    final allQuestions = getQuestions(language);
    final countMap = <DifficultyLevel, int>{};

    for (final difficulty in DifficultyLevel.values) {
      countMap[difficulty] = allQuestions
          .where((question) => question.difficulty == difficulty)
          .length;
    }

    return countMap;
  }

  /// Belirli bir kategorideki soruları zorluk seviyesine göre getirir
  static List<Question> getQuestionsByCategoryAndDifficulty(
      AppLanguage language, String category, DifficultyLevel difficulty) {
    final allQuestions = getQuestions(language);
    return allQuestions
        .where((question) =>
            question.category == category && question.difficulty == difficulty)
        .toList();
  }
}
