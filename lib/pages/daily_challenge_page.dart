// lib/pages/daily_challenge_page.dart
// Daily challenge page to display and track daily tasks

import 'package:flutter/material.dart';
import '../services/achievement_service.dart';
import '../models/daily_challenge.dart';
import '../widgets/daily_challenge_card.dart';

class DailyChallengePage extends StatelessWidget {
  const DailyChallengePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Günlük Görevler'),
      ),
      body: StreamBuilder<List<DailyChallenge>>(
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

          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              if (activeChallenges.isNotEmpty) ...[
                const Text(
                  'Aktif Görevler',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                ...activeChallenges.map(
                    (challenge) => DailyChallengeCard(challenge: challenge)),
              ],
              if (completedChallenges.isNotEmpty) ...[
                const SizedBox(height: 24),
                const Text(
                  'Tamamlanan Görevler',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.green,
                  ),
                ),
                const SizedBox(height: 8),
                ...completedChallenges.map(
                    (challenge) => DailyChallengeCard(challenge: challenge)),
              ],
              if (expiredChallenges.isNotEmpty) ...[
                const SizedBox(height: 24),
                const Text(
                  'Süresi Dolan Görevler',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.red,
                  ),
                ),
                const SizedBox(height: 8),
                ...expiredChallenges.map(
                    (challenge) => DailyChallengeCard(challenge: challenge)),
              ],
            ],
          );
        },
      ),
    );
  }
}
