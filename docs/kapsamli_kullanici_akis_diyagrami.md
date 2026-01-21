# Karbonson Uygulaması - Kapsamlı Kullanıcı Akış Diyagramı

Bu doküman, uygulamanın tüm sayfalarını ve kullanıcı geçişlerini kapsayan kapsamlı bir kullanıcı akış diyagramıdır. Tüm prompt'lara göre tasarlanmıştır.

```mermaid
flowchart TB
    %% ========================================
    %% ANA BAŞLANGIÇ & TOKEN KONTROLÜ
    %% ========================================
    subgraph SPLASH_AUTH["🔐 Kimlik Doğrulama Akışı"]
        START([Uygulama Başlatılır]) --> SPLASH[Splash Screen]
        SPLASH --> TOKEN_CHECK{Token Kontrolü}
        TOKEN_CHECK -->|Token Geçerli| HOME_ROUTE[Home/Dashboard]
        TOKEN_CHECK -->|Token Geçersiz| LOGIN[Login Ekranı]
        
        LOGIN -->|Başarılı Giriş| HOME_ROUTE
        LOGIN -->|Hata| LOGIN_ERROR[❌ Hata Mesajı]
        LOGIN -->|Şifremi Unuttum| FORGOT_PASS[Şifre Sıfırlama]
        FORGOT_PASS --> LOGIN
        
        REGISTER[Register Ekranı] -->|Kayıt Başarılı| EMAIL_VERIFY[E-posta Doğrulama]
        REGISTER -->|Eksik Bilgi| REGISTER_WARN[⚠️ Uyarı Mesajı]
        EMAIL_VERIFY --> HOME_ROUTE
        
        LOGOUT[Çıkış Yap] --> TOKEN_DELETE[Token Sil]
        TOKEN_DELETE --> LOGIN
    end

    %% ========================================
    %% HOME / DASHBOARD - MERKEZİ NOKTA
    %% ========================================
    subgraph HOME["🏠 Home/Dashboard - Merkezi Navigasyon"]
        direction TB
        HOME_ROUTE --> WELCOME[Hoş Geldin Bölümü]
        WELCOME --> QUICK_ACCESS[Hızlı Erişim]
        
        QUICK_ACCESS --> QUIZ_BTN[Quiz Başlat]
        QUICK_ACCESS --> DUEL_BTN[Düello]
        QUICK_ACCESS --> MULTI_BTN[Çok Oyunculu]
        QUICK_ACCESS --> DAILY_BTN[Günlük Görevler]
        QUICK_ACCESS --> REWARDS_BTN[Ödüller]
        QUICK_ACCESS --> LEADERBOARD_BTN[Liderlik]
        QUICK_ACCESS --> FRIENDS_BTN[Arkadaşlar]
        QUICK_ACCESS --> NOTIF_BTN[Bildirimler]
        QUICK_ACCESS --> AI_BTN[AI Öneri]
        QUICK_ACCESS --> PROFILE_BTN[Profil]
        QUICK_ACCESS --> SETTINGS_BTN[Ayarlar]
    end

    %% ========================================
    %% QUIZ AKIŞI
    %% ========================================
    subgraph QUIZ_FLOW["📝 Quiz Modülü"]
        QUIZ_BTN --> QUIZ_SETTINGS[Quiz Ayar Ekranı]
        
        QUIZ_SETTINGS --> CAT_SELECT[Kategori Seçimi]
        CAT_SELECT --> DIFF_SELECT[Zorluk Seçimi]
        DIFF_SELECT --> QCOUNT_SELECT[Soru Sayısı]
        QCOUNT_SELECT --> START_QUIZ[Quiz Başlat]
        
        START_QUIZ --> LOADING_QUIZ[Yükleniyor...]
        LOADING_QUIZ --> QUIZ_GAME[Quiz Oyun Ekranı]
        
        QUIZ_GAME --> QUESTION[Soru Gösterimi]
        QUESTION --> ANSWER[Cevap Seçimi]
        ANSWER --> FEEDBACK[✅/❌ Geri Bildirim]
        FEEDBACK --> NEXT_QUESTION[Sonraki Soru]
        
        loop Tüm Sorular İçin
            NEXT_QUESTION --> QUESTION
        end
        
        NEXT_QUESTION -->|Tüm Sorular Bitti| QUIZ_COMPLETE[Quiz Tamamlandı]
        QUIZ_COMPLETE --> QUIZ_RESULTS[Sonuç Ekranı]
        QUIZ_RESULTS --> SCORE[Puan Gösterimi]
        SCORE --> DAILY_UPDATE[Günlük Görev Güncelleme]
        DAILY_UPDATE --> REWARD_BOX[Ödül Kutusu Kazanma]
        REWARD_BOX --> HOME_ROUTE
    end

    %% ========================================
    %% DÜELLO (4 KİŞİLİK) AKIŞI
    %% ========================================
    subgraph DUEL_FLOW["⚔️ Düello Modülü (4 Kişilik)"]
        DUEL_BTN --> DUEL_MAIN[Düello Ana Ekran]
        
        DUEL_MAIN --> DUEL_CREATE[Oda Oluştur]
        DUEL_CREATE --> DUEL_HOST_WAIT[Bekleme Ekranı - Host]
        
        DUEL_MAIN --> DUEL_JOIN[Odaya Katıl]
        DUEL_JOIN --> ENTER_CODE[Oda Kodu Gir]
        ENTER_CODE --> JOIN_CHECK{Katılım Kontrolü}
        JOIN_CHECK -->|Başarılı| DUEL_PLAYER_WAIT[Bekleme Ekranı - Oyuncu]
        JOIN_CHECK -->|Hata| DUEL_ERROR[❌ Hata: Oda Bulunamadı/Dolu]
        
        DUEL_HOST_WAIT -->|Oyuncu Katıldı| PLAYER_JOINED[Oyuncu Katıldı Bildirimi]
        PLAYER_JOINED --> START_DUEL[Oyun Başlat]
        
        DUEL_PLAYER_WAIT -->|Host Başlattı| START_DUEL
        
        START_DUEL --> DUEL_GAME[Düello Oyun Ekranı]
        DUEL_GAME --> DQ_QUESTION[Düello Sorusu]
        DQ_QUESTION --> DQ_ANSWER[Hızlı Cevap]
        DQ_ANSWER --> DQ_FEEDBACK[Skor Tablosu Güncellemesi]
        
        loop 5 Soru
            DQ_FEEDBACK --> DQ_QUESTION
        end
        
        DQ_FEEDBACK -->|Oyun Bitti| DUEL_RESULTS[Düello Sonuçları]
        DUEL_RESULTS --> DUEL_WINNER[Kazanan Belirleme]
        DUEL_WINNER --> DUEL_REWARD[Ödül / Başarım]
        DUEL_REWARD --> HOME_ROUTE
    end

    %% ========================================
    %% ÇOK OYUNCULU (2 KİŞİLİK) AKIŞI
    %% ========================================
    subgraph MULTI_FLOW["👥 Çok Oyunculu Modülü (2 Kişilik)"]
        MULTI_BTN --> MULTI_MAIN[Çok Oyunculu Ana Ekran]
        
        MULTI_MAIN --> MULTI_CREATE[Oda Oluştur]
        MULTI_CREATE --> MULTI_HOST_WAIT[Bekleme Ekranı]
        
        MULTI_MAIN --> MULTI_JOIN[Koda Katıl]
        MULTI_JOIN --> MULTI_CODE[Oda Kodu Gir]
        MULTI_CODE --> MULTI_CHECK{Katılım Kontrolü}
        MULTI_CHECK -->|Başarılı| MULTI_GAME[Çok Oyunculu Oyun]
        MULTI_CHECK -->|Hata| MULTI_ERROR[❌ Hata]
        
        MULTI_HOST_WAIT -->|Oyuncu Katıldı| MULTI_GAME
        
        MULTI_GAME --> MQ_QUESTION[Soru Gösterimi]
        MQ_QUESTION --> MQ_ANSWER[Oyuncular Cevaplar]
        MQ_ANSWER --> MQ_ROUND[Raunt Sonucu]
        
        loop Belirli Rauntlar
            MQ_ROUND --> MQ_QUESTION
        end
        
        MQ_ROUND -->|Oyun Bitti| MULTI_RESULTS[Sonuçlar]
        MULTI_RESULTS --> MULTI_SCORE[Puan Hesaplama]
        MULTI_SCORE --> MULTI_REWARD[Ödül]
        MULTI_REWARD --> HOME_ROUTE
    end

    %% ========================================
    %% GÜNLÜK GÖREVLER
    %% ========================================
    subgraph DAILY_FLOW["📋 Günlük Görevler"]
        DAILY_BTN --> DAILY_LIST[Görev Listesi]
        DAILY_LIST --> TASK_DETAIL[Görev Detayı]
        
        TASK_DETAIL --> TASK_PROGRESS[İlerleme Gösterimi]
        TASK_PROGRESS --> CLAIM_REWARD[Ödül Talep Et]
        CLAIM_REWARD --> SUCCESS_REWARD[✅ Ödül Kazanıldı]
        SUCCESS_REWARD --> HOME_ROUTE
        
        DAILY_LIST -->|Görev Tamamlandı| TASK_COMPLETE[Otomatik Ödül]
    end

    %% ========================================
    %% ÖDÜLLER & LOOT BOX
    %% ========================================
    subgraph REWARD_FLOW["🎁 Ödüller & Loot Box"]
        REWARDS_BTN --> REWARDS_MAIN[Ödüller Ana Ekran]
        
        REWARDS_MAIN --> REWARD_STORE[Ödül Mağazası]
        REWARDS_MAIN --> OWNED_REWARDS[Sahip Olunan Ödüller]
        REWARDS_MAIN --> WON_BOXES[Kazanılan Kutular]
        
        WON_BOXES --> OPEN_BOX[Kutu Aç]
        OPEN_BOX --> BOX_ANIM[Animasyon]
        BOX_ANIM --> REVEAL_REWARD[Ödül Gösterimi]
        REVEAL_REWARD --> INVENTORY[Envanter/Gallery]
        INVENTORY --> HOME_ROUTE
        
        REWARD_STORE --> BUY_REWARD[Ödül Satın Al]
        BUY_REWARD -->|Yeterli Puan| PURCHASE_SUCCESS[✅ Satın Alma Başarılı]
        BUY_REWARD -->|Yetersiz Puan| PURCHASE_ERROR[❌ Yetersiz Puan]
    end

    %% ========================================
    %% BAŞARIMLAR
    %% ========================================
    subgraph ACHIEVEMENT_FLOW["🏆 Başarımlar"]
        ACHIEVEMENTS_BTN[Başarımlar] --> ACH_LIST[Başarım Listesi]
        ACH_LIST --> ACH_DETAIL[Başarım Detayı]
        ACH_DETAIL --> ACH_PROGRESS[İlerleme Görüntüleme]
        ACH_PROGRESS --> ACH_UNLOCKED[Kilit Açıldı]
        ACH_UNLOCKED --> HOME_ROUTE
    end

    %% ========================================
    %% LİDERLİK TABLOSU
    %% ========================================
    subgraph LEADERBOARD_FLOW["📊 Liderlik Tablosu"]
        LEADERBOARD_BTN --> LEADERBOARD[Liderlik Ekranı]
        
        LEADERBOARD --> MY_RANK[Kendi Sıram]
        MY_RANK --> GLOBAL_RANK[Global Sıralama]
        GLOBAL_RANK --> FILTER_BY[Filtreleme Seçenekleri]
        FILTER_BY --> HOME_ROUTE
    end

    %% ========================================
    %% ARKADAŞLAR & QR
    %% ========================================
    subgraph FRIENDS_FLOW["👫 Arkadaşlar & QR Kod"]
        FRIENDS_BTN --> FRIENDS_MAIN[Arkadaşlar Ekranı]
        
        FRIENDS_MAIN --> FRIEND_LIST[Arkadaş Listesi]
        FRIENDS_MAIN --> SCAN_QR[QR Okut]
        FRIENDS_MAIN --> MY_QR[QR Kodum]
        
        MY_QR --> SHARE_QR[Paylaş]
        SHARE_QR --> WHATSAPP[WhatsApp]
        SHARE_QR --> GMAIL[Gmail]
        SHARE_QR --> SYSTEM_SHARE[Sistem Paylaşımı]
        
        SCAN_QR --> QR_RESULT{QR Sonucu}
        QR_RESULT -->|Geçerli Kullanıcı| ADD_FRIEND_REQUEST[Arkadaşlık İsteği]
        QR_RESULT -->|Geçersiz| QR_ERROR[❌ Hata]
        
        ADD_FRIEND_REQUEST --> REQUEST_SENT[İstek Gönderildi]
        REQUEST_SENT --> HOME_ROUTE
        
        FRIEND_LIST --> FRIEND_ACTIONS[Arkadaş İşlemleri]
        FRIEND_ACTIONS --> INVITE_DUEL[Düello Daveti]
        FRIEND_ACTIONS --> VIEW_PROFILE[Profili Görüntüle]
    end

    %% ========================================
    %% BİLDİRİMLER
    %% ========================================
    subgraph NOTIF_FLOW["🔔 Bildirimler"]
        NOTIF_BTN --> NOTIF_LIST[Bildirim Listesi]
        NOTIF_LIST --> NOTIF_DETAIL[Bildirim Detayı]
        NOTIF_DETAIL --> RELATED_PAGE[İlgili Sayfaya Yönlendirme]
        
        RELATED_PAGE -->|Düello Daveti| DUEL_ACCEPT[Düello Kabul Et]
        RELATED_PAGE -->|Arkadaşlık İsteği| FRIEND_ACCEPT[İsteği Kabul Et]
        RELATED_PAGE -->|Görev Tamamlandı| TASK_REWARD[Görev Ödülü]
        
        DUEL_ACCEPT --> DUEL_MAIN
        FRIEND_ACCEPT --> FRIENDS_MAIN
        TASK_REWARD --> HOME_ROUTE
    end

    %% ========================================
    %% AI ÖNERİLERİ
    %% ========================================
    subgraph AI_FLOW["🤖 AI Önerileri"]
        AI_BTN --> AI_PAGE[AI Recommendation Ekranı]
        
        AI_PAGE --> AI_LOADING[Yükleniyor...]
        AI_LOADING -->|Veri Geldi| AI_DATA[Öneri Verileri]
        AI_LOADING -->|Veri Yok| EMPTY_STATE[Boş Durum]
        AI_LOADING -->|Hata| AI_ERROR[Hata Mesajı]
        
        AI_DATA --> RECOMMENDATIONS[Kişiselleştirilmiş Öneriler]
        RECOMMENDATIONS --> HOME_ROUTE
        
        EMPTY_STATE --> HOME_ROUTE
        AI_ERROR -->|Yeniden Dene| AI_PAGE
    end

    %% ========================================
    %% PROFİL & AYARLAR
    %% ========================================
    subgraph PROFILE_FLOW["👤 Profil & Ayarlar"]
        PROFILE_BTN --> PROFILE[Profil Ekranı]
        
        PROFILE --> USER_INFO[Kullanıcı Bilgileri]
        USER_INFO --> EDIT_PROFILE[Düzenleme]
        EDIT_PROFILE --> SAVE_PROFILE[Kaydet]
        SAVE_PROFILE --> PROFILE_UPDATE[✅ Profil Güncellendi]
        PROFILE_UPDATE --> HOME_ROUTE
        
        SETTINGS_BTN --> SETTINGS[Ayarlar Ekranı]
        SETTINGS --> NOTIF_SETTINGS[Bildirim Ayarları]
        SETTINGS --> THEME_SETTINGS[Tema Seçimi]
        SETTINGS --> LANGUAGE_SETTINGS[Dil Seçimi]
        SETTINGS --> LOGOUT_BTN[Çıkış Yap]
        LOGOUT_BTN --> LOGOUT
    end

    %% ========================================
    %% HATA & BOŞ DURUMLAR
    %% ========================================
    subgraph ERROR_FLOW["⚠️ Hata & Boş Durumlar"]
        ERROR_STATE[Hata Durumu] --> ERROR_MSG[Hata Mesajı Göster]
        ERROR_MSG --> RETRY[Yeniden Dene]
        RETRY --> HOME_ROUTE
        
        EMPTY_STATE[Boş Durum] --> EMPTY_MSG[Boş İçerik Mesajı]
        EMPTY_MSG --> HOME_ROUTE
        
        OFFLINE[İnternet Yok] --> OFFLINE_MSG[Offline Uyarısı]
        OFFLINE_MSG --> AUTO_REFRESH[Bağlantı Gelince Otomatik Yenile]
        AUTO_REFRESH --> HOME_ROUTE
    end

    %% ========================================
    %% GERİ NAVİGASYON KURALLARI
    %% ========================================
    subgraph BACK_NAV["🔙 Geri Navigasyon"]
        BACK_PRESS{Geri Tuşuna Basıldı}
        
        BACK_PRESS -->|Ana Ekranlar| PREV_PAGE[Önceki Sayfa]
        BACK_PRESS -->|Oyun Sırasında| CONFIRM_EXIT{Çıkış Onayı}
        
        CONFIRM_EXIT -->|Hayır| GAME_CONTINUE[Oyun Devam]
        CONFIRM_EXIT -->|Evet| QUIT_CONFIRM[Oyunu Kapat]
        QUIT_CONFIRM --> HOME_ROUTE
        
        PREV_PAGE --> HOME_ROUTE
    end

    %% ========================================
    %% STILL DÜĞMELERİ & HIZLI MENÜ
    %% ========================================
    subgraph QUICK_MENU["⚡ Hızlı Menü"]
        FAB[+ FAB Butonu] --> QUICK_MENU_POPUP[Hızlı Menü Popup]
        QUICK_MENU_POPUP --> QM_QUIZ[Quiz]
        QUICK_MENU_POPUP --> QM_DUEL[Düello]
        QM_DUEL --> QUICK_DUEL[⚡ Hızlı Düello]
        QM_DUEL --> ROOM_DUEL[🏠 Oda Düellosu]
        QUICK_MENU_POPUP --> QM_FRIENDS[Arkadaşlar]
        QM_QUICK_MENU_POPUP --> QM_LEADERBOARD[Liderlik]
        QM_QUICK_MENU_POPUP --> QM_ACHIEVEMENTS[Başarımlar]
        QM_QUICK_MENU_POPUP --> QM_REWARDS[Ödüller]
    end

    %% ========================================
    %% YARDIM & NASIL OYNANIR
    %% ========================================
    subgraph HELP_FLOW["❓ Yardım"]
        HELP[?] --> HELP_DIALOG[Yardım Dialog]
        HELP_DIALOG --> HOW_TO_PLAY[Nasıl Oynanır]
        HOW_TO_PLAY --> TUTORIAL[Tutorial Ekranı]
        TUTORIAL --> HOME_ROUTE
    end

    %% ========================================
    %% BAĞLANTI & DURUM KONTROLÜ
    %% ========================================
    subgraph CONNECTIVITY["📡 Bağlantı Durumu"]
        CONN_CHECK[Bağlantı Kontrolü]
        CONN_CHECK -->|Çevrimiçi| ONLINE[Çevrimiçi]
        CONN_CHECK -->|Çevrimdışı| OFFLINE_IND[Offline Göstergesi]
        
        ONLINE --> CONTINUE[İşleme Devam]
        OFFLINE_IND --> RETRY_CONN[Yeniden Dene]
        RETRY_CONN --> CONN_CHECK
    end

    %% ========================================
    %% DEEP LINKING
    %% ========================================
    subgraph DEEP_LINKS["🔗 Deep Linking"]
        DEEP_LINK[Deep Link Alındı]
        DEEP_LINK --> DL_PARSE[Link Parse Et]
        DL_PARSE --> DL_ROUTE{Yönlendirme}
        
        DL_ROUTE -->|karbonson://duel/{id}| DL_DUEL[Düello Odası]
        DL_ROUTE -->|karbonson://profile/{id}| DL_PROFILE[Kullanıcı Profili]
        DL_ROUTE -->|karbonson://invite| DL_INVITE[Davet Ekranı]
        
        DL_DUEL --> DUEL_MAIN
        DL_PROFILE --> FRIENDS_MAIN
    end

    %% ========================================
    %% STİL & KURALLAR
    %% ========================================
    classDef start fill:#4CAF50,stroke:#2E7D32,stroke-width:2px,color:white
    classDef end fill:#f44336,stroke:#D32F2F,stroke-width:2px,color:white
    classDef decision fill:#FF9800,stroke:#F57C00,stroke-width:2px,color:white
    classDef page fill:#2196F3,stroke:#1976D2,stroke-width:2px,color:white
    classDef action fill:#9C27B0,stroke:#7B1FA2,stroke-width:2px,color:white
    classDef error fill:#f44336,stroke:#D32F2F,stroke-width:2px,color:white,stroke-dasharray: 5 5
    classDef success fill:#4CAF50,stroke:#2E7D32,stroke-width:2px,color:white,stroke-dasharray: 5 5
    
    class START end
    class HOME_ROUTE page
    class LOGIN page
    class QUIZ_GAME page
    class DUEL_GAME page
    class MULTI_GAME page
    class ERROR_STATE error
    class TOKEN_CHECK decision
```

