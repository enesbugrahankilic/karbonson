// lib/services/onboarding_service.dart

import 'dart:async';
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/material.dart';

class OnboardingService {
  static OnboardingService? _instance;
  static OnboardingService get instance => _instance ??= OnboardingService._();

  OnboardingService._();

  final StreamController<OnboardingStep> _stepController =
      StreamController<OnboardingStep>.broadcast();

  Stream<OnboardingStep> get stepStream => _stepController.stream;

  // Onboarding State
  OnboardingStep? _currentStep;
  Timer? _autoAdvanceTimer;

  // Step Management
  void startOnboarding() {
    _currentStep = OnboardingStep.welcome;
    _stepController.add(_currentStep!);
    _startAutoAdvanceTimer();
  }

  void nextStep() {
    if (_currentStep != null) {
      _currentStep = _getNextStep(_currentStep!);
      if (_currentStep != null) {
        _stepController.add(_currentStep!);
        _startAutoAdvanceTimer();
      } else {
        completeOnboarding();
      }
    }
  }

  void previousStep() {
    if (_currentStep != null) {
      _currentStep = _getPreviousStep(_currentStep!);
      if (_currentStep != null) {
        _stepController.add(_currentStep!);
        _startAutoAdvanceTimer();
      }
    }
  }

  OnboardingStep? _getNextStep(OnboardingStep currentStep) {
    switch (currentStep) {
      case OnboardingStep.welcome:
        return OnboardingStep.gameObjective;
      case OnboardingStep.gameObjective:
        return OnboardingStep.boardTiles;
      case OnboardingStep.boardTiles:
        return OnboardingStep.scoring;
      case OnboardingStep.scoring:
        return OnboardingStep.singlePlayer;
      case OnboardingStep.singlePlayer:
        return OnboardingStep.multiPlayer;
      case OnboardingStep.multiPlayer:
        return OnboardingStep.howToPlay;
      case OnboardingStep.howToPlay:
        return null; // End of onboarding
    }
  }

  OnboardingStep? _getPreviousStep(OnboardingStep currentStep) {
    switch (currentStep) {
      case OnboardingStep.welcome:
        return null; // First step
      case OnboardingStep.gameObjective:
        return OnboardingStep.welcome;
      case OnboardingStep.boardTiles:
        return OnboardingStep.gameObjective;
      case OnboardingStep.scoring:
        return OnboardingStep.boardTiles;
      case OnboardingStep.singlePlayer:
        return OnboardingStep.scoring;
      case OnboardingStep.multiPlayer:
        return OnboardingStep.singlePlayer;
      case OnboardingStep.howToPlay:
        return OnboardingStep.multiPlayer;
    }
  }

  void _startAutoAdvanceTimer() {
    _autoAdvanceTimer?.cancel();
    _autoAdvanceTimer = Timer(const Duration(seconds: 10), () {
      nextStep();
    });
  }

  void stopAutoAdvance() {
    _autoAdvanceTimer?.cancel();
  }

  void completeOnboarding() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('hasCompletedOnboarding', true);
    await prefs.setBool('hasSeenTutorial', true);

    stopAutoAdvance();
    _currentStep = null;

