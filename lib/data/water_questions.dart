// lib/data/water_questions.dart
// Su Teması için Kapsamlı Soru Bankası - 350 Soru

import '../models/question.dart';

class WaterQuestions {
  /// Su Temelleri sorularını getirir (50 soru)
  static List<Question> getTurkishWaterFundamentals() {
    return [
      // Su ve Yaşam (10 soru)
      Question(
        text: 'İnsan vücudunun yüzde kaçı sudan oluşur?',
        options: [
          Option(text: '%40-50', score: 0),
          Option(text: '%55-65', score: 10),
          Option(text: '%70-75', score: 0),
          Option(text: '%80-85', score: 0),
        ],
        category: 'Su',
      ),
      Question(
        text: 'Su molekülünün kimyasal formülü nedir?',
        options: [
          Option(text: 'CO₂', score: 0),
          Option(text: 'H₂O', score: 10),
          Option(text: 'O₂', score: 0),
          Option(text: 'NaCl', score: 0),
        ],
        category: 'Su',
      ),
      Question(
        text: 'Su molekülündeki bağ açısı yaklaşık kaç derecedir?',
        options: [
          Option(text: '90°', score: 0),
          Option(text: '104.5°', score: 10),
          Option(text: '120°', score: 0),
          Option(text: '180°', score: 0),
        ],
        category: 'Su',
      ),
      Question(
        text: 'Suyun yoğunluğu en yüksek seviyeye hangi sıcaklıkta ulaşır?',
        options: [
          Option(text: '0°C', score: 0),
          Option(text: '4°C', score: 10),
          Option(text: '10°C', score: 0),
          Option(text: '20°C', score: 0),
        ],
        category: 'Su',
      ),
      Question(
        text: 'Suyun hangi özelliği denizlerdeki yaşam için kritiktir?',
        options: [
          Option(text: 'Yüksek ısı kapasitesi', score: 10),
          Option(text: 'Düşük viskozite', score: 0),
          Option(text: 'Renksiz olması', score: 0),
          Option(text: 'Asit özelliği', score: 0),
        ],
        category: 'Su',
      ),
      Question(
        text: 'Su döngüsünde en büyük su kaynağı nedir?',
        options: [
          Option(text: 'Nehirler', score: 0),
          Option(text: 'Okyanuslar', score: 10),
          Option(text: 'Göller', score: 0),
          Option(text: 'Yeraltı suları', score: 0),
        ],
        category: 'Su',
      ),
      Question(
        text: 'İnsan günlük yaklaşık kaç litre su içmelidir?',
        options: [
          Option(text: '1-1.5 litre', score: 0),
          Option(text: '2-2.5 litre', score: 10),
          Option(text: '3-4 litre', score: 0),
          Option(text: '5-6 litre', score: 0),
        ],
        category: 'Su',
      ),
      Question(
        text: 'Suyun kaynama noktası deniz seviyesinde kaç °C\'dir?',
        options: [
          Option(text: '90°C', score: 0),
          Option(text: '100°C', score: 10),
          Option(text: '110°C', score: 0),
          Option(text: '120°C', score: 0),
        ],
        category: 'Su',
      ),
      Question(
        text: 'Su molekülündeki hidrojen bağları neden önemlidir?',
        options: [
          Option(text: 'Sadece tadını etkiler', score: 0),
          Option(text: 'Suyun yüksek ısı kapasitesi ve yüzey gerilimi', score: 10),
          Option(text: 'Sadece rengini belirler', score: 0),
          Option(text: 'Sadece kokusunu etkiler', score: 0),
        ],
        category: 'Su',
      ),
      Question(
        text: 'Dünyadaki tatlı suyun yaklaşık yüzde kaçı buzullarda bulunur?',
        options: [
          Option(text: '%60', score: 0),
          Option(text: '%68', score: 10),
          Option(text: '%75', score: 0),
          Option(text: '%80', score: 0),
        ],
        category: 'Su',
      ),

      // Su Kaynakları (10 soru)
      Question(
        text: 'Dünyadaki suyun yüzde kaçı tatlı sudur?',
        options: [
          Option(text: '%1', score: 0),
          Option(text: '%2.5', score: 10),
          Option(text: '%5', score: 0),
          Option(text: '%10', score: 0),
        ],
        category: 'Su',
      ),
      Question(
        text: 'Yer altı suları toplam tatlı suyun yaklaşık yüzde kaçını oluşturur?',
        options: [
          Option(text: '%10', score: 0),
          Option(text: '%30', score: 10),
          Option(text: '%50', score: 0),
          Option(text: '%70', score: 0),
        ],
        category: 'Su',
      ),
      Question(
        text: 'Dünyadaki en büyük tatlı su rezervuarı nerededir?',
        options: [
          Option(text: 'Amazon Nehri', score: 0),
          Option(text: 'Antarktika Buz Tabakası', score: 10),
          Option(text: 'Baikal Gölü', score: 0),
          Option(text: 'Mississippi Nehri', score: 0),
        ],
        category: 'Su',
      ),
      Question(
        text: 'Akifer nedir?',
        options: [
          Option(text: 'Yeraltında su tutan geçirgen kaynak tabakası', score: 10),
          Option(text: 'Yüzeydeki tatlı su gölü', score: 0),
          Option(text: 'Buzul eriyiği suyu', score: 0),
          Option(text: 'Yıllık yağış miktarı', score: 0),
        ],
        category: 'Su',
      ),
      Question(
        text: 'Türkiye\'deki en büyük yeraltı suyu havzası hangisidir?',
        options: [
          Option(text: 'Konya Havzası', score: 10),
          Option(text: 'Ankara Havzası', score: 0),
          Option(text: 'İzmir Havzası', score: 0),
          Option(text: 'Antalya Havzası', score: 0),
        ],
        category: 'Su',
      ),
      Question(
        text: 'Rehabilitasyon nedir?',
        options: [
          Option(text: 'Su kaynağının yeniden canlandırılması', score: 10),
          Option(text: 'Su tasarrufu yapma', score: 0),
          Option(text: 'Su arıtma işlemi', score: 0),
          Option(text: 'Su kanalı yapımı', score: 0),
        ],
        category: 'Su',
      ),
      Question(
        text: 'Yeraltı suyu hangi faktörlerden etkilenir?',
        options: [
          Option(text: 'Sadece yağış miktarı', score: 0),
          Option(text: 'Jeolojik yapı, yağış, bitki örtüsü', score: 10),
          Option(text: 'Sadece sıcaklık', score: 0),
          Option(text: 'Sadece rüzgar', score: 0),
        ],
        category: 'Su',
      ),
      Question(
        text: 'Hidrolojik döngüde enerji kaynağı nedir?',
        options: [
          Option(text: 'Ay', score: 0),
          Option(text: 'Güneş', score: 10),
          Option(text: 'Dünya', score: 0),
          Option(text: 'Rüzgar', score: 0),
        ],
        category: 'Su',
      ),
      Question(
        text: 'Yer altı suyu nasıl yenilenir?',
        options: [
          Option(text: 'Sadece yağış ile', score: 0),
          Option(text: 'Yağış, kar erimesi ve infiltrasyon', score: 10),
          Option(text: 'Sadece kar erimesi ile', score: 0),
          Option(text: 'Sadece infiltrasyon ile', score: 0),
        ],
        category: 'Su',
      ),
      Question(
        text: 'Dünyada su kaynakları nasıl dağılmıştır?',
        options: [
          Option(text: 'Eşit olarak dağılmış', score: 0),
          Option(text: 'Eşitsiz olarak dağılmış', score: 10),
          Option(text: 'Sadece ekvator çevresinde', score: 0),
          Option(text: 'Sadece kutup bölgelerinde', score: 0),
        ],
        category: 'Su',
      ),

      // Su Kimyası (10 soru)
      Question(
        text: 'pH değeri 7 olan su nasıl bir sudur?',
        options: [
          Option(text: 'Asidik', score: 0),
          Option(text: 'Nötr', score: 10),
          Option(text: 'Bazik', score: 0),
          Option(text: 'Çok asidik', score: 0),
        ],
        category: 'Su',
      ),
      Question(
        text: 'İçme suyu için kabul edilebilir pH aralığı nedir?',
        options: [
          Option(text: '6.5-8.5', score: 10),
          Option(text: '5.0-6.0', score: 0),
          Option(text: '9.0-10.0', score: 0),
          Option(text: '7.5-8.0', score: 0),
        ],
        category: 'Su',
      ),
      Question(
        text: 'Su sertliğinin temel nedeni hangi minerallerdir?',
        options: [
          Option(text: 'Sodyum ve Potasyum', score: 0),
          Option(text: 'Kalsiyum ve Magnezyum', score: 10),
          Option(text: 'Demir ve Bakır', score: 0),
          Option(text: 'Çinko ve Alüminyum', score: 0),
        ],
        category: 'Su',
      ),
      Question(
        text: 'Sudaki çözünmüş oksijen hangi canlılar için kritiktir?',
        options: [
          Option(text: 'Sadece bitkiler', score: 0),
          Option(text: 'Balıklar ve sucul canlılar', score: 10),
          Option(text: 'Sadece bakteriler', score: 0),
          Option(text: 'Sadece algler', score: 0),
        ],
        category: 'Su',
      ),
      Question(
        text: 'BOD nedir?',
        options: [
          Option(text: 'Biyolojik Oksijen İhtiyacı', score: 10),
          Option(text: 'Basınç Oksijen Dağılımı', score: 0),
          Option(text: 'Bakteri Oksijen Dengesi', score: 0),
          Option(text: 'Bitki Oksijen Üretimi', score: 0),
        ],
        category: 'Su',
      ),
      Question(
        text: 'Su sertliği hangi birimle ölçülür?',
        options: [
          Option(text: 'mg/L', score: 0),
          Option(text: 'ppm CaCO₃', score: 10),
          Option(text: 'mV', score: 0),
          Option(text: '°C', score: 0),
        ],
        category: 'Su',
      ),
      Question(
        text: 'TDS nedir?',
        options: [
          Option(text: 'Toplam Dissolve Olmuş Katılar', score: 10),
          Option(text: 'Toplam Doğal Sıcaklık', score: 0),
          Option(text: 'Tatlı Doğal Su', score: 0),
          Option(text: 'Termal Direnç Sistemi', score: 0),
        ],
        category: 'Su',
      ),
      Question(
        text: 'Su iletkenliği hangi faktörlere bağlıdır?',
        options: [
          Option(text: 'Sadece sıcaklık', score: 0),
          Option(text: 'Çözünmüş iyonlar ve sıcaklık', score: 10),
          Option(text: 'Sadece basınç', score: 0),
          Option(text: 'Sadece pH', score: 0),
        ],
        category: 'Su',
      ),
      Question(
        text: 'Klorun su arıtmasındaki temel işlevi nedir?',
        options: [
          Option(text: 'Tat vermek', score: 0),
          Option(text: 'Bakteri ve virüsleri öldürmek', score: 10),
          Option(text: 'Renk vermek', score: 0),
          Option(text: 'Koku vermek', score: 0),
        ],
        category: 'Su',
      ),
      Question(
        text: 'Alg patlaması (algal bloom) su kalitesini nasıl etkiler?',
        options: [
          Option(text: 'Olumlu etki yapar', score: 0),
          Option(text: 'Oksijen tüketimini artırır ve zehirli maddeler üretir', score: 10),
          Option(text: 'Sadece rengi değiştirir', score: 0),
          Option(text: 'Sadece kokusunu değiştirir', score: 0),
        ],
        category: 'Su',
      ),

      // Su Mühendisliği (10 soru)
      Question(
        text: 'Su arıtma tesislerinde ilk adım hangisidir?',
        options: [
          Option(text: 'Klorlama', score: 0),
          Option(text: 'Kaba filtrasyon', score: 10),
          Option(text: 'UV sterilizasyon', score: 0),
          Option(text: 'Aktif karbon filtrasyonu', score: 0),
        ],
        category: 'Su',
      ),
      Question(
        text: 'Koagülasyon işlemi su arıtımında ne için kullanılır?',
        options: [
          Option(text: 'pH ayarlamak için', score: 0),
          Option(text: 'Askıda parçacıkları çökeltmek için', score: 10),
          Option(text: 'Koku gidermek için', score: 0),
          Option(text: 'Tat vermek için', score: 0),
        ],
        category: 'Su',
      ),
      Question(
        text: 'Su dağıtım şebekelerinde en büyük sorun nedir?',
        options: [
          Option(text: 'Basınç kaybı', score: 0),
          Option(text: 'Su kayıpları', score: 10),
          Option(text: 'Sıcaklık değişimi', score: 0),
          Option(text: 'Renk değişimi', score: 0),
        ],
        category: 'Su',
      ),
      Question(
        text: 'Reverse osmosis sisteminde su hangi yönde hareket eder?',
        options: [
          Option(text: 'Yüksek basınçtan düşük basınca', score: 0),
          Option(text: 'Düşük konsantrasyondan yüksek konsantrasyona', score: 10),
          Option(text: 'Sıcaktan soğuğa', score: 0),
          Option(text: 'Yukarıdan aşağıya', score: 0),
        ],
        category: 'Su',
      ),
      Question(
        text: 'Su arıtımında ozonun avantajı nedir?',
        options: [
          Option(text: 'Düşük maliyet', score: 0),
          Option(text: 'Güçlü oksidasyon ve dezenfeksiyon', score: 10),
          Option(text: 'Kolay uygulama', score: 0),
          Option(text: 'Uzun süreli etki', score: 0),
        ],
        category: 'Su',
      ),
      Question(
        text: 'Su hatlarında korozyonun ana nedeni nedir?',
        options: [
          Option(text: 'Sadece pH', score: 0),
          Option(text: 'Oksijen ve düşük pH', score: 10),
          Option(text: 'Sadece sıcaklık', score: 0),
          Option(text: 'Sadece basınç', score: 0),
        ],
        category: 'Su',
      ),
      Question(
        text: 'Çamur susuzlaştırma işleminde hangi yöntem kullanılır?',
        options: [
          Option(text: 'Filtrasyon', score: 0),
          Option(text: 'Pres veya santrifüj', score: 10),
          Option(text: 'Klorlama', score: 0),
          Option(text: 'UV ışınlama', score: 0),
        ],
        category: 'Su',
      ),
      Question(
        text: 'Su depolama tesislerinde hangi sorunlar yaşanabilir?',
        options: [
          Option(text: 'Sadece koku problemi', score: 0),
          Option(text: 'Bakteri üremesi ve koku problemi', score: 10),
          Option(text: 'Sadece renk değişimi', score: 0),
          Option(text: 'Sadece tad değişimi', score: 0),
        ],
        category: 'Su',
      ),
      Question(
        text: 'Su arıtımında kullanılan en yaygın filtrasyon malzemesi nedir?',
        options: [
          Option(text: 'Kum', score: 10),
          Option(text: 'Çakıl', score: 0),
          Option(text: 'Mermer', score: 0),
          Option(text: 'Kömür', score: 0),
        ],
        category: 'Su',
      ),
      Question(
        text: 'SCADA sistemi su yönetiminde ne işe yarar?',
        options: [
          Option(text: 'Sadece su tasarrufu', score: 0),
          Option(text: 'Uzaktan izleme ve kontrol', score: 10),
          Option(text: 'Sadece maliyet hesaplama', score: 0),
          Option(text: 'Sadece faturalama', score: 0),
        ],
        category: 'Su',
      ),

      // Su Yönetimi (10 soru)
      Question(
        text: 'Sürdürülebilir su yönetiminin temel ilkesi nedir?',
        options: [
          Option(text: 'Mevcut kaynakları tamamen kullanmak', score: 0),
          Option(text: 'Gelecek nesillere yetecek su bırakmak', score: 10),
          Option(text: 'Suyu sadece şehirlerde kullanmak', score: 0),
          Option(text: 'Su maliyetini minimize etmek', score: 0),
        ],
        category: 'Su',
      ),
      Question(
        text: 'Su tasarrufu için en etkili yöntem nedir?',
        options: [
          Option(text: 'Sadece kısa duş almak', score: 0),
          Option(text: 'Teknoloji kullanımı ve davranış değişikliği', score: 10),
          Option(text: 'Sadece fiyat artırmak', score: 0),
          Option(text: 'Sadece yasaklar koymak', score: 0),
        ],
        category: 'Su',
      ),
      Question(
        text: 'Su krizinin temel nedenleri nelerdir?',
        options: [
          Option(text: 'Sadece kuraklık', score: 0),
          Option(text: 'Nüfus artışı, iklim değişimi ve yanlış yönetim', score: 10),
          Option(text: 'Sadece teknoloji eksikliği', score: 0),
          Option(text: 'Sadece ekonomik sorunlar', score: 0),
        ],
        category: 'Su',
      ),
      Question(
        text: 'Entegre Su Kaynakları Yönetimi (IWRM) nedir?',
        options: [
          Option(text: 'Sadece teknik çözümler', score: 0),
          Option(text: 'Tüm paydaşları kapsayan bütüncül yaklaşım', score: 10),
          Option(text: 'Sadece devlet kontrolü', score: 0),
          Option(text: 'Sadece pazar mekanizması', score: 0),
        ],
        category: 'Su',
      ),
      Question(
        text: 'Su hakları hangi prensibe dayanır?',
        options: [
          Option(text: 'Önce gelen alır', score: 0),
          Option(text: 'Herkese yeterli ve temiz su hakkı', score: 10),
          Option(text: 'Para ile satın alma', score: 0),
          Option(text: 'Sadece vatandaşlara özel', score: 0),
        ],
        category: 'Su',
      ),
      Question(
        text: 'Su fiyatlandırmasının amacı nedir?',
        options: [
          Option(text: 'Sadece gelir sağlamak', score: 0),
          Option(text: 'Verimliliği artırmak ve sürdürülebilirliği sağlamak', score: 10),
          Option(text: 'Sadece fakirleri cezalandırmak', score: 0),
          Option(text: 'Sadece zenginleri desteklemek', score: 0),
        ],
        category: 'Su',
      ),
      Question(
        text: 'Su kaynaklarında paydaş kimlerdir?',
        options: [
          Option(text: 'Sadece devlet kurumları', score: 0),
          Option(text: 'Tüm kullanıcılar ve etkilenen gruplar', score: 10),
          Option(text: 'Sadece su şirketleri', score: 0),
          Option(text: 'Sadece bilim insanları', score: 0),
        ],
        category: 'Su',
      ),
      Question(
        text: 'Su stresi hangi durumu ifade eder?',
        options: [
          Option(text: 'Tamamen su olmaması', score: 0),
          Option(text: 'Su kıtlığı yaşanma riski', score: 10),
          Option(text: 'Fazla su olması', score: 0),
          Option(text: 'Kirli su olması', score: 0),
        ],
        category: 'Su',
      ),
      Question(
        text: 'Su yönetiminde adaptasyon nedir?',
        options: [
          Option(text: 'Değişen koşullara uyum sağlama', score: 10),
          Option(text: 'Teknoloji değiştirme', score: 0),
          Option(text: 'Personel değiştirme', score: 0),
          Option(text: 'Fiyat artırma', score: 0),
        ],
        category: 'Su',
      ),
      Question(
        text: 'Su güvenliği hangi bileşenleri içerir?',
        options: [
          Option(text: 'Sadece miktar', score: 0),
          Option(text: 'Miktar, kalite ve erişim güvenliği', score: 10),
          Option(text: 'Sadece kalite', score: 0),
          Option(text: 'Sadece erişim', score: 0),
        ],
        category: 'Su',
      ),
    ];
  }

