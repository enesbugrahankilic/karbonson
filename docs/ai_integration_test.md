# AI Entegrasyonu Test Rehberi

## Test Ortamı Kurulumu

AI entegrasyonunu test etmek için aşağıdaki adımları izleyin:

### 1. Python API Sunucusunu Başlatma

```bash
cd python_api
pip install -r requirements.txt
python ai_api.py
```

API sunucusunun başarıyla başladığını doğrulayın. Çıktıda "Running on http://0.0.0.0:5000" mesajını görmelisiniz.

### 2. Flutter Uygulamasını Başlatma

```bash
cd ..
flutter pub get
flutter run
```

Flutter uygulaması açıldığında, AI önerileri sayfasına gidin. Bunun için `/ai-recommendations` rotasına gitmeniz gerekir.

## Manuel Test Senaryoları

### Test 1: AI Önerilerini Görüntüleme

1. Flutter uygulamasında `/ai-recommendations` sayfasına gidin
2. Sayfa yüklendiğinde, AI önerileri gösterilmelidir
3. Önerilerde quiz başlığı, kategorisi, güven puanı ve neden bilgisi bulunmalıdır

### Test 2: AI Davranış Analizi

1. Flutter uygulamasında `/ai-recommendations` sayfasında bulunan herhangi bir öneriye tıklayın
2. Bu işlem AI davranış analizi fonksiyonunu tetiklemelidir
3. Analiz sonuçları konsol çıktısında görüntülenmelidir

### Test 3: Kullanıcı Verisi Gönderimi

1. Flutter uygulamasında herhangi bir quiz tamamlandığında veya profil sayfası ziyaret edildiğinde
2. Kullanıcı verisi otomatik olarak AI API'sine gönderilmelidir
3. Bu işlem konsol çıktısında görüntülenmelidir

## Otomatik Testler

### Python API Testleri

Python API'si için otomatik testler oluşturulmuştur. Bu testleri çalıştırmak için:

```bash
cd python_api
pip install pytest
pytest test_ai_api.py
```

### Flutter Uygulaması Testleri

Flutter uygulaması için otomatik testler oluşturulmuştur. Bu testleri çalıştırmak için:

```bash
cd ..
flutter test lib/tests/ai_service_test.dart
```

## Test Sonuçları Değerlendirme

Tüm testler başarıyla geçerse, AI entegrasyonu düzgün çalışıyor demektir. Herhangi bir test başarısız olursa, aşağıdaki adımları izleyin:

1. API sunucusunun çalıştığını doğrulayın
2. Flutter uygulamasındaki ağ bağlantısı izinlerini kontrol edin
3. API endpoint'lerinin doğru olduğunu kontrol edin
4. Konsol çıktılarını inceleyerek hata mesajlarını analiz edin

## Sorun Giderme

### Yaygın Sorunlar

1. **"Connection refused" hatası**: API sunucusu çalışmıyor olabilir. Sunucuyu yeniden başlatın.
2. **Boş öneriler**: Kullanıcının quiz geçmişi verisi eksik olabilir. Daha fazla quiz verisi ekleyin.
3. **Yavaş yanıt süreleri**: Sunucu performansı düşük olabilir. Sunucu kaynaklarını kontrol edin.

### Gelişmiş Hata Ayıklama

Daha ayrıntılı hata ayıklama için:

1. API sunucusunda debug modunu etkinleştirin
2. Flutter uygulamasında daha ayrıntılı loglama ekleyin
3. Postman veya curl ile API endpoint'lerini manuel olarak test edin

## Sonuç

Bu test rehberi, AI entegrasyonunun doğru çalışıp çalışmadığını kontrol etmenize yardımcı olacaktır. Herhangi bir sorunla karşılaştığınızda, yukarıdaki sorun giderme adımlarını izleyin.