    debugPrint('Onboarding completed');
  }

  // State Persistence
  Future<bool> hasCompletedOnboarding() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool('hasCompletedOnboarding') ?? false;
  }

  Future<bool> hasSeenTutorial() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool('hasSeenTutorial') ?? false;
  }

  Future<void> resetOnboarding() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('hasCompletedOnboarding');
    await prefs.remove('hasSeenTutorial');
    await prefs.remove('onboardingPreferences');
  }

  // Interactive Tutorial
  Future<void> startInteractiveTutorial(String tutorialType) async {
    switch (tutorialType) {
      case 'dice_roll':
        await _startDiceRollTutorial();
        break;
      case 'quiz':
        await _startQuizTutorial();
        break;
      case 'multiplayer':
        await _startMultiplayerTutorial();
        break;
      case 'accessibility':
        await _startAccessibilityTutorial();
        break;
    }
  }

  Future<void> _startDiceRollTutorial() async {
    // Interactive tutorial for dice rolling
    // This would guide user through their first dice roll
    debugPrint('Starting dice roll tutorial');
  }

  Future<void> _startQuizTutorial() async {
    // Interactive tutorial for quiz answering
    // This would guide user through answering their first quiz question
    debugPrint('Starting quiz tutorial');
  }

  Future<void> _startMultiplayerTutorial() async {
    // Interactive tutorial for multiplayer features
    // This would guide user through creating/joining their first multiplayer game
    debugPrint('Starting multiplayer tutorial');
  }

  Future<void> _startAccessibilityTutorial() async {
    // Interactive tutorial for accessibility features
    // This would guide user through setting up accessibility features
    debugPrint('Starting accessibility tutorial');
  }

  // Progressive Disclosure
  Future<void> markFeatureAsSeen(String featureKey) async {
    final prefs = await SharedPreferences.getInstance();
    final seenFeatures = prefs.getStringList('seenFeatures') ?? [];
    if (!seenFeatures.contains(featureKey)) {
      seenFeatures.add(featureKey);
      await prefs.setStringList('seenFeatures', seenFeatures);
    }
  }

  Future<bool> shouldShowFeature(String featureKey) async {
    final prefs = await SharedPreferences.getInstance();
    final seenFeatures = prefs.getStringList('seenFeatures') ?? [];
    return !seenFeatures.contains(featureKey);
  }

  // Contextual Help
  Future<void> showContextualHelp(String contextKey, String message) async {
    // Store contextual help messages for display in relevant screens
    final prefs = await SharedPreferences.getInstance();
    final helpMessages = prefs.getString('helpMessages') ?? '{}';
    final helpMap = Map<String, dynamic>.from(json.decode(helpMessages));
    helpMap[contextKey] = message;
    await prefs.setString('helpMessages', json.encode(helpMap));
  }

  Future<String?> getContextualHelp(String contextKey) async {
    final prefs = await SharedPreferences.getInstance();
    final helpMessages = prefs.getString('helpMessages') ?? '{}';
    final helpMap = Map<String, dynamic>.from(json.decode(helpMessages));
    return helpMap[contextKey];
  }

  // User Preferences
  Future<void> saveOnboardingPreferences(
      Map<String, dynamic> preferences) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('onboardingPreferences', json.encode(preferences));
  }

  Future<Map<String, dynamic>> getOnboardingPreferences() async {
    final prefs = await SharedPreferences.getInstance();
    final preferencesString = prefs.getString('onboardingPreferences') ?? '{}';
    return json.decode(preferencesString);
  }

  void dispose() {
    _stepController.close();
    _autoAdvanceTimer?.cancel();
  }
}

// Onboarding Steps
enum OnboardingStep {
  welcome,
  gameObjective,
  boardTiles,
  scoring,
  singlePlayer,
  multiPlayer,
  howToPlay,
}

class OnboardingStepData {
  final OnboardingStep step;
  final String title;
  final String description;
  final String icon;
  final List<String> bulletPoints;
  final bool hasInteractiveElement;
  final String? interactiveText;

  const OnboardingStepData({
    required this.step,
    required this.title,
    required this.description,
    required this.icon,
    required this.bulletPoints,
    this.hasInteractiveElement = false,
    this.interactiveText,
  });