---

## 📋 Özet Tablo

| Bölüm | Ana Sayfalar | Geçişler |
|-------|-------------|----------|
| **Kimlik Doğrulama** | Splash → Login → Register → Forgot Password | Token kontrolü ile yönlendirme |
| **Home/Dashboard** | Merkezi hub | Tüm modüllere erişim |
| **Quiz** | Ayarlar → Oyun → Sonuçlar | Kategori, zorluk, soru sayısı seçimi |
| **Düello** | Ana ekran → Oda oluştur/katıl → Bekleme → Oyun | 4 kişilik tam oyun akışı |
| **Çok Oyunculu** | Lobby → Oda → Bekleme → Oyun | 2 kişilik eşleşme akışı |
| **Günlük Görevler** | Liste → Detay → Ödül | Otomatik güncelleme |
| **Ödüller** | Mağaza → Envanter → Loot Box | Kutu açma animasyonu |
| **Başarımlar** | Liste → Detay → Kilitleme açma | İlerleme takibi |
| **Liderlik** | Global → Arkadaşlar → Haftalık | Filtreleme seçenekleri |
| **Arkadaşlar** | Liste → QR okut → Profil | Sosyal özellikler |
| **Bildirimler** | Liste → Detay → Yönlendirme | Deep linking |
| **AI Öneri** | Loading → Veri/Boş/Hata | Durum yönetimi |
| **Profil/Ayarlar** | Bilgiler → Düzenleme → Kaydet | Tema/dil/çıkış |
| **Hata Yönetimi** | Retry → Refresh → Offline | Kullanıcı geri bildirimi |

---

## 🔄 Akış Özeti

1. **Başlangıç**: Splash → Token Kontrolü → Home/Login
2. **Home**: Merkezi navigasyon noktası, tüm modüllere hızlı erişim
3. **Quiz**: Ayarlar → Oyun → Sonuç → Ödül → Home
4. **Düello**: Oluştur/Katıl → Bekleme → Oyun → Sonuç → Home
5. **Çok Oyunculu**: Oda → Bekleme → Oyun → Sonuç → Home
6. **Görev/Ödül**: Görev → Ödül → Loot Box → Envanter
7. **Sosyal**: Arkadaşlar → QR → Liderlik → Başarımlar
8. **Hata**: Retry/Offline/Refresh durumları
9. **Geri Tuşu**: Oyun sırasında onay, diğerlerinde standart

