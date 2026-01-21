# Event-Driven Günlük Görevler Implementasyonu

## Genel Bakış

Bu implementasyon, günlük görevlerin **event-driven** (olay tabanlı) bir mimari ile çalışmasını sağlar. Artık görev ilerlemesi otomatik olarak artacak ve kullanıcı quiz tamamladığında veya oyun oynadığında ilgili görevler otomatik güncellenecek.

## Yeni Dosyalar

### `lib/services/daily_task_event_service.dart`

Bu servis, günlük görevlerin event-driven şekilde çalışmasını sağlar:

#### Ana Özellikler:

1. **Event Dinleyicileri (Listeners)**
   - `onQuizCompleted()` - Quiz tamamlandığında tetiklenir
   - `onGamePlayed()` - Oyun oynandığında tetiklenir
   - `onDuelCompleted()` - Düello tamamlandığında tetiklenir
   - `onMultiplayerCompleted()` - Multiplayer oyun tamamlandığında tetiklenir

2. **Event Tipleri (DailyTaskEventType)**
   - `quizCompleted` - Quiz tamamlama eventi
   - `gamePlayed` - Oyun oynama eventi
   - `duelCompleted` - Düello tamamlama eventi
   - `multiplayerCompleted` - Multiplayer tamamlama eventi
   - `challengeUpdated` - Görev güncelleme eventi
   - `allChallengesUpdated` - Tüm görevler güncellendi eventi

3. **Stream API**
   - `eventStream` - Tüm event'leri dinler
   - `updateResultsStream` - Güncelleme sonuçlarını dinler
   - `statisticsStream` - İstatistik güncellemelerini dinler

4. **Challenge Update Sistemi**
   - Quiz görevleri için: Quiz tamamlandığında `ChallengeType.quiz` görevleri güncellenir
   - Düello görevleri için: Düello kazanıldığında `ChallengeType.duel` görevleri güncellenir
   - Multiplayer görevleri için: Multiplayer kazanıldığında `ChallengeType.multiplayer` görevleri güncellenir
   - Sadece kazanılan oyunlar sayılır (kaybedilenler sayılmaz)

5. **Real-time Updates**
   - Batch processing ile performans optimizasyonu
   - 500ms batch window ile UI güncellemeleri
   - Otomatik Firestore senkronizasyonu

## Entegrasyon

### `lib/services/game_completion_service.dart` Değişiklikleri

GameCompletionService artık DailyTaskEventService ile entegre çalışır:

```dart
// Quiz completion sonrası görev ilerlemesini güncelle
await _dailyTaskService.onQuizCompleted(
  category: category,
  score: score,
  correctAnswers: correctAnswers,
  difficulty: difficulty,
);

// Game completion sonrası görev ilerlemesini güncelle
await _dailyTaskService.onGamePlayed(
  gameType: gameType,
  finalScore: finalScore,
  isWinner: isWinner,
  position: position,
);
```

## Kullanım Örnekleri

### Quiz Sayfasında Kullanım

```dart
// Quiz tamamlandığında
await GameCompletionService().sendQuizCompletion(
  score: score,
  totalQuestions: totalQuestions,
  correctAnswers: correctAnswers,
  timeSpentSeconds: timeSpentSeconds,
  category: category,
  difficulty: difficulty,
  answers: answers,
  correctAnswersList: correctAnswersList,
);
// Bu otomatik olarak:
// 1. Quiz completion eventi gönderir
// 2. State refresh tetikler
// 3. Quiz görevlerinin ilerlemesini artırır
```

### Oyun Sayfasında Kullanım

```dart
// Oyun tamamlandığında
await GameCompletionService().sendGameCompletion(
  gameType: 'duel',
  finalScore: finalScore,
  quizScore: quizScore,
  timeElapsedSeconds: timeElapsedSeconds,
  position: position,
  isWinner: isWinner,
  playerResults: playerResults,
);
// Bu otomatik olarak:
// 1. Game completion eventi gönderir
// 2. Düello/Multiplayer görevlerinin ilerlemesini artırır (sadece kazanılanlar)
```

## Görev Tipleri ve Event Eşleştirmesi

| Challenge Type | Event Type | Koşul |
|----------------|------------|-------|
| `ChallengeType.quiz` | `DailyTaskEventType.quizCompleted` | Her quiz tamamlandığında |
| `ChallengeType.duel` | `DailyTaskEventType.duelCompleted` | Sadece düello kazanıldığında |
| `ChallengeType.multiplayer` | `DailyTaskEventType.multiplayerCompleted` | Sadece multiplayer kazanıldığında |

## Veritabanı Yapısı

### Günlük Görevler (`users/{uid}/daily_challenges`)
```json
{
  "id": "challenge_id",
  "title": "Günlük Quiz",
  "description": "Bugün 3 quiz tamamla",
  "type": 0,  // ChallengeType.quiz
  "targetValue": 3,
  "currentValue": 1,
  "rewardPoints": 25,
  "rewardType": 0,  // RewardType.points
  "date": 1699872000000,
  "expiresAt": 1699958400000,
  "isCompleted": false,
  "difficulty": 0,  // ChallengeDifficulty.easy
  "icon": "🧠"
}
```

### Haftalık Görevler (`users/{uid}/weekly_challenges`)
```json
{
  "id": "weekly_challenge_id",
  "title": "Haftalık Quiz Uzmanı",
  "description": "Bu hafta 20 soru yanıtla",
  "type": 0,
  "targetValue": 20,
  "currentValue": 5,
  "rewardPoints": 500,
  "rewardType": 0,
  "weekStart": 1699526400000,
  "weekEnd": 1700131200000,
  "isCompleted": false,
  "difficulty": 1,
  "icon": "🎯"
}
```

## İstatistik API

```dart
// Mevcut görev istatistiklerini al
final stats = await DailyTaskEventService().getChallengeStatistics();
// Çıktı:
// {
//   'daily': {
//     'total': 3,
//     'completed': 1,
//     'progress': 5,
//     'target': 8,
//     'completionRate': '33.3',
//   },
//   'weekly': {
//     'total': 2,
//     'completed': 0,
//     'progress': 5,
//     'target': 25,
//     'completionRate': '0.0',
//   },
//   'lastUpdated': 1699872000000,
// }

// Tüm görevleri yenile (örn. login sonrası)
await DailyTaskEventService().refreshAllChallenges();
```

## UI Entegrasyonu

Stream API kullanarak UI'yi real-time güncelleyebilirsiniz:

```dart
// Widget'ınızda
StreamBuilder<List<ChallengeUpdateResult>>(
  stream: DailyTaskEventService().updateResultsStream,
  builder: (context, snapshot) {
    if (snapshot.hasData) {
      final updates = snapshot.data!;
      // Güncellenen görevleri göster
      return ChallengeProgressWidget(updates: updates);
    }
    return Container();
  },
)
```

## Debugging

Debug modda yapılan işlemler konsola yazdırılır:

```
✅ DailyTaskEventService initialized
📝 Quiz completed: category=Enerji, score=12/15, updated 1 challenges
✅ Updated challenge "Günlük Quiz": 0 → 1/3
🎮 Game played: type=duel, winner=true, updated 1 challenges
✅ Updated challenge "Düello Mücadelesi": 0 → 1/2
🎉 Challenge completion logged: Düello Mücadelesi
```

## Özet

Bu implementasyon ile:
- ✅ Görev ilerlemesi otomatik artar
- ✅ Quiz ve oyun event'leri dinlenir
- ✅ Real-time UI güncellemeleri
- ✅ Batch processing ile performans
- ✅ Weekly ve daily challenge desteği
- ✅ Debug ve logging desteği

