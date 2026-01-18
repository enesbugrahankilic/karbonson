# 🎮 Eco Game - Nasıl Oynanır?

Bu rehber, Eco Game uygulamasındaki tüm oyun modlarını ve kurallarını detaylı olarak açıklar.

## 📋 İçindekiler

1. [Genel Bakış](#genel-bakış)
2. [Masa Oyunu Modu](#masa-oyunu-modu)
3. [Düello Modu](#düello-modu)
4. [Çok Oyunculu Mod](#çok-oyunculu-mod)
5. [Puanlama Sistemi](#puanlama-sistemi)
6. [Ödül ve Başarım Sistemi](#ödül-ve-başarım-sistemi)
7. [İpuçları ve Stratejiler](#ipuçları-ve-stratejiler)

---

## 🌿 Genel Bakış

Eco Game, çevre bilinci üzerine kurulu eğitici bir quiz oyunudur. Oyuncular çevre, enerji, su, geri dönüşüm, orman ve tüketim konularında quiz soruları yanıtlayarak puan kazanır.

### Oyun Modları

| Mod | Açıklama | Oyuncu Sayısı |
|-----|----------|---------------|
| 🏠 **Masa Oyunu** | Klasik tahta oyunu tarzı | 1 Oyuncu |
| ⚔️ **Düello** | Hızlı cevap yarışı | 2 Oyuncu |
| 👥 **Çok Oyunculu** | Gerçek zamanlı çok oyunculu | 2-4 Oyuncu |

---

## 🎲 Masa Oyunu Modu

### Oyun Tahtası

Oyun tahtası **25 kareden** oluşur:
- **Başlangıç (🟢)**: Oyunun başladığı yer
- **Quiz (💡)**: Quiz sorusu cevaplanacak kareler
- **Bonus (💰)**: +5 saniye kazandırır
- **Ceza (🛑)**: +5 saniye ceza ve -5 puan kaybı
- **Bitiş (🏁)**: Oyunun sonu

### Kare Dağılımı

```
┌────┬────┬────┬────┬────┐
│ Baş│Quiz│Bons│Quiz│Ceza│  ← Üst sıra
├────┼────┼────┼────┼────┤
│Ceza│Quiz│Bons│Quiz│Bons│
├────┼────┼────┼────┼────┤
│Quiz│Quiz│Ceza│Quiz│Quiz│  ← Orta sıra
├────┼────┼────┼────┼────┤
│Bons│Quiz│Bons│Quiz│Ceza│
├────┼────┼────┼────┼────┤
│Quiz│Ceza│Quiz│Bons│Bitiş│  ← Alt sıra
└────┴────┴────┴────┴────┘
```

### Nasıl Oynanır?

1. **Zar Atma**: "Zar At" butonuna basarak 1-3 arası bir sayı atarsınız
2. **Hareket**: Zar sonucu kadar ilerlersiniz
3. **Kare Etkisi**: 
   - **Quiz Karesi** → Quiz sorusu açılır
   - **Bonus Karesi** → -5 saniye (süre avantajı)
   - **Ceza Karesi** → +5 saniye ceza ve -5 puan
4. **Bitişe Ulaşma**: İlk kez 25. kareye (Bitiş) ulaşan oyuncu oyunu kazanır

### Koruma Sistemi

İlk **2 zar atışında** Ceza kareleri size zarar vermez:
- İlk 2 tur: "Güvenli Bölge! İlk 2 tur koruması devede." mesajı
- 3. tur ve sonrası: Ceza kareleri aktif hale gelir

### Oyun Akışı

```
Zar At → Kareye Git → Kare Etkisini Uygula
                                    ↓
                           Quiz Karesi mi?
                                    ↓
                        ┌───────┴───────┐
                        ↓               ↓
                      EVET            HAYIR
                        ↓               ↓
               Quiz Sorusu        Devam Et
               Cevapla            Etkiyi Göster
                        ↓
                   Puan Kazan
```

---

## ⚔️ Düello Modu

### Genel Bakış

Düello modu, iki oyuncu arasında hızlı cevap yarışıdır. Hem hız hem de doğruluk önemlidir!

### Kurallar

| Özellik | Değer |
|---------|-------|
| Toplam Soru | 5 soru |
| Süre Sınırı | 15 saniye/soru |
| Kazanma Koşulu | İlk 3 doğru cevap VEYA en yüksek puan |
| Temel Puan | 10 puan/doğru cevap |
| Hız Bonusu | (15 - cevap süresi) puan |

### Puan Hesaplama

```
Toplam Puan = Doğru Cevap Sayısı × 10 + Hız Bonusları
Hız Bonusu  = 15 saniye - Cevap Süresi
```

**Örnek**: 8 saniyede cevap verirseniz:
- Temel puan: 10
- Hız bonusu: 15 - 8 = 7
- **Toplam**: 17 puan

### Kazanma Senaryoları

1. **Erken Kazanma**: Bir oyuncu 3 doğru cevap verirse oyun biter
2. **Puan Kazanma**: 5 soru sonunda en yüksek puan alan kazanır
3. **Beraberlik**: Puanlar eşitse toplam puan değerlendirilir

### Oyun Akışı

```
Oda Oluştur → Arkadaşını Davet Et → Rakip Katılır
                                         ↓
                              ←←← Bekleme →→→
                                         ↓
                              Oyun Başlıyor ↓↓↓
                                         ↓
                           Soru 1 (15 sn)
                        ←← Cevapla →→
                                         ↓
                           Soru 2 (15 sn)
                        ←← Cevapla →→
                                         ↓
                           Soru 3 (15 sn)
                        ←← Cevapla →→
                                         ↓
                    (Birinci 3 doğruyu bulan kazanır VEYA devam)
                                         ↓
                           Soru 4 (15 sn)
                           Soru 5 (15 sn)
                                         ↓
                              Kazananı Belirle
```

---

## 👥 Çok Oyunculu Mod

### Oda Sistemi

- **Oda Kodu**: 4 haneli benzersiz kod
- **Oyuncu Sayısı**: 2-4 oyuncu
- **Gerçek Zamanlı**: Tüm oyuncular aynı tahtayı görür

### Nasıl Katılırım?

1. Ana menüden "Çok Oyunculu" seçeneğini seçin
2. "Oda Oluştur" ile yeni oda açın VEYA "Odaya Katıl" ile kod girin
3. Oda kodunu arkadaşlarınızla paylaşın
4. Tüm oyuncular hazır olduğunda oyun başlar

### Sıra Sistemi

- Her oyuncunun kendi sırası vardır
- Sıra göstergesi ekranda belirir
- Bekleyen oyuncular "Bekleniyor..." görür

### Özellikler

| Özellik | Açıklama |
|---------|----------|
| 🎥 İzleyici Modu | Oyunları canlı izleyebilirsiniz |
| 🔄 Tekrar İzleme | Geçmiş oyunları kaydetme ve izleme |
| 💬 Sohbet | Oyun sırasında iletişim |

---

## 📊 Puanlama Sistemi

### Masa Oyunu Skoru

```
Final Skor = Quiz Puanları - (Geçen Süre / 10)

Örnek:
- Quiz Puanları: 150
- Geçen Süre: 5:30 (330 saniye)
- Ceza: 0 puan
- Final Skor = 150 - 33 = 117
```

### Puanlama Kuralları

| Durum | Puan Etkisi |
|-------|-------------|
| Doğru Quiz Cevabı | +10 puan |
| Bonus Kare | -5 saniye |
| Ceza Kare (3+ tur) | +5 saniye, -5 puan |
| Ceza Kare (1-2 tur) | Koruma aktif (0 etki) |

### Leaderboard

- En yüksek skorlar liderlik tablosunda gösterilir
- İlk 10'a girenler özel rozet alır
- Tüm zamanların en iyisi takip edilir

---

## 🏆 Ödül ve Başarım Sistemi

### Günlük Görevler

| Görev | Ödül | Açıklama |
|-------|------|----------|
| 🌱 Çevre Ustası | 25 puan | 5 quiz tamamla |
| ⚡ Enerji Kahramanı | 20 puan | 3 enerji sorusu |
| 💧 Su Koruyucusu | 20 puan | 3 su sorusu |
| 🌲 Orman Dostu | 20 puan | 3 orman sorusu |
| ♻️ Geri Dönüşüm Ustası | 20 puan | 3 geri dönüşüm sorusu |
| 👥 Takım Ruhu | 30 puan | 1 çok oyunculu maç kazan |

### Başarımlar

| Başarım | Gereksinim | Nadirlik |
|---------|------------|----------|
| 🌱 Çevre Elçisi | İlk quizi tamamla | Ortak |
| 🎯 Quiz Ustası | 50 quiz tamamla | Nadir |
| 🏆 Şampiyon | 10 düello kazan | Efsanevi |
| 👥 Sosyal Kelebek | 20 arkadaş ekle | Nadir |
| ⏱️ Hızlı Cevap | 50 soruyu 5 sn altında cevapla | Nadir |
| 🔥 Seri Kazanan | 5 üst üste düello kazan | Efsanevi |

### Rozetler

- **🥉 Bronz**: İlk adımlar
- **🥈 Gümüş**: Orta seviye başarı
- **🥇 Altın**: İleri seviye başarı
- 💎 **Elmas**: En üst düzey başarı

---

## 💡 İpuçları ve Stratejiler

### Masa Oyunu İpuçları

1. **Bonus Kareleri Hedefleyin**: Bonus kareler zaman avantajı sağlar
2. **Ceza Karelerinden Kaçının**: Özellikle 3. turdan sonra
3. **Hızlı Quiz Cevapları**: Süre puanınızı etkiler
4. **Koruma Dönemini Kullanın**: İlk 2 turda ceza kareleri güvenli

### Düello Stratejileri

1. **Hız ve Doğruluk Dengesi**: Acele etmeyin ama düşünmeyi de bırakmayın
2. **Hız Bonusunu Hesaplayın**: 
   - 10 saniye = 5 bonus puan
   - 5 saniye = 10 bonus puan
3. **Rakibi Okuyun**: Rakip zorlanıyorsa sakin kalın
4. **İlk 3 Soru Kritik**: Erken liderlik psikolojik avantaj sağlar

### Genel Stratejiler

- 🎯 **Düzenli Pratik**: Quiz sorularını çözerek hızlanın
- 📚 **Konuları Öğrenin**: Çevre bilginizi artırın
- ⏰ **Zamanı Yönetin**: Her soru için ortalama süre belirleyin
- 🎮 **Çok Oyunculu Oynayın**: Hem eğlenin hem de öğrenin

---

## ❓ SSS (Sıkça Sorulan Sorular)

### Masa Oyunu

**S: Ceza karesine girdim, ne olur?**
C: İlk 2 turde koruma var. Sonra +5 saniye ceza ve -5 puan uygulanır.

**S: Zar atışım 0 gelirse ne olur?**
C: Tur atlanır ve ceza sayacı düşer.

**S: Quiz sorularını seçebilir miyim?**
C: Hayır, sorular rastgele seçilir.

### Düello

**S: Süre dolduğunda ne olur?**
C: O soru için puan alamazsınız.

**S: Beraberlik olursa?**
C: Toplam puanlara bakılır, o da eşitse beraberlik ilan edilir.

**S: Odadan çıkarsam ne olur?**
C: Oyun sona erer ve diskalifiye olursunuz.

### Teknik

**S: İnternet gerekli mi?**
C: Evet, çok oyunculu mod için internet gereklidir.

**S: Offline oynayabilir miyim?**
C: Tek oyunculu mod offline çalışır.

---

## 📞 Destek

Sorularınız için:
- 📧 Email: destek@ecogame.app
- 💬 Discord: discord.gg/ecogame
- 🌐 Website: www.ecogame.app

---

**İyi eğlenceler! 🌿🎮**

*Eco Game - Çevre Bilinciyle Oyna!*

