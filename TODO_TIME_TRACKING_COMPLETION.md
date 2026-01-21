# Time Tracking & Game Completion Implementation

## Tasks
- [x] 4. QuizPage - Add time tracking + completion event (`lib/pages/quiz_page.dart`)
- [ ] 5. BoardGamePage - Add game completion event (`lib/pages/board_game_page.dart`)
- [ ] 6. MultiplayerGameLogic - Add time tracking + completion (`lib/services/multiplayer_game_logic.dart`)
- [ ] 7. GameLogic - Add single player completion (`lib/services/game_logic.dart`)

## Implementation Details

### QuizPage (COMPLETED)
- Added `_quizStartTime` to track when quiz starts
- Added `_timeSpentSeconds` to calculate duration
- Added `_difficultyDisplayName` for difficulty name
- Added `_completionEventSent` flag to prevent duplicate sends
- Import `QuizCompletionHelper` from `game_completion_service.dart`
- Set `_quizStartTime = DateTime.now()` when quiz loads
- Call `QuizCompletionHelper.completeQuiz()` in `QuizCompleted` state

### BoardGamePage (IN PROGRESS)
- Import `GameCompletionHelper` and `GameCompletionService`
- In `_showEndGameDialog()`:
  - Single player: Call `GameCompletionHelper.completeSinglePlayerGame()`
  - Multiplayer: Call `GameCompletionHelper.completeMultiplayerGame()`

### MultiplayerGameLogic & GameLogic
- Both already have `timeElapsedInSeconds` and `quizScore`
- Add `finalScore` getter for single player
- Integrate with completion service


