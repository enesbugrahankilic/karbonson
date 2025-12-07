# AI Entegrasyonu İmplementasyon Raporu

## Genel Bakış

KarbonSon uygulaması için yapay zeka (AI) entegrasyonu başarıyla tamamlanmıştır. Bu rapor, entegrasyonun ayrıntılarını ve nasıl kullanılacağını açıklamaktadır.

## Seçilen Teknolojiler

- **AI Teknolojisi**: Custom AI Model
- **Veri Kaynakları**: Kullanıcı Quiz Geçmişi, Kullanıcı Oyun Süreleri, Kullanıcı Sosyal Etkileşimleri, Kullanıcı Profil Verileri
- **AI Modeli**: Matris Ayrıştırma Tabanlı Tavsiye Sistemi
- **Veri Formatı**: JSON
- **Veri İşleme Kütüphaneleri**: Pandas, NumPy, Scikit-learn, TensorFlow

## Yeni Eklenen Dosyalar

1. **lib/services/ai_service.dart**
   - AI API'si ile iletişim kurmak için temel servis
   - Kullanıcı verilerini AI'ye gönderme ve kişiselleştirilmiş quiz önerilerini alma fonksiyonları
   - HTTP istekleri için gerekli kodları içerir

2. **lib/models/ai_recommendation.dart**
   - AI tarafından önerilen quizler için veri modeli
   - Quiz ID, başlık, kategori, güven puanı ve neden bilgilerini içerir
   - JSON ile serileştirme/derserileştirme metodları

3. **lib/provides/ai_bloc.dart**
   - AI BLoC (Business Logic Component) yapısı
   - AI önerilerini yönetmek ve UI'ya bildirmek için kullanılır
   - Quiz önerileri yükleme ve hata durumları için event/state yönetimi

4. **lib/widgets/ai_recommendation_widget.dart**
   - AI önerilerini göstermek için özelleştirilmiş widget
   - Quiz başlığı, kategorisi, güven puanı ve neden bilgilerini gösterir
   - Tıklanabilir tasarım, kullanıcıyı quiz detayına yönlendirmek için

5. **lib/pages/ai_recommendations_page.dart**
   - AI önerilerini görüntülemek için sayfa
   - BLoC ile entegre çalışır, önerileri listeler
   - Yükleme ve hata durumları için UI durumları

## Değiştirilen Dosyalar

1. **lib/core/navigation/app_router.dart**
   - Yeni AI önerileri sayfası için route eklendi
   - `/ai-recommendations` adıyla route tanımlandı

2. **pubspec.yaml**
   - HTTP istekleri için gerekli `http` paketi eklendi
   - Versiyon: `^1.2.2`

3. **lib/main.dart**
   - `AIService` ve `AIBloc` için importlar eklendi
   - MultiProvider'a AIBloc provider'ı eklendi
   - AIService, localhost:5000 üzerinde çalışan AI API'sine bağlanacak şekilde yapılandırıldı

## Python Flask API

### AI API Sunucusu

AI önerilerini sağlamak için `python_api/ai_api.py` dosyasında bir Flask API'si geliştirilmiştir. Bu API:

- `/recommendations` endpoint'i ile kullanıcı bazlı quiz önerilerini sağlar
- `/analyze` endpoint'i ile kullanıcı davranış analizini sağlar
- `/user_data` endpoint'i ile kullanıcı verilerini kabul eder

Matris Ayrıştırma Tabanlı Tavsiye Sistemi (SVD) kullanarak kullanıcı-quiz etkileşimlerini analiz eder ve kişiselleştirilmiş öneriler üretir.

### Python Kurulumu

API'yi çalıştırmak için Python ve pip'in sistemde kurulu olması gerekir. macOS için Python kurulum rehberi için `docs/python_kurulum_rehberi.md` dosyasına bakın.

### API Başlatma

API'yi başlatmak için:

1. Gerekli Python paketlerini yükleyin:
```bash
pip install -r python_api/requirements.txt
```

2. API sunucusunu başlatın:
```bash
python python_api/ai_api.py
```

Bu komut, API'yi http://localhost:5000 adresinde başlatacaktır.

### API Entegrasyonu

Flutter uygulaması, `lib/services/ai_service.dart` dosyası üzerinden bu API ile iletişim kurar. AIService sınıfı, API isteklerini yönetir ve yanıtları işler.

### API Dokümantasyonu

API hakkında detaylı dokümantasyon için `python_api/README.md` dosyasına bakın.

## Kullanım Talimatları

### AI Önerilerini Gösterme

Uygulamada AI önerilerini göstermek için `/ai-recommendations` rotasına gitmeniz yeterlidir. Bu, `AIRecommendationsPage` bileşenini görüntüleyecektir.

### Kodun Entegrasyonu

AI entegrasyonu mevcut uygulama mimarisine sorunsuz entegre edilmiştir. Provider (BLoC) yapısı kullanılarak, AI servisleri uygulama genelinde erişilebilir hale getirilmiştir.

### AI API'si Yapılandırması

`lib/main.dart` dosyasında AIService, şu anda localhost:5000 adresine bağlanacak şekilde yapılandırılmıştır. Üretim ortamında, bu URL'yi gerçek AI API sunucu adresiyle değiştirmeniz gerekecektir.

## Test

AI entegrasyonu için kapsamlı test senaryoları oluşturulmuştur. Detaylı test rehberi için `docs/ai_integration_test.md` dosyasına bakın.

### Test Türleri

1. **Python API Testleri**:
   - `/recommendations` endpoint testi
   - `/analyze` endpoint testi
   - `/user_data` endpoint testi

2. **Flutter Uygulaması Testleri**:
   - AI önerileri görüntüleme testi
   - AI davranış analizi testi
   - Kullanıcı verisi gönderimi testi

3. **Entegrasyon Testleri**:
   - API bağlantısı testleri
   - Veri işleme testleri
   - Hata durumu testleri

### Test Komutları

Python API testleri:
```bash
cd python_api
pip install pytest
pytest test_ai_api.py
```

Flutter uygulaması testleri:
```bash
flutter test lib/tests/ai_service_test.dart
```

Manuel API testleri:
```bash
bash python_api/test_api.sh
```

## Gelecek Geliştirmeler

1. **Daha Gelişmiş Öneriler**: Matris ayrıştırma tabanlı tavsiye sistemi, kullanıcı tercihlerine göre daha doğru öneriler yapacak şekilde geliştirilebilir.

2. **Gerçek Zamanlı Öğrenme**: Kullanıcı geri bildirimleriyle modelin sürekli iyileştirilmesi için gerçek zamanlı öğrenme mekanizmaları eklenebilir.

3. **AI Önerilerinin Kişiselleştirilmesi**: Kullanıcıların AI önerilerini özelleştirebilmesi için bir arayüz eklenebilir.

## Sonuç

KarbonSon uygulamasına AI entegrasyonu başarıyla tamamlanmıştır. Bu entegrasyon, kullanıcılara kişiselleştirilmiş quiz önerileri sunarak uygulamanın kullanılabilirliğini ve kullanıcı etkileşimini artıracaktır. Matris ayrıştırma tabanlı öneri sistemi, kullanıcı davranışlarına göre daha doğru öneriler sağlayacaktır. Ayrıca, kapsamlı test senaryoları ve dokümantasyon ile sistem güvenilirliği sağlanmıştır.