  /// Su Kalitesi sorularını getirir (50 soru)
  static List<Question> getTurkishWaterQuality() {
    return [
      // Su Kalitesi Parametreleri (15 soru)
      Question(
        text: 'Su kalitesinin fiziksel parametreleri hangileridir?',
        options: [
          Option(text: 'Sadece renk ve koku', score: 0),
          Option(text: 'Renk, koku, tat, bulanıklık, sıcaklık', score: 10),
          Option(text: 'Sadece pH ve sertlik', score: 0),
          Option(text: 'Sadece çözünmüş oksijen', score: 0),
        ],
        category: 'Su',
      ),
      Question(
        text: 'Bulanıklık hangi birimle ölçülür?',
        options: [
          Option(text: 'mg/L', score: 0),
          Option(text: 'NTU (Nephelometric Turbidity Unit)', score: 10),
          Option(text: 'ppm', score: 0),
          Option(text: 'mV', score: 0),
        ],
        category: 'Su',
      ),
      Question(
        text: 'İçme suyu için kabul edilebilir bulanıklık değeri nedir?',
        options: [
          Option(text: '1 NTU', score: 0),
          Option(text: '0.5 NTU', score: 10),
          Option(text: '2 NTU', score: 0),
          Option(text: '5 NTU', score: 0),
        ],
        category: 'Su',
      ),
      Question(
        text: 'Renk ve koku oluşumunun ana nedenleri nelerdir?',
        options: [
          Option(text: 'Sadece organik maddeler', score: 0),
          Option(text: 'Organik maddeler, endüstriyel atıklar ve mikroorganizmalar', score: 10),
          Option(text: 'Sadece mineraller', score: 0),
          Option(text: 'Sadece klor', score: 0),
        ],
        category: 'Su',
      ),
      Question(
        text: 'Çözünmüş oksijen (DO) seviyesi neyi gösterir?',
        options: [
          Option(text: 'Sadece su sertliği', score: 0),
          Option(text: 'Su ekosisteminin sağlığını', score: 10),
          Option(text: 'Sadece sıcaklık', score: 0),
          Option(text: 'Sadece pH', score: 0),
        ],
        category: 'Su',
      ),
      Question(
        text: 'Sağlıklı bir su kaynağında çözünmüş oksijen seviyesi ne olmalıdır?',
        options: [
          Option(text: '2-3 mg/L', score: 0),
          Option(text: '6-8 mg/L', score: 10),
          Option(text: '10-12 mg/L', score: 0),
          Option(text: '1-2 mg/L', score: 0),
        ],
        category: 'Su',
      ),
      Question(
        text: 'COD nedir ve neyi ölçer?',
        options: [
          Option(text: 'Sadece organik kirlilik', score: 0),
          Option(text: 'Kimyasal Oksijen İhtiyacı - organik kirlilik seviyesi', score: 10),
          Option(text: 'Sadece inorganik kirlilik', score: 0),
          Option(text: 'Sadece ağır metal kirliliği', score: 0),
        ],
        category: 'Su',
      ),
      Question(
        text: 'Kiral su hangi parametreleri etkiler?',
        options: [
          Option(text: 'Sadece tat ve koku', score: 0),
          Option(text: 'Tat, koku, sağlık ve ekolojik denge', score: 10),
          Option(text: 'Sadece renk', score: 0),
          Option(text: 'Sadece sıcaklık', score: 0),
        ],
        category: 'Su',
      ),
      Question(
        text: 'Mikrobiyolojik kirlilik göstergesi nedir?',
        options: [
          Option(text: 'E. coli', score: 10),
          Option(text: 'pH', score: 0),
          Option(text: 'Sıcaklık', score: 0),
          Option(text: 'Bulanıklık', score: 0),
        ],
        category: 'Su',
      ),
      Question(
        text: 'İçme suyunda E. coli sayısı ne kadar olmalıdır?',
        options: [
          Option(text: '10 CFU/100mL', score: 0),
          Option(text: '0 CFU/100mL', score: 10),
          Option(text: '50 CFU/100mL', score: 0),
          Option(text: '100 CFU/100mL', score: 0),
        ],
        category: 'Su',
      ),
      Question(
        text: 'Su kalitesinde ağır metallerin önemi nedir?',
        options: [
          Option(text: 'Sadece tat etkisi', score: 0),
          Option(text: 'Sağlık riskleri ve uzun vadeli etkiler', score: 10),
          Option(text: 'Sadece koku', score: 0),
          Option(text: 'Sadece renk', score: 0),
        ],
        category: 'Su',
      ),
      Question(
        text: 'İçme suyunda kurşun limiti nedir?',
        options: [
          Option(text: '0.05 mg/L', score: 0),
          Option(text: '0.01 mg/L', score: 10),
          Option(text: '0.1 mg/L', score: 0),
          Option(text: '0.5 mg/L', score: 0),
        ],
        category: 'Su',
      ),
      Question(
        text: 'Nitrat kirliliğinin ana kaynakları nelerdir?',
        options: [
          Option(text: 'Sadece endüstri', score: 0),
          Option(text: 'Tarımsal gübreler, kanalizasyon ve hayvancılık', score: 10),
          Option(text: 'Sadece trafik', score: 0),
          Option(text: 'Sadece evsel atıklar', score: 0),
        ],
        category: 'Su',
      ),
      Question(
        text: 'Nitratın içme suyundaki limiti nedir?',
        options: [
          Option(text: '30 mg/L', score: 0),
          Option(text: '50 mg/L', score: 10),
          Option(text: '100 mg/L', score: 0),
          Option(text: '20 mg/L', score: 0),
        ],
        category: 'Su',
      ),
      Question(
        text: 'Fosfat kirliliğinin temel etkisi nedir?',
        options: [
          Option(text: 'Sadece tat değişikliği', score: 0),
          Option(text: 'Ötrofikasyon (alg patlaması)', score: 10),
          Option(text: 'Sadece renk değişikliği', score: 0),
          Option(text: 'Sadece koku', score: 0),
        ],
        category: 'Su',
      ),

      // Kirlilik Türleri ve Kaynakları (15 soru)
      Question(
        text: 'Noktasal kirlilik kaynakları nelerdir?',
        options: [
          Option(text: 'Dağınık kaynaklar', score: 0),
          Option(text: 'Fabrika, kanalizasyon çıkışı gibi belirli noktalar', score: 10),
          Option(text: 'Tarım alanları', score: 0),
          Option(text: 'Otomobil egzozları', score: 0),
        ],
        category: 'Su',
      ),
      Question(
        text: 'Dağınık kirlilik kaynaklarına örnek nedir?',
        options: [
          Option(text: 'Fabrika atığı', score: 0),
          Option(text: 'Tarım ilaçları ve gübreler', score: 10),
          Option(text: 'Kanalizasyon çıkışı', score: 0),
          Option(text: 'Maden atığı', score: 0),
        ],
        category: 'Su',
      ),
      Question(
        text: 'Organik kirlilik hangi kaynaklardan gelir?',
        options: [
          Option(text: 'Sadece endüstriyel atıklar', score: 0),
          Option(text: 'Evsel atıklar, tarımsal kalıntılar ve endüstriyel deşarjlar', score: 10),
          Option(text: 'Sadece trafik', score: 0),
          Option(text: 'Sadece inşaat', score: 0),
        ],
        category: 'Su',
      ),
      Question(
        text: 'Termal kirlilik hangi kaynaklardan oluşur?',
        options: [
          Option(text: 'Güneş ısısı', score: 0),
          Option(text: 'Endüstriyel soğutma suyu ve enerji santralleri', score: 10),
          Option(text: 'Volkanik aktivite', score: 0),
          Option(text: 'Jeotermal enerji', score: 0),
        ],
        category: 'Su',
      ),
      Question(
        text: 'Radyoaktif kirlilik hangi kaynaklardan gelebilir?',
        options: [
          Option(text: 'Sadece nükleer santraller', score: 0),
          Option(text: 'Nükleer santraller, tıbbi atıklar ve doğal kaynaklar', score: 10),
          Option(text: 'Sadece hastaneler', score: 0),
          Option(text: 'Sadece madencilik', score: 0),
        ],
        category: 'Su',
      ),
      Question(
        text: 'Plastik kirliliği su ekosistemlerini nasıl etkiler?',
        options: [
          Option(text: 'Sadece görsel kirlilik', score: 0),
          Option(text: 'Besin zinciri, toksisite ve habitat tahribatı', score: 10),
          Option(text: 'Sadece fiziksel engel', score: 0),
          Option(text: 'Sadece koku', score: 0),
        ],
        category: 'Su',
      ),
      Question(
        text: 'Petrol kirliliğinin denizlerdeki etkileri nelerdir?',
        options: [
          Option(text: 'Sadece yüzeyde kalır', score: 0),
          Option(text: 'Kuş tüylerini kirletir, balık solunumunu engeller', score: 10),
          Option(text: 'Sadece koku yapar', score: 0),
          Option(text: 'Sadece görsel kirlilik', score: 0),
        ],
        category: 'Su',
      ),
      Question(
        text: 'Tarımsal kirliliğin temel bileşenleri nelerdir?',
        options: [
          Option(text: 'Sadece pestisitler', score: 0),
          Option(text: 'Pestisit, gübre ve sediment', score: 10),
          Option(text: 'Sadece gübre', score: 0),
          Option(text: 'Sadece sediment', score: 0),
        ],
        category: 'Su',
      ),
      Question(
        text: 'Endüstriyel kirliliğin özellikleri nelerdir?',
        options: [
          Option(text: 'Sadece organik', score: 0),
          Option(text: 'Çeşitli toksik kimyasallar ve ağır metaller', score: 10),
          Option(text: 'Sadece inorganik', score: 0),
          Option(text: 'Sadece biyolojik', score: 0),
        ],
        category: 'Su',
      ),
      Question(
        text: 'Evsel kirliliğin ana bileşenleri nelerdir?',
        options: [
          Option(text: 'Sadece deterjan', score: 0),
          Option(text: 'Organik maddeler, besin maddeleri ve patojenler', score: 10),
          Option(text: 'Sadece tuz', score: 0),
          Option(text: 'Sadece yağ', score: 0),
        ],
        category: 'Su',
      ),
      Question(
        text: 'Maden kirliliğinin özellikleri nelerdir?',
        options: [
          Option(text: 'Sadece pH değişimi', score: 0),
          Option(text: 'Ağır metaller, asidik özellik ve toksisite', score: 10),
          Option(text: 'Sadece renk değişikliği', score: 0),
          Option(text: 'Sadece koku', score: 0),
        ],
        category: 'Su',
      ),
      Question(
        text: 'Erozyonun su kalitesine etkisi nedir?',
        options: [
          Option(text: 'Sadece bulanıklık artışı', score: 0),
          Option(text: 'Bulanıklık, sediment ve besin maddesi kirliliği', score: 10),
          Option(text: 'Sadece sediment', score: 0),
          Option(text: 'Sadece besin maddesi', score: 0),
        ],
        category: 'Su',
      ),
      Question(
        text: 'Tuzluluk kirliliğinin kaynakları nelerdir?',
        options: [
          Option(text: 'Sadece deniz suyu', score: 0),
          Option(text: 'Deniz suyu sızması, tuz kullanımı ve endüstriyel atıklar', score: 10),
          Option(text: 'Sadece kar erimesi', score: 0),
          Option(text: 'Sadece yağmur', score: 0),
        ],
        category: 'Su',
      ),
      Question(
        text: 'Biyolojik kirlilik nedir?',
        options: [
          Option(text: 'Sadece algler', score: 0),
          Option(text: 'Patojenik mikroorganizmalar ve zararlı türler', score: 10),
          Option(text: 'Sadece balıklar', score: 0),
          Option(text: 'Sadece bitkiler', score: 0),
        ],
        category: 'Su',
      ),
      Question(
        text: 'Kimyasal kirliliğin türleri nelerdir?',
        options: [
          Option(text: 'Sadece pestisitler', score: 0),
          Option(text: 'Organik, inorganik ve petro-kimyasal kirleticiler', score: 10),
          Option(text: 'Sadece ağır metaller', score: 0),
          Option(text: 'Sadece radyoaktif maddeler', score: 0),
        ],
        category: 'Su',
      ),

      // Arıtma Yöntemleri (20 soru)
      Question(
        text: 'Fiziksel arıtma yöntemleri hangileridir?',
        options: [
          Option(text: 'Sadece filtrasyon', score: 0),
          Option(text: 'Çökeltme, filtrasyon ve flotasyon', score: 10),
          Option(text: 'Sadece çökeltme', score: 0),
          Option(text: 'Sadece klorlama', score: 0),
        ],
        category: 'Su',
      ),
      Question(
        text: 'Kimyasal arıtma yöntemleri nelerdir?',
        options: [
          Option(text: 'Sadece klorlama', score: 0),
          Option(text: 'Koagülasyon, oksidasyon ve dezenfeksiyon', score: 10),
          Option(text: 'Sadece oksidasyon', score: 0),
          Option(text: 'Sadece dezenfeksiyon', score: 0),
        ],
        category: 'Su',
      ),
      Question(
        text: 'Biyolojik arıtma nasıl çalışır?',
        options: [
          Option(text: 'Sadece kimyasal reaksiyon', score: 0),
          Option(text: 'Mikroorganizmaların organik maddeleri parçalaması', score: 10),
          Option(text: 'Sadece filtrasyon', score: 0),
          Option(text: 'Sadece çökeltme', score: 0),
        ],
        category: 'Su',
      ),
      Question(
        text: 'Koagülasyonda kullanılan kimyasallar nelerdir?',
        options: [
          Option(text: 'Sadece kireç', score: 0),
          Option(text: 'Alüminyum sülfat ve demir klorür', score: 10),
          Option(text: 'Sadece aktif karbon', score: 0),
          Option(text: 'Sadece ozon', score: 0),
        ],
        category: 'Su',
      ),
      Question(
        text: 'Flokülasyon koagülasyondan sonra neden yapılır?',
        options: [
          Option(text: 'pH ayarlamak için', score: 0),
          Option(text: 'Küçük parçacıkları büyük çökeltilebilir parçacıklara dönüştürmek için', score: 10),
          Option(text: 'Koku gidermek için', score: 0),
          Option(text: 'Renk gidermek için', score: 0),
        ],
        category: 'Su',
      ),
      Question(
        text: 'Sedimentasyon havuzlarının amacı nedir?',
        options: [
          Option(text: 'Sadece su depolamak', score: 0),
          Option(text: 'Askıda katıları çökeltmek', score: 10),
          Option(text: 'Sadece su soğutmak', score: 0),
          Option(text: 'Sadece su ısıtmak', score: 0),
        ],
        category: 'Su',
      ),
      Question(
        text: 'Filtrasyon havuzlarında hangi malzemeler kullanılır?',
        options: [
          Option(text: 'Sadece kum', score: 0),
          Option(text: 'Kum, çakıl ve antrasit', score: 10),
          Option(text: 'Sadece çakıl', score: 0),
          Option(text: 'Sadece aktif karbon', score: 0),
        ],
        category: 'Su',
      ),
      Question(
        text: 'Dezenfeksiyonun amacı nedir?',
        options: [
          Option(text: 'Sadece koku gidermek', score: 0),
          Option(text: 'Patojenik mikroorganizmaları öldürmek', score: 10),
          Option(text: 'Sadece renk gidermek', score: 0),
          Option(text: 'Sadece tat iyileştirmek', score: 0),
        ],
        category: 'Su',
      ),
      Question(
        text: 'Klorlamanın avantajları nelerdir?',
        options: [
          Option(text: 'Sadece ucuz olması', score: 0),
          Option(text: 'Güçlü dezenfektan ve kalıcı etki', score: 10),
          Option(text: 'Sadece kolay uygulanması', score: 0),
          Option(text: 'Sadece çevre dostu olması', score: 0),
        ],
        category: 'Su',
      ),
      Question(
        text: 'Ozonlamanın avantajları nelerdir?',
        options: [
          Option(text: 'Sadece ucuz olması', score: 0),
          Option(text: 'Güçlü oksidasyon, koku giderimi ve hızlı etki', score: 10),
          Option(text: 'Sadece kolay üretilmesi', score: 0),
          Option(text: 'Sadece güvenli olması', score: 0),
        ],
        category: 'Su',
      ),
      Question(
        text: 'UV sterilizasyonu nasıl çalışır?',
        options: [
          Option(text: 'Isıtma ile', score: 0),
          Option(text: 'Ultraviyole ışığı ile DNA hasarı', score: 10),
          Option(text: 'Basınç ile', score: 0),
          Option(text: 'Elektrik ile', score: 0),
        ],
        category: 'Su',
      ),
      Question(
        text: 'Aktif karbon filtrasyonu ne için kullanılır?',
        options: [
          Option(text: 'Sadece mikroorganizma giderimi', score: 0),
          Option(text: 'Organik kirleticiler, koku ve tat giderimi', score: 10),
          Option(text: 'Sadece sertlik giderimi', score: 0),
          Option(text: 'Sadece pH ayarlama', score: 0),
        ],
        category: 'Su',
      ),
      Question(
        text: 'Reverse osmosis hangi kirleticileri etkili şekilde giderir?',
        options: [
          Option(text: 'Sadece organik maddeler', score: 0),
          Option(text: 'Tuzlar, ağır metaller ve mikroorganizmalar', score: 10),
          Option(text: 'Sadece bakteriler', score: 0),
          Option(text: 'Sadece virüsler', score: 0),
        ],
        category: 'Su',
      ),
      Question(
        text: 'İyon değiştirici reçineler hangi kirleticileri giderir?',
        options: [
          Option(text: 'Sadece organik maddeler', score: 0),
          Option(text: 'Sertlik, nitrat ve ağır metaller', score: 10),
          Option(text: 'Sadece bakteriler', score: 0),
          Option(text: 'Sadece virüsler', score: 0),
        ],
        category: 'Su',
      ),
      Question(
        text: 'Demir ve mangan giderimi nasıl yapılır?',
        options: [
          Option(text: 'Sadece çökeltme', score: 0),
          Option(text: 'Oksidasyon, çökeltme ve filtrasyon', score: 10),
          Option(text: 'Sadece filtrasyon', score: 0),
          Option(text: 'Sadece klorlama', score: 0),
        ],
        category: 'Su',
      ),
      Question(
        text: 'Florür giderimi hangi yöntemlerle yapılır?',
        options: [
          Option(text: 'Sadece çökeltme', score: 0),
          Option(text: 'Aktif alumina, kemik kömürü ve ters ozmoz', score: 10),
          Option(text: 'Sadece filtrasyon', score: 0),
          Option(text: 'Sadece klorlama', score: 0),
        ],
        category: 'Su',
      ),
      Question(
        text: 'Arsenik giderimi neden zordur?',
        options: [
          Option(text: 'Sadece pahalı olması', score: 0),
          Option(text: 'Düşük konsantrasyonlarda ve çeşitli formlarda bulunması', score: 10),
          Option(text: 'Sadece toksik olması', score: 0),
          Option(text: 'Sadece renksiz olması', score: 0),
        ],
        category: 'Su',
      ),
      Question(
        text: 'Atıksu arıtımında ilk aşama nedir?',
        options: [
          Option(text: 'Biyolojik arıtma', score: 0),
          Option(text: 'Ön arıtma (ızgara ve kum tutucu)', score: 10),
          Option(text: 'Kimyasal arıtma', score: 0),
          Option(text: 'Dezenfeksiyon', score: 0),
        ],
        category: 'Su',
      ),
      Question(
        text: 'Aktif çamur prosesinin avantajı nedir?',
        options: [
          Option(text: 'Sadece düşük maliyet', score: 0),
          Option(text: 'Yüksek arıtma verimi ve esneklik', score: 10),
          Option(text: 'Sadece basit işletim', score: 0),
          Option(text: 'Sadece az yer kaplaması', score: 0),
        ],
        category: 'Su',
      ),
      Question(
        text: 'Çamur arıtımının amacı nedir?',
        options: [
          Option(text: 'Sadece hacim azaltma', score: 0),
          Option(text: 'Hacim azaltma, stabilizasyon ve bertaraf', score: 10),
          Option(text: 'Sadece koku giderme', score: 0),
          Option(text: 'Sadece dezenfeksiyon', score: 0),
        ],
        category: 'Su',
      ),
    ];
  }

