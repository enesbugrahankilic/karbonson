# Firebase Firestore Index Hatası Çözüm Rehberi

## Sorun Tanımı

Uygulamanızda "aktif odalar getirilirken hata" mesajı alıyorsunuz. Bu hata Firebase Firestore'da composite index eksikliğinden kaynaklanmaktadır.

### Hata Mesajı
```
flutter: HATA: Aktif odalar getirilirken hata: [cloud_firestore/failed-precondition] The query requires an index. You can create it here: https://console.firebase.google.com/v1/r/project/karbon2-c39e7/firestore/indexes?create_composite=...
```

### Hatanın Nedeni
`FirestoreService.getActiveRooms()` metodu aşağıdaki sorguyu çalıştırmaya çalışıyor:

```dart
_db.collection('game_rooms')
    .where('status', isEqualTo: 'waiting')
    .where('isActive', isEqualTo: true)
    .orderBy('createdAt', descending: true)
    .limit(20)
    .get();
```

Bu sorgu 3 alanda filtreleme ve sıralama yapıyor:
1. `isActive` (boolean)
2. `status` (string) 
3. `createdAt` (timestamp) - sıralama için

Firebase Firestore'da bu tür çoklu koşullu sorgular için composite index gereklidir.

## Çözüm

### 1. Firebase Console'dan Index Oluşturma

Hızlı çözüm için, hata mesajındaki linke tıklayın:

**🔗 [Index Oluşturma Linki](https://console.firebase.google.com/v1/r/project/karbon2-c39e7/firestore/indexes?create_composite=ClBwcm9qZWN0cy9rYXJib24yLWMzOWU3L2RhdGFiYXNlcy8oZGVmYXVsdCkvY29sbGVjdGlvbkdyb3Vwcy9nYW1lX3Jvb21zL2luZGV4ZXMvXxABGgwKCGlzQWN0aXZlEAEaCgoGc3RhdHVzEAEaDQoJY3JlYXRlZEF0EAIaDAoIX19uYW1lX18QAg)**

**ADIMLAR:**
1. Yukarıdaki linke tıklayın
2. "Create Index" butonuna tıklayın
3. Index'in oluşmasını bekleyin (genellikle 2-5 dakika)

### 2. Manuel Index Oluşturma

Eğer link çalışmazsa, Firebase Console'dan manuel olarak oluşturun:

1. [Firebase Console](https://console.firebase.google.com/) → Proje: `karbon2-c39e7` → Firestore Database → Indexes sekmesine gidin
2. "Create Index" butonuna tıklayın
3. **Collection ID:** `game_rooms`
4. **Fields to index:**
   - `isActive` (Ascending)
   - `status` (Ascending) 
   - `createdAt` (Descending)
5. "Create" butonuna tıklayın

### 3. Deployment ile Index Oluşturma (Opsiyonel)

Projenizin `firestore/indexes.json` dosyasını oluşturdum. Bu dosyayı kullanarak Firebase CLI ile de index oluşturabilirsiniz:

```bash
# Firebase CLI kurulu değilse:
npm install -g firebase-tools

# Login olun:
firebase login

# Proje dizinine gidin ve:
firebase deploy --only firestore:indexes
```

## Teknik Detaylar

### Query Analizi
```dart
// Mevcut problematic query
Future<List<GameRoom>> getActiveRooms() async {
  final querySnapshot = await _db
      .collection('game_rooms')
      .where('status', isEqualTo: 'waiting')        // Koşul 1
      .where('isActive', isEqualTo: true)           // Koşul 2
      .orderBy('createdAt', descending: true)      // Sıralama
      .limit(20)
      .get();
}
```

### Gerekli Composite Index
- **Collection:** `game_rooms`
- **Fields:**
  1. `isActive` (ASC)
  2. `status` (ASC) 
  3. `createdAt` (DESC)

## Test Etme

Index oluşturulduktan sonra:

1. Uygulamayı yeniden çalıştırın
2. Multiplayer lobby'e gidin
3. Aktif odalar listesinin yüklendiğini kontrol edin
4. Console'da hata mesajı kalmadığını doğrulayın

## Geçici Çözüm (Acil Durum)

Eğer index oluşturma işlemi zaman alıyorsa, geçici olarak sorguyu basitleştirebilirsiniz:

```dart
// Geçici çözüm - sadece temel filtreleme
Future<List<GameRoom>> getActiveRooms() async {
  try {
    final querySnapshot = await _db
        .collection('game_rooms')
        .where('status', isEqualTo: 'waiting')
        .limit(20)
        .get();

    // İstemci tarafında filtrele
    return querySnapshot.docs
        .map((doc) => GameRoom.fromMap(doc.data()))
        .where((room) => room.isActive == true)
        .toList();
  } catch (e) {
    debugPrint('HATA: Aktif odalar getirilirken hata: $e');
    return [];
  }
}
```

⚠️ **Not:** Bu geçici çözüm sadece küçük veri setlerinde performanslıdır. Ana çözüm için composite index'i oluşturun.

## Sonuç

Bu hata, Firebase Firestore'ın composite index gerektiren çoklu koşullu sorguları için normal bir davranışıdır. Yukarıdaki adımları takip ederek sorunu çözebilirsiniz.

**Tahmini süre:** 2-5 dakika (index oluşturma süresi dahil)