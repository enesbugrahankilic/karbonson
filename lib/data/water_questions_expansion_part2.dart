// lib/data/water_questions_expansion_part2.dart
// Su Teması için Kalan 125 Soru

import '../models/question.dart';
import '../services/language_service.dart';

class WaterQuestionsExpansionPart2 {
  static List<Question> getTurkishWaterQuestionsPart2() {
    return [
      // Su Politikası ve Yönetimi (25 soru)
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

      // Su Teknolojisi (25 soru)
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
}