  /// Su Teknolojisi sorularını getirir (75 soru - ilk 50)
  static List<Question> getTurkishWaterTechnology() {
    return [
      // Su Arıtma Teknolojileri (15 soru)
      Question(
        text: 'Modern su arıtma teknolojilerinin temel bileşenleri nelerdir?',
        options: [
          Option(text: 'Sadece kimyasal arıtma', score: 0),
          Option(text: 'Fiziksel, kimyasal ve biyolojik arıtma kombinasyonu', score: 10),
          Option(text: 'Sadece biyolojik arıtma', score: 0),
          Option(text: 'Sadece membran teknolojisi', score: 0),
        ],
        category: 'Su',
      ),
      Question(
        text: 'Membran teknolojilerinde en yaygın kullanılan tür hangisidir?',
        options: [
          Option(text: 'Ultrafiltrasyon', score: 0),
          Option(text: 'Ters ozmoz', score: 10),
          Option(text: 'Nanofiltrasyon', score: 0),
          Option(text: 'Mikrofiltrasyon', score: 0),
        ],
        category: 'Su',
      ),
      Question(
        text: 'Elektrodiyaliz teknolojisi hangi prensibe dayanır?',
        options: [
          Option(text: 'Sadece elektroliz', score: 0),
          Option(text: 'İyon değişimi ve elektrik alanı', score: 10),
          Option(text: 'Sadece filtrasyon', score: 0),
          Option(text: 'Sadece çökeltme', score: 0),
        ],
        category: 'Su',
      ),
      Question(
        text: 'Ozon-UV hibrit arıtma sisteminin avantajı nedir?',
        options: [
          Option(text: 'Sadece düşük maliyet', score: 0),
          Option(text: 'Güçlü oksidasyon ve sinerjik etki', score: 10),
          Option(text: 'Sadece basit işletim', score: 0),
          Option(text: 'Sadece az enerji tüketimi', score: 0),
        ],
        category: 'Su',
      ),
      Question(
        text: 'Advanced Oxidation Processes (AOP) ne amaçla kullanılır?',
        options: [
          Option(text: 'Sadece sertlik giderimi', score: 0),
          Option(text: 'Dirençli organik kirleticilerin parçalanması', score: 10),
          Option(text: 'Sadece pH ayarlama', score: 0),
          Option(text: 'Sadece dezenfeksiyon', score: 0),
        ],
        category: 'Su',
      ),
      Question(
        text: 'Elektrokoagülasyon teknolojisinin avantajı nedir?',
        options: [
          Option(text: 'Sadece kimyasal kullanımını ortadan kaldırması', score: 10),
          Option(text: 'Sadece yüksek maliyet', score: 0),
          Option(text: 'Sadece basit işletim', score: 0),
          Option(text: 'Sadece az yer kaplaması', score: 0),
        ],
        category: 'Su',
      ),
      Question(
        text: 'Fotokatalitik arıtma teknolojisinde hangi malzeme kullanılır?',
        options: [
          Option(text: 'Sadece titanyum dioksit', score: 10),
          Option(text: 'Sadece çinko oksit', score: 0),
          Option(text: 'Sadece demir oksit', score: 0),
          Option(text: 'Sadece alüminyum oksit', score: 0),
        ],
        category: 'Su',
      ),
      Question(
        text: 'Membran bioreaktör (MBR) sisteminin avantajı nedir?',
        options: [
          Option(text: 'Sadece düşük maliyet', score: 0),
          Option(text: 'Yüksek kalite çıkış suyu ve kompakt tasarım', score: 10),
          Option(text: 'Sadece basit işletim', score: 0),
          Option(text: 'Sadece az enerji tüketimi', score: 0),
        ],
        category: 'Su',
      ),
      Question(
        text: 'Granüler aktif karbon (GAC) filtrasyonu ne sağlar?',
        options: [
          Option(text: 'Sadece sertlik giderimi', score: 0),
          Option(text: 'Organik kirletici ve koku giderimi', score: 10),
          Option(text: 'Sadece pH ayarlama', score: 0),
          Option(text: 'Sadece mikroorganizma giderimi', score: 0),
        ],
        category: 'Su',
      ),
      Question(
        text: 'Hızlı karıştırma havuzlarının işlevi nedir?',
        options: [
          Option(text: 'Sadece su depolamak', score: 0),
          Option(text: 'Kimyasalları su ile hızla karıştırmak', score: 10),
          Option(text: 'Sadece pH ayarlamak', score: 0),
          Option(text: 'Sadece sıcaklık kontrolü', score: 0),
        ],
        category: 'Su',
      ),
      Question(
        text: 'Lamella çökelticilerinin avantajı nedir?',
        options: [
          Option(text: 'Sadece düşük maliyet', score: 0),
          Option(text: 'Yüksek yüzey alanı ve hızlı çökeltme', score: 10),
          Option(text: 'Sadece basit tasarım', score: 0),
          Option(text: 'Sadece az bakım', score: 0),
        ],
        category: 'Su',
      ),
      Question(
        text: 'Düşük basınçlı membran (LPM) teknolojisi ne zaman kullanılır?',
        options: [
          Option(text: 'Sadece deniz suyu arıtımında', score: 0),
          Option(text: 'Yüksek kaliteli içme suyu üretiminde', score: 10),
          Option(text: 'Sadece atıksu arıtımında', score: 0),
          Option(text: 'Sadece endüstriyel arıtımda', score: 0),
        ],
        category: 'Su',
      ),
      Question(
        text: 'Elektro-ultrafiltrasyon teknolojisinin özelliği nedir?',
        options: [
          Option(text: 'Sadece elektrik enerjisi kullanması', score: 0),
          Option(text: 'Elektrik alanı ile membran performansını artırması', score: 10),
          Option(text: 'Sadece düşük maliyet', score: 0),
          Option(text: 'Sadece basit işletim', score: 0),
        ],
        category: 'Su',
      ),
      Question(
        text: 'Vakumlu evaporasyon teknolojisi hangi durumlarda kullanılır?',
        options: [
          Option(text: 'Sadece tatlı su üretiminde', score: 0),
          Option(text: 'Yüksek konsantrasyonlu atıksu arıtımında', score: 10),
          Option(text: 'Sadece soğuk iklimlerde', score: 0),
          Option(text: 'Sadece sıcak iklimlerde', score: 0),
        ],
        category: 'Su',
      ),
      Question(
        text: 'Plazma arıtma teknolojisinin avantajı nedir?',
        options: [
          Option(text: 'Sadece düşük maliyet', score: 0),
          Option(text: 'Hızlı arıtma ve geniş kirletici yelpazesi', score: 10),
          Option(text: 'Sadece basit işletim', score: 0),
          Option(text: 'Sadece çevre dostu olması', score: 0),
        ],
        category: 'Su',
      ),

      // Su Dağıtım Sistemleri (10 soru)
      Question(
        text: 'Su dağıtım şebekelerinde basınç yönetimi neden önemlidir?',
        options: [
          Option(text: 'Sadece maliyet tasarrufu', score: 0),
          Option(text: 'Su kayıplarını önlemek ve ekipman ömrünü uzatmak', score: 10),
          Option(text: 'Sadece kalite kontrolü', score: 0),
          Option(text: 'Sadece güvenlik', score: 0),
        ],
        category: 'Su',
      ),
      Question(
        text: 'SCADA sistemlerinin su dağıtımındaki rolü nedir?',
        options: [
          Option(text: 'Sadece su tasarrufu', score: 0),
          Option(text: 'Uzaktan izleme, kontrol ve optimizasyon', score: 10),
          Option(text: 'Sadece faturalama', score: 0),
          Option(text: 'Sadece arıza tespiti', score: 0),
        ],
        category: 'Su',
      ),
      Question(
        text: 'Su şebekelerinde su kalitesi nasıl izlenir?',
        options: [
          Option(text: 'Sadece laboratuvar analizi', score: 0),
          Option(text: 'Online sensörler ve düzenli numune alma', score: 10),
          Option(text: 'Sadece görsel kontrol', score: 0),
          Option(text: 'Sadece kullanıcı şikayetleri', score: 0),
        ],
        category: 'Su',
      ),
      Question(
        text: 'Su kayıplarının ana nedenleri nelerdir?',
        options: [
          Option(text: 'Sadece sızıntılar', score: 0),
          Option(text: 'Sızıntılar, kaçaklar ve ölçüm hataları', score: 10),
          Option(text: 'Sadece kaçaklar', score: 0),
          Option(text: 'Sadece ölçüm hataları', score: 0),
        ],
        category: 'Su',
      ),
      Question(
        text: 'District Metered Area (DMA) yaklaşımının amacı nedir?',
        options: [
          Option(text: 'Sadece maliyet azaltma', score: 0),
          Option(text: 'Sızıntı kontrolü ve basınç yönetimi', score: 10),
          Option(text: 'Sadece kalite iyileştirme', score: 0),
          Option(text: 'Sadece kapasite artırma', score: 0),
        ],
        category: 'Su',
      ),
      Question(
        text: 'Su şebekelerinde rehabilitasyon yöntemleri nelerdir?',
        options: [
          Option(text: 'Sadece boru değişimi', score: 0),
          Option(text: 'Boru değişimi, iç kaplama ve patlatma tekniği', score: 10),
          Option(text: 'Sadece iç kaplama', score: 0),
          Option(text: 'Sadece patlatma tekniği', score: 0),
        ],
        category: 'Su',
      ),
      Question(
        text: 'Su dağıtımında akıllı sayaçların faydaları nelerdir?',
        options: [
          Option(text: 'Sadece otomatik okuma', score: 0),
          Option(text: 'Gerçek zamanlı izleme, kaçak tespiti ve optimizasyon', score: 10),
          Option(text: 'Sadece maliyet tasarrufu', score: 0),
          Option(text: 'Sadece kullanıcı memnuniyeti', score: 0),
        ],
        category: 'Su',
      ),
      Question(
        text: 'Su şebekelerinde hidrantların önemi nedir?',
        options: [
          Option(text: 'Sadece itfaiye için', score: 0),
          Option(text: 'Acil durumlar, bakım ve şebeke temizliği', score: 10),
          Option(text: 'Sadece basınç ölçümü', score: 0),
          Option(text: 'Sadece numune alma', score: 0),
        ],
        category: 'Su',
      ),
      Question(
        text: 'Su depolama sistemlerinde hangi sorunlar yaşanabilir?',
        options: [
          Option(text: 'Sadece kapasite yetersizliği', score: 0),
          Option(text: 'Bakteri üremesi, koku problemi ve yapısal sorunlar', score: 10),
          Option(text: 'Sadece koku problemi', score: 0),
          Option(text: 'Sadece yapısal sorunlar', score: 0),
        ],
        category: 'Su',
      ),
      Question(
        text: 'Su dağıtım şebekelerinde su yaşlandırması nedir?',
        options: [
          Option(text: 'Suyun yaşlanması', score: 0),
          Option(text: 'Su şebekede uzun süre beklemesi ve kalite bozulması', score: 10),
          Option(text: 'Sadece kimyasal değişim', score: 0),
          Option(text: 'Sadece sıcaklık değişimi', score: 0),
        ],
        category: 'Su',
      ),

      // Atıksu Arıtma Teknolojileri (15 soru)
      Question(
        text: 'Atıksu arıtımının temel aşamaları nelerdir?',
        options: [
          Option(text: 'Sadece ön arıtma', score: 0),
          Option(text: 'Ön arıtma, birincil, ikincil ve üçüncül arıtma', score: 10),
          Option(text: 'Sadece birincil arıtma', score: 0),
          Option(text: 'Sadece ikincil arıtma', score: 0),
        ],
        category: 'Su',
      ),
      Question(
        text: 'Aktif çamur sisteminde MLSS ne anlama gelir?',
        options: [
          Option(text: 'Mixed Liquor Suspended Solids', score: 10),
          Option(text: 'Maximum Liquid Storage System', score: 0),
          Option(text: 'Main Line Sewage Solution', score: 0),
          Option(text: 'Modern Liquid Treatment System', score: 0),
        ],
        category: 'Su',
      ),
      Question(
        text: 'Biyolojik nutrient removal (BNR) hangi kirleticileri giderir?',
        options: [
          Option(text: 'Sadece organik maddeler', score: 0),
          Option(text: 'Azot ve fosfor', score: 10),
          Option(text: 'Sadece azot', score: 0),
          Option(text: 'Sadece fosfor', score: 0),
        ],
        category: 'Su',
      ),
      Question(
        text: 'Anaerobik arıtma hangi avantajları sağlar?',
        options: [
          Option(text: 'Sadece düşük maliyet', score: 0),
          Option(text: 'Düşük enerji tüketimi ve biogas üretimi', score: 10),
          Option(text: 'Sadece yüksek verim', score: 0),
          Option(text: 'Sadece az çamur üretimi', score: 0),
        ],
        category: 'Su',
      ),
      Question(
        text: 'Membrance Bioreactor (MBR) sisteminin çalışma prensibi nedir?',
        options: [
          Option(text: 'Sadece biyolojik arıtma', score: 0),
          Option(text: 'Biyolojik arıtma ve membran ayrımı', score: 10),
          Option(text: 'Sadece membran filtrasyonu', score: 0),
          Option(text: 'Sadece çökeltme', score: 0),
        ],
        category: 'Su',
      ),
      Question(
        text: 'Denitrifikasyon işleminde hangi koşullar gerekir?',
        options: [
          Option(text: 'Sadece oksijen', score: 0),
          Option(text: 'Anoksik koşullar ve organik karbon', score: 10),
          Option(text: 'Sadece pH kontrolü', score: 0),
          Option(text: 'Sadece sıcaklık kontrolü', score: 0),
        ],
        category: 'Su',
      ),
      Question(
        text: 'Kimyasal fosfor giderimi nasıl yapılır?',
        options: [
          Option(text: 'Sadece pH ayarlama', score: 0),
          Option(text: 'Alüminyum veya demir tuzları ile çökeltme', score: 10),
          Option(text: 'Sadece biyolojik arıtma', score: 0),
          Option(text: 'Sadece filtrasyon', score: 0),
        ],
        category: 'Su',
      ),
      Question(
        text: 'Aktif çamur yaşının önemi nedir?',
        options: [
          Option(text: 'Sadece maliyet', score: 0),
          Option(text: 'Arıtma verimi ve çamur stabilitesi', score: 10),
          Option(text: 'Sadece enerji tüketimi', score: 0),
          Option(text: 'Sadece bakım', score: 0),
        ],
        category: 'Su',
      ),
      Question(
        text: 'Moving Bed Biofilm Reactor (MBBR) sisteminin avantajı nedir?',
        options: [
          Option(text: 'Sadece düşük maliyet', score: 0),
          Option(text: 'Yüksek yüzey alanı ve esnek işletim', score: 10),
          Option(text: 'Sadece az yer kaplaması', score: 0),
          Option(text: 'Sadece basit bakım', score: 0),
        ],
        category: 'Su',
      ),
      Question(
        text: 'Sequencing Batch Reactor (SBR) sisteminin özelliği nedir?',
        options: [
          Option(text: 'Sürekli akış', score: 0),
          Option(text: 'Kesikli (batch) reaktör ile arıtma', score: 10),
          Option(text: 'Sadece yüksek kapasite', score: 0),
          Option(text: 'Sadece düşük maliyet', score: 0),
        ],
        category: 'Su',
      ),
      Question(
        text: 'Çamur susuzlaştırmada kullanılan yöntemler nelerdir?',
        options: [
          Option(text: 'Sadece filtrasyon', score: 0),
          Option(text: 'Pres, santrifüj ve kurutma yatakları', score: 10),
          Option(text: 'Sadece pres', score: 0),
          Option(text: 'Sadece santrifüj', score: 0),
        ],
        category: 'Su',
      ),
      Question(
        text: 'Çamur çürütme işleminin amacı nedir?',
        options: [
          Option(text: 'Sadece hacim azaltma', score: 0),
          Option(text: 'Organik madde stabilizasyonu ve gaz üretimi', score: 10),
          Option(text: 'Sadece koku giderme', score: 0),
          Option(text: 'Sadece dezenfeksiyon', score: 0),
        ],
        category: 'Su',
      ),
      Question(
        text: 'Advanced wastewater treatment hangi teknolojileri içerir?',
        options: [
          Option(text: 'Sadece kimyasal arıtma', score: 0),
          Option(text: 'Membran teknolojisi, adsorpsiyon ve ileri oksidasyon', score: 10),
          Option(text: 'Sadece biyolojik arıtma', score: 0),
          Option(text: 'Sadece fiziksel arıtma', score: 0),
        ],
        category: 'Su',
      ),
      Question(
        text: 'Nutrient recovery atıksu arıtımında hangi faydaları sağlar?',
        options: [
          Option(text: 'Sadece maliyet tasarrufu', score: 0),
          Option(text: 'Sürdürülebilirlik, kaynak geri kazanımı ve çevre koruması', score: 10),
          Option(text: 'Sadece enerji üretimi', score: 0),
          Option(text: 'Sadece kalite iyileştirmesi', score: 0),
        ],
        category: 'Su',
      ),
      Question(
        text: 'Water reuse atıksu arıtımında hangi gereksinimleri karşılamalıdır?',
        options: [
          Option(text: 'Sadece mikrobiyolojik güvenlik', score: 0),
          Option(text: 'Mikrobiyolojik güvenlik, kimyasal güvenlik ve kullanım amacına uygunluk', score: 10),
          Option(text: 'Sadece kimyasal güvenlik', score: 0),
          Option(text: 'Sadece estetik kalite', score: 0),
        ],
        category: 'Su',
      ),

      // Su Analizi ve İzleme (10 soru)
      Question(
        text: 'Su kalitesi parametrelerinin sınıflandırılması nasıl yapılır?',
        options: [
          Option(text: 'Sadece fiziksel ve kimyasal', score: 0),
          Option(text: 'Fiziksel, kimyasal, biyolojik ve radyoaktif', score: 10),
          Option(text: 'Sadece biyolojik', score: 0),
          Option(text: 'Sadece radyoaktif', score: 0),
        ],
        category: 'Su',
      ),
      Question(
        text: 'Online su kalitesi izleme sistemlerinin avantajları nelerdir?',
        options: [
          Option(text: 'Sadece düşük maliyet', score: 0),
          Option(text: 'Gerçek zamanlı veri, sürekli izleme ve hızlı tepki', score: 10),
          Option(text: 'Sadece kolay kurulum', score: 0),
          Option(text: 'Sadece düşük bakım', score: 0),
        ],
        category: 'Su',
      ),
      Question(
        text: 'Su analizinde quality assurance (QA) ne anlama gelir?',
        options: [
          Option(text: 'Sadece analiz yapmak', score: 0),
          Option(text: 'Analiz sonuçlarının güvenilirliğini garanti etmek', score: 10),
          Option(text: 'Sadece hızlı sonuç', score: 0),
          Option(text: 'Sadece düşük maliyet', score: 0),
        ],
        category: 'Su',
      ),
      Question(
        text: 'Su örnekleme stratejileri nelerdir?',
        options: [
          Option(text: 'Sadece rastgele örnekleme', score: 0),
          Option(text: 'Rastgele, sistematik ve kompozit örnekleme', score: 10),
          Option(text: 'Sadece sistematik örnekleme', score: 0),
          Option(text: 'Sadece kompozit örnekleme', score: 0),
        ],
        category: 'Su',
      ),
      Question(
        text: 'Su kalitesi standartlarının belirlenmesinde hangi faktörler dikkate alınır?',
        options: [
          Option(text: 'Sadece sağlık etkileri', score: 0),
          Option(text: 'Sağlık etkileri, estetik faktörler ve kullanım amacı', score: 10),
          Option(text: 'Sadece estetik faktörler', score: 0),
          Option(text: 'Sadece ekonomik faktörler', score: 0),
        ],
        category: 'Su',
      ),
      Question(
        text: 'Biosensor teknolojileri su kalitesi izlemede nasıl kullanılır?',
        options: [
          Option(text: 'Sadece pH ölçümü', score: 0),
          Option(text: 'Hızlı biyolojik analiz ve erken uyarı', score: 10),
          Option(text: 'Sadece sıcaklık ölçümü', score: 0),
          Option(text: 'Sadece bulanıklık ölçümü', score: 0),
        ],
        category: 'Su',
      ),
      Question(
        text: 'Remote sensing su kaynaklarının izlenmesinde nasıl kullanılır?',
        options: [
          Option(text: 'Sadece su seviyesi ölçümü', score: 0),
          Option(text: 'Geniş alan izleme, kirlilik tespiti ve değişim analizi', score: 10),
          Option(text: 'Sadece sıcaklık haritalama', score: 0),
          Option(text: 'Sadece bitki örtüsü analizi', score: 0),
        ],
        category: 'Su',
      ),
      Question(
        text: 'Su analizinde precision ve accuracy arasındaki fark nedir?',
        options: [
          Option(text: 'Aynı şey', score: 0),
          Option(text: 'Precision: tekrarlanabilirlik, Accuracy: doğruluk', score: 10),
          Option(text: 'Precision: hız, Accuracy: maliyet', score: 0),
          Option(text: 'Precision: maliyet, Accuracy: kalite', score: 0),
        ],
        category: 'Su',
      ),
      Question(
        text: 'Su kalitesi izleme ağları nasıl tasarlanır?',
        options: [
          Option(text: 'Sadece eşit aralıklarla', score: 0),
          Option(text: 'Risk analizi, kullanım amacı ve coğrafi faktörler', score: 10),
          Option(text: 'Sadece kullanıcı sayısına göre', score: 0),
          Option(text: 'Sadece maliyet etkinliğine göre', score: 0),
        ],
        category: 'Su',
      ),
      Question(
        text: 'Su kalitesi verilerinin değerlendirilmesinde hangi istatistiksel yöntemler kullanılır?',
        options: [
          Option(text: 'Sadece ortalama', score: 0),
          Option(text: 'Trend analizi, korelasyon ve varyans analizi', score: 10),
          Option(text: 'Sadece trend analizi', score: 0),
          Option(text: 'Sadece korelasyon', score: 0),
        ],
        category: 'Su',
      ),
    ];
  }

