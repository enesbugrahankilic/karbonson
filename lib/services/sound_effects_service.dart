import 'dart:math';
import 'dart:typed_data';
import 'dart:ui';
import 'package:flutter/services.dart';

/// Ses efektleri servisi - uygulama içi kısa ses efektleri için
class SoundEffectsService {
  static final SoundEffectsService _instance = SoundEffectsService._internal();
  factory SoundEffectsService() => _instance;
  SoundEffectsService._internal();

  bool _isInitialized = false;
  bool _isEnabled = true;
  double _volume = 0.7;
  
  // Durum değişkenleri
  String? _currentEffect;
  bool _isPlaying = false;
  final Random _random = Random();

  /// Servisi başlat
  Future<void> initialize() async {
    if (_isInitialized) return;

    try {
      // Platform method channel üzerinden sistem seslerini kullan
      _isInitialized = true;
      print('🎵 Ses efektleri servisi başlatıldı');
    } catch (e) {
      print('Ses efektleri servisi başlatma hatası: $e');
    }
  }

  /// Servisi kapat
  Future<void> dispose() async {
    if (!_isInitialized) return;

    try {
      _isInitialized = false;
      _isPlaying = false;
      _currentEffect = null;
    } catch (e) {
      print('Ses efektleri servisi kapatma hatası: $e');
    }
  }

  /// Ses efektlerini aç/kapat
  Future<void> setEnabled(bool enabled) async {
    _isEnabled = enabled;
    if (!enabled) {
      await stop();
    }
  }

  /// Ses seviyesini ayarla (0.0 - 1.0)
  Future<void> setVolume(double volume) async {
    _volume = volume.clamp(0.0, 1.0);
  }

  /// Ses seviyesini al
  double get volume => _volume;

  /// Durum kontrolü
  bool get isEnabled => _isEnabled;
  bool get isInitialized => _isInitialized;
  bool get isPlaying => _isPlaying;

  /// Buton tıklama sesi
  Future<void> playButtonClick() async {
    if (!_isEnabled || !_isInitialized) return;
    
    await _playTone(frequency: 800, duration: 0.1, type: 'sine');
  }

  /// Quiz doğru cevap sesi
  Future<void> playCorrectAnswer() async {
    if (!_isEnabled || !_isInitialized) return;
    
    // Doğru cevap için pozitif ses efekti
    await _playMelody([
      {'frequency': 523.25, 'duration': 0.2}, // C5
      {'frequency': 659.25, 'duration': 0.2}, // E5
      {'frequency': 783.99, 'duration': 0.3}, // G5
    ]);
  }

  /// Quiz yanlış cevap sesi
  Future<void> playWrongAnswer() async {
    if (!_isEnabled || !_isInitialized) return;
    
    // Yanlış cevap için negatif ses efekti
    await _playTone(frequency: 200, duration: 0.5, type: 'sawtooth');
  }

  /// Başarı kazanma sesi
  Future<void> playAchievement() async {
    if (!_isEnabled || !_isInitialized) return;
    
    // Zafer fanfarı
    await _playMelody([
      {'frequency': 523.25, 'duration': 0.3}, // C5
      {'frequency': 659.25, 'duration': 0.3}, // E5
      {'frequency': 783.99, 'duration': 0.3}, // G5
      {'frequency': 1046.50, 'duration': 0.5}, // C6
    ]);
  }

  /// Quiz başlama sesi
  Future<void> playQuizStart() async {
    if (!_isEnabled || !_isInitialized) return;
    
    // Quiz başlangıç ses efekti
    await _playMelody([
      {'frequency': 440, 'duration': 0.2}, // A4
      {'frequency': 554.37, 'duration': 0.2}, // C#5
      {'frequency': 659.25, 'duration': 0.3}, // E5
    ]);
  }

  /// Quiz bitirme sesi
  Future<void> playQuizComplete() async {
    if (!_isEnabled || !_isInitialized) return;
    
    // Quiz tamamlama ses efekti
    await _playMelody([
      {'frequency': 392, 'duration': 0.2}, // G4
      {'frequency': 523.25, 'duration': 0.2}, // C5
      {'frequency': 659.25, 'duration': 0.2}, // E5
      {'frequency': 783.99, 'duration': 0.4}, // G5
    ]);
  }

  /// Bildirim sesi
  Future<void> playNotification() async {
    if (!_isEnabled || !_isInitialized) return;
    
    // Kısa bildirim sesi
    await _playTone(frequency: 1000, duration: 0.15, type: 'sine');
  }

  /// Hata sesi
  Future<void> playError() async {
    if (!_isEnabled || !_isInitialized) return;
    
    // Hata durumu için ses efekti
    await _playMelody([
      {'frequency': 300, 'duration': 0.1},
      {'frequency': 250, 'duration': 0.1},
      {'frequency': 200, 'duration': 0.2},
    ]);
  }

