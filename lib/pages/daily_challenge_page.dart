// lib/pages/daily_challenge_page.dart
// Daily challenge page to display and track daily tasks

import 'package:flutter/material.dart';
import '../services/achievement_service.dart';
import '../models/daily_challenge.dart';
import '../widgets/daily_challenge_card.dart';
import '../widgets/page_templates.dart';
import '../theme/theme_colors.dart';
import '../theme/design_system.dart';
import 'dart:async';

class DailyChallengePage extends StatefulWidget {
  DailyChallengePage({super.key});

  @override
  State<DailyChallengePage> createState() => _DailyChallengePageState();
}

class _DailyChallengePageState extends State<DailyChallengePage> {
  late Timer _timeoutTimer;
  bool _isTimeout = false;

  @override
  void initState() {
    super.initState();
    // ✅ 10 saniye timeout kontrolü
    _timeoutTimer = Timer(const Duration(seconds: 10), () {
      if (mounted) {
        setState(() => _isTimeout = true);
      }
    });
  }

  @override
  void dispose() {
    _timeoutTimer.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: StandardAppBar(
        title: const Text('Günlük Görevler'),
        onBackPressed: () => Navigator.pop(context),
      ),
      body: PageBody(
        scrollable: true,
        child: StreamBuilder<List<DailyChallenge>>(
          stream: AchievementService().challengesStream,
          builder: (context, snapshot) {
            // ✅ Timeout durumu
            if (_isTimeout && snapshot.connectionState == ConnectionState.waiting) {
              return _buildTimeoutUI(context);
            }

            if (snapshot.connectionState == ConnectionState.waiting) {
              return _buildLoadingUI(context);
            }

            if (snapshot.hasError) {
              return _buildErrorUI(context, snapshot.error.toString());
            }

            final challenges = snapshot.data ?? [];

            // ✅ Boş durum UI'ı
            if (challenges.isEmpty) {
              return _buildEmptyStateUI(context);
            }

            final activeChallenges =
                challenges.where((c) => !c.isCompleted && !c.isExpired).toList();
            final completedChallenges =
                challenges.where((c) => c.isCompleted).toList();
            final expiredChallenges =
                challenges.where((c) => c.isExpired && !c.isCompleted).toList();

            // Cancel timeout timer when data loaded
            _timeoutTimer.cancel();

            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (activeChallenges.isNotEmpty) ...[
                  SectionHeader(title: 'Aktif Görevler'),
                  ...activeChallenges.map(
                      (challenge) => DailyChallengeCard(challenge: challenge)),
                ],
                if (completedChallenges.isNotEmpty) ...[
                  const SizedBox(height: 24),
                  SectionHeader(title: 'Tamamlanan Görevler'),
                  ...completedChallenges.map(
                      (challenge) => DailyChallengeCard(challenge: challenge)),
                ],
                if (expiredChallenges.isNotEmpty) ...[
                  const SizedBox(height: 24),
                  SectionHeader(title: 'Süresi Dolan Görevler'),
                  ...expiredChallenges.map(
                      (challenge) => DailyChallengeCard(challenge: challenge)),
                ],
              ],
            );
          },
        ),
      ),
    );
  }

  /// ✅ Loading UI
  Widget _buildLoadingUI(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const CircularProgressIndicator(),
          const SizedBox(height: DesignSystem.spacingM),
          Text(
            'Görevler yükleniyor...',
            style: DesignSystem.getBodyMedium(context),
          ),
        ],
      ),
    );
  }

  /// ✅ Timeout UI
  Widget _buildTimeoutUI(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.schedule,
            size: 80,
            color: ThemeColors.getWarningColor(context),
          ),
          const SizedBox(height: DesignSystem.spacingL),
          Text(
            'Yükleme Zaman Aşımına Uğradı',
            textAlign: TextAlign.center,
            style: DesignSystem.getTitleMedium(context),
          ),
          const SizedBox(height: DesignSystem.spacingM),
          Text(
            'Görevler yüklenemedi. İnternet bağlantınızı kontrol edin.',
            textAlign: TextAlign.center,
            style: DesignSystem.getBodyMedium(context).copyWith(
              color: ThemeColors.getSecondaryText(context),
            ),
          ),
          const SizedBox(height: DesignSystem.spacingL),
          ElevatedButton.icon(
            onPressed: () {
              setState(() => _isTimeout = false);
              _timeoutTimer = Timer(const Duration(seconds: 10), () {
                if (mounted) setState(() => _isTimeout = true);
              });
            },
            icon: const Icon(Icons.refresh),
            label: const Text('Tekrar Dene'),
          ),
        ],
      ),
    );
  }

  /// ✅ Error UI
  Widget _buildErrorUI(BuildContext context, String error) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.error_outline,
            size: 80,
            color: Colors.red[400],
          ),
          const SizedBox(height: DesignSystem.spacingL),
          Text(
            'Bir Hata Oluştu',
            textAlign: TextAlign.center,
            style: DesignSystem.getTitleMedium(context),
          ),
          const SizedBox(height: DesignSystem.spacingM),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: DesignSystem.spacingL),
            child: Text(
              error.length > 100 ? error.substring(0, 100) + '...' : error,
              textAlign: TextAlign.center,
              style: DesignSystem.getBodySmall(context).copyWith(
                color: ThemeColors.getSecondaryText(context),
              ),
            ),
          ),
          const SizedBox(height: DesignSystem.spacingL),
          ElevatedButton.icon(
            onPressed: () => Navigator.pop(context),
            icon: const Icon(Icons.arrow_back),
            label: const Text('Geri Dön'),
          ),
        ],
      ),
    );
  }

  /// ✅ Boş durum UI'ı
  Widget _buildEmptyStateUI(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.task_alt,
            size: 80,
            color: ThemeColors.getSuccessColor(context),
          ),
          const SizedBox(height: DesignSystem.spacingL),
          Text(
            'Görev Yok',
            textAlign: TextAlign.center,
            style: DesignSystem.getTitleMedium(context),
          ),
          const SizedBox(height: DesignSystem.spacingM),
          Text(
            'Bugün için henüz görev bulunmamaktadır.\nSonra kontrol etmeyi unutmayın!',
            textAlign: TextAlign.center,
            style: DesignSystem.getBodyMedium(context).copyWith(
              color: ThemeColors.getSecondaryText(context),
            ),
          ),
          const SizedBox(height: DesignSystem.spacingL),
          OutlinedButton.icon(
            onPressed: () => Navigator.pop(context),
            icon: const Icon(Icons.arrow_back),
            label: const Text('Geri Dön'),
          ),
        ],
      ),
    );
  }
}
