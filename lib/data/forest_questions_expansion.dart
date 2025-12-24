// lib/data/forest_questions_expansion.dart
// Orman Teması için 200 Ek Soru

import '../models/question.dart';
import '../services/language_service.dart';

class ForestQuestionsExpansion {
  static List<Question> getTurkishForestQuestions() {
    return [
      // Orman Ekosistemi ve Biyoçeşitlilik (40 soru)
      Question(
        text: 'Orman ekosistemi nedir?',
        options: [
          Option(text: 'Sadece ağaçlar', score: 0),
          Option(text: 'Ağaçlar, bitkiler, hayvanlar ve mikroorganizmaların oluşturduğu karmaşık sistem', score: 10),
          Option(text: 'Sadece toprak', score: 0),
          Option(text: 'Sadece su kaynakları', score: 0),
        ],
        category: 'Orman',
      ),
      Question(
        text: 'Orman ekosisteminde karbon döngüsünün önemi nedir?',
        options: [
          Option(text: 'Sadece oksijen üretimi', score: 0),
          Option(text: 'CO₂ tutma ve iklim düzenleme', score: 10),
          Option(text: 'Sadece besin üretimi', score: 0),
          Option(text: 'Sadece su döngüsü', score: 0),
        ],
        category: 'Orman',
      ),
      Question(
        text: 'Ormanlarda biyoçeşitlilik neden bu kadar yüksek?',
        options: [
          Option(text: 'Sadece iklim koşulları', score: 0),
          Option(text: 'Karmaşık habitat yapısı ve besin ağları', score: 10),
          Option(text: 'Sadece toprak kalitesi', score: 0),
          Option(text: 'Sadece su varlığı', score: 0),
        ],
        category: 'Orman',
      ),
      Question(
        text: 'Orman ekosisteminde canopy (taç örtüsü) ne işe yarar?',
        options: [
          Option(text: 'Sadece gölge sağlama', score: 0),
          Option(text: 'Yağmur tutma, rüzgar koruması ve mikroklima yaratma', score: 10),
          Option(text: 'Sadece estetik görünüm', score: 0),
          Option(text: 'Sadece hayvan barınağı', score: 0),
        ],
        category: 'Orman',
      ),
      Question(
        text: 'Orman tabanında humus katmanının önemi nedir?',
        options: [
          Option(text: 'Sadece toprak rengi', score: 0),
          Option(text: 'Besin maddesi sağlama ve su tutma kapasitesi', score: 10),
          Option(text: 'Sadece estetik', score: 0),
          Option(text: 'Sadece böcek barınağı', score: 0),
        ],
        category: 'Orman',
      ),
      Question(
        text: 'Orman ekosistemi hizmetleri nelerdir?',
        options: [
          Option(text: 'Sadece odun üretimi', score: 0),
          Option(text: 'Karbon tutma, su döngüsü, oksijen üretimi ve yaşam alanı', score: 10),
          Option(text: 'Sadece rekreasyon', score: 0),
          Option(text: 'Sadece gölge', score: 0),
        ],
        category: 'Orman',
      ),
      Question(
        text: 'Ormanlarda mycorhiza (mantarların kök sistemi ile simbiyozu) nasıl çalışır?',
        options: [
          Option(text: 'Sadece toprak parçalama', score: 0),
          Option(text: 'Besin alışverişi ve su emilimini artırma', score: 10),
          Option(text: 'Sadece çürütme', score: 0),
          Option(text: 'Sadece hastalık yayma', score: 0),
        ],
        category: 'Orman',
      ),
      Question(
        text: 'Orman ekosisteminin successional development (süksesyonel gelişim) aşamaları nelerdir?',
        options: [
          Option(text: 'Sadece büyüme', score: 0),
          Option(text: 'Pionir türler, ara aşama ve klimaks toplulukları', score: 10),
          Option(text: 'Sadece yaşlanma', score: 0),
          Option(text: 'Sadece çoğalma', score: 0),
        ],
        category: 'Orman',
      ),
      Question(
        text: 'Orman ekosisteminde herbivory (otçul etkisi) ne kadar önemlidir?',
        options: [
          Option(text: 'Sadece ağaç yeme', score: 0),
          Option(text: 'Bitki çeşitliliğini koruma ve besin döngüsünü destekleme', score: 10),
          Option(text: 'Sadece zarar verme', score: 0),
          Option(text: 'Sadece nüfus kontrolü', score: 0),
        ],
        category: 'Orman',
      ),
      Question(
        text: 'Ormanlarda edge effects (kenar etkileri) nelerdir?',
        options: [
          Option(text: 'Sadece görsel etki', score: 0),
          Option(text: 'Habitat değişimi, tür kompozisyonu ve mikroklima farklılıkları', score: 10),
          Option(text: 'Sadece ses etkisi', score: 0),
          Option(text: 'Sadece renk etkisi', score: 0),
        ],
        category: 'Orman',
      ),
      Question(
        text: 'Orman ekosisteminin resilience (dirençlilik) özelliği nedir?',
        options: [
          Option(text: 'Sadece güçlü olmak', score: 0),
          Option(text: 'Bozulmalardan sonra kendini yenileyebilme kapasitesi', score: 10),
          Option(text: 'Sadece dayanıklılık', score: 0),
          Option(text: 'Sadece büyüme', score: 0),
        ],
        category: 'Orman',
      ),
      Question(
        text: 'Ormanlarda keystone species (temel tür) ne demektir?',
        options: [
          Option(text: 'Sadece büyük hayvanlar', score: 0),
          Option(text: 'Ekosistemin işleyişi için kritik öneme sahip türler', score: 10),
          Option(text: 'Sadece nadır türler', score: 0),
          Option(text: 'Sadece yırtıcı türler', score: 0),
        ],
        category: 'Orman',
      ),
      Question(
        text: 'Orman ekosisteminde nutrient cycling (besin döngüsü) nasıl çalışır?',
        options: [
          Option(text: 'Sadece bitki büyümesi', score: 0),
          Option(text: 'Organik maddelerin ayrıştırılması ve yeniden kullanımı', score: 10),
          Option(text: 'Sadece su taşınması', score: 0),
          Option(text: 'Sadece toprak oluşumu', score: 0),
        ],
        category: 'Orman',
      ),
      Question(
        text: 'Ormanlarda disturbance (bozulma) türleri nelerdir?',
        options: [
          Option(text: 'Sadece insan etkisi', score: 0),
          Option(text: 'Yangın, fırtına, hastalık ve doğal afetler', score: 10),
          Option(text: 'Sadece hayvan etkisi', score: 0),
          Option(text: 'Sadece iklim değişimi', score: 0),
        ],
        category: 'Orman',
      ),
      Question(
        text: 'Orman ekosisteminde trophic levels (besin seviyeleri) nasıl organize olur?',
        options: [
          Option(text: 'Sadece bitki ve hayvan', score: 0),
          Option(text: 'Üreticiler, tüketiciler ve ayrıştırıcılar', score: 10),
          Option(text: 'Sadece büyük ve küçük', score: 0),
          Option(text: 'Sadece yırtıcı ve av', score: 0),
        ],
        category: 'Orman',
      ),
      Question(
        text: 'Ormanlarda mycorrhizal networks (mantarlı ağ) nasıl çalışır?',
        options: [
          Option(text: 'Sadece toprak bağlama', score: 0),
          Option(text: 'Ağaçlar arası besin ve iletişim ağı', score: 10),
          Option(text: 'Sadece su iletimi', score: 0),
          Option(text: 'Sadece oksijen taşıma', score: 0),
        ],
        category: 'Orman',
      ),
      Question(
        text: 'Orman ekosisteminde ecological corridors (ekolojik koridorlar) ne işe yarar?',
        options: [
          Option(text: 'Sadece yol', score: 0),
          Option(text: 'Türlerin hareketi ve genetik çeşitliliğin korunması', score: 10),
          Option(text: 'Sadece estetik', score: 0),
          Option(text: 'Sadece rekreasyon', score: 0),
        ],
        category: 'Orman',
      ),
      Question(
        text: 'Ormanlarda decomposition (ayrışma) sürecinin önemi nedir?',
        options: [
          Option(text: 'Sadece çöp temizleme', score: 0),
          Option(text: 'Besin döngüsü ve toprak verimliliği', score: 10),
          Option(text: 'Sadece koku giderme', score: 0),
          Option(text: 'Sadece yer açma', score: 0),
        ],
        category: 'Orman',
      ),
      Question(
        text: 'Orman ekosisteminde carrying capacity (taşıma kapasitesi) ne anlama gelir?',
        options: [
          Option(text: 'Sadece alan büyüklüğü', score: 0),
          Option(text: 'Ekosistemin destekleyebileceği maksimum popülasyon', score: 10),
          Option(text: 'Sadece ağaç sayısı', score: 0),
          Option(text: 'Sadece su miktarı', score: 0),
        ],
        category: 'Orman',
      ),
      Question(
        text: 'Ormanlarda secondary succession (ikincil süksesyon) nasıl başlar?',
        options: [
          Option(text: 'Sadece tohumdan', score: 0),
          Option(text: 'Mevcut toprak ve tohum bankasından yeniden başlama', score: 10),
          Option(text: 'Sadece rüzgardan', score: 0),
          Option(text: 'Sadece hayvanlardan', score: 0),
        ],
        category: 'Orman',
      ),
      Question(
        text: 'Orman ekosisteminde competitive exclusion (rekabet dışlama) ilkesi nedir?',
        options: [
          Option(text: 'Sadece güçlü kazanır', score: 0),
          Option(text: 'Aynı kaynak için rekabet eden türlerden birinin baskın olması', score: 10),
          Option(text: 'Sadece hızlı olan kazanır', score: 0),
          Option(text: 'Sadece büyük olan kazanır', score: 0),
        ],
        category: 'Orman',
      ),
      Question(
        text: 'Ormanlarda pioneer species (pionir türler) hangi özelliklere sahiptir?',
        options: [
          Option(text: 'Sadece hızlı büyür', score: 0),
          Option(text: 'Zorlu koşullara dayanıklı, hızlı çoğalan türler', score: 10),
          Option(text: 'Sadece büyük boyutlu', score: 0),
          Option(text: 'Sadece uzun ömürlü', score: 0),
        ],
        category: 'Orman',
      ),
      Question(
        text: 'Orman ekosisteminin biodiversity hotspot (biyoçeşitlilik sıcak noktası) olması ne demektir?',
        options: [
          Option(text: 'Sadece çok tür olması', score: 0),
          Option(text: 'Yüksek tür çeşitliliği ve endemik türlerin bulunması', score: 10),
          Option(text: 'Sadece büyük alan', score: 0),
          Option(text: 'Sadece yoğun nüfus', score: 0),
        ],
        category: 'Orman',
      ),
      Question(
        text: 'Ormanlarda ecological balance (ekolojik denge) nasıl korunur?',
        options: [
          Option(text: 'Sadece koruma', score: 0),
          Option(text: 'Türler arası etkileşimler ve doğal döngüler', score: 10),
          Option(text: 'Sadece az sayıda tür', score: 0),
          Option(text: 'Sadece büyük hayvanlar', score: 0),
        ],
        category: 'Orman',
      ),

      // Orman Koruma ve Yönetim (40 soru)
      Question(
        text: 'Sürdürülebilir ormancılık nedir?',
        options: [
          Option(text: 'Sadece ağaç kesimi', score: 0),
          Option(text: 'Gelecek nesillerin ihtiyaçlarını tehlikeye atmadan orman yönetimi', score: 10),
          Option(text: 'Sadece ağaç dikme', score: 0),
          Option(text: 'Sadece koruma', score: 0),
        ],
        category: 'Orman',
      ),
      Question(
        text: 'Selective cutting (seçici kesim) yöntemi nasıl çalışır?',
        options: [
          Option(text: 'Tüm ağaçları kesme', score: 0),
          Option(text: 'Belirli ağaçları seçerek kesim ve doğal yenilenmeyi destekleme', score: 10),
          Option(text: 'Sadece hastalıklı ağaçlar', score: 0),
          Option(text: 'Sadece yaşlı ağaçlar', score: 0),
        ],
        category: 'Orman',
      ),
      Question(
        text: 'Orman yangınlarını önleme stratejileri nelerdir?',
        options: [
          Option(text: 'Sadece yangın söndürme', score: 0),
          Option(text: 'Kontrollü yakma, yangın şeritleri ve erken uyarı sistemleri', score: 10),
          Option(text: 'Sadece ağaç dikme', score: 0),
          Option(text: 'Sadece bölge kapatma', score: 0),
        ],
        category: 'Orman',
      ),
      Question(
        text: 'Ağaçlandırma projelerinde hangi faktörler başarıyı etkiler?',
        options: [
          Option(text: 'Sadece tohum sayısı', score: 0),
          Option(text: 'Uygun tür seçimi, toprak hazırlığı ve bakım programı', score: 10),
          Option(text: 'Sadece maliyet', score: 0),
          Option(text: 'Sadece zaman', score: 0),
        ],
        category: 'Orman',
      ),
      Question(
        text: 'Orman ekosistemindeki biyoçeşitliliği korumak için neler yapılmalı?',
        options: [
          Option(text: 'Sadece ağaç dikme', score: 0),
          Option(text: 'Doğal habitatları koruma, tür çeşitliliğini destekleme ve ekolojik koridorlar', score: 10),
          Option(text: 'Sadece av yasağı', score: 0),
          Option(text: 'Sadece bölge kapatma', score: 0),
        ],
        category: 'Orman',
      ),
      Question(
        text: 'Agroforestry (tarım ormancılığı) sistemleri nasıl çalışır?',
        options: [
          Option(text: 'Sadece ağaç dikme', score: 0),
          Option(text: 'Ağaçlar ve tarım ürünlerini entegre etme ile sürdürülebilir üretim', score: 10),
          Option(text: 'Sadece orman tarımı', score: 0),
          Option(text: 'Sadece hayvancılık', score: 0),
        ],
        category: 'Orman',
      ),
      Question(
        text: 'Ormanlarda su döngüsüne ağaçların katkısı nedir?',
        options: [
          Option(text: 'Sadece su tüketimi', score: 0),
          Option(text: 'Transpirasyon, yeraltı suyu beslemesi ve erozyon kontrolü', score: 10),
          Option(text: 'Sadece yağmur tutma', score: 0),
          Option(text: 'Sadece akış düzenleme', score: 0),
        ],
        category: 'Orman',
      ),
      Question(
        text: 'Orman ekosistemi hizmetleri nelerdir?',
        options: [
          Option(text: 'Sadece odun üretimi', score: 0),
          Option(text: 'Karbon tutma, su döngüsü, biyoçeşitlilik ve iklim düzenleme', score: 10),
          Option(text: 'Sadece rekreasyon', score: 0),
          Option(text: 'Sadece hammadde', score: 0),
        ],
        category: 'Orman',
      ),
      Question(
        text: 'Çölleşme ile mücadelede ağaçlandırmanın rolü nedir?',
        options: [
          Option(text: 'Sadece gölge sağlama', score: 0),
          Option(text: 'Toprak stabilizasyonu, nem artırma ve mikroklima iyileştirme', score: 10),
          Option(text: 'Sadece rüzgar koruması', score: 0),
          Option(text: 'Sadece estetik', score: 0),
        ],
        category: 'Orman',
      ),
      Question(
        text: 'Orman yangınları sonrası rehabilitation (rehabilitasyon) nasıl yapılır?',
        options: [
          Option(text: 'Sadece yeni ağaç dikme', score: 0),
          Option(text: 'Toprak analizi, uygun tür seçimi ve uzun vadeli izleme', score: 10),
          Option(text: 'Sadece gübreleme', score: 0),
          Option(text: 'Sadece sulama', score: 0),
        ],
        category: 'Orman',
      ),
      Question(
        text: 'Ormanlarda ecosystem restoration (ekosistem restorasyonu) prensipleri nelerdir?',
        options: [
          Option(text: 'Sadece ağaç dikme', score: 0),
          Option(text: 'Doğal süreçleri destekleme, yerel türleri kullanma ve uzun vadeli bakım', score: 10),
          Option(text: 'Sadece hızlı büyüyen türler', score: 0),
          Option(text: 'Sadece ekonomik türler', score: 0),
        ],
        category: 'Orman',
      ),
      Question(
        text: 'Orman yönetiminde climate change adaptation (iklim değişikliği uyumu) nasıl sağlanır?',
        options: [
          Option(text: 'Sadece dayanıklı türler', score: 0),
          Option(text: 'Çeşitli türler, esnek yönetim ve adaptif stratejiler', score: 10),
          Option(text: 'Sadece koruma alanları', score: 0),
          Option(text: 'Sadece izleme', score: 0),
        ],
        category: 'Orman',
      ),
      Question(
        text: 'Urban forestry (kent ormancılığı) faydaları nelerdir?',
        options: [
          Option(text: 'Sadece estetik', score: 0),
          Option(text: 'Hava kalitesi, sıcaklık düşürme, gürültü azaltma ve yaşam kalitesi', score: 10),
          Option(text: 'Sadece gölge', score: 0),
          Option(text: 'Sadece oksijen', score: 0),
        ],
        category: 'Orman',
      ),
      Question(
        text: 'Ormanlarda illegal logging (yasadışı ağaç kesimi) nasıl önlenir?',
        options: [
          Option(text: 'Sadece devriye', score: 0),
          Option(text: 'Teknolojik izleme, yasal düzenlemeler ve toplumsal katılım', score: 10),
          Option(text: 'Sadece ceza', score: 0),
          Option(text: 'Sadece bilgilendirme', score: 0),
        ],
        category: 'Orman',
      ),
      Question(
        text: 'Orman ekosisteminde carbon sequestration (karbon tutma) kapasitesi nasıl artırılır?',
        options: [
          Option(text: 'Sadece hızlı büyüyen ağaçlar', score: 0),
          Option(text: 'Yaşlı orman koruma, çeşitli türler ve uzun vadeli planlama', score: 10),
          Option(text: 'Sadece yoğun dikim', score: 0),
          Option(text: 'Sadece gübreleme', score: 0),
        ],
        category: 'Orman',
      ),
      Question(
        text: 'Orman yangın riskini azaltmak için landscape planning (manzara planlaması) nasıl yapılır?',
        options: [
          Option(text: 'Sadece yangın şeritleri', score: 0),
          Option(text: 'Yangın dirençli türler, bölgeleme ve koridor sistemleri', score: 10),
          Option(text: 'Sadece bariyerler', score: 0),
          Option(text: 'Sadece su kaynakları', score: 0),
        ],
        category: 'Orman',
      ),
      Question(
        text: 'Orman ekosistemlerinde keşfedilmemiş türlerin korunması neden önemlidir?',
        options: [
          Option(text: 'Sadece bilimsel merak', score: 0),
          Option(text: 'Potansiyel faydalar, ekosistem denge ve genetik çeşitlilik', score: 10),
          Option(text: 'Sadece estetik değer', score: 0),
          Option(text: 'Sadece eğitim', score: 0),
        ],
        category: 'Orman',
      ),
      Question(
        text: 'Ormanlarda soil erosion (toprak erozyonu) önleme yöntemleri nelerdir?',
        options: [
          Option(text: 'Sadece ağaç dikme', score: 0),
          Option(text: 'Kök sistemleri, örtü bitkileri ve teraslama teknikleri', score: 10),
          Option(text: 'Sadece gübreleme', score: 0),
          Option(text: 'Sadece sulama', score: 0),
        ],
        category: 'Orman',
      ),
      Question(
        text: 'Orman ekosistemlerinde native species (yerel türler) neden tercih edilir?',
        options: [
          Option(text: 'Sadece ucuzluk', score: 0),
          Option(text: 'Uyum sağlamış ekosistem, az bakım ihtiyacı ve biyoçeşitlilik', score: 10),
          Option(text: 'Sadece hızlı büyüme', score: 0),
          Option(text: 'Sadece dayanıklılık', score: 0),
        ],
        category: 'Orman',
      ),
      Question(
        text: 'Orman yönetiminde community participation (toplum katılımı) nasıl sağlanır?',
        options: [
          Option(text: 'Sadece bilgilendirme', score: 0),
          Option(text: 'Eğitim programları, gelir fırsatları ve karar alma süreçlerine katılım', score: 10),
          Option(text: 'Sadece teşvikler', score: 0),
          Option(text: 'Sadece yasal düzenlemeler', score: 0),
        ],
        category: 'Orman',
      ),
      Question(
        text: 'Orman ekosistemlerinde invasive species (zararlı türler) ile mücadele nasıl yapılır?',
        options: [
          Option(text: 'Sadece kimyasal ilaç', score: 0),
          Option(text: 'Erken tespit, biyolojik mücadele ve ekolojik yöntemler', score: 10),
          Option(text: 'Sadece elle toplama', score: 0),
          Option(text: 'Sadece yakma', score: 0),
        ],
        category: 'Orman',
      ),
      Question(
        text: 'Ormanlarda sustainable tourism (sürdürülebilir turizm) nasıl geliştirilir?',
        options: [
          Option(text: 'Sadece altyapı geliştirme', score: 0),
          Option(text: 'Çevre dostu tesisler, sınırlı ziyaretçi sayısı ve eğitim programları', score: 10),
          Option(text: 'Sadece rekreasyon alanları', score: 0),
          Option(text: 'Sadece konaklama tesisleri', score: 0),
        ],
        category: 'Orman',
      ),
      Question(
        text: 'Orman ekosistemlerinde long-term monitoring (uzun vadeli izleme) nasıl yapılır?',
        options: [
          Option(text: 'Sadece periyodik kontrol', score: 0),
          Option(text: 'Bilimsel metodoloji, veri toplama ve analiz sistemleri', score: 10),
          Option(text: 'Sadece görsel inceleme', score: 0),
          Option(text: 'Sadece fotoğraf çekme', score: 0),
        ],
        category: 'Orman',
      ),
      Question(
        text: 'Orman yönetiminde ecosystem-based approach (ekosistem temelli yaklaşım) nedir?',
        options: [
          Option(text: 'Sadece ağaç odaklı', score: 0),
          Option(text: 'Tüm ekosistemin işleyişini anlayıp bütüncül yönetim', score: 10),
          Option(text: 'Sadece koruma alanları', score: 0),
          Option(text: 'Sadece ekonomik değer', score: 0),
        ],
        category: 'Orman',
      ),
      Question(
        text: 'Ormanlarda forest certification (orman sertifikasyonu) neden önemlidir?',
        options: [
          Option(text: 'Sadece pazarlama', score: 0),
          Option(text: 'Sürdürülebilir yönetim standartlarını garanti etme', score: 10),
          Option(text: 'Sadece fiyat artışı', score: 0),
          Option(text: 'Sadece prestij', score: 0),
        ],
        category: 'Orman',
      ),
      Question(
        text: 'Orman ekosistemi sağlığının değerlendirilmesinde hangi göstergeler kullanılır?',
        options: [
          Option(text: 'Sadece ağaç sayısı', score: 0),
          Option(text: 'Biyokütle, tür çeşitliliği, toprak kalitesi ve su döngüsü', score: 10),
          Option(text: 'Sadece alan büyüklüğü', score: 0),
          Option(text: 'Sadece yaş', score: 0),
        ],
        category: 'Orman',
      ),

      // İklim Değişikliği ve Orman (40 soru)
      Question(
        text: 'Ormanlar iklim değişikliği ile mücadelede nasıl rol oynar?',
        options: [
          Option(text: 'Sadece CO₂ emme', score: 0),
          Option(text: 'Karbon depolama, iklim düzenleme ve ekolojik denge koruma', score: 10),
          Option(text: 'Sadece oksijen üretimi', score: 0),
          Option(text: 'Sadece gölge sağlama', score: 0),
        ],
        category: 'Orman',
      ),
      Question(
        text: 'Climate-resilient forestry (iklime dayanıklı ormancılık) nedir?',
        options: [
          Option(text: 'Sadece dayanıklı ağaçlar', score: 0),
          Option(text: 'Değişen iklim koşullarına uyum sağlayabilen orman yönetimi', score: 10),
          Option(text: 'Sadece koruma', score: 0),
          Option(text: 'Sadece izleme', score: 0),
        ],
        category: 'Orman',
      ),
      Question(
        text: 'Orman yangınları ile iklim değişikliği arasındaki ilişki nedir?',
        options: [
          Option(text: 'Sadece sıcaklık etkisi', score: 0),
          Option(text: 'Kuraklık artışı, daha sık ve şiddetli yangınlar', score: 10),
          Option(text: 'Sadece rüzgar etkisi', score: 0),
          Option(text: 'Sadece nem etkisi', score: 0),
        ],
        category: 'Orman',
      ),
      Question(
        text: 'Orman ekosisteminin climate regulation (iklim düzenleme) kapasitesi nasıl çalışır?',
        options: [
          Option(text: 'Sadece buhar üretimi', score: 0),
          Option(text: 'Su döngüsü, albedo etkisi ve enerji dengelemesi', score: 10),
          Option(text: 'Sadece rüzgar kırma', score: 0),
          Option(text: 'Sadece sıcaklık azaltma', score: 0),
        ],
        category: 'Orman',
      ),
      Question(
        text: 'Reduces deforestation (orman tahribatını azaltma) projelerinin iklim etkisi nedir?',
        options: [
          Option(text: 'Sadece ağaç koruma', score: 0),
          Option(text: 'Karbon salınımını azaltma ve ekosistem hizmetlerini koruma', score: 10),
          Option(text: 'Sadece biodiversite', score: 0),
          Option(text: 'Sadece turizm', score: 0),
        ],
        category: 'Orman',
      ),
      Question(
        text: 'Orman ekosistemlerinde feedback loops (geri besleme döngüleri) nasıl çalışır?',
        options: [
          Option(text: 'Sadece ağaç büyümesi', score: 0),
          Option(text: 'İklim, orman ve atmosfer arasındaki karşılıklı etkileşimler', score: 10),
          Option(text: 'Sadece su döngüsü', score: 0),
          Option(text: 'Sadece toprak oluşumu', score: 0),
        ],
        category: 'Orman',
      ),
      Question(
        text: 'Forest degradation (orman bozulması) iklim üzerindeki etkileri nelerdir?',
        options: [
          Option(text: 'Sadece ağaç kaybı', score: 0),
          Option(text: 'Karbon salınımı, su döngüsü bozulması ve mikroklima değişiklikleri', score: 10),
          Option(text: 'Sadece toprak kaybı', score: 0),
          Option(text: 'Sadece hayvan kaybı', score: 0),
        ],
        category: 'Orman',
      ),
      Question(
        text: 'Ormanlarda climate smart forestry (iklim akıllı ormancılık) nasıl uygulanır?',
        options: [
          Option(text: 'Sadece modern teknoloji', score: 0),
          Option(text: 'Adaptasyon, mitigasyon ve gıda güvenliği entegrasyonu', score: 10),
          Option(text: 'Sadece ağaç türü değişimi', score: 0),
          Option(text: 'Sadece koruma', score: 0),
        ],
        category: 'Orman',
      ),
      Question(
        text: 'Orman ekosistemlerinin climate tipping points (iklim dönüm noktaları) nelerdir?',
        options: [
          Option(text: 'Sadece sıcaklık artışı', score: 0),
          Option(text: 'Ormanın geri dönüşü olmayan değişime uğradığı eşik değerler', score: 10),
          Option(text: 'Sadece kuraklık', score: 0),
          Option(text: 'Sadece yangın', score: 0),
        ],
        category: 'Orman',
      ),
      Question(
        text: 'Orman kaynaklı karbon piyasası nasıl çalışır?',
        options: [
          Option(text: 'Sadece ağaç satışı', score: 0),
          Option(text: 'Karbon kredisi ticareti ve offset programları', score: 10),
          Option(text: 'Sadece sertifikasyon', score: 0),
          Option(text: 'Sadece vergilendirme', score: 0),
        ],
        category: 'Orman',
      ),
      Question(
        text: 'Ormanların albedo (yansıtma) etkisi iklim üzerinde nasıl rol oynar?',
        options: [
          Option(text: 'Sadece ışık yansıtma', score: 0),
          Option(text: 'Güneş enerjisinin yansıtılması ve ısı dengelemesi', score: 10),
          Option(text: 'Sadece gölge', score: 0),
          Option(text: 'Sadece buharlaşma', score: 0),
        ],
        category: 'Orman',
      ),
      Question(
        text: 'Ormanlarda drought tolerance (kuraklık toleransı) nasıl geliştirilir?',
        options: [
          Option(text: 'Sadece sulama', score: 0),
          Option(text: 'Kuraklığa dayanıklı tür seçimi ve su yönetimi', score: 10),
          Option(text: 'Sadece gübreleme', score: 0),
          Option(text: 'Sadece ilaçlama', score: 0),
        ],
        category: 'Orman',
      ),
      Question(
        text: 'Orman ekosistemlerinde phenology (fenoloji) değişiklikleri nelerdir?',
        options: [
          Option(text: 'Sadece çiçeklenme zamanı', score: 0),
          Option(text: 'Mevsimsel döngülerin iklim değişikliği ile değişmesi', score: 10),
          Option(text: 'Sadece yaprak dökme', score: 0),
          Option(text: 'Sadece meyve verme', score: 0),
        ],
        category: 'Orman',
      ),
      Question(
        text: 'Orman yönetiminde adaptation measures (uyum önlemleri) nelerdir?',
        options: [
          Option(text: 'Sadece koruma', score: 0),
          Option(text: 'Tür çeşitliliği, esnek yönetim ve risk azaltma', score: 10),
          Option(text: 'Sadece teknoloji', score: 0),
          Option(text: 'Sadece yasal düzenleme', score: 0),
        ],
        category: 'Orman',
      ),
      Question(
        text: 'Orman ekosistemlerinin climate mitigation (iklim azaltımı) potansiyeli nedir?',
        options: [
          Option(text: 'Sadece CO₂ tutma', score: 0),
          Option(text: 'Karbon depolama, enerji tasarrufu ve ekosistem hizmetleri', score: 10),
          Option(text: 'Sadece oksijen üretimi', score: 0),
          Option(text: 'Sadece su döngüsü', score: 0),
        ],
        category: 'Orman',
      ),
      Question(
        text: 'Ormanlarda climate vulnerability (iklim kırılganlığı) nasıl değerlendirilir?',
        options: [
          Option(text: 'Sadece sıcaklık', score: 0),
          Option(text: 'Hassasiyet, maruziyet ve adaptasyon kapasitesi analizi', score: 10),
          Option(text: 'Sadece yağış', score: 0),
          Option(text: 'Sadece rüzgar', score: 0),
        ],
        category: 'Orman',
      ),
      Question(
        text: 'Orman ekosistemlerinde extreme weather events (aşırı hava olayları) etkileri nelerdir?',
        options: [
          Option(text: 'Sadece fiziksel hasar', score: 0),
          Option(text: 'Yapısal değişim, tür kompozisyonu ve ekolojik süreç bozulmaları', score: 10),
          Option(text: 'Sadece ekonomik kayıp', score: 0),
          Option(text: 'Sadece sosyal etki', score: 0),
        ],
        category: 'Orman',
      ),
      Question(
        text: 'Orman yönetiminde climate-informed decisions (iklime dayalı kararlar) nasıl alınır?',
        options: [
          Option(text: 'Sadece deneyim', score: 0),
          Option(text: 'Bilimsel veri, projeksiyonlar ve risk değerlendirmesi', score: 10),
          Option(text: 'Sadece gelenek', score: 0),
          Option(text: 'Sadece ekonomi', score: 0),
        ],
        category: 'Orman',
      ),
      Question(
        text: 'Orman ekosistemlerinde climate refugia (iklim sığınakları) nedir?',
        options: [
          Option(text: 'Sadece koruma alanları', score: 0),
          Option(text: 'İklim değişikliğinden etkilenmeyen veya az etkilenen alanlar', score: 10),
          Option(text: 'Sadece dağlık alanlar', score: 0),
          Option(text: 'Sadece kıyı alanları', score: 0),
        ],
        category: 'Orman',
      ),
      Question(
        text: 'Ormanlarda carbon density (karbon yoğunluğu) nasıl artırılır?',
        options: [
          Option(text: 'Sadece daha fazla ağaç', score: 0),
          Option(text: 'Uzun ömürlü türler, yoğunluk artırma ve uzun vadeli koruma', score: 10),
          Option(text: 'Sadece gübreleme', score: 0),
          Option(text: 'Sadece sulama', score: 0),
        ],
        category: 'Orman',
      ),
      Question(
        text: 'Orman ekosistemlerinde temperature regulation (sıcaklık düzenleme) nasıl çalışır?',
        options: [
          Option(text: 'Sadece gölge', score: 0),
          Option(text: 'Transpirasyon, albedo etkisi ve mikroklima oluşturma', score: 10),
          Option(text: 'Sadece rüzgar', score: 0),
          Option(text: 'Sadece nem', score: 0),
        ],
        category: 'Orman',
      ),
      Question(
        text: 'Orman yönetiminde climate risk assessment (iklim riski değerlendirmesi) neden önemlidir?',
        options: [
          Option(text: 'Sadece sigorta', score: 0),
          Option(text: 'Potansiyel etkileri öngörme ve hazırlıklı olma', score: 10),
          Option(text: 'Sadece planlama', score: 0),
          Option(text: 'Sadece bütçe', score: 0),
        ],
        category: 'Orman',
      ),
      Question(
        text: 'Orman ekosistemlerinin climate change resilience (iklim değişikliği dirençliliği) nasıl güçlendirilir?',
        options: [
          Option(text: 'Sadece ağaç dikme', score: 0),
          Option(text: 'Tür çeşitliliği, ekolojik koridorlar ve esnek yönetim', score: 10),
          Option(text: 'Sadece teknoloji', score: 0),
          Option(text: 'Sadece koruma', score: 0),
        ],
        category: 'Orman',
      ),
      Question(
        text: 'Ormanlarda climate monitoring (iklim izleme) sistemleri nelerdir?',
        options: [
          Option(text: 'Sadece sıcaklık ölçümü', score: 0),
          Option(text: 'Hava durumu istasyonları, sensör ağları ve uydu gözlemi', score: 10),
          Option(text: 'Sadece yağış ölçümü', score: 0),
          Option(text: 'Sadece rüzgar ölçümü', score: 0),
        ],
        category: 'Orman',
      ),
      Question(
        text: 'Orman ekosistemlerinin climate services (iklim hizmetleri) sunması ne anlama gelir?',
        options: [
          Option(text: 'Sadece karbon depolama', score: 0),
          Option(text: 'İklim düzenleme, su yönetimi ve afet koruma hizmetleri', score: 10),
          Option(text: 'Sadece oksijen üretimi', score: 0),
          Option(text: 'Sadece gölge', score: 0),
        ],
        category: 'Orman',
      ),
      Question(
        text: 'Ormanlarda climate change impacts (iklim değişikliği etkileri) nasıl yönetilir?',
        options: [
          Option(text: 'Sadece zarar gören ağaçları kesme', score: 0),
          Option(text: 'Risk azaltma, adaptasyon ve restore etme stratejileri', score: 10),
          Option(text: 'Sadece koruma', score: 0),
          Option(text: 'Sadece yenileme', score: 0),
        ],
        category: 'Orman',
      ),

      // Teknoloji ve Orman Yönetimi (40 soru)
      Question(
        text: 'Remote sensing (uzaktan algılama) orman yönetiminde nasıl kullanılır?',
        options: [
          Option(text: 'Sadece fotoğraf çekme', score: 0),
          Option(text: 'Uydu görüntüleri ile orman izleme, haritalama ve analiz', score: 10),
          Option(text: 'Sadece hava fotoğrafı', score: 0),
          Option(text: 'Sadece radar', score: 0),
        ],
        category: 'Orman',
      ),
      Question(
        text: 'Geographic Information Systems (GIS) orman yönetiminde ne işe yarar?',
        options: [
          Option(text: 'Sadece harita çizme', score: 0),
          Option(text: 'Mekansal analiz, planlama ve karar destek sistemleri', score: 10),
          Option(text: 'Sadece konum belirleme', score: 0),
          Option(text: 'Sadece navigasyon', score: 0),
        ],
        category: 'Orman',
      ),
      Question(
        text: 'Drone (insansız hava aracı) teknolojisi ormancılıkta nasıl kullanılır?',
        options: [
          Option(text: 'Sadece fotoğraf çekme', score: 0),
          Option(text: 'Hava kalitesi ölçümü, ağaç sayımı ve yangın tespiti', score: 10),
          Option(text: 'Sadece video çekme', score: 0),
          Option(text: 'Sadece gözetim', score: 0),
        ],
        category: 'Orman',
      ),
      Question(
        text: 'LiDAR (Light Detection and Ranging) teknolojisi orman araştırmalarında nasıl çalışır?',
        options: [
          Option(text: 'Sadece mesafe ölçümü', score: 0),
          Option(text: 'Lazer ışınları ile 3D orman yapısı haritalama', score: 10),
          Option(text: 'Sadece yükseklik ölçümü', score: 0),
          Option(text: 'Sadece hız ölçümü', score: 0),
        ],
        category: 'Orman',
      ),
      Question(
        text: 'Orman yangınlarında early warning system (erken uyarı sistemi) nasıl çalışır?',
        options: [
          Option(text: 'Sadece kamera', score: 0),
          Option(text: 'Sensörler, uydu verileri ve yapay zeka analizi', score: 10),
          Option(text: 'Sadece radar', score: 0),
          Option(text: 'Sadece sıcaklık ölçümü', score: 0),
        ],
        category: 'Orman',
      ),
      Question(
        text: 'Forest inventory (orman envanteri) nasıl yapılır?',
        options: [
          Option(text: 'Sadece ağaç sayma', score: 0),
          Option(text: 'Sistematik örnekleme, ölçüm ve veri analizi', score: 10),
          Option(text: 'Sadece gözlem', score: 0),
          Option(text: 'Sadece tahmin', score: 0),
        ],
        category: 'Orman',
      ),
      Question(
        text: 'Orman sağlığı izleme sistemlerinde hangi teknolojiler kullanılır?',
        options: [
          Option(text: 'Sadece gözle kontrol', score: 0),
          Option(text: 'Sensörler, uydu verileri ve biyolojik izleme', score: 10),
          Option(text: 'Sadece örnek alma', score: 0),
          Option(text: 'Sadece laboratuvar testi', score: 0),
        ],
        category: 'Orman',
      ),
      Question(
        text: 'Precision forestry (hassas ormancılık) nedir?',
        options: [
          Option(text: 'Sadece hassas ölçüm', score: 0),
          Option(text: 'Teknoloji destekli hassas planlama ve uygulama', score: 10),
          Option(text: 'Sadece GPS kullanımı', score: 0),
          Option(text: 'Sadece bilgisayar', score: 0),
        ],
        category: 'Orman',
      ),
      Question(
        text: 'Orman yönetiminde artificial intelligence (yapay zeka) nasıl kullanılır?',
        options: [
          Option(text: 'Sadece veri işleme', score: 0),
          Option(text: 'Pattern tanıma, tahmin ve karar destek sistemleri', score: 10),
          Option(text: 'Sadece otomatik kontrol', score: 0),
          Option(text: 'Sadece raporlama', score: 0),
        ],
        category: 'Orman',
      ),
      Question(
        text: 'Satellite imagery (uydu görüntüleri) ile orman değişiklikleri nasıl izlenir?',
        options: [
          Option(text: 'Sadece görsel karşılaştırma', score: 0),
          Option(text: 'Zaman serisi analizi ve spektral değerlendirme', score: 10),
          Option(text: 'Sadece boyut ölçümü', score: 0),
          Option(text: 'Sadece renk analizi', score: 0),
        ],
        category: 'Orman',
      ),
      Question(
        text: 'Orman ekosistemlerinde IoT (Nesnelerin İnterneti) uygulamaları nelerdir?',
        options: [
          Option(text: 'Sadece sensör ağı', score: 0),
          Option(text: 'Gerçek zamanlı izleme, veri toplama ve analiz', score: 10),
          Option(text: 'Sadece kablosuz iletişim', score: 0),
          Option(text: 'Sadece otomasyon', score: 0),
        ],
        category: 'Orman',
      ),
      Question(
        text: 'Forest modeling (orman modelleme) nedir?',
        options: [
          Option(text: 'Sadece matematiksel hesap', score: 0),
          Option(text: 'Orman dinamiklerini simüle eden bilgisayar modelleri', score: 10),
          Option(text: 'Sadece grafik çizme', score: 0),
          Option(text: 'Sadece plan yapma', score: 0),
        ],
        category: 'Orman',
      ),
      Question(
        text: 'Orman yangınlarında fire behavior modeling (yangın davranış modelleme) nasıl çalışır?',
        options: [
          Option(text: 'Sadece deneyim', score: 0),
          Option(text: 'Meteorolojik veriler ve yanıcı madde analizi', score: 10),
          Option(text: 'Sadece tarihsel veri', score: 0),
          Option(text: 'Sadece uydu verisi', score: 0),
        ],
        category: 'Orman',
      ),
      Question(
        text: 'Forest health monitoring (orman sağlığı izleme) sistemlerinde hangi göstergeler takip edilir?',
        options: [
          Option(text: 'Sadece ağaç sayısı', score: 0),
          Option(text: 'Hastalık belirtileri, zararlı yoğunluğu ve stres göstergeleri', score: 10),
          Option(text: 'Sadece yaprak rengi', score: 0),
          Option(text: 'Sadece büyüme hızı', score: 0),
        ],
        category: 'Orman',
      ),
      Question(
        text: 'Orman yönetiminde decision support systems (karar destek sistemleri) nasıl çalışır?',
        options: [
          Option(text: 'Sadece veri saklama', score: 0),
          Option(text: 'Çoklu kriter analizi ve optimizasyon algoritmaları', score: 10),
          Option(text: 'Sadece rapor üretme', score: 0),
          Option(text: 'Sadece grafik çizme', score: 0),
        ],
        category: 'Orman',
      ),
      Question(
        text: 'Orman araştırmalarında spectral analysis (spektral analiz) nasıl kullanılır?',
        options: [
          Option(text: 'Sadece renk ölçümü', score: 0),
          Option(text: 'Bitki sağlığı, tür tanıma ve stres tespiti', score: 10),
          Option(text: 'Sadece parlaklık ölçümü', score: 0),
          Option(text: 'Sadece kontrast ölçümü', score: 0),
        ],
        category: 'Orman',
      ),
      Question(
        text: 'Orman ekosistemi simülasyonları nasıl oluşturulur?',
        options: [
          Option(text: 'Sadece basit hesap', score: 0),
          Option(text: 'Ekolojik süreçler ve etkileşimlerin matematiksel modellemesi', score: 10),
          Option(text: 'Sadece istatistik', score: 0),
          Option(text: 'Sadece grafik', score: 0),
        ],
        category: 'Orman',
      ),
      Question(
        text: 'Forest certification technology (orman sertifikasyon teknolojisi) nasıl çalışır?',
        options: [
          Option(text: 'Sadece kağıt işlem', score: 0),
          Option(text: 'Blockchain, izlenebilirlik ve dijital sertifikasyon', score: 10),
          Option(text: 'Sadece barkod', score: 0),
          Option(text: 'Sadece QR kod', score: 0),
        ],
        category: 'Orman',
      ),
      Question(
        text: 'Orman yangınları için predictive analytics (tahmine dayalı analitik) nasıl kullanılır?',
        options: [
          Option(text: 'Sadece geçmiş veri', score: 0),
          Option(text: 'Makine öğrenmesi ile risk tahmini ve senaryo analizi', score: 10),
          Option(text: 'Sadece mevsimsel pattern', score: 0),
          Option(text: 'Sadece hava durumu', score: 0),
        ],
        category: 'Orman',
      ),
      Question(
        text: 'Orman yönetiminde mobile applications (mobil uygulamalar) hangi amaçlarla kullanılır?',
        options: [
          Option(text: 'Sadece oyun', score: 0),
          Option(text: 'Veri toplama, konum belirleme ve saha yönetimi', score: 10),
          Option(text: 'Sadece iletişim', score: 0),
          Option(text: 'Sadece navigasyon', score: 0),
        ],
        category: 'Orman',
      ),
      Question(
        text: 'Orman ekosistemlerinde environmental sensors (çevresel sensörler) neleri ölçer?',
        options: [
          Option(text: 'Sadece sıcaklık', score: 0),
          Option(text: 'İklim, toprak, su kalitesi ve biyolojik parametreler', score: 10),
          Option(text: 'Sadece nem', score: 0),
          Option(text: 'Sadece rüzgar', score: 0),
        ],
        category: 'Orman',
      ),
      Question(
        text: 'Orman araştırmalarında machine learning (makine öğrenmesi) uygulamaları nelerdir?',
        options: [
          Option(text: 'Sadece veri analizi', score: 0),
          Option(text: 'Pattern tanıma, sınıflandırma ve tahmin modelleri', score: 10),
          Option(text: 'Sadece otomasyon', score: 0),
          Option(text: 'Sadece optimizasyon', score: 0),
        ],
        category: 'Orman',
      ),
      Question(
        text: 'Orman yönetiminde digital twins (dijital ikizler) nasıl oluşturulur?',
        options: [
          Option(text: 'Sadece 3D model', score: 0),
          Option(text: 'Gerçek zamanlı verilerle senkronize dijital kopya', score: 10),
          Option(text: 'Sadece simülasyon', score: 0),
          Option(text: 'Sadece animasyon', score: 0),
        ],
        category: 'Orman',
      ),
      Question(
        text: 'Orman ekosistemlerinde citizen science (vatandaş bilimi) projeleri nasıl çalışır?',
        options: [
          Option(text: 'Sadece eğitim', score: 0),
          Option(text: 'Halk katılımı ile veri toplama ve bilimsel araştırma', score: 10),
          Option(text: 'Sadece gönüllülük', score: 0),
          Option(text: 'Sadece sosyal medya', score: 0),
        ],
        category: 'Orman',
      ),
      Question(
        text: 'Orman yönetiminde blockchain teknolojisi nasıl kullanılır?',
        options: [
          Option(text: 'Sadece kripto para', score: 0),
          Option(text: 'Tedarik zinciri şeffaflığı ve izlenebilirlik', score: 10),
          Option(text: 'Sadece akıllı sözleşmeler', score: 0),
          Option(text: 'Sadece dijital para', score: 0),
        ],
        category: 'Orman',
      ),
      Question(
        text: 'Orman araştırmalarında big data (büyük veri) analizi nasıl yapılır?',
        options: [
          Option(text: 'Sadece çok veri', score: 0),
          Option(text: 'Çoklu kaynaklı veri entegrasyonu ve analitik', score: 10),
          Option(text: 'Sadece hızlı işlem', score: 0),
          Option(text: 'Sadece depolama', score: 0),
        ],
        category: 'Orman',
      ),
      Question(
        text: 'Orman ekosistemi monitoring (izleme) ağları nasıl kurulur?',
        options: [
          Option(text: 'Sadece sensör', score: 0),
          Option(text: 'Dağıtık sensör ağı, veri iletişimi ve koordinasyon', score: 10),
          Option(text: 'Sadece GPS', score: 0),
          Option(text: 'Sadece internet', score: 0),
        ],
        category: 'Orman',
      ),
      Question(
        text: 'Orman yönetiminde virtual reality (sanal gerçeklik) uygulamaları nelerdir?',
        options: [
          Option(text: 'Sadece oyun', score: 0),
          Option(text: 'Eğitim, planlama görselleştirme ve deneyimleme', score: 10),
          Option(text: 'Sadece eğlence', score: 0),
          Option(text: 'Sadece görselleştirme', score: 0),
        ],
        category: 'Orman',
      ),
    ];
  }
}