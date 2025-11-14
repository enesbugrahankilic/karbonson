// lib/services/quiz_logic.dart
import '../models/question.dart'; 
import 'dart:math';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:firebase_auth/firebase_auth.dart';

class QuizLogic {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  int _currentScore = 0;
  int _highScore = 0;
  List<String> _answeredQuestions = [];
  List<Question> _allQuestions = [
    // Soru 1
    Question(
      text: 'Karbon ayak izinizi azaltmanın en etkili yolu nedir?',
      options: [
        Option(text: 'Daha az et tüketmek', score: 10),
        Option(text: 'Gereksiz ışıkları kapatmak', score: 5),
        Option(text: 'Çok sıcak su ile duş almak', score: 0),
        Option(text: 'Eski gazeteleri atmak', score: 0),
      ],
    ),
    // Soru 2
    Question(
      text: 'Yenilenebilir enerji kaynaklarından biri hangisidir?',
      options: [
        Option(text: 'Kömür', score: 0),
        Option(text: 'Güneş enerjisi', score: 10),
        Option(text: 'Doğal gaz', score: 0),
        Option(text: 'Petrol', score: 0),
      ],
    ),
    // Soru 3
    Question(
      text: 'Sürdürülebilir ulaşım için en iyi seçenek nedir?',
      options: [
        Option(text: 'Uçakla seyahat', score: 0),
        Option(text: 'Bireysel araç kullanmak', score: 0),
        Option(text: 'Bisiklet kullanmak veya yürümek', score: 10),
        Option(text: 'Taksi kullanmak', score: 5),
      ],
    ),
    // Soru 4
    Question(
      text: 'Aşağıdakilerden hangisi su tasarrufu sağlamaz?',
      options: [
        Option(text: 'Diş fırçalarken musluğu açık bırakmak', score: 0),
        Option(text: 'Duş süresini kısaltmak', score: 10),
        Option(text: 'Yağmur suyu toplamak', score: 10),
        Option(text: 'Çamaşır makinesini tam dolmadan çalıştırmak', score: 0),
      ],
    ),
    // Soru 5
    Question(
      text: 'Geri dönüşüm kutularının amacı nedir?',
      options: [
        Option(text: 'Atıkları karıştırmak', score: 0),
        Option(text: 'Malzemeleri yeniden değerlendirmek', score: 10),
        Option(text: 'Çöpleri gizlemek', score: 0),
        Option(text: 'Enerji tüketimini artırmak', score: 0),
      ],
    ),
    // Soru 6
    Question(
      text: 'Evde enerji tasarrufu yapmanın en etkili yolu nedir?',
      options: [
        Option(text: 'Enerji verimli ampuller kullanmak', score: 10),
        Option(text: 'Televizyonu bekleme modunda bırakmak', score: 0),
        Option(text: 'Camları sürekli açık tutmak', score: 0),
        Option(text: 'Elektronik cihazları fişten çekmek', score: 5),
      ],
    ),
    // Soru 7
    Question(
      text: 'Ağaç dikmenin çevreye katkısı nedir?',
      options: [
        Option(text: 'Hava kalitesini artırır', score: 10),
        Option(text: 'Toprak erozyonunu artırır', score: 0),
        Option(text: 'Karbondioksit miktarını artırır', score: 0),
        Option(text: 'Gürültü kirliliğini artırır', score: 0),
      ],
    ),
    // Soru 8
    Question(
      text: 'Hangisi sürdürülebilir tüketim alışkanlığıdır?',
      options: [
        Option(text: 'Yalnızca ihtiyaç kadar ürün almak', score: 10),
        Option(text: 'Sürekli yeni ürünler satın almak', score: 0),
        Option(text: 'Plastik poşetleri tek kullanmak', score: 0),
        Option(text: 'Kullanmadığı eşyaları çöpe atmak', score: 0),
      ],
    ),
    // Soru 9
    Question(
      text: 'Atık piller nereye atılmalıdır?',
      options: [
        Option(text: 'Normal çöp kutusuna', score: 0),
        Option(text: 'Geri dönüşüm kutusuna', score: 10),
        Option(text: 'Lavaboya', score: 0),
        Option(text: 'Bahçeye gömülmeli', score: 0),
      ],
    ),
    // Soru 10
    Question(
      text: 'Hangisi çevreye zarar verir?',
      options: [
        Option(text: 'Denizlere atık boşaltmak', score: 0),
        Option(text: 'Kağıtları geri dönüştürmek', score: 10),
        Option(text: 'Toplu taşımayı tercih etmek', score: 10),
        Option(text: 'Ormanlık alanları korumak', score: 10),
      ],
    ),
    // Soru 11
    Question(
      text: 'Plastik atıkları azaltmak için ne yapılabilir?',
      options: [
        Option(text: 'Bez çanta kullanmak', score: 10),
        Option(text: 'Her alışverişte poşet almak', score: 0),
        Option(text: 'Plastik şişeleri çöpe atmak', score: 0),
        Option(text: 'Cam şişeleri atmak', score: 5),
      ],
    ),
    // Soru 12
    Question(
      text: 'Hangisi iklim değişikliğine katkı sağlar?',
      options: [
        Option(text: 'Fosil yakıt kullanımı', score: 0),
        Option(text: 'Rüzgar türbinleri kurmak', score: 10),
        Option(text: 'Ağaçlandırma yapmak', score: 10),
        Option(text: 'Güneş panelleri kullanmak', score: 10),
      ],
    ),
    // Soru 13
    Question(
      text: 'Elektrikli araçların avantajı nedir?',
      options: [
        Option(text: 'Daha az karbon salımı yapmaları', score: 10),
        Option(text: 'Fazla gürültü çıkarmaları', score: 0),
        Option(text: 'Fosil yakıt tüketmeleri', score: 0),
        Option(text: 'Daha fazla egzoz gazı yaymaları', score: 0),
      ],
    ),
    // Soru 14
    Question(
      text: 'Evlerde enerji israfını azaltmak için ne yapılabilir?',
      options: [
        Option(text: 'Cihazları kullanılmadığında kapatmak', score: 10),
        Option(text: 'Bütün lambaları açık bırakmak', score: 0),
        Option(text: 'Klimayı gereksiz çalıştırmak', score: 0),
        Option(text: 'Yüksek wattlı ampuller kullanmak', score: 0),
      ],
    ),
    // Soru 15
    Question(
      text: 'Hangisi geri dönüştürülebilir bir atıktır?',
      options: [
        Option(text: 'Cam şişe', score: 10),
        Option(text: 'Yemek artığı', score: 0),
        Option(text: 'Kullanılmış peçete', score: 0),
        Option(text: 'Plastik kap', score: 10),
      ],
    ),
    // Soru 16
    Question(
      text: 'Hangisi ekosisteme zarar verir?',
      options: [
        Option(text: 'Atıkları doğaya bırakmak', score: 0),
        Option(text: 'Geri dönüşüm yapmak', score: 10),
        Option(text: 'Doğal yaşamı korumak', score: 10),
        Option(text: 'Enerji tasarrufu sağlamak', score: 10),
      ],
    ),
    // Soru 17
    Question(
      text: 'Toprak kirliliğini azaltmak için ne yapılmalıdır?',
      options: [
        Option(text: 'Kimyasal atıkları doğaya dökmemek', score: 10),
        Option(text: 'Plastik gömmek', score: 0),
        Option(text: 'Zehirli maddeleri yakmak', score: 0),
        Option(text: 'Evsel atıkları doğaya bırakmak', score: 0),
      ],
    ),
    // Soru 18
    Question(
      text: 'Hangisi doğayı koruma yöntemidir?',
      options: [
        Option(text: 'Geri dönüşüm yapmak', score: 10),
        Option(text: 'Orman yangınlarına sebep olmak', score: 0),
        Option(text: 'Ağaçları kesmek', score: 0),
        Option(text: 'Atıkları doğaya atmak', score: 0),
      ],
    ),
    // Soru 19
    Question(
      text: 'Enerji verimliliği ne anlama gelir?',
      options: [
        Option(text: 'Aynı işi daha az enerjiyle yapmak', score: 10),
        Option(text: 'Enerjiyi boşa harcamak', score: 0),
        Option(text: 'Tüm cihazları aynı anda çalıştırmak', score: 0),
        Option(text: 'Yüksek enerji tüketmek', score: 0),
      ],
    ),
    // Soru 20
    Question(
      text: 'Hangisi sürdürülebilir bir yaşam tarzına örnektir?',
      options: [
        Option(text: 'Yerel ürünleri tercih etmek', score: 10),
        Option(text: 'Yiyecekleri israf etmek', score: 0),
        Option(text: 'Gereksiz alışveriş yapmak', score: 0),
        Option(text: 'Tek kullanımlık ürünleri tercih etmek', score: 0),
      ],
    ),
    // Soru 21
    Question(
      text: 'Küresel ısınmanın en belirgin sonucu nedir?',
      options: [
        Option(text: 'Sıcaklık düşüşleri', score: 0),
        Option(text: 'Buzulların erimesi ve deniz seviyesinin yükselmesi', score: 10),
        Option(text: 'Yağışların azalması', score: 5),
        Option(text: 'Rüzgar hızının azalması', score: 0),
      ],
    ),
    // Soru 22
    Question(
      text: 'Su tasarrufu için banyoda ne yapılmalıdır?',
      options: [
        Option(text: 'Banyo yapmayı tercih etmek', score: 0),
        Option(text: 'Kısa süreli duş almak', score: 10),
        Option(text: 'Sıcak suyu sürekli akıtmak', score: 0),
        Option(text: 'Muslukları tamir etmemek', score: 0),
      ],
    ),
    // Soru 23
    Question(
      text: 'Hangi ulaşım aracı en çevre dostudur?',
      options: [
        Option(text: 'Özel otomobil', score: 0),
        Option(text: 'Otobüs', score: 5),
        Option(text: 'Elektrikli tren', score: 10),
        Option(text: 'Motosiklet', score: 0),
      ],
    ),
    // Soru 24
    Question(
      text: 'Hangi atık türü kompost yapılabilir?',
      options: [
        Option(text: 'Plastik şişe', score: 0),
        Option(text: 'Metal kutu', score: 0),
        Option(text: 'Meyve ve sebze kabukları', score: 10),
        Option(text: 'Cam kırıkları', score: 0),
      ],
    ),
    // Soru 25
    Question(
      text: 'Ağaçların atmosferdeki rolü nedir?',
      options: [
        Option(text: 'Oksijen üretir ve karbondioksiti emerler', score: 10),
        Option(text: 'Su buharı miktarını azaltırlar', score: 0),
        Option(text: 'Metan gazı yayarlar', score: 0),
        Option(text: 'Hava basıncını artırırlar', score: 0),
      ],
    ),
    // Soru 26
    Question(
      text: 'Sera gazı emisyonlarının ana kaynağı nedir?',
      options: [
        Option(text: 'Volkanik patlamalar', score: 0),
        Option(text: 'Güneş fırtınaları', score: 0),
        Option(text: 'Fosil yakıtların yakılması', score: 10),
        Option(text: 'Okyanus akıntıları', score: 0),
      ],
    ),
    // Soru 27
    Question(
      text: 'Ekolojik ayak izi ne anlama gelir?',
      options: [
        Option(text: 'Bir kişinin ayakkabı numarası', score: 0),
        Option(text: 'İnsanların doğadan talep ettiği kaynak miktarı', score: 10),
        Option(text: 'Bir ülkenin yüzölçümü', score: 0),
        Option(text: 'Hayvanların yaşam alanı', score: 0),
      ],
    ),
    // Soru 28
    Question(
      text: 'Doğal kaynakların korunması neden önemlidir?',
      options: [
        Option(text: 'Sadece gelecek nesiller için', score: 5),
        Option(text: 'Ekonomik büyümeyi yavaşlatmak için', score: 0),
        Option(text: 'Yaşamın devamlılığı ve sürdürülebilirlik için', score: 10),
        Option(text: 'Bütün canlı türlerini azaltmak için', score: 0),
      ],
    ),
    // Soru 29
    Question(
      text: 'Sürdürülebilir tarımın amacı nedir?',
      options: [
        Option(text: 'Kimyasal gübre kullanımını artırmak', score: 0),
        Option(text: 'Doğal kaynakları tüketmek', score: 0),
        Option(text: 'Toprağı koruyarak verimli ürün elde etmek', score: 10),
        Option(text: 'Tek bir ürün çeşidi yetiştirmek', score: 0),
      ],
    ),
    // Soru 30
    Question(
      text: 'Geri dönüştürülemeyen atıklara örnek nedir?',
      options: [
        Option(text: 'Gazeteler', score: 0),
        Option(text: 'Tıbbi atıklar (bulaşıcı)', score: 10),
        Option(text: 'Alüminyum kutular', score: 0),
        Option(text: 'Plastik torbalar', score: 5),
      ],
    ),
    // Soru 31
    Question(
      text: 'Hangi eylem "yeniden kullan" ilkesine örnektir?',
      options: [
        Option(text: 'Eski bir kavanozu baharatlık yapmak', score: 10),
        Option(text: 'Plastik şişeyi çöpe atmak', score: 0),
        Option(text: 'Eskimiş kıyafeti yakmak', score: 0),
        Option(text: 'Her şeyi geri dönüşüme vermek', score: 5),
      ],
    ),
    // Soru 32
    Question(
      text: 'Ormanların yok edilmesinin sonuçlarından biri nedir?',
      options: [
        Option(text: 'Biyoçeşitliliğin artması', score: 0),
        Option(text: 'Hava sıcaklığının düşmesi', score: 0),
        Option(text: 'Sel ve erozyon riskinin artması', score: 10),
        Option(text: 'Daha fazla oksijen üretimi', score: 0),
      ],
    ),
    // Soru 33
    Question(
      text: 'Yerel ve mevsimlik ürünler tüketmenin avantajı nedir?',
      options: [
        Option(text: 'Gıda maliyetini artırmak', score: 0),
        Option(text: 'Tarımsal ilaç kullanımını artırmak', score: 0),
        Option(text: 'Taşıma kaynaklı karbon salımını azaltmak', score: 10),
        Option(text: 'Ürün çeşitliliğini azaltmak', score: 0),
      ],
    ),
    // Soru 34
    Question(
      text: 'Binalarda enerji verimliliğini artırmanın en önemli yolu nedir?',
      options: [
        Option(text: 'Pencereleri açık bırakmak', score: 0),
        Option(text: 'İzolasyon (yalıtım) yapmak', score: 10),
        Option(text: 'Klimayı sürekli çalıştırmak', score: 0),
        Option(text: 'Tek camlı pencereler kullanmak', score: 0),
      ],
    ),
    // Soru 35
    Question(
      text: 'Okyanuslardaki plastik kirliliğinin temel kaynağı nedir?',
      options: [
        Option(text: 'Gemi kazaları', score: 5),
        Option(text: 'Karadan gelen evsel ve sanayi atıkları', score: 10),
        Option(text: 'Volkanik küller', score: 0),
        Option(text: 'Deniz bitkileri', score: 0),
      ],
    ),
    // Soru 36
    Question(
      text: 'Güneş enerjisi sistemlerinin çevresel avantajı nedir?',
      options: [
        Option(text: 'Sıcaklığı yükseltmeleri', score: 0),
        Option(text: 'Sera gazı salımı yapmamaları', score: 10),
        Option(text: 'Yüksek gürültü çıkarmaları', score: 0),
        Option(text: 'Fosil yakıt kullanmaları', score: 0),
      ],
    ),
    // Soru 37
    Question(
      text: 'Hangi su kirliliği türü, su canlılarının oksijenini tüketir?',
      options: [
        Option(text: 'Isı kirliliği', score: 5),
        Option(text: 'Organik atık kirliliği', score: 10),
        Option(text: 'Plastik kirliliği', score: 5),
        Option(text: 'Radyoaktif kirlilik', score: 0),
      ],
    ),
    // Soru 38
    Question(
      text: 'Düşük su tüketimli (Az akımlı) duş başlıkları neden önemlidir?',
      options: [
        Option(text: 'Duş süresini uzattıkları için', score: 0),
        Option(text: 'Su ve enerji tasarrufu sağladıkları için', score: 10),
        Option(text: 'Daha az temizledikleri için', score: 0),
        Option(text: 'Daha pahalı oldukları için', score: 0),
      ],
    ),
    // Soru 39
    Question(
      text: 'Biyolojik çeşitliliğin korunması ne anlama gelir?',
      options: [
        Option(text: 'Sadece insan türünü korumak', score: 0),
        Option(text: 'Tüm canlı türlerini ve ekosistemlerini korumak', score: 10),
        Option(text: 'Yalnızca egzotik hayvanları korumak', score: 0),
        Option(text: 'Yeni türler yaratmak', score: 0),
      ],
    ),
    // Soru 40
    Question(
      text: 'Hangi kimyasal kirlilik, su yollarında yosun patlamasına neden olur?',
      options: [
        Option(text: 'Petrol', score: 0),
        Option(text: 'Ağır metaller', score: 0),
        Option(text: 'Azot ve fosfat (Gübre atıkları)', score: 10),
        Option(text: 'Tuz', score: 0),
      ],
    ),
    // Soru 41
    Question(
      text: 'Doğada çözünme süresi en uzun olan madde hangisidir?',
      options: [
        Option(text: 'Elma çöpü', score: 0),
        Option(text: 'Kağıt', score: 0),
        Option(text: 'Cam şişe', score: 5), // Geri dönüştürülmezse binlerce yıl
        Option(text: 'Plastik şişe', score: 10),
      ],
    ),
    // Soru 42
    Question(
      text: 'Şarj edilebilir piller kullanmak neye katkı sağlar?',
      options: [
        Option(text: 'Daha fazla atık üretimine', score: 0),
        Option(text: 'Kimyasal atık miktarını azaltmaya', score: 10),
        Option(text: 'Enerji tüketimini artırmaya', score: 0),
        Option(text: 'Daha zayıf performans sağlamaya', score: 0),
      ],
    ),
    // Soru 43
    Question(
      text: 'Sürdürülebilir kalkınmanın en temel hedefi nedir?',
      options: [
        Option(text: 'Sadece ekonomik büyümeye odaklanmak', score: 0),
        Option(text: 'Doğal kaynakları sınırsız kullanmak', score: 0),
        Option(text: 'Çevre, toplum ve ekonomiyi dengelemek', score: 10),
        Option(text: 'Nüfus artışını hızlandırmak', score: 0),
      ],
    ),
    // Soru 44
    Question(
      text: 'Toplu taşıma kullanmanın bireysel çevreye katkısı nedir?',
      options: [
        Option(text: 'Daha fazla trafik yaratmak', score: 0),
        Option(text: 'Kişi başına düşen karbon salımını azaltmak', score: 10),
        Option(text: 'Daha fazla yakıt tüketmek', score: 0),
        Option(text: 'Yolculuk süresini uzatmak', score: 5),
      ],
    ),
    // Soru 45
    Question(
      text: 'Gıda israfını azaltmak için ne yapılabilir?',
      options: [
        Option(text: 'Gereğinden fazla yemek pişirmek', score: 0),
        Option(text: 'Son kullanma tarihi geçen gıdaları saklamak', score: 0),
        Option(text: 'Alışveriş listesi yapmak ve porsiyonları ayarlamak', score: 10),
        Option(text: 'Bütün yiyecekleri atmak', score: 0),
      ],
    ),
    // Soru 46
    Question(
      text: 'Hangi doğal kaynak, yenilenemez bir enerji kaynağıdır?',
      options: [
        Option(text: 'Rüzgar', score: 0),
        Option(text: 'Güneş', score: 0),
        Option(text: 'Petrol', score: 10),
        Option(text: 'Su', score: 0),
      ],
    ),
    // Soru 47
    Question(
      text: 'Su kirliliğine neden olan en büyük etkenlerden biri nedir?',
      options: [
        Option(text: 'Evsel ve endüstriyel atık sular', score: 10),
        Option(text: 'Balık avcılığı', score: 0),
        Option(text: 'Buharlaşma', score: 0),
        Option(text: 'Yağmur yağması', score: 0),
      ],
    ),
    // Soru 48
    Question(
      text: 'Geri dönüşümde kâğıt atıkların toplanması neyi engeller?',
      options: [
        Option(text: 'Ağaç kesimini azaltmaya yardımcı olur', score: 10),
        Option(text: 'Daha fazla çöp sahası ihtiyacını artırır', score: 0),
        Option(text: 'Enerji tüketimini artırır', score: 0),
        Option(text: 'Kâğıt kalitesini düşürür', score: 0),
      ],
    ),
    // Soru 49
    Question(
      text: 'Çevre dostu temizlik ürünleri kullanmanın avantajı nedir?',
      options: [
        Option(text: 'Daha pahalı olmaları', score: 0),
        Option(text: 'Su kaynaklarına daha az kimyasal salmaları', score: 10),
        Option(text: 'Daha zor temizlemeleri', score: 0),
        Option(text: 'Daha çok köpürmeleri', score: 0),
      ],
    ),
    // Soru 50
    Question(
      text: 'İklim değişikliği ile mücadelede bireylerin en temel sorumluluğu nedir?',
      options: [
        Option(text: 'Sürekli seyahat etmek', score: 0),
        Option(text: 'Tüketimi artırmak', score: 0),
        Option(text: 'Karbon ayak izini azaltacak bilinçli kararlar almak', score: 10),
        Option(text: 'Gelişmeleri takip etmemek', score: 0),
      ],
    ),
  ];

