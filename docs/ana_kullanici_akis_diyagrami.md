# Ana Kullanıcı Akış Diyagramı

Bu diyagram, uygulamanın tüm sayfalarını ve geçişlerini kapsayan kapsamlı bir kullanıcı akış diyagramıdır. Prompt'lara göre tasarlanmıştır.

```mermaid
graph TD
    %% Başlangıç Akışı
    Splash[Splash Screen] --> TokenCheck[Token Kontrolü]
    TokenCheck -->|Token Geçerli| Home[Home/Dashboard]
    TokenCheck -->|Token Geçersiz| Login[Login Ekranı]

    %% Auth Akışı
    Login -->|Başarılı Giriş| Home
    Login -->|Hata| Login
    Login -->|Şifremi Unuttum| Reset[Şifre Sıfırlama]
    Reset --> Login

    Register[Kayıt Ekranı] -->|Kayıt Başarılı| Home
    Register -->|Eksik Bilgi| Register

    %% Home'dan Modlara Geçişler
    Home --> QuizSettings[Quiz Ayar Ekranı]
    Home --> DuelLobby[Düello Ana Ekranı]
    Home --> MultiplayerLobby[Çok Oyunculu Ana Ekranı]
    Home --> DailyTasks[Günlük Görevler]
    Home --> Rewards[Ödüller Ana Ekranı]
    Home --> Achievements[Başarımlar]
    Home --> Leaderboard[Liderlik Tablosu]
    Home --> Friends[Arkadaşlar]
    Home --> Notifications[Bildirimler]
    Home --> AIRecommendation[AI Öneri]
    Home --> Profile[Profil]
    Home --> Settings[Ayarlar]

    %% Quiz Akışı
    QuizSettings --> QuizGame[Quiz Oyun Ekranı]
    QuizGame --> QuizResults[Quiz Sonuç Ekranı]
    QuizResults --> Home
    QuizResults --> DailyTasksUpdate[Günlük Görev Güncelleme]

    %% Düello Akışı (4 Kişilik)
    DuelLobby --> DuelCreateRoom[Düello Oda Oluştur]
    DuelCreateRoom --> DuelWaiting[Bekleme Ekranı]
    DuelWaiting --> DuelGame[Düello Oyun]
    DuelGame --> DuelResults[Düello Sonuçları]
    DuelResults --> Home
    DuelResults --> RewardsUpdate[Ödül Güncelleme]

    DuelLobby --> DuelJoinRoom[Düello Odaya Katıl]
    DuelJoinRoom --> DuelWaiting

    %% Çok Oyunculu Akışı (2 Kişilik)
    MultiplayerLobby --> MultiCreateRoom[Çok Oyunculu Oda Oluştur]
    MultiCreateRoom --> MultiWaiting[Bekleme]
    MultiWaiting --> MultiGame[Çok Oyunculu Oyun]
    MultiGame --> MultiResults[Sonuçlar]
    MultiResults --> Home
    MultiResults --> RewardsUpdate

    MultiplayerLobby --> MultiJoinRoom[Odaya Katıl]
    MultiJoinRoom --> MultiWaiting

    %% Günlük Görevler
    DailyTasks --> TaskDetail[Görev Detayı]
    TaskDetail --> RewardClaim[Ödül Kazanma]
    RewardClaim --> Home

    %% Ödüller
    Rewards --> RewardStore[Ödül Mağazası]
    Rewards --> OwnedRewards[Sahip Olunan Ödüller]
    Rewards --> LootBoxes[Kazanılan Kutular]
    LootBoxes --> LootBoxOpen[Kutu Aç]
    LootBoxOpen --> LootBoxAnimation[Animasyon]
    LootBoxAnimation --> RewardReveal[Ödül Göster]
    RewardReveal --> Inventory[Envanter]

    %% Başarımlar
    Achievements --> AchievementList[Liste]
    AchievementList --> AchievementDetail[Detay]
    AchievementDetail --> ProgressView[İlerleme Gösterimi]

    %% Liderlik
    Leaderboard --> MyRank[Kendi Sıram]
    MyRank --> GlobalRanking[Global Sıralama]
    GlobalRanking --> Home

    %% Arkadaşlar
    Friends --> FriendList[Arkadaş Listesi]
    Friends --> QRScan[QR Okut]
    Friends --> MyQR[QR Kodum]
    MyQR --> QRShare[Paylaş]
    QRShare --> WhatsApp[WhatsApp]
    QRShare --> Gmail[Gmail]
    QRShare --> SystemShare[Sistem Paylaşımı]

    %% Bildirimler
    Notifications --> NotificationList[Liste]
    NotificationList --> NotificationDetail[Detay]
    NotificationDetail --> RelatedPage[İlgili Sayfa]

    %% AI Öneri
    AIRecommendation --> Loading[Yükleniyor]
    Loading --> Data[Veri]
    Loading --> EmptyState[Boş Durum]
    Loading --> Error[Hata]

    %% Profil
    Profile --> UserInfo[Kullanıcı Bilgileri]
    UserInfo --> Edit[Düzenleme]
    Edit --> Save[Kaydet]

    %% Ayarlar
    Settings --> NotificationSettings[Bildirim Ayarları]
    Settings --> Logout[Çıkış Yap]
    Logout --> Login

    %% Hata ve Boş Durumlar
    ErrorState[Hata Durumu] --> Home
    EmptyState --> Home
    Offline[Offline] --> Refresh[Yenile]
    Refresh --> Home

    %% Geri Navigasyon
    BackNavigation[Geri Tuşu] --> PreviousPage[Önceki Sayfa]
    BackNavigation -->|Oyun Sırasında| ConfirmExit[Çıkış Onayı]
    ConfirmExit -->|Hayır| Game[Oyun Devam]
    ConfirmExit -->|Evet| Home