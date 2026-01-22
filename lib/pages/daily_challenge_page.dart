// lib/pages/daily_challenge_page.dart
// Daily challenge page to display and track daily tasks

import 'package:flutter/material.dart';
import '../services/achievement_service.dart';
import '../models/daily_challenge.dart';
import '../widgets/daily_challenge_card.dart';
import '../widgets/page_templates.dart';
import '../theme/theme_colors.dart';

class DailyChallengePage extends StatelessWidget {
  const DailyChallengePage({super.key});

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
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }

            if (snapshot.hasError) {
              return Center(
                child: Text('Hata: ${snapshot.error}'),
              );
            }

            final challenges = snapshot.data ?? [];

            if (challenges.isEmpty) {
              return const Center(
                child: Text('Bugün için görev bulunamadı'),
              );
            }

            final activeChallenges =
                challenges.where((c) => !c.isCompleted && !c.isExpired).toList();
            final completedChallenges =
                challenges.where((c) => c.isCompleted).toList();
            final expiredChallenges =
                challenges.where((c) => c.isExpired && !c.isCompleted).toList();

            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (activeChallenges.isNotEmpty) ...[
                  _SectionHeader(title: 'Aktif Görevler'),
                  ...activeChallenges.map(
                      (challenge) => DailyChallengeCard(challenge: challenge)),
                ],
                if (completedChallenges.isNotEmpty) ...[
                  const SizedBox(height: 24),
                  _SectionHeader(title: 'Tamamlanan Görevler'),
                  ...completedChallenges.map(
                      (challenge) => DailyChallengeCard(challenge: challenge)),
                ],
                if (expiredChallenges.isNotEmpty) ...[
                  const SizedBox(height: 24),
                  _SectionHeader(title: 'Süresi Dolan Görevler'),
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
}

class _SectionHeader extends StatelessWidget {
  final String title;

  const _SectionHeader({required this.title});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(0, 16, 0, 12),
      child: Text(
        title,
        style: Theme.of(context).textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.w600,
              color: ThemeColors.getText(context),
            ),
      ),
    );
  }
}
