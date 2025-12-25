// lib/data/consumption_questions_expansion.dart
// Tüketim Teması için 200 Ek Soru

import '../models/question.dart';

class ConsumptionQuestionsExpansion {
  static List<Question> getTurkishConsumptionQuestions() {
    return [
      // Sürdürülebilir Tüketim (50 soru)
      Question(
        text: 'Sürdürülebilir tüketim nedir?',
        options: [
          Option(text: 'Sadece az tüketim', score: 0),
          Option(text: 'İhtiyaçları karşılarken gelecek nesillerin kaynaklarını koruma', score: 10),
          Option(text: 'Sadece organik ürün', score: 0),
          Option(text: 'Sadece ucuz ürün', score: 0),
        ],
        category: 'Tüketim',
      ),
      Question(
        text: 'Sustainable consumption patterns (sürdürülebilir tüketim kalıpları) nasıl değiştirilir?',
        options: [
          Option(text: 'Sadece yasal düzenlemeler', score: 0),
          Option(text: 'Eğitim, teşvik sistemleri, alternatif çözümler ve toplumsal normlar', score: 10),
          Option(text: 'Sadece vergi artışı', score: 0),
          Option(text: 'Sadece kampanya', score: 0),
        ],
        category: 'Tüketim',
      ),
      Question(
        text: 'Consumption footprint (tüketim ayak izi) nasıl hesaplanır?',
        options: [
          Option(text: 'Sadece harcama miktarı', score: 0),
          Option(text: 'Ürün yaşam döngüsü, enerji tüketimi ve atık üretimi', score: 10),
          Option(text: 'Sadece nakliye mesafesi', score: 0),
          Option(text: 'Sadece ambalaj miktarı', score: 0),
        ],
        category: 'Tüketim',
      ),
      Question(
        text: 'Consumer empowerment (tüketici güçlendirme) nasıl sağlanır?',
        options: [
          Option(text: 'Sadece bilgi erişimi', score: 0),
          Option(text: 'Eğitim programları, hak bilinci ve karar verme araçları', score: 10),
          Option(text: 'Sadece indirim kartı', score: 0),
          Option(text: 'Sadece sadakat programı', score: 0),
        ],
        category: 'Tüketim',
      ),
      Question(
        text: 'Value-based consumption (değer temelli tüketim) nasıl uygulanır?',
        options: [
          Option(text: 'Sadece pahalı ürünler', score: 0),
          Option(text: 'Kişisel değerlerle uyumlu, etkisi olan ve anlamlı seçimler', score: 10),
          Option(text: 'Sadece prestij', score: 0),
          Option(text: 'Sadece statü', score: 0),
        ],
        category: 'Tüketim',
      ),
      Question(
        text: 'Sustainable procurement (sürdürülebilir satın alma) kriterleri nelerdir?',
        options: [
          Option(text: 'Sadece düşük fiyat', score: 0),
          Option(text: 'Çevresel etki, sosyal sorumluluk ve yaşam döngüsü maliyeti', score: 10),
          Option(text: 'Sadece hızlı teslimat', score: 0),
          Option(text: 'Sadece kolay sipariş', score: 0),
        ],
        category: 'Tüketim',
      ),
      Question(
        text: 'Consumption habits transformation (tüketim alışkanlıkları dönüşümü) nasıl gerçekleştirilir?',
        options: [
          Option(text: 'Sadece bilgilendirme', score: 0),
          Option(text: 'Adım adım değişim, destek sistemleri ve sürekli motivasyon', score: 10),
          Option(text: 'Sadece zorlamalar', score: 0),
          Option(text: 'Sadece tek seferlik kampanya', score: 0),
        ],
        category: 'Tüketim',
      ),
      Question(
        text: 'Mindful consumption (bilinçli tüketim) pratikleri nelerdir?',
        options: [
          Option(text: 'Sadece meditasyon', score: 0),
          Option(text: 'İhtiyaç analizi, satın alma öncesi bekleme ve değer sorgulama', score: 10),
          Option(text: 'Sadece bütçe kontrolü', score: 0),
          Option(text: 'Sadece liste yapma', score: 0),
        ],
        category: 'Tüketim',
      ),
      Question(
        text: 'Circular business models (döngüsel iş modelleri) nelerdir?',
        options: [
          Option(text: 'Sadece geri dönüşüm', score: 0),
          Option(text: 'Paylaşım, ürün hizmetleştirme ve kaynak geri kazanımı', score: 10),
          Option(text: 'Sadece enerji verimliliği', score: 0),
          Option(text: 'Sadece atık azaltımı', score: 0),
        ],
        category: 'Tüketim',
      ),
      Question(
        text: 'Consumer behavior change (tüketici davranış değişikliği) nasıl sağlanır?',
        options: [
          Option(text: 'Sadece bilgilendirme', score: 0),
          Option(text: 'Motivasyon, sosyal etki, kolaylık ve sürekli teşvik', score: 10),
          Option(text: 'Sadece zorlamalar', score: 0),
          Option(text: 'Sadece fiyat artışı', score: 0),
        ],
        category: 'Tüketim',
      ),
      Question(
        text: 'Sustainable lifestyle choices (sürdürülebilir yaşam tarzı seçimleri) nelerdir?',
        options: [
          Option(text: 'Sadece çevre dostu ürünler', score: 0),
          Option(text: 'Bilinçli tüketim, az atık üretme ve sosyal sorumluluk', score: 10),
          Option(text: 'Sadece organik gıda', score: 0),
          Option(text: 'Sadece elektrikli araç', score: 0),
        ],
        category: 'Tüketim',
      ),
      Question(
        text: 'Greenwashing (yeşil boyama) nasıl tespit edilir?',
        options: [
          Option(text: 'Sadece logo kontrolü', score: 0),
          Option(text: 'Sertifika doğrulama, somut veriler ve şeffaflık analizi', score: 10),
          Option(text: 'Sadece fiyat karşılaştırması', score: 0),
          Option(text: 'Sadece marka araştırması', score: 0),
        ],
        category: 'Tüketim',
      ),
      Question(
        text: 'Ethical consumption (etik tüketim) kriterleri nelerdir?',
        options: [
          Option(text: 'Sadece hayırseverlik', score: 0),
          Option(text: 'Çalışma koşulları, çevresel etki ve sosyal sorumluluk', score: 10),
          Option(text: 'Sadece yerel üretim', score: 0),
          Option(text: 'Sadece organik sertifika', score: 0),
        ],
        category: 'Tüketim',
      ),
      Question(
        text: 'Product durability (ürün dayanıklılığı) nasıl artırılır?',
        options: [
          Option(text: 'Sadece malzeme kalitesi', score: 0),
          Option(text: 'Sağlam tasarım, bakım kolaylığı ve yedek parça erişimi', score: 10),
          Option(text: 'Sadece garanti süresi', score: 0),
          Option(text: 'Sadece marka değeri', score: 0),
        ],
        category: 'Tüketim',
      ),
      Question(
        text: 'Sustainable packaging (sürdürülebilir ambalaj) özellikleri nelerdir?',
        options: [
          Option(text: 'Sadece geri dönüştürülebilir', score: 0),
          Option(text: 'Geri dönüştürülebilir, biyolojik parçalanabilir ve minimal malzeme', score: 10),
          Option(text: 'Sadece kağıt', score: 0),
          Option(text: 'Sadece cam', score: 0),
        ],
        category: 'Tüketim',
      ),
      Question(
        text: 'Buy less, choose well (daha az al, iyi seç) yaklaşımı nasıl uygulanır?',
        options: [
          Option(text: 'Sadece fiyat karşılaştırması', score: 0),
          Option(text: 'İhtiyaç analizi, kalite değerlendirmesi ve uzun vadeli kullanım', score: 10),
          Option(text: 'Sadece indirim takibi', score: 0),
          Option(text: 'Sadece trend analizi', score: 0),
        ],
        category: 'Tüketim',
      ),
      Question(
        text: 'Digital minimalism (dijital minimalizm) prensipleri nelerdir?',
        options: [
          Option(text: 'Sadece az uygulama', score: 0),
          Option(text: 'Teknoloji farkındalığı, bilinçli kullanım ve dijital detoks', score: 10),
          Option(text: 'Sadece eski cihazlar', score: 0),
          Option(text: 'Sadece çevrimdışı yaşam', score: 0),
        ],
        category: 'Tüketim',
      ),
      Question(
        text: 'Second-hand economy (ikinci el ekonomi) nasıl gelişir?',
        options: [
          Option(text: 'Sadece kalite sorunu', score: 0),
          Option(text: 'Kalite standartları, güven sistemleri ve değer yeniden tanımı', score: 10),
          Option(text: 'Sadece maliyet avantajı', score: 0),
          Option(text: 'Sadece nostalji', score: 0),
        ],
        category: 'Tüketim',
      ),
      Question(
        text: 'Sharing economy (paylaşım ekonomisi) modelleri nelerdir?',
        options: [
          Option(text: 'Sadece araç paylaşımı', score: 0),
          Option(text: 'Emlak, araç, araç-gereç ve bilgi paylaşım platformları', score: 10),
          Option(text: 'Sadece teknoloji', score: 0),
          Option(text: 'Sadece sosyal medya', score: 0),
        ],
        category: 'Tüketim',
      ),
      Question(
        text: 'Conscious consumption (bilinçli tüketim) kararları nasıl verilir?',
        options: [
          Option(text: 'Sadece fiyat odaklı', score: 0),
          Option(text: 'Etki analizi, değer sistemi ve uzun vadeli sonuçlar', score: 10),
          Option(text: 'Sadece marka tercihi', score: 0),
          Option(text: 'Sadece trend takibi', score: 0),
        ],
        category: 'Tüketim',
      ),
      Question(
        text: 'Slow fashion (yavaş moda) hareketinin prensipleri nelerdir?',
        options: [
          Option(text: 'Sadece pahalı ürünler', score: 0),
          Option(text: 'Kaliteli üretim, etik koşullar ve uzun ömürlü tasarım', score: 10),
          Option(text: 'Sadece yerel üretim', score: 0),
          Option(text: 'Sadece organik malzeme', score: 0),
        ],
        category: 'Tüketim',
      ),
      Question(
        text: 'Ürün yaşam döngüsü analizinde hangi aşamalar değerlendirilir?',
        options: [
          Option(text: 'Sadece üretim', score: 0),
          Option(text: 'Hammadde, üretim, kullanım ve bertaraf aşamaları', score: 10),
          Option(text: 'Sadece kullanım', score: 0),
          Option(text: 'Sadece bertaraf', score: 0),
        ],
        category: 'Tüketim',
      ),
      Question(
        text: 'Güvenli tüketim (safe consumption) için hangi kriterler önemlidir?',
        options: [
          Option(text: 'Sadece fiyat', score: 0),
          Option(text: 'Güvenlik standartları, içerik şeffaflığı ve sertifikalar', score: 10),
          Option(text: 'Sadece marka', score: 0),
          Option(text: 'Sadece ambalaj', score: 0),
        ],
        category: 'Tüketim',
      ),
      Question(
        text: 'Minimalist yaşam felsefesinin temel prensipleri nelerdir?',
        options: [
          Option(text: 'Sadece az eşya', score: 0),
          Option(text: 'Sahip olduklarını değerlendirme, kalite ve işlevsellik önceliği', score: 10),
          Option(text: 'Sadece maddi yoksunluk', score: 0),
          Option(text: 'Sadece ferah alan', score: 0),
        ],
        category: 'Tüketim',
      ),
      Question(
        text: 'Sustainable consumption education (sürdürülebilir tüketim eğitimi) nasıl verilir?',
        options: [
          Option(text: 'Sadece teorik bilgi', score: 0),
          Option(text: 'Pratik uygulamalar, örnekler ve yaşam deneyimi', score: 10),
          Option(text: 'Sadece kampanya', score: 0),
          Option(text: 'Sadece broşür', score: 0),
        ],
        category: 'Tüketim',
      ),
      Question(
        text: 'Consumer rights (tüketici hakları) nelerdir?',
        options: [
          Option(text: 'Sadece iade hakkı', score: 0),
          Option(text: 'Güvenli ürün, doğru bilgi, şeffaflık ve adil fiyat', score: 10),
          Option(text: 'Sadece garanti', score: 0),
          Option(text: 'Sadece servis', score: 0),
        ],
        category: 'Tüketim',
      ),
      Question(
        text: 'Ön yargılı tüketim (impulsive consumption) nasıl önlenir?',
        options: [
          Option(text: 'Sadece alışverişten kaçınma', score: 0),
          Option(text: 'Bekleme süresi, alternatif değerlendirme ve ihtiyaç analizi', score: 10),
          Option(text: 'Sadece bütçe sınırı', score: 0),
          Option(text: 'Sadece liste yapma', score: 0),
        ],
        category: 'Tüketim',
      ),
      Question(
        text: 'Sürdürülebilir marka (sustainable brand) nasıl tanınır?',
        options: [
          Option(text: 'Sadece yeşil renk', score: 0),
          Option(text: 'Somut çevresel çaba, şeffaflık ve sertifikalar', score: 10),
          Option(text: 'Sadece doğal ürün', score: 0),
          Option(text: 'Sadece organik logo', score: 0),
        ],
        category: 'Tüketim',
      ),
      Question(
        text: 'Tüketim çılgınlığı (consumerism) zararları nelerdir?',
        options: [
          Option(text: 'Sadece borçlanma', score: 0),
          Option(text: 'Çevre kirliliği, kaynak israfı ve mutsuzluk', score: 10),
          Option(text: 'Sadece maliyet', score: 0),
          Option(text: 'Sadece alan sorunu', score: 0),
        ],
        category: 'Tüketim',
      ),
      Question(
        text: 'Sustainable lifestyle (sürdürülebilir yaşam tarzı) faydaları nelerdir?',
        options: [
          Option(text: 'Sadece çevre koruma', score: 0),
          Option(text: 'Daha az stres, daha fazla zaman ve finansal tasarruf', score: 10),
          Option(text: 'Sadece prestij', score: 0),
          Option(text: 'Sadece sağlık', score: 0),
        ],
        category: 'Tüketim',
      ),
      Question(
        text: 'Tüketim alışkanlıklarını değiştirmek için etkili stratejiler nelerdir?',
        options: [
          Option(text: 'Sadece motivasyon', score: 0),
          Option(text: 'Küçük adımlar, sosyal destek ve olumlu pekiştirme', score: 10),
          Option(text: 'Sadece cezalandırma', score: 0),
          Option(text: 'Sadece bilgilendirme', score: 0),
        ],
        category: 'Tüketim',
      ),
      Question(
        text: 'Çevresel etki analizi (environmental impact analysis) nasıl yapılır?',
        options: [
          Option(text: 'Sadece ambalaj kontrolü', score: 0),
          Option(text: 'Yaşam döngüsü değerlendirmesi ve karbon ayak izi', score: 10),
          Option(text: 'Sadece geri dönüşüm', score: 0),
          Option(text: 'Sadece enerji tüketimi', score: 0),
        ],
        category: 'Tüketim',
      ),
      Question(
        text: 'Düşük karbonlu yaşam (low carbon living) nasıl sürdürülür?',
        options: [
          Option(text: 'Sadece elektrikli araç', score: 0),
          Option(text: 'Enerji verimliliği, sürdürülebilir ulaşım ve tüketim', score: 10),
          Option(text: 'Sadece güneş paneli', score: 0),
          Option(text: 'Sadece bisiklet', score: 0),
        ],
        category: 'Tüketim',
      ),
      Question(
        text: 'Tüketimde kalite vs miktar (quality vs quantity) dengesi nasıl kurulur?',
        options: [
          Option(text: 'Sadece ucuz ürünler', score: 0),
          Option(text: 'Dayanıklı, işlevsel ve anlamlı ürünlere öncelik verme', score: 10),
          Option(text: 'Sadece pahalı ürünler', score: 0),
          Option(text: 'Sadece marka ürünleri', score: 0),
        ],
        category: 'Tüketim',
      ),
      Question(
        text: 'Sürdürülebilir alışveriş stratejileri nelerdir?',
        options: [
          Option(text: 'Sadece indirim takibi', score: 0),
          Option(text: 'Planlı alışveriş, yerel üretimler ve mevsimsel ürünler', score: 10),
          Option(text: 'Sadece online alışveriş', score: 0),
          Option(text: 'Sadece toplu alışveriş', score: 0),
        ],
        category: 'Tüketim',
      ),
      Question(
        text: 'Tüketimde bağımlılık (consumption addiction) nasıl aşılır?',
        options: [
          Option(text: 'Sadece alışveriş yasağı', score: 0),
          Option(text: 'Duygusal farkındalık, alternatif aktiviteler ve destek sistemi', score: 10),
          Option(text: 'Sadece bütçe kontrolü', score: 0),
          Option(text: 'Sadece aile kontrolü', score: 0),
        ],
        category: 'Tüketim',
      ),
      Question(
        text: 'Ethical investing (etik yatırım) ile tüketim arasındaki bağlantı nedir?',
        options: [
          Option(text: 'Sadece para kazancı', score: 0),
          Option(text: 'Sosyal sorumluluk bilinci ve bilinçli tercihler', score: 10),
          Option(text: 'Sadece vergi avantajı', score: 0),
          Option(text: 'Sadece prestij', score: 0),
        ],
        category: 'Tüketim',
      ),
      Question(
        text: 'Sürdürülebilir tüketimde teknolojinin rolü nedir?',
        options: [
          Option(text: 'Sadece online alışveriş', score: 0),
          Option(text: 'Bilgi erişimi, alternatif çözümler ve izleme araçları', score: 10),
          Option(text: 'Sadece mobil uygulama', score: 0),
          Option(text: 'Sadece dijital ödeme', score: 0),
        ],
        category: 'Tüketim',
      ),
      Question(
        text: 'Tüketim alışkanlıklarının aile içinde aktarılması nasıl gerçekleşir?',
        options: [
          Option(text: 'Sadece genetik', score: 0),
          Option(text: 'Rol model olma, eğitim ve ortak deneyimler', score: 10),
          Option(text: 'Sadece zorlama', score: 0),
          Option(text: 'Sadece öğretme', score: 0),
        ],
        category: 'Tüketim',
      ),
      Question(
        text: 'Sürdürülebilir tüketimde toplumsal normların etkisi nedir?',
        options: [
          Option(text: 'Sadece reklam', score: 0),
          Option(text: 'Sosyal kabul, grup baskısı ve kültürel değerler', score: 10),
          Option(text: 'Sadece medya', score: 0),
          Option(text: 'Sadece celebrity', score: 0),
        ],
        category: 'Tüketim',
      ),
      Question(
        text: 'Tüketim kararlarında sosyal medyanın etkisi nasıl yönetilir?',
        options: [
          Option(text: 'Sadece sosyal medyadan kaçınma', score: 0),
          Option(text: 'Bilinçli kullanım, kaynak doğrulama ve eleştirel düşünme', score: 10),
          Option(text: 'Sadece filtre kullanma', score: 0),
          Option(text: 'Sadece takip etmeme', score: 0),
        ],
        category: 'Tüketim',
      ),
      Question(
        text: 'Sürdürülebilir tüketimde kültürel farklılıklar nelerdir?',
        options: [
          Option(text: 'Sadece coğrafya', score: 0),
          Option(text: 'Geleneksel değerler, ekonomik koşullar ve toplumsal yapı', score: 10),
          Option(text: 'Sadece din', score: 0),
          Option(text: 'Sadece dil', score: 0),
        ],
        category: 'Tüketim',
      ),
      Question(
        text: 'Tüketimde farkındalık (consumer awareness) nasıl artırılır?',
        options: [
          Option(text: 'Sadece eğitim', score: 0),
          Option(text: 'Deneyimleme, tartışma ve uygulama fırsatları', score: 10),
          Option(text: 'Sadece seminer', score: 0),
          Option(text: 'Sadece broşür', score: 0),
        ],
        category: 'Tüketim',
      ),
      Question(
        text: 'Sürdürülebilir tüketimde yerel ekonominin önemi nedir?',
        options: [
          Option(text: 'Sadece nakliye azaltma', score: 0),
          Option(text: 'Topluluk desteği, çevresel etki azaltma ve güvenilirlik', score: 10),
          Option(text: 'Sadece iş imkanı', score: 0),
          Option(text: 'Sadece kalite', score: 0),
        ],
        category: 'Tüketim',
      ),

      // Bilinçli Alışveriş ve Karar Verme (50 soru)
      Question(
        text: 'Informed decision making (bilgilendirilmiş karar verme) nasıl yapılır?',
        options: [
          Option(text: 'Sadece fiyat karşılaştırması', score: 0),
          Option(text: 'Araştırma, alternatif değerlendirme ve uzun vadeli sonuçlar', score: 10),
          Option(text: 'Sadece marka güveni', score: 0),
          Option(text: 'Sadece arkadaş tavsiyesi', score: 0),
        ],
        category: 'Tüketim',
      ),
      Question(
        text: 'Product lifecycle assessment (ürün yaşam döngüsü değerlendirmesi) neden önemlidir?',
        options: [
          Option(text: 'Sadece maliyet hesaplama', score: 0),
          Option(text: 'Çevresel etkileri tam olarak anlama ve karşılaştırma', score: 10),
          Option(text: 'Sadece kalite kontrolü', score: 0),
          Option(text: 'Sadece garanti süresi', score: 0),
        ],
        category: 'Tüketim',
      ),
      Question(
        text: 'Consumer research (tüketici araştırması) nasıl yapılır?',
        options: [
          Option(text: 'Sadece fiyat araştırması', score: 0),
          Option(text: 'Ürün özellikleri, kullanıcı deneyimleri ve etki analizi', score: 10),
          Option(text: 'Sadece marka araştırması', score: 0),
          Option(text: 'Sadece reklam araştırması', score: 0),
        ],
        category: 'Tüketim',
      ),
      Question(
        text: 'Sustainable product alternatives (sürdürülebilir ürün alternatifleri) nasıl bulunur?',
        options: [
          Option(text: 'Sadece internette arama', score: 0),
          Option(text: 'Sertifika kontrolü, alternatif analizi ve karşılaştırma', score: 10),
          Option(text: 'Sadece mağaza gezme', score: 0),
          Option(text: 'Sadece arkadaş soruşturma', score: 0),
        ],
        category: 'Tüketim',
      ),
      Question(
        text: 'Consumer protection (tüketici koruması) hakları nelerdir?',
        options: [
          Option(text: 'Sadece iade hakkı', score: 0),
          Option(text: 'Güvenli ürün, doğru bilgi, şikayet hakkı ve tazminat', score: 10),
          Option(text: 'Sadece değiştirme hakkı', score: 0),
          Option(text: 'Sadece garanti', score: 0),
        ],
        category: 'Tüketim',
      ),
      Question(
        text: 'Transparent labeling (şeffaf etiketleme) neden gereklidir?',
        options: [
          Option(text: 'Sadece yasal gereklilik', score: 0),
          Option(text: 'Tüketici bilgilendirme, bilinçli seçim ve güven', score: 10),
          Option(text: 'Sadece estetik', score: 0),
          Option(text: 'Sadece pazarlama', score: 0),
        ],
        category: 'Tüketim',
      ),
      Question(
        text: 'Responsible sourcing (sorumlu kaynak temini) nasıl değerlendirilir?',
        options: [
          Option(text: 'Sadece fiyat', score: 0),
          Option(text: 'Tedarik zinciri şeffaflığı, etik standartlar ve çevresel etki', score: 10),
          Option(text: 'Sadece hız', score: 0),
          Option(text: 'Sadece kalite', score: 0),
        ],
        category: 'Tüketim',
      ),
      Question(
        text: 'Consumer boycott (tüketici boykotu) nasıl etkili olur?',
        options: [
          Option(text: 'Sadece tek kişi', score: 0),
          Option(text: 'Toplumsal katılım, medya desteği ve sürdürülebilirlik', score: 10),
          Option(text: 'Sadece sosyal medya', score: 0),
          Option(text: 'Sadece haber', score: 0),
        ],
        category: 'Tüketim',
      ),
      Question(
        text: 'Product authenticity (ürün özgünlüğü) nasıl kontrol edilir?',
        options: [
          Option(text: 'Sadece görünüm', score: 0),
          Option(text: 'Sertifika, seri numarası, tedarikçi doğrulama', score: 10),
          Option(text: 'Sadece fiyat', score: 0),
          Option(text: 'Sadece mağaza', score: 0),
        ],
        category: 'Tüketim',
      ),
      Question(
        text: 'Fair trade (adil ticaret) ürünleri nasıl tanınır?',
        options: [
          Option(text: 'Sadece etiket', score: 0),
          Option(text: 'Sertifika, fiyat adaleti, çalışma koşulları ve çevresel standartlar', score: 10),
          Option(text: 'Sadece marka', score: 0),
          Option(text: 'Sadece menşe', score: 0),
        ],
        category: 'Tüketim',
      ),
      Question(
        text: 'Sustainable consumption tracking (sürdürülebilir tüketim takibi) nasıl yapılır?',
        options: [
          Option(text: 'Sadece harcama takibi', score: 0),
          Option(text: 'Çevresel etki, atık üretimi ve kaynak kullanımı izleme', score: 10),
          Option(text: 'Sadece zaman takibi', score: 0),
          Option(text: 'Sadece miktar takibi', score: 0),
        ],
        category: 'Tüketim',
      ),
      Question(
        text: 'Consumer advocacy (tüketici savunuculuğu) nedir?',
        options: [
          Option(text: 'Sadece şikayet etme', score: 0),
          Option(text: 'Hakları koruma, sistem değişikliği ve toplumsal bilinç', score: 10),
          Option(text: 'Sadece geri ödeme', score: 0),
          Option(text: 'Sadece dava açma', score: 0),
        ],
        category: 'Tüketim',
      ),
      Question(
        text: 'Product comparison tools (ürün karşılaştırma araçları) nasıl kullanılır?',
        options: [
          Option(text: 'Sadece fiyat karşılaştırması', score: 0),
          Option(text: 'Özellik, kalite, etki ve değer analizi', score: 10),
          Option(text: 'Sadece marka karşılaştırması', score: 0),
          Option(text: 'Sadece görünüm karşılaştırması', score: 0),
        ],
        category: 'Tüketim',
      ),
      Question(
        text: 'Consumer financial literacy (tüketici finansal okuryazarlığı) neden önemlidir?',
        options: [
          Option(text: 'Sadece para tasarrufu', score: 0),
          Option(text: 'Bilinçli harcama, borç yönetimi ve yatırım kararları', score: 10),
          Option(text: 'Sadece kredi kartı', score: 0),
          Option(text: 'Sadece banka hesabı', score: 0),
        ],
        category: 'Tüketim',
      ),
      Question(
        text: 'Sustainable consumption policy (sürdürülebilir tüketim politikası) nasıl geliştirilir?',
        options: [
          Option(text: 'Sadece vergi', score: 0),
          Option(text: 'Teşvik sistemleri, düzenlemeler ve eğitim programları', score: 10),
          Option(text: 'Sadece yasak', score: 0),
          Option(text: 'Sadece ceza', score: 0),
        ],
        category: 'Tüketim',
      ),
      Question(
        text: 'Consumer feedback systems (tüketici geri bildirim sistemleri) nasıl etkili olur?',
        options: [
          Option(text: 'Sadece puanlama', score: 0),
          Option(text: 'Detaylı yorum, sorun çözme ve sürekli iyileştirme', score: 10),
          Option(text: 'Sadece şikayet', score: 0),
          Option(text: 'Sadece övgü', score: 0),
        ],
        category: 'Tüketim',
      ),
      Question(
        text: 'Product disposal planning (ürün bertaraf planlaması) neden önemlidir?',
        options: [
          Option(text: 'Sadece çevre', score: 0),
          Option(text: 'Atık azaltma, geri dönüşüm ve yaşam döngüsü tamamlama', score: 10),
          Option(text: 'Sadece maliyet', score: 0),
          Option(text: 'Sadece yasal uyumluluk', score: 0),
        ],
        category: 'Tüketim',
      ),
      Question(
        text: 'Consumer education programs (tüketici eğitim programları) nasıl etkili olur?',
        options: [
          Option(text: 'Sadece bilgi verme', score: 0),
          Option(text: 'Pratik uygulama, deneyimleme ve sürekli güncelleme', score: 10),
          Option(text: 'Sadece seminer', score: 0),
          Option(text: 'Sadece broşür', score: 0),
        ],
        category: 'Tüketim',
      ),
      Question(
        text: 'Sustainable consumption indicators (sürdürülebilir tüketim göstergeleri) nelerdir?',
        options: [
          Option(text: 'Sadece satış rakamı', score: 0),
          Option(text: 'Çevresel etki, sosyal fayda ve ekonomik verimlilik', score: 10),
          Option(text: 'Sadece müşteri memnuniyeti', score: 0),
          Option(text: 'Sadece pazar payı', score: 0),
        ],
        category: 'Tüketim',
      ),
      Question(
        text: 'Consumer trust building (tüketici güveni oluşturma) nasıl yapılır?',
        options: [
          Option(text: 'Sadece reklam', score: 0),
          Option(text: 'Şeffaflık, tutarlılık ve somut kanıtlar', score: 10),
          Option(text: 'Sadece düşük fiyat', score: 0),
          Option(text: 'Sadece ücretsiz hizmet', score: 0),
        ],
        category: 'Tüketim',
      ),
      Question(
        text: 'Product transparency (ürün şeffaflığı) nasıl sağlanır?',
        options: [
          Option(text: 'Sadece etiket', score: 0),
          Option(text: 'İçerik, üretim süreci, tedarik zinciri ve etki bilgileri', score: 10),
          Option(text: 'Sadece menşe', score: 0),
          Option(text: 'Sadece kullanım kılavuzu', score: 0),
        ],
        category: 'Tüketim',
      ),
      Question(
        text: 'Consumer decision fatigue (tüketici karar yorgunluğu) nasıl önlenir?',
        options: [
          Option(text: 'Sadece seçenek azaltma', score: 0),
          Option(text: 'Net kriterler, öncelik belirleme ve karar destek araçları', score: 10),
          Option(text: 'Sadece otomatik seçim', score: 0),
          Option(text: 'Sadece başkasına sorma', score: 0),
        ],
        category: 'Tüketim',
      ),
      Question(
        text: 'Sustainable consumption challenge (sürdürülebilir tüketim zorluğu) nedir?',
        options: [
          Option(text: 'Sadece fiyat engeli', score: 0),
          Option(text: 'Alışkanlık değişimi, bilgi eksikliği ve sistemik sorunlar', score: 10),
          Option(text: 'Sadece zaman kısıtı', score: 0),
          Option(text: 'Sadece seçenek azlığı', score: 0),
        ],
        category: 'Tüketim',
      ),
      Question(
        text: 'Consumer rights protection (tüketici hakları koruması) nasıl güçlendirilir?',
        options: [
          Option(text: 'Sadece yasal düzenleme', score: 0),
          Option(text: 'Denetim mekanizmaları, eğitim ve toplumsal bilinç', score: 10),
          Option(text: 'Sadece ceza', score: 0),
          Option(text: 'Sadece kurum', score: 0),
        ],
        category: 'Tüketim',
      ),
      Question(
        text: 'Sustainable consumption measurement (sürdürülebilir tüketim ölçümü) nasıl yapılır?',
        options: [
          Option(text: 'Sadece harcama', score: 0),
          Option(text: 'Çevresel etki, sosyal fayda ve uzun vadeli değer analizi', score: 10),
          Option(text: 'Sadece miktar', score: 0),
          Option(text: 'Sadece sıklık', score: 0),
        ],
        category: 'Tüketim',
      ),
      Question(
        text: 'Consumer behavior economics (tüketici davranış ekonomisi) nasıl çalışır?',
        options: [
          Option(text: 'Sadece fiyat teorisi', score: 0),
          Option(text: 'Psikolojik faktörler, sosyal etki ve bilişsel önyargılar', score: 10),
          Option(text: 'Sadece arz-talep', score: 0),
          Option(text: 'Sadece rekabet', score: 0),
        ],
        category: 'Tüketim',
      ),
      Question(
        text: 'Product safety standards (ürün güvenlik standartları) nasıl değerlendirilir?',
        options: [
          Option(text: 'Sadece sertifika', score: 0),
          Option(text: 'Test sonuçları, risk analizi ve sürekli uyumluluk', score: 10),
          Option(text: 'Sadece marka güveni', score: 0),
          Option(text: 'Sadece fiyat', score: 0),
        ],
        category: 'Tüketim',
      ),
      Question(
        text: 'Consumer social responsibility (tüketici sosyal sorumluluğu) nedir?',
        options: [
          Option(text: 'Sadece bağış yapma', score: 0),
          Option(text: 'Sosyal etkiyi dikkate alma, etik tercihler ve toplumsal katkı', score: 10),
          Option(text: 'Sadece gönüllülük', score: 0),
          Option(text: 'Sadece yerel alışveriş', score: 0),
        ],
        category: 'Tüketim',
      ),
      Question(
        text: 'Sustainable consumption innovation (sürdürülebilir tüketim yeniliği) nasıl teşvik edilir?',
        options: [
          Option(text: 'Sadece araştırma fonu', score: 0),
          Option(text: 'Teşvik sistemleri, işbirliği ve başarı örnekleri', score: 10),
          Option(text: 'Sadece patent', score: 0),
          Option(text: 'Sadece yarışma', score: 0),
        ],
        category: 'Tüketim',
      ),
      Question(
        text: 'Consumer digital rights (tüketici dijital hakları) nelerdir?',
        options: [
          Option(text: 'Sadece gizlilik', score: 0),
          Option(text: 'Veri koruması, şeffaflık, güvenlik ve seçim özgürlüğü', score: 10),
          Option(text: 'Sadece hız', score: 0),
          Option(text: 'Sadece kolaylık', score: 0),
        ],
        category: 'Tüketim',
      ),
      Question(
        text: 'Product authenticity verification (ürün özgünlük doğrulaması) nasıl yapılır?',
        options: [
          Option(text: 'Sadece QR kod', score: 0),
          Option(text: 'Blockchain, sertifika doğrulama ve tedarik zinciri takibi', score: 10),
          Option(text: 'Sadece barkod', score: 0),
          Option(text: 'Sadece hologram', score: 0),
        ],
        category: 'Tüketim',
      ),
      Question(
        text: 'Consumer collective action (tüketici kolektif eylemi) nasıl organize edilir?',
        options: [
          Option(text: 'Sadece sosyal medya', score: 0),
          Option(text: 'Koordinasyon, ortak hedefler ve sürdürülebilir strateji', score: 10),
          Option(text: 'Sadece lider', score: 0),
          Option(text: 'Sadece kampanya', score: 0),
        ],
        category: 'Tüketim',
      ),
      Question(
        text: 'Sustainable consumption ecosystem (sürdürülebilir tüketim ekosistemi) nasıl oluşturulur?',
        options: [
          Option(text: 'Sadece bireysel çaba', score: 0),
          Option(text: 'Paydaş işbirliği, sistem değişikliği ve toplumsal dönüşüm', score: 10),
          Option(text: 'Sadece teknoloji', score: 0),
          Option(text: 'Sadece yasa', score: 0),
        ],
        category: 'Tüketim',
      ),
      Question(
        text: 'Consumer behavioral economics insights (tüketici davranış ekonomisi içgörüleri) nelerdir?',
        options: [
          Option(text: 'Sadece rasyonel karar', score: 0),
          Option(text: 'Duygusal etkiler, sosyal normlar ve bilişsel sınırlar', score: 10),
          Option(text: 'Sadece bilgi eksikliği', score: 0),
          Option(text: 'Sadece zaman kısıtı', score: 0),
        ],
        category: 'Tüketim',
      ),
      Question(
        text: 'Product lifecycle optimization (ürün yaşam döngüsü optimizasyonu) nasıl yapılır?',
        options: [
          Option(text: 'Sadece üretim verimliliği', score: 0),
          Option(text: 'Tasarım iyileştirme, kullanım süresi uzatma ve geri dönüşüm', score: 10),
          Option(text: 'Sadece maliyet azaltımı', score: 0),
          Option(text: 'Sadece hız artışı', score: 0),
        ],
        category: 'Tüketim',
      ),
      Question(
        text: 'Consumer empowerment strategies (tüketici güçlendirme stratejileri) nelerdir?',
        options: [
          Option(text: 'Sadece bilgi', score: 0),
          Option(text: 'Beceri geliştirme, araç sağlama ve toplumsal ağ kurma', score: 10),
          Option(text: 'Sadece finansal destek', score: 0),
          Option(text: 'Sadece yasal koruma', score: 0),
        ],
        category: 'Tüketim',
      ),
      Question(
        text: 'Sustainable consumption community (sürdürülebilir tüketim topluluğu) nasıl kurulur?',
        options: [
          Option(text: 'Sadece online grup', score: 0),
          Option(text: 'Ortak değerler, paylaşım kültürü ve kolektif eylem', score: 10),
          Option(text: 'Sadece seminer', score: 0),
          Option(text: 'Sadece proje', score: 0),
        ],
        category: 'Tüketim',
      ),
      Question(
        text: 'Consumer protection mechanisms (tüketici koruma mekanizmaları) nasıl çalışır?',
        options: [
          Option(text: 'Sadece şikayet hattı', score: 0),
          Option(text: 'Yasal çerçeve, denetim sistemi ve hak ihlali prosedürleri', score: 10),
          Option(text: 'Sadece medya baskısı', score: 0),
          Option(text: 'Sadece tüketici derneği', score: 0),
        ],
        category: 'Tüketim',
      ),
      Question(
        text: 'Sustainable consumption metrics (sürdürülebilir tüketim metrikleri) nelerdir?',
        options: [
          Option(text: 'Sadece satış verisi', score: 0),
          Option(text: 'Çevresel etki, sosyal fayda ve uzun vadeli değer göstergeleri', score: 10),
          Option(text: 'Sadece müşteri sayısı', score: 0),
          Option(text: 'Sadece gelir', score: 0),
        ],
        category: 'Tüketim',
      ),

      // Paylaşım Ekonomisi ve Sürdürülebilir Yaşam (50 soru)
      Question(
        text: 'Sharing economy (paylaşım ekonomisi) nasıl çalışır?',
        options: [
          Option(text: 'Sadece teknoloji platformu', score: 0),
          Option(text: 'Kaynak paylaşımı, toplumsal güven ve verimli kullanım', score: 10),
          Option(text: 'Sadece para kazanma', score: 0),
          Option(text: 'Sadece kolaylık', score: 0),
        ],
        category: 'Tüketim',
      ),
      Question(
        text: 'Collaborative consumption (işbirlikçi tüketim) modelleri nelerdir?',
        options: [
          Option(text: 'Sadece araç paylaşımı', score: 0),
          Option(text: 'Product service systems, sharing communities ve peer-to-peer platforms', score: 10),
          Option(text: 'Sadece barınma', score: 0),
          Option(text: 'Sadece yemek', score: 0),
        ],
        category: 'Tüketim',
      ),
      Question(
        text: 'Access over ownership (sahipliğin yerine erişim) prensibi nedir?',
        options: [
          Option(text: 'Sadece kiralama', score: 0),
          Option(text: 'İhtiyaç duyulduğunda erişim, sahiplik maliyetinden kaçınma', score: 10),
          Option(text: 'Sadece abonelik', score: 0),
          Option(text: 'Sadece takas', score: 0),
        ],
        category: 'Tüketim',
      ),
      Question(
        text: 'Peer-to-peer platforms (kişiden kişiye platformlar) faydaları nelerdir?',
        options: [
          Option(text: 'Sadece düşük maliyet', score: 0),
          Option(text: 'Toplumsal bağ, kaynak verimliliği ve ekonomik çeşitlilik', score: 10),
          Option(text: 'Sadece kolaylık', score: 0),
          Option(text: 'Sadece esneklik', score: 0),
        ],
        category: 'Tüketim',
      ),
      Question(
        text: 'Community resource sharing (topluluk kaynak paylaşımı) nasıl organize edilir?',
        options: [
          Option(text: 'Sadece kurumsal yönetim', score: 0),
          Option(text: 'Gönüllülük, ortak kurallar ve karşılıklı güven', score: 10),
          Option(text: 'Sadece dijital platform', score: 0),
          Option(text: 'Sadece finansman', score: 0),
        ],
        category: 'Tüketim',
      ),
      Question(
        text: 'Tool libraries (araç kütüphaneleri) nasıl çalışır?',
        options: [
          Option(text: 'Sadece kiralama sistemi', score: 0),
          Option(text: 'Üyelik, kayıt sistemi ve topluluk bakımı', score: 10),
          Option(text: 'Sadece depo', score: 0),
          Option(text: 'Sadece satış', score: 0),
        ],
        category: 'Tüketim',
      ),
      Question(
        text: 'Time banks (zaman bankaları) nedir?',
        options: [
          Option(text: 'Sadece para birimi', score: 0),
          Option(text: 'Hizmet değiş tokuşu, toplumsal bağ ve karşılıklı destek', score: 10),
          Option(text: 'Sadece gönüllülük', score: 0),
          Option(text: 'Sadece eğitim', score: 0),
        ],
        category: 'Tüketim',
      ),
      Question(
        text: 'Skill sharing networks (beceri paylaşım ağları) nasıl kurulur?',
        options: [
          Option(text: 'Sadece online platform', score: 0),
          Option(text: 'Profil oluşturma, eşleştirme sistemi ve güven mekanizması', score: 10),
          Option(text: 'Sadece reklam', score: 0),
          Option(text: 'Sadece seminer', score: 0),
        ],
        category: 'Tüketim',
      ),
      Question(
        text: 'Community gardens (topluluk bahçeleri) faydaları nelerdir?',
        options: [
          Option(text: 'Sadece sebze üretimi', score: 0),
          Option(text: 'Toplumsal bağ, çevre eğitimi ve sağlıklı yaşam', score: 10),
          Option(text: 'Sadece aktivite', score: 0),
          Option(text: 'Sadece tasarruf', score: 0),
        ],
        category: 'Tüketim',
      ),
      Question(
        text: 'Repair cafes (tamir kafeleri) nasıl çalışır?',
        options: [
          Option(text: 'Sadece ücretsiz tamir', score: 0),
          Option(text: 'Gönüllü uzmanlar, beceri paylaşımı ve atık azaltma', score: 10),
          Option(text: 'Sadece sosyal buluşma', score: 0),
          Option(text: 'Sadece hobby', score: 0),
        ],
        category: 'Tüketim',
      ),
      Question(
        text: 'Freecycle networks (ücretsiz takas ağları) nasıl organize edilir?',
        options: [
          Option(text: 'Sadece online grup', score: 0),
          Option(text: 'Üyelik sistemi, kurallar ve güven mekanizması', score: 10),
          Option(text: 'Sadece yardım', score: 0),
          Option(text: 'Sadece çevre', score: 0),
        ],
        category: 'Tüketim',
      ),
      Question(
        text: 'Clothing swaps (giyim takası) nasıl yapılır?',
        options: [
          Option(text: 'Sadece partiler', score: 0),
          Option(text: 'Kıyafet değerlendirme, eşleştirme ve takas sistemi', score: 10),
          Option(text: 'Sadece bağış', score: 0),
          Option(text: 'Sadece satış', score: 0),
        ],
        category: 'Tüketim',
      ),
      Question(
        text: 'Book sharing libraries (kitap paylaşım kütüphaneleri) faydaları nelerdir?',
        options: [
          Option(text: 'Sadece kitap okuma', score: 0),
          Option(text: 'Kaynak verimliliği, toplumsal etkileşim ve kültürel paylaşım', score: 10),
          Option(text: 'Sadece maliyet tasarrufu', score: 0),
          Option(text: 'Sadece çevre', score: 0),
        ],
        category: 'Tüketim',
      ),
      Question(
        text: 'Couch surfing (kanepe sörfü) nasıl güvenli hale getirilir?',
        options: [
          Option(text: 'Sadece profil kontrolü', score: 0),
          Option(text: 'Referans sistemi, değerlendirme ve topluluk moderasyonu', score: 10),
          Option(text: 'Sadece fotoğraf', score: 0),
          Option(text: 'Sadece doğrulama', score: 0),
        ],
        category: 'Tüketim',
      ),
      Question(
        text: 'Car sharing programs (araç paylaşım programları) nasıl çalışır?',
        options: [
          Option(text: 'Sadece araç kiralama', score: 0),
          Option(text: 'Üyelik, rezervasyon sistemi ve güvenlik protokolleri', score: 10),
          Option(text: 'Sadece GPS', score: 0),
          Option(text: 'Sadece mobil uygulama', score: 0),
        ],
        category: 'Tüketim',
      ),
      Question(
        text: 'Tool sharing cooperatives (araç paylaşım kooperatifleri) nasıl kurulur?',
        options: [
          Option(text: 'Sadece ortak satın alma', score: 0),
          Option(text: 'Kooperatif yapısı, yönetim ve kar paylaşım sistemi', score: 10),
          Option(text: 'Sadece depo', score: 0),
          Option(text: 'Sadece sigorta', score: 0),
        ],
        category: 'Tüketim',
      ),
      Question(
        text: 'Community kitchens (topluluk mutfakları) nasıl organize edilir?',
        options: [
          Option(text: 'Sadece yemek pişirme', score: 0),
          Option(text: 'Ortak alan, gönüllü çalışanlar ve maliyet paylaşımı', score: 10),
          Option(text: 'Sadece sosyal aktivite', score: 0),
          Option(text: 'Sadece maliyet azaltma', score: 0),
        ],
        category: 'Tüketim',
      ),
      Question(
        text: 'Skill exchange platforms (beceri değişim platformları) nasıl çalışır?',
        options: [
          Option(text: 'Sadece eşleştirme', score: 0),
          Option(text: 'Beceri listeleme, değerlendirme ve güven sistemi', score: 10),
          Option(text: 'Sadece online', score: 0),
          Option(text: 'Sadece ücretsiz', score: 0),
        ],
        category: 'Tüketim',
      ),
      Question(
        text: 'Community supported agriculture (topluluk destekli tarım) nasıl çalışır?',
        options: [
          Option(text: 'Sadece organik ürün', score: 0),
          Option(text: 'Doğrudan çiftçi desteği, mevsimlik abonelik ve risk paylaşımı', score: 10),
          Option(text: 'Sadece yerel ürün', score: 0),
          Option(text: 'Sadece taze ürün', score: 0),
        ],
        category: 'Tüketim',
      ),
      Question(
        text: 'Buy nothing groups (hiçbir şey satın alma grupları) nasıl organize edilir?',
        options: [
          Option(text: 'Sadece ücretsiz paylaşım', score: 0),
          Option(text: 'İhtiyaç karşılama, bağış ve takas sistemi', score: 10),
          Option(text: 'Sadece komşuluk', score: 0),
          Option(text: 'Sadece çevre', score: 0),
        ],
        category: 'Tüketim',
      ),
      Question(
        text: 'Repair skills workshops (tamir beceri atölyeleri) nasıl düzenlenir?',
        options: [
          Option(text: 'Sadece teknik eğitim', score: 0),
          Option(text: 'Pratik uygulama, uzman rehberliği ve topluluk etkileşimi', score: 10),
          Option(text: 'Sadece teorik bilgi', score: 0),
          Option(text: 'Sadece hobby', score: 0),
        ],
        category: 'Tüketim',
      ),
      Question(
        text: 'Childcare cooperatives (çocuk bakım kooperatifleri) nasıl çalışır?',
        options: [
          Option(text: 'Sadece bakım hizmeti', score: 0),
          Option(text: 'Ebeveyn katılımı, maliyet paylaşımı ve esnek program', score: 10),
          Option(text: 'Sadece kreş', score: 0),
          Option(text: 'Sadece oyun grubu', score: 0),
        ],
        category: 'Tüketim',
      ),
      Question(
        text: 'Energy cooperatives (enerji kooperatifleri) nasıl kurulur?',
        options: [
          Option(text: 'Sadece enerji üretimi', score: 0),
          Option(text: 'Ortak yatırım, kar paylaşımı ve sürdürülebilir enerji', score: 10),
          Option(text: 'Sadece tasarruf', score: 0),
          Option(text: 'Sadece çevre', score: 0),
        ],
        category: 'Tüketim',
      ),
      Question(
        text: 'Community internet sharing (topluluk internet paylaşımı) nasıl organize edilir?',
        options: [
          Option(text: 'Sadece WiFi paylaşımı', score: 0),
          Option(text: 'Ortak bağlantı, maliyet paylaşımı ve teknolojik destek', score: 10),
          Option(text: 'Sadece hız', score: 0),
          Option(text: 'Sadece maliyet', score: 0),
        ],
        category: 'Tüketim',
      ),
      Question(
        text: 'Sharing platform trust (paylaşım platformu güveni) nasıl oluşturulur?',
        options: [
          Option(text: 'Sadece kimlik doğrulama', score: 0),
          Option(text: 'Referans sistemi, değerlendirme ve sürekli izleme', score: 10),
          Option(text: 'Sadece profil', score: 0),
          Option(text: 'Sadece sözleşme', score: 0),
        ],
        category: 'Tüketim',
      ),
      Question(
        text: 'Community sustainability projects (topluluk sürdürülebilirlik projeleri) nelerdir?',
        options: [
          Option(text: 'Sadece çevre temizliği', score: 0),
          Option(text: 'Kompost, yağmur suyu toplama, enerji verimliliği', score: 10),
          Option(text: 'Sadece eğitim', score: 0),
          Option(text: 'Sadece farkındalık', score: 0),
        ],
        category: 'Tüketim',
      ),
      Question(
        text: 'Collaborative consumption challenges (işbirlikçi tüketim zorlukları) nelerdir?',
        options: [
          Option(text: 'Sadece teknoloji', score: 0),
          Option(text: 'Güven sorunu, yasal düzenlemeler ve kalite kontrolü', score: 10),
          Option(text: 'Sadece maliyet', score: 0),
          Option(text: 'Sadece kolaylık', score: 0),
        ],
        category: 'Tüketim',
      ),
      Question(
        text: 'Community resource management (topluluk kaynak yönetimi) nasıl yapılır?',
        options: [
          Option(text: 'Sadece kurallar', score: 0),
          Option(text: 'Katılımcı yönetim, sürdürülebilir kullanım ve adalet', score: 10),
          Option(text: 'Sadece teknoloji', score: 0),
          Option(text: 'Sadece gönüllülük', score: 0),
        ],
        category: 'Tüketim',
      ),
      Question(
        text: 'Sharing economy sustainability (paylaşım ekonomisi sürdürülebilirliği) nasıl sağlanır?',
        options: [
          Option(text: 'Sadece teknoloji', score: 0),
          Option(text: 'Uzun vadeli planlama, toplumsal fayda ve çevresel etki', score: 10),
          Option(text: 'Sadece ekonomik verim', score: 0),
          Option(text: 'Sadece kullanım kolaylığı', score: 0),
        ],
        category: 'Tüketim',
      ),
      Question(
        text: 'Community impact measurement (topluluk etki ölçümü) nasıl yapılır?',
        options: [
          Option(text: 'Sadece katılımcı sayısı', score: 0),
          Option(text: 'Sosyal bağ, ekonomik tasarruf ve çevresel etki analizi', score: 10),
          Option(text: 'Sadece faaliyet sayısı', score: 0),
          Option(text: 'Sadece bütçe', score: 0),
        ],
        category: 'Tüketim',
      ),
      Question(
        text: 'Sharing platform business models (paylaşım platformu iş modelleri) nelerdir?',
        options: [
          Option(text: 'Sadece komisyon', score: 0),
          Option(text: 'Üyelik, hizmet ücreti ve katma değerli servisler', score: 10),
          Option(text: 'Sadece reklam', score: 0),
          Option(text: 'Sadece veri satışı', score: 0),
        ],
        category: 'Tüketim',
      ),
      Question(
        text: 'Community resilience building (topluluk dirençlilik inşası) nasıl yapılır?',
        options: [
          Option(text: 'Sadece kaynak birikimi', score: 0),
          Option(text: 'Sosyal bağlar, beceri geliştirme ve dayanıklılık', score: 10),
          Option(text: 'Sadece teknoloji', score: 0),
          Option(text: 'Sadece finansman', score: 0),
        ],
        category: 'Tüketim',
      ),
      Question(
        text: 'Sharing culture development (paylaşım kültürü geliştirme) nasıl yapılır?',
        options: [
          Option(text: 'Sadece kampanya', score: 0),
          Option(text: 'Rol model olma, deneyim paylaşımı ve teşvik sistemi', score: 10),
          Option(text: 'Sadece eğitim', score: 0),
          Option(text: 'Sadece ödül', score: 0),
        ],
        category: 'Tüketim',
      ),
      Question(
        text: 'Community governance models (topluluk yönetişim modelleri) nelerdir?',
        options: [
          Option(text: 'Sadece demokratik oylama', score: 0),
          Option(text: 'Katılımcı süreç, uzlaşma arama ve şeffaf yönetim', score: 10),
          Option(text: 'Sadece liderlik', score: 0),
          Option(text: 'Sadece komite', score: 0),
        ],
        category: 'Tüketim',
      ),
      Question(
        text: 'Sharing platform scalability (paylaşım platformu ölçeklenebilirliği) nasıl sağlanır?',
        options: [
          Option(text: 'Sadece teknoloji', score: 0),
          Option(text: 'Standardizasyon, kalite kontrolü ve topluluk büyütme', score: 10),
          Option(text: 'Sadece pazarlama', score: 0),
          Option(text: 'Sadece finansman', score: 0),
        ],
        category: 'Tüketim',
      ),
      Question(
        text: 'Community benefit distribution (topluluk fayda dağıtımı) nasıl yapılır?',
        options: [
          Option(text: 'Sadece eşit paylaşım', score: 0),
          Option(text: 'İhtiyaç temelli, katkı oranlı ve adalet ilkeleri', score: 10),
          Option(text: 'Sadece performans', score: 0),
          Option(text: 'Sadece sıralama', score: 0),
        ],
        category: 'Tüketim',
      ),
      Question(
        text: 'Sharing economy regulations (paylaşım ekonomisi düzenlemeleri) nasıl geliştirilir?',
        options: [
          Option(text: 'Sadece vergi', score: 0),
          Option(text: 'Güvenlik, tüketici koruması ve adalet standartları', score: 10),
          Option(text: 'Sadece kısıtlama', score: 0),
          Option(text: 'Sadece yasak', score: 0),
        ],
        category: 'Tüketim',
      ),
      Question(
        text: 'Community innovation funds (topluluk inovasyon fonları) nasıl kurulur?',
        options: [
          Option(text: 'Sadece bağış', score: 0),
          Option(text: 'Ortak finansman, proje seçimi ve etki değerlendirmesi', score: 10),
          Option(text: 'Sadece hibe', score: 0),
          Option(text: 'Sadece yatırım', score: 0),
        ],
        category: 'Tüketim',
      ),
      Question(
        text: 'Sharing platform user experience (paylaşım platformu kullanıcı deneyimi) nasıl iyileştirilir?',
        options: [
          Option(text: 'Sadece tasarım', score: 0),
          Option(text: 'Kullanıcı geri bildirimi, süreç optimizasyonu ve destek', score: 10),
          Option(text: 'Sadece hız', score: 0),
          Option(text: 'Sadece kolaylık', score: 0),
        ],
        category: 'Tüketim',
      ),
      Question(
        text: 'Community data ownership (topluluk veri sahipliği) nasıl sağlanır?',
        options: [
          Option(text: 'Sadece gizlilik', score: 0),
          Option(text: 'Veri kontrolü, şeffaflık ve toplumsal fayda', score: 10),
          Option(text: 'Sadece anonimlik', score: 0),
          Option(text: 'Sadece güvenlik', score: 0),
        ],
        category: 'Tüketim',
      ),
      Question(
        text: 'Sharing economy future (paylaşım ekonomisi geleceği) nasıl şekillenir?',
        options: [
          Option(text: 'Sadece teknoloji', score: 0),
          Option(text: 'Sürdürülebilirlik, toplumsal ihtiyaçlar ve teknolojik gelişim', score: 10),
          Option(text: 'Sadece pazar', score: 0),
          Option(text: 'Sadece regülasyon', score: 0),
        ],
        category: 'Tüketim',
      ),
    ];
  }
}