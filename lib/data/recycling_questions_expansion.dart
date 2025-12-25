// lib/data/recycling_questions_expansion.dart
// Geri Dönüşüm Teması için 200 Ek Soru

import '../models/question.dart';

class RecyclingQuestionsExpansion {
  static List<Question> getTurkishRecyclingQuestions() {
    return [
      // Atık Yönetimi (25 soru)
      Question(
        text: 'Atık yönetiminde hiyerarşi (waste hierarchy) prensibinin ilk adımı nedir?',
        options: [
          Option(text: 'Geri dönüşüm', score: 0),
          Option(text: 'Önleme', score: 10),
          Option(text: 'Yeniden kullanım', score: 0),
          Option(text: 'Enerji geri kazanımı', score: 0),
        ],
        category: 'Geri Dönüşüm',
      ),
      Question(
        text: 'Organik atıkların kompostlaştırılması ile hangi faydalar elde edilir?',
        options: [
          Option(text: 'Sadece atık azaltımı', score: 0),
          Option(text: 'Toprak iyileştirme ve sera gazı azaltımı', score: 10),
          Option(text: 'Sadece enerji üretimi', score: 0),
          Option(text: 'Sadece maliyet azaltımı', score: 0),
        ],
        category: 'Geri Dönüşüm',
      ),
      Question(
        text: 'Endüstriyel atık yönetiminde en iyi uygulama nedir?',
        options: [
          Option(text: 'Sadece bertaraf', score: 0),
          Option(text: 'Atık minimizasyonu ve kaynak geri kazanımı', score: 10),
          Option(text: 'Sadece yakma', score: 0),
          Option(text: 'Sadece depolama', score: 0),
        ],
        category: 'Geri Dönüşüm',
      ),
      Question(
        text: 'Evsel atıkların kaynağında ayrıştırılmasının avantajı nedir?',
        options: [
          Option(text: 'Sadece maliyet azaltımı', score: 0),
          Option(text: 'Geri dönüşüm kalitesini artırma ve çevresel etkiyi azaltma', score: 10),
          Option(text: 'Sadece kolay taşıma', score: 0),
          Option(text: 'Sadece alan tasarrufu', score: 0),
        ],
        category: 'Geri Dönüşüm',
      ),
      Question(
        text: 'Atık yönetiminde extended producer responsibility (genişletilmiş üretici sorumluluğu) nedir?',
        options: [
          Option(text: 'Sadece vergi ödeme', score: 0),
          Option(text: 'Ürünün yaşam döngüsü sonundaki yönetim sorumluluğu', score: 10),
          Option(text: 'Sadece kalite kontrolü', score: 0),
          Option(text: 'Sadece garanti hizmeti', score: 0),
        ],
        category: 'Geri Dönüşüm',
      ),
      Question(
        text: 'Gelişmiş atık yönetim sistemlerinde material recovery facility (MRF) ne işe yarar?',
        options: [
          Option(text: 'Sadece atık yakma', score: 0),
          Option(text: 'Geri dönüştürülebilir malzemeleri ayrıştırma ve işleme', score: 10),
          Option(text: 'Sadece atık depolama', score: 0),
          Option(text: 'Sadece kompost üretimi', score: 0),
        ],
        category: 'Geri Dönüşüm',
      ),
      Question(
        text: 'Atık yönetiminde life cycle thinking (yaşam döngüsü düşüncesi) yaklaşımı nedir?',
        options: [
          Option(text: 'Sadece bertaraf aşaması', score: 0),
          Option(text: 'Ürünün doğumundan ölümüne tüm çevresel etkilerini değerlendirme', score: 10),
          Option(text: 'Sadece üretim aşaması', score: 0),
          Option(text: 'Sadece tüketim aşaması', score: 0),
        ],
        category: 'Geri Dönüşüm',
      ),
      Question(
        text: 'Evsel atıkların mekanik-biyolojik arıtma (MBT) sistemi nasıl çalışır?',
        options: [
          Option(text: 'Sadece mekanik ayrıştırma', score: 0),
          Option(text: 'Fiziksel ayrıştırma ve biyolojik işleme kombinasyonu', score: 10),
          Option(text: 'Sadece biyolojik arıtma', score: 0),
          Option(text: 'Sadece kimyasal arıtma', score: 0),
        ],
        category: 'Geri Dönüşüm',
      ),
      Question(
        text: 'Atık yönetiminde circular economy (döngüsel ekonomi) prensibi nedir?',
        options: [
          Option(text: 'Sadece geri dönüşüm', score: 0),
          Option(text: 'Atıkları kaynağa dönüştürme ve sürekli döngü yaratma', score: 10),
          Option(text: 'Sadece atık azaltımı', score: 0),
          Option(text: 'Sadece enerji geri kazanımı', score: 0),
        ],
        category: 'Geri Dönüşüm',
      ),
      Question(
        text: 'Gıda atığı yönetiminde anaerobic digestion (anaerobik çürütme) nasıl çalışır?',
        options: [
          Option(text: 'Sadece oksijenli çürütme', score: 0),
          Option(text: 'Oksijensiz ortamda metan ve CO₂ üretimi', score: 10),
          Option(text: 'Sadece kompostlaştırma', score: 0),
          Option(text: 'Sadece yakma', score: 0),
        ],
        category: 'Geri Dönüşüm',
      ),
      Question(
        text: 'Atık yönetiminde waste-to-energy (atıktan enerji) teknolojileri nelerdir?',
        options: [
          Option(text: 'Sadece yakma', score: 0),
          Option(text: 'Termal işleme, gazifikasyon ve biyogaz üretimi', score: 10),
          Option(text: 'Sadece biyokütle', score: 0),
          Option(text: 'Sadece fotovoltaik', score: 0),
        ],
        category: 'Geri Dönüşüm',
      ),
      Question(
        text: 'İnşaat ve yıkıntı atıklarının geri dönüşümünde hangi malzemeler elde edilir?',
        options: [
          Option(text: 'Sadece metal', score: 0),
          Option(text: 'Geri dönüştürülmüş agrega ve yeniden kullanılabilir malzemeler', score: 10),
          Option(text: 'Sadece cam', score: 0),
          Option(text: 'Sadece plastik', score: 0),
        ],
        category: 'Geri Dönüşüm',
      ),
      Question(
        text: 'Atık yönetiminde pre-treatment (ön işleme) aşaması nedir?',
        options: [
          Option(text: 'Sadece depolama', score: 0),
          Option(text: 'Ayırma, temizleme ve boyut küçültme işlemleri', score: 10),
          Option(text: 'Sadece taşıma', score: 0),
          Option(text: 'Sadece sıkıştırma', score: 0),
        ],
        category: 'Geri Dönüşüm',
      ),
      Question(
        text: 'Tehlikeli atıkların yönetiminde hangi önlemler alınmalıdır?',
        options: [
          Option(text: 'Sadece ayrı toplama', score: 0),
          Option(text: 'Güvenli depolama, özel taşıma ve lisanslı bertaraf', score: 10),
          Option(text: 'Sadece karıştırma', score: 0),
          Option(text: 'Sadece yakma', score: 0),
        ],
        category: 'Geri Dönüşüm',
      ),
      Question(
        text: 'Atık yönetiminde segregation (ayrıştırma) neden önemlidir?',
        options: [
          Option(text: 'Sadece kolaylık', score: 0),
          Option(text: 'Kirliliği önleme ve geri dönüşüm kalitesini artırma', score: 10),
          Option(text: 'Sadece maliyet azaltımı', score: 0),
          Option(text: 'Sadece alan tasarrufu', score: 0),
        ],
        category: 'Geri Dönüşüm',
      ),
      Question(
        text: 'Evsel atıkların termal arıtma sistemlerinde hangi enerji geri kazanım yöntemleri kullanılır?',
        options: [
          Option(text: 'Sadece buhar üretimi', score: 0),
          Option(text: 'Buhar üretimi, elektrik üretimi ve yakıt gazı üretimi', score: 10),
          Option(text: 'Sadece ısı üretimi', score: 0),
          Option(text: 'Sadece elektrik üretimi', score: 0),
        ],
        category: 'Geri Dönüşüm',
      ),
      Question(
        text: 'Atık yönetiminde source reduction (kaynakta azaltım) stratejileri nelerdir?',
        options: [
          Option(text: 'Sadece geri dönüşüm', score: 0),
          Option(text: 'Tasarım iyileştirmesi, ambalaj azaltımı ve tekrar kullanım', score: 10),
          Option(text: 'Sadece kompostlaştırma', score: 0),
          Option(text: 'Sadece enerji geri kazanımı', score: 0),
        ],
        category: 'Geri Dönüşüm',
      ),
      Question(
        text: 'Atık yönetiminde landfill mining (çöp dağı tarama) nedir?',
        options: [
          Option(text: 'Sadece yeni alan açma', score: 0),
          Option(text: 'Eski çöp alanlarından değerli malzemeleri geri kazanma', score: 10),
          Option(text: 'Sadece genişletme', score: 0),
          Option(text: 'Sadece kapatma', score: 0),
        ],
        category: 'Geri Dönüşüm',
      ),
      Question(
        text: 'Atık yönetiminde quality control (kalite kontrol) neden gereklidir?',
        options: [
          Option(text: 'Sadece maliyet kontrolü', score: 0),
          Option(text: 'Geri dönüştürülen malzemenin kalite standartlarını sağlama', score: 10),
          Option(text: 'Sadece hız kontrolü', score: 0),
          Option(text: 'Sadece miktar kontrolü', score: 0),
        ],
        category: 'Geri Dönüşüm',
      ),
      Question(
        text: 'Endüstriyel atık geri dönüşümünde industrial symbiosis (endüstriyel simbiyoz) nedir?',
        options: [
          Option(text: 'Sadece maliyet paylaşımı', score: 0),
          Option(text: 'Bir endüstrinin atığının diğer endüstrinin hammadde olması', score: 10),
          Option(text: 'Sadece teknoloji paylaşımı', score: 0),
          Option(text: 'Sadece alan paylaşımı', score: 0),
        ],
        category: 'Geri Dönüşüm',
      ),
      Question(
        text: 'Atık yönetiminde environmental management system (çevre yönetim sistemi) nedir?',
        options: [
          Option(text: 'Sadece raporlama', score: 0),
          Option(text: 'Sürekli iyileştirme ve çevresel performans yönetimi', score: 10),
          Option(text: 'Sadece uyumluluk', score: 0),
          Option(text: 'Sadece denetim', score: 0),
        ],
        category: 'Geri Dönüşüm',
      ),
      Question(
        text: 'Atık yönetiminde public-private partnership (kamu-özel ortaklığı) modelinin avantajı nedir?',
        options: [
          Option(text: 'Sadece maliyet azaltımı', score: 0),
          Option(text: 'Teknoloji transferi, finansman ve operasyonel verimlilik', score: 10),
          Option(text: 'Sadece sorumluluk paylaşımı', score: 0),
          Option(text: 'Sadece risk paylaşımı', score: 0),
        ],
        category: 'Geri Dönüşüm',
      ),
      Question(
        text: 'Atık yönetiminde monitoring and evaluation (izleme ve değerlendirme) nasıl yapılır?',
        options: [
          Option(text: 'Sadece miktar takibi', score: 0),
          Option(text: 'Performans göstergeleri, çevresel etkiler ve sürekli iyileştirme', score: 10),
          Option(text: 'Sadece maliyet takibi', score: 0),
          Option(text: 'Sadece zaman takibi', score: 0),
        ],
        category: 'Geri Dönüşüm',
      ),
      Question(
        text: 'Atık yönetiminde behavioral change interventions (davranış değişikliği müdahaleleri) neleri içerir?',
        options: [
          Option(text: 'Sadece bilgilendirme', score: 0),
          Option(text: 'Eğitim, teşvikler, sosyal normlar ve kolaylaştırıcı önlemler', score: 10),
          Option(text: 'Sadece cezalar', score: 0),
          Option(text: 'Sadece vergiler', score: 0),
        ],
        category: 'Geri Dönüşüm',
      ),

      // Geri Dönüştürme Teknolojileri (25 soru)
      Question(
        text: 'Plastik geri dönüşümünde chemical recycling (kimyasal geri dönüşüm) nasıl çalışır?',
        options: [
          Option(text: 'Sadece mekanik işlem', score: 0),
          Option(text: 'Plastikleri monomerlerine ayırarak yeni plastik üretimi', score: 10),
          Option(text: 'Sadece yakma', score: 0),
          Option(text: 'Sadece kompostlaştırma', score: 0),
        ],
        category: 'Geri Dönüşüm',
      ),
      Question(
        text: 'Metal geri dönüşümünde pyrometallurgy (pirometalurji) yöntemi nedir?',
        options: [
          Option(text: 'Sadece düşük sıcaklık işlem', score: 0),
          Option(text: 'Yüksek sıcaklıkta metal eritme ve saflaştırma', score: 10),
          Option(text: 'Sadece elektroliz', score: 0),
          Option(text: 'Sadece mekanik ayrıştırma', score: 0),
        ],
        category: 'Geri Dönüşüm',
      ),
      Question(
        text: 'Cam geri dönüşümünde cullet (kırık cam) kullanımının avantajı nedir?',
        options: [
          Option(text: 'Sadece maliyet artırımı', score: 0),
          Option(text: 'Daha düşük sıcaklıkta eritme ve enerji tasarrufu', score: 10),
          Option(text: 'Sadece kalite artışı', score: 0),
          Option(text: 'Sadece hız artışı', score: 0),
        ],
        category: 'Geri Dönüşüm',
      ),
      Question(
        text: 'Kağıt geri dönüşümünde deinking (mürekkep giderme) işlemi nasıl yapılır?',
        options: [
          Option(text: 'Sadece yıkama', score: 0),
          Option(text: 'Kimyasal ve mekanik yöntemlerle mürekkep ayırma', score: 10),
          Option(text: 'Sadece sıcaklık uygulaması', score: 0),
          Option(text: 'Sadece basınç uygulaması', score: 0),
        ],
        category: 'Geri Dönüşüm',
      ),
      Question(
        text: 'Elektronik atık (e-waste) geri dönüşümünde precious metals recovery (değerli metal geri kazanımı) nasıl yapılır?',
        options: [
          Option(text: 'Sadece ayrıştırma', score: 0),
          Option(text: 'Hidrometalurji ve pirometalurji teknikleri', score: 10),
          Option(text: 'Sadece manyetik ayrım', score: 0),
          Option(text: 'Sadece elektroliz', score: 0),
        ],
        category: 'Geri Dönüşüm',
      ),
      Question(
        text: 'Tekstil geri dönüşümünde fiber-to-fiber (lif-lif) teknolojisi nedir?',
        options: [
          Option(text: 'Sadece yeni lif üretimi', score: 0),
          Option(text: 'Eski tekstillerden yeni tekstil liflerine dönüştürme', score: 10),
          Option(text: 'Sadece enerji üretimi', score: 0),
          Option(text: 'Sadece kompost üretimi', score: 0),
        ],
        category: 'Geri Dönüşüm',
      ),
      Question(
        text: 'Atık yağ geri dönüşümünde biodiesel üretimi nasıl yapılır?',
        options: [
          Option(text: 'Sadece filtreleme', score: 0),
          Option(text: 'Transesterifikasyon reaksiyonu ile kimyasal dönüşüm', score: 10),
          Option(text: 'Sadece distilasyon', score: 0),
          Option(text: 'Sadece kristalizasyon', score: 0),
        ],
        category: 'Geri Dönüşüm',
      ),
      Question(
        text: 'Geri dönüştürülmüş malzemelerin kalitesini artırmak için advanced sorting (gelişmiş ayrıştırma) teknikleri nelerdir?',
        options: [
          Option(text: 'Sadece görsel kontrol', score: 0),
          Option(text: 'Optik ayrıştırma, AI tabanlı tanıma ve spektroskopi', score: 10),
          Option(text: 'Sadece manyetik ayrım', score: 0),
          Option(text: 'Sadece yoğunluk ayrımı', score: 0),
        ],
        category: 'Geri Dönüşüm',
      ),
      Question(
        text: 'Kompozit malzemelerin geri dönüşümünde hangi teknolojiler kullanılır?',
        options: [
          Option(text: 'Sadece mekanik geri dönüşüm', score: 0),
          Option(text: 'Kimyasal çözücüler, termal parçalama ve ileri teknolojiler', score: 10),
          Option(text: 'Sadece yakma', score: 0),
          Option(text: 'Sadece depolama', score: 0),
        ],
        category: 'Geri Dönüşüm',
      ),
      Question(
        text: 'Plastik geri dönüşümünde bioplastics (biyoplastikler) üretimi nasıl yapılır?',
        options: [
          Option(text: 'Sadece petrol bazlı', score: 0),
          Option(text: 'Bitkisel kaynaklardan biyolojik olarak parçalanabilir plastikler', score: 10),
          Option(text: 'Sadece geri dönüştürülmüş plastiğin eritilmesi', score: 0),
          Option(text: 'Sadece kimyasal reaksiyon', score: 0),
        ],
        category: 'Geri Dönüşüm',
      ),
      Question(
        text: 'Atık cam geri dönüşümünde glass-to-glass (cam-cam) teknolojisi nasıl çalışır?',
        options: [
          Option(text: 'Sadece kırma ve eritme', score: 0),
          Option(text: 'Cam parçalarını doğrudan yeni cam üretiminde kullanma', score: 10),
          Option(text: 'Sadece boyama', score: 0),
          Option(text: 'Sadece kaplama', score: 0),
        ],
        category: 'Geri Dönüşüm',
      ),
      Question(
        text: 'Metal geri dönüşümünde hydrometallurgy (hidrometalurji) yöntemi nedir?',
        options: [
          Option(text: 'Sadece su kullanımı', score: 0),
          Option(text: 'Kimyasal çözeltilerle metal çözme ve geri kazanım', score: 10),
          Option(text: 'Sadece mekanik işlem', score: 0),
          Option(text: 'Sadece elektroliz', score: 0),
        ],
        category: 'Geri Dönüşüm',
      ),
      Question(
        text: 'Kağıt geri dönüşümünde pulping (hamurlaştırma) işlemi nedir?',
        options: [
          Option(text: 'Sadece kesme', score: 0),
          Option(text: 'Kağıdı liflerine ayırarak yeniden kağıt hamuru üretme', score: 10),
          Option(text: 'Sadece basınç uygulama', score: 0),
          Option(text: 'Sadece ısıtma', score: 0),
        ],
        category: 'Geri Dönüşüm',
      ),
      Question(
        text: 'Tekstil geri dönüşümünde mechanical recycling (mekanik geri dönüşüm) nasıl çalışır?',
        options: [
          Option(text: 'Sadece yıkama', score: 0),
          Option(text: 'Lifleri mekanik olarak ayırıp yeniden dokuma', score: 10),
          Option(text: 'Sadece kimyasal işlem', score: 0),
          Option(text: 'Sadece ısıl işlem', score: 0),
        ],
        category: 'Geri Dönüşüm',
      ),
      Question(
        text: 'Atık lastik geri dönüşümünde pyrolysis (piroliz) teknolojisi nasıl çalışır?',
        options: [
          Option(text: 'Sadece yakma', score: 0),
          Option(text: 'Oksijensiz ortamda yüksek sıcaklıkta parçalama', score: 10),
          Option(text: 'Sadece öğütme', score: 0),
          Option(text: 'Sadece eritme', score: 0),
        ],
        category: 'Geri Dönüşüm',
      ),
      Question(
        text: 'Geri dönüştürülmüş malzemelerin kalite standardizasyonu nasıl sağlanır?',
        options: [
          Option(text: 'Sadece görsel kontrol', score: 0),
          Option(text: 'Test protokolleri, sertifikasyon ve sürekli kalite kontrolü', score: 10),
          Option(text: 'Sadece ağırlık kontrolü', score: 0),
          Option(text: 'Sadece boyut kontrolü', score: 0),
        ],
        category: 'Geri Dönüşüm',
      ),
      Question(
        text: 'Elektronik atık geri dönüşümünde manual disassembly (manuel söküm) neden tercih edilir?',
        options: [
          Option(text: 'Sadece hız için', score: 0),
          Option(text: 'Değerli bileşenleri korumak ve kirliliği önlemek için', score: 10),
          Option(text: 'Sadece maliyet için', score: 0),
          Option(text: 'Sadece basitlik için', score: 0),
        ],
        category: 'Geri Dönüşüm',
      ),
      Question(
        text: 'Plastik geri dönüşümünde upcycling (değer artırma) nedir?',
        options: [
          Option(text: 'Sadece aynı kalitede ürün', score: 0),
          Option(text: 'Daha yüksek değerli ürünlere dönüştürme', score: 10),
          Option(text: 'Sadece enerji üretimi', score: 0),
          Option(text: 'Sadece hammadde geri kazanımı', score: 0),
        ],
        category: 'Geri Dönüşüm',
      ),
      Question(
        text: 'Metal geri dönüşümünde alloying (alaşım yapma) işlemi nedir?',
        options: [
          Option(text: 'Sadece karıştırma', score: 0),
          Option(text: 'Farklı metalleri birleştirerek özel özellikler elde etme', score: 10),
          Option(text: 'Sadece eritme', score: 0),
          Option(text: 'Sadece soğutma', score: 0),
        ],
        category: 'Geri Dönüşüm',
      ),
      Question(
        text: 'Geri dönüştürülmüş ürünlerin market acceptance (pazar kabulü) nasıl artırılır?',
        options: [
          Option(text: 'Sadece düşük fiyat', score: 0),
          Option(text: 'Kalite güvencesi, sertifikasyon ve tüketici eğitimi', score: 10),
          Option(text: 'Sadece tasarım', score: 0),
          Option(text: 'Sadece reklam', score: 0),
        ],
        category: 'Geri Dönüşüm',
      ),
      Question(
        text: 'Kağıt geri dönüşümünde de-inking efficiency (mürekkep giderme verimi) nasıl artırılır?',
        options: [
          Option(text: 'Sadece daha fazla kimyasal', score: 0),
          Option(text: 'Optimize edilmiş kimyasal formülasyon ve proses parametreleri', score: 10),
          Option(text: 'Sadece daha yüksek sıcaklık', score: 0),
          Option(text: 'Sadece daha uzun süre', score: 0),
        ],
        category: 'Geri Dönüşüm',
      ),
      Question(
        text: 'Atık yönetiminde artificial intelligence (yapay zeka) nasıl kullanılır?',
        options: [
          Option(text: 'Sadece veri toplama', score: 0),
          Option(text: 'Ayrıştırma optimizasyonu, tahmin ve kalite kontrolü', score: 10),
          Option(text: 'Sadece raporlama', score: 0),
          Option(text: 'Sadece faturalama', score: 0),
        ],
        category: 'Geri Dönüşüm',
      ),
      Question(
        text: 'Tekstil geri dönüşümünde chemical recycling (kimyasal geri dönüşüm) nasıl çalışır?',
        options: [
          Option(text: 'Sadece çözücü kullanımı', score: 0),
          Option(text: 'Lifleri kimyasal olarak monomerlere ayırıp yeniden polimerizasyon', score: 10),
          Option(text: 'Sadece ısıl işlem', score: 0),
          Option(text: 'Sadece mekanik işlem', score: 0),
        ],
        category: 'Geri Dönüşüm',
      ),
      Question(
        text: 'Geri dönüştürülmüş malzemelerde contamination (kirlenme) sorunu nasıl önlenir?',
        options: [
          Option(text: 'Sadece temizlik', score: 0),
          Option(text: 'Kaynakta ayrıştırma, ileri temizleme ve kalite kontrolü', score: 10),
          Option(text: 'Sadece filtreleme', score: 0),
          Option(text: 'Sadece yıkama', score: 0),
        ],
        category: 'Geri Dönüşüm',
      ),

      // Sürdürülebilir Yaşam (25 soru)
      Question(
        text: 'Sürdürülebilir yaşamda zero waste (sıfır atık) yaklaşımının ilkeleri nelerdir?',
        options: [
          Option(text: 'Sadece geri dönüşüm', score: 0),
          Option(text: 'Önleme, azaltma, yeniden kullanım ve geri dönüşüm', score: 10),
          Option(text: 'Sadece kompostlaştırma', score: 0),
          Option(text: 'Sadece enerji geri kazanımı', score: 0),
        ],
        category: 'Geri Dönüşüm',
      ),
      Question(
        text: 'Evde plastik atık azaltmak için hangi stratejiler etkilidir?',
        options: [
          Option(text: 'Sadece geri dönüştürme', score: 0),
          Option(text: 'Tek kullanımlık ürünleri azaltma ve tekrar kullanılabilir alternatifler', score: 10),
          Option(text: 'Sadece cam ambalaj', score: 0),
          Option(text: 'Sadece kağıt ambalaj', score: 0),
        ],
        category: 'Geri Dönüşüm',
      ),
      Question(
        text: 'Gıda israfını azaltmak için hangi yöntemler kullanılabilir?',
        options: [
          Option(text: 'Sadece kompostlaştırma', score: 0),
          Option(text: 'Planlı alışveriş, doğru saklama ve porsiyon kontrolü', score: 10),
          Option(text: 'Sadece dondurma', score: 0),
          Option(text: 'Sadece konserve yapma', score: 0),
        ],
        category: 'Geri Dönüşüm',
      ),
      Question(
        text: 'Sürdürülebilir alışveriş yaparken hangi faktörler dikkate alınmalıdır?',
        options: [
          Option(text: 'Sadece fiyat', score: 0),
          Option(text: 'Ambalaj, menşe, üretim süreci ve dayanıklılık', score: 10),
          Option(text: 'Sadece marka', score: 0),
          Option(text: 'Sadece tasarım', score: 0),
        ],
        category: 'Geri Dönüşüm',
      ),
      Question(
        text: 'Evde enerji tasarrufu için hangi atık yönetimi uygulamaları etkilidir?',
        options: [
          Option(text: 'Sadece LED kullanımı', score: 0),
          Option(text: 'Atık ısı geri kazanımı ve verimli cihaz seçimi', score: 10),
          Option(text: 'Sadece yalıtım', score: 0),
          Option(text: 'Sadece güneş paneli', score: 0),
        ],
        category: 'Geri Dönüşüm',
      ),
      Question(
        text: 'Sürdürülebilir moda ve tekstil tüketimi nasıl sağlanır?',
        options: [
          Option(text: 'Sadece ucuz alışveriş', score: 0),
          Option(text: 'Kaliteli, dayanıklı ve geri dönüştürülmüş malzemeler', score: 10),
          Option(text: 'Sadece hızlı moda', score: 0),
          Option(text: 'Sadece marka takibi', score: 0),
        ],
        category: 'Geri Dönüşüm',
      ),
      Question(
        text: 'Evde su tasarrufu ve atık azaltımı nasıl birleştirilebilir?',
        options: [
          Option(text: 'Sadece tasarruflu armatür', score: 0),
          Option(text: 'Yağmur suyu hasadı, gri su sistemleri ve su verimli ürünler', score: 10),
          Option(text: 'Sadece filtre sistemi', score: 0),
          Option(text: 'Sadece sayaç takibi', score: 0),
        ],
        category: 'Geri Dönüşüm',
      ),
      Question(
        text: 'Dijital yaşamda sürdürülebilirlik nasıl sağlanır?',
        options: [
          Option(text: 'Sadece uzun ömürlü cihazlar', score: 0),
          Option(text: 'Cihaz ömrünü uzatma, e-atık geri dönüşümü ve enerji verimli kullanım', score: 10),
          Option(text: 'Sadece bulut depolama', score: 0),
          Option(text: 'Sadece uygulama sayısı azaltma', score: 0),
        ],
        category: 'Geri Dönüşüm',
      ),
      Question(
        text: 'Bahçede sürdürülebilir uygulamalar nelerdir?',
        options: [
          Option(text: 'Sadece kimyasal gübre', score: 0),
          Option(text: 'Kompost, organik tarım ve yerel bitki türleri', score: 10),
          Option(text: 'Sadece sentetik ilaçlar', score: 0),
          Option(text: 'Sadece sulama sistemi', score: 0),
        ],
        category: 'Geri Dönüşüm',
      ),
      Question(
        text: 'Sürdürülebilir ulaşım ve atık ilişkisi nedir?',
        options: [
          Option(text: 'Sadece elektrikli araç', score: 0),
          Option(text: 'Toplu taşıma, bisiklet ve araç paylaşımı ile emisyon azaltımı', score: 10),
          Option(text: 'Sadece hibrit araç', score: 0),
          Option(text: 'Sadece yakıt verimliliği', score: 0),
        ],
        category: 'Geri Dönüşüm',
      ),
      Question(
        text: 'Evde kompostlaştırma sistemi kurarken nelere dikkat edilmeli?',
        options: [
          Option(text: 'Sadece alan', score: 0),
          Option(text: 'Hava akımı, nem dengesi ve doğru oranlama', score: 10),
          Option(text: 'Sadece malzeme seçimi', score: 0),
          Option(text: 'Sadece sıcaklık kontrolü', score: 0),
        ],
        category: 'Geri Dönüşüm',
      ),
      Question(
        text: 'Sürdürülebilir ambalaj seçiminde hangi kriterler önemlidir?',
        options: [
          Option(text: 'Sadece görünüm', score: 0),
          Option(text: 'Geri dönüştürülebilirlik, biyolojik parçalanabilirlik ve minimal ambalaj', score: 10),
          Option(text: 'Sadece dayanıklılık', score: 0),
          Option(text: 'Sadece maliyet', score: 0),
        ],
        category: 'Geri Dönüşüm',
      ),
      Question(
        text: 'Evde kimyasal temizlik ürünleri yerine hangi doğal alternatifler kullanılabilir?',
        options: [
          Option(text: 'Sadece su', score: 0),
          Option(text: 'Sirke, karbonat, limon ve doğal yağlar', score: 10),
          Option(text: 'Sadece deterjan', score: 0),
          Option(text: 'Sadece çamaşır suyu', score: 0),
        ],
        category: 'Geri Dönüşüm',
      ),
      Question(
        text: 'Sürdürülebilir yaşamda enerji verimliliği nasıl artırılır?',
        options: [
          Option(text: 'Sadece cihaz değişimi', score: 0),
          Option(text: 'Yalıtım, verimli cihazlar ve akıllı enerji yönetimi', score: 10),
          Option(text: 'Sadece yenilenebilir enerji', score: 0),
          Option(text: 'Sadece enerji tasarrufu', score: 0),
        ],
        category: 'Geri Dönüşüm',
      ),
      Question(
        text: 'Teknoloji kullanımında e-waste (elektronik atık) azaltma stratejileri nelerdir?',
        options: [
          Option(text: 'Sadece geri dönüşüm', score: 0),
          Option(text: 'Uzun ömürlü ürünler, tamir etme ve paylaşım kültürü', score: 10),
          Option(text: 'Sadece ikinci el', score: 0),
          Option(text: 'Sadece garanti', score: 0),
        ],
        category: 'Geri Dönüşüm',
      ),
      Question(
        text: 'Evde sürdürülebilir mutfak uygulamaları nelerdir?',
        options: [
          Option(text: 'Sadece organik ürün', score: 0),
          Option(text: 'Yerel ürünler, mevsimsel beslenme ve atık minimizasyonu', score: 10),
          Option(text: 'Sadece vegan beslenme', score: 0),
          Option(text: 'Sadece düşük kalorili', score: 0),
        ],
        category: 'Geri Dönüşüm',
      ),
      Question(
        text: 'Sürdürülebilir yaşamda toplumsal etki nasıl yaratılır?',
        options: [
          Option(text: 'Sadece bireysel çaba', score: 0),
          Option(text: 'Topluluk projeleri, bilgi paylaşımı ve örnek olma', score: 10),
          Option(text: 'Sadece sosyal medya', score: 0),
          Option(text: 'Sadece kampanya', score: 0),
        ],
        category: 'Geri Dönüşüm',
      ),
      Question(
        text: 'Evde atık azaltma ve değerlendirme stratejileri nasıl planlanır?',
        options: [
          Option(text: 'Sadece pratik uygulamalar', score: 0),
          Option(text: 'Hedef belirleme, izleme ve sürekli iyileştirme', score: 10),
          Option(text: 'Sadece teknik çözümler', score: 0),
          Option(text: 'Sadece maliyet hesabı', score: 0),
        ],
        category: 'Geri Dönüşüm',
      ),
      Question(
        text: 'Sürdürülebilir yaşamda çocuk eğitimi nasıl yapılır?',
        options: [
          Option(text: 'Sadece teorik bilgi', score: 0),
          Option(text: 'Pratik uygulamalar, oyunlaştırma ve rol model olma', score: 10),
          Option(text: 'Sadece cezalandırma', score: 0),
          Option(text: 'Sadece ödüllendirme', score: 0),
        ],
        category: 'Geri Dönüşüm',
      ),
      Question(
        text: 'Evde sürdürülebilir mobilya ve dekorasyon seçimi nasıl yapılır?',
        options: [
          Option(text: 'Sadece ucuz ürünler', score: 0),
          Option(text: 'Dayanıklı, geri dönüştürülmüş ve ikinci el seçenekler', score: 10),
          Option(text: 'Sadece moda trendler', score: 0),
          Option(text: 'Sadece lüks ürünler', score: 0),
        ],
        category: 'Geri Dönüşüm',
      ),
      Question(
        text: 'Sürdürülebilir yaşamda finansal planlama nasıl yapılır?',
        options: [
          Option(text: 'Sadece tasarruf', score: 0),
          Option(text: 'Uzun vadeli yatırım, etik tüketim ve maliyet-fayda analizi', score: 10),
          Option(text: 'Sadece borçlanma', score: 0),
          Option(text: 'Sadece kredi kullanımı', score: 0),
        ],
        category: 'Geri Dönüşüm',
      ),
      Question(
        text: 'Evde sağlıklı yaşam ve sürdürülebilirlik nasıl birleştirilebilir?',
        options: [
          Option(text: 'Sadece doğal ürünler', score: 0),
          Option(text: 'Temiz hava, toksin azaltımı ve çevre dostu yaşam alanları', score: 10),
          Option(text: 'Sadece spor', score: 0),
          Option(text: 'Sadece beslenme', score: 0),
        ],
        category: 'Geri Dönüşüm',
      ),
      Question(
        text: 'Sürdürülebilir yaşamda teknoloji destekli çözümler nelerdir?',
        options: [
          Option(text: 'Sadece akıllı ev sistemi', score: 0),
          Option(text: 'Enerji izleme, atık takibi ve sürdürülebilirlik uygulamaları', score: 10),
          Option(text: 'Sadece robot temizlik', score: 0),
          Option(text: 'Sadece otomasyon', score: 0),
        ],
        category: 'Geri Dönüşüm',
      ),

      // Çevre Koruma ve Teknoloji (25 soru)
      Question(
        text: 'Plastik kirliliğinin okyanuslara etkileri nelerdir?',
        options: [
          Option(text: 'Sadece görsel kirlilik', score: 0),
          Option(text: 'Deniz yaşamına zarar, besin zinciri kirliliği ve mikroplastik', score: 10),
          Option(text: 'Sadece balık ölümü', score: 0),
          Option(text: 'Sadece kıyı erozyonu', score: 0),
        ],
        category: 'Geri Dönüşüm',
      ),
      Question(
        text: 'Microplastics (mikroplastikler) sorunu nasıl çözülür?',
        options: [
          Option(text: 'Sadece filtre sistemleri', score: 0),
          Option(text: 'Kaynak azaltımı, ileri arıtma teknolojileri ve politika değişiklikleri', score: 10),
          Option(text: 'Sadece temizlik', score: 0),
          Option(text: 'Sadece yasaklama', score: 0),
        ],
        category: 'Geri Dönüşüm',
      ),
      Question(
        text: 'Ocean cleanup projelerinde hangi teknolojiler kullanılır?',
        options: [
          Option(text: 'Sadece ağ sistemleri', score: 0),
          Option(text: 'Yüzen bariyerler, otomatik toplama sistemleri ve çevre dostu yöntemler', score: 10),
          Option(text: 'Sadece drone', score: 0),
          Option(text: 'Sadece gemi', score: 0),
        ],
        category: 'Geri Dönüşüm',
      ),
      Question(
        text: 'Plastik atıklarının deniz ekosistemlerine etkilerini azaltmak için neler yapılabilir?',
        options: [
          Option(text: 'Sadece yasaklama', score: 0),
          Option(text: 'Alternatif malzemeler, geri dönüşüm sistemleri ve eğitim programları', score: 10),
          Option(text: 'Sadece temizlik', score: 0),
          Option(text: 'Sadece cezalar', score: 0),
        ],
        category: 'Geri Dönüşüm',
      ),
      Question(
        text: 'Geri dönüştürülmüş malzemelerin kalitesini artırmak için advanced sorting (gelişmiş ayrıştırma) teknikleri nelerdir?',
        options: [
          Option(text: 'Sadece görsel kontrol', score: 0),
          Option(text: 'AI destekli tanıma, spektroskopi ve sensör teknolojileri', score: 10),
          Option(text: 'Sadece manyetik ayrım', score: 0),
          Option(text: 'Sadece yoğunluk ayrımı', score: 0),
        ],
        category: 'Geri Dönüşüm',
      ),
      Question(
        text: 'Plastik geri dönüşümünde bio-based alternatives (biyobazlı alternatifler) nelerdir?',
        options: [
          Option(text: 'Sadece bitki bazlı', score: 0),
          Option(text: 'PLA, PHA ve diğer biyolojik olarak parçalanabilir polimerler', score: 10),
          Option(text: 'Sadece geri dönüştürülmüş', score: 0),
          Option(text: 'Sadece kompozit malzemeler', score: 0),
        ],
        category: 'Geri Dönüşüm',
      ),
      Question(
        text: 'Atık yönetiminde IoT (Internet of Things) teknolojileri nasıl kullanılır?',
        options: [
          Option(text: 'Sadece izleme', score: 0),
          Option(text: 'Akıllı çöp kutuları, optimizasyon algoritmaları ve veri analizi', score: 10),
          Option(text: 'Sadece otomatik toplama', score: 0),
          Option(text: 'Sadece GPS takibi', score: 0),
        ],
        category: 'Geri Dönüşüm',
      ),
      Question(
        text: 'Blockchain teknolojisi atık yönetiminde nasıl kullanılabilir?',
        options: [
          Option(text: 'Sadece dijital para', score: 0),
          Option(text: 'İzlenebilirlik, şeffaflık ve otomatik ödeme sistemleri', score: 10),
          Option(text: 'Sadece raporlama', score: 0),
          Option(text: 'Sadece sözleşmeler', score: 0),
        ],
        category: 'Geri Dönüşüm',
      ),
      Question(
        text: 'Geri dönüştürülmüş malzemelerin market acceptance (pazar kabulü) nasıl artırılır?',
        options: [
          Option(text: 'Sadece düşük fiyat', score: 0),
          Option(text: 'Kalite güvencesi, sertifikasyon ve tüketici eğitimi', score: 10),
          Option(text: 'Sadece tasarım', score: 0),
          Option(text: 'Sadece reklam', score: 0),
        ],
        category: 'Geri Dönüşüm',
      ),
      Question(
        text: 'Atık yönetiminde predictive analytics (tahmine dayalı analitik) nasıl kullanılır?',
        options: [
          Option(text: 'Sadece geçmiş veri', score: 0),
          Option(text: 'Atık miktarı tahmini, optimizasyon ve kaynak planlaması', score: 10),
          Option(text: 'Sadece raporlama', score: 0),
          Option(text: 'Sadece maliyet analizi', score: 0),
        ],
        category: 'Geri Dönüşüm',
      ),
      Question(
        text: 'Plastik kirliliğini azaltmak için extended producer responsibility (genişletilmiş üretici sorumluluğu) nasıl uygulanır?',
        options: [
          Option(text: 'Sadece vergi ödeme', score: 0),
          Option(text: 'Ürün tasarımından bertarfa tüm sorumluluğu üstlenme', score: 10),
          Option(text: 'Sadece geri dönüşüm katkı payı', score: 0),
          Option(text: 'Sadece bilgilendirme', score: 0),
        ],
        category: 'Geri Dönüşüm',
      ),
      Question(
        text: 'Geri dönüştürülmüş ürünlerde quality assurance (kalite güvencesi) nasıl sağlanır?',
        options: [
          Option(text: 'Sadece görsel kontrol', score: 0),
          Option(text: 'Test protokolleri, standartlar ve sürekli izleme', score: 10),
          Option(text: 'Sadece sertifika', score: 0),
          Option(text: 'Sadece garanti', score: 0),
        ],
        category: 'Geri Dönüşüm',
      ),
      Question(
        text: 'Atık yönetiminde automation (otomasyon) hangi alanlarda kullanılır?',
        options: [
          Option(text: 'Sadece taşıma', score: 0),
          Option(text: 'Ayrıştırma, sıkıştırma, izleme ve optimizasyon', score: 10),
          Option(text: 'Sadece depolama', score: 0),
          Option(text: 'Sadece raporlama', score: 0),
        ],
        category: 'Geri Dönüşüm',
      ),
      Question(
        text: 'Sürdürülebilir ambalaj tasarımında design for recycling (geri dönüşüm için tasarım) prensipleri nelerdir?',
        options: [
          Option(text: 'Sadece malzeme seçimi', score: 0),
          Option(text: 'Tek malzeme, kolay ayrıştırma ve etiketleme standartları', score: 10),
          Option(text: 'Sadece boyut optimizasyonu', score: 0),
          Option(text: 'Sadece maliyet azaltımı', score: 0),
        ],
        category: 'Geri Dönüşüm',
      ),
      Question(
        text: 'Atık yönetiminde circular economy business models (döngüsel ekonomi iş modelleri) nelerdir?',
        options: [
          Option(text: 'Sadece geri dönüşüm', score: 0),
          Option(text: 'Product-as-a-service, remanufacturing ve material recovery', score: 10),
          Option(text: 'Sadece enerji geri kazanımı', score: 0),
          Option(text: 'Sadece atık azaltımı', score: 0),
        ],
        category: 'Geri Dönüşüm',
      ),
      Question(
        text: 'Geri dönüştürülmüş malzemelerin traceable supply chains (izlenebilir tedarik zinciri) nasıl sağlanır?',
        options: [
          Option(text: 'Sadece kağıt işlemler', score: 0),
          Option(text: 'Dijital izleme, blockchain ve sertifikasyon sistemleri', score: 10),
          Option(text: 'Sadece barkod', score: 0),
          Option(text: 'Sadece veritabanı', score: 0),
        ],
        category: 'Geri Dönüşüm',
      ),
      Question(
        text: 'Atık yönetiminde green technology innovations (yeşil teknoloji yenilikleri) nelerdir?',
        options: [
          Option(text: 'Sadece enerji verimli makineler', score: 0),
          Option(text: 'Biyolojik arıtma, AI optimizasyon ve ileri malzeme teknolojileri', score: 10),
          Option(text: 'Sadece robotik', score: 0),
          Option(text: 'Sadece sensör teknolojisi', score: 0),
        ],
        category: 'Geri Dönüşüm',
      ),
      Question(
        text: 'Plastik atıkların environmental impact assessment (çevresel etki değerlendirmesi) nasıl yapılır?',
        options: [
          Option(text: 'Sadece miktar ölçümü', score: 0),
          Option(text: 'Yaşam döngüsü analizi, ekosistem etkisi ve uzun vadeli sonuçlar', score: 10),
          Option(text: 'Sadece maliyet hesabı', score: 0),
          Option(text: 'Sadece görsel etki', score: 0),
        ],
        category: 'Geri Dönüşüm',
      ),
      Question(
        text: 'Geri dönüştürülmüş ürünlerin consumer trust (tüketici güveni) nasıl kazanılır?',
        options: [
          Option(text: 'Sadece düşük fiyat', score: 0),
          Option(text: 'Şeffaflık, kalite garantisi ve sosyal sorumluluk kanıtları', score: 10),
          Option(text: 'Sadece güzel ambalaj', score: 0),
          Option(text: 'Sadece reklam kampanyası', score: 0),
        ],
        category: 'Geri Dönüşüm',
      ),
      Question(
        text: 'Atık yönetiminde performance metrics (performans göstergeleri) nelerdir?',
        options: [
          Option(text: 'Sadece toplanan miktar', score: 0),
          Option(text: 'Geri dönüşüm oranı, maliyet verimliliği ve çevresel etki', score: 10),
          Option(text: 'Sadece müşteri memnuniyeti', score: 0),
          Option(text: 'Sadece çalışan sayısı', score: 0),
        ],
        category: 'Geri Dönüşüm',
      ),
      Question(
        text: 'Plastik kirliliğini önlemek için behavioral change interventions (davranış değişikliği müdahaleleri) nelerdir?',
        options: [
          Option(text: 'Sadece bilgilendirme', score: 0),
          Option(text: 'Eğitim, teşvikler, sosyal normlar ve kolaylaştırıcı önlemler', score: 10),
          Option(text: 'Sadece cezalar', score: 0),
          Option(text: 'Sadece yasaklar', score: 0),
        ],
        category: 'Geri Dönüşüm',
      ),
      Question(
        text: 'Geri dönüştürülmüş malzemelerin standardization (standardizasyon) süreci nasıl çalışır?',
        options: [
          Option(text: 'Sadece kalite kontrolü', score: 0),
          Option(text: 'Uluslararası standartlar, test protokolleri ve sertifikasyon', score: 10),
          Option(text: 'Sadece boyut standardı', score: 0),
          Option(text: 'Sadece malzeme standardı', score: 0),
        ],
        category: 'Geri Dönüşüm',
      ),
      Question(
        text: 'Atık yönetiminde sustainable innovation (sürdürülebilir yenilik) nasıl teşvik edilir?',
        options: [
          Option(text: 'Sadece araştırma fonları', score: 0),
          Option(text: 'Teşvik sistemleri, işbirliği platformları ve başarı hikayeleri', score: 10),
          Option(text: 'Sadece patent koruması', score: 0),
          Option(text: 'Sadece vergi avantajı', score: 0),
        ],
        category: 'Geri Dönüşüm',
      ),
    ];
  }
}