  static Map<OnboardingStep, OnboardingStepData> getStepData() {
    return {
      OnboardingStep.welcome: const OnboardingStepData(
        step: OnboardingStep.welcome,
        title: 'Eco Game\'e Hoş Geldiniz!',
        description:
            'Çevre bilincini artıran eğlenceli bir tahta oyununa hazır mısınız? Zar atarak ilerleyin, quiz sorularını yanıtlayın ve en yüksek skoru elde etmeye çalışın!',
        icon: '🎉',
        bulletPoints: [
          'Çevre bilincini artıran eğlenceli oyun',
          'Quiz sorularıyla öğrenme',
          'Tek ve çok oyuncu modları',
        ],
      ),
      OnboardingStep.gameObjective: const OnboardingStepData(
        step: OnboardingStep.gameObjective,
        title: 'Oyun Amacı',
        description:
            'Hedefiniz tahtadaki "Bitiş" karesine ulaşmak! Zar atarak ilerlerken quiz sorularını yanıtlayın, bonus ve ceza karelerinden puan kazanın veya kaybedin.',
        icon: '🎯',
        bulletPoints: [
          'Tahtadaki "Bitiş" karesine ulaşın',
          'Quiz sorularını doğru yanıtlayın',
          'Bonus karelerinden puan kazanın',
          'Ceza karelerinden kaçının',
        ],
      ),
      OnboardingStep.boardTiles: const OnboardingStepData(
        step: OnboardingStep.boardTiles,
        title: 'Tahta Kareleri',
        description:
            'Oyun tahtasında farklı türde kareler bulunur. Her birinin kendine özgü bir etkisi vardır.',
        icon: '🎲',
        bulletPoints: [
          '🏠 Başlangıç: Oyunun başladığı yer',
          '❓ Quiz: Soru yanıtlayın, doğru cevap puan kazandırır',
          '⭐ Bonus: Ekstra puan kazanın',
          '⚠️ Ceza: Puan kaybı',
          '🏁 Bitiş: Oyunu tamamlayın',
        ],
      ),
      OnboardingStep.scoring: const OnboardingStepData(
        step: OnboardingStep.scoring,
        title: 'Puanlama Sistemi',
        description:
            'Quiz puanlarınız toplanır, ancak geçen süreye göre ceza uygulanır. Daha hızlı bitirirseniz daha yüksek skor elde edersiniz!',
        icon: '📊',
        bulletPoints: [
          'Quiz doğru cevapları puan kazandırır',
          'Hızlı bitirme bonus puanı sağlar',
          'Ceza kareleri puanınızı azaltır',
          'Zamanında bitirmek önemlidir',
        ],
      ),
      OnboardingStep.singlePlayer: const OnboardingStepData(
        step: OnboardingStep.singlePlayer,
        title: 'Tek Oyuncu Modu',
        description:
            'Tek başınıza oynayın. Zar atın, ilerleyin ve quiz sorularını yanıtlayın. Skorunuz kaydedilir ve liderlik tablosunda yer alabilirsiniz.',
        icon: '👤',
        bulletPoints: [
          'Kendi hızınızda oynayın',
          'Skorlarınız liderlik tablosunda görünür',
          'Kişisel rekorlarınızı geliştirin',
          'Çevrimdışı da oynayabilirsiniz',
        ],
        hasInteractiveElement: true,
        interactiveText: 'Tek oyuncu modunu dene',
      ),
      OnboardingStep.multiPlayer: const OnboardingStepData(
        step: OnboardingStep.multiPlayer,
        title: 'Çok Oyuncu Modu',
        description:
            'Arkadaşlarınızla birlikte oynayın! Sırayla zar atın, birbirinizi geçmeye çalışın. Oda oluşturun veya katılın.',
        icon: '👥',
        bulletPoints: [
          'Arkadaşlarınızla oynayın',
          'Gerçek zamanlı rekabet',
          'İzleyici modunu kullanın',
          'Oyun tekrarlarını kaydedin',
        ],
        hasInteractiveElement: true,
        interactiveText: 'Çok oyuncu modunu keşfet',
      ),
      OnboardingStep.howToPlay: const OnboardingStepData(
        step: OnboardingStep.howToPlay,
        title: 'Nasıl Başlanır?',
        description:
            'Giriş yapın, tek oyuncu veya çok oyuncu modunu seçin. Zar at butonuna tıklayarak oyuna başlayın. İyi eğlenceler!',
        icon: '🚀',
        bulletPoints: [
          'Giriş yapın veya kayıt olun',
          'Tek oyuncu veya çok oyuncu seçin',
          'Zar at butonuna tıklayın',
          'Oyunda eğlenceli vakit geçirin!',
        ],
        hasInteractiveElement: true,
        interactiveText: 'Oyuna başla!',
      ),
    };
  }
}