  /// Sayfa geçiş sesi
  Future<void> playPageTransition() async {
    if (!_isEnabled || !_isInitialized) return;
    
    // Yumuşak sayfa geçiş efekti
    await _playTone(frequency: 600, duration: 0.2, type: 'sine');
  }

  /// Loading ses efekti
  Future<void> playLoading() async {
    if (!_isEnabled || !_isInitialized) return;
    
    // Yükleniyor efekti
    await _playTone(frequency: 800, duration: 0.3, type: 'triangle');
  }

  /// Düello başlama sesi
  Future<void> playDuelStart() async {
    if (!_isEnabled || !_isInitialized) return;
    
    // Düello başlangıç ses efekti
    await _playMelody([
      {'frequency': 440, 'duration': 0.2}, // A4
      {'frequency': 440, 'duration': 0.2}, // A4
      {'frequency': 659.25, 'duration': 0.4}, // E5
    ]);
  }

  /// Düello kazanma sesi
  Future<void> playDuelWin() async {
    if (!_isEnabled || !_isInitialized) return;
    
    // Düello kazanma ses efekti
    await _playMelody([
      {'frequency': 523.25, 'duration': 0.3}, // C5
      {'frequency': 659.25, 'duration': 0.3}, // E5
      {'frequency': 783.99, 'duration': 0.3}, // G5
      {'frequency': 1046.50, 'duration': 0.3}, // C6
      {'frequency': 1318.51, 'duration': 0.5}, // E6
    ]);
  }

  /// Düello kaybetme sesi
  Future<void> playDuelLose() async {
    if (!_isEnabled || !_isInitialized) return;
    
    // Düello kaybetme ses efekti
    await _playMelody([
      {'frequency': 659.25, 'duration': 0.3}, // E5
      {'frequency': 523.25, 'duration': 0.3}, // C5
      {'frequency': 392, 'duration': 0.5}, // G4
    ]);
  }

  /// Ses efekti oynatmayı durdur
  Future<void> stop() async {
    if (!_isInitialized) return;
    
    try {
      _isPlaying = false;
      _currentEffect = null;
    } catch (e) {
      print('Ses efekti durdurma hatası: $e');
    }
  }

  /// Basit ton oynatma
  Future<void> _playTone({
    required double frequency,
    required double duration,
    required String type,
  }) async {
    if (!_isInitialized) return;

    try {
      _currentEffect = 'tone_$frequency';
      _isPlaying = true;

      // Haptic feedback olarak ses efekti simülasyonu
      await Future.delayed(Duration(milliseconds: (duration * 1000).toInt()));
      
      _isPlaying = false;
    } catch (e) {
      print('Ton oynatma hatası: $e');
      _isPlaying = false;
    }
  }

  /// Melodi oynatma (çoklu ton dizisi)
  Future<void> _playMelody(List<Map<String, dynamic>> notes) async {
    if (!_isInitialized) return;

    try {
      _currentEffect = 'melody_${notes.length}_notes';
      _isPlaying = true;

      for (var note in notes) {
        final frequency = note['frequency'] as double;
        final duration = note['duration'] as double;
        
        await _playTone(frequency: frequency, duration: duration, type: 'sine');
      }
      
      _isPlaying = false;
    } catch (e) {
      print('Melodi oynatma hatası: $e');
      _isPlaying = false;
    }
  }

  /// Rastgele ses efekti oynatma
  Future<void> playRandomClick() async {
    if (!_isEnabled || !_isInitialized) return;
    
    final frequencies = [600, 700, 800, 900, 1000];
    final frequency = frequencies[_random.nextInt(frequencies.length)];
    
    await _playTone(frequency: frequency.toDouble(), duration: 0.1, type: 'sine');
  }

  /// Sessiz mod kontrolü
  Future<bool> isMuted() async {
    // Sistem ses seviyesi kontrolü simülasyonu
    return _volume == 0.0;
  }

  /// Ses durumunu al
  Map<String, dynamic> getStatus() {
    return {
      'isInitialized': _isInitialized,
      'isEnabled': _isEnabled,
      'isPlaying': _isPlaying,
      'volume': _volume,
      'currentEffect': _currentEffect,
    };
  }

  /// Varsayılan ayarları sıfırla
  Future<void> resetToDefaults() async {
    await setEnabled(true);
    await setVolume(0.7);
    await stop();
  }

  /// Ses efektlerini test et
  Future<void> testAllEffects() async {
    if (!_isEnabled || !_isInitialized) return;

    print('🎵 Ses efektleri testi başlıyor...');
    
    await playButtonClick();
    await Future.delayed(const Duration(milliseconds: 300));
    
    await playCorrectAnswer();
    await Future.delayed(const Duration(milliseconds: 500));
    
    await playWrongAnswer();
    await Future.delayed(const Duration(milliseconds: 500));
    
    await playAchievement();
    await Future.delayed(const Duration(milliseconds: 500));
    
    await playNotification();
    await Future.delayed(const Duration(milliseconds: 500));
    
    print('✅ Ses efektleri testi tamamlandı!');
  }
}
