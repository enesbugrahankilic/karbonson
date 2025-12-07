# AI API Dokümantasyonu

## Gereksinimler

Bu API'yi çalıştırmak için Python 3.7+ ve pip paket yöneticisinin kurulu olması gerekir.

## Kurulum

1. Python kurulumu için [Python Kurulum Rehberi](../docs/python_kurulum_rehberi.md) dosyasına bakın.

2. Gerekli paketleri yükleyin:
```bash
pip install -r requirements.txt
```

## API'yi Çalıştırma

```bash
python ai_api.py
```

Bu komut, API'yi http://localhost:5000 adresinde çalıştıracaktır.

## API Endpoint'leri

### 1. Öneriler Endpoint'i

**GET /recommendations?user_id=<KULLANICI_ID>**

Kullanıcı için kişiselleştirilmiş quiz önerilerini döndürür.

**Örnek istek:**
```bash
curl http://localhost:5000/recommendations?user_id=user1
```

**Örnek yanıt:**
```json
{
  "recommendations": [
    {
      "quizId": "quiz4",
      "quizTitle": "Dünya Başkentleri",
      "category": "Coğrafya",
      "confidenceScore": 0.85,
      "reason": "Based on your quiz history and similar user preferences"
    },
    {
      "quizId": "quiz5",
      "quizTitle": "Antik Roma",
      "category": "Tarih",
      "confidenceScore": 0.75,
      "reason": "Based on your quiz history and similar user preferences"
    }
  ]
}
```

### 2. Kullanıcı Davranış Analizi

**GET /analyze?user_id=<KULLANICI_ID>**

Kullanıcının davranış analizini döndürür.

**Örnek istek:**
```bash
curl http://localhost:5000/analyze?user_id=user1
```

**Örnek yanıt:**
```json
{
  "userId": "user1",
  "preferredCategories": ["Coğrafya", "Tarih"],
  "avgScore": 4.2,
  "engagementLevel": "Yüksek",
  "timeSpent": "15 dakika",
  "lastActive": "2025-01-17T15:30:00",
  "recommendationsCount": 3,
  "socialInteractions": 5
}
```

### 3. Kullanıcı Verisi Gönderimi

**POST /user_data**

Kullanıcı verilerini sisteme gönderir.

**Örnek istek:**
```bash
curl -X POST http://localhost:5000/user_data \
  -H "Content-Type: application/json" \
  -d '{"userId": "test_user", "quizHistory": [{"quizId": "quiz1", "rating": 5}]}'
```

**Örnek yanıt:**
```json
{
  "status": "success",
  "message": "User data received"
}
```

## Test

### Otomatik Testler

API'yi test etmek için otomatik testler çalıştırılabilir:

```bash
pip install pytest
pytest test_ai_api.py
```

### Manuel Testler

API endpoint'lerini manuel olarak test etmek için:

```bash
bash test_api.sh
```

Bu script, tüm API endpoint'lerini test edecek ve sonuçları gösterecektir.

## Matris Ayrıştırma Tabanlı Tavsiye Sistemi

Bu API, kullanıcı-quiz etkileşimlerini analiz ederek matris ayrıştırma (SVD) tekniğini kullanarak kişiselleştirilmiş öneriler üretir. Sistem, aşağıdaki adımları izler:

1. Kullanıcı-quiz etkileşim matrisini oluşturur
2. TruncatedSVD ile matrisi ayrıştırır
3. Kullanıcı ve quiz faktörlerini hesaplar
4. Kullanıcının henüz yapmadığı quizler için öneri puanlarını hesaplar
5. En yüksek puanlı quizleri öneri olarak döndürür

## Veri İşleme Kütüphaneleri

API, aşağıdaki Python kütüphanelerini kullanır:

- **Pandas**: Veri manipülasyonu ve analizi
- **NumPy**: Sayısal hesaplamalar
- **Scikit-learn**: Makine öğrenmesi algoritmaları (TruncatedSVD)
- **Scipy**: Bilimsel hesaplamalar

## Veri Formatı

API, JSON formatında veri alır ve döndürür. Bu, Flutter uygulamasıyla kolay entegrasyon sağlar.

## Gelecek Geliştirmeler

1. Daha gelişmiş öneri algoritmaları eklenmesi
2. Gerçek zamanlı öğrenme mekanizmaları
3. Daha kapsamlı kullanıcı davranış analizi
4. API performans optimizasyonları