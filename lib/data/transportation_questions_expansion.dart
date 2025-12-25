// lib/data/transportation_questions_expansion.dart
// Ulaşım Teması için 200 Ek Soru

import '../models/question.dart';

class TransportationQuestionsExpansion {
  static List<Question> getTurkishTransportationQuestions() {
    return [
      // Elektrikli Araçlar (25 soru)
      Question(
        text: 'Elektrikli araçların (EV) şarj süresini etkileyen en önemli faktör hangisidir?',
        options: [
          Option(text: 'Araç rengi', score: 0),
          Option(text: 'Batarya kapasitesi ve şarj gücü', score: 10),
          Option(text: 'Araç boyutu', score: 0),
          Option(text: 'Lastik basıncı', score: 0),
        ],
        category: 'Ulaşım',
      ),
      Question(
        text: 'Elektrikli araçlarda kullanılan Li-ion bataryaların avantajı nedir?',
        options: [
          Option(text: 'Çok düşük enerji yoğunluğu', score: 0),
          Option(text: 'Yüksek enerji yoğunluğu ve uzun ömür', score: 10),
          Option(text: 'Çok hızlı şarj süresi', score: 0),
          Option(text: 'Düşük maliyet', score: 0),
        ],
        category: 'Ulaşım',
      ),
      Question(
        text: 'Elektrikli araç şarj istasyonlarında Level 2 şarj nedir?',
        options: [
          Option(text: 'Sokak prizinden şarj', score: 0),
          Option(text: 'Evde kullanılan 240V AC şarj', score: 10),
          Option(text: 'DC hızlı şarj', score: 0),
          Option(text: 'Solar panel ile şarj', score: 0),
        ],
        category: 'Ulaşım',
      ),
      Question(
        text: 'Elektrikli araçların menzil kaygısını azaltmanın en etkili yolu nedir?',
        options: [
          Option(text: 'Daha büyük batarya kullanmak', score: 10),
          Option(text: 'Daha küçük motor kullanmak', score: 0),
          Option(text: 'Daha ağır araç yapmak', score: 0),
          Option(text: 'Daha yüksek hızda gitmek', score: 0),
        ],
        category: 'Ulaşım',
      ),
      Question(
        text: 'Elektrikli araçlarda regenerative braking (rejeneratif frenleme) nasıl çalışır?',
        options: [
          Option(text: 'Sadece mekanik fren sistemi', score: 0),
          Option(text: 'Frenleme enerjisini elektrik enerjisine dönüştürür', score: 10),
          Option(text: 'Sadece ısı enerjisi üretir', score: 0),
          Option(text: 'Sadece gürültü azaltır', score: 0),
        ],
        category: 'Ulaşım',
      ),
      Question(
        text: 'Elektrikli araç şarj istasyonlarında CHAdeMO standardının avantajı nedir?',
        options: [
          Option(text: 'Sadece AC şarj', score: 0),
          Option(text: 'Hızlı DC şarj ve çift yönlü enerji akışı', score: 10),
          Option(text: 'Sadece yavaş şarj', score: 0),
          Option(text: 'Sadece Tesla uyumluluğu', score: 0),
        ],
        category: 'Ulaşım',
      ),
      Question(
        text: 'Elektrikli araçlarda battery management system (BMS) ne işe yarar?',
        options: [
          Option(text: 'Sadece şarj durumunu gösterir', score: 0),
          Option(text: 'Batarya güvenliği, performansı ve ömrünü optimize eder', score: 10),
          Option(text: 'Sadece sıcaklık kontrolü yapar', score: 0),
          Option(text: 'Sadece voltaj ölçer', score: 0),
        ],
        category: 'Ulaşım',
      ),
      Question(
        text: 'Elektrikli araçlarda kullanılan DC hızlı şarj (DC fast charging) ne kadar sürede şarj eder?',
        options: [
          Option(text: '8-12 saat', score: 0),
          Option(text: '30-60 dakika', score: 10),
          Option(text: '2-3 saat', score: 0),
          Option(text: '1-2 dakika', score: 0),
        ],
        category: 'Ulaşım',
      ),
      Question(
        text: 'Elektrikli araçlarda motor türü olarak hangisi en yaygın kullanılır?',
        options: [
          Option(text: 'DC motor', score: 0),
          Option(text: 'AC asenkron motor veya PMSM', score: 10),
          Option(text: 'Step motor', score: 0),
          Option(text: 'Servo motor', score: 0),
        ],
        category: 'Ulaşım',
      ),
      Question(
        text: 'Elektrikli araç bataryalarının geri dönüşümünde en değerli malzeme hangisidir?',
        options: [
          Option(text: 'Çelik', score: 0),
          Option(text: 'Lityum, kobalt ve nikel', score: 10),
          Option(text: 'Alüminyum', score: 0),
          Option(text: 'Bakır', score: 0),
        ],
        category: 'Ulaşım',
      ),
      Question(
        text: 'Elektrikli araç şarj altyapısında smart charging (akıllı şarj) ne anlama gelir?',
        options: [
          Option(text: 'Sadece hızlı şarj', score: 0),
          Option(text: 'Şebeke yüküne göre şarj hızını optimize etme', score: 10),
          Option(text: 'Sadece uzaktan kontrol', score: 0),
          Option(text: 'Sadece kablosuz şarj', score: 0),
        ],
        category: 'Ulaşım',
      ),
      Question(
        text: 'Elektrikli araçlarda range anxiety (menzil kaygısı) nedir?',
        options: [
          Option(text: 'Bataryanın çok hızlı boşalması', score: 0),
          Option(text: 'Şarj istasyonu bulamama endişesi', score: 10),
          Option(text: 'Motor arızası endişesi', score: 0),
          Option(text: 'Yüksek maliyet endişesi', score: 0),
        ],
        category: 'Ulaşım',
      ),
      Question(
        text: 'Elektrikli araçlarda vehicle-to-grid (V2G) teknolojisi ne işe yarar?',
        options: [
          Option(text: 'Sadece araç şarj etme', score: 0),
          Option(text: 'Araçtan şebekeye enerji geri verme', score: 10),
          Option(text: 'Sadece enerji depolama', score: 0),
          Option(text: 'Sadece motor kontrolü', score: 0),
        ],
        category: 'Ulaşım',
      ),
      Question(
        text: 'Elektrikli araç bataryalarında depth of discharge (DOD) nedir?',
        options: [
          Option(text: 'Şarj süresi', score: 0),
          Option(text: 'Kullanılan enerji yüzdesi', score: 10),
          Option(text: 'Batarya ağırlığı', score: 0),
          Option(text: 'Voltaj seviyesi', score: 0),
        ],
        category: 'Ulaşım',
      ),
      Question(
        text: 'Elektrikli araç şarj istasyonlarında CCS (Combined Charging System) standardının avantajı nedir?',
        options: [
          Option(text: 'Sadece AC şarj', score: 0),
          Option(text: 'Hem AC hem DC şarj tek konektörle', score: 10),
          Option(text: 'Sadece Tesla uyumluluğu', score: 0),
          Option(text: 'Sadece yavaş şarj', score: 0),
        ],
        category: 'Ulaşım',
      ),
      Question(
        text: 'Elektrikli araçlarda thermal management (ısı yönetimi) neden önemlidir?',
        options: [
          Option(text: 'Sadece konfor için', score: 0),
          Option(text: 'Batarya performansı ve güvenliği için', score: 10),
          Option(text: 'Sadece maliyet azaltımı için', score: 0),
          Option(text: 'Sadece menzil artırımı için', score: 0),
        ],
        category: 'Ulaşım',
      ),
      Question(
        text: 'Elektrikli araçlarda on-board charger (gömülü şarj cihazı) hangi güçte olur?',
        options: [
          Option(text: '50-150 kW', score: 0),
          Option(text: '3-11 kW', score: 10),
          Option(text: '200-350 kW', score: 0),
          Option(text: '1-2 kW', score: 0),
        ],
        category: 'Ulaşım',
      ),
      Question(
        text: 'Elektrikli araçlarda kullanılan solid-state battery teknolojisinin avantajı nedir?',
        options: [
          Option(text: 'Daha düşük enerji yoğunluğu', score: 0),
          Option(text: 'Daha yüksek güvenlik ve enerji yoğunluğu', score: 10),
          Option(text: 'Daha düşük maliyet', score: 0),
          Option(text: 'Daha uzun şarj süresi', score: 0),
        ],
        category: 'Ulaşım',
      ),
      Question(
        text: 'Elektrikli araç şarj altyapısında pay-per-use (kullanım başına ödeme) modelinin avantajı nedir?',
        options: [
          Option(text: 'Sadece gelir artışı', score: 0),
          Option(text: 'Düşük başlangıç maliyeti ve esnek ödeme', score: 10),
          Option(text: 'Sadece basit kullanım', score: 0),
          Option(text: 'Sadece hızlı kurulum', score: 0),
        ],
        category: 'Ulaşım',
      ),
      Question(
        text: 'Elektrikli araçlarda energy consumption (enerji tüketimi) genellikle kaç kWh/100km\'dir?',
        options: [
          Option(text: '50-80 kWh/100km', score: 0),
          Option(text: '12-25 kWh/100km', score: 10),
          Option(text: '5-10 kWh/100km', score: 0),
          Option(text: '100-150 kWh/100km', score: 0),
        ],
        category: 'Ulaşım',
      ),
      Question(
        text: 'Elektrikli araç bataryalarında cycle life (döngü ömrü) nedir?',
        options: [
          Option(text: 'Garanti süresi', score: 0),
          Option(text: 'Bataryanın tam şarj-deşarj döngüsü sayısı', score: 10),
          Option(text: 'Üretim süresi', score: 0),
          Option(text: 'Depolama süresi', score: 0),
        ],
        category: 'Ulaşım',
      ),
      Question(
        text: 'Elektrikli araçlarda kullanılan wireless charging (kablosuz şarj) teknolojisi nasıl çalışır?',
        options: [
          Option(text: 'Sadece manyetik alan', score: 0),
          Option(text: 'Elektromanyetik indüksiyon ile enerji transferi', score: 10),
          Option(text: 'Sadece RF dalgaları', score: 0),
          Option(text: 'Sadece infrared ışınlar', score: 0),
        ],
        category: 'Ulaşım',
      ),
      Question(
        text: 'Elektrikli araç şarj altyapısında ultra-fast charging (ultra hızlı şarj) nedir?',
        options: [
          Option(text: '50 kW üzeri DC şarj', score: 10),
          Option(text: 'AC şarj', score: 0),
          Option(text: 'Kablosuz şarj', score: 0),
          Option(text: 'Solar şarj', score: 0),
        ],
        category: 'Ulaşım',
      ),
      Question(
        text: 'Elektrikli araçlarda state of charge (SOC) nedir?',
        options: [
          Option(text: 'Şarj hızı', score: 0),
          Option(text: 'Batarya şarj seviyesi yüzdesi', score: 10),
          Option(text: 'Sıcaklık seviyesi', score: 0),
          Option(text: 'Voltaj seviyesi', score: 0),
        ],
        category: 'Ulaşım',
      ),
      Question(
        text: 'Elektrikli araçlarda peak shaving (tepe güç azaltma) stratejisi nedir?',
        options: [
          Option(text: 'Sadece şarj hızını artırma', score: 0),
          Option(text: 'Şebekedeki yoğun saatlerde şarjı azaltma', score: 10),
          Option(text: 'Sadece enerji tasarrufu', score: 0),
          Option(text: 'Sadece maliyet azaltımı', score: 0),
        ],
        category: 'Ulaşım',
      ),

      // Toplu Taşıma (25 soru)
      Question(
        text: 'Sürdürülebilir toplu taşıma sistemlerinin en önemli avantajı nedir?',
        options: [
          Option(text: 'Daha yüksek hız', score: 0),
          Option(text: 'Kişi başına düşük emisyon ve maliyet', score: 10),
          Option(text: 'Daha fazla konfor', score: 0),
          Option(text: 'Daha geniş ulaşım ağı', score: 0),
        ],
        category: 'Ulaşım',
      ),
      Question(
        text: 'Metro sistemlerinin şehir ulaşımındaki rolü nedir?',
        options: [
          Option(text: 'Sadece turizm taşımacılığı', score: 0),
          Option(text: 'Yüksek kapasiteli, hızlı ve güvenilir ulaşım', score: 10),
          Option(text: 'Sadece gece ulaşımı', score: 0),
          Option(text: 'Sadece banliyö bağlantısı', score: 0),
        ],
        category: 'Ulaşım',
      ),
      Question(
        text: 'Bus Rapid Transit (BRT) sisteminin avantajı nedir?',
        options: [
          Option(text: 'Metro kadar yüksek maliyet', score: 0),
          Option(text: 'Metro benzeri performans, daha düşük maliyet', score: 10),
          Option(text: 'Sadece çevre dostu yakıt', score: 0),
          Option(text: 'Sadece hızlı inşa', score: 0),
        ],
        category: 'Ulaşım',
      ),
      Question(
        text: 'Elektrikli otobüslerin çevresel faydaları nelerdir?',
        options: [
          Option(text: 'Sadece gürültü kirliliği azaltımı', score: 0),
          Option(text: 'Sıfır emisyon ve hava kalitesi iyileştirmesi', score: 10),
          Option(text: 'Sadece enerji tasarrufu', score: 0),
          Option(text: 'Sadece maliyet azaltımı', score: 0),
        ],
        category: 'Ulaşım',
      ),
      Question(
        text: 'Toplu taşıma sistemlerinde real-time information (gerçek zamanlı bilgi) sistemi ne sağlar?',
        options: [
          Option(text: 'Sadece reklam', score: 0),
          Option(text: 'Varış süreleri, gecikmeler ve kapasite bilgisi', score: 10),
          Option(text: 'Sadece hava durumu', score: 0),
          Option(text: 'Sadece trafik bilgisi', score: 0),
        ],
        category: 'Ulaşım',
      ),
      Question(
        text: 'Tramvay sistemlerinin şehir içi ulaşımındaki yeri nedir?',
        options: [
          Option(text: 'Sadece turistik amaç', score: 0),
          Option(text: 'Orta kapasiteli, çevre dostu ve konforlu ulaşım', score: 10),
          Option(text: 'Sadece gece ulaşımı', score: 0),
          Option(text: 'Sadece kargo taşımacılığı', score: 0),
        ],
        category: 'Ulaşım',
      ),
      Question(
        text: 'Toplu taşıma kullanımını artırmanın en etkili yolu nedir?',
        options: [
          Option(text: 'Sadece fiyat indirimi', score: 0),
          Option(text: 'Konfor, güvenilirlik ve entegrasyon iyileştirmesi', score: 10),
          Option(text: 'Sadece yeni hat açma', score: 0),
          Option(text: 'Sadece reklam kampanyası', score: 0),
        ],
        category: 'Ulaşım',
      ),
      Question(
        text: 'Ferry sistemlerinin toplu taşımadaki rolü nedir?',
        options: [
          Option(text: 'Sadece turizm', score: 0),
          Option(text: 'Su geçişleri için alternatif ve hızlı ulaşım', score: 10),
          Option(text: 'Sadece kargo taşımacılığı', score: 0),
          Option(text: 'Sadece acil durum ulaşımı', score: 0),
        ],
        category: 'Ulaşım',
      ),
      Question(
        text: 'Akıllı biletleme sistemlerinin avantajı nedir?',
        options: [
          Option(text: 'Sadece maliyet artırma', score: 0),
          Option(text: 'Daha hızlı geçiş ve veri toplama imkanı', score: 10),
          Option(text: 'Sadece güvenlik artırma', score: 0),
          Option(text: 'Sadece reklam gösterimi', score: 0),
        ],
        category: 'Ulaşım',
      ),
      Question(
        text: 'Light rail (hafif raylı) sistemlerinin özelliği nedir?',
        options: [
          Option(text: 'Metro kadar yüksek kapasite', score: 0),
          Option(text: 'Otobüs ve tramvay arası kapasite ve hız', score: 10),
          Option(text: 'Sadece banliyö ulaşımı', score: 0),
          Option(text: 'Sadece gece ulaşımı', score: 0),
        ],
        category: 'Ulaşım',
      ),
      Question(
        text: 'Toplu taşıma sistemlerinde integration (entegrasyon) neden önemlidir?',
        options: [
          Option(text: 'Sadece maliyet tasarrufu', score: 0),
          Option(text: 'Farklı taşıma türleri arasında sorunsuz geçiş', score: 10),
          Option(text: 'Sadece yolcu artışı', score: 0),
          Option(text: 'Sadece teknoloji geliştirme', score: 0),
        ],
        category: 'Ulaşım',
      ),
      Question(
        text: 'Bus lane (otobüs şeridi) kullanımının faydası nedir?',
        options: [
          Option(text: 'Sadece otobüs trafiğini engellemek', score: 0),
          Option(text: 'Otobüslerin hızını ve güvenilirliğini artırmak', score: 10),
          Option(text: 'Sadece özel araç trafiğini azaltmak', score: 0),
          Option(text: 'Sadece çevre koruması', score: 0),
        ],
        category: 'Ulaşım',
      ),
      Question(
        text: 'Toplu taşıma araçlarında wheelchair accessibility (tekerlekli sandalye erişimi) neden önemlidir?',
        options: [
          Option(text: 'Sadece yasal zorunluluk', score: 0),
          Option(text: 'Engelli bireylerin ulaşım hakkı ve eşitlik', score: 10),
          Option(text: 'Sadece prestij', score: 0),
          Option(text: 'Sadece güvenlik', score: 0),
        ],
        category: 'Ulaşım',
      ),
      Question(
        text: 'Electric bus rapid transit (e-BRT) sistemlerinin avantajı nedir?',
        options: [
          Option(text: 'Sadece çevre dostu', score: 0),
          Option(text: 'Sıfır emisyon + BRT hız ve kapasitesi', score: 10),
          Option(text: 'Sadece düşük maliyet', score: 0),
          Option(text: 'Sadece hızlı kurulum', score: 0),
        ],
        category: 'Ulaşım',
      ),
      Question(
        text: 'Toplu taşıma sistemlerinde demand responsive transport (talep odaklı ulaşım) nedir?',
        options: [
          Option(text: 'Sabit hatlı sistem', score: 0),
          Option(text: 'Talebe göre rotaları değişen esnek sistem', score: 10),
          Option(text: 'Sadece gece hizmeti', score: 0),
          Option(text: 'Sadece hafta sonu hizmeti', score: 0),
        ],
        category: 'Ulaşım',
      ),
      Question(
        text: 'Funicular (füniküler) sistemlerinin kullanım alanı nedir?',
        options: [
          Option(text: 'Sadece turizm', score: 0),
          Option(text: 'Dik eğimli bölgelerde raylı ulaşım', score: 10),
          Option(text: 'Sadece kargo taşımacılığı', score: 0),
          Option(text: 'Sadece acil durum ulaşımı', score: 0),
        ],
        category: 'Ulaşım',
      ),
      Question(
        text: 'Toplu taşıma sistemlerinde capacity management (kapasite yönetimi) nasıl yapılır?',
        options: [
          Option(text: 'Sadece araç sayısını artırmak', score: 0),
          Option(text: 'Talep analizi ve hizmet optimizasyonu', score: 10),
          Option(text: 'Sadece fiyat ayarlama', score: 0),
          Option(text: 'Sadece güzergah değişikliği', score: 0),
        ],
        category: 'Ulaşım',
      ),
      Question(
        text: 'Cable car (teleferik) sistemlerinin toplu taşımadaki rolü nedir?',
        options: [
          Option(text: 'Sadece turistik amaç', score: 0),
          Option(text: 'Dağlık bölgelerde alternatif ve çevre dostu ulaşım', score: 10),
          Option(text: 'Sadece acil durum ulaşımı', score: 0),
          Option(text: 'Sadece kargo taşımacılığı', score: 0),
        ],
        category: 'Ulaşım',
      ),
      Question(
        text: 'Toplu taşıma araçlarında air conditioning (klima) sistemlerinin önemi nedir?',
        options: [
          Option(text: 'Sadece konfor', score: 0),
          Option(text: 'Yolcu konforu ve sistem verimliliği', score: 10),
          Option(text: 'Sadece enerji tasarrufu', score: 0),
          Option(text: 'Sadece teknoloji gösterisi', score: 0),
        ],
        category: 'Ulaşım',
      ),
      Question(
        text: 'Transit-oriented development (TOD) yaklaşımı nedir?',
        options: [
          Option(text: 'Sadece ulaşım altyapısı geliştirme', score: 0),
          Option(text: 'Toplu taşıma etrafında yoğun kentleşme', score: 10),
          Option(text: 'Sadece ticari alan geliştirme', score: 0),
          Option(text: 'Sadece konut geliştirme', score: 0),
        ],
        category: 'Ulaşım',
      ),
      Question(
        text: 'Toplu taşıma sistemlerinde safety and security (güvenlik) hangi önlemleri içerir?',
        options: [
          Option(text: 'Sadece kamera sistemi', score: 0),
          Option(text: 'Acil durum sistemi, güvenlik personeli ve tasarım', score: 10),
          Option(text: 'Sadece alarm sistemi', score: 0),
          Option(text: 'Sadece iletişim sistemi', score: 0),
        ],
        category: 'Ulaşım',
      ),
      Question(
        text: 'Para transit (parafiyatlı) sistemlerde integration nedir?',
        options: [
          Option(text: 'Sadece tek biletleme', score: 0),
          Option(text: 'Farklı taşıma türleri arasında geçiş hakkı', score: 10),
          Option(text: 'Sadece fiyat indirimi', score: 0),
          Option(text: 'Sadece zaman tablosu entegrasyonu', score: 0),
        ],
        category: 'Ulaşım',
      ),
      Question(
        text: 'Toplu taşıma sistemlerinde contactless payment (temassız ödeme) nasıl çalışır?',
        options: [
          Option(text: 'Sadece nakit para', score: 0),
          Option(text: 'Kart veya mobil cihazla hızlı ödeme', score: 10),
          Option(text: 'Sadece qr kod', score: 0),
          Option(text: 'Sadece nfc', score: 0),
        ],
        category: 'Ulaşım',
      ),
      Question(
        text: 'Feeder service (besleyici servis) nedir?',
        options: [
          Option(text: 'Ana hat ulaşımı', score: 0),
          Option(text: 'Ana ulaşım hatlarına yolcu taşıyan yardımcı hatlar', score: 10),
          Option(text: 'Sadece gece hizmeti', score: 0),
          Option(text: 'Sadece acil durum hizmeti', score: 0),
        ],
        category: 'Ulaşım',
      ),
      Question(
        text: 'Toplu taşıma sistemlerinde last mile connectivity (son kilometre bağlantısı) nasıl sağlanır?',
        options: [
          Option(text: 'Sadece yürüyüş', score: 0),
          Option(text: 'Bisiklet, scooter ve mikro-ulaşım çözümleri', score: 10),
          Option(text: 'Sadece taksi', score: 0),
          Option(text: 'Sadece özel araç', score: 0),
        ],
        category: 'Ulaşım',
      ),

      // Bisiklet ve Yürüyüş (25 soru)
      Question(
        text: 'Bisiklet yollarının şehir ulaşımındaki en önemli faydası nedir?',
        options: [
          Option(text: 'Sadece spor imkanı', score: 0),
          Option(text: 'Trafik yoğunluğunu azaltma ve çevre dostu ulaşım', score: 10),
          Option(text: 'Sadece turizm', score: 0),
          Option(text: 'Sadece eğlence', score: 0),
        ],
        category: 'Ulaşım',
      ),
      Question(
        text: 'Bisiklet kullanımının sağlık faydaları nelerdir?',
        options: [
          Option(text: 'Sadece kas geliştirme', score: 0),
          Option(text: 'Kardiyovasküler sağlık, kilo kontrolü ve mental iyilik', score: 10),
          Option(text: 'Sadece eklem sağlığı', score: 0),
          Option(text: 'Sadece dayanıklılık', score: 0),
        ],
        category: 'Ulaşım',
      ),
      Question(
        text: 'Bisiklet paylaşım sistemlerinin (bike sharing) avantajı nedir?',
        options: [
          Option(text: 'Sadece gelir sağlama', score: 0),
          Option(text: 'Erişilebilirlik ve esneklik artışı', score: 10),
          Option(text: 'Sadece teknoloji gösterisi', score: 0),
          Option(text: 'Sadece turizm tanıtımı', score: 0),
        ],
        category: 'Ulaşım',
      ),
      Question(
        text: 'Bisiklet altyapısında protected bike lane (korumalı bisiklet şeridi) ne anlama gelir?',
        options: [
          Option(text: 'Sadece boyalı şerit', score: 0),
          Option(text: 'Fiziksel bariyerlerle korunan bisiklet yolu', score: 10),
          Option(text: 'Sadece işaretli alan', score: 0),
          Option(text: 'Sadece hız sınırı', score: 0),
        ],
        category: 'Ulaşım',
      ),
      Question(
        text: 'Yürüyüş dostu şehir tasarımının temel prensipleri nelerdir?',
        options: [
          Option(text: 'Sadece geniş kaldırımlar', score: 0),
          Option(text: 'Güvenlik, erişilebilirlik ve çekicilik', score: 10),
          Option(text: 'Sadece estetik görünüm', score: 0),
          Option(text: 'Sadece ticari aktivite', score: 0),
        ],
        category: 'Ulaşım',
      ),
      Question(
        text: 'E-bisiklet (elektrikli bisiklet) kullanımının artışının nedeni nedir?',
        options: [
          Option(text: 'Sadece çevre bilinci', score: 0),
          Option(text: 'Daha az fiziksel efor ve daha uzun menzil', score: 10),
          Option(text: 'Sadece teknoloji merakı', score: 0),
          Option(text: 'Sadece ekonomik durum', score: 0),
        ],
        category: 'Ulaşım',
      ),
      Question(
        text: 'Bisiklet park alanlarının (bike parking) tasarımında önemli faktörler nelerdir?',
        options: [
          Option(text: 'Sadece sayısal kapasite', score: 0),
          Option(text: 'Güvenlik, erişilebilirlik ve konum', score: 10),
          Option(text: 'Sadece estetik görünüm', score: 0),
          Option(text: 'Sadece maliyet', score: 0),
        ],
        category: 'Ulaşım',
      ),
      Question(
        text: 'Pedestrian priority (yaya öncelikli) bölgelerin faydası nedir?',
        options: [
          Option(text: 'Sadece güvenlik', score: 0),
          Option(text: 'Yaya güvenliği, trafik azaltımı ve yaşam kalitesi', score: 10),
          Option(text: 'Sadece ticari canlanma', score: 0),
          Option(text: 'Sadece çevre koruması', score: 0),
        ],
        category: 'Ulaşım',
      ),
      Question(
        text: 'Bisiklet kullanımını artırmak için hangi faktörler önemlidir?',
        options: [
          Option(text: 'Sadece bisiklet satış fiyatı', score: 0),
          Option(text: 'Güvenli altyapı, park alanları ve bilinçlendirme', score: 10),
          Option(text: 'Sadece reklam', score: 0),
          Option(text: 'Sadece teknoloji', score: 0),
        ],
        category: 'Ulaşım',
      ),
      Question(
        text: 'Yürüyüş mesafesi (walking distance) standartı genellikle kaç dakikadır?',
        options: [
          Option(text: '1-2 dakika', score: 0),
          Option(text: '5-10 dakika (400-800 metre)', score: 10),
          Option(text: '20-30 dakika', score: 0),
          Option(text: '45-60 dakika', score: 0),
        ],
        category: 'Ulaşım',
      ),
      Question(
        text: 'Bisiklet bakım istasyonlarının (bike repair station) şehirdeki rolü nedir?',
        options: [
          Option(text: 'Sadece tamir hizmeti', score: 0),
          Option(text: 'Bisiklet kullanımını destekleyen altyapı hizmeti', score: 10),
          Option(text: 'Sadece ticari gelir', score: 0),
          Option(text: 'Sadece prestij', score: 0),
        ],
        category: 'Ulaşım',
      ),
      Question(
        text: 'Crosswalk (yaya geçidi) tasarımında güvenlik için hangi faktörler önemlidir?',
        options: [
          Option(text: 'Sadece görünürlük', score: 0),
          Option(text: 'Görünürlük, genişlik ve trafik kontrolü', score: 10),
          Option(text: 'Sadece işaretleme', score: 0),
          Option(text: 'Sadece aydınlatma', score: 0),
        ],
        category: 'Ulaşım',
      ),
      Question(
        text: 'Bisiklet kullanımında helmet (kask) kullanımının önemi nedir?',
        options: [
          Option(text: 'Sadece yasal zorunluluk', score: 0),
          Option(text: 'Baş yaralanması riskini önemli ölçüde azaltma', score: 10),
          Option(text: 'Sadece konfor', score: 0),
          Option(text: 'Sadece görünüm', score: 0),
        ],
        category: 'Ulaşım',
      ),
      Question(
        text: 'Yaya dostu cadde tasarımında traffic calming (trafik yatıştırma) teknikleri nelerdir?',
        options: [
          Option(text: 'Sadece hız limiti', score: 0),
          Option(text: 'Kasis, ada ve daraltma gibi fiziksel düzenlemeler', score: 10),
          Option(text: 'Sadece işaretler', score: 0),
          Option(text: 'Sadece kamera', score: 0),
        ],
        category: 'Ulaşım',
      ),
      Question(
        text: 'Bisiklet şehir planlamasında bicycle boulevard (bisiklet bulvarı) konsepti nedir?',
        options: [
          Option(text: 'Sadece bisiklet yolu', score: 0),
          Option(text: 'Otomobil trafiğinin minimize edildiği bisiklet odaklı yol', score: 10),
          Option(text: 'Sadece geniş yol', score: 0),
          Option(text: 'Sadece hızlı yol', score: 0),
        ],
        category: 'Ulaşım',
      ),
      Question(
        text: 'Yürüyüş altyapısında universal design (evrensel tasarım) prensipleri nelerdir?',
        options: [
          Option(text: 'Sadece engelliler için', score: 0),
          Option(text: 'Herkes için erişilebilir ve kullanımı kolay tasarım', score: 10),
          Option(text: 'Sadece yaşlılar için', score: 0),
          Option(text: 'Sadece çocuklar için', score: 0),
        ],
        category: 'Ulaşım',
      ),
      Question(
        text: 'Bisiklet eğitim programlarının toplumdaki rolü nedir?',
        options: [
          Option(text: 'Sadece teknik beceri', score: 0),
          Option(text: 'Güvenli sürüş ve trafik bilinci kazandırma', score: 10),
          Option(text: 'Sadece spor', score: 0),
          Option(text: 'Sadece eğlence', score: 0),
        ],
        category: 'Ulaşım',
      ),
      Question(
        text: 'Yaya bölgelerinde (pedestrian zones) hangi araçlar izin verilir?',
        options: [
          Option(text: 'Tüm motorlu araçlar', score: 0),
          Option(text: 'Acil durum araçları ve bazı ticari araçlar', score: 10),
          Option(text: 'Sadece otobüs', score: 0),
          Option(text: 'Sadece taksi', score: 0),
        ],
        category: 'Ulaşım',
      ),
      Question(
        text: 'Bisiklet kullanımının çevresel faydaları nelerdir?',
        options: [
          Option(text: 'Sadece gürültü azaltımı', score: 0),
          Option(text: 'Sıfır emisyon, hava kalitesi iyileştirmesi ve alan tasarrufu', score: 10),
          Option(text: 'Sadece enerji tasarrufu', score: 0),
          Option(text: 'Sadece maliyet azaltımı', score: 0),
        ],
        category: 'Ulaşım',
      ),
      Question(
        text: 'Yürüyüş ve bisiklet köprülerinin (pedestrian bridge) şehir planlamasındaki yeri nedir?',
        options: [
          Option(text: 'Sadece dekoratif', score: 0),
          Option(text: 'Ulaşım sürekliliği ve engelleri aşma', score: 10),
          Option(text: 'Sadece turizm', score: 0),
          Option(text: 'Sadece prestij', score: 0),
        ],
        category: 'Ulaşım',
      ),
      Question(
        text: 'Bisiklet turizminin şehir ekonomisine katkısı nedir?',
        options: [
          Option(text: 'Sadece turizm geliri', score: 0),
          Option(text: 'Yerel ekonomi canlanması ve istihdam yaratma', score: 10),
          Option(text: 'Sadece altyapı yatırımı', score: 0),
          Option(text: 'Sadece tanıtım', score: 0),
        ],
        category: 'Ulaşım',
      ),
      Question(
        text: 'Yaya geçitlerinde push button (düğme) sistemlerinin amacı nedir?',
        options: [
          Option(text: 'Sadece kolaylık', score: 0),
          Option(text: 'Yaya sinyali talep etme ve trafik kontrolü', score: 10),
          Option(text: 'Sadece güvenlik', score: 0),
          Option(text: 'Sadece teknoloji', score: 0),
        ],
        category: 'Ulaşım',
      ),
      Question(
        text: 'Bisiklet kullanımında grup sürüş (group riding) kuralları nelerdir?',
        options: [
          Option(text: 'Sadece keyif', score: 0),
          Option(text: 'Güvenlik, düzen ve trafik kurallarına uyum', score: 10),
          Option(text: 'Sadece hız', score: 0),
          Option(text: 'Sadece eğlence', score: 0),
        ],
        category: 'Ulaşım',
      ),
      Question(
        text: 'Yürüyüş altyapısında wayfinding (yol bulma) sistemleri nasıl çalışır?',
        options: [
          Option(text: 'Sadece haritalar', score: 0),
          Option(text: 'İşaretler, tabelalar ve dijital yönlendirme', score: 10),
          Option(text: 'Sadece gps', score: 0),
          Option(text: 'Sadece uygulamalar', score: 0),
        ],
        category: 'Ulaşım',
      ),
      Question(
        text: 'Bisiklet ve yürüyüş dostu şehirlerde economic impact (ekonomik etki) nasıl ölçülür?',
        options: [
          Option(text: 'Sadece altyapı maliyeti', score: 0),
          Option(text: 'Sağlık tasarrufu, emlak değeri ve turizm geliri', score: 10),
          Option(text: 'Sadece araç satışı', score: 0),
          Option(text: 'Sadece benzin tüketimi', score: 0),
        ],
        category: 'Ulaşım',
      ),

      // Sürdürülebilir Ulaşım (25 soru)
      Question(
        text: 'Sürdürülebilir ulaşım sistemlerinin tanımı nedir?',
        options: [
          Option(text: 'Sadece elektrikli araçlar', score: 0),
          Option(text: 'Çevre, ekonomi ve sosyal faydayı dengeleyen ulaşım', score: 10),
          Option(text: 'Sadece toplu taşıma', score: 0),
          Option(text: 'Sadece yürüyüş ve bisiklet', score: 0),
        ],
        category: 'Ulaşım',
      ),
      Question(
        text: 'Ulaşım sektörünün küresel CO₂ emisyonlarındaki payı yaklaşık yüzde kaçtır?',
        options: [
          Option(text: '%5-10', score: 0),
          Option(text: '%20-25', score: 10),
          Option(text: '%40-45', score: 0),
          Option(text: '%60-65', score: 0),
        ],
        category: 'Ulaşım',
      ),
      Question(
        text: 'Sustainable transportation planning (sürdürülebilir ulaşım planlaması) hangi faktörleri dikkate alır?',
        options: [
          Option(text: 'Sadece trafik yoğunluğu', score: 0),
          Option(text: 'Çevresel etki, sosyal eşitlik ve ekonomik verimlilik', score: 10),
          Option(text: 'Sadece maliyet', score: 0),
          Option(text: 'Sadece teknoloji', score: 0),
        ],
        category: 'Ulaşım',
      ),
      Question(
        text: 'Mobility as a Service (MaaS) konsepti nedir?',
        options: [
          Option(text: 'Sadece taksi hizmeti', score: 0),
          Option(text: 'Farklı ulaşım türlerini entegre eden dijital platform', score: 10),
          Option(text: 'Sadece toplu taşıma', score: 0),
          Option(text: 'Sadece araç kiralama', score: 0),
        ],
        category: 'Ulaşım',
      ),
      Question(
        text: 'Low Emission Zone (LEZ) uygulamasının amacı nedir?',
        options: [
          Option(text: 'Sadece trafik azaltımı', score: 0),
          Option(text: 'Yüksek emisyonlu araçların şehir merkezine girişini sınırlamak', score: 10),
          Option(text: 'Sadece gelir artışı', score: 0),
          Option(text: 'Sadece prestij', score: 0),
        ],
        category: 'Ulaşım',
      ),
      Question(
        text: 'Shared mobility (paylaşımlı mobilite) çözümleri hangilerini içerir?',
        options: [
          Option(text: 'Sadece bisiklet paylaşımı', score: 0),
          Option(text: 'Araç, bisiklet ve scooter paylaşım sistemleri', score: 10),
          Option(text: 'Sadece araç paylaşımı', score: 0),
          Option(text: 'Sadece scooter paylaşımı', score: 0),
        ],
        category: 'Ulaşım',
      ),
      Question(
        text: 'Transportation demand management (ulaşım talep yönetimi) nedir?',
        options: [
          Option(text: 'Sadece yol inşası', score: 0),
          Option(text: 'Ulaşım ihtiyacını azaltma ve alternatifleri teşvik etme', score: 10),
          Option(text: 'Sadece trafik yönetimi', score: 0),
          Option(text: 'Sadece park yönetimi', score: 0),
        ],
        category: 'Ulaşım',
      ),
      Question(
        text: 'Green transportation (yeşil ulaşım) uygulamalarının en etkilisi hangisidir?',
        options: [
          Option(text: 'Sadece elektrikli araçlar', score: 0),
          Option(text: 'Kombine yaklaşım: toplu taşıma + bisiklet + yürüyüş', score: 10),
          Option(text: 'Sadece bioyakıt', score: 0),
          Option(text: 'Sadece hidrojen', score: 0),
        ],
        category: 'Ulaşım',
      ),
      Question(
        text: 'Sürdürülebilir ulaşımda equitable access (eşit erişim) ne anlama gelir?',
        options: [
          Option(text: 'Sadece fiyat eşitliği', score: 0),
          Option(text: 'Tüm sosyal grupların ulaşım hizmetlerine eşit erişimi', score: 10),
          Option(text: 'Sadece coğrafi erişim', score: 0),
          Option(text: 'Sadece zamansal erişim', score: 0),
        ],
        category: 'Ulaşım',
      ),
      Question(
        text: 'Transportation vulnerability assessment (ulaşım kırılganlık değerlendirmesi) hangi faktörleri analiz eder?',
        options: [
          Option(text: 'Sadece maliyet', score: 0),
          Option(text: 'Altyapı dayanıklılığı, iklim değişikliği etkileri ve sosyal dayanıklılık', score: 10),
          Option(text: 'Sadece trafik yoğunluğu', score: 0),
          Option(text: 'Sadece teknoloji', score: 0),
        ],
        category: 'Ulaşım',
      ),
      Question(
        text: 'Carbon footprint (karbon ayak izi) azaltımında ulaşım sektörünün önemi nedir?',
        options: [
          Option(text: 'Sadece hava kirliliği', score: 0),
          Option(text: 'Küresel emisyonların önemli bölümü ve hızla büyüyen kaynak', score: 10),
          Option(text: 'Sadece yerel etki', score: 0),
          Option(text: 'Sadece teknoloji sorunu', score: 0),
        ],
        category: 'Ulaşım',
      ),
      Question(
        text: 'Transit-oriented development (TOD) ve sustainable transportation arasındaki ilişki nedir?',
        options: [
          Option(text: 'Sadece gayrimenkul geliştirme', score: 0),
          Option(text: 'Toplu taşıma etrafında kompakt, sürdürülebilir şehirleşme', score: 10),
          Option(text: 'Sadece ticari alan geliştirme', score: 0),
          Option(text: 'Sadece konut geliştirme', score: 0),
        ],
        category: 'Ulaşım',
      ),
      Question(
        text: 'Sustainable urban mobility plan (SUMP) nedir?',
        options: [
          Option(text: 'Sadece trafik planlaması', score: 0),
          Option(text: 'Sürdürülebilir ulaşım stratejileri ve hedefler bütünü', score: 10),
          Option(text: 'Sadece altyapı planlaması', score: 0),
          Option(text: 'Sadece teknoloji planlaması', score: 0),
        ],
        category: 'Ulaşım',
      ),
      Question(
        text: 'Green infrastructure (yeşil altyapı) ulaşımda hangi uygulamaları içerir?',
        options: [
          Option(text: 'Sadece ağaçlandırma', score: 0),
          Option(text: 'Yeşil çatılar, yağmur bahçeleri ve permeable yüzeyler', score: 10),
          Option(text: 'Sadece park alanları', score: 0),
          Option(text: 'Sadece bisiklet yolları', score: 0),
        ],
        category: 'Ulaşım',
      ),
      Question(
        text: 'Transportation resilience (ulaşım dayanıklılığı) hangi durumlarda önem kazanır?',
        options: [
          Option(text: 'Sadece normal günlük trafik', score: 0),
          Option(text: 'Doğal afetler, iklim değişikliği ve acil durumlar', score: 10),
          Option(text: 'Sadece teknik arızalar', score: 0),
          Option(text: 'Sadece grev durumları', score: 0),
        ],
        category: 'Ulaşım',
      ),
      Question(
        text: 'Behavioral change (davranış değişikliği) sürdürülebilir ulaşımda nasıl sağlanır?',
        options: [
          Option(text: 'Sadece zorlayıcı önlemler', score: 0),
          Option(text: 'Eğitim, teşvik ve kolay alternatifler sunma', score: 10),
          Option(text: 'Sadece vergi artışı', score: 0),
          Option(text: 'Sadece teknoloji çözümü', score: 0),
        ],
        category: 'Ulaşım',
      ),
      Question(
        text: 'Lifecycle assessment (yaşam döngüsü değerlendirmesi) ulaşım projelerinde neden yapılır?',
        options: [
          Option(text: 'Sadece maliyet hesabı', score: 0),
          Option(text: 'Projenin çevresel etkilerini kapsamlı değerlendirmek', score: 10),
          Option(text: 'Sadece teknik analiz', score: 0),
          Option(text: 'Sadece güvenlik değerlendirmesi', score: 0),
        ],
        category: 'Ulaşım',
      ),
      Question(
        text: 'Sustainable logistics (sürdürülebilir lojistik) hangi yaklaşımları içerir?',
        options: [
          Option(text: 'Sadece hızlı teslimat', score: 0),
          Option(text: 'Rota optimizasyonu, çevre dostu araçlar ve paketleme', score: 10),
          Option(text: 'Sadece maliyet azaltımı', score: 0),
          Option(text: 'Sadece teknoloji', score: 0),
        ],
        category: 'Ulaşım',
      ),
      Question(
        text: 'Climate adaptation (iklim uyumu) ulaşım altyapısında hangi önlemleri gerektirir?',
        options: [
          Option(text: 'Sadece aydınlatma iyileştirmesi', score: 0),
          Option(text: 'Sel, sıcaklık ve aşırı hava olaylarına dayanıklı tasarım', score: 10),
          Option(text: 'Sadece genişletme', score: 0),
          Option(text: 'Sadece bakım', score: 0),
        ],
        category: 'Ulaşım',
      ),
      Question(
        text: 'Public participation (halk katılımı) sürdürülebilir ulaşım planlamasında nasıl sağlanır?',
        options: [
          Option(text: 'Sadece anket çalışması', score: 0),
          Option(text: 'Toplantılar, çevrimiçi platformlar ve danışma süreçleri', score: 10),
          Option(text: 'Sadece medya kampanyası', score: 0),
          Option(text: 'Sadece uzman görüşü', score: 0),
        ],
        category: 'Ulaşım',
      ),
      Question(
        text: 'Transportation poverty (ulaşım yoksulluğu) nedir?',
        options: [
          Option(text: 'Sadece araç sahibi olmamak', score: 0),
          Option(text: 'Ulaşım maliyeti nedeniyle temel hizmetlere erişim zorluğu', score: 10),
          Option(text: 'Sadece coğrafi kısıt', score: 0),
          Option(text: 'Sadece zaman kısıtı', score: 0),
        ],
        category: 'Ulaşım',
      ),
      Question(
        text: 'Green procurement (yeşil satın alma) ulaşım altyapısında nasıl uygulanır?',
        options: [
          Option(text: 'Sadece düşük maliyet', score: 0),
          Option(text: 'Çevresel etkisi düşük malzemeler ve teknolojiler seçme', score: 10),
          Option(text: 'Sadece yerli ürün', score: 0),
          Option(text: 'Sadece kaliteli ürün', score: 0),
        ],
        category: 'Ulaşım',
      ),
      Question(
        text: 'Sustainable transport indicators (sürdürülebilir ulaşım göstergeleri) hangi metrikleri içerir?',
        options: [
          Option(text: 'Sadece trafik hızı', score: 0),
          Option(text: 'Emisyon, erişilebilirlik, güvenlik ve verimlilik ölçümleri', score: 10),
          Option(text: 'Sadece kullanıcı memnuniyeti', score: 0),
          Option(text: 'Sadece maliyet', score: 0),
        ],
        category: 'Ulaşım',
      ),
      Question(
        text: 'Transport energy transition (ulaşım enerji geçişi) hangi aşamaları içerir?',
        options: [
          Option(text: 'Sadece araç değişimi', score: 0),
          Option(text: 'Teknoloji, altyapı, politika ve davranış değişikliği', score: 10),
          Option(text: 'Sadece finansman', score: 0),
          Option(text: 'Sadece regülasyon', score: 0),
        ],
        category: 'Ulaşım',
      ),

      // Alternatif Yakıtlar (25 soru)
      Question(
        text: 'Biogas (biogaz) ulaşımda nasıl kullanılır?',
        options: [
          Option(text: 'Sadece yakıt olarak', score: 0),
          Option(text: 'Sıkıştırılmış biogaz (CBG) olarak araç yakıtı', score: 10),
          Option(text: 'Sadece elektrik üretimi', score: 0),
          Option(text: 'Sadece ısıtma', score: 0),
        ],
        category: 'Ulaşım',
      ),
      Question(
        text: 'Hydrogen fuel cell vehicles (hidrojen yakıt hücreli araçlar) nasıl çalışır?',
        options: [
          Option(text: 'Hidrojeni yakarak ısı üretir', score: 0),
          Option(text: 'Hidrojen ve oksijeni elektrik üretmek için birleştirir', score: 10),
          Option(text: 'Hidrojeni direkt yakıt olarak kullanır', score: 0),
          Option(text: 'Sadece elektrikli motor', score: 0),
        ],
        category: 'Ulaşım',
      ),
      Question(
        text: 'Biofuel (biyoyakıt) üretiminde hangi hammaddeler kullanılır?',
        options: [
          Option(text: 'Sadece mısır', score: 0),
          Option(text: 'Bitkisel yağlar, şeker kamışı ve algler', score: 10),
          Option(text: 'Sadece ağaç', score: 0),
          Option(text: 'Sadece atıklar', score: 0),
        ],
        category: 'Ulaşım',
      ),
      Question(
        text: 'Compressed Natural Gas (CNG) araçlarının avantajı nedir?',
        options: [
          Option(text: 'Daha yüksek emisyon', score: 0),
          Option(text: 'Daha düşük maliyet ve çevresel etki', score: 10),
          Option(text: 'Daha yüksek performans', score: 0),
          Option(text: 'Daha kolay depolama', score: 0),
        ],
        category: 'Ulaşım',
      ),
      Question(
        text: 'Liquefied Petroleum Gas (LPG) araçlarının özellikleri nelerdir?',
        options: [
          Option(text: 'Sadece dizel araçlarda', score: 0),
          Option(text: 'Benzin ve dizel araçlara dönüştürülebilir, daha temiz yanma', score: 10),
          Option(text: 'Sadece elektrikli araçlarda', score: 0),
          Option(text: 'Sadece hibrit araçlarda', score: 0),
        ],
        category: 'Ulaşım',
      ),
      Question(
        text: 'E-fuels (e-yakıtlar) nedir ve nasıl üretilir?',
        options: [
          Option(text: 'Sadece elektrikli araçlar için yakıt', score: 0),
          Option(text: 'Elektrikle üretilen sentetik yakıtlar (PtL teknolojisi)', score: 10),
          Option(text: 'Sadece biyoyakıt', score: 0),
          Option(text: 'Sadece hidrojen', score: 0),
        ],
        category: 'Ulaşım',
      ),
      Question(
        text: 'Synthetic diesel (sentetik dizel) üretiminde kullanılan Fischer-Tropsch prosesi nedir?',
        options: [
          Option(text: 'Sadece petrol işleme', score: 0),
          Option(text: 'Gazlaşmış karbon kaynaklarından sıvı yakıt üretimi', score: 10),
          Option(text: 'Sadece bitkisel yağ işleme', score: 0),
          Option(text: 'Sadece atık işleme', score: 0),
        ],
        category: 'Ulaşım',
      ),
      Question(
        text: 'Ammonia (amonyak) yakıt olarak ulaşımda nasıl kullanılır?',
        options: [
          Option(text: 'Sadece gemi taşımacılığında', score: 0),
          Option(text: 'Yakıt hücresi veya direkt yanma ile enerji üretimi', score: 10),
          Option(text: 'Sadece araç soğutmasında', score: 0),
          Option(text: 'Sadece endüstriyel kullanım', score: 0),
        ],
        category: 'Ulaşım',
      ),
      Question(
        text: 'LNG (Liquefied Natural Gas) ulaşım sektöründeki kullanım alanları nelerdir?',
        options: [
          Option(text: 'Sadece ev ısıtması', score: 0),
          Option(text: 'Ağır vasıta, gemi ve tren taşımacılığı', score: 10),
          Option(text: 'Sadece elektrik üretimi', score: 0),
          Option(text: 'Sadece endüstriyel proses', score: 0),
        ],
        category: 'Ulaşım',
      ),
      Question(
        text: 'Second-generation biofuels (ikinci nesil biyoyakıtlar) hangi özelliğe sahiptir?',
        options: [
          Option(text: 'Gıda bitkilerinden üretilir', score: 0),
          Option(text: 'Gıda ile rekabet etmeyen atık ve alglerden üretilir', score: 10),
          Option(text: 'Sadece hayvansal atıklardan üretilir', score: 0),
          Option(text: 'Sadece orman atıklarından üretilir', score: 0),
        ],
        category: 'Ulaşım',
      ),
      Question(
        text: 'Fuel cell electric vehicles (FCEV) batarya elektrikli araçlara göre avantajı nedir?',
        options: [
          Option(text: 'Daha düşük maliyet', score: 0),
          Option(text: 'Daha hızlı yakıt ikmali ve daha uzun menzil', score: 10),
          Option(text: 'Daha az teknoloji karmaşıklığı', score: 0),
          Option(text: 'Daha basit altyapı', score: 0),
        ],
        category: 'Ulaşım',
      ),
      Question(
        text: 'Methanol yakıt olarak ulaşımda hangi avantajlara sahiptir?',
        options: [
          Option(text: 'Sadece düşük maliyet', score: 0),
          Option(text: 'Yüksek oktan sayısı, temiz yanma ve esnek üretim', score: 10),
          Option(text: 'Sadece yüksek enerji yoğunluğu', score: 0),
          Option(text: 'Sadece kolay depolama', score: 0),
        ],
        category: 'Ulaşım',
      ),
      Question(
        text: 'Hybrid electric vehicles (HEV) yakıt sisteminde hangi yakıt türlerini kullanır?',
        options: [
          Option(text: 'Sadece elektrik', score: 0),
          Option(text: 'Benzin veya dizel + elektrik hibrit sistemi', score: 10),
          Option(text: 'Sadece hidrojen', score: 0),
          Option(text: 'Sadece biyoyakıt', score: 0),
        ],
        category: 'Ulaşım',
      ),
      Question(
        text: 'Renewable diesel (yenilenebilir dizel) üretim yöntemleri nelerdir?',
        options: [
          Option(text: 'Sadece bitkisel yağ işleme', score: 0),
          Option(text: 'Hydrotreating ve gasification-Fischer-Tropsch', score: 10),
          Option(text: 'Sadece atık yağ işleme', score: 0),
          Option(text: 'Sadece alg işleme', score: 0),
        ],
        category: 'Ulaşım',
      ),
      Question(
        text: 'Biogas upgrading (biogaz iyileştirme) işlemi nedir?',
        options: [
          Option(text: 'Sadece koku giderimi', score: 0),
          Option(text: 'Metan konsantrasyonunu artırarak yakıt kalitesini iyileştirme', score: 10),
          Option(text: 'Sadece basınç artırma', score: 0),
          Option(text: 'Sadece filtreleme', score: 0),
        ],
        category: 'Ulaşım',
      ),
      Question(
        text: 'Jet fuel alternatifleri havacılıkta hangi özellikleri sağlamalıdır?',
        options: [
          Option(text: 'Sadece düşük maliyet', score: 0),
          Option(text: 'Yüksek enerji yoğunluğu ve mevcut motor uyumluluğu', score: 10),
          Option(text: 'Sadece çevre dostu', score: 0),
          Option(text: 'Sadece kolay üretim', score: 0),
        ],
        category: 'Ulaşım',
      ),
      Question(
        text: 'Power-to-X teknolojisi nedir?',
        options: [
          Option(text: 'Sadece elektrik üretimi', score: 0),
          Option(text: 'Elektrikten farklı enerji formları (X) üretme teknolojileri', score: 10),
          Option(text: 'Sadece ısı üretimi', score: 0),
          Option(text: 'Sadece hidrojen üretimi', score: 0),
        ],
        category: 'Ulaşım',
      ),
      Question(
        text: 'Carbon neutral fuels (karbon nötr yakıtlar) nasıl çalışır?',
        options: [
          Option(text: 'Sıfır karbon emisyonu', score: 0),
          Option(text: 'Kullanılan CO₂ atmosferden alınmış ve tekrar salınmış', score: 10),
          Option(text: 'Sadece düşük emisyon', score: 0),
          Option(text: 'Sadece temiz yakıt', score: 0),
        ],
        category: 'Ulaşım',
      ),
      Question(
        text: 'Waste-to-fuel (atıktan yakıt) teknolojileri hangi atık türlerini kullanır?',
        options: [
          Option(text: 'Sadece gıda atığı', score: 0),
          Option(text: 'Plastik, organik ve endüstriyel atıklar', score: 10),
          Option(text: 'Sadece kağıt atığı', score: 0),
          Option(text: 'Sadece tekstil atığı', score: 0),
        ],
        category: 'Ulaşım',
      ),
      Question(
        text: 'Sustainable aviation fuels (SAF) üretiminde hangi yöntemler kullanılır?',
        options: [
          Option(text: 'Sadece bitkisel yağ', score: 0),
          Option(text: 'HEFA, FT-SPK ve ATJ teknolojileri', score: 10),
          Option(text: 'Sadece alg', score: 0),
          Option(text: 'Sadece atık yağ', score: 0),
        ],
        category: 'Ulaşım',
      ),
      Question(
        text: 'Alternative fuel infrastructure (alternatif yakıt altyapısı) geliştirmede en büyük zorluk nedir?',
        options: [
          Option(text: 'Sadece maliyet', score: 0),
          Option(text: 'Standartlaşma, güvenlik ve yatırım geri dönüş süresi', score: 10),
          Option(text: 'Sadece teknoloji', score: 0),
          Option(text: 'Sadece regülasyon', score: 0),
        ],
        category: 'Ulaşım',
      ),
      Question(
        text: 'Plug-in hybrid electric vehicles (PHEV) yakıt sistemi nasıl çalışır?',
        options: [
          Option(text: 'Sadece benzin motoru', score: 0),
          Option(text: 'Elektrik motoru + benzin motoru hibrit sistemi', score: 10),
          Option(text: 'Sadece elektrik motoru', score: 0),
          Option(text: 'Sadece hidrojen yakıt hücresi', score: 0),
        ],
        category: 'Ulaşım',
      ),
      Question(
        text: 'Bio-CNG üretiminde digestate (çürütme kalıntısı) nasıl kullanılır?',
        options: [
          Option(text: 'Sadece atık', score: 0),
          Option(text: 'Organik gübre ve toprak iyileştirici olarak', score: 10),
          Option(text: 'Sadece yakıt', score: 0),
          Option(text: 'Sadece kimyasal', score: 0),
        ],
        category: 'Ulaşım',
      ),
      Question(
        text: 'Renewable natural gas (RNG) nedir?',
        options: [
          Option(text: 'Sadece doğal gaz', score: 0),
          Option(text: 'Biyogazdan üretilen biyometan', score: 10),
          Option(text: 'Sadece sentetik gaz', score: 0),
          Option(text: 'Sadece LNG', score: 0),
        ],
        category: 'Ulaşım',
      ),
      Question(
        text: 'Alternative fuels lifecycle assessment (alternatif yakıtlar yaşam döngüsü değerlendirmesi) neden önemlidir?',
        options: [
          Option(text: 'Sadece maliyet hesabı', score: 0),
          Option(text: 'Gerçek çevresel etkiyi kapsamlı değerlendirmek için', score: 10),
          Option(text: 'Sadece teknik analiz', score: 0),
          Option(text: 'Sadece ekonomik analiz', score: 0),
        ],
        category: 'Ulaşım',
      ),

      // Havacılık ve Denizcilik (25 soru)
      Question(
        text: 'Havacılık sektörünün küresel CO₂ emisyonlarındaki payı yaklaşık yüzde kaçtır?',
        options: [
          Option(text: '%1-2', score: 0),
          Option(text: '%2-3', score: 10),
          Option(text: '%5-7', score: 0),
          Option(text: '%10-12', score: 0),
        ],
        category: 'Ulaşım',
      ),
      Question(
        text: 'Sustainable Aviation Fuels (SAF) kullanımının avantajı nedir?',
        options: [
          Option(text: 'Sadece maliyet azaltımı', score: 0),
          Option(text: 'Mevcut motorlarla uyumlu ve %80\'e kadar emisyon azaltımı', score: 10),
          Option(text: 'Sadece performans artışı', score: 0),
          Option(text: 'Sadece güvenlik', score: 0),
        ],
        category: 'Ulaşım',
      ),
      Question(
        text: 'Deniz taşımacılığında LNG kullanımının faydası nedir?',
        options: [
          Option(text: 'Sadece maliyet artışı', score: 0),
          Option(text: 'Daha temiz yanma ve daha düşük kükürt emisyonu', score: 10),
          Option(text: 'Sadece güvenlik artışı', score: 0),
          Option(text: 'Sadece kapasite artışı', score: 0),
        ],
        category: 'Ulaşım',
      ),
      Question(
        text: 'Electric aircraft (elektrikli uçak) teknolojisinin mevcut sınırlamaları nelerdir?',
        options: [
          Option(text: 'Sadece güvenlik sorunları', score: 0),
          Option(text: 'Batarya ağırlığı ve enerji yoğunluğu sınırlamaları', score: 10),
          Option(text: 'Sadece maliyet sorunları', score: 0),
          Option(text: 'Sadece teknoloji karmaşıklığı', score: 0),
        ],
        category: 'Ulaşım',
      ),
      Question(
        text: 'Deniz taşımacılığında scrubber (filtre) sistemlerinin amacı nedir?',
        options: [
          Option(text: 'Sadece yakıt tasarrufu', score: 0),
          Option(text: 'Kükürt emisyonlarını azaltmak için egzoz gazı temizleme', score: 10),
          Option(text: 'Sadece motor koruması', score: 0),
          Option(text: 'Sadece gürültü azaltımı', score: 0),
        ],
        category: 'Ulaşım',
      ),
      Question(
        text: 'Havacılıkta efficiency (verimlilik) artırma yöntemleri nelerdir?',
        options: [
          Option(text: 'Sadece hız artırma', score: 0),
          Option(text: 'Yeni motor teknolojileri, hafif malzemeler ve aerodinamik iyileştirmeler', score: 10),
          Option(text: 'Sadece rota optimizasyonu', score: 0),
          Option(text: 'Sadece yakıt değişimi', score: 0),
        ],
        category: 'Ulaşım',
      ),
      Question(
        text: 'Hydrogen-powered ships (hidrojenle çalışan gemiler) nasıl enerji üretir?',
        options: [
          Option(text: 'Sadece yakma ile', score: 0),
          Option(text: 'Yakıt hücresi teknolojisi ile elektrik üretimi', score: 10),
          Option(text: 'Sadece buhar üretimi', score: 0),
          Option(text: 'Sadece ısı üretimi', score: 0),
        ],
        category: 'Ulaşım',
      ),
      Question(
        text: 'Aviation biofuels üretiminde hangi hammadde kaynakları kullanılır?',
        options: [
          Option(text: 'Sadece mısır', score: 0),
          Option(text: 'Algler, atık yağlar ve enerji bitkileri', score: 10),
          Option(text: 'Sadece şeker kamışı', score: 0),
          Option(text: 'Sadece orman atıkları', score: 0),
        ],
        category: 'Ulaşım',
      ),
      Question(
        text: 'Deniz taşımacılığında slow steaming (yavaş seyir) tekniğinin faydası nedir?',
        options: [
          Option(text: 'Sadece zaman tasarrufu', score: 0),
          Option(text: 'Yakıt tüketimi ve emisyon azaltımı', score: 10),
          Option(text: 'Sadece güvenlik artışı', score: 0),
          Option(text: 'Sadece konfor artışı', score: 0),
        ],
        category: 'Ulaşım',
      ),
      Question(
        text: 'Aircraft noise reduction (uçak gürültü azaltma) yöntemleri nelerdir?',
        options: [
          Option(text: 'Sadece motor tasarımı', score: 0),
          Option(text: 'Motor teknolojisi, uçuş prosedürleri ve havaalanı tasarımı', score: 10),
          Option(text: 'Sadece rota değişimi', score: 0),
          Option(text: 'Sadece zaman kısıtlaması', score: 0),
        ],
        category: 'Ulaşım',
      ),
      Question(
        text: 'Maritime autonomous surface ships (MASS) teknolojisinin avantajları nelerdir?',
        options: [
          Option(text: 'Sadece maliyet artışı', score: 0),
          Option(text: 'Güvenlik artışı, verimlilik ve operasyon maliyeti azaltımı', score: 10),
          Option(text: 'Sadece teknoloji gösterisi', score: 0),
          Option(text: 'Sadece rekabet avantajı', score: 0),
        ],
        category: 'Ulaşım',
      ),
      Question(
        text: 'Aviation industry carbon offsetting (havacılık karbon telafisi) nasıl çalışır?',
        options: [
          Option(text: 'Sadece bağış toplama', score: 0),
          Option(text: 'Emisyonları başka projelerle dengeleme sistemi', score: 10),
          Option(text: 'Sadece vergi artışı', score: 0),
          Option(text: 'Sadece teknoloji yatırımı', score: 0),
        ],
        category: 'Ulaşım',
      ),
      Question(
        text: 'Ship emissions control areas (ECA) nedir ve amacı nedir?',
        options: [
          Option(text: 'Sadece güvenlik bölgesi', score: 0),
          Option(text: 'Kükürt ve nitrojen emisyonlarını sınırlandırmak için özel bölgeler', score: 10),
          Option(text: 'Sadece ticari bölge', score: 0),
          Option(text: 'Sadece gümrük bölgesi', score: 0),
        ],
        category: 'Ulaşım',
      ),
      Question(
        text: 'Alternative jet fuels (alternatif jet yakıtları) hangi standartlara uymalıdır?',
        options: [
          Option(text: 'Sadece maliyet standardı', score: 0),
          Option(text: 'ASTM D7566 gibi güvenlik ve performans standartları', score: 10),
          Option(text: 'Sadece çevre standardı', score: 0),
          Option(text: 'Sadece ekonomi standardı', score: 0),
        ],
        category: 'Ulaşım',
      ),
      Question(
        text: 'Green shipping corridors (yeşil deniz koridorları) nedir?',
        options: [
          Option(text: 'Sadece güvenlik koridoru', score: 0),
          Option(text: 'Sürdürülebilir yakıt kullanan gemiler için özel rotalar', score: 10),
          Option(text: 'Sadece ticari koridor', score: 0),
          Option(text: 'Sadece turizm koridoru', score: 0),
        ],
        category: 'Ulaşım',
      ),
      Question(
        text: 'Aviation sector net-zero emissions (net-sıfır emisyon) hedefi hangi yıldır?',
        options: [
          Option(text: '2030', score: 0),
          Option(text: '2050', score: 10),
          Option(text: '2070', score: 0),
          Option(text: '2090', score: 0),
        ],
        category: 'Ulaşım',
      ),
      Question(
        text: 'Maritime sector decarbonization (denizcilik karbonsuzlaştırma) hangi stratejileri içerir?',
        options: [
          Option(text: 'Sadece yakıt değişimi', score: 0),
          Option(text: 'Yakıt alternatifleri, verimlilik artışı ve karbon yakalama', score: 10),
          Option(text: 'Sadece teknoloji geliştirme', score: 0),
          Option(text: 'Sadece rota optimizasyonu', score: 0),
        ],
        category: 'Ulaşım',
      ),
      Question(
        text: 'Electric vertical takeoff and landing (eVTOL) araçları ne için tasarlanmıştır?',
        options: [
          Option(text: 'Sadece kargo taşımacılığı', score: 0),
          Option(text: 'Şehir içi hava taksi ve acil durum hizmetleri', score: 10),
          Option(text: 'Sadece tarım ilaçlama', score: 0),
          Option(text: 'Sadece askeri kullanım', score: 0),
        ],
        category: 'Ulaşım',
      ),
      Question(
        text: 'Sustainable aviation roadmap (sürdürülebilir havacılık yol haritası) hangi aşamaları içerir?',
        options: [
          Option(text: 'Sadece teknoloji geliştirme', score: 0),
          Option(text: 'Yakıt iyileştirmeleri, yeni teknolojiler ve politika destekleri', score: 10),
          Option(text: 'Sadece ekonomik teşvikler', score: 0),
          Option(text: 'Sadece regülasyon', score: 0),
        ],
        category: 'Ulaşım',
      ),
      Question(
        text: 'Blue ammonia (mavi amonyak) denizcilikte yakıt olarak nasıl üretilir?',
        options: [
          Option(text: 'Sadece elektrik ile', score: 0),
          Option(text: 'Doğal gazdan üretim, karbon yakalama ile', score: 10),
          Option(text: 'Sadece hidrojen ile', score: 0),
          Option(text: 'Sadece biyokütle ile', score: 0),
        ],
        category: 'Ulaşım',
      ),
      Question(
        text: 'Aviation industry scope 3 emissions (kapsam 3 emisyonları) hangi kaynaklardan oluşur?',
        options: [
          Option(text: 'Sadece uçak yakıt tüketimi', score: 0),
          Option(text: 'Yolcu seyahati, kargo ve destek hizmetleri', score: 10),
          Option(text: 'Sadece havaalanı operasyonları', score: 0),
          Option(text: 'Sadece bakım hizmetleri', score: 0),
        ],
        category: 'Ulaşım',
      ),
      Question(
        text: 'Wind-assist technology (rüzgar destek teknolojisi) gemilerde nasıl çalışır?',
        options: [
          Option(text: 'Sadece elektrik üretimi', score: 0),
          Option(text: 'Yelken veya rüzgar türbini ile ek itiş gücü sağlama', score: 10),
          Option(text: 'Sadece gürültü azaltımı', score: 0),
          Option(text: 'Sadece stabilite artırma', score: 0),
        ],
        category: 'Ulaşım',
      ),
      Question(
        text: 'Aircraft efficiency improvements (uçak verimlilik iyileştirmeleri) hangi alanlarda yapılır?',
        options: [
          Option(text: 'Sadece motor teknolojisi', score: 0),
          Option(text: 'Aerodinamik, malzeme ve motor teknolojileri', score: 10),
          Option(text: 'Sadece navigasyon sistemi', score: 0),
          Option(text: 'Sadece yakıt kalitesi', score: 0),
        ],
        category: 'Ulaşım',
      ),
      Question(
        text: 'Carbon capture and storage (CCS) havacılıkta nasıl uygulanabilir?',
        options: [
          Option(text: 'Sadece motor içi uygulama', score: 0),
          Option(text: 'Egzoz gazlarından CO₂ yakalama ve depolama teknolojileri', score: 10),
          Option(text: 'Sadece yakıt üretiminde', score: 0),
          Option(text: 'Sadece havaalanında', score: 0),
        ],
        category: 'Ulaşım',
      ),
      Question(
        text: 'Maritime green finance (denizcilik yeşil finansmanı) hangi projeleri destekler?',
        options: [
          Option(text: 'Sadece teknoloji geliştirme', score: 0),
          Option(text: 'Sürdürülebilir yakıt, verimli teknoloji ve altyapı projeleri', score: 10),
          Option(text: 'Sadece araştırma projeleri', score: 0),
          Option(text: 'Sadece eğitim programları', score: 0),
        ],
        category: 'Ulaşım',
      ),

      // Ulaşım Planlama ve Akıllı Ulaşım (25 soru)
      Question(
        text: 'Smart transportation systems (akıllı ulaşım sistemleri) nasıl çalışır?',
        options: [
          Option(text: 'Sadece trafik ışıkları', score: 0),
          Option(text: 'Sensörler, veri analizi ve gerçek zamanlı optimizasyon', score: 10),
          Option(text: 'Sadece kameralar', score: 0),
          Option(text: 'Sadece uygulamalar', score: 0),
        ],
        category: 'Ulaşım',
      ),
      Question(
        text: 'Intelligent transportation systems (ITS) hangi teknolojileri içerir?',
        options: [
          Option(text: 'Sadece GPS', score: 0),
          Option(text: 'IoT, AI, veri analizi ve otomasyon sistemleri', score: 10),
          Option(text: 'Sadece mobil uygulamalar', score: 0),
          Option(text: 'Sadece trafik sensörleri', score: 0),
        ],
        category: 'Ulaşım',
      ),
      Question(
        text: 'Transportation planning (ulaşım planlamasında) hangi veri türleri kullanılır?',
        options: [
          Option(text: 'Sadece trafik sayıları', score: 0),
          Option(text: 'Demografik, ekonomik, çevresel ve sosyal veri', score: 10),
          Option(text: 'Sadece yolculuk süreleri', score: 0),
          Option(text: 'Sadece araç sayıları', score: 0),
        ],
        category: 'Ulaşım',
      ),
      Question(
        text: 'Autonomous vehicles (otonom araçlar) ulaşım sistemini nasıl değiştirecek?',
        options: [
          Option(text: 'Sadece araç sahipliği artacak', score: 0),
          Option(text: 'Paylaşımlı mobilite, güvenlik artışı ve trafik optimizasyonu', score: 10),
          Option(text: 'Sadece teknoloji gelişimi', score: 0),
          Option(text: 'Sadece maliyet azalması', score: 0),
        ],
        category: 'Ulaşım',
      ),
      Question(
        text: 'Dynamic routing (dinamik rota) sistemleri nasıl çalışır?',
        options: [
          Option(text: 'Sadece sabit rota', score: 0),
          Option(text: 'Gerçek zamanlı trafik verilerine göre optimum rota hesaplama', score: 10),
          Option(text: 'Sadece mesafe hesaplama', score: 0),
          Option(text: 'Sadece hız limiti', score: 0),
        ],
        category: 'Ulaşım',
      ),
      Question(
        text: 'Transportation demand modeling (ulaşım talep modellemesi) nedir?',
        options: [
          Option(text: 'Sadece trafik tahmini', score: 0),
          Option(text: 'Gelecekteki ulaşım ihtiyaçlarını matematiksel olarak tahmin etme', score: 10),
          Option(text: 'Sadece rota planlaması', score: 0),
          Option(text: 'Sadece maliyet hesaplama', score: 0),
        ],
        category: 'Ulaşım',
      ),
      Question(
        text: 'Smart traffic signals (akıllı trafik ışıkları) nasıl çalışır?',
        options: [
          Option(text: 'Sadece sabit zaman', score: 0),
          Option(text: 'Trafik yoğunluğuna göre dinamik zaman ayarlama', score: 10),
          Option(text: 'Sadece sensörler', score: 0),
          Option(text: 'Sadece kamera', score: 0),
        ],
        category: 'Ulaşım',
      ),
      Question(
        text: 'Multimodal transportation (çoklu taşıma) entegrasyonu nasıl sağlanır?',
        options: [
          Option(text: 'Sadece bilet entegrasyonu', score: 0),
          Option(text: 'Fiziksel bağlantı, bilgi sistemi ve tarifelerin uyumu', score: 10),
          Option(text: 'Sadece zaman tablosu', score: 0),
          Option(text: 'Sadece araç paylaşımı', score: 0),
        ],
        category: 'Ulaşım',
      ),
      Question(
        text: 'Predictive maintenance (öngörücü bakım) ulaşım altyapısında nasıl uygulanır?',
        options: [
          Option(text: 'Sadece düzenli kontrol', score: 0),
          Option(text: 'Sensör verileri ve AI ile arıza tahmini ve önleme', score: 10),
          Option(text: 'Sadece görsel inceleme', score: 0),
          Option(text: 'Sadece planlı bakım', score: 0),
        ],
        category: 'Ulaşım',
      ),
      Question(
        text: 'Transportation accessibility (ulaşım erişilebilirliği) nasıl değerlendirilir?',
        options: [
          Option(text: 'Sadece coğrafi erişim', score: 0),
          Option(text: 'Fiziksel, ekonomik ve zamansal erişim kriterleri', score: 10),
          Option(text: 'Sadece teknoloji erişimi', score: 0),
          Option(text: 'Sadece bilgi erişimi', score: 0),
        ],
        category: 'Ulaşım',
      ),
      Question(
        text: 'Real-time passenger information (RTPI) sistemleri ne sağlar?',
        options: [
          Option(text: 'Sadece reklam', score: 0),
          Option(text: 'Varış süreleri, gecikmeler ve kapasite bilgisi', score: 10),
          Option(text: 'Sadece hava durumu', score: 0),
          Option(text: 'Sadece trafik bilgisi', score: 0),
        ],
        category: 'Ulaşım',
      ),
      Question(
        text: 'Transportation network analysis (ulaşım ağ analizi) hangi metrikleri kullanır?',
        options: [
          Option(text: 'Sadece mesafe', score: 0),
          Option(text: 'Kapasite, hız, güvenilirlik ve erişilebilirlik ölçümleri', score: 10),
          Option(text: 'Sadece sayım', score: 0),
          Option(text: 'Sadece maliyet', score: 0),
        ],
        category: 'Ulaşım',
      ),
      Question(
        text: 'Smart parking systems (akıllı park sistemleri) nasıl çalışır?',
        options: [
          Option(text: 'Sadece otomatik ödeme', score: 0),
          Option(text: 'Sensörlerle boş yer tespiti ve dinamik fiyatlandırma', score: 10),
          Option(text: 'Sadece kamera kontrolü', score: 0),
          Option(text: 'Sadece mobil uygulama', score: 0),
        ],
        category: 'Ulaşım',
      ),
      Question(
        text: 'Transportation energy efficiency (ulaşım enerji verimliliği) nasıl artırılır?',
        options: [
          Option(text: 'Sadece araç teknolojisi', score: 0),
          Option(text: 'Sistem optimizasyonu, davranış değişikliği ve altyapı iyileştirmesi', score: 10),
          Option(text: 'Sadece yakıt değişimi', score: 0),
          Option(text: 'Sadece hız kontrolü', score: 0),
        ],
        category: 'Ulaşım',
      ),
      Question(
        text: 'Connected vehicle technology (bağlı araç teknolojisi) ne sağlar?',
        options: [
          Option(text: 'Sadece internet erişimi', score: 0),
          Option(text: 'Araçlar arası iletişim ve trafik optimizasyonu', score: 10),
          Option(text: 'Sadece eğlence', score: 0),
          Option(text: 'Sadece navigasyon', score: 0),
        ],
        category: 'Ulaşım',
      ),
      Question(
        text: 'Transportation resilience (ulaşım dayanıklılığı) nasıl güçlendirilir?',
        options: [
          Option(text: 'Sadece güçlü malzeme', score: 0),
          Option(text: 'Çeşitlilik, esneklik ve hızlı toparlanma kapasitesi', score: 10),
          Option(text: 'Sadece yedek sistem', score: 0),
          Option(text: 'Sadece bakım', score: 0),
        ],
        category: 'Ulaşım',
      ),
      Question(
        text: 'Digital twins (dijital ikizler) ulaşım planlamasında nasıl kullanılır?',
        options: [
          Option(text: 'Sadece 3D model', score: 0),
          Option(text: 'Gerçek zamanlı verilerle sistem simülasyonu ve optimizasyon', score: 10),
          Option(text: 'Sadece görselleştirme', score: 0),
          Option(text: 'Sadece eğitim', score: 0),
        ],
        category: 'Ulaşım',
      ),
      Question(
        text: 'Transportation equity (ulaşım adaleti) nasıl sağlanır?',
        options: [
          Option(text: 'Sadece eşit fiyat', score: 0),
          Option(text: 'Tüm gruplara eşit erişim, kalite ve fırsat sunma', score: 10),
          Option(text: 'Sadece coğrafi denge', score: 0),
          Option(text: 'Sadece zaman denge', score: 0),
        ],
        category: 'Ulaşım',
      ),
      Question(
        text: 'Mobility-as-a-Service (MaaS) platformları nasıl çalışır?',
        options: [
          Option(text: 'Sadece araç kiralama', score: 0),
          Option(text: 'Farklı ulaşım türlerini entegre eden tek platform', score: 10),
          Option(text: 'Sadece ödeme sistemi', score: 0),
          Option(text: 'Sadece rezervasyon', score: 0),
        ],
        category: 'Ulaşım',
      ),
      Question(
        text: 'Transportation big data (ulaşım büyük verisi) analizi ne sağlar?',
        options: [
          Option(text: 'Sadece istatistik', score: 0),
          Option(text: 'Pattern tanıma, tahmin ve optimizasyon fırsatları', score: 10),
          Option(text: 'Sadece raporlama', score: 0),
          Option(text: 'Sadece kayıt tutma', score: 0),
        ],
        category: 'Ulaşım',
      ),
      Question(
        text: 'Smart city transportation (akıllı şehir ulaşımı) nasıl tasarlanır?',
        options: [
          Option(text: 'Sadece teknoloji entegrasyonu', score: 0),
          Option(text: 'Veri odaklı, sürdürülebilir ve insan odaklı yaklaşım', score: 10),
          Option(text: 'Sadece otomasyon', score: 0),
          Option(text: 'Sadece maliyet optimizasyonu', score: 0),
        ],
        category: 'Ulaşım',
      ),
      Question(
        text: 'Transportation behavioral insights (ulaşım davranış içgörüleri) nasıl kullanılır?',
        options: [
          Option(text: 'Sadece istatistiksel analiz', score: 0),
          Option(text: 'Kullanıcı davranışını anlayarak hizmet iyileştirme', score: 10),
          Option(text: 'Sadece pazar araştırması', score: 0),
          Option(text: 'Sadece anket', score: 0),
        ],
        category: 'Ulaşım',
      ),
      Question(
        text: 'Adaptive signal control (adaptif sinyal kontrolü) nasıl çalışır?',
        options: [
          Option(text: 'Sadece sabit program', score: 0),
          Option(text: 'Gerçek zamanlı trafik verilerine göre sinyal optimizasyonu', score: 10),
          Option(text: 'Sadece zaman tablosu', score: 0),
          Option(text: 'Sadece sensör kontrolü', score: 0),
        ],
        category: 'Ulaşım',
      ),
      Question(
        text: 'Transportation lifecycle assessment (ulaşım yaşam döngüsü değerlendirmesi) neden önemlidir?',
        options: [
          Option(text: 'Sadece maliyet hesabı', score: 0),
          Option(text: 'Kapsamlı çevresel etki ve sürdürülebilirlik analizi', score: 10),
          Option(text: 'Sadece teknik değerlendirme', score: 0),
          Option(text: 'Sadece güvenlik değerlendirmesi', score: 0),
        ],
        category: 'Ulaşım',
      ),
      Question(
        text: 'Transportation user experience (ulaşım kullanıcı deneyimi) nasıl iyileştirilir?',
        options: [
          Option(text: 'Sadece tasarım', score: 0),
          Option(text: 'Kullanıcı geri bildirimi, erişilebilirlik ve süreç optimizasyonu', score: 10),
          Option(text: 'Sadece teknoloji', score: 0),
          Option(text: 'Sadece maliyet azaltma', score: 0),
        ],
        category: 'Ulaşım',
      ),
      Question(
        text: 'Transportation governance (ulaşım yönetişimi) nasıl geliştirilir?',
        options: [
          Option(text: 'Sadece yasal düzenleme', score: 0),
          Option(text: 'Paydaş katılımı, şeffaflık ve çok seviyeli koordinasyon', score: 10),
          Option(text: 'Sadece merkezi yönetim', score: 0),
          Option(text: 'Sadece teknik çözüm', score: 0),
        ],
        category: 'Ulaşım',
      ),

      // Gelecek Ulaşım Teknolojileri (25 soru)
      Question(
        text: 'Hyperloop teknolojisi nasıl çalışır?',
        options: [
          Option(text: 'Sadece manyetik levitasyon', score: 0),
          Option(text: 'Vakum tüpünde manyetik levitasyon ile yüksek hız', score: 10),
          Option(text: 'Sadece elektrikli motor', score: 0),
          Option(text: 'Sadece hava basıncı', score: 0),
        ],
        category: 'Ulaşım',
      ),
      Question(
        text: 'Flying cars (uçan arabalar) için en büyük teknolojik zorluk nedir?',
        options: [
          Option(text: 'Sadece maliyet', score: 0),
          Option(text: 'Güvenlik, regülasyon ve altyapı gereksinimleri', score: 10),
          Option(text: 'Sadece teknoloji karmaşıklığı', score: 0),
          Option(text: 'Sadece enerji tüketimi', score: 0),
        ],
        category: 'Ulaşım',
      ),
      Question(
        text: 'Quantum computing (kuantum bilgisayar) ulaşım planlamasında nasıl kullanılabilir?',
        options: [
          Option(text: 'Sadece hız hesaplaması', score: 0),
          Option(text: 'Karmaşık rota optimizasyonu ve trafik simülasyonu', score: 10),
          Option(text: 'Sadece veri depolama', score: 0),
          Option(text: 'Sadece güvenlik sistemi', score: 0),
        ],
        category: 'Ulaşım',
      ),
      Question(
        text: 'Brain-computer interface (BCI) araçlarda nasıl uygulanabilir?',
        options: [
          Option(text: 'Sadece eğlence sistemi', score: 0),
          Option(text: 'Düşünce ile araç kontrolü ve güvenlik sistemleri', score: 10),
          Option(text: 'Sadece sağlık takibi', score: 0),
          Option(text: 'Sadece navigasyon', score: 0),
        ],
        category: 'Ulaşım',
      ),
      Question(
        text: 'Nanotechnology (nanoteknoloji) araçlarda hangi uygulamaları bulabilir?',
        options: [
          Option(text: 'Sadece boya teknolojisi', score: 0),
          Option(text: 'Kendiliğinden onarım, hafif malzemeler ve akıllı sensörler', score: 10),
          Option(text: 'Sadece güvenlik', score: 0),
          Option(text: 'Sadece enerji depolama', score: 0),
        ],
        category: 'Ulaşım',
      ),
      Question(
        text: '5G teknolojisinin ulaşım sistemlerine etkisi nedir?',
        options: [
          Option(text: 'Sadece daha hızlı internet', score: 0),
          Option(text: 'Gerçek zamanlı iletişim, otonom araç desteği ve akıllı altyapı', score: 10),
          Option(text: 'Sadece video kalitesi', score: 0),
          Option(text: 'Sadece oyun performansı', score: 0),
        ],
        category: 'Ulaşım',
      ),
      Question(
        text: 'Augmented reality (AR) sürüş deneyimini nasıl geliştirebilir?',
        options: [
          Option(text: 'Sadece eğlence', score: 0),
          Option(text: 'Navigasyon bilgisi, güvenlik uyarıları ve araç bilgileri görselleştirme', score: 10),
          Option(text: 'Sadece reklam', score: 0),
          Option(text: 'Sadece oyun', score: 0),
        ],
        category: 'Ulaşım',
      ),
      Question(
        text: 'Blockchain teknolojisi ulaşımda hangi sorunları çözebilir?',
        options: [
          Option(text: 'Sadece ödeme sistemi', score: 0),
          Option(text: 'Güvenli veri paylaşımı, kimlik doğrulama ve lojistik izleme', score: 10),
          Option(text: 'Sadece para transferi', score: 0),
          Option(text: 'Sadece kayıt tutma', score: 0),
        ],
        category: 'Ulaşım',
      ),
      Question(
        text: 'Fusion energy (füzyon enerjisi) araçlarda kullanılabilir mi?',
        options: [
          Option(text: 'Mevcut teknolojiyle mümkün', score: 0),
          Option(text: 'Henüz uygulanabilir değil, yıllarca araştırma gerekli', score: 10),
          Option(text: 'Sadece uzay araçları için', score: 0),
          Option(text: 'Sadece deniz araçları için', score: 0),
        ],
        category: 'Ulaşım',
      ),
      Question(
        text: 'Smart materials (akıllı malzemeler) araçlarda nasıl kullanılır?',
        options: [
          Option(text: 'Sadece dekoratif amaç', score: 0),
          Option(text: 'Şekil hafızası, kendi kendini temizleme ve renk değiştirme', score: 10),
          Option(text: 'Sadece dayanıklılık', score: 0),
          Option(text: 'Sadece maliyet azaltımı', score: 0),
        ],
        category: 'Ulaşım',
      ),
      Question(
        text: 'Internet of Things (IoT) ulaşım altyapısında hangi rolü oynar?',
        options: [
          Option(text: 'Sadece bilgi toplama', score: 0),
          Option(text: 'Sensör ağı, veri analizi ve akıllı karar verme sistemi', score: 10),
          Option(text: 'Sadece iletişim', score: 0),
          Option(text: 'Sadece kontrol', score: 0),
        ],
        category: 'Ulaşım',
      ),
      Question(
        text: '3D printing (3D baskı) araç üretiminde nasıl devrim yaratabilir?',
        options: [
          Option(text: 'Sadece hızlı prototipleme', score: 0),
          Option(text: 'Kişiselleştirilmiş parça üretimi ve karmaşık geometriler', score: 10),
          Option(text: 'Sadece maliyet azaltımı', score: 0),
          Option(text: 'Sadece hız artışı', score: 0),
        ],
        category: 'Ulaşım',
      ),
      Question(
        text: 'Metaverse teknolojisi ulaşım planlamasında nasıl kullanılabilir?',
        options: [
          Option(text: 'Sadece eğlence', score: 0),
          Option(text: 'Sanal altyapı testi, kullanıcı deneyimi simülasyonu ve eğitim', score: 10),
          Option(text: 'Sadece sanal turizm', score: 0),
          Option(text: 'Sadece sosyal medya', score: 0),
        ],
        category: 'Ulaşım',
      ),
      Question(
        text: 'Robotic automation (robotik otomasyon) ulaşımda hangi alanlarda etkili olacak?',
        options: [
          Option(text: 'Sadece üretim hattı', score: 0),
          Option(text: 'Bakım, güvenlik kontrolü, yükleme-boşaltma ve acil durum müdahalesi', score: 10),
          Option(text: 'Sadece temizlik', score: 0),
          Option(text: 'Sadece montaj', score: 0),
        ],
        category: 'Ulaşım',
      ),
      Question(
        text: 'Space elevator (uzay asansörü) ulaşım sistemini nasıl değiştirebilir?',
        options: [
          Option(text: 'Şehir içi ulaşım', score: 0),
          Option(text: 'Yer ile yörünge arası yük ve yolcu taşımacılığı', score: 10),
          Option(text: 'Sadece kargo taşımacılığı', score: 0),
          Option(text: 'Sadece turizm', score: 0),
        ],
        category: 'Ulaşım',
      ),
      Question(
        text: 'Synthetic biology (sentetik biyoloji) ulaşım yakıtlarında nasıl kullanılabilir?',
        options: [
          Option(text: 'Sadece biyoyakıt üretimi', score: 0),
          Option(text: 'Mikroorganizmalarla özel yakıt molekülleri tasarlama', score: 10),
          Option(text: 'Sadece atık işleme', score: 0),
          Option(text: 'Sadece karbon yakalama', score: 0),
        ],
        category: 'Ulaşım',
      ),
      Question(
        text: 'Quantum sensors (kuantum sensörler) araçlarda ne avantaj sağlar?',
        options: [
          Option(text: 'Sadece hassasiyet', score: 0),
          Option(text: 'Ultra hassas navigasyon, çarpışma algılama ve çevre tarama', score: 10),
          Option(text: 'Sadece hız ölçümü', score: 0),
          Option(text: 'Sadece konum belirleme', score: 0),
        ],
        category: 'Ulaşım',
      ),
      Question(
        text: 'Metamaterials (metamateryaller) araçlarda nasıl kullanılır?',
        options: [
          Option(text: 'Sadece görünmezlik', score: 0),
          Option(text: 'Süper lens, akustik kontrol ve elektromanyetik kalkanlama', score: 10),
          Option(text: 'Sadece estetik', score: 0),
          Option(text: 'Sadece dayanıklılık', score: 0),
        ],
        category: 'Ulaşım',
      ),
      Question(
        text: 'Neural networks (sinir ağları) trafik yönetiminde nasıl uygulanır?',
        options: [
          Option(text: 'Sadece veri analizi', score: 0),
          Option(text: 'Pattern tanıma, tahmin algoritmaları ve adaptif kontrol sistemleri', score: 10),
          Option(text: 'Sadece raporlama', score: 0),
          Option(text: 'Sadece tahmin', score: 0),
        ],
        category: 'Ulaşım',
      ),
      Question(
        text: 'Terahertz technology (terahertz teknolojisi) araç güvenliğinde nasıl kullanılır?',
        options: [
          Option(text: 'Sadece iletişim', score: 0),
          Option(text: 'Görünmez engel algılama, malzeme analizi ve güvenlik tarama', score: 10),
          Option(text: 'Sadece radar', score: 0),
          Option(text: 'Sadece lidar', score: 0),
        ],
        category: 'Ulaşım',
      ),
      Question(
        text: 'Bio-inspired robotics (biyomimetik robotik) ulaşımda nasıl uygulanabilir?',
        options: [
          Option(text: 'Sadece görünüm', score: 0),
          Option(text: 'Yılan gibi hareket eden araçlar, kuş sürü davranışı koordinasyonu', score: 10),
          Option(text: 'Sadece performans', score: 0),
          Option(text: 'Sadece estetik', score: 0),
        ],
        category: 'Ulaşım',
      ),
      Question(
        text: 'Optical computing (optik bilgisayar) ulaşım sistemlerinde avantajı nedir?',
        options: [
          Option(text: 'Sadece hız', score: 0),
          Option(text: 'Çok yüksek işlem hızı, düşük enerji tüketimi ve paralel işlem', score: 10),
          Option(text: 'Sadece maliyet', score: 0),
          Option(text: 'Sadece boyut', score: 0),
        ],
        category: 'Ulaşım',
      ),
      Question(
        text: 'Crumple zone technology (ezilme bölgesi teknolojisi) gelecekte nasıl gelişecek?',
        options: [
          Option(text: 'Sadece çelik geliştirme', score: 0),
          Option(text: 'Akıllı malzemeler, aktif güvenlik sistemleri ve enerji emilim optimizasyonu', score: 10),
          Option(text: 'Sadece maliyet azaltımı', score: 0),
          Option(text: 'Sadece ağırlık azaltımı', score: 0),
        ],
        category: 'Ulaşım',
      ),
      Question(
        text: 'Molecular manufacturing (moleküler üretim) araç parçalarında nasıl devrim yaratır?',
        options: [
          Option(text: 'Sadece hız artışı', score: 0),
          Option(text: 'Atom seviyesinde hassas üretim, kendi kendini montaj ve ultra hafif malzemeler', score: 10),
          Option(text: 'Sadece maliyet', score: 0),
          Option(text: 'Sadece kalite', score: 0),
        ],
        category: 'Ulaşım',
      ),
      Question(
        text: 'Swarm intelligence (sürü zekası) araç koordinasyonunda nasıl çalışır?',
        options: [
          Option(text: 'Sadece merkezi kontrol', score: 0),
          Option(text: 'Araçların kendi aralarında koordinasyonu ve toplu davranış optimizasyonu', score: 10),
          Option(text: 'Sadece basit iletişim', score: 0),
          Option(text: 'Sadece mesafe takibi', score: 0),
        ],
        category: 'Ulaşım',
      ),
      Question(
        text: 'Cryogenic technology (kriyojenik teknoloji) gelecek ulaşım sistemlerinde rolü nedir?',
        options: [
          Option(text: 'Sadece soğutma', score: 0),
          Option(text: 'Süper iletken malzemeler, yakıt depolama ve enerji verimliliği', score: 10),
          Option(text: 'Sadece konfor', score: 0),
          Option(text: 'Sadece güvenlik', score: 0),
        ],
        category: 'Ulaşım',
      ),
    ];
  }
}