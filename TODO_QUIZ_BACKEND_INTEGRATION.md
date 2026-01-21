# Quiz Backend Integration - TODO List

## Objective
Connect the quiz completion screen to backend success, showing "Quiz Tamamlandı" only when backend returns success.

## Changes

### 1. lib/provides/quiz_bloc.dart ✅ COMPLETED
- [x] Add `QuizCompletionInProgress` state for waiting backend response
- [x] Add `QuizCompletionError` state for backend failures
- [x] Modify `_onAnswerQuestion` to wait for backend before emitting completion
- [x] Add event for retrying failed backend calls (`RetryQuizCompletion`)
- [x] Add `_onRetryQuizCompletion` handler

### 2. lib/pages/quiz_page.dart ✅ COMPLETED
- [x] Remove automatic `_sendQuizCompletionEvent` call (now handled by Bloc)
- [x] Add loading UI for `QuizCompletionInProgress` state
- [x] Add error dialog for `QuizCompletionError` state with retry option
- [x] Update the build method to handle new states
- [x] Add `kDebugMode` import

## Flow
1. User answers last question → Bloc sends completion to backend
2. Emit `QuizCompletionInProgress` → Show loading spinner with "Kaydediliyor..."
3. If backend success → Emit `QuizCompleted` → Show success screen ("Quiz Tamamlandı!")
4. If backend error → Emit `QuizCompletionError` → Show error dialog with retry option

## Testing
- [ ] Test backend success flow
- [ ] Test backend failure flow
- [ ] Test retry functionality

## Key Features
- Backend success/failure is now checked before showing completion screen
- Users see a loading state while backend processes the completion
- Users can retry if backend fails
- Error messages are shown in Turkish


