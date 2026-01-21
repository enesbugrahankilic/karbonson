# Quiz & Oyun Tamamlama Backend Event Sistemi

## Görev: Quiz/Oyun bitince backend'e completion event gönder

### Yapılacaklar:
- [x] 1. Completion data model oluştur (`lib/models/completion_data.dart`)
- [x] 2. Game completion service oluştur (`lib/services/game_completion_service.dart`)
- [x] 3. QuizBloc güncelle - quiz completion event ekle (`lib/provides/quiz_bloc.dart`)
- [ ] 4. QuizPage güncelle - time tracking ekle (`lib/pages/quiz_page.dart`)
- [ ] 5. BoardGamePage güncelle - game completion event ekle (`lib/pages/board_game_page.dart`)
- [ ] 6. MultiplayerGameLogic güncelle - game completion event (`lib/services/multiplayer_game_logic.dart`)
- [ ] 7. GameLogic güncelle - single player completion (`lib/services/game_logic.dart`)

### Tamamlanan İşlemler:

#### 1. Completion Data Model ✅
- `QuizCompletionEvent` - Quiz sonuçları için
- `GameCompletionEvent` - Oyun sonuçları için  
- `CompletionEvent` - Tek tip wrapper

#### 2. Game Completion Service ✅
- `GameCompletionService` - Ana servis
- `QuizCompletionHelper` - Quiz helper
- `GameCompletionHelper` - Game helper
- Offline queue desteği
- Periodic sync
- Firestore entegrasyonu

#### 3. QuizBloc ✅
- Quiz tamamlandığında backend'e completion event gönderiliyor
- quiz_id, user_id, score, category, answers dahil

### Devam Eden İşlemler:

#### 5. BoardGamePage (Game Completion)
Oyun bittiğinde (tek/çoklu oyuncu) completion event gönderilecek:
- game_id, room_id, user_id
- final_score, quiz_score
- time_elapsed_seconds
- position, is_winner
- player_results (çoklu oyuncu için)