  /// Su Politika ve Yönetimi sorularını getirir (25 soru)
  static List<Question> getTurkishWaterPolicy() {
    return [
      Question(
        text: 'Su hakkı (water right) nedir?',
        options: [
          Option(text: 'Sadece su satın alma hakkı', score: 0),
          Option(text: 'Su kaynaklarına yasal erişim ve kullanım hakkı', score: 10),
          Option(text: 'Sadece su tasarrufu yapma hakkı', score: 0),
          Option(text: 'Sadece su kalitesi talep etme hakkı', score: 0),
        ],
        category: 'Su',
      ),
      Question(
        text: 'Su politikalarında integrated water resources management (IWRM) yaklaşımı nedir?',
        options: [
          Option(text: 'Sadece su arıtma', score: 0),
          Option(text: 'Tüm su kaynaklarının koordineli yönetimi', score: 10),
          Option(text: 'Sadece su dağıtımı', score: 0),
          Option(text: 'Sadece su tasarrufu', score: 0),
        ],
        category: 'Su',
      ),
      Question(
        text: 'Su fiyatlandırmasında inclining block tariff (artımlı tarifeler) nasıl çalışır?',
        options: [
          Option(text: 'Sabit fiyat', score: 0),
          Option(text: 'Tüketim arttıkça birim fiyat artar', score: 10),
          Option(text: 'Sezonluk değişken fiyat', score: 0),
          Option(text: 'Kullanıcı tipine göre fiyat', score: 0),
        ],
        category: 'Su',
      ),
      Question(
        text: 'Su yönetiminde public-private partnership (kamu-özel ortaklığı) modeli nedir?',
        options: [
          Option(text: 'Sadece devlet yönetimi', score: 0),
          Option(text: 'Kamu ve özel sektörün ortak su hizmeti sunması', score: 10),
          Option(text: 'Sadece özel sektör yönetimi', score: 0),
          Option(text: 'Sadece yerel yönetim', score: 0),
        ],
        category: 'Su',
      ),
      Question(
        text: 'Su kaynaklarında allocation (paylaştırma) nasıl yapılır?',
        options: [
          Option(text: 'Sadece ilk gelen alır', score: 0),
          Option(text: 'İhtiyaç, hak ve sürdürülebilirlik temelinde dengeli paylaştırma', score: 10),
          Option(text: 'Sadece siyasi karar', score: 0),
          Option(text: 'Sadece ekonomik güç', score: 0),
        ],
        category: 'Su',
      ),
      Question(
        text: 'Su politikalarında water pricing reform (su fiyatlandırma reformu) hangi amaçları taşır?',
        options: [
          Option(text: 'Sadece gelir artışı', score: 0),
          Option(text: 'Verimlilik artışı, sürdürülebilirlik ve adil dağıtım', score: 10),
          Option(text: 'Sadece tasarruf teşviki', score: 0),
          Option(text: 'Sadece kalite iyileştirmesi', score: 0),
        ],
        category: 'Su',
      ),
      Question(
        text: 'Su yönetiminde stakeholder participation (paydaş katılımı) nasıl sağlanır?',
        options: [
          Option(text: 'Sadece resmi toplantılar', score: 0),
          Option(text: 'Konsültasyon, ortak karar verme ve şeffaflık', score: 10),
          Option(text: 'Sadece anket çalışmaları', score: 0),
          Option(text: 'Sadece medya duyuruları', score: 0),
        ],
        category: 'Su',
      ),
      Question(
        text: 'Su kaynaklarında environmental flow (çevresel akış) nedir?',
        options: [
          Option(text: 'Sadece minimum akış', score: 0),
          Option(text: 'Ekosistemi korumak için gerekli su miktarı', score: 10),
          Option(text: 'Sadece taşkın akışı', score: 0),
          Option(text: 'Sadece mevsimsel akış', score: 0),
        ],
        category: 'Su',
      ),
      Question(
        text: 'Su politikalarında water security (su güvenliği) ne anlama gelir?',
        options: [
          Option(text: 'Sadece su temini güvenliği', score: 0),
          Option(text: 'Sürdürülebilir su erişimi ve risk yönetimi', score: 10),
          Option(text: 'Sadece su kalitesi güvenliği', score: 0),
          Option(text: 'Sadece altyapı güvenliği', score: 0),
        ],
        category: 'Su',
      ),
      Question(
        text: 'Su yönetiminde basin approach (havza yaklaşımı) nedir?',
        options: [
          Option(text: 'Sadece tek nehir yönetimi', score: 0),
          Option(text: 'Havza sınırları içinde koordineli kaynak yönetimi', score: 10),
          Option(text: 'Sadece sınır ötesi yönetim', score: 0),
          Option(text: 'Sadece ulusal yönetim', score: 0),
        ],
        category: 'Su',
      ),
      Question(
        text: 'Su politikalarında water governance (su yönetişimi) hangi bileşenleri içerir?',
        options: [
          Option(text: 'Sadece teknik yönetim', score: 0),
          Option(text: 'Kurumsal yapı, karar verme süreçleri ve hesap verebilirlik', score: 10),
          Option(text: 'Sadece finansal yönetim', score: 0),
          Option(text: 'Sadece operasyonel yönetim', score: 0),
        ],
        category: 'Su',
      ),
      Question(
        text: 'Su kaynaklarında transboundary cooperation (sınır ötesi işbirliği) neden önemlidir?',
        options: [
          Option(text: 'Sadece siyasi nedenler', score: 0),
          Option(text: 'Paylaşılan su kaynaklarının sürdürülebilir yönetimi', score: 10),
          Option(text: 'Sadece ekonomik nedenler', score: 0),
          Option(text: 'Sadece çevresel nedenler', score: 0),
        ],
        category: 'Su',
      ),
      Question(
        text: 'Su politikalarında water demand management (su talep yönetimi) hangi stratejileri içerir?',
        options: [
          Option(text: 'Sadece arz artırma', score: 0),
          Option(text: 'Tasarruf teşviki, verimlilik ve alternatif kaynaklar', score: 10),
          Option(text: 'Sadece fiyat kontrolü', score: 0),
          Option(text: 'Sadece teknoloji geliştirme', score: 0),
        ],
        category: 'Su',
      ),
      Question(
        text: 'Su yönetiminde adaptive management (uyum sağlayıcı yönetim) nasıl uygulanır?',
        options: [
          Option(text: 'Sadece sabit planlar', score: 0),
          Option(text: 'Öğrenme, izleme ve stratejiye göre uyarlama', score: 10),
          Option(text: 'Sadece kriz yönetimi', score: 0),
          Option(text: 'Sadece risk yönetimi', score: 0),
        ],
        category: 'Su',
      ),
      Question(
        text: 'Su politikalarında water equity (su eşitliği) nasıl sağlanır?',
        options: [
          Option(text: 'Sadece eşit fiyat', score: 0),
          Option(text: 'Erişilebilirlik, kalite ve adalet temelinde hizmet', score: 10),
          Option(text: 'Sadece eşit miktar', score: 0),
          Option(text: 'Sadece eşit kalite', score: 0),
        ],
        category: 'Su',
      ),
      Question(
        text: 'Su kaynaklarında catchment management (havza yönetimi) hangi aktiviteleri içerir?',
        options: [
          Option(text: 'Sadece su depolama', score: 0),
          Option(text: 'Arazi kullanımı, orman yönetimi ve kirlilik kontrolü', score: 10),
          Option(text: 'Sadece sulama yönetimi', score: 0),
          Option(text: 'Sadece balıkçılık yönetimi', score: 0),
        ],
        category: 'Su',
      ),
      Question(
        text: 'Su politikalarında water efficiency (su verimliliği) nasıl ölçülür?',
        options: [
          Option(text: 'Sadece toplam üretim', score: 0),
          Option(text: 'Çıktı başına su kullanımı, kayıp oranları ve hizmet kalitesi', score: 10),
          Option(text: 'Sadece teknik verimlilik', score: 0),
          Option(text: 'Sadece ekonomik verimlilik', score: 0),
        ],
        category: 'Su',
      ),
      Question(
        text: 'Su yönetiminde water footprint (su ayak izi) konsepti nedir?',
        options: [
          Option(text: 'Sadece su tüketimi', score: 0),
          Option(text: 'Ürün veya hizmetin toplam su gereksinimi', score: 10),
          Option(text: 'Sadece doğrudan kullanım', score: 0),
          Option(text: 'Sadece endirekt kullanım', score: 0),
        ],
        category: 'Su',
      ),
      Question(
        text: 'Su politikalarında cross-sectoral coordination (sektörler arası koordinasyon) neden gereklidir?',
        options: [
          Option(text: 'Sadece maliyet tasarrufu', score: 0),
          Option(text: 'Çelişkili ihtiyaçların dengelenmesi ve optimum kaynak kullanımı', score: 10),
          Option(text: 'Sadece verimlilik artışı', score: 0),
          Option(text: 'Sadece çevre koruması', score: 0),
        ],
        category: 'Su',
      ),
      Question(
        text: 'Su yönetiminde water accounting (su muhasebesi) hangi bilgileri sağlar?',
        options: [
          Option(text: 'Sadece finansal kayıtlar', score: 0),
          Option(text: 'Su giriş-çıkış, kullanım ve kayıpların detaylı takibi', score: 10),
          Option(text: 'Sadece kalite ölçümleri', score: 0),
          Option(text: 'Sadece miktar ölçümleri', score: 0),
        ],
        category: 'Su',
      ),
      Question(
        text: 'Su politikalarında water poverty index (su yoksulluk endeksi) nelere bakar?',
        options: [
          Option(text: 'Sadece gelir düzeyi', score: 0),
          Option(text: 'Erişim, kalite, kapasite, çevre ve verimlilik', score: 10),
          Option(text: 'Sadece coğrafi erişim', score: 0),
          Option(text: 'Sadece teknik altyapı', score: 0),
        ],
        category: 'Su',
      ),
      Question(
        text: 'Su yönetiminde stakeholder engagement strategy (paydaş katılım stratejisi) nasıl geliştirilir?',
        options: [
          Option(text: 'Sadece tek seferlik toplantılar', score: 0),
          Option(text: 'Sürekli diyalog, eğitim ve ortak değer yaratma', score: 10),
          Option(text: 'Sadece resmi danışma', score: 0),
          Option(text: 'Sadece medya kampanyaları', score: 0),
        ],
        category: 'Su',
      ),
      Question(
        text: 'Su politikalarında sustainability principles (sürdürülebilirlik ilkeleri) nelerdir?',
        options: [
          Option(text: 'Sadece çevresel koruma', score: 0),
          Option(text: 'Ekonomik, sosyal ve çevresel dengenin korunması', score: 10),
          Option(text: 'Sadece ekonomik verimlilik', score: 0),
          Option(text: 'Sadece sosyal adalet', score: 0),
        ],
        category: 'Su',
      ),
      Question(
        text: 'Su yönetiminde institutional capacity building (kurumsal kapasite geliştirme) hangi alanları kapsar?',
        options: [
          Option(text: 'Sadece teknik eğitim', score: 0),
          Option(text: 'İnsan kaynakları, süreçler, teknoloji ve yönetim sistemleri', score: 10),
          Option(text: 'Sadece finansal yönetim', score: 0),
          Option(text: 'Sadece operasyonel geliştirme', score: 0),
        ],
        category: 'Su',
      ),
    ];
  }

