// lib/data/water_questions_expansion.dart
// Su Teması için 200 Ek Soru

import '../models/question.dart';
import '../services/language_service.dart';

class WaterQuestionsExpansion {
  static List<Question> getTurkishWaterQuestions() {
    return [
      // Su Tasarrufu (25 soru)
      Question(
        text: 'Evlerde su tasarrufu için en etkili yöntem nedir?',
        options: [
          Option(text: 'Daha az su kullanmak', score: 0),
          Option(text: 'Su tasarruflu armatür ve cihazlar kullanmak', score: 10),
          Option(text: 'Sadece kısa duş almak', score: 5),
          Option(text: 'Sadece diş fırçalamamak', score: 0),
        ],
        category: 'Su',
      ),
      Question(
        text: 'Düşük akışlı (low-flow) duş başlıkları ne kadar su tasarrufu sağlar?',
        options: [
          Option(text: '%10-20', score: 0),
          Option(text: '%30-50', score: 10),
          Option(text: '%60-70', score: 0),
          Option(text: '%80-90', score: 0),
        ],
        category: 'Su',
      ),
      Question(
        text: 'Mutfakta su tasarrufu için hangi uygulamalar en etkilidir?',
        options: [
          Option(text: 'Sadece bulaşık makinesi kullanmak', score: 0),
          Option(text: 'Bulaşıkları önceden temizlemek ve makineyi tam doldurmak', score: 10),
          Option(text: 'Sadece elde yıkamak', score: 5),
          Option(text: 'Sadece soğuk su kullanmak', score: 0),
        ],
        category: 'Su',
      ),
      Question(
        text: 'Bahçe sulamasında su tasarrufu için hangi yöntem en iyisidir?',
        options: [
          Option(text: 'Sadece sabah sulamak', score: 5),
          Option(text: 'Damla sulama sistemi kullanmak', score: 10),
          Option(text: 'Sadece akşam sulamak', score: 5),
          Option(text: 'Sadece yağmurlama sistemi', score: 0),
        ],
        category: 'Su',
      ),
      Question(
        text: 'Çamaşır ve bulaşık makinelerinde su tasarrufu için hangi program tercih edilmelidir?',
        options: [
          Option(text: 'Hızlı program', score: 0),
          Option(text: 'Eko veya su tasarrufu programı', score: 10),
          Option(text: 'Yoğun temizlik programı', score: 0),
          Option(text: 'Sıcaklık yüksek program', score: 0),
        ],
        category: 'Su',
      ),
      Question(
        text: 'Tuvaletlerde su tasarrufu için hangi teknolojiler kullanılır?',
        options: [
          Option(text: 'Sadece çift kademeli sifon', score: 5),
          Option(text: 'Çift kademeli sifon ve vakumlu tuvalet teknolojisi', score: 10),
          Option(text: 'Sadece düşük hacimli sifon', score: 5),
          Option(text: 'Sadece kompost tuvalet', score: 0),
        ],
        category: 'Su',
      ),
      Question(
        text: 'Musluklarda su tasarrufu için aerator (havalandırıcı) kullanımının faydası nedir?',
        options: [
          Option(text: 'Sadece basınç artırımı', score: 0),
          Option(text: 'Akışı koruyarak su miktarını azaltma', score: 10),
          Option(text: 'Sadece gürültü azaltımı', score: 0),
          Option(text: 'Sadece sıcaklık kontrolü', score: 0),
        ],
        category: 'Su',
      ),
      Question(
        text: 'Su sızıntılarının önlenmesi için hangi önlemler alınmalıdır?',
        options: [
          Option(text: 'Sadece boru değişimi', score: 0),
          Option(text: 'Düzenli bakım, sızıntı tespiti ve hızlı onarım', score: 10),
          Option(text: 'Sadece filtre kullanımı', score: 0),
          Option(text: 'Sadece basınç kontrolü', score: 0),
        ],
        category: 'Su',
      ),
      Question(
        text: 'Yağmur suyu hasadı (rainwater harvesting) sistemlerinin faydası nedir?',
        options: [
          Option(text: 'Sadece bahçe sulaması', score: 0),
          Option(text: 'İçme dışı kullanımlar için su temini ve taşkın önleme', score: 10),
          Option(text: 'Sadece enerji üretimi', score: 0),
          Option(text: 'Sadece dekorasyon', score: 0),
        ],
        category: 'Su',
      ),
      Question(
        text: 'Akıllı su sayaçları hangi avantajları sağlar?',
        options: [
          Option(text: 'Sadece otomatik okuma', score: 0),
          Option(text: 'Gerçek zamanlı izleme, sızıntı tespiti ve optimizasyon', score: 10),
          Option(text: 'Sadece uzaktan kontrol', score: 0),
          Option(text: 'Sadece maliyet azaltımı', score: 0),
        ],
        category: 'Su',
      ),
      Question(
        text: 'Endüstriyel su tasarrufu için hangi yöntemler en etkilidir?',
        options: [
          Option(text: 'Sadece proses optimizasyonu', score: 0),
          Option(text: 'Geri dönüşüm, yeniden kullanım ve verimli teknolojiler', score: 10),
          Option(text: 'Sadece atık azaltımı', score: 0),
          Option(text: 'Sadece personel eğitimi', score: 0),
        ],
        category: 'Su',
      ),
      Question(
        text: 'Su tasarrufu davranışlarını teşvik etmek için hangi yöntemler kullanılır?',
        options: [
          Option(text: 'Sadece cezalar', score: 0),
          Option(text: 'Fiyatlandırma, bilinçlendirme ve teknoloji teşvikleri', score: 10),
          Option(text: 'Sadece kampanyalar', score: 0),
          Option(text: 'Sadece yasal düzenlemeler', score: 0),
        ],
        category: 'Su',
      ),
      Question(
        text: 'Tarımda su tasarrufu için hangi sulama teknolojileri en etkilidir?',
        options: [
          Option(text: 'Sadece yağmurlama', score: 0),
          Option(text: 'Damla sulama ve mikro spreyler', score: 10),
          Option(text: 'Sadece salma sulama', score: 0),
          Option(text: 'Sadece yağmur suyu', score: 0),
        ],
        category: 'Su',
      ),
      Question(
        text: 'Gri su (greywater) yeniden kullanımının faydası nedir?',
        options: [
          Option(text: 'Sadece maliyet azaltımı', score: 0),
          Option(text: 'İçme dışı kullanımlar için su tasarrufu', score: 10),
          Option(text: 'Sadece enerji tasarrufu', score: 0),
          Option(text: 'Sadece çevre koruması', score: 0),
        ],
        category: 'Su',
      ),
      Question(
        text: 'Su baskınlarından korunmak için hangi önlemler alınmalıdır?',
        options: [
          Option(text: 'Sadece pompa sistemi', score: 0),
          Option(text: 'Drenaj sistemi, yeşil altyapı ve erken uyarı sistemi', score: 10),
          Option(text: 'Sadece baraj inşası', score: 0),
          Option(text: 'Sadece yükseltme', score: 0),
        ],
        category: 'Su',
      ),
      Question(
        text: 'Su kalitesi ile su tasarrufu arasındaki ilişki nedir?',
        options: [
          Option(text: 'Ters orantı', score: 0),
          Option(text: 'Kaliteli su daha az israf edilir', score: 10),
          Option(text: 'Doğrudan orantı', score: 0),
          Option(text: 'İlişki yok', score: 0),
        ],
        category: 'Su',
      ),
      Question(
        text: 'Çift camlı (dual pane) pencerelerin su tasarrufuna etkisi nedir?',
        options: [
          Option(text: 'Sadece ısı tasarrufu', score: 0),
          Option(text: 'Kondensasyonu azaltarak nem kontrolü sağlar', score: 5),
          Option(text: 'Sadece ses izolasyonu', score: 0),
          Option(text: 'Su tasarrufuna doğrudan etkisi yok', score: 0),
        ],
        category: 'Su',
      ),
      Question(
        text: 'Toprak nem sensörleri bahçe sulamasında nasıl yardımcı olur?',
        options: [
          Option(text: 'Sadece pH ölçümü', score: 0),
          Option(text: 'Toprak nemine göre otomatik sulama kontrolü', score: 10),
          Option(text: 'Sadece sıcaklık ölçümü', score: 0),
          Option(text: 'Sadece ışık ölçümü', score: 0),
        ],
        category: 'Su',
      ),
      Question(
        text: 'Su kirliliğinin su tasarrufu ile ilişkisi nedir?',
        options: [
          Option(text: 'Kirlilik su tasarrufunu artırır', score: 0),
          Option(text: 'Kirlilik temiz su ihtiyacını artırır', score: 10),
          Option(text: 'İlişki yoktur', score: 0),
          Option(text: 'Kirlilik su tasarrufunu azaltır', score: 0),
        ],
        category: 'Su',
      ),
      Question(
        text: 'Akıllı bahçe sulama sistemleri hangi teknolojileri kullanır?',
        options: [
          Option(text: 'Sadece zamanlayıcı', score: 0),
          Option(text: 'Hava durumu sensörleri, toprak nemi ve otomatik kontrol', score: 10),
          Option(text: 'Sadece uzaktan kontrol', score: 0),
          Option(text: 'Sadece mobil uygulama', score: 0),
        ],
        category: 'Su',
      ),
      Question(
        text: 'Su depolama sistemlerinde hangi faktörler önemlidir?',
        options: [
          Option(text: 'Sadece kapasite', score: 0),
          Option(text: 'Kapasite, malzeme, konum ve hijyen koşulları', score: 10),
          Option(text: 'Sadece malzeme', score: 0),
          Option(text: 'Sadece konum', score: 0),
        ],
        category: 'Su',
      ),
      Question(
        text: 'Endüstriyel proseslerde su geri dönüşümü nasıl uygulanır?',
        options: [
          Option(text: 'Sadece filtreleme', score: 0),
          Option(text: 'Arıtma, yeniden kullanım ve kapalı devre sistemler', score: 10),
          Option(text: 'Sadece dezenfeksiyon', score: 0),
          Option(text: 'Sadece kimyasal arıtma', score: 0),
        ],
        category: 'Su',
      ),
      Question(
        text: 'Su tasarrufu hedefleri belirlenirken hangi metrikler kullanılır?',
        options: [
          Option(text: 'Sadece kişi başı tüketim', score: 0),
          Option(text: 'Kişi başı tüketim, sektörel kullanım ve verimlilik oranları', score: 10),
          Option(text: 'Sadece toplam tüketim', score: 0),
          Option(text: 'Sadece maliyet', score: 0),
        ],
        category: 'Su',
      ),
      Question(
        text: 'Çevre dostu binalarda su tasarrufu nasıl sağlanır?',
        options: [
          Option(text: 'Sadece su tasarruflu armatürler', score: 0),
          Option(text: 'Tasarım optimizasyonu, geri dönüşüm ve akıllı sistemler', score: 10),
          Option(text: 'Sadece yeşil çatı', score: 0),
          Option(text: 'Sadece yağmur suyu hasadı', score: 0),
        ],
        category: 'Su',
      ),

      // Su Arıtma (25 soru)
      Question(
        text: 'İçme suyu arıtma tesislerinde ilk aşama hangisidir?',
        options: [
          Option(text: 'Dezenfeksiyon', score: 0),
          Option(text: 'Ön arıtma (pıhtılaştırma ve çöktürme)', score: 10),
          Option(text: 'Filtrasyon', score: 0),
          Option(text: 'Kimyasal arıtma', score: 0),
        ],
        category: 'Su',
      ),
      Question(
        text: 'Reverse osmosis (ters ozmoz) teknolojisi nasıl çalışır?',
        options: [
          Option(text: 'Sadece filtrasyon', score: 0),
          Option(text: 'Yarı geçirgen membran ile suyu basınçla arıtma', score: 10),
          Option(text: 'Sadece kaynatma', score: 0),
          Option(text: 'Sadece UV dezenfeksiyon', score: 0),
        ],
        category: 'Su',
      ),
      Question(
        text: 'UV dezenfeksiyonun avantajı nedir?',
        options: [
          Option(text: 'Sadece düşük maliyet', score: 0),
          Option(text: 'Kimyasal kullanımı olmadan mikroorganizma temizleme', score: 10),
          Option(text: 'Sadece hızlı işlem', score: 0),
          Option(text: 'Sadece kolay kullanım', score: 0),
        ],
        category: 'Su',
      ),
      Question(
        text: 'Aktif karbon filtrasyonu hangi kirleticileri temizler?',
        options: [
          Option(text: 'Sadece bakteriler', score: 0),
          Option(text: 'Organik maddeler, klor ve kötü kokular', score: 10),
          Option(text: 'Sadece ağır metaller', score: 0),
          Option(text: 'Sadece virüsler', score: 0),
        ],
        category: 'Su',
      ),
      Question(
        text: 'İleri arıtma teknolojileri arasında hangi yöntemler bulunur?',
        options: [
          Option(text: 'Sadece filtrasyon', score: 0),
          Option(text: 'Membran teknolojileri, ozonlama ve adsorpsiyon', score: 10),
          Option(text: 'Sadece kimyasal arıtma', score: 0),
          Option(text: 'Sadece biyolojik arıtma', score: 0),
        ],
        category: 'Su',
      ),
      Question(
        text: 'Atık su arıtma tesislerinde üçüncül arıtma nedir?',
        options: [
          Option(text: 'Sadece ön arıtma', score: 0),
          Option(text: 'Besleyici maddeleri (azot, fosfor) uzaklaştırma', score: 10),
          Option(text: 'Sadece dezenfeksiyon', score: 0),
          Option(text: 'Sadece çökeltme', score: 0),
        ],
        category: 'Su',
      ),
      Question(
        text: 'Ozonlama teknolojisinin su arıtmadaki rolü nedir?',
        options: [
          Option(text: 'Sadece koku giderme', score: 0),
          Option(text: 'Güçlü oksidasyon ile mikroorganizma ve kirletici temizleme', score: 10),
          Option(text: 'Sadece renk giderme', score: 0),
          Option(text: 'Sadece pH ayarlama', score: 0),
        ],
        category: 'Su',
      ),
      Question(
        text: 'İyon değiştirici reçineler hangi maddeleri uzaklaştırır?',
        options: [
          Option(text: 'Sadece organik maddeler', score: 0),
          Option(text: 'Kalsiyum, magnezyum ve ağır metaller', score: 10),
          Option(text: 'Sadece bakteriler', score: 0),
          Option(text: 'Sadece virüsler', score: 0),
        ],
        category: 'Su',
      ),
      Question(
        text: 'Su arıtma tesislerinde sludge (çamur) yönetimi nasıl yapılır?',
        options: [
          Option(text: 'Sadece bertaraf', score: 0),
          Option(text: 'Kurutma, kompostlaştırma ve enerji üretimi', score: 10),
          Option(text: 'Sadece geri dönüşüm', score: 0),
          Option(text: 'Sadece yakma', score: 0),
        ],
        category: 'Su',
      ),
      Question(
        text: 'Elektrodiyaliz teknolojisi su arıtmada nasıl çalışır?',
        options: [
          Option(text: 'Sadece elektrik kullanımı', score: 0),
          Option(text: 'Elektrik alanı ile iyonları membrandan geçirme', score: 10),
          Option(text: 'Sadece basınç uygulaması', score: 0),
          Option(text: 'Sadece ısı uygulaması', score: 0),
        ],
        category: 'Su',
      ),
      Question(
        text: 'Su arıtma kalitesini kontrol eden parametreler nelerdir?',
        options: [
          Option(text: 'Sadece pH', score: 0),
          Option(text: 'pH, bulanıklık, iletkenlik ve mikrobiyolojik göstergeler', score: 10),
          Option(text: 'Sadece renk', score: 0),
          Option(text: 'Sadece koku', score: 0),
        ],
        category: 'Su',
      ),
      Question(
        text: 'Membran bioreactor (MBR) teknolojisi nasıl çalışır?',
        options: [
          Option(text: 'Sadece biyolojik arıtma', score: 0),
          Option(text: 'Biyolojik arıtma ve membran filtrasyonunu birleştirir', score: 10),
          Option(text: 'Sadece fiziksel arıtma', score: 0),
          Option(text: 'Sadece kimyasal arıtma', score: 0),
        ],
        category: 'Su',
      ),
      Question(
        text: 'Su arıtmada kullanılan koagülant maddeler nelerdir?',
        options: [
          Option(text: 'Sadece klor', score: 0),
          Option(text: 'Alüminyum ve demir tuzları', score: 10),
          Option(text: 'Sadece ozon', score: 0),
          Option(text: 'Sadece hidrojen peroksit', score: 0),
        ],
        category: 'Su',
      ),
      Question(
        text: 'Arıtılmış suyun dezenfeksiyonu için hangi yöntemler kullanılır?',
        options: [
          Option(text: 'Sadece klorlama', score: 0),
          Option(text: 'Klorlama, UV ve ozonlama kombinasyonu', score: 10),
          Option(text: 'Sadece UV', score: 0),
          Option(text: 'Sadece ozonlama', score: 0),
        ],
        category: 'Su',
      ),
      Question(
        text: 'Granular activated carbon (GAC) filtrasyonun avantajı nedir?',
        options: [
          Option(text: 'Sadece düşük maliyet', score: 0),
          Option(text: 'Yüksek yüzey alanı ile organik madde ve koku temizleme', score: 10),
          Option(text: 'Sadece kolay bakım', score: 0),
          Option(text: 'Sadece uzun ömür', score: 0),
        ],
        category: 'Su',
      ),
      Question(
        text: 'Su arıtma tesislerinde otomasyon sistemleri nasıl çalışır?',
        options: [
          Option(text: 'Sadece zamanlama', score: 0),
          Option(text: 'Sensörler, PLC ve SCADA ile tam otomatik kontrol', score: 10),
          Option(text: 'Sadece uzaktan kontrol', score: 0),
          Option(text: 'Sadece alarm sistemi', score: 0),
        ],
        category: 'Su',
      ),
      Question(
        text: 'Çevresel deşarj standartları su arıtmayı nasıl etkiler?',
        options: [
          Option(text: 'Sadece maliyet artışı', score: 0),
          Option(text: 'Daha ileri arıtma teknolojileri gereksinimi', score: 10),
          Option(text: 'Sadece operasyonel değişiklik', score: 0),
          Option(text: 'Sadece izleme artışı', score: 0),
        ],
        category: 'Su',
      ),
      Question(
        text: 'Membrane fouling (membran kirlenmesi) sorunu nasıl çözülür?',
        options: [
          Option(text: 'Sadece filtre değişimi', score: 0),
          Option(text: 'Kimyasal temizleme, backwashing ve ön arıtma', score: 10),
          Option(text: 'Sadece basınç artırma', score: 0),
          Option(text: 'Sadece sıcaklık kontrolü', score: 0),
        ],
        category: 'Su',
      ),
      Question(
        text: 'Su arıtma tesislerinde enerji verimliliği nasıl artırılır?',
        options: [
          Option(text: 'Sadece ekipman değişimi', score: 0),
          Option(text: 'Verimli pompalar, proses optimizasyonu ve enerji geri kazanımı', score: 10),
          Option(text: 'Sadece zamanlama optimizasyonu', score: 0),
          Option(text: 'Sadece bakım programı', score: 0),
        ],
        category: 'Su',
      ),
      Question(
        text: 'Advanced oxidation processes (AOP) hangi kirleticiler için kullanılır?',
        options: [
          Option(text: 'Sadece inorganik maddeler', score: 0),
          Option(text: 'İlaç kalıntıları ve endokrin bozucular gibi dirençli organik kirleticiler', score: 10),
          Option(text: 'Sadece ağır metaller', score: 0),
          Option(text: 'Sadece bakteriler', score: 0),
        ],
        category: 'Su',
      ),
      Question(
        text: 'Su arıtma kalitesi izleme sistemlerinde hangi parametreler takip edilir?',
        options: [
          Option(text: 'Sadece pH ve bulanıklık', score: 0),
          Option(text: 'Gerçek zamanlı pH, bulanıklık, klor ve mikroorganizma', score: 10),
          Option(text: 'Sadece sıcaklık', score: 0),
          Option(text: 'Sadece basınç', score: 0),
        ],
        category: 'Su',
      ),
      Question(
        text: 'Solar-powered water purification (güneş enerjili su arıtma) nasıl çalışır?',
        options: [
          Option(text: 'Sadece ısıtma', score: 0),
          Option(text: 'Güneş enerjisi ile UV dezenfeksiyon ve damıtma', score: 10),
          Option(text: 'Sadece elektrik üretimi', score: 0),
          Option(text: 'Sadece pompalama', score: 0),
        ],
        category: 'Su',
      ),
      Question(
        text: 'Su arıtma tesislerinde risk yönetimi nasıl yapılır?',
        options: [
          Option(text: 'Sadece ekipman güvenliği', score: 0),
          Option(text: 'HACCP prensipleri, kalite kontrol ve acil durum planları', score: 10),
          Option(text: 'Sadece personel eğitimi', score: 0),
          Option(text: 'Sadece sigorta', score: 0),
        ],
        category: 'Su',
      ),
      Question(
        text: 'Endüstriyel atık su arıtımında hangi teknolojiler kullanılır?',
        options: [
          Option(text: 'Sadece fiziksel arıtma', score: 0),
          Option(text: 'Kimyasal, biyolojik ve fiziksel arıtma kombinasyonu', score: 10),
          Option(text: 'Sadece biyolojik arıtma', score: 0),
          Option(text: 'Sadece kimyasal arıtma', score: 0),
        ],
        category: 'Su',
      ),

      // Su Altyapısı (25 soru)
      Question(
        text: 'Su dağıtım sistemlerinde basınç yönetiminin önemi nedir?',
        options: [
          Option(text: 'Sadece enerji tasarrufu', score: 0),
          Option(text: 'Sızıntı azaltımı ve hizmet kalitesi sağlama', score: 10),
          Option(text: 'Sadece ekipman koruması', score: 0),
          Option(text: 'Sadece operasyonel kolaylık', score: 0),
        ],
        category: 'Su',
      ),
      Question(
        text: 'Su şebekelerinde SCADA sistemi ne işe yarar?',
        options: [
          Option(text: 'Sadece veri toplama', score: 0),
          Option(text: 'Uzaktan izleme, kontrol ve optimizasyon', score: 10),
          Option(text: 'Sadece alarm sistemi', score: 0),
          Option(text: 'Sadece raporlama', score: 0),
        ],
        category: 'Su',
      ),
      Question(
        text: 'Su boru hatlarında kullanılan malzemelerin seçimi hangi faktörlere bağlıdır?',
        options: [
          Option(text: 'Sadece maliyet', score: 0),
          Option(text: 'Basınç, toprak koşulları, kimyasal direnç ve ömür', score: 10),
          Option(text: 'Sadece çap', score: 0),
          Option(text: 'Sadece uzunluk', score: 0),
        ],
        category: 'Su',
      ),
      Question(
        text: 'Su depolama sistemlerinde mixing (karıştırma) neden önemlidir?',
        options: [
          Option(text: 'Sadece enerji tasarrufu', score: 0),
          Option(text: 'Su kalitesini eşitlemek ve çamur birikimini önlemek', score: 10),
          Option(text: 'Sadece basınç kontrolü', score: 0),
          Option(text: 'Sadece sıcaklık kontrolü', score: 0),
        ],
        category: 'Su',
      ),
      Question(
        text: 'Su pompa istasyonlarında enerji verimliliği nasıl artırılır?',
        options: [
          Option(text: 'Sadece pompa değişimi', score: 0),
          Option(text: 'Değişken hızlı sürücüler ve optimal pompalama stratejileri', score: 10),
          Option(text: 'Sadece bakım programı', score: 0),
          Option(text: 'Sadece filtre değişimi', score: 0),
        ],
        category: 'Su',
      ),
      Question(
        text: 'Su şebekelerinde leak detection (sızıntı tespiti) hangi yöntemlerle yapılır?',
        options: [
          Option(text: 'Sadece görsel kontrol', score: 0),
          Option(text: 'Akustik sensörler, basınç izleme ve gerçek zamanlı analiz', score: 10),
          Option(text: 'Sadece manuel ölçüm', score: 0),
          Option(text: 'Sadece yeraltı radarı', score: 0),
        ],
        category: 'Su',
      ),
      Question(
        text: 'Su arıtma tesislerinde hydraulic design (hidrolik tasarım) nelere dikkat eder?',
        options: [
          Option(text: 'Sadece akış hızı', score: 0),
          Option(text: 'Akış hızı, süre ve çamur birikimi optimizasyonu', score: 10),
          Option(text: 'Sadece basınç kaybı', score: 0),
          Option(text: 'Sadece kapasite', score: 0),
        ],
        category: 'Su',
      ),
      Question(
        text: 'Su dağıtım ağlarında fire fighting (yangın söndürme) sistemleri nasıl entegre edilir?',
        options: [
          Option(text: 'Sadece ayrı sistem', score: 0),
          Option(text: 'Yeterli basınç ve debi sağlayacak şekilde ana sistemle entegrasyon', score: 10),
          Option(text: 'Sadece ek pompalar', score: 0),
          Option(text: 'Sadece rezervuar sistemi', score: 0),
        ],
        category: 'Su',
      ),
      Question(
        text: 'Su altyapısında GIS (Coğrafi Bilgi Sistemi) kullanımının faydası nedir?',
        options: [
          Option(text: 'Sadece harita oluşturma', score: 0),
          Option(text: 'Altyapı yönetimi, bakım planlaması ve analiz', score: 10),
          Option(text: 'Sadece görselleştirme', score: 0),
          Option(text: 'Sadece konum belirleme', score: 0),
        ],
        category: 'Su',
      ),
      Question(
        text: 'Su boru hatlarında cathodic protection (katodik koruma) neden gereklidir?',
        options: [
          Option(text: 'Sadece korozyon önleme', score: 10),
          Option(text: 'Elektrolitik korozyonu önleyerek boru ömrünü uzatma', score: 10),
          Option(text: 'Sadece maliyet azaltımı', score: 0),
          Option(text: 'Sadece basınç artırımı', score: 0),
        ],
        category: 'Su',
      ),
      Question(
        text: 'Su sistemlerinde water hammer (su darbesi) sorunu nasıl önlenir?',
        options: [
          Option(text: 'Sadece basınç artırma', score: 0),
          Option(text: 'Hava tankları, vana kontrolü ve yavaş kapama sistemleri', score: 10),
          Option(text: 'Sadece pompa kontrolü', score: 0),
          Option(text: 'Sadece boru değişimi', score: 0),
        ],
        category: 'Su',
      ),
      Question(
        text: 'Su depolama tanklarında disinfection byproducts (dezenfeksiyon yan ürünleri) nasıl önlenir?',
        options: [
          Option(text: 'Sadece klor miktarını azaltma', score: 0),
          Option(text: 'Ön arıtma, alternatif dezenfeksiyon ve optimal klorlama', score: 10),
          Option(text: 'Sadece UV kullanma', score: 0),
          Option(text: 'Sadece filtre değişimi', score: 0),
        ],
        category: 'Su',
      ),
      Question(
        text: 'Su şebekelerinde surge analysis (dalgalanma analizi) ne amaçla yapılır?',
        options: [
          Option(text: 'Sadece basınç ölçümü', score: 0),
          Option(text: 'Sistem güvenliği ve ekipman koruması için basınç dalgalanma analizi', score: 10),
          Option(text: 'Sadece akış analizi', score: 0),
          Option(text: 'Sadece kapasite analizi', score: 0),
        ],
        category: 'Su',
      ),
      Question(
        text: 'Su altyapısında condition assessment (durum değerlendirmesi) hangi yöntemlerle yapılır?',
        options: [
          Option(text: 'Sadece görsel kontrol', score: 0),
          Option(text: 'İç kamera, ultrasonik test ve basınç testleri', score: 10),
          Option(text: 'Sadece basınç ölçümü', score: 0),
          Option(text: 'Sadece akış ölçümü', score: 0),
        ],
        category: 'Su',
      ),
      Question(
        text: 'Su pompalarında VFD (Değişken Frekans Sürücü) kullanımının avantajı nedir?',
        options: [
          Option(text: 'Sadece hız kontrolü', score: 0),
          Option(text: 'Enerji tasarrufu, basınç kontrolü ve yumuşak başlatma', score: 10),
          Option(text: 'Sadece gürültü azaltımı', score: 0),
          Option(text: 'Sadece ömür uzatma', score: 0),
        ],
        category: 'Su',
      ),
      Question(
        text: 'Su dağıtım ağlarında zoning (bölgelendirme) ne amaçla yapılır?',
        options: [
          Option(text: 'Sadece maliyet azaltımı', score: 0),
          Option(text: 'Basınç yönetimi, sızıntı kontrolü ve hizmet kalitesi', score: 10),
          Option(text: 'Sadece bakım kolaylığı', score: 0),
          Option(text: 'Sadece genişletme', score: 0),
        ],
        category: 'Su',
      ),
      Question(
        text: 'Su altyapısında asset management (varlık yönetimi) hangi bileşenleri içerir?',
        options: [
          Option(text: 'Sadece finansal kayıt', score: 0),
          Option(text: 'Durum değerlendirmesi, yaşam döngüsü ve bakım planlaması', score: 10),
          Option(text: 'Sadece envanter', score: 0),
          Option(text: 'Sadece sigorta', score: 0),
        ],
        category: 'Su',
      ),
      Question(
        text: 'Su boru hatlarında cleaning (temizleme) ve flushing (yıkama) neden yapılır?',
        options: [
          Option(text: 'Sadece koku giderme', score: 0),
          Option(text: 'Sediment, biyofilm ve korozyon ürünlerini uzaklaştırma', score: 10),
          Option(text: 'Sadece dezenfeksiyon', score: 0),
          Option(text: 'Sadece bakım', score: 0),
        ],
        category: 'Su',
      ),
      Question(
        text: 'Su sistemlerinde emergency response (acil durum müdahalesi) planları neleri içerir?',
        options: [
          Option(text: 'Sadece iletişim bilgileri', score: 0),
          Option(text: 'Arıza tespiti, onarım prosedürleri ve alternatif tedarik', score: 10),
          Option(text: 'Sadece yedek ekipman', score: 0),
          Option(text: 'Sadece personel listesi', score: 0),
        ],
        category: 'Su',
      ),
      Question(
        text: 'Su altyapısında rehabilitation (yenileme) ne zaman gereklidir?',
        options: [
          Option(text: 'Sadece arıza durumunda', score: 0),
          Option(text: 'Performans düşüşü, sızıntı artışı ve güvenlik riskleri', score: 10),
          Option(text: 'Sadece yaşlanma durumunda', score: 0),
          Option(text: 'Sadece kapasite artışı', score: 0),
        ],
        category: 'Su',
      ),
      Question(
        text: 'Su şebekelerinde smart meters (akıllı sayaçlar) hangi verileri sağlar?',
        options: [
          Option(text: 'Sadece tüketim miktarı', score: 0),
          Option(text: 'Gerçek zamanlı tüketim, sızıntı tespiti ve kalite izleme', score: 10),
          Option(text: 'Sadece fatura bilgisi', score: 0),
          Option(text: 'Sadece kullanım saati', score: 0),
        ],
        category: 'Su',
      ),
      Question(
        text: 'Su altyapısında water quality monitoring (su kalitesi izleme) nasıl yapılır?',
        options: [
          Option(text: 'Sadece laboratuvar testleri', score: 0),
          Option(text: 'Online sensörler, düzenli numune alma ve laboratuvar analizi', score: 10),
          Option(text: 'Sadece görsel kontrol', score: 0),
          Option(text: 'Sadece koku kontrolü', score: 0),
        ],
        category: 'Su',
      ),
      Question(
        text: 'Su dağıtım ağlarında redundancy (yedeklilik) neden önemlidir?',
        options: [
          Option(text: 'Sadece maliyet artırımı', score: 0),
          Option(text: 'Kesintisiz hizmet, arıza durumunda alternatif tedarik', score: 10),
          Option(text: 'Sadece basınç artırımı', score: 0),
          Option(text: 'Sadece kapasite artırımı', score: 0),
        ],
        category: 'Su',
      ),
      Question(
        text: 'Su altyapısında seismic design (depreme dayanıklı tasarım) nelere dikkat eder?',
        options: [
          Option(text: 'Sadece malzeme seçimi', score: 0),
          Option(text: 'Esnek bağlantılar, dayanıklı malzemeler ve tsunami koruması', score: 10),
          Option(text: 'Sadece boru çapı', score: 0),
          Option(text: 'Sadece basınç kontrolü', score: 0),
        ],
        category: 'Su',
      ),

      // Su Kalitesi (25 soru)
      Question(
        text: 'İçme suyu kalitesinde en önemli mikrobiyolojik parametre hangisidir?',
        options: [
          Option(text: 'E. coli', score: 10),
          Option(text: 'Coliform bakterileri', score: 5),
          Option(text: 'Streptococcus', score: 0),
          Option(text: 'Staphylococcus', score: 0),
        ],
        category: 'Su',
      ),
      Question(
        text: 'Su kalitesinde TDS (Toplam Çözünmüş Katılar) hangi etkilere sahiptir?',
        options: [
          Option(text: 'Sadece tat', score: 0),
          Option(text: 'Tat, sertlik ve sağlık etkileri', score: 10),
          Option(text: 'Sadece sertlik', score: 0),
          Option(text: 'Sadece renk', score: 0),
        ],
        category: 'Su',
      ),
      Question(
        text: 'Su sertliğinin ana nedeni hangi minerallerdir?',
        options: [
          Option(text: 'Sodyum ve potasyum', score: 0),
          Option(text: 'Kalsiyum ve magnezyum', score: 10),
          Option(text: 'Demir ve manganez', score: 0),
          Option(text: 'Bakır ve çinko', score: 0),
        ],
        category: 'Su',
      ),
      Question(
        text: 'Su kalitesinde pH değerinin ideal aralığı nedir?',
        options: [
          Option(text: '6.5-8.5', score: 10),
          Option(text: '5.0-7.0', score: 0),
          Option(text: '8.5-10.0', score: 0),
          Option(text: '4.0-6.0', score: 0),
        ],
        category: 'Su',
      ),
      Question(
        text: 'Su kalitesinde nitrat kirliliğinin ana kaynakları nelerdir?',
        options: [
          Option(text: 'Sadece endüstriyel atık', score: 0),
          Option(text: 'Tarımsal gübre, kanalizasyon ve hayvancılık', score: 10),
          Option(text: 'Sadece trafik kirliliği', score: 0),
          Option(text: 'Sadece evsel atık', score: 0),
        ],
        category: 'Su',
      ),
      Question(
        text: 'Su kalitesinde ağır metal kirliliğinin en tehlikeli kaynakları nelerdir?',
        options: [
          Option(text: 'Sadece trafik', score: 0),
          Option(text: 'Endüstriyel atık, madencilik ve uygunsuz bertaraf', score: 10),
          Option(text: 'Sadece tarım', score: 0),
          Option(text: 'Sadece evsel atık', score: 0),
        ],
        category: 'Su',
      ),
      Question(
        text: 'Su kalitesinde mikroplastik kirliliği nasıl tespit edilir?',
        options: [
          Option(text: 'Sadece mikroskop', score: 0),
          Option(text: 'Spektroskopi, mikroskopi ve kimyasal analiz', score: 10),
          Option(text: 'Sadece filtrasyon', score: 0),
          Option(text: 'Sadece sedimantasyon', score: 0),
        ],
        category: 'Su',
      ),
      Question(
        text: 'Su kalitesinde pesticides (pestisit) kalıntıları hangi sağlık risklerini oluşturur?',
        options: [
          Option(text: 'Sadece cilt problemleri', score: 0),
          Option(text: 'Kanser riski, hormonal bozukluklar ve sinir sistemi etkileri', score: 10),
          Option(text: 'Sadece sindirim problemleri', score: 0),
          Option(text: 'Sadece alerjik reaksiyonlar', score: 0),
        ],
        category: 'Su',
      ),
      Question(
        text: 'Su kalitesinde pharmaceutical compounds (ilaç kalıntıları) hangi arıtma yöntemleriyle temizlenir?',
        options: [
          Option(text: 'Sadece klorlama', score: 0),
          Option(text: 'Aktif karbon, membran filtrasyon ve ileri oksidasyon', score: 10),
          Option(text: 'Sadece UV dezenfeksiyon', score: 0),
          Option(text: 'Sadece filtrasyon', score: 0),
        ],
        category: 'Su',
      ),
      Question(
        text: 'Su kalitesinde eutrophication (ötrofikasyon) nedir?',
        options: [
          Option(text: 'Sadece su kirliliği', score: 0),
          Option(text: 'Besleyici maddelerin fazla olmasıyla alg büyümesi', score: 10),
          Option(text: 'Sadece sıcaklık artışı', score: 0),
          Option(text: 'Sadece pH değişimi', score: 0),
        ],
        category: 'Su',
      ),
      Question(
        text: 'Su kalitesinde bacterial contamination (bakteriyel kirlilik) hangi yöntemlerle kontrol edilir?',
        options: [
          Option(text: 'Sadece klorlama', score: 0),
          Option(text: 'Dezenfeksiyon, filtrasyon ve kaynak koruması', score: 10),
          Option(text: 'Sadece UV', score: 0),
          Option(text: 'Sadece ozonlama', score: 0),
        ],
        category: 'Su',
      ),
      Question(
        text: 'Su kalitesinde salinity (tuzluluk) artışının nedenleri nelerdir?',
        options: [
          Option(text: 'Sadece deniz suyu karışımı', score: 0),
          Option(text: 'Deniz suyu girişi, tuzlu su sondajı ve iklim değişikliği', score: 10),
          Option(text: 'Sadece endüstriyel atık', score: 0),
          Option(text: 'Sadece tarımsal faaliyet', score: 0),
        ],
        category: 'Su',
      ),
      Question(
        text: 'Su kalitesinde turbidity (bulanıklık) hangi sorunlara yol açar?',
        options: [
          Option(text: 'Sadece görsel problem', score: 0),
          Option(text: 'Dezenfeksiyon etkinliğini azaltma ve sağlık riskleri', score: 10),
          Option(text: 'Sadece tat problemi', score: 0),
          Option(text: 'Sadece koku problemi', score: 0),
        ],
        category: 'Su',
      ),
      Question(
        text: 'Su kalitesinde endocrine disruptors (endokrin bozucular) hangi kaynaklardan gelir?',
        options: [
          Option(text: 'Sadece endüstriyel atık', score: 0),
          Option(text: 'Plastik, pestisit, ilaç kalıntıları ve kişisel bakım ürünleri', score: 10),
          Option(text: 'Sadece tarım', score: 0),
          Option(text: 'Sadece trafik', score: 0),
        ],
        category: 'Su',
      ),
      Question(
        text: 'Su kalitesinde natural organic matter (doğal organik madde) hangi problemleri yaratır?',
        options: [
          Option(text: 'Sadece renk problemi', score: 0),
          Option(text: 'DBP oluşumu, koku ve mikrobiyal büyüme', score: 10),
          Option(text: 'Sadece pH değişimi', score: 0),
          Option(text: 'Sadece sertlik artışı', score: 0),
        ],
        category: 'Su',
      ),
      Question(
        text: 'Su kalitesinde radyoaktif kirlilik hangi nedenlerle oluşur?',
        options: [
          Option(text: 'Sadece nükleer santral kazaları', score: 0),
          Option(text: 'Doğal radyoaktif maddeler, nükleer faaliyetler ve tıbbi atıklar', score: 10),
          Option(text: 'Sadece madencilik', score: 0),
          Option(text: 'Sadece endüstriyel faaliyet', score: 0),
        ],
        category: 'Su',
      ),
      Question(
        text: 'Su kalitesinde emerging contaminants (yeni ortaya çıkan kirleticiler) nelerdir?',
        options: [
          Option(text: 'Sadece ağır metaller', score: 0),
          Option(text: 'Nanomalzemeler, ilaç kalıntıları ve mikroplastikler', score: 10),
          Option(text: 'Sadece pestisitler', score: 0),
          Option(text: 'Sadece petrol ürünleri', score: 0),
        ],
        category: 'Su',
      ),
      Question(
        text: 'Su kalitesinde chlorine residual (klor kalıntısı) neden önemlidir?',
        options: [
          Option(text: 'Sadece dezenfeksiyon', score: 0),
          Option(text: 'Dağıtım sisteminde mikrobiyal büyümeyi önleme', score: 10),
          Option(text: 'Sadece tat iyileştirme', score: 0),
          Option(text: 'Sadece koku giderme', score: 0),
        ],
        category: 'Su',
      ),
      Question(
        text: 'Su kalitesinde iron and manganese (demir ve manganez) hangi sorunlara yol açar?',
        options: [
          Option(text: 'Sadece tat problemi', score: 0),
          Option(text: 'Renk, koku ve leke oluşumu', score: 10),
          Option(text: 'Sadece sağlık sorunu', score: 0),
          Option(text: 'Sadece korozyon', score: 0),
        ],
        category: 'Su',
      ),
      Question(
        text: 'Su kalitesinde biofilm formation (biyofilm oluşumu) nasıl önlenir?',
        options: [
          Option(text: 'Sadece klorlama', score: 0),
          Option(text: 'Uygun dezenfeksiyon, akış hızı ve yüzey özellikleri', score: 10),
          Option(text: 'Sadece filtrasyon', score: 0),
          Option(text: 'Sadece UV', score: 0),
        ],
        category: 'Su',
      ),
      Question(
        text: 'Su kalitesinde corrosion (korozyon) sorunu nasıl kontrol edilir?',
        options: [
          Option(text: 'Sadece pH kontrolü', score: 0),
          Option(text: 'pH ayarlama, korozyon inhibitörleri ve malzeme seçimi', score: 10),
          Option(text: 'Sadece akış kontrolü', score: 0),
          Option(text: 'Sadece sıcaklık kontrolü', score: 0),
        ],
        category: 'Su',
      ),
      Question(
        text: 'Su kalitesinde taste and odor (tat ve koku) sorunlarının nedenleri nelerdir?',
        options: [
          Option(text: 'Sadece klorlama', score: 0),
          Option(text: 'Biyolojik aktivite, endüstriyel kirlilik ve doğal kaynaklar', score: 10),
          Option(text: 'Sadece mineral konsantrasyonu', score: 0),
          Option(text: 'Sadece pH değişimi', score: 0),
        ],
        category: 'Su',
      ),
      Question(
        text: 'Su kalitesinde virus removal (virüs uzaklaştırma) hangi yöntemlerle yapılır?',
        options: [
          Option(text: 'Sadece klorlama', score: 0),
          Option(text: 'İnaktif etme ve uzaklaştırma kombinasyonu', score: 10),
          Option(text: 'Sadece UV', score: 0),
          Option(text: 'Sadece filtrasyon', score: 0),
        ],
        category: 'Su',
      ),
      Question(
        text: 'Su kalitesinde temperature (sıcaklık) etkisi nedir?',
        options: [
          Option(text: 'Sadece konfor', score: 0),
          Option(text: 'Oksijen çözünürlüğü, kimyasal reaksiyonlar ve mikrobiyal büyüme', score: 10),
          Option(text: 'Sadece tat', score: 0),
          Option(text: 'Sadece renk', score: 0),
        ],
        category: 'Su',
      ),
    ];
  }
}