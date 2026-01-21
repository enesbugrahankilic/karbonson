# Diyagram Gereksinimleri Analizi

## Diyagram Genel Bakış
Ana kullanıcı akış diyagramı, uygulamanın tüm sayfalarını ve geçişlerini kapsayan kapsamlı bir yapı tanımlar. Prompt'lara göre tasarlanmış, modern bir oyun uygulaması akışı.

## Diyagramdaki Tüm Sayfalar ve Akışlar

### Başlangıç Akışı
- **Splash Screen** - Uygulama başlangıç ekranı
- **Token Kontrolü** - Otomatik giriş kontrolü (mantık, sayfa değil)
- **Home/Dashboard** - Ana kontrol merkezi

### Kimlik Doğrulama Akışı
- **Login Ekranı** - Kullanıcı girişi
- **Şifre Sıfırlama** - Parola kurtarma
- **Kayıt Ekranı** - Yeni kullanıcı kaydı

### Ana Modüller (Home'dan Geçişler)
- **Quiz Ayar Ekranı** - Quiz konfigürasyonu
- **Düello Ana Ekranı** - Düello modu girişi
- **Çok Oyunculu Ana Ekranı** - Multiplayer modu girişi
- **Günlük Görevler** - Daily tasks/quests
- **Ödüller Ana Ekranı** - Rewards merkezi
- **Başarımlar** - Achievements sistemi
- **Liderlik Tablosu** - Leaderboard
- **Arkadaşlar** - Friends yönetimi
- **Bildirimler** - Notifications merkezi
- **AI Öneri** - AI recommendations
- **Profil** - User profile
- **Ayarlar** - Application settings

### Quiz Akışı
- **Quiz Oyun Ekranı** - Quiz gameplay
- **Quiz Sonuç Ekranı** - Quiz results/score screen

### Düello Akışı (4 Kişilik)
- **Düello Oda Oluştur** - Create duel room
- **Bekleme Ekranı** - Waiting lobby
- **Düello Oyun** - Duel gameplay
- **Düello Sonuçları** - Duel results

### Çok Oyunculu Akışı (2 Kişilik)
- **Çok Oyunculu Oda Oluştur** - Create multiplayer room
- **Bekleme** - Waiting lobby
- **Çok Oyunculu Oyun** - Multiplayer gameplay
- **Sonuçlar** - Match results

### Günlük Görevler Akışı
- **Görev Detayı** - Task details
- **Ödül Kazanma** - Reward claiming

### Ödüller Akışı
- **Ödül Mağazası** - Reward shop
- **Sahip Olunan Ödüller** - Owned rewards
- **Kazanılan Kutular** - Won boxes/loot boxes
- **Kutu Aç** - Box opening
- **Animasyon** - Opening animation
- **Ödül Göster** - Reward reveal
- **Envanter** - Inventory

### Başarımlar Akışı
- **Liste** - Achievements list
- **Detay** - Achievement details
- **İlerleme Gösterimi** - Progress view

### Liderlik Akışı
- **Kendi Sıram** - My rank
- **Global Sıralama** - Global rankings

### Arkadaşlar Akışı
- **Arkadaş Listesi** - Friends list
- **QR Okut** - QR scan
- **QR Kodum** - My QR code
- **Paylaş** - Share options
  - WhatsApp
  - Gmail
  - Sistem Paylaşımı (System share)

### Bildirimler Akışı
- **Liste** - Notifications list
- **Detay** - Notification details
- **İlgili Sayfa** - Related page (deep linking)

### AI Öneri Akışı
- **Yükleniyor** - Loading state
- **Veri** - Data display
- **Boş Durum** - Empty state
- **Hata** - Error state

### Profil Akışı
- **Kullanıcı Bilgileri** - User info
- **Düzenleme** - Edit mode
- **Kaydet** - Save changes

### Ayarlar Akışı
- **Bildirim Ayarları** - Notification settings
- **Çıkış Yap** - Logout

### Hata ve Özel Durumlar
- **Hata Durumu** - Error states
- **Boş Durum** - Empty states
- **Offline** - Offline mode
- **Yenile** - Refresh action

### Navigasyon Kontrolleri
- **Geri Tuşu** - Back navigation
- **Önceki Sayfa** - Previous page
- **Çıkış Onayı** - Exit confirmation
- **Oyun Devam** - Continue game

## Akış Özellikleri
- **Koordineli Geçişler**: Tüm sayfalar arası geçişler tanımlanmış
- **Hata Yönetimi**: Her akış için hata durumları mevcut
- **Geri Navigasyon**: Tutarlı geri dönüş mekanizmaları
- **Durum Yönetimi**: Loading, error, empty states
- **Derin Bağlantılar**: Bildirimlerden ilgili sayfalara geçiş