  /// Su Teknolojisi Ek sorularını getirir (25 soru)
  static List<Question> getTurkishWaterTechnologyAdvanced() {
    return [
      Question(
        text: 'Smart water grids (akıllı su şebekeleri) hangi teknolojileri kullanır?',
        options: [
          Option(text: 'Sadece sensörler', score: 0),
          Option(text: 'IoT, big data analitiği ve otomasyon sistemleri', score: 10),
          Option(text: 'Sadece SCADA', score: 0),
          Option(text: 'Sadece mobil uygulamalar', score: 0),
        ],
        category: 'Su',
      ),
      Question(
        text: 'Desalination (tatlılaştırma) teknolojilerinde en yaygın yöntem hangisidir?',
        options: [
          Option(text: 'Damlama', score: 0),
          Option(text: 'Reverse osmosis (ters ozmoz)', score: 10),
          Option(text: 'Filtrasyon', score: 0),
          Option(text: 'Destilasyon', score: 0),
        ],
        category: 'Su',
      ),
      Question(
        text: 'Su teknolojilerinde membrane bioreactor (MBR) sisteminin avantajı nedir?',
        options: [
          Option(text: 'Sadece düşük maliyet', score: 0),
          Option(text: 'Yüksek kaliteli çıkış suyu ve kompakt tasarım', score: 10),
          Option(text: 'Sadece düşük enerji tüketimi', score: 0),
          Option(text: 'Sadece kolay bakım', score: 0),
        ],
        category: 'Su',
      ),
      Question(
        text: 'Su teknolojilerinde forward osmosis (ileri ozmoz) nasıl çalışır?',
        options: [
          Option(text: 'Sadece basınç uygulaması', score: 0),
          Option(text: 'Çekim gücü farkıyla suyu yarı geçirgen membrandan geçirme', score: 10),
          Option(text: 'Sadece elektrik enerjisi', score: 0),
          Option(text: 'Sadece ısı enerjisi', score: 0),
        ],
        category: 'Su',
      ),
      Question(
        text: 'Su arıtma teknolojilerinde photocatalysis (fotokataliz) nasıl çalışır?',
        options: [
          Option(text: 'Sadece ışık', score: 0),
          Option(text: 'UV ışık ve katalizör ile kirleticileri parçalama', score: 10),
          Option(text: 'Sadece ısı', score: 0),
          Option(text: 'Sadece elektrik', score: 0),
        ],
        category: 'Su',
      ),
      Question(
        text: 'Su teknolojilerinde electrochemical treatment (elektrokimyasal arıtma) hangi kirleticileri temizler?',
        options: [
          Option(text: 'Sadece organik maddeler', score: 0),
          Option(text: 'Ağır metaller, organik kirleticiler ve inorganik maddeler', score: 10),
          Option(text: 'Sadece bakteriler', score: 0),
          Option(text: 'Sadece virüsler', score: 0),
        ],
        category: 'Su',
      ),
      Question(
        text: 'Su dağıtım teknolojilerinde real-time monitoring (gerçek zamanlı izleme) hangi verileri toplar?',
        options: [
          Option(text: 'Sadece basınç', score: 0),
          Option(text: 'Basınç, akış, kalite ve sistem performansı', score: 10),
          Option(text: 'Sadece akış', score: 0),
          Option(text: 'Sadece sıcaklık', score: 0),
        ],
        category: 'Su',
      ),
      Question(
        text: 'Su teknolojilerinde bioaugmentation (biyo-artırma) nedir?',
        options: [
          Option(text: 'Sadece enzim ekleme', score: 0),
          Option(text: 'Arıtma verimini artırmak için faydalı mikroorganizma ekleme', score: 10),
          Option(text: 'Sadece besleyici ekleme', score: 0),
          Option(text: 'Sadece pH ayarlama', score: 0),
        ],
        category: 'Su',
      ),
      Question(
        text: 'Su teknolojilerinde capacitive deionization (kapasitif deiyonizasyon) nasıl çalışır?',
        options: [
          Option(text: 'Sadece elektrik', score: 0),
          Option(text: 'Elektrik alanıyla iyonları elektrodlarda biriktirme', score: 10),
          Option(text: 'Sadece basınç', score: 0),
          Option(text: 'Sadece sıcaklık', score: 0),
        ],
        category: 'Su',
      ),
      Question(
        text: 'Su arıtma teknolojilerinde moving bed biofilm reactor (MBBR) sistemi nedir?',
        options: [
          Option(text: 'Sadece aktif çamur', score: 0),
          Option(text: 'Hareketli taşıyıcılar üzerinde biyofilm ile arıtma', score: 10),
          Option(text: 'Sadece sabit biyofilm', score: 0),
          Option(text: 'Sadece kimyasal arıtma', score: 0),
        ],
        category: 'Su',
      ),
      Question(
        text: 'Su teknolojilerinde graphene oxide membranes (grafen oksit membranlar) hangi avantajlara sahiptir?',
        options: [
          Option(text: 'Sadece düşük maliyet', score: 0),
          Option(text: 'Yüksek su geçirgenliği ve seçici filtrasyon', score: 10),
          Option(text: 'Sadece dayanıklılık', score: 0),
          Option(text: 'Sadece kolay üretim', score: 0),
        ],
        category: 'Su',
      ),
      Question(
        text: 'Su teknolojilerinde ultrasound-assisted treatment (ultrason destekli arıtma) nasıl çalışır?',
        options: [
          Option(text: 'Sadece ses dalgaları', score: 0),
          Option(text: 'Ultrasonik kavitasyonla kirleticileri parçalama', score: 10),
          Option(text: 'Sadece ısı üretimi', score: 0),
          Option(text: 'Sadece karıştırma', score: 0),
        ],
        category: 'Su',
      ),
      Question(
        text: 'Su dağıtım teknolojilerinde pressure management valves (basınç yönetim vanaları) nasıl çalışır?',
        options: [
          Option(text: 'Sadece sabit basınç', score: 0),
          Option(text: 'Akış ve zamana göre basıncı otomatik ayarlama', score: 10),
          Option(text: 'Sadece manuel kontrol', score: 0),
          Option(text: 'Sadece güvenlik', score: 0),
        ],
        category: 'Su',
      ),
      Question(
        text: 'Su teknolojilerinde electrocoagulation (elektrokoagülasyon) hangi kirleticileri uzaklaştırır?',
        options: [
          Option(text: 'Sadece organik maddeler', score: 0),
          Option(text: 'Ağır metaller, askıda katılar ve renkli kirleticiler', score: 10),
          Option(text: 'Sadece bakteriler', score: 0),
          Option(text: 'Sadece virüsler', score: 0),
        ],
        category: 'Su',
      ),
      Question(
        text: 'Su arıtma teknolojilerinde ozon-biological activated carbon (O₃-BAC) sistemi nasıl çalışır?',
        options: [
          Option(text: 'Sadece ozon', score: 0),
          Option(text: 'Ozon oksidasyonu ve aktif karbon biyolojik arıtma kombinasyonu', score: 10),
          Option(text: 'Sadece aktif karbon', score: 0),
          Option(text: 'Sadece biyolojik arıtma', score: 0),
        ],
        category: 'Su',
      ),
      Question(
        text: 'Su teknolojilerinde anaerobic membrane bioreactors (AnMBR) hangi avantajları sağlar?',
        options: [
          Option(text: 'Sadece enerji üretimi', score: 0),
          Option(text: 'Düşük enerji tüketimi, biogas üretimi ve yüksek kalite', score: 10),
          Option(text: 'Sadece düşük maliyet', score: 0),
          Option(text: 'Sadece küçük alan', score: 0),
        ],
        category: 'Su',
      ),
      Question(
        text: 'Su teknolojilerinde smart sensors (akıllı sensörler) hangi parametreleri ölçer?',
        options: [
          Option(text: 'Sadece pH', score: 0),
          Option(text: 'pH, bulanıklık, iletkenlik, klor ve mikroorganizma', score: 10),
          Option(text: 'Sadece sıcaklık', score: 0),
          Option(text: 'Sadece basınç', score: 0),
        ],
        category: 'Su',
      ),
      Question(
        text: 'Su arıtma teknolojilerinde high-rate clarification (yüksek hızlı açıklama) nasıl çalışır?',
        options: [
          Option(text: 'Sadece çökeltme', score: 0),
          Option(text: 'Flokülasyon ve hızlı çökeltme ile yüksek kapasiteli arıtma', score: 10),
          Option(text: 'Sadece filtrasyon', score: 0),
          Option(text: 'Sadece flotasyon', score: 0),
        ],
        category: 'Su',
      ),
      Question(
        text: 'Su teknolojilerinde hydraulic fracturing water treatment (hidrolik kırılma suyu arıtma) özel gereksinimleri nelerdir?',
        options: [
          Option(text: 'Sadece büyük kapasite', score: 0),
          Option(text: 'Yüksek tuz içeriği, kimyasal kirleticiler ve özel arıtma', score: 10),
          Option(text: 'Sadece düşük maliyet', score: 0),
          Option(text: 'Sadece hızlı işlem', score: 0),
        ],
        category: 'Su',
      ),
      Question(
        text: 'Su arıtma teknolojilerinde ballasted clarification (balastlı açıklama) sistemi nedir?',
        options: [
          Option(text: 'Sadece çökeltme', score: 0),
          Option(text: 'Mikro kum veya polimer balast ile hızlı çökeltme', score: 10),
          Option(text: 'Sadece flotasyon', score: 0),
          Option(text: 'Sadece filtrasyon', score: 0),
        ],
        category: 'Su',
      ),
      Question(
        text: 'Su teknolojilerinde advanced oxidation processes (AOP) hangi kirleticileri etkili şekilde temizler?',
        options: [
          Option(text: 'Sadece inorganik maddeler', score: 0),
          Option(text: 'İlaç kalıntıları, pestisit ve dirençli organik kirleticiler', score: 10),
          Option(text: 'Sadece ağır metaller', score: 0),
          Option(text: 'Sadece radyoaktif maddeler', score: 0),
        ],
        category: 'Su',
      ),
      Question(
        text: 'Su dağıtım teknolojilerinde district metered areas (DMA) nedir?',
        options: [
          Option(text: 'Sadece bölgesel sayaç', score: 0),
          Option(text: 'Sızıntı tespiti ve basınç yönetimi için izole edilmiş bölgeler', score: 10),
          Option(text: 'Sadece faturalama', score: 0),
          Option(text: 'Sadece kalite izleme', score: 0),
        ],
        category: 'Su',
      ),
      Question(
        text: 'Su teknolojilerinde membrane distillation (membran distilasyonu) nasıl çalışır?',
        options: [
          Option(text: 'Sadece basınç', score: 0),
          Option(text: 'Sıcaklık farkıyla buharlaştırma ve yoğunlaştırma', score: 10),
          Option(text: 'Sadece elektrik', score: 0),
          Option(text: 'Sadece kimyasal', score: 0),
        ],
        category: 'Su',
      ),
      Question(
        text: 'Su arıtma teknolojilerinde sequential batch reactor (SBR) sistemi nasıl çalışır?',
        options: [
          Option(text: 'Sürekli akış', score: 0),
          Option(text: 'Dolum, reaksiyon, çökeltme ve boşaltma döngüleri', score: 10),
          Option(text: 'Sadece tek aşama', score: 0),
          Option(text: 'Sadece karışık reaktör', score: 0),
        ],
        category: 'Su',
      ),
      Question(
        text: 'Su teknolojilerinde bio-electrochemical systems (biyo-elektrokimyasal sistemler) hangi faydaları sağlar?',
        options: [
          Option(text: 'Sadece arıtma', score: 0),
          Option(text: 'Enerji üretimi, arıtma ve kaynak geri kazanımı', score: 10),
          Option(text: 'Sadece enerji üretimi', score: 0),
          Option(text: 'Sadece maliyet azaltımı', score: 0),
        ],
        category: 'Su',
      ),
    ];
  }

