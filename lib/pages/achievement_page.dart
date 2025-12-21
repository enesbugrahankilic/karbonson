// lib/pages/achievement_page.dart
// Achievement page to display user achievements and progress

import 'package:flutter/material.dart';
import '../services/achievement_service.dart';
import '../models/achievement.dart';
import '../models/user_progress.dart';
import '../widgets/achievement_card.dart';

class AchievementPage extends StatefulWidget {
  const AchievementPage({super.key});

  @override
  State<AchievementPage> createState() => _AchievementPageState();
}

class _AchievementPageState extends State<AchievementPage>
    with TickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Başarımlar'),
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: 'Tümü'),
            Tab(text: 'Kazanılan'),
            Tab(text: 'Kazanılmamış'),
          ],
        ),
      ),
      body: StreamBuilder<UserProgress>(
        stream: AchievementService().progressStream,
        builder: (context, progressSnapshot) {
          if (progressSnapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          final progress = progressSnapshot.data;
          if (progress == null) {
            return const Center(child: Text('İlerleme verisi yüklenemedi'));
          }

          return StreamBuilder<List<Achievement>>(
            stream: AchievementService().achievementsStream,
            builder: (context, achievementsSnapshot) {
              if (achievementsSnapshot.connectionState ==
                  ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }

              final allAchievements = achievementsSnapshot.data ?? [];
              final unlockedAchievements =
                  allAchievements.where((a) => a.unlockedAt != null).toList();
              final lockedAchievements =
                  allAchievements.where((a) => a.unlockedAt == null).toList();

              return TabBarView(
                controller: _tabController,
                children: [
                  _buildAchievementList(allAchievements, progress),
                  _buildAchievementList(unlockedAchievements, progress),
                  _buildAchievementList(lockedAchievements, progress),
                ],
              );
            },
          );
        },
      ),
    );
  }

  Widget _buildAchievementList(
      List<Achievement> achievements, UserProgress progress) {
    if (achievements.isEmpty) {
      return const Center(
        child: Text('Henüz başarımların yok'),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: achievements.length,
      itemBuilder: (context, index) {
        final achievement = achievements[index];
        return AchievementCard(
          achievement: achievement,
          isUnlocked: achievement.unlockedAt != null,
        );
      },
    );
  }
}