  List<Question> questions = [];
  final Random _random = Random();

  QuizLogic() {
    _loadHighScore();
    _selectRandomQuestions(5);
  }

  Future<void> _loadHighScore() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      _highScore = prefs.getInt('highScore') ?? 0;
    } catch (e) {
      print('Error loading high score: $e');
    }
  }

  Future<void> _saveHighScore() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setInt('highScore', _highScore);
      
      final userId = FirebaseAuth.instance.currentUser?.uid;
      if (userId != null) {
        await _firestore.collection('scores').doc(userId).set({
          'highScore': _highScore,
          'lastUpdated': FieldValue.serverTimestamp(),
        }, SetOptions(merge: true));
      }
    } catch (e) {
      print('Error saving high score: $e');
    }
  }
  
  void _selectRandomQuestions(int count) {
    var availableQuestions = _allQuestions.where((q) => !_answeredQuestions.contains(q.text)).toList();
    if (availableQuestions.isEmpty) {
      _answeredQuestions.clear();
      availableQuestions = _allQuestions;
    }
    
    availableQuestions.shuffle(_random);
    questions = availableQuestions.take(min(count, availableQuestions.length)).toList();
    questions.forEach((q) => _answeredQuestions.add(q.text));
  }

  Future<List<Question>> getQuestions() async {
    return questions;
  }

  Future<bool> checkAnswer(Question question, String answer) async {
    Option selectedOption = question.options.firstWhere(
      (option) => option.text == answer,
      orElse: () => Option(text: '', score: 0),
    );

    _currentScore += selectedOption.score;
    
    if (_currentScore > _highScore) {
      _highScore = _currentScore;
      await _saveHighScore();
    }

    return selectedOption.score > 0;
  }

  int getCurrentScore() => _currentScore;
  
  int getHighScore() => _highScore;

  void resetScore() {
    _currentScore = 0;
  }

  Future<void> startNewQuiz() async {
    resetScore();
    _selectRandomQuestions(5);
    await _loadHighScore();
  }

  Future<List<Map<String, dynamic>>> getLeaderboard() async {
    try {
      final QuerySnapshot snapshot = await _firestore
          .collection('scores')
          .orderBy('highScore', descending: true)
          .limit(10)
          .get();

      return snapshot.docs.map((doc) {
        final data = doc.data() as Map<String, dynamic>;
        return {
          'userId': doc.id,
          'highScore': data['highScore'] ?? 0,
          'lastUpdated': data['lastUpdated'],
        };
      }).toList();
    } catch (e) {
      print('Error fetching leaderboard: $e');
      return [];
    }
  }

  Future<void> saveGameResults(int score, List<String> answeredQuestions) async {
    try {
      final userId = FirebaseAuth.instance.currentUser?.uid;
      if (userId != null) {
        await _firestore.collection('game_results').add({
          'userId': userId,
          'score': score,
          'answeredQuestions': answeredQuestions,
          'timestamp': FieldValue.serverTimestamp(),
        });
      }
    } catch (e) {
      print('Error saving game results: $e');
    }
  }
}