  /// Su ve Çevre sorularını getirir (25 soru)
  static List<Question> getTurkishWaterEnvironment() {
    return [
      Question(
        text: 'Su kaynaklarının çevresel etkilerini değerlendirme yöntemi hangisidir?',
        options: [
          Option(text: 'Sadece ekonomik analiz', score: 0),
          Option(text: 'Yaşam döngüsü değerlendirmesi ve ekolojik ayak izi', score: 10),
          Option(text: 'Sadece teknik fizibilite', score: 0),
          Option(text: 'Sadece sosyal etki', score: 0),
        ],
        category: 'Su',
      ),
      Question(
        text: 'Su kaynaklarında ecosystem services (ekosistem hizmetleri) nelerdir?',
        options: [
          Option(text: 'Sadece su temini', score: 0),
          Option(text: 'Su döngüsü, habitat sağlama ve iklim düzenleme', score: 10),
          Option(text: 'Sadece balıkçılık', score: 0),
          Option(text: 'Sadece rekreasyon', score: 0),
        ],
        category: 'Su',
      ),
      Question(
        text: 'Su kirliliğinin biyoçeşitlilik üzerindeki etkisi nedir?',
        options: [
          Option(text: 'Sadece olumlu etki', score: 0),
          Option(text: 'Tür kaybı, habitat bozulması ve ekolojik dengenin bozulması', score: 10),
          Option(text: 'Sadece geçici etki', score: 0),
          Option(text: 'Sadece ekonomik etki', score: 0),
        ],
        category: 'Su',
      ),
      Question(
        text: 'Sulak alanların (wetlands) çevresel faydaları nelerdir?',
        options: [
          Option(text: 'Sadece su depolama', score: 0),
          Option(text: 'Su filtreleme, taşkın kontrolü ve karbon depolama', score: 10),
          Option(text: 'Sadece rekreasyon', score: 0),
          Option(text: 'Sadece tarım', score: 0),
        ],
        category: 'Su',
      ),
      Question(
        text: 'Su kaynaklarında over-extraction (aşırı çekim) hangi çevresel sorunlara yol açar?',
        options: [
          Option(text: 'Sadece su kıtlığı', score: 0),
          Option(text: 'Toprak çökmesi, habitat kaybı ve ekosistemin bozulması', score: 10),
          Option(text: 'Sadece ekonomik kayıp', score: 0),
          Option(text: 'Sadece sosyal etki', score: 0),
        ],
        category: 'Su',
      ),
      Question(
        text: 'Su kaynaklarında groundwater depletion (yer altı suyu tükenmesi) nasıl önlenir?',
        options: [
          Option(text: 'Sadece çekim azaltımı', score: 0),
          Option(text: 'Yeniden doldurma, verimli kullanım ve alternatif kaynaklar', score: 10),
          Option(text: 'Sadece teknoloji geliştirme', score: 0),
          Option(text: 'Sadece fiyatlandırma', score: 0),
        ],
        category: 'Su',
      ),
      Question(
        text: 'Su kalitesi ve iklim değişikliği arasındaki ilişki nedir?',
        options: [
          Option(text: 'İlişki yok', score: 0),
          Option(text: 'Sıcaklık artışı, kuraklık ve aşırı yağış su kalitesini etkiler', score: 10),
          Option(text: 'Sadece tek yönlü etki', score: 0),
          Option(text: 'Sadece olumlu etki', score: 0),
        ],
        category: 'Su',
      ),
      Question(
        text: 'Su kaynaklarında acidification (asidifikasyon) sorunu nasıl oluşur?',
        options: [
          Option(text: 'Sadece endüstriyel atık', score: 0),
          Option(text: 'Asidik yağmur, asidik toprak ve endüstriyel kirlilik', score: 10),
          Option(text: 'Sadece doğal süreç', score: 0),
          Option(text: 'Sadece tarımsal faaliyet', score: 0),
        ],
        category: 'Su',
      ),
      Question(
        text: 'Su ekosistemi restorasyonu (restoration) hangi yöntemleri içerir?',
        options: [
          Option(text: 'Sadece ağaç dikimi', score: 0),
          Option(text: 'Habitat iyileştirme, kirlilik kontrolü ve doğal akış restorasyonu', score: 10),
          Option(text: 'Sadece mühendislik çözümleri', score: 0),
          Option(text: 'Sadece yasal düzenlemeler', score: 0),
        ],
        category: 'Su',
      ),
      Question(
        text: 'Su kaynaklarında environmental flow requirements (çevresel akış gereksinimleri) nasıl belirlenir?',
        options: [
          Option(text: 'Sadece teknik hesaplama', score: 0),
          Option(text: 'Ekolojik araştırma, tür ihtiyaçları ve mevsimsel gereksinimler', score: 10),
          Option(text: 'Sadece ekonomik değerlendirme', score: 0),
          Option(text: 'Sadece sosyal ihtiyaçlar', score: 0),
        ],
        category: 'Su',
      ),
      Question(
        text: 'Su kaynaklarında pollution load (kirlilik yükü) nasıl ölçülür?',
        options: [
          Option(text: 'Sadece görsel kontrol', score: 0),
          Option(text: 'Kimyasal, fiziksel ve biyolojik parametrelerin analizi', score: 10),
          Option(text: 'Sadece koku testi', score: 0),
          Option(text: 'Sadece tat testi', score: 0),
        ],
        category: 'Su',
      ),
      Question(
        text: 'Su ekosistemlerinde bioaccumulation (biyo-birikim) nedir?',
        options: [
          Option(text: 'Sadece besin zincirinde artış', score: 0),
          Option(text: 'Kirleticilerin organizmalarda zamanla birikmesi', score: 10),
          Option(text: 'Sadece besin üretimi', score: 0),
          Option(text: 'Sadece büyüme hızı', score: 0),
        ],
        category: 'Su',
      ),
      Question(
        text: 'Su kaynaklarında watershed management (havza yönetimi) hangi prensiplere dayanır?',
        options: [
          Option(text: 'Sadece teknik çözümler', score: 0),
          Option(text: 'Bütüncül yaklaşım, ekosistem temelli ve paydaş katılımı', score: 10),
          Option(text: 'Sadece ekonomik verimlilik', score: 0),
          Option(text: 'Sadece teknik optimizasyon', score: 0),
        ],
        category: 'Su',
      ),
      Question(
        text: 'Su kalitesinde eutrophication (ötrofikasyon) kontrolü nasıl yapılır?',
        options: [
          Option(text: 'Sadece kimyasal çözümler', score: 0),
          Option(text: 'Besleyici madde azaltımı, filtreleme ve biyolojik kontrol', score: 10),
          Option(text: 'Sadece mekanik temizlik', score: 0),
          Option(text: 'Sadece değiştirme', score: 0),
        ],
        category: 'Su',
      ),
      Question(
        text: 'Su kaynaklarında acid mine drainage (asit maden dreneji) sorunu nasıl çözülür?',
        options: [
          Option(text: 'Sadece kapatma', score: 0),
          Option(text: 'Nötralizasyon, geçirimsiz bariyer ve bitki örtüsü restorasyonu', score: 10),
          Option(text: 'Sadece boşaltma', score: 0),
          Option(text: 'Sadece karıştırma', score: 0),
        ],
        category: 'Su',
      ),
      Question(
        text: 'Su ekosistemlerinde invasive species (işgalci türler) su kaynaklarını nasıl etkiler?',
        options: [
          Option(text: 'Sadece olumlu etki', score: 0),
          Option(text: 'Yerel türlerin rekabeti, habitat bozulması ve ekolojik dengenin bozulması', score: 10),
          Option(text: 'Sadece ekonomik etki', score: 0),
          Option(text: 'Sadece görsel etki', score: 0),
        ],
        category: 'Su',
      ),
      Question(
        text: 'Su kaynaklarında thermal pollution (ısı kirliliği) hangi kaynaklardan oluşur?',
        options: [
          Option(text: 'Sadece endüstriyel atık', score: 0),
          Option(text: 'Endüstriyel soğutma, enerji santralleri ve iklim değişikliği', score: 10),
          Option(text: 'Sadece doğal kaynaklar', score: 0),
          Option(text: 'Sadece tarımsal faaliyet', score: 0),
        ],
        category: 'Su',
      ),
      Question(
        text: 'Su ekosistemi koruma stratejileri nelerdir?',
        options: [
          Option(text: 'Sadece yasal koruma', score: 0),
          Option(text: 'Habitat koruması, kirlilik kontrolü ve sürdürülebilir kullanım', score: 10),
          Option(text: 'Sadece bilimsel araştırma', score: 0),
          Option(text: 'Sadece eğitim programları', score: 0),
        ],
        category: 'Su',
      ),
      Question(
        text: 'Su kaynaklarında microplastics (mikroplastik) kirliliğinin etkileri nelerdir?',
        options: [
          Option(text: 'Sadece fiziksel etki', score: 0),
          Option(text: 'Besin zinciri etkisi, toksisite ve ekolojik bozulma', score: 10),
          Option(text: 'Sadece ekonomik etki', score: 0),
          Option(text: 'Sadece estetik etki', score: 0),
        ],
        category: 'Su',
      ),
      Question(
        text: 'Su ekosistemi monitoring (izleme) sistemleri hangi verileri toplar?',
        options: [
          Option(text: 'Sadece su seviyesi', score: 0),
          Option(text: 'Su kalitesi, biyoçeşitlilik, habitat durumu ve ekolojik sağlık', score: 10),
          Option(text: 'Sadece meteorolojik veri', score: 0),
          Option(text: 'Sadece hidrometrik veri', score: 0),
        ],
        category: 'Su',
      ),
      Question(
        text: 'Su kaynaklarında riparian zones (kıyı bölgeleri) ekolojik önemi nedir?',
        options: [
          Option(text: 'Sadece estetik değer', score: 0),
          Option(text: 'Habitat sağlama, erozyon kontrolü ve su kalitesi iyileştirme', score: 10),
          Option(text: 'Sadece rekreasyon', score: 0),
          Option(text: 'Sadece tarım', score: 0),
        ],
        category: 'Su',
      ),
      Question(
        text: 'Su ekosistemi restoration projects (restorasyon projeleri) hangi başarı kriterlerini içerir?',
        options: [
          Option(text: 'Sadece maliyet', score: 0),
          Option(text: 'Biyoçeşitlilik artışı, su kalitesi iyileştirmesi ve ekolojik fonksiyon restorasyonu', score: 10),
          Option(text: 'Sadece görsel iyileştirme', score: 0),
          Option(text: 'Sadece teknik başarı', score: 0),
        ],
        category: 'Su',
      ),
      Question(
        text: 'Su kaynaklarında environmental compliance (çevresel uyum) nasıl sağlanır?',
        options: [
          Option(text: 'Sadece yasal düzenlemeler', score: 0),
          Option(text: 'İzleme, denetim, eğitim ve teşvik sistemleri', score: 10),
          Option(text: 'Sadece teknik standartlar', score: 0),
          Option(text: 'Sadece mali yaptırımlar', score: 0),
        ],
        category: 'Su',
      ),
      Question(
        text: 'Su ekosistemi resilience (dayanıklılığı) nasıl güçlendirilir?',
        options: [
          Option(text: 'Sadece tek tür koruması', score: 0),
          Option(text: 'Çeşitlilik koruması, habitat iyileştirme ve kirlilik azaltımı', score: 10),
          Option(text: 'Sadece teknik çözümler', score: 0),
          Option(text: 'Sadece ekonomik destek', score: 0),
        ],
        category: 'Su',
      ),
    ];
  }

  /// Su ve Toplum sorularını getirir (25 soru)
  static List<Question> getTurkishWaterSociety() {
    return [
      Question(
        text: 'Su adaleti (water justice) hangi boyutları içerir?',
        options: [
          Option(text: 'Sadece ekonomik eşitlik', score: 0),
          Option(text: 'Erişim adaleti, kalite eşitliği ve sürdürülebilir fayda paylaşımı', score: 10),
          Option(text: 'Sadece coğrafi eşitlik', score: 0),
          Option(text: 'Sadece sosyal statü', score: 0),
        ],
        category: 'Su',
      ),
      Question(
        text: 'Su kıtlığından en çok etkilenen toplum grupları hangileridir?',
        options: [
          Option(text: 'Sadece şehir sakinleri', score: 0),
          Option(text: 'Düşük gelir grupları, kırsal topluluklar ve kadınlar', score: 10),
          Option(text: 'Sadece endüstriyel kullanıcılar', score: 0),
          Option(text: 'Sadece turizm sektörü', score: 0),
        ],
        category: 'Su',
      ),
      Question(
        text: 'Su hizmetlerinde affordability (erişilebilirlik) nasıl tanımlanır?',
        options: [
          Option(text: 'Sadece maliyet miktarı', score: 0),
          Option(text: 'Hanenin gelirinden su faturasının oranı', score: 10),
          Option(text: 'Sadece teknik erişim', score: 0),
          Option(text: 'Sadece coğrafi erişim', score: 0),
        ],
        category: 'Su',
      ),
      Question(
        text: 'Su kaynakları çatışmalarının temel nedenleri nelerdir?',
        options: [
          Option(text: 'Sadece teknoloji eksikliği', score: 0),
          Option(text: 'Kaynak kıtlığı, eşitsiz dağılım ve yönetim yetersizlikleri', score: 10),
          Option(text: 'Sadece siyasi sorunlar', score: 0),
          Option(text: 'Sadece ekonomik faktörler', score: 0),
        ],
        category: 'Su',
      ),
      Question(
        text: 'Su eğitiminde (water education) hangi konular ele alınmalıdır?',
        options: [
          Option(text: 'Sadece teknik bilgi', score: 0),
          Option(text: 'Tasarruf, kalite, haklar ve sürdürülebilirlik', score: 10),
          Option(text: 'Sadece ekonomi', score: 0),
          Option(text: 'Sadece politika', score: 0),
        ],
        category: 'Su',
      ),
      Question(
        text: 'Su kaynaklarında indigenous rights (yerli hakları) nasıl korunur?',
        options: [
          Option(text: 'Sadece yasal tanıma', score: 0),
          Option(text: 'Geleneksel bilgi, kutsal alan koruması ve katılım hakkı', score: 10),
          Option(text: 'Sadece ekonomik tazminat', score: 0),
          Option(text: 'Sadece teknik destek', score: 0),
        ],
        category: 'Su',
      ),
      Question(
        text: 'Su krizi sırasında social cohesion (toplumsal birlik) nasıl korunur?',
        options: [
          Option(text: 'Sadece devlet müdahalesi', score: 0),
          Option(text: 'İletişim, koordinasyon ve dayanışma mekanizmaları', score: 10),
          Option(text: 'Sadece medya kampanyaları', score: 0),
          Option(text: 'Sadece teknik çözümler', score: 0),
        ],
        category: 'Su',
      ),
      Question(
        text: 'Su kaynakları planlamasında community participation (topluluk katılımı) nasıl sağlanır?',
        options: [
          Option(text: 'Sadece resmi toplantılar', score: 0),
          Option(text: 'Danışma süreçleri, ortak karar verme ve kapasite geliştirme', score: 10),
          Option(text: 'Sadece anket çalışmaları', score: 0),
          Option(text: 'Sadece medya duyuruları', score: 0),
        ],
        category: 'Su',
      ),
      Question(
        text: 'Su hizmetlerinde gender equality (cinsiyet eşitliği) nasıl sağlanır?',
        options: [
          Option(text: 'Sadece eşit fiyat', score: 0),
          Option(text: 'Erişim eşitliği, karar verme süreçlerinde katılım ve kapasite geliştirme', score: 10),
          Option(text: 'Sadece teknik eğitim', score: 0),
          Option(text: 'Sadece ekonomik destek', score: 0),
        ],
        category: 'Su',
      ),
      Question(
        text: 'Su kaynaklarında social impact assessment (sosyal etki değerlendirmesi) nelere bakar?',
        options: [
          Option(text: 'Sadece ekonomik etkiler', score: 0),
          Option(text: 'Yaşam kalitesi, sağlık, kültür ve toplumsal yapı', score: 10),
          Option(text: 'Sadece teknik etkiler', score: 0),
          Option(text: 'Sadece çevresel etkiler', score: 0),
        ],
        category: 'Su',
      ),
      Question(
        text: 'Su eşitsizliğinin temel nedenleri nelerdir?',
        options: [
          Option(text: 'Sadece coğrafi faktörler', score: 0),
          Option(text: 'Gelir eşitsizliği, kurumsal yetersizlikler ve politik öncelikler', score: 10),
          Option(text: 'Sadece teknik eksiklikler', score: 0),
          Option(text: 'Sadece doğal faktörler', score: 0),
        ],
        category: 'Su',
      ),
      Question(
        text: 'Su kaynakları yönetiminde traditional knowledge (geleneksel bilgi) nasıl kullanılır?',
        options: [
          Option(text: 'Sadece dekoratif amaç', score: 0),
          Option(text: 'Su yönetimi, tahmin ve sürdürülebilir pratikler', score: 10),
          Option(text: 'Sadece eğitim amaçlı', score: 0),
          Option(text: 'Sadece kültürel değer', score: 0),
        ],
        category: 'Su',
      ),
      Question(
        text: 'Su krizleri sırasında vulnerability assessment (kırılganlık değerlendirmesi) nasıl yapılır?',
        options: [
          Option(text: 'Sadece teknik değerlendirme', score: 0),
          Option(text: 'Sosyoekonomik durum, altyapı durumu ve risk faktörleri', score: 10),
          Option(text: 'Sadece maliyet hesabı', score: 0),
          Option(text: 'Sadece teknik kapasite', score: 0),
        ],
        category: 'Su',
      ),
      Question(
        text: 'Su hizmetlerinde customer satisfaction (müşteri memnuniyeti) nasıl ölçülür?',
        options: [
          Option(text: 'Sadece fatura miktarı', score: 0),
          Option(text: 'Hizmet kalitesi, erişilebilirlik, güvenilirlik ve destek', score: 10),
          Option(text: 'Sadece şikayet sayısı', score: 0),
          Option(text: 'Sadece teknik performans', score: 0),
        ],
        category: 'Su',
      ),
      Question(
        text: 'Su kaynaklarında cultural heritage (kültürel miras) nasıl korunur?',
        options: [
          Option(text: 'Sadece yasal koruma', score: 0),
          Option(text: 'Kutsal alanlar, geleneksel uygulamalar ve toplumsal değerler', score: 10),
          Option(text: 'Sadece turizm geliri', score: 0),
          Option(text: 'Sadece tarihi belgeler', score: 0),
        ],
        category: 'Su',
      ),
      Question(
        text: 'Su eğitiminde behavioral change (davranış değişikliği) nasıl sağlanır?',
        options: [
          Option(text: 'Sadece bilgi verme', score: 0),
          Option(text: 'Farkındalık, teşvik sistemleri ve sosyal normlar', score: 10),
          Option(text: 'Sadece ceza sistemi', score: 0),
          Option(text: 'Sadece teknoloji sunumu', score: 0),
        ],
        category: 'Su',
      ),
      Question(
        text: 'Su kaynakları yönetiminde public awareness (halk farkındalığı) nasıl artırılır?',
        options: [
          Option(text: 'Sadece medya kampanyaları', score: 0),
          Option(text: 'Eğitim programları, toplum etkinlikleri ve dijital platformlar', score: 10),
          Option(text: 'Sadece resmi duyurular', score: 0),
          Option(text: 'Sadece okul müfredatı', score: 0),
        ],
        category: 'Su',
      ),
      Question(
        text: 'Su hizmetlerinde equity (eşitlik) hangi boyutları içerir?',
        options: [
          Option(text: 'Sadece coğrafi eşitlik', score: 0),
          Option(text: 'Erişim, kalite, maliyet ve hizmet çeşitliliği eşitliği', score: 10),
          Option(text: 'Sadece zaman eşitliği', score: 0),
          Option(text: 'Sadece miktar eşitliği', score: 0),
        ],
        category: 'Su',
      ),
      Question(
        text: 'Su kaynaklarında displacement (yer değiştirme) sorunları nasıl önlenir?',
        options: [
          Option(text: 'Sadece ekonomik tazminat', score: 0),
          Option(text: 'Katılımcı planlama, alternatif yaşam alanları ve sosyal destek', score: 10),
          Option(text: 'Sadece teknik çözümler', score: 0),
          Option(text: 'Sadece yasal düzenlemeler', score: 0),
        ],
        category: 'Su',
      ),
      Question(
        text: 'Su eğitiminde capacity building (kapasite geliştirme) hangi alanları kapsar?',
        options: [
          Option(text: 'Sadece teknik eğitim', score: 0),
          Option(text: 'Su yönetimi, liderlik, katılım ve sürdürülebilirlik bilinci', score: 10),
          Option(text: 'Sadece finansal eğitim', score: 0),
          Option(text: 'Sadece operasyonel eğitim', score: 0),
        ],
        category: 'Su',
      ),
      Question(
        text: 'Su kaynakları planlamasında social sustainability (sosyal sürdürülebilirlik) nelere odaklanır?',
        options: [
          Option(text: 'Sadece teknik altyapı', score: 0),
          Option(text: 'Toplumsal refah, kapsayıcılık ve gelecek nesiller için eşitlik', score: 10),
          Option(text: 'Sadece ekonomik büyüme', score: 0),
          Option(text: 'Sadece teknolojik gelişim', score: 0),
        ],
        category: 'Su',
      ),
      Question(
        text: 'Su hizmetlerinde service quality (hizmet kalitesi) göstergeleri nelerdir?',
        options: [
          Option(text: 'Sadece teknik parametreler', score: 0),
          Option(text: 'Güvenilirlik, erişilebilirlik, güvenlik ve müşteri memnuniyeti', score: 10),
          Option(text: 'Sadece maliyet', score: 0),
          Option(text: 'Sadece kapasite', score: 0),
        ],
        category: 'Su',
      ),
      Question(
        text: 'Su kaynakları yönetiminde trust building (güven inşası) nasıl yapılır?',
        options: [
          Option(text: 'Sadece şeffaflık', score: 0),
          Option(text: 'Şeffaflık, hesap verebilirlik ve tutarlı performans', score: 10),
          Option(text: 'Sadece iletişim', score: 0),
          Option(text: 'Sadece yasal düzenlemeler', score: 0),
        ],
        category: 'Su',
      ),
      Question(
        text: 'Su krizleri sırasında emergency response (acil durum müdahalesi) nasıl koordine edilir?',
        options: [
          Option(text: 'Sadece devlet liderliği', score: 0),
          Option(text: 'Çok paydaşlı koordinasyon, iletişim ve kaynak seferberliği', score: 10),
          Option(text: 'Sadece teknik ekipler', score: 0),
          Option(text: 'Sadece gönüllü gruplar', score: 0),
        ],
        category: 'Su',
      ),
    ];
  }

  /// Su Ekonomisi sorularını getirir (25 soru)
  static List<Question> getTurkishWaterEconomics() {
    return [
      Question(
        text: 'Su ekonomisinde water value chain (su değer zinciri) hangi aşamaları içerir?',
        options: [
          Option(text: 'Sadece dağıtım', score: 0),
          Option(text: 'Kaynak yönetimi, arıtma, dağıtım ve hizmet sunumu', score: 10),
          Option(text: 'Sadece tüketim', score: 0),
          Option(text: 'Sadece geri dönüşüm', score: 0),
        ],
        category: 'Su',
      ),
      Question(
        text: 'Su fiyatlandırmasında cost recovery (maliyet geri kazanımı) prensibi nedir?',
        options: [
          Option(text: 'Sadece operasyonel maliyet', score: 0),
          Option(text: 'Yatırım, operasyon ve bakım maliyetlerinin tam karşılanması', score: 10),
          Option(text: 'Sadece personel maliyeti', score: 0),
          Option(text: 'Sadece enerji maliyeti', score: 0),
        ],
        category: 'Su',
      ),
      Question(
        text: 'Su ekonomisinde economic efficiency (ekonomik verimlilik) nasıl ölçülür?',
        options: [
          Option(text: 'Sadece maliyet', score: 0),
          Option(text: 'Çıktı başına maliyet, kaynak kullanım etkinliği ve fayda-maliyet oranı', score: 10),
          Option(text: 'Sadece kapasite kullanımı', score: 0),
          Option(text: 'Sadece gelir', score: 0),
        ],
        category: 'Su',
      ),
      Question(
        text: 'Su yatırımlarında project appraisal (proje değerlendirmesi) hangi yöntemlerle yapılır?',
        options: [
          Option(text: 'Sadece maliyet hesabı', score: 0),
          Option(text: 'Fayda-maliyet analizi, net bugünkü değer ve iç getiri oranı', score: 10),
          Option(text: 'Sadece teknik fizibilite', score: 0),
          Option(text: 'Sadece çevresel etki', score: 0),
        ],
        category: 'Su',
      ),
      Question(
        text: 'Su hizmetlerinde subsidies (teşvikler) hangi amaçlarla verilir?',
        options: [
          Option(text: 'Sadece maliyet azaltımı', score: 0),
          Option(text: 'Erişilebilirlik sağlama, sosyal adalet ve hizmet genişletme', score: 10),
          Option(text: 'Sadece teknoloji teşviki', score: 0),
          Option(text: 'Sadece rekabet artırımı', score: 0),
        ],
        category: 'Su',
      ),
      Question(
        text: 'Su ekonomisinde economies of scale (ölçek ekonomisi) hangi avantajları sağlar?',
        options: [
          Option(text: 'Sadece kapasite artışı', score: 0),
          Option(text: 'Birim maliyet düşüşü, verimlilik artışı ve hizmet kalitesi', score: 10),
          Option(text: 'Sadece teknoloji gelişimi', score: 0),
          Option(text: 'Sadece pazar payı', score: 0),
        ],
        category: 'Su',
      ),
      Question(
        text: 'Su fiyatlandırmasında lifeline rate (asgari ücret tarifesi) nedir?',
        options: [
          Option(text: 'Sadece düşük fiyat', score: 0),
          Option(text: 'Temel ihtiyaçlar için düşük maliyetli su tarifesi', score: 10),
          Option(text: 'Sadece sosyal tarifeler', score: 0),
          Option(text: 'Sadece kırsal tarifeler', score: 0),
        ],
        category: 'Su',
      ),
      Question(
        text: 'Su yatırımlarında financial sustainability (finansal sürdürülebilirlik) nasıl sağlanır?',
        options: [
          Option(text: 'Sadece devlet desteği', score: 0),
          Option(text: 'Uygun fiyatlandırma, verimli operasyon ve gelir çeşitliliği', score: 10),
          Option(text: 'Sadece borçlanma', score: 0),
          Option(text: 'Sadece hibe', score: 0),
        ],
        category: 'Su',
      ),
      Question(
        text: 'Su ekonomisinde water trading (su ticareti) nedir?',
        options: [
          Option(text: 'Sadece su satışı', score: 0),
          Option(text: 'Su haklarının alım-satımı ve esnek kullanım', score: 10),
          Option(text: 'Sadece teknik hizmet', score: 0),
          Option(text: 'Sadece danışmanlık', score: 0),
        ],
        category: 'Su',
      ),
      Question(
        text: 'Su hizmetlerinde operational efficiency (operasyonel verimlilik) nasıl artırılır?',
        options: [
          Option(text: 'Sadece teknoloji yatırımı', score: 0),
          Option(text: 'Proses optimizasyonu, kayıp azaltımı ve enerji verimliliği', score: 10),
          Option(text: 'Sadece personel artışı', score: 0),
          Option(text: 'Sadece ekipman değişimi', score: 0),
        ],
        category: 'Su',
      ),
      Question(
        text: 'Su fiyatlandırmasında peak pricing (tepe fiyatlandırma) nasıl çalışır?',
        options: [
          Option(text: 'Sabit fiyat', score: 0),
          Option(text: 'Yüksek talep dönemlerinde daha yüksek fiyat', score: 10),
          Option(text: 'Sezonluk fiyat', score: 0),
          Option(text: 'Kaliteye göre fiyat', score: 0),
        ],
        category: 'Su',
      ),
      Question(
        text: 'Su yatırımlarında risk management (risk yönetimi) hangi riskleri kapsar?',
        options: [
          Option(text: 'Sadece teknik riskler', score: 0),
          Option(text: 'Mali, çevresel, sosyal ve politik riskler', score: 10),
          Option(text: 'Sadece finansal riskler', score: 0),
          Option(text: 'Sadece operasyonel riskler', score: 0),
        ],
        category: 'Su',
      ),
      Question(
        text: 'Su ekonomisinde cost allocation (maliyet dağılımı) nasıl yapılır?',
        options: [
          Option(text: 'Eşit dağıtım', score: 0),
          Option(text: 'Kullanım miktarı, hizmet seviyesi ve maliyet sürücülerine göre', score: 10),
          Option(text: 'Siyasi karar', score: 0),
          Option(text: 'Teknik hesaplama', score: 0),
        ],
        category: 'Su',
      ),
      Question(
        text: 'Su hizmetlerinde revenue collection (gelir toplama) nasıl optimize edilir?',
        options: [
          Option(text: 'Sadece manuel tahsilat', score: 0),
          Option(text: 'Otomatik ödeme, hedefleme ve etkin takip sistemleri', score: 10),
          Option(text: 'Sadece fiyat artışı', score: 0),
          Option(text: 'Sadece yasal zorlama', score: 0),
        ],
        category: 'Su',
      ),
      Question(
        text: 'Su fiyatlandırmasında marginal cost (marjinal maliyet) nedir?',
        options: [
          Option(text: 'Ortalama maliyet', score: 0),
          Option(text: 'Ek bir birim su için katlanılan maliyet', score: 10),
          Option(text: 'Toplam maliyet', score: 0),
          Option(text: 'Sabit maliyet', score: 0),
        ],
        category: 'Su',
      ),
      Question(
        text: 'Su yatırımlarında payback period (geri ödeme süresi) nasıl hesaplanır?',
        options: [
          Option(text: 'Proje süresi', score: 0),
          Option(text: 'Yatırım maliyeti / yıllık net nakit akışı', score: 10),
          Option(text: 'Teknik ömür', score: 0),
          Option(text: 'Garanti süresi', score: 0),
        ],
        category: 'Su',
      ),
      Question(
        text: 'Su ekonomisinde externalities (dışsallıklar) nelerdir?',
        options: [
          Option(text: 'Sadece doğrudan maliyetler', score: 0),
          Option(text: 'Çevresel ve sosyal etkilerin ekonomik değeri', score: 10),
          Option(text: 'Sadece teknik maliyetler', score: 0),
          Option(text: 'Sadece operasyonel maliyetler', score: 0),
        ],
        category: 'Su',
      ),
      Question(
        text: 'Su hizmetlerinde cross-subsidization (çapraz sübvansiyon) nasıl çalışır?',
        options: [
          Option(text: 'Sadece maliyet azaltımı', score: 0),
          Option(text: 'Karlı segmentlerin zararlı segmentleri desteklemesi', score: 10),
          Option(text: 'Sadece fiyat eşitleme', score: 0),
          Option(text: 'Sadece vergi desteği', score: 0),
        ],
        category: 'Su',
      ),
      Question(
        text: 'Su fiyatlandırmasında willingness to pay (ödeme istekliliği) nasıl ölçülür?',
        options: [
          Option(text: 'Sadece anket', score: 0),
          Option(text: 'Pazar araştırması, konjoint analizi ve deneysel yöntemler', score: 10),
          Option(text: 'Sadece gözlem', score: 0),
          Option(text: 'Sadece uzman görüşü', score: 0),
        ],
        category: 'Su',
      ),
      Question(
        text: 'Su yatırımlarında financial instruments (finansal araçlar) nelerdir?',
        options: [
          Option(text: 'Sadece kredi', score: 0),
          Option(text: 'Kredi, tahvil, leasing ve hibrit finansman araçları', score: 10),
          Option(text: 'Sadece özkaynak', score: 0),
          Option(text: 'Sadece hibe', score: 0),
        ],
        category: 'Su',
      ),
      Question(
        text: 'Su ekonomisinde water valuation (su değerlemesi) hangi yöntemlerle yapılır?',
        options: [
          Option(text: 'Sadece üretim maliyeti', score: 0),
          Option(text: 'Pazar değeri, ikame maliyeti ve hedonik fiyatlandırma', score: 10),
          Option(text: 'Sadece maliyet artı kar', score: 0),
          Option(text: 'Sadece rekabet fiyatı', score: 0),
        ],
        category: 'Su',
      ),
      Question(
        text: 'Su hizmetlerinde tariff structure (tarife yapısı) nasıl tasarlanır?',
        options: [
          Option(text: 'Sadece tek tarifeler', score: 0),
          Option(text: 'Sabit, değişken, artımlı ve sezonluk bileşenler', score: 10),
          Option(text: 'Sadece tüketim bazlı', score: 0),
          Option(text: 'Sadece kapasite bazlı', score: 0),
        ],
        category: 'Su',
      ),
      Question(
        text: 'Su yatırımlarında benchmarking (kıyaslama) nasıl yapılır?',
        options: [
          Option(text: 'Sadece sektör ortalaması', score: 0),
          Option(text: 'En iyi uygulamalar, performans göstergeleri ve verimlilik analizi', score: 10),
          Option(text: 'Sadece teknik standart', score: 0),
          Option(text: 'Sadece yasal gereklilik', score: 0),
        ],
        category: 'Su',
      ),
      Question(
        text: 'Su ekonomisinde water productivity (su verimliliği) nasıl artırılır?',
        options: [
          Option(text: 'Sadece teknoloji değişimi', score: 0),
          Option(text: 'Verimli teknolojiler, süreç optimizasyonu ve yönetim iyileştirmeleri', score: 10),
          Option(text: 'Sadece eğitim', score: 0),
          Option(text: 'Sadece regülasyon', score: 0),
        ],
        category: 'Su',
      ),
    ];
  }

  /// Tüm su sorularını getirir (350 soru)
  static List<Question> getAllTurkishWaterQuestions() {
    List<Question> allQuestions = [];
    
    allQuestions.addAll(getTurkishWaterFundamentals());
    allQuestions.addAll(getTurkishWaterQuality());
    allQuestions.addAll(getTurkishWaterTechnology());
    allQuestions.addAll(getTurkishWaterPolicy());
    allQuestions.addAll(getTurkishWaterTechnologyAdvanced());
    allQuestions.addAll(getTurkishWaterEnvironment());
    allQuestions.addAll(getTurkishWaterSociety());
    allQuestions.addAll(getTurkishWaterEconomics());
    
    return allQuestions;
  }

  /// Belirli sayıda rastgele su sorusu getirir
  static List<Question> getRandomWaterQuestions(int count) {
    List<Question> allQuestions = getAllTurkishWaterQuestions();
    allQuestions.shuffle();
    return allQuestions.take(count).toList();
  }

  /// Belirli kategorideki su sorularını getirir
  static List<Question> getWaterQuestionsByCategory(String category) {
    List<Question> allQuestions = getAllTurkishWaterQuestions();
    return allQuestions.where((question) => question.category == category).toList();
  }
}