// lib/data/energy_questions_expansion.dart
// Enerji Teması için 200 Ek Soru

import '../models/question.dart';
import '../services/language_service.dart';

class EnergyQuestionsExpansion {
  static List<Question> getTurkishEnergyQuestions() {
    return [
      // Güneş Enerjisi (25 soru)
      Question(
        text: 'Güneş paneli verimliliğini etkileyen en önemli faktör nedir?',
        options: [
          Option(text: 'Panelin rengi', score: 0),
          Option(text: 'Güneş ışığı açısı ve yoğunluğu', score: 10),
          Option(text: 'Panelin boyutu', score: 5),
          Option(text: 'Panelin ağırlığı', score: 0),
        ],
        category: 'Enerji',
      ),
      Question(
        text: 'Fotovoltaik hücreler hangi enerji türünü doğrudan elektrik enerjisine çevirir?',
        options: [
          Option(text: 'Isı enerjisi', score: 0),
          Option(text: 'Işık enerjisi', score: 10),
          Option(text: 'Ses enerjisi', score: 0),
          Option(text: 'Kinetik enerji', score: 0),
        ],
        category: 'Enerji',
      ),
      Question(
        text: 'Güneş enerjisi sistemlerinde inverter ne işe yarar?',
        options: [
          Option(text: 'Enerji üretir', score: 0),
          Option(text: 'DC elektriği AC elektriğe çevirir', score: 10),
          Option(text: 'Enerji depolar', score: 0),
          Option(text: 'Sistemi soğutur', score: 0),
        ],
        category: 'Enerji',
      ),
      Question(
        text: 'Güneş enerjisi santrallerinde en yaygın kullanılan teknoloji hangisidir?',
        options: [
          Option(text: 'Konsantrasyon güneş enerjisi (CSP)', score: 5),
          Option(text: 'Fotovoltaik (PV) paneller', score: 10),
          Option(text: 'Güneş ocakları', score: 0),
          Option(text: 'Güneş bacaları', score: 0),
        ],
        category: 'Enerji',
      ),
      Question(
        text: 'Güneş paneli temizliği ne sıklıkla yapılmalıdır?',
        options: [
          Option(text: 'Her gün', score: 0),
          Option(text: 'Haftada bir', score: 0),
          Option(text: 'Ayda bir veya ihtiyaç halinde', score: 10),
          Option(text: 'Yılda bir', score: 0),
        ],
        category: 'Enerji',
      ),
      Question(
        text: 'Güneş enerjisi sistemlerinde net ölçüm (net metering) nedir?',
        options: [
          Option(text: 'Üretilen enerjiyi ölçer', score: 5),
          Option(text: 'Fazla enerjiyi şebekeye satma imkanı', score: 10),
          Option(text: 'Sistem verimliliğini ölçer', score: 5),
          Option(text: 'Güneş şiddetini ölçer', score: 0),
        ],
        category: 'Enerji',
      ),
      Question(
        text: 'Güneş paneli sistemlerinde backup (yedek) sistem neden gereklidir?',
        options: [
          Option(text: 'Geceleri enerji sağlamak için', score: 10),
          Option(text: 'Sistem maliyetini azaltmak için', score: 0),
          Option(text: 'Panel ömrünü uzatmak için', score: 0),
          Option(text: 'Gürültüyü azaltmak için', score: 0),
        ],
        category: 'Enerji',
      ),
      Question(
        text: 'Güneş enerjisi sistemlerinde maksimum güç noktası takip sistemi (MPPT) ne işe yarar?',
        options: [
          Option(text: 'Enerji depolama kapasitesini artırır', score: 0),
          Option(text: 'Panelin maksimum enerji üretim noktasını bulur', score: 10),
          Option(text: 'Sistem güvenliğini sağlar', score: 0),
          Option(text: 'Panel sıcaklığını kontrol eder', score: 0),
        ],
        category: 'Enerji',
      ),
      Question(
        text: 'Güneş paneli verimliliği genellikle yüzde kaç arasında değişir?',
        options: [
          Option(text: '%5-10', score: 0),
          Option(text: '%15-22', score: 10),
          Option(text: '%50-60', score: 0),
          Option(text: '%80-90', score: 0),
        ],
        category: 'Enerji',
      ),
      Question(
        text: 'Güneş enerjisi sistemlerinde en yaygın kullanılan panel türü hangisidir?',
        options: [
          Option(text: 'Ince film paneller', score: 5),
          Option(text: 'Kristal silikon paneller', score: 10),
          Option(text: 'Boya bazlı paneller', score: 0),
          Option(text: 'Sıvı bazlı paneller', score: 0),
        ],
        category: 'Enerji',
      ),
      Question(
        text: 'Güneş paneli kurulumunda en uygun çatı yönü hangisidir?',
        options: [
          Option(text: 'Kuzey', score: 0),
          Option(text: 'Güney (kuzey yarımküre)', score: 10),
          Option(text: 'Doğu', score: 0),
          Option(text: 'Batı', score: 0),
        ],
        category: 'Enerji',
      ),
      Question(
        text: 'Güneş enerjisi sistemlerinde sistem maliyetini etkileyen en önemli faktör hangisidir?',
        options: [
          Option(text: 'Panel rengi', score: 0),
          Option(text: 'Sistem kapasitesi (kW)', score: 10),
          Option(text: 'Panel sayısı', score: 5),
          Option(text: 'Kablo uzunluğu', score: 0),
        ],
        category: 'Enerji',
      ),
      Question(
        text: 'Güneş paneli üretim sürecinde en çok hangi malzeme kullanılır?',
        options: [
          Option(text: 'Bakır', score: 0),
          Option(text: 'Silisyum', score: 10),
          Option(text: 'Alüminyum', score: 5),
          Option(text: 'Çelik', score: 0),
        ],
        category: 'Enerji',
      ),
      Question(
        text: 'Güneş enerjisi sistemlerinde kullanılan akülerin ömrü genellikle kaç yıldır?',
        options: [
          Option(text: '2-3 yıl', score: 0),
          Option(text: '5-10 yıl', score: 10),
          Option(text: '15-20 yıl', score: 5),
          Option(text: '25-30 yıl', score: 0),
        ],
        category: 'Enerji',
      ),
      Question(
        text: 'Güneş paneli sistemlerinde şebeke bağlantısı olmayan (off-grid) sistemlerde ne gereklidir?',
        options: [
          Option(text: 'İnverter', score: 5),
          Option(text: 'Akü sistemi', score: 10),
          Option(text: 'Jeneratör', score: 0),
          Option(text: 'Transformator', score: 0),
        ],
        category: 'Enerji',
      ),
      Question(
        text: 'Güneş enerjisi maliyetlerindeki düşüşün ana nedeni nedir?',
        options: [
          Option(text: 'Teknolojik gelişmeler ve üretim artışı', score: 10),
          Option(text: 'Devlet teşviklerinin artması', score: 5),
          Option(text: 'Panel boyutlarının küçülmesi', score: 0),
          Option(text: 'Kurulum maliyetlerinin azalması', score: 0),
        ],
        category: 'Enerji',
      ),
      Question(
        text: 'Güneş paneli sistemlerinde kar tutulumu enerji üretimini nasıl etkiler?',
        options: [
          Option(text: 'Hiç etkilemez', score: 0),
          Option(text: 'Üretimi tamamen durdurur', score: 0),
          Option(text: 'Üretimi önemli ölçüde azaltır', score: 10),
          Option(text: 'Üretimi artırır', score: 0),
        ],
        category: 'Enerji',
      ),
      Question(
        text: 'Güneş enerjisi sistemlerinde güvenlik için hangi ekipman kullanılır?',
        options: [
          Option(text: 'Sigorta sistemi', score: 10),
          Option(text: 'Soğutucu sistem', score: 0),
          Option(text: 'Filtre sistemi', score: 0),
          Option(text: 'Yükseltici sistem', score: 0),
        ],
        category: 'Enerji',
      ),
      Question(
        text: 'Güneş paneli üretiminde çevre dostu üretim yöntemleri nelerdir?',
        options: [
          Option(text: 'Geri dönüştürülmüş malzeme kullanımı', score: 10),
          Option(text: 'Kimyasal prosesler', score: 0),
          Option(text: 'Yüksek sıcaklık işlemleri', score: 0),
          Option(text: 'Plastik bazlı üretim', score: 0),
        ],
        category: 'Enerji',
      ),
      Question(
        text: 'Güneş enerjisi sistemlerinde yıllık bakım gereksinimleri nelerdir?',
        options: [
          Option(text: 'Panel temizliği ve bağlantı kontrolü', score: 10),
          Option(text: 'Panel değişimi', score: 0),
          Option(text: 'Sistem tamamen yenileme', score: 0),
          Option(text: 'Kablo değişimi', score: 0),
        ],
        category: 'Enerji',
      ),
      Question(
        text: 'Güneş paneli performansını etkileyen sıcaklık faktörü hakkında hangisi doğrudur?',
        options: [
          Option(text: 'Sıcaklık artışı verimliliği artırır', score: 0),
          Option(text: 'Yüksek sıcaklık verimliliği azaltır', score: 10),
          Option(text: 'Sıcaklık verimliliği etkilemez', score: 0),
          Option(text: 'Çok düşük sıcaklık verimliliği artırır', score: 0),
        ],
        category: 'Enerji',
      ),
      Question(
        text: 'Güneş enerjisi sistemlerinde kullanılan monokristal panellerin avantajı nedir?',
        options: [
          Option(text: 'Daha düşük maliyet', score: 0),
          Option(text: 'Daha yüksek verimlilik', score: 10),
          Option(text: 'Daha hafif yapı', score: 5),
          Option(text: 'Daha kolay kurulum', score: 0),
        ],
        category: 'Enerji',
      ),
      Question(
        text: 'Güneş paneli sistemlerinde sistem izleme (monitoring) neden önemlidir?',
        options: [
          Option(text: 'Enerji tasarrufu sağlar', score: 0),
          Option(text: 'Sistem performansını takip etmek için', score: 10),
          Option(text: 'Maliyet azaltımı sağlar', score: 0),
          Option(text: 'Güvenlik sağlar', score: 0),
        ],
        category: 'Enerji',
      ),
      Question(
        text: 'Güneş enerjisi üretiminde enerji geri ödeme süresi nedir?',
        options: [
          Option(text: 'Sistemin üretim maliyetini karşıladığı süre', score: 10),
          Option(text: 'Garanti süresi', score: 0),
          Option(text: 'Kurulum süresi', score: 0),
          Option(text: 'Bakım süresi', score: 0),
        ],
        category: 'Enerji',
      ),
      Question(
        text: 'Güneş paneli sistemlerinde hibrit sistem yaklaşımı nedir?',
        options: [
          Option(text: 'Sadece güneş enerjisi kullanımı', score: 0),
          Option(text: 'Güneş + rüzgar veya diğer kaynak kombinasyonu', score: 10),
          Option(text: 'Sadece şebeke bağlantısı', score: 0),
          Option(text: 'Sadece akü sistemi', score: 0),
        ],
        category: 'Enerji',
      ),

      // Rüzgar Enerjisi (25 soru)
      Question(
        text: 'Rüzgar enerjisi sistemlerinde türbin kanatlarının aerodynamik tasarımı neden önemlidir?',
        options: [
          Option(text: 'Gürültüyü artırmak için', score: 0),
          Option(text: 'Verimliliği maksimize etmek için', score: 10),
          Option(text: 'Maliyeti azaltmak için', score: 0),
          Option(text: 'Dayanıklılığı artırmak için', score: 0),
        ],
        category: 'Enerji',
      ),
      Question(
        text: 'Rüzgar enerjisi üretimi için ideal rüzgar hızı aralığı nedir?',
        options: [
          Option(text: '1-5 m/s', score: 0),
          Option(text: '6-25 m/s', score: 10),
          Option(text: '26-40 m/s', score: 0),
          Option(text: '41-60 m/s', score: 0),
        ],
        category: 'Enerji',
      ),
      Question(
        text: 'Rüzgar türbinlerinde güç katsayısı (Cp) neyi ifade eder?',
        options: [
          Option(text: 'Türbin maliyeti', score: 0),
          Option(text: 'Rüzgar enerjisinin elektrik enerjisine dönüşüm verimi', score: 10),
          Option(text: 'Türbin boyutu', score: 0),
          Option(text: 'Kurulum süresi', score: 0),
        ],
        category: 'Enerji',
      ),
      Question(
        text: 'Rüzgar enerjisi sistemlerinde kullanılan gearbox (dişli kutusu) hangi fonksiyonu yerine getirir?',
        options: [
          Option(text: 'Rüzgar yönünü değiştirir', score: 0),
          Option(text: 'Yavaş dönen mili hızlı jeneratöre bağlar', score: 10),
          Option(text: 'Enerji depolar', score: 0),
          Option(text: 'Sistemi soğutur', score: 0),
        ],
        category: 'Enerji',
      ),
      Question(
        text: 'Rüzgar türbini kurulumu için en uygun arazi tipi hangisidir?',
        options: [
          Option(text: 'Çok engebeli arazi', score: 0),
          Option(text: 'Açık, düz ve rüzgarın engelsiz estiği alanlar', score: 10),
          Option(text: 'Ormanlık alan', score: 0),
          Option(text: 'Şehir merkezi', score: 0),
        ],
        category: 'Enerji',
      ),
      Question(
        text: 'Rüzgar enerjisi sistemlerinde nacelle (gövde) hangi parçaları barındırır?',
        options: [
          Option(text: 'Sadece kanatlar', score: 0),
          Option(text: 'Jeneratör, dişli kutusu ve kontrol sistemleri', score: 10),
          Option(text: 'Sadece motor', score: 0),
          Option(text: 'Sadece elektronik kontrol', score: 0),
        ],
        category: 'Enerji',
      ),
      Question(
        text: 'Rüzgar türbinlerinde rotor çapının büyümesi neyi artırır?',
        options: [
          Option(text: 'Sadece maliyeti', score: 0),
          Option(text: 'Enerji üretim kapasitesi', score: 10),
          Option(text: 'Sadece görsel etki', score: 0),
          Option(text: 'Sadece bakım gereksinimi', score: 0),
        ],
        category: 'Enerji',
      ),
      Question(
        text: 'Rüzgar enerjisi sistemlerinde aktif yönlendirme (active yaw) sistemi ne işe yarar?',
        options: [
          Option(text: 'Türbini güvenli modda tutar', score: 0),
          Option(text: 'Türbini rüzgar yönüne doğru hizalar', score: 10),
          Option(text: 'Enerji depolama yapar', score: 0),
          Option(text: 'Sistemi soğutur', score: 0),
        ],
        category: 'Enerji',
      ),
      Question(
        text: 'Rüzgar türbinlerinde kullanılan pervanelerin malzemesi genellikle nedir?',
        options: [
          Option(text: 'Çelik', score: 0),
          Option(text: 'Fiberglass veya karbon fiber', score: 10),
          Option(text: 'Alüminyum', score: 5),
          Option(text: 'Plastik', score: 0),
        ],
        category: 'Enerji',
      ),
      Question(
        text: 'Rüzgar enerjisi sistemlerinde cut-in speed (başlama hızı) nedir?',
        options: [
          Option(text: 'Maksimum güvenli çalışma hızı', score: 0),
          Option(text: 'Türbinin enerji üretmeye başladığı minimum hız', score: 10),
          Option(text: 'En yüksek üretim hızı', score: 0),
          Option(text: 'Kapatma hızı', score: 0),
        ],
        category: 'Enerji',
      ),
      Question(
        text: 'Rüzgar türbini kurulumunda kule yüksekliğinin önemi nedir?',
        options: [
          Option(text: 'Sadece estetik görünüm için', score: 0),
          Option(text: 'Rüzgar hızının yükseklikle artması nedeniyle', score: 10),
          Option(text: 'Maliyet tasarrufu için', score: 0),
          Option(text: 'Güvenlik için', score: 0),
        ],
        category: 'Enerji',
      ),
      Question(
        text: 'Rüzgar enerjisi sistemlerinde offshore (deniz üstü) kurulumların avantajı nedir?',
        options: [
          Option(text: 'Daha düşük kurulum maliyeti', score: 0),
          Option(text: 'Daha güçlü ve sürekli rüzgar kaynakları', score: 10),
          Option(text: 'Daha kolay bakım erişimi', score: 0),
          Option(text: 'Daha az çevresel etki', score: 0),
        ],
        category: 'Enerji',
      ),
      Question(
        text: 'Rüzgar türbinlerinde kullanılan frekans invertörünün görevi nedir?',
        options: [
          Option(text: 'Rüzgar hızını ölçmek', score: 0),
          Option(text: 'Değişken frekanslı AC elektriği sabit frekansa çevirmek', score: 10),
          Option(text: 'Enerji depolamak', score: 0),
          Option(text: 'Sistemi korumak', score: 0),
        ],
        category: 'Enerji',
      ),
      Question(
        text: 'Rüzgar enerjisi sistemlerinde rüzgar ölçüm (wind assessment) neden kritiktir?',
        options: [
          Option(text: 'Maliyet hesabı için', score: 0),
          Option(text: 'Proje ekonomik fizibilitesini belirlemek için', score: 10),
          Option(text: 'Yasal izinler için', score: 0),
          Option(text: 'Teknik tasarım için', score: 5),
        ],
        category: 'Enerji',
      ),
      Question(
        text: 'Rüzgar türbinlerinde güvenlik sistemleri hangi durumlarda devreye girer?',
        options: [
          Option(text: 'Sadece rüzgar hızının çok yüksek olduğu durumlarda', score: 10),
          Option(text: 'Sadece arıza durumlarında', score: 5),
          Option(text: 'Sadece bakım zamanlarında', score: 0),
          Option(text: 'Sadece gece saatlerinde', score: 0),
        ],
        category: 'Enerji',
      ),
      Question(
        text: 'Rüzgar enerjisi sistemlerinde kullanılan SCADA sistemi ne işe yarar?',
        options: [
          Option(text: 'Enerji depolama kontrolü', score: 0),
          Option(text: 'Uzaktan sistem izleme ve kontrol', score: 10),
          Option(text: 'Rüzgar ölçümü', score: 0),
          Option(text: 'Elektrik kalite kontrolü', score: 0),
        ],
        category: 'Enerji',
      ),
      Question(
        text: 'Rüzgar türbinlerinde kullanılan pitch control (kanat açısı kontrolü) sistemi ne için kullanılır?',
        options: [
          Option(text: 'Gürültü kontrolü', score: 0),
          Option(text: 'Güç çıkışını ve sistem güvenliğini kontrol etmek', score: 10),
          Option(text: 'Enerji verimliliğini artırmak', score: 0),
          Option(text: 'Maliyet azaltımı', score: 0),
        ],
        category: 'Enerji',
      ),
      Question(
        text: 'Rüzgar enerjisi projelerinde çevresel etki değerlendirmesi neden gereklidir?',
        options: [
          Option(text: 'Sadece yasal zorunluluk', score: 0),
          Option(text: 'Kuş ve yarasa ölümlerini minimize etmek için', score: 10),
          Option(text: 'Sadece halk onayı almak için', score: 0),
          Option(text: 'Maliyet hesaplamak için', score: 0),
        ],
        category: 'Enerji',
      ),
      Question(
        text: 'Rüzgar türbinlerinde en yaygın arıza türü hangisidir?',
        options: [
          Option(text: 'Elektronik kontrol arızaları', score: 5),
          Option(text: 'Mekanik parça arızaları', score: 10),
          Option(text: 'Yapısal hasar', score: 0),
          Option(text: 'Elektrik bağlantı arızaları', score: 0),
        ],
        category: 'Enerji',
      ),
      Question(
        text: 'Rüzgar enerjisi sistemlerinde capacity factor (kapasite faktörü) nedir?',
        options: [
          Option(text: 'Türbin maliyeti', score: 0),
          Option(text: 'Gerçek üretimin potansiyel üretime oranı', score: 10),
          Option(text: 'Kurulum süresi', score: 0),
          Option(text: 'Bakım maliyeti', score: 0),
        ],
        category: 'Enerji',
      ),
      Question(
        text: 'Rüzgar türbinlerinde wake effect (iz etkisi) nedir?',
        options: [
          Option(text: 'Türbinlerin arkasındaki rüzgar azalması', score: 10),
          Option(text: 'Gürültü etkisi', score: 0),
          Option(text: 'Titreşim etkisi', score: 0),
          Option(text: 'Görsel etki', score: 0),
        ],
        category: 'Enerji',
      ),
      Question(
        text: 'Rüzgar enerjisi sistemlerinde hibrid sistem yaklaşımı nedir?',
        options: [
          Option(text: 'Sadece rüzgar kullanımı', score: 0),
          Option(text: 'Rüzgar + güneş veya diğer kaynak kombinasyonu', score: 10),
          Option(text: 'Sadece şebeke bağlantısı', score: 0),
          Option(text: 'Sadece enerji depolama', score: 0),
        ],
        category: 'Enerji',
      ),
      Question(
        text: 'Rüzgar türbinlerinde kullanılan doubly-fed induction generator (DFIG) avantajı nedir?',
        options: [
          Option(text: 'Daha düşük maliyet', score: 0),
          Option(text: 'Değişken rüzgar hızlarında verimli üretim', score: 10),
          Option(text: 'Daha az bakım gereksinimi', score: 0),
          Option(text: 'Daha sessiz çalışma', score: 0),
        ],
        category: 'Enerji',
      ),
      Question(
        text: 'Rüzgar enerjisi projelerinde repowering (yeniden güçlendirme) ne anlama gelir?',
        options: [
          Option(text: 'Eski türbinleri daha verimli yenileriyle değiştirme', score: 10),
          Option(text: 'Sadece bakım yapma', score: 0),
          Option(text: 'Sadece tamir etme', score: 0),
          Option(text: 'Sadece güvenlik güncellemesi', score: 0),
        ],
        category: 'Enerji',
      ),

      // Hidroelektrik Enerji (25 soru)
      Question(
        text: 'Küçük ölçekli hidroelektrik sistemlerde (small hydro) kurulum kapasitesi genellikle kaç MW\'tır?',
        options: [
          Option(text: '0.1-1 MW', score: 0),
          Option(text: '1-10 MW', score: 10),
          Option(text: '50-100 MW', score: 0),
          Option(text: '500 MW ve üzeri', score: 0),
        ],
        category: 'Enerji',
      ),
      Question(
        text: 'Hidroelektrik santrallerde kullanılan Kaplan türbininin avantajı nedir?',
        options: [
          Option(text: 'Sadece yüksek debili akışlarda çalışır', score: 0),
          Option(text: 'Geniş debi aralığında verimli çalışır', score: 10),
          Option(text: 'Sadece yüksek basınçlı sistemlerde çalışır', score: 0),
          Option(text: 'Sadece deniz seviyesinde çalışır', score: 0),
        ],
        category: 'Enerji',
      ),
      Question(
        text: 'Hidroelektrik enerji üretiminde head (düşüm yüksekliği) nedir?',
        options: [
          Option(text: 'Su debisi miktarı', score: 0),
          Option(text: 'Su seviyesi farkı nedeniyle oluşan basınç', score: 10),
          Option(text: 'Türbin çapı', score: 0),
          Option(text: 'Santral kurulum yüksekliği', score: 0),
        ],
        category: 'Enerji',
      ),
      Question(
        text: 'Hidroelektrik santrallerde run-of-river (akış üzeri) sistem nedir?',
        options: [
          Option(text: 'Büyük barajlı sistem', score: 0),
          Option(text: 'Doğal akışı değiştirmeyen, küçük kurulu sistem', score: 10),
          Option(text: 'Deniz üzeri kurulan sistem', score: 0),
          Option(text: 'Yeraltı suyu sistemi', score: 0),
        ],
        category: 'Enerji',
      ),
      Question(
        text: 'Hidroelektrik türbinlerde efficiency (verimlilik) oranı genellikle yüzde kaçtır?',
        options: [
          Option(text: '%60-70', score: 0),
          Option(text: '%80-90', score: 10),
          Option(text: '%95-100', score: 0),
          Option(text: '%40-50', score: 0),
        ],
        category: 'Enerji',
      ),
      Question(
        text: 'Hidroelektrik santrallerde kullanılan Francis türbini hangi tip akışlar için uygundur?',
        options: [
          Option(text: 'Sadece çok yüksek debili akışlar', score: 0),
          Option(text: 'Orta ila yüksek düşümlü akışlar', score: 10),
          Option(text: 'Sadece düşük basınçlı akışlar', score: 0),
          Option(text: 'Sadece gel-git sistemleri', score: 0),
        ],
        category: 'Enerji',
      ),
      Question(
        text: 'Hidroelektrik enerji sistemlerinde fish ladder (balık merdiveni) ne amaçla kullanılır?',
        options: [
          Option(text: 'Balık ölümünü azaltmak için', score: 10),
          Option(text: 'Su debisini artırmak için', score: 0),
          Option(text: 'Türbin verimliliğini artırmak için', score: 0),
          Option(text: 'Santral maliyetini azaltmak için', score: 0),
        ],
        category: 'Enerji',
      ),
      Question(
        text: 'Hidroelektrik santrallerde peak load (yük pik) yönetimi nasıl yapılır?',
        options: [
          Option(text: 'Sadece gündüz üretim', score: 0),
          Option(text: 'Su seviyesi farkını kullanarak hızlı güç ayarı', score: 10),
          Option(text: 'Türbin sayısını artırma', score: 0),
          Option(text: 'Basınç artırma sistemi', score: 0),
        ],
        category: 'Enerji',
      ),
      Question(
        text: 'Hidroelektrik enerji sistemlerinde reservoir (rezervuar) kapasitesinin önemi nedir?',
        options: [
          Option(text: 'Sadece maliyet tasarrufu', score: 0),
          Option(text: 'Enerji depolama ve mevsimsel yönetim', score: 10),
          Option(text: 'Sadece güvenlik sağlama', score: 0),
          Option(text: 'Sadece çevresel koruma', score: 0),
        ],
        category: 'Enerji',
      ),
      Question(
        text: 'Hidroelektrik türbinlerde kullanılan draft tube (emme borusu) ne işe yarar?',
        options: [
          Option(text: 'Su debisini artırmak', score: 0),
          Option(text: 'Türbin çıkışında vakum oluşturarak verimliliği artırmak', score: 10),
          Option(text: 'Suyu filtrelemek', score: 0),
          Option(text: 'Sistemi soğutmak', score: 0),
        ],
        category: 'Enerji',
      ),
      Question(
        text: 'Hidroelektrik enerji projelerinde EIA (çevresel etki değerlendirmesi) neden kritiktir?',
        options: [
          Option(text: 'Sadece yasal zorunluluk', score: 0),
          Option(text: 'Ekosistem ve su kaynakları üzerindeki etkileri değerlendirmek', score: 10),
          Option(text: 'Sadece maliyet hesaplamak', score: 0),
          Option(text: 'Sadece teknik fizibilite', score: 0),
        ],
        category: 'Enerji',
      ),
      Question(
        text: 'Hidroelektrik santrallerde spillway (taşma yolu) hangi durumlarda kullanılır?',
        options: [
          Option(text: 'Normal çalışma koşullarında', score: 0),
          Option(text: 'Aşırı su seviyesinde güvenlik için', score: 10),
          Option(text: 'Sadece bakım zamanlarında', score: 0),
          Option(text: 'Sadece kuru mevsimde', score: 0),
        ],
        category: 'Enerji',
      ),
      Question(
        text: 'Hidroelektrik enerji sistemlerinde pumped storage (pompaj depolama) nasıl çalışır?',
        options: [
          Option(text: 'Sadece bir yönde su akışı', score: 0),
          Option(text: 'Fazla elektrikle suyu yukarı pompalamak ve ihtiyaç halinde bırakmak', score: 10),
          Option(text: 'Sadece rüzgar enerjisi ile', score: 0),
          Option(text: 'Sadece güneş enerjisi ile', score: 0),
        ],
        category: 'Enerji',
      ),
      Question(
        text: 'Hidroelektrik türbinlerde Kaplan pervanesi hangi özelliğe sahiptir?',
        options: [
          Option(text: 'Sabit kanat açısı', score: 0),
          Option(text: 'Ayarlanabilir kanat açısı', score: 10),
          Option(text: 'Tek kanatlı tasarım', score: 0),
          Option(text: 'Yatay eksenli tasarım', score: 0),
        ],
        category: 'Enerji',
      ),
      Question(
        text: 'Hidroelektrik enerji üretiminde spesifik hız (specific speed) neyi ifade eder?',
        options: [
          Option(text: 'Türbin maliyeti', score: 0),
          Option(text: 'Türbin tasarım karakteristiği ve performans ölçüsü', score: 10),
          Option(text: 'Su debisi hızı', score: 0),
          Option(text: 'Santral kurulum süresi', score: 0),
        ],
        category: 'Enerji',
      ),
      Question(
        text: 'Hidroelektrik santrallerde governor (hız kontrol cihazı) ne işe yarar?',
        options: [
          Option(text: 'Su debisini ölçmek', score: 0),
          Option(text: 'Türbin hızını ve güç çıkışını kontrol etmek', score: 10),
          Option(text: 'Sistemi soğutmak', score: 0),
          Option(text: 'Gürültüyü azaltmak', score: 0),
        ],
        category: 'Enerji',
      ),
      Question(
        text: 'Hidroelektrik enerji sistemlerinde micro-hydro sistemlerde tipik kurulum gücü kaç kW\'tır?',
        options: [
          Option(text: '100-500 kW', score: 0),
          Option(text: '5-100 kW', score: 10),
          Option(text: '1-2 MW', score: 0),
          Option(text: '10-50 MW', score: 0),
        ],
        category: 'Enerji',
      ),
      Question(
        text: 'Hidroelektrik santrallerde air vent (havalandırma) neden gereklidir?',
        options: [
          Option(text: 'Enerji tasarrufu için', score: 0),
          Option(text: 'Basınç değişimlerinde hava kabarcığı oluşumunu önlemek', score: 10),
          Option(text: 'Sistemi temizlemek için', score: 0),
          Option(text: 'Gürültüyü azaltmak için', score: 0),
        ],
        category: 'Enerji',
      ),
      Question(
        text: 'Hidroelektrik enerji üretiminde cavitation (kavitasyon) nedir ve neden zararlıdır?',
        options: [
          Option(text: 'Su buharı kabarcıklarının oluşumu ve türbin hasarı', score: 10),
          Option(text: 'Su kalitesi problemi', score: 0),
          Option(text: 'Gürültü problemi', score: 0),
          Option(text: 'Verimlilik kaybı', score: 5),
        ],
        category: 'Enerji',
      ),
      Question(
        text: 'Hidroelektrik santrallerde trash rack (çöp ızgarası) ne amaçla kullanılır?',
        options: [
          Option(text: 'Su akışını hızlandırmak', score: 0),
          Option(text: 'Türbini hasar verebilecek atıklardan korumak', score: 10),
          Option(text: 'Su basıncını artırmak', score: 0),
          Option(text: 'Sistemi filtrelemek', score: 0),
        ],
        category: 'Enerji',
      ),
      Question(
        text: 'Hidroelektrik enerji sistemlerinde run-of-river projelerinin avantajı nedir?',
        options: [
          Option(text: 'Daha yüksek enerji üretimi', score: 0),
          Option(text: 'Daha az çevresel etki ve düşük maliyet', score: 10),
          Option(text: 'Daha kolay bakım', score: 0),
          Option(text: 'Daha az teknik karmaşıklık', score: 0),
        ],
        category: 'Enerji',
      ),
      Question(
        text: 'Hidroelektrik türbinlerde impulse (darbe) türbinleri hangi koşullarda kullanılır?',
        options: [
          Option(text: 'Yüksek basınç, düşük debili akışlar', score: 10),
          Option(text: 'Düşük basınç, yüksek debili akışlar', score: 0),
          Option(text: 'Sadece deniz sistemleri', score: 0),
          Option(text: 'Sadece kanal sistemleri', score: 0),
        ],
        category: 'Enerji',
      ),
      Question(
        text: 'Hidroelektrik enerji projelerinde sedimentation (sediment birikimi) sorunu nasıl çözülür?',
        options: [
          Option(text: 'Sadece periyodik temizlik', score: 5),
          Option(text: 'Sediment by-pass sistemleri ve düzenli temizlik', score: 10),
          Option(text: 'Sadece filtre sistemi', score: 0),
          Option(text: 'Sadece kimyasal çözeltiler', score: 0),
        ],
        category: 'Enerji',
      ),

      // Enerji Verimliliği (25 soru)
      Question(
        text: 'Evlerde enerji verimliliğini artırmanın en etkili yolu nedir?',
        options: [
          Option(text: 'Tüm cihazları kapatmak', score: 5),
          Option(text: 'Yalıtım iyileştirmeleri ve verimli cihazlar', score: 10),
          Option(text: 'Daha az elektrik kullanmak', score: 0),
          Option(text: 'Sadece LED ampul kullanmak', score: 0),
        ],
        category: 'Enerji',
      ),
      Question(
        text: 'Bina enerji verimliliğinde U-değeri neyi ifade eder?',
        options: [
          Option(text: 'Enerji maliyeti', score: 0),
          Option(text: 'Isı geçirgenlik katsayısı (düşük = iyi)', score: 10),
          Option(text: 'Su geçirgenliği', score: 0),
          Option(text: 'Ses yalıtımı', score: 0),
        ],
        category: 'Enerji',
      ),
      Question(
        text: 'Akıllı termostatların enerji tasarrufu sağlama prensibi nedir?',
        options: [
          Option(text: 'Sürekli maksimum güç', score: 0),
          Option(text: 'Programlı ve adaptif ısıtma/soğutma kontrolü', score: 10),
          Option(text: 'Manuel kontrol', score: 0),
          Option(text: 'Sadece zamanlayıcı fonksiyonu', score: 5),
        ],
        category: 'Enerji',
      ),
      Question(
        text: 'LED aydınlatma teknolojisinin enerji verimliliği avantajı nedir?',
        options: [
          Option(text: 'Daha yüksek güç tüketimi', score: 0),
          Option(text: 'Daha az enerji tüketimi ve uzun ömür', score: 10),
          Option(text: 'Sadece düşük maliyet', score: 0),
          Option(text: 'Sadece iyi aydınlatma', score: 0),
        ],
        category: 'Enerji',
      ),
      Question(
        text: 'Binalarda çift cam kullanımının enerji verimliliğine katkısı nedir?',
        options: [
          Option(text: 'Hiç katkısı yoktur', score: 0),
          Option(text: 'Isı kayıplarını azaltır ve konforu artırır', score: 10),
          Option(text: 'Sadece estetik sağlar', score: 0),
          Option(text: 'Sadece gürültü azaltır', score: 0),
        ],
        category: 'Enerji',
      ),
      Question(
        text: 'Enerji etiketinde A+++ sınıfı ne anlama gelir?',
        options: [
          Option(text: 'Orta enerji verimliliği', score: 0),
          Option(text: 'En yüksek enerji verimliliği', score: 10),
          Option(text: 'Düşük enerji verimliliği', score: 0),
          Option(text: 'Ortalama enerji verimliliği', score: 0),
        ],
        category: 'Enerji',
      ),
      Question(
        text: 'Evlerde kullanılan inverter klimaların avantajı nedir?',
        options: [
          Option(text: 'Daha yüksek enerji tüketimi', score: 0),
          Option(text: 'Değişken hızlı kompresör ile enerji tasarrufu', score: 10),
          Option(text: 'Sadece daha sessiz çalışma', score: 0),
          Option(text: 'Sadece daha hızlı soğutma', score: 0),
        ],
        category: 'Enerji',
      ),
      Question(
        text: 'Binalarda enerji audit (denetimi) ne amaçla yapılır?',
        options: [
          Option(text: 'Sadece maliyet hesabı', score: 0),
          Option(text: 'Enerji kullanım analizi ve iyileştirme önerileri', score: 10),
          Option(text: 'Sadece yasal zorunluluk', score: 0),
          Option(text: 'Sadece güvenlik kontrolü', score: 0),
        ],
        category: 'Enerji',
      ),
      Question(
        text: 'Güneş kontrollü aydınlatma sistemi nasıl çalışır?',
        options: [
          Option(text: 'Sabit aydınlatma sağlar', score: 0),
          Option(text: 'Doğal ışık seviyesine göre otomatik ayarlama', score: 10),
          Option(text: 'Sadece gece çalışır', score: 0),
          Option(text: 'Sadece gündüz çalışır', score: 0),
        ],
        category: 'Enerji',
      ),
      Question(
        text: 'Endüstriyel tesislerde waste heat recovery (atık ısı geri kazanım) nedir?',
        options: [
          Option(text: 'Isıyı yok etmek', score: 0),
          Option(text: 'Atık ısıyı tekrar enerji üretiminde kullanmak', score: 10),
          Option(text: 'Isıyı havaya salmak', score: 0),
          Option(text: 'Isıyı suya boşaltmak', score: 0),
        ],
        category: 'Enerji',
      ),
      Question(
        text: 'Binalarda thermal mass (termal kütle) ne işe yarar?',
        options: [
          Option(text: 'Isı üretmek', score: 0),
          Option(text: 'Isı depolayarak sıcaklık dalgalanmalarını dengelemek', score: 10),
          Option(text: 'Soğuk depolamak', score: 0),
          Option(text: 'Nem kontrolü yapmak', score: 0),
        ],
        category: 'Enerji',
      ),
      Question(
        text: 'Akıllı ev sistemlerinde enerji yönetimi nasıl çalışır?',
        options: [
          Option(text: 'Sadece zamanlama', score: 0),
          Option(text: 'Cihazları koordine ederek optimum enerji kullanımı', score: 10),
          Option(text: 'Sadece uzaktan kontrol', score: 0),
          Option(text: 'Sadece güvenlik sağlama', score: 0),
        ],
        category: 'Enerji',
      ),
      Question(
        text: 'Enerji verimli ev aletlerinde Energy Star sertifikası ne anlama gelir?',
        options: [
          Option(text: 'Pahalı ürün işareti', score: 0),
          Option(text: 'Enerji verimliliği standartlarını karşılayan ürün', score: 10),
          Option(text: 'Yerli ürün işareti', score: 0),
          Option(text: 'Kaliteli ürün işareti', score: 0),
        ],
        category: 'Enerji',
      ),
      Question(
        text: 'Binalarda cool roof (serin çatı) teknolojisinin faydası nedir?',
        options: [
          Option(text: 'Isı yalıtımı sağlar', score: 0),
          Option(text: 'Güneş ışınımını yansıtarak binayı serin tutar', score: 10),
          Option(text: 'Su geçirmezlik sağlar', score: 0),
          Option(text: 'Estetik görünüm sağlar', score: 0),
        ],
        category: 'Enerji',
      ),
      Question(
        text: 'Endüstriyel proseslerde Variable Frequency Drive (VFD) kullanımının faydası nedir?',
        options: [
          Option(text: 'Motor hızını kontrol ederek enerji tasarrufu', score: 10),
          Option(text: 'Motor ömrünü uzatmak', score: 5),
          Option(text: 'Gürültüyü azaltmak', score: 0),
          Option(text: 'Maliyet artırmak', score: 0),
        ],
        category: 'Enerji',
      ),
      Question(
        text: 'Evlerde enerji depolama sistemleri hangi amaçla kullanılır?',
        options: [
          Option(text: 'Sadece yedek güç sağlamak', score: 0),
          Option(text: 'Fazla enerjiyi depolamak ve ihtiyaç halinde kullanmak', score: 10),
          Option(text: 'Sadece maliyet azaltmak', score: 0),
          Option(text: 'Sadece güvenlik sağlamak', score: 0),
        ],
        category: 'Enerji',
      ),
      Question(
        text: 'Binalarda energy management system (EMS) ne işe yarar?',
        options: [
          Option(text: 'Sadece enerji ölçümü', score: 0),
          Option(text: 'Enerji kullanımını optimize etmek ve kontrol etmek', score: 10),
          Option(text: 'Sadece fatura takibi', score: 0),
          Option(text: 'Sadece alarm sistemi', score: 0),
        ],
        category: 'Enerji',
      ),
      Question(
        text: 'Enerji verimliliği projelerinde payback period (geri ödeme süresi) nasıl hesaplanır?',
        options: [
          Option(text: 'Proje süresi', score: 0),
          Option(text: 'Yatırım maliyeti / yıllık tasarruf miktarı', score: 10),
          Option(text: 'Kurulum süresi', score: 0),
          Option(text: 'Garanti süresi', score: 0),
        ],
        category: 'Enerji',
      ),
      Question(
        text: 'Binalarda daylighting (gün ışığı kullanımı) tasarımında hangi faktörler önemlidir?',
        options: [
          Option(text: 'Sadece pencere boyutu', score: 0),
          Option(text: 'Pencere yönü, boyut ve gölgeleme elemanları', score: 10),
          Option(text: 'Sadece pencere sayısı', score: 0),
          Option(text: 'Sadece cam kalınlığı', score: 0),
        ],
        category: 'Enerji',
      ),
      Question(
        text: 'Endüstriyel enerji verimliliğinde process optimization (proses optimizasyonu) ne anlama gelir?',
        options: [
          Option(text: 'Sadece ekipman değiştirme', score: 0),
          Option(text: 'Üretim süreçlerini optimize ederek enerji verimliliği artırma', score: 10),
          Option(text: 'Sadece bakım yapma', score: 0),
          Option(text: 'Sadece otomasyon', score: 0),
        ],
        category: 'Enerji',
      ),
      Question(
        text: 'Evlerde kullanılan heat recovery ventilation (ısı geri kazanımlı havalandırma) nasıl çalışır?',
        options: [
          Option(text: 'Havayı dışarı atar', score: 0),
          Option(text: 'Atılan havadaki ısıyı temiz havaya aktarır', score: 10),
          Option(text: 'Havayı filtreler', score: 0),
          Option(text: 'Havayı nemlendirir', score: 0),
        ],
        category: 'Enerji',
      ),
      Question(
        text: 'Enerji verimliliği standardında ISO 50001 ne hakkındadır?',
        options: [
          Option(text: 'Ürün güvenliği', score: 0),
          Option(text: 'Enerji yönetim sistemleri', score: 10),
          Option(text: 'Çevre koruması', score: 0),
          Option(text: 'İş sağlığı ve güvenliği', score: 0),
        ],
        category: 'Enerji',
      ),
      Question(
        text: 'Binalarda insulation (yalıtım) kalitesini ölçmek için hangi parametre kullanılır?',
        options: [
          Option(text: 'R-değeri (termal direnç)', score: 10),
          Option(text: 'P-değeri', score: 0),
          Option(text: 'M-değeri', score: 0),
          Option(text: 'K-değeri', score: 0),
        ],
        category: 'Enerji',
      ),
      Question(
        text: 'Endüstriyel tesislerde cogeneration (kojenerasyon) sistemi nasıl çalışır?',
        options: [
          Option(text: 'Sadece elektrik üretimi', score: 0),
          Option(text: 'Elektrik ve ısı eşzamanlı üretimi', score: 10),
          Option(text: 'Sadece ısı üretimi', score: 0),
          Option(text: 'Sadece soğutma üretimi', score: 0),
        ],
        category: 'Enerji',
      ),

      // Ev Enerjisi (25 soru)
      Question(
        text: 'Evin en büyük enerji tüketici kalemi genellikle nedir?',
        options: [
          Option(text: 'Aydınlatma', score: 0),
          Option(text: 'Isıtma ve soğutma sistemleri', score: 10),
          Option(text: 'Elektronik cihazlar', score: 0),
          Option(text: 'Su ısıtma', score: 0),
        ],
        category: 'Enerji',
      ),
      Question(
        text: 'Evin elektrik faturalarını azaltmak için ilk yapılması gereken nedir?',
        options: [
          Option(text: 'Tüm cihazları satmak', score: 0),
          Option(text: 'Enerji audit yaptırmak ve en çok tüketen alanları tespit etmek', score: 10),
          Option(text: 'Sadece LED ampul kullanmak', score: 0),
          Option(text: 'Klima kullanmayı bırakmak', score: 0),
        ],
        category: 'Enerji',
      ),
      Question(
        text: 'Evin ısı kayıplarının en büyük kaynağı genellikle nedir?',
        options: [
          Option(text: 'Tavan', score: 0),
          Option(text: 'Pencereler ve kapılar', score: 10),
          Option(text: 'Duvar', score: 5),
          Option(text: 'Zemin', score: 0),
        ],
        category: 'Enerji',
      ),
      Question(
        text: 'Evin elektrik tüketimini ölçmek için kullanılan cihazın adı nedir?',
        options: [
          Option(text: 'Termometre', score: 0),
          Option(text: 'Elektrik sayaç', score: 10),
          Option(text: 'Barometre', score: 0),
          Option(text: 'Higrometre', score: 0),
        ],
        category: 'Enerji',
      ),
      Question(
        text: 'Evin su ısıtma sisteminde solar water heater (güneşli su ısıtıcısı) verimi nasıl artırılır?',
        options: [
          Option(text: 'Daha küçük tank kullanmak', score: 0),
          Option(text: 'Sistemi düzenli temizlemek ve güneş alan konuma yerleştirmek', score: 10),
          Option(text: 'Daha fazla boru kullanmak', score: 0),
          Option(text: 'Daha yüksek basınçlı sistem kurmak', score: 0),
        ],
        category: 'Enerji',
      ),
      Question(
        text: 'Evin elektrik tesisatında standby power (bekleme gücü) ne anlama gelir?',
        options: [
          Option(text: 'Cihaz çalışırken tükettiği güç', score: 0),
          Option(text: 'Cihaz kapalıyken de tüketilen elektrik', score: 10),
          Option(text: 'Maksimum güç tüketimi', score: 0),
          Option(text: 'Minimum güç tüketimi', score: 0),
        ],
        category: 'Enerji',
      ),
      Question(
        text: 'Evin ısıtma sisteminde thermostat (termostat) doğru kullanımı nasıl olmalıdır?',
        options: [
          Option(text: 'Sürekli maksimum sıcaklıkta tutmak', score: 0),
          Option(text: 'Konfor ve tasarruf arasında dengeli programlama', score: 10),
          Option(text: 'Sürekli minimum sıcaklıkta tutmak', score: 0),
          Option(text: 'Manuel açma-kapama', score: 0),
        ],
        category: 'Enerji',
      ),
      Question(
        text: 'Evin elektrik faturalarında kW (kilovat) birimi neyi ifade eder?',
        options: [
          Option(text: 'Elektrik maliyeti', score: 0),
          Option(text: 'Güç birimi (enerji tüketim hızı)', score: 10),
          Option(text: 'Elektrik kalitesi', score: 0),
          Option(text: 'Elektrik voltajı', score: 0),
        ],
        category: 'Enerji',
      ),
      Question(
        text: 'Evin banyosunda enerji tasarrufu için hangi cihaz önerilir?',
        options: [
          Option(text: 'Geleneksel elektrikli su ısıtıcısı', score: 0),
          Option(text: 'Anında su ısıtıcısı (instant water heater)', score: 10),
          Option(text: 'Klasik su ısıtıcısı', score: 0),
          Option(text: 'Gazlı su ısıtıcısı', score: 0),
        ],
        category: 'Enerji',
      ),
      Question(
        text: 'Evin çamaşır ve bulaşık makinelerinde enerji verimli kullanım nasıl yapılır?',
        options: [
          Option(text: 'Sürekli yarım yük çalıştırmak', score: 0),
          Option(text: 'Tam dolu ve düşük sıcaklıkta çalıştırmak', score: 10),
          Option(text: 'Yüksek sıcaklıkta kısa program', score: 0),
          Option(text: 'Sürekli düşük sıcaklıkta uzun program', score: 0),
        ],
        category: 'Enerji',
      ),
      Question(
        text: 'Evin elektrikli araç şarj istasyonu kurulumunda hangi faktörler önemlidir?',
        options: [
          Option(text: 'Sadece estetik görünüm', score: 0),
          Option(text: 'Kapasite, güvenlik ve ev elektrik sistemi uyumluluğu', score: 10),
          Option(text: 'Sadece fiyat', score: 0),
          Option(text: 'Sadece marka', score: 0),
        ],
        category: 'Enerji',
      ),
      Question(
        text: 'Evin ısıtma sisteminde heat pump (ısı pompası) nasıl çalışır?',
        options: [
          Option(text: 'Elektrik enerjisini direkt ısıya çevirir', score: 0),
          Option(text: 'Düşük sıcaklıktaki ısıyı yüksek sıcaklığa transfer eder', score: 10),
          Option(text: 'Sadece soğutma yapar', score: 0),
          Option(text: 'Sadece havalandırma yapar', score: 0),
        ],
        category: 'Enerji',
      ),
      Question(
        text: 'Evin elektrik sisteminde residual current device (RCD) ne işe yarar?',
        options: [
          Option(text: 'Enerji tasarrufu sağlar', score: 0),
          Option(text: 'Elektrik kaçağı ve yangın riskini önler', score: 10),
          Option(text: 'Elektrik maliyetini azaltır', score: 0),
          Option(text: 'Elektrik kalitesini artırır', score: 0),
        ],
        category: 'Enerji',
      ),
      Question(
        text: 'Evin günlük enerji tüketimini takip etmek için hangi teknoloji kullanılır?',
        options: [
          Option(text: 'Sadece fatura kontrolü', score: 0),
          Option(text: 'Akıllı sayaç ve izleme uygulamaları', score: 10),
          Option(text: 'Sadece manuel kayıt', score: 0),
          Option(text: 'Sadece tahmin', score: 0),
        ],
        category: 'Enerji',
      ),
      Question(
        text: 'Evin soğutma sisteminde evaporative cooler (buharlaştırmalı soğutucu) hangi iklime uygundur?',
        options: [
          Option(text: 'Nemli iklimler', score: 0),
          Option(text: 'Kuru ve sıcak iklimler', score: 10),
          Option(text: 'Soğuk iklimler', score: 0),
          Option(text: 'Yağmurlu iklimler', score: 0),
        ],
        category: 'Enerji',
      ),
      Question(
        text: 'Evin elektrik sisteminde load balancing (yük dengeleme) ne anlama gelir?',
        options: [
          Option(text: 'Elektrik maliyetini artırmak', score: 0),
          Option(text: 'Elektrik yükünü fazlar arasında eşit dağıtmak', score: 10),
          Option(text: 'Elektrik kalitesini azaltmak', score: 0),
          Option(text: 'Elektrik güvenliğini sağlamak', score: 0),
        ],
        category: 'Enerji',
      ),
      Question(
        text: 'Evin çatısında kurulan güneş paneli sisteminde grid-tie (şebeke bağlantılı) sistem ne anlama gelir?',
        options: [
          Option(text: 'Sadece akü sistemi', score: 0),
          Option(text: 'Fazla enerjiyi şebekeye satma imkanı', score: 10),
          Option(text: 'Sadece yedek güç sistemi', score: 0),
          Option(text: 'Sadece off-grid sistem', score: 0),
        ],
        category: 'Enerji',
      ),
      Question(
        text: 'Evin ısıtma sisteminde radiant heating (ışıma ile ısıtma) avantajı nedir?',
        options: [
          Option(text: 'Daha yüksek maliyet', score: 0),
          Option(text: 'Eşit sıcaklık dağılımı ve enerji verimliliği', score: 10),
          Option(text: 'Sadece dekoratif görünüm', score: 0),
          Option(text: 'Sadece hızlı ısınma', score: 0),
        ],
        category: 'Enerji',
      ),
      Question(
        text: 'Evin elektrik sisteminde surge protector (voltaj koruyucu) neden gereklidir?',
        options: [
          Option(text: 'Enerji tasarrufu için', score: 0),
          Option(text: 'Elektronik cihazları ani voltaj dalgalanmalarından korumak', score: 10),
          Option(text: 'Elektrik maliyetini azaltmak', score: 0),
          Option(text: 'Elektrik kalitesini artırmak', score: 0),
        ],
        category: 'Enerji',
      ),
      Question(
        text: 'Evin ısıtma sisteminde zone heating (bölge ısıtma) nasıl çalışır?',
        options: [
          Option(text: 'Tüm evi aynı anda ısıtmak', score: 0),
          Option(text: 'Farklı alanları bağımsız olarak ısıtmak', score: 10),
          Option(text: 'Sadece tek odayı ısıtmak', score: 0),
          Option(text: 'Sadece merkezi ısıtma yapmak', score: 0),
        ],
        category: 'Enerji',
      ),
      Question(
        text: 'Evin elektrikli aletlerinde vampire power (vampir gücü) ne anlama gelir?',
        options: [
          Option(text: 'Yüksek güç tüketimi', score: 0),
          Option(text: 'Cihaz kapalıyken de tüketilen standby güç', score: 10),
          Option(text: 'Cihaz çalışırken tükettiği güç', score: 0),
          Option(text: 'Maksimum güç tüketimi', score: 0),
        ],
        category: 'Enerji',
      ),
      Question(
        text: 'Evin ısı yalıtımında spray foam insulation (püskürtme köpük yalıtım) avantajı nedir?',
        options: [
          Option(text: 'Daha düşük maliyet', score: 0),
          Option(text: 'Boşlukları tamamen doldurarak sızdırmazlık sağlar', score: 10),
          Option(text: 'Sadece hızlı uygulama', score: 0),
          Option(text: 'Sadece estetik görünüm', score: 0),
        ],
        category: 'Enerji',
      ),
      Question(
        text: 'Evin elektrik sisteminde smart meter (akıllı sayaç) özellikleri nelerdir?',
        options: [
          Option(text: 'Sadece elektrik tüketimini ölçer', score: 0),
          Option(text: 'Gerçek zamanlı veri iletimi ve uzaktan okuma', score: 10),
          Option(text: 'Sadece güvenlik sağlar', score: 0),
          Option(text: 'Sadece maliyet takibi yapar', score: 0),
        ],
        category: 'Enerji',
      ),

      // Endüstriyel Enerji (25 soru)
      Question(
        text: 'Endüstriyel tesislerde en büyük enerji tüketici genellikle hangi proses aşamasıdır?',
        options: [
          Option(text: 'Ürün ambalajlama', score: 0),
          Option(text: 'Isıtma ve soğutma prosesleri', score: 10),
          Option(text: 'Kalite kontrol', score: 0),
          Option(text: 'Lojistik operasyonları', score: 0),
        ],
        category: 'Enerji',
      ),
      Question(
        text: 'Endüstriyel enerji yönetiminde ISO 50001 standardının amacı nedir?',
        options: [
          Option(text: 'Çevre koruması', score: 0),
          Option(text: 'Enerji performansını sürekli iyileştirmek', score: 10),
          Option(text: 'İş sağlığı ve güvenliği', score: 0),
          Option(text: 'Kalite yönetimi', score: 0),
        ],
        category: 'Enerji',
      ),
      Question(
        text: 'Endüstriyel tesislerde compressed air (basınçlı hava) sistemlerinde enerji verimliliği nasıl artırılır?',
        options: [
          Option(text: 'Sadece daha yüksek basınç kullanmak', score: 0),
          Option(text: 'Sızıntı önleme ve verimli kompresör seçimi', score: 10),
          Option(text: 'Sadece daha büyük kompresör', score: 0),
          Option(text: 'Sadece düzenli bakım', score: 5),
        ],
        category: 'Enerji',
      ),
      Question(
        text: 'Endüstriyel buhar sistemlerinde condensate recovery (kondensat geri kazanım) faydası nedir?',
        options: [
          Option(text: 'Sadece su tasarrufu', score: 0),
          Option(text: 'Enerji ve su tasarrufu ile verimlilik artışı', score: 10),
          Option(text: 'Sadece maliyet azaltımı', score: 0),
          Option(text: 'Sadece çevre koruması', score: 0),
        ],
        category: 'Enerji',
      ),
      Question(
        text: 'Endüstriyel tesislerde waste heat recovery sistemleri hangi tip endüstrilerde en etkilidir?',
        options: [
          Option(text: 'Tekstil endüstrisi', score: 5),
          Option(text: 'Çelik, çimento ve rafineri endüstrileri', score: 10),
          Option(text: 'Gıda işleme', score: 0),
          Option(text: 'Elektronik üretimi', score: 0),
        ],
        category: 'Enerji',
      ),
      Question(
        text: 'Endüstriyel elektrik motorlarında premium efficiency motorlar standart motorlara göre ne kadar daha verimlidir?',
        options: [
          Option(text: '%1-2', score: 0),
          Option(text: '%2-5', score: 10),
          Option(text: '%10-15', score: 0),
          Option(text: '%20-25', score: 0),
        ],
        category: 'Enerji',
      ),
      Question(
        text: 'Endüstriyel tesislerde energy management system (EMS) entegrasyonu nasıl gerçekleştirilir?',
        options: [
          Option(text: 'Sadece manuel takip', score: 0),
          Option(text: 'Otomatik izleme, kontrol ve optimizasyon sistemleri', score: 10),
          Option(text: 'Sadece raporlama', score: 0),
          Option(text: 'Sadece alarm sistemi', score: 0),
        ],
        category: 'Enerji',
      ),
      Question(
        text: 'Endüstriyel proseslerde Combined Heat and Power (CHP) sistemlerinin avantajı nedir?',
        options: [
          Option(text: 'Sadece elektrik üretimi', score: 0),
          Option(text: 'Elektrik ve ısı eşzamanlı üretimi ile %80+ verim', score: 10),
          Option(text: 'Sadece ısı üretimi', score: 0),
          Option(text: 'Sadece maliyet azaltımı', score: 0),
        ],
        category: 'Enerji',
      ),
      Question(
        text: 'Endüstriyel soğutma sistemlerinde chiller optimization (chiller optimizasyonu) nasıl yapılır?',
        options: [
          Option(text: 'Sadece düzenli bakım', score: 0),
          Option(text: 'Değişken hızlı kompresör ve akıllı kontrol sistemleri', score: 10),
          Option(text: 'Sadece filtre değişimi', score: 0),
          Option(text: 'Sadece su kalitesi kontrolü', score: 0),
        ],
        category: 'Enerji',
      ),
      Question(
        text: 'Endüstriyel tesislerde demand response (talep tepkisi) programlarına katılımın faydası nedir?',
        options: [
          Option(text: 'Sadece çevre koruması', score: 0),
          Option(text: 'Enerji maliyeti azaltımı ve şebeke desteği', score: 10),
          Option(text: 'Sadece gelir artışı', score: 0),
          Option(text: 'Sadece güvenlik', score: 0),
        ],
        category: 'Enerji',
      ),
      Question(
        text: 'Endüstriyel tesislerde predictive maintenance (öngörücü bakım) enerji verimliliğine nasıl katkı sağlar?',
        options: [
          Option(text: 'Sadece arıza önleme', score: 0),
          Option(text: 'Ekipman verimliliğini koruyarak enerji kayıplarını önleme', score: 10),
          Option(text: 'Sadece maliyet azaltımı', score: 0),
          Option(text: 'Sadece güvenlik', score: 0),
        ],
        category: 'Enerji',
      ),
      Question(
        text: 'Endüstriyel tesislerde boiler optimization (kazan optimizasyonu) hangi faktörleri kapsar?',
        options: [
          Option(text: 'Sadece yakıt seçimi', score: 0),
          Option(text: 'Yanma verimliliği, buhar kalitesi ve sistem kontrolü', score: 10),
          Option(text: 'Sadece güvenlik sistemi', score: 0),
          Option(text: 'Sadece bakım programı', score: 0),
        ],
        category: 'Enerji',
      ),
      Question(
        text: 'Endüstriyel proseslerde air compressor efficiency (kompresör verimliliği) nasıl ölçülür?',
        options: [
          Option(text: 'Sadece basınç ölçümü', score: 0),
          Option(text: ' Spesifik enerji tüketimi (kWh/m³)', score: 10),
          Option(text: 'Sadece debi ölçümü', score: 0),
          Option(text: 'Sadece sıcaklık ölçümü', score: 0),
        ],
        category: 'Enerji',
      ),
      Question(
        text: 'Endüstriyel tesislerde renewable energy integration (yenilenebilir enerji entegrasyonu) nasıl planlanır?',
        options: [
          Option(text: 'Sadece güneş paneli kurulumu', score: 0),
          Option(text: 'Enerji profil analizi ve hibrit sistem tasarımı', score: 10),
          Option(text: 'Sadece rüzgar türbini', score: 0),
          Option(text: 'Sadece enerji depolama', score: 0),
        ],
        category: 'Enerji',
      ),
      Question(
        text: 'Endüstriyel tesislerde industrial energy audit (endüstriyel enerji denetimi) hangi adımları içerir?',
        options: [
          Option(text: 'Sadece fatura analizi', score: 0),
          Option(text: 'Veri toplama, analiz, öneri geliştirme ve uygulama planı', score: 10),
          Option(text: 'Sadece ekipman listesi', score: 0),
          Option(text: 'Sadece maliyet hesabı', score: 0),
        ],
        category: 'Enerji',
      ),
      Question(
        text: 'Endüstriyel proseslerde process intensification (proses yoğunlaştırma) enerji verimliliğini nasıl artırır?',
        options: [
          Option(text: 'Sadece ekipman sayısını artırır', score: 0),
          Option(text: 'Daha küçük ekipmanlarla aynı üretimi yaparak enerji tasarrufu', score: 10),
          Option(text: 'Sadece üretim hızını artırır', score: 0),
          Option(text: 'Sadece kaliteyi artırır', score: 0),
        ],
        category: 'Enerji',
      ),
      Question(
        text: 'Endüstriyel tesislerde thermal energy storage (termal enerji depolama) hangi durumlarda kullanılır?',
        options: [
          Option(text: 'Sadece güvenlik için', score: 0),
          Option(text: 'Fazla enerjiyi depolayıp talep zamanında kullanmak', score: 10),
          Option(text: 'Sadece maliyet azaltımı için', score: 0),
          Option(text: 'Sadece çevre koruması için', score: 0),
        ],
        category: 'Enerji',
      ),
      Question(
        text: 'Endüstriyel elektrik sistemlerinde power factor correction (güç faktörü düzeltmesi) neden gereklidir?',
        options: [
          Option(text: 'Sadece güvenlik için', score: 0),
          Option(text: 'Reaktif güç cezalarını önlemek ve sistem verimliliğini artırmak', score: 10),
          Option(text: 'Sadece maliyet azaltımı için', score: 0),
          Option(text: 'Sadece kalite artırımı için', score: 0),
        ],
        category: 'Enerji',
      ),
      Question(
        text: 'Endüstriyel tesislerde energy performance contracting (enerji performans sözleşmesi) modeli nedir?',
        options: [
          Option(text: 'Sadece ekipman satışı', score: 0),
          Option(text: 'Tasarruf paylaşımı ile enerji iyileştirme hizmeti', score: 10),
          Option(text: 'Sadece finansman sağlama', score: 0),
          Option(text: 'Sadece teknik danışmanlık', score: 0),
        ],
        category: 'Enerji',
      ),
      Question(
        text: 'Endüstriyel proseslerde heat integration (ısı entegrasyonu) nasıl gerçekleştirilir?',
        options: [
          Option(text: 'Sadece ek ısıtıcı eklemek', score: 0),
          Option(text: 'Proces arası ısı transferi ile enerji verimliliği', score: 10),
          Option(text: 'Sadece izolasyon iyileştirmek', score: 0),
          Option(text: 'Sadece sıcaklık artırmak', score: 0),
        ],
        category: 'Enerji',
      ),
      Question(
        text: 'Endüstriyel tesislerde industrial symbiosis (endüstriyel simbiyoz) ne anlama gelir?',
        options: [
          Option(text: 'Sadece rekabet', score: 0),
          Option(text: 'Bir tesisin atığının diğer tesisin hammadde olması', score: 10),
          Option(text: 'Sadece teknoloji paylaşımı', score: 0),
          Option(text: 'Sadece finansman ortaklığı', score: 0),
        ],
        category: 'Enerji',
      ),
      Question(
        text: 'Endüstriyel enerji yönetiminde key performance indicators (KPI) hangi metrikleri içerir?',
        options: [
          Option(text: 'Sadece maliyet metrikleri', score: 0),
          Option(text: 'Enerji yoğunluğu, verimlilik ve maliyet metrikleri', score: 10),
          Option(text: 'Sadece üretim metrikleri', score: 0),
          Option(text: 'Sadece kalite metrikleri', score: 0),
        ],
        category: 'Enerji',
      ),
      Question(
        text: 'Endüstriyel tesislerde district energy (bölgesel enerji) sistemlerinin avantajı nedir?',
        options: [
          Option(text: 'Sadece maliyet artırımı', score: 0),
          Option(text: 'Ölçek ekonomisi ile verimlilik ve çevre faydaları', score: 10),
          Option(text: 'Sadece güvenlik sağlama', score: 0),
          Option(text: 'Sadece bağımsızlık', score: 0),
        ],
        category: 'Enerji',
      ),

      // Biokütle Enerjisi (25 soru)
      Question(
        text: 'Biokütle enerjisi nedir?',
        options: [
          Option(text: 'Fosil yakıtlardan elde edilen enerji', score: 0),
          Option(text: 'Organik maddelerden elde edilen yenilenebilir enerji', score: 10),
          Option(text: 'Güneş enerjisinden elde edilen elektrik', score: 0),
          Option(text: 'Rüzgar enerjisinden elde edilen güç', score: 0),
        ],
        category: 'Enerji',
      ),
      Question(
        text: 'Biokütle yakıtların yakılması ile oluşan CO₂ emisyonları çevreye zararlı mıdır?',
        options: [
          Option(text: 'Evet, çok zararlıdır', score: 0),
          Option(text: 'Hayır, çünkü bitkiler bu CO₂\'yi tekrar absorbe eder', score: 10),
          Option(text: 'Sadece kısa vadede zararlıdır', score: 0),
          Option(text: 'Sadece belirli koşullarda zararlıdır', score: 0),
        ],
        category: 'Enerji',
      ),
      Question(
        text: 'Biogaz üretiminde en yaygın kullanılan yöntem hangisidir?',
        options: [
          Option(text: 'Açık yakma', score: 0),
          Option(text: 'Anaerobik (oksijensiz) çürütme', score: 10),
          Option(text: 'Piroliz', score: 0),
          Option(text: 'Gazifikasyon', score: 0),
        ],
        category: 'Enerji',
      ),
      Question(
        text: 'Biokütle enerjisi üretiminde hangi organik maddeler kullanılabilir?',
        options: [
          Option(text: 'Sadece ağaçlar', score: 0),
          Option(text: 'Tarımsal atıklar, hayvansal dışkılar ve organik çöpler', score: 10),
          Option(text: 'Sadece gıda atıkları', score: 0),
          Option(text: 'Sadece kağıt atıkları', score: 0),
        ],
        category: 'Enerji',
      ),
      Question(
        text: 'Biokütle yakıt pelletlerinin avantajı nedir?',
        options: [
          Option(text: 'Daha yüksek nem içeriği', score: 0),
          Option(text: 'Yoğun enerji, kolay taşıma ve depolama', score: 10),
          Option(text: 'Daha düşük enerji yoğunluğu', score: 0),
          Option(text: 'Sadece düşük maliyet', score: 0),
        ],
        category: 'Enerji',
      ),
      Question(
        text: 'Enerji üretimi için en verimli biokütle türü hangisidir?',
        options: [
          Option(text: 'Kuru organik atıklar', score: 5),
          Option(text: 'Hızlı büyüyen enerji bitkileri (mısır, şeker kamışı)', score: 10),
          Option(text: 'Orman atıkları', score: 0),
          Option(text: 'Gıda atıkları', score: 0),
        ],
        category: 'Enerji',
      ),
      Question(
        text: 'Biokütle sistemlerinde kullanılan anaerobic digester (anaerobik çürütücü) nasıl çalışır?',
        options: [
          Option(text: 'Oksijen varlığında organik maddelerin parçalanması', score: 0),
          Option(text: 'Oksijensiz ortamda metan ve CO₂ üretimi', score: 10),
          Option(text: 'Yüksek sıcaklıkta yakma işlemi', score: 0),
          Option(text: 'Sadece mekanik parçalama', score: 0),
        ],
        category: 'Enerji',
      ),
      Question(
        text: 'Biokütle enerjisinin fosil yakıtlara göre avantajı nedir?',
        options: [
          Option(text: 'Daha yüksek maliyet', score: 0),
          Option(text: 'Karbon-nötr olma ve yenilenebilir olma', score: 10),
          Option(text: 'Daha az enerji yoğunluğu', score: 0),
          Option(text: 'Daha zor üretim', score: 0),
        ],
        category: 'Enerji',
      ),
      Question(
        text: 'Biokütle pirolizi ile hangi yakıt ürünleri elde edilir?',
        options: [
          Option(text: 'Sadece metan', score: 0),
          Option(text: 'Bio-yağ, gaz ve katran', score: 10),
          Option(text: 'Sadece elektrik', score: 0),
          Option(text: 'Sadece ısı', score: 0),
        ],
        category: 'Enerji',
      ),
      Question(
        text: 'Biokütle enerjisinde sustainability (sürdürülebilirlik) açısından en önemli faktör nedir?',
        options: [
          Option(text: 'En yüksek enerji verimi', score: 0),
          Option(text: 'Doğal ekosistemlere zarar vermeden üretim', score: 10),
          Option(text: 'En düşük maliyet', score: 0),
          Option(text: 'En hızlı üretim', score: 0),
        ],
        category: 'Enerji',
      ),
      Question(
        text: 'Biokütle yakıtlarının yanma verimliliğini etkileyen en önemli faktör nedir?',
        options: [
          Option(text: 'Yakıt rengi', score: 0),
          Option(text: 'Nem içeriği ve tane boyutu', score: 10),
          Option(text: 'Yakıt kokusu', score: 0),
          Option(text: 'Yakıt ağırlığı', score: 0),
        ],
        category: 'Enerji',
      ),
      Question(
        text: 'Biokütle enerjisinde kullanılan gasification (gazifikasyon) prosesinin ürünü nedir?',
        options: [
          Option(text: 'Sadece katı yakıt', score: 0),
          Option(text: 'Sentez gazı (CO, H₂, CH₄ karışımı)', score: 10),
          Option(text: 'Sadece sıvı yakıt', score: 0),
          Option(text: 'Sadece ısı enerjisi', score: 0),
        ],
        category: 'Enerji',
      ),
      Question(
        text: 'Biokütle enerjisi projelerinde land use change (arazi kullanım değişimi) riski nedir?',
        options: [
          Option(text: 'Sadece ekonomik etki', score: 0),
          Option(text: 'Gıda üretimi alanlarının enerji bitkileri için kullanılması', score: 10),
          Option(text: 'Sadece çevresel etki', score: 0),
          Option(text: 'Sadece sosyal etki', score: 0),
        ],
        category: 'Enerji',
      ),
      Question(
        text: 'Biokütle enerjisi üretiminde co-firing (birlikte yakma) tekniği ne anlama gelir?',
        options: [
          Option(text: 'Sadece biokütle yakmak', score: 0),
          Option(text: 'Kömür ile biokütle karışımını birlikte yakmak', score: 10),
          Option(text: 'Sadece kömür yakmak', score: 0),
          Option(text: 'Sadece gaz yakmak', score: 0),
        ],
        category: 'Enerji',
      ),
      Question(
        text: 'Biokütle enerjisi sistemlerinde ash content (kül içeriği) neden önemlidir?',
        options: [
          Option(text: 'Sadece maliyet etkisi', score: 0),
          Option(text: 'Yanma verimliliği ve atık yönetimi', score: 10),
          Option(text: 'Sadece estetik görünüm', score: 0),
          Option(text: 'Sadece güvenlik', score: 0),
        ],
        category: 'Enerji',
      ),
      Question(
        text: 'Biokütle enerjisinde sustainable forestry (sürdürülebilir ormancılık) prensipleri nelerdir?',
        options: [
          Option(text: 'Sadece ağaç kesme', score: 0),
          Option(text: 'Kesilen ağaç kadar yeniden dikme ve ekosistem koruma', score: 10),
          Option(text: 'Sadece hızlı büyüme', score: 0),
          Option(text: 'Sadece maliyet optimizasyonu', score: 0),
        ],
        category: 'Enerji',
      ),
      Question(
        text: 'Biokütle yakıtlarda torrefaction (kavurma) işleminin amacı nedir?',
        options: [
          Option(text: 'Yakıtı kokulaştırmak', score: 0),
          Option(text: 'Nem ve uçucu maddeleri azaltarak enerji yoğunluğunu artırmak', score: 10),
          Option(text: 'Yakıtı renklendirmek', score: 0),
          Option(text: 'Yakıtı sertleştirmek', score: 0),
        ],
        category: 'Enerji',
      ),
      Question(
        text: 'Biokütle enerjisi projelerinde life cycle assessment (yaşam döngüsü değerlendirmesi) neden önemlidir?',
        options: [
          Option(text: 'Sadece maliyet hesabı', score: 0),
          Option(text: 'Üretimden bertarafına kadar tüm çevresel etkileri değerlendirmek', score: 10),
          Option(text: 'Sadece güvenlik değerlendirmesi', score: 0),
          Option(text: 'Sadece kalite değerlendirmesi', score: 0),
        ],
        category: 'Enerji',
      ),
      Question(
        text: 'Biokütle enerjisinde feed-in tariff (geri ödeme tarifesi) sistemi nasıl çalışır?',
        options: [
          Option(text: 'Sadece sabit fiyat ödeme', score: 0),
          Option(text: 'Üretilen enerjiye sabit fiyattan satın alma garantisi', score: 10),
          Option(text: 'Sadece değişken fiyat ödeme', score: 0),
          Option(text: 'Sadece prim ödeme sistemi', score: 0),
        ],
        category: 'Enerji',
      ),
      Question(
        text: 'Biokütle enerjisinde biochar (biokömür) kullanımının faydası nedir?',
        options: [
          Option(text: 'Sadece enerji üretimi', score: 0),
          Option(text: 'Toprak iyileştirme ve karbon depolama', score: 10),
          Option(text: 'Sadece atık azaltımı', score: 0),
          Option(text: 'Sadece maliyet azaltımı', score: 0),
        ],
        category: 'Enerji',
      ),
      Question(
        text: 'Biokütle enerjisi sistemlerinde air pollutant emissions (hava kirletici emisyonlar) hangi faktörlere bağlıdır?',
        options: [
          Option(text: 'Sadece yakıt cinsi', score: 0),
          Option(text: 'Yanma sıcaklığı, oksijen seviyesi ve yakıt kalitesi', score: 10),
          Option(text: 'Sadece sistem boyutu', score: 0),
          Option(text: 'Sadece maliyet', score: 0),
        ],
        category: 'Enerji',
      ),
      Question(
        text: 'Biokütle enerjisinde cascade use (basamaklı kullanım) prensibi nedir?',
        options: [
          Option(text: 'Sadece enerji üretimi için kullanmak', score: 0),
          Option(text: 'Önce malzeme olarak, son enerji olarak kullanmak', score: 10),
          Option(text: 'Sadece tek amaçlı kullanım', score: 0),
          Option(text: 'Sadece doğrudan yakma', score: 0),
        ],
        category: 'Enerji',
      ),
      Question(
        text: 'Biokütle enerjisi projelerinde certification (sertifikasyon) sistemlerinin önemi nedir?',
        options: [
          Option(text: 'Sadece pazarlama aracı', score: 0),
          Option(text: 'Sürdürülebilirlik ve kalite standartlarını garanti etmek', score: 10),
          Option(text: 'Sadece maliyet artırımı', score: 0),
          Option(text: 'Sadece yasal zorunluluk', score: 0),
        ],
        category: 'Enerji',
      ),
      Question(
        text: 'Biokütle enerjisinde biomass-to-liquid (BTL) teknolojisi hangi yakıtı üretir?',
        options: [
          Option(text: 'Sadece elektrik', score: 0),
          Option(text: 'Sentez yakıtı (sentez gazından sıvı yakıt)', score: 10),
          Option(text: 'Sadece metan', score: 0),
          Option(text: 'Sadece hidrojen', score: 0),
        ],
        category: 'Enerji',
      ),
      Question(
        text: 'Biokütle enerjisinde sustainability criteria (sürdürülebilirlik kriterleri) hangi alanları kapsar?',
        options: [
          Option(text: 'Sadece ekonomik faktörler', score: 0),
          Option(text: 'Çevresel, sosyal ve ekonomik etki değerlendirmesi', score: 10),
          Option(text: 'Sadece teknik faktörler', score: 0),
          Option(text: 'Sadece yasal uygunluk', score: 0),
        ],
        category: 'Enerji',
      ),

      // Jeotermal Enerji (25 soru)
      Question(
        text: 'Jeotermal enerji nedir?',
        options: [
          Option(text: 'Güneş\'ten gelen ısı enerjisi', score: 0),
          Option(text: 'Yer kabuğunun derinliklerinden gelen doğal ısı enerjisi', score: 10),
          Option(text: 'Rüzgar enerjisinin dönüşümü', score: 0),
          Option(text: 'Okyanus dalgalarından elde edilen enerji', score: 0),
        ],
        category: 'Enerji',
      ),
      Question(
        text: 'Jeotermal enerji sistemlerinde kullanılan geothermal gradient (jeotermal gradyan) ne anlama gelir?',
        options: [
          Option(text: 'Yeraltı suyu seviyesi', score: 0),
          Option(text: 'Derinlikle birlikte sıcaklık artış oranı', score: 10),
          Option(text: 'Yer kabuğu kalınlığı', score: 0),
          Option(text: 'Manyetik alan şiddeti', score: 0),
        ],
        category: 'Enerji',
      ),
      Question(
        text: 'Jeotermal enerji sistemlerinde enhanced geothermal system (EGS) ne anlama gelir?',
        options: [
          Option(text: 'Doğal jeotermal kaynakları güçlendirme teknolojisi', score: 10),
          Option(text: 'Sadece yüzey jeotermal sistemler', score: 0),
          Option(text: 'Sadece deniz jeotermal sistemler', score: 0),
          Option(text: 'Sadece kırsal jeotermal sistemler', score: 0),
        ],
        category: 'Enerji',
      ),
      Question(
        text: 'Jeotermal enerji santrallerinde binary cycle (ikili döngü) sistemi nasıl çalışır?',
        options: [
          Option(text: 'Tek akışkan kullanır', score: 0),
          Option(text: 'Jeotermal suyu ikincil akışkanla ısı transferi yapar', score: 10),
          Option(text: 'Sadece doğrudan buhar kullanır', score: 0),
          Option(text: 'Sadece kuru buhar kullanır', score: 0),
        ],
        category: 'Enerji',
      ),
      Question(
        text: 'Jeotermal enerji sistemlerinde reservoir (rezervuar) nedir?',
        options: [
          Option(text: 'Sadece su depolama alanı', score: 0),
          Option(text: 'Sıcak su ve buharın bulunduğu jeolojik formasyon', score: 10),
          Option(text: 'Sadece gaz depolama alanı', score: 0),
          Option(text: 'Sadece mineral depolama alanı', score: 0),
        ],
        category: 'Enerji',
      ),
      Question(
        text: 'Jeotermal enerji projelerinde exploration (keşif) aşaması hangi aktiviteleri içerir?',
        options: [
          Option(text: 'Sadece harita çıkarma', score: 0),
          Option(text: 'Jeolojik araştırma, sismik çalışma ve sondaj', score: 10),
          Option(text: 'Sadece çevre değerlendirmesi', score: 0),
          Option(text: 'Sadece sosyal etki analizi', score: 0),
        ],
        category: 'Enerji',
      ),
      Question(
        text: 'Jeotermal enerji sistemlerinde reinjection (geri enjeksiyon) işleminin amacı nedir?',
        options: [
          Option(text: 'Sadece maliyet azaltımı', score: 0),
          Option(text: 'Rezervuar basıncını korumak ve sürdürülebilirlik sağlamak', score: 10),
          Option(text: 'Sadece çevre koruması', score: 0),
          Option(text: 'Sadece enerji artırımı', score: 0),
        ],
        category: 'Enerji',
      ),
      Question(
        text: 'Jeotermal enerji santrallerinde dry steam (kuru buhar) sistemleri hangi koşullarda kullanılır?',
        options: [
          Option(text: 'Düşük sıcaklık ve düşük basınçta', score: 0),
          Option(text: 'Yüksek sıcaklıkta doğrudan buhar üretimi', score: 10),
          Option(text: 'Sadece sıvı su bulunan alanlarda', score: 0),
          Option(text: 'Sadece gaz fazlı sistemlerde', score: 0),
        ],
        category: 'Enerji',
      ),
      Question(
        text: 'Jeotermal enerji sistemlerinde flash steam (ani buharlaşma) teknolojisi nasıl çalışır?',
        options: [
          Option(text: 'Sadece sıcak suyu ısıtmak', score: 0),
          Option(text: 'Yüksek basınçlı sıcak suyun aniden buharlaştırılması', score: 10),
          Option(text: 'Sadece soğutma yapmak', score: 0),
          Option(text: 'Sadece gaz üretmek', score: 0),
        ],
        category: 'Enerji',
      ),
      Question(
        text: 'Jeotermal enerji projelerinde environmental impact (çevresel etki) hangi faktörleri içerir?',
        options: [
          Option(text: 'Sadece hava kirliliği', score: 0),
          Option(text: 'Su kirliliği, toprak kirliliği ve gürültü', score: 10),
          Option(text: 'Sadece görsel etki', score: 0),
          Option(text: 'Sadece ekonomik etki', score: 0),
        ],
        category: 'Enerji',
      ),
      Question(
        text: 'Jeotermal enerji sistemlerinde capacity factor (kapasite faktörü) oranı genellikle yüzde kaçtır?',
        options: [
          Option(text: '%20-30', score: 0),
          Option(text: '%70-95', score: 10),
          Option(text: '%50-60', score: 0),
          Option(text: '%10-15', score: 0),
        ],
        category: 'Enerji',
      ),
      Question(
        text: 'Jeotermal enerji sistemlerinde heat exchanger (ısı değiştirici) neden kullanılır?',
        options: [
          Option(text: 'Sadece sıcaklığı ölçmek', score: 0),
          Option(text: 'Jeotermal akışkanı temiz tutmak ve türbini korumak', score: 10),
          Option(text: 'Sadece basınç kontrolü', score: 0),
          Option(text: 'Sadece akış hızını artırmak', score: 0),
        ],
        category: 'Enerji',
      ),
      Question(
        text: 'Jeotermal enerji projelerinde drilling (sondaj) derinliği genellikle kaç metredir?',
        options: [
          Option(text: '100-500 metre', score: 0),
          Option(text: '1-5 kilometre', score: 10),
          Option(text: '10-20 kilometre', score: 0),
          Option(text: '50-100 metre', score: 0),
        ],
        category: 'Enerji',
      ),
      Question(
        text: 'Jeotermal enerji sistemlerinde scaling (ölçeklenme) sorunu nedir?',
        options: [
          Option(text: 'Sadece maliyet artışı', score: 0),
          Option(text: 'Mineral birikintilerinin ekipman performansını düşürmesi', score: 10),
          Option(text: 'Sadece verimlilik kaybı', score: 0),
          Option(text: 'Sadece güvenlik sorunu', score: 0),
        ],
        category: 'Enerji',
      ),
      Question(
        text: 'Jeotermal enerji santrallerinde cooling tower (soğutma kulesi) nasıl çalışır?',
        options: [
          Option(text: 'Sadece suyu soğutur', score: 0),
          Option(text: 'Kondenser suyunu soğutarak verimliliği artırır', score: 10),
          Option(text: 'Sadece hava akımı sağlar', score: 0),
          Option(text: 'Sadece buhar üretir', score: 0),
        ],
        category: 'Enerji',
      ),
      Question(
        text: 'Jeotermal enerji projelerinde induced seismicity (indüklenmiş sismik aktivite) riski hangi sistemlerde vardır?',
        options: [
          Option(text: 'Sadece düşük sıcaklık sistemleri', score: 0),
          Option(text: 'Enhanced Geothermal System (EGS) projeleri', score: 10),
          Option(text: 'Sadece doğal jeotermal sistemler', score: 0),
          Option(text: 'Sadece küçük ölçekli sistemler', score: 0),
        ],
        category: 'Enerji',
      ),
      Question(
        text: 'Jeotermal enerji sistemlerinde geothermal district heating (jeotermal bölgesel ısıtma) nasıl çalışır?',
        options: [
          Option(text: 'Sadece elektrik üretimi', score: 0),
          Option(text: 'Merkezi jeotermal enerjiyle birden fazla binayı ısıtmak', score: 10),
          Option(text: 'Sadece soğutma hizmeti', score: 0),
          Option(text: 'Sadece endüstriyel proses ısıtması', score: 0),
        ],
        category: 'Enerji',
      ),
      Question(
        text: 'Jeotermal enerji projelerinde feasibility study (fizibilite çalışması) hangi faktörleri değerlendirir?',
        options: [
          Option(text: 'Sadece teknik fizibilite', score: 0),
          Option(text: 'Kaynak kalitesi, teknik fizibilite ve ekonomik uygunluk', score: 10),
          Option(text: 'Sadece çevresel etki', score: 0),
          Option(text: 'Sadece sosyal etki', score: 0),
        ],
        category: 'Enerji',
      ),
      Question(
        text: 'Jeotermal enerji sistemlerinde downhole heat exchanger (kuyu içi ısı değiştirici) ne işe yarar?',
        options: [
          Option(text: 'Sadece su seviyesini ölçmek', score: 0),
          Option(text: 'Yeraltı suyunu ısıtmak veya soğutmak', score: 10),
          Option(text: 'Sadece basınç ölçmek', score: 0),
          Option(text: 'Sadece akış hızını kontrol etmek', score: 0),
        ],
        category: 'Enerji',
      ),
      Question(
        text: 'Jeotermal enerji santrallerinde retrofit (yenileme) projelerinin amacı nedir?',
        options: [
          Option(text: 'Sadece maliyet azaltımı', score: 0),
          Option(text: 'Mevcut sistemi modernize ederek verimlilik artırmak', score: 10),
          Option(text: 'Sadece güvenlik iyileştirmesi', score: 0),
          Option(text: 'Sadece kapasite artırımı', score: 0),
        ],
        category: 'Enerji',
      ),
      Question(
        text: 'Jeotermal enerji sistemlerinde geothermal energy storage (jeotermal enerji depolama) nasıl çalışır?',
        options: [
          Option(text: 'Sadece elektrik depolama', score: 0),
          Option(text: 'Fazla jeotermal enerjiyi mevsimsel depolamada kullanma', score: 10),
          Option(text: 'Sadece su depolama', score: 0),
          Option(text: 'Sadece mineral depolama', score: 0),
        ],
        category: 'Enerji',
      ),
      Question(
        text: 'Jeotermal enerji projelerinde public acceptance (halk kabulü) hangi faktörlere bağlıdır?',
        options: [
          Option(text: 'Sadece ekonomik faydalar', score: 0),
          Option(text: 'Çevresel etki, ekonomik fayda ve sosyal fayda', score: 10),
          Option(text: 'Sadece teknik güvenilirlik', score: 0),
          Option(text: 'Sadece maliyet', score: 0),
        ],
        category: 'Enerji',
      ),
      Question(
        text: 'Jeotermal enerji sistemlerinde heat pump (ısı pompası) teknolojisi nasıl çalışır?',
        options: [
          Option(text: 'Sadece elektrik tüketir', score: 0),
          Option(text: 'Yer altından ısı çekerek verimli ısıtma/soğutma sağlar', score: 10),
          Option(text: 'Sadece hava ısıtır', score: 0),
          Option(text: 'Sadece su ısıtır', score: 0),
        ],
        category: 'Enerji',
      ),
      Question(
        text: 'Jeotermal enerji santrallerinde maintenance strategy (bakım stratejisi) hangi yaklaşımı benimser?',
        options: [
          Option(text: 'Sadece arıza sonrası bakım', score: 0),
          Option(text: 'Önleyici ve tahminli bakım kombinasyonu', score: 10),
          Option(text: 'Sadece planlı bakım', score: 0),
          Option(text: 'Sadece değişim bakımı', score: 0),
        ],
        category: 'Enerji',
      ),
    ];
  }
}