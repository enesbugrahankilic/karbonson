// lib/services/firestore_service.dart

import 'package:cloud_firestore/cloud_firestore.dart';

class FirestoreService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  // Skorların kaydedildiği koleksiyon adı
  static const String _collectionName = 'users';

  /// Yeni bir kullanıcının skorunu Firestore'a kaydeder.
  Future<void> saveUserScore(String nickname, int score) async {
    try {
      await _db.collection(_collectionName).doc().set({
        'nickname': nickname, // Oyuncu takma adı
        'score': score,       // Oyun sonu skoru
        'timestamp': FieldValue.serverTimestamp(), // Kayıt zamanı
      });
      print('Başarılı: Skor $nickname için kaydedildi: $score');
    } catch (e) {
      print('HATA: Skor kaydederken hata oluştu: $e');
    }
  }

  /// Tüm skorları puana göre azalan sırada (en yüksekten en düşüğe) çeker.
  Future<List<Map<String, dynamic>>> getLeaderboard() async {
    try {
      final querySnapshot = await _db
          .collection(_collectionName)
          .orderBy('score', descending: true) // Skora göre sırala
          // .limit(10) kaldırılmıştır, tüm kayıtlar çekilir.
          .get();

      // Dokümanlardan veri haritalarını listeye dönüştür.
      return querySnapshot.docs.map((doc) => doc.data()).toList();
      
    } catch (e) {
      print('HATA: Liderlik tablosu getirilirken hata oluştu: $e');
      return []; 
    }
  }
}