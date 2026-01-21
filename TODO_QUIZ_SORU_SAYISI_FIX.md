# Quiz Soru Sayısı Senkronizasyonu Düzeltme Planı

## Görevler

### 1. lib/services/quiz_logic.dart
- [ ] `_selectRandomQuestionsByDifficulty()` metodunda questionCount parametresinin tüm dallarda kullanıldığını doğrula
- [ ] `startNewQuiz()` metodunda questionCount parametresinin doğru geçtiğini doğrula
- [ ] questions listesinin tam olarak count kadar soru içerdiğini garanti altına al

### 2. lib/services/enhanced_quiz_logic_service.dart
- [ ] `startNewQuiz()` metoduna questionCount parametresi ekle
- [ ] `_getQuestionCountForDifficulty()` metodunu kaldır, kullanıcının seçtiği sayıyı kullan
- [ ] `_generateQuestions()` metodunda questionCount parametresini kullan

### 3. lib/data/questions_database.dart
- [ ] `getMixedDifficultyQuestions()` metodunda yuvarlama hatasını düzelt
- [ ] Tam sayıda soru döndürdüğünden emin ol

### 4. lib/provides/quiz_bloc.dart
- [ ] `LoadQuiz` event'inde questionCount parametresinin doğru kullanıldığını doğrula
- [ ] `_onLoadQuiz()` metodunda questionCount'ı quizLogic'e doğru geçir

### 5. lib/pages/quiz_settings_page.dart
- [ ] `onStartQuiz` callback'inde questionCount parametresinin doğru geçtiğini doğrula

### 6. lib/pages/quiz_page.dart
- [ ] `didChangeDependencies()` ve `_showCategorySelection()` metodlarında questionCount'ın doğru geçtiğini doğrula

## Test Edilecek Senaryolar
- 5 soru seçildiğinde quiz 5 soru içermeli
- 10 soru seçildiğinde quiz 10 soru içermeli
- 15 soru seçildiğinde quiz 15 soru içermeli
- 20 soru seçildiğinde quiz 20 soru içermeli
- 25 soru seçildiğinde quiz 25 soru içermeli

## Backend-Frontend Senkronizasyonu
Frontend'de seçilen soru sayısı ile backend'de oluşturulan soru sayısı eşleşmeli.

