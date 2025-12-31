// lib/pages/leaderboard_page.dart (GÜNCELLENMİŞ KOD)

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../widgets/leaderboard_item.dart';
import '../widgets/home_button.dart';
import 'login_page.dart';
import '../services/app_localizations.dart';
import '../services/firestore_service.dart';
import '../provides/language_provider.dart';

class LeaderboardPage extends StatelessWidget {
  // YENİ: Oyuncunun takma adını almak için eklendi
  final String? currentPlayerNickname;

  const LeaderboardPage({super.key, this.currentPlayerNickname});

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isSmallScreen = screenWidth < 360;
    final titleFontSize = isSmallScreen ? 18.0 : 20.0;

    return Scaffold(
      appBar: AppBar(
        leading: const HomeButton(),
        title: Consumer<LanguageProvider>(
          builder: (context, languageProvider, child) {
            return Text(
              AppLocalizations.leaderboard,
              style: TextStyle(fontSize: titleFontSize),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            );
          },
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.exit_to_app),
            onPressed: () {
              Navigator.of(context).pushAndRemoveUntil(
                MaterialPageRoute(builder: (context) => const LoginPage()),
                (Route<dynamic> route) => false,
              );
            },
            tooltip: 'Ana Sayfaya Dön',
          ),
        ],
      ),
      body: FutureBuilder<List<Map<String, dynamic>>>(
        future: FirestoreService().getLeaderboard(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.error_outline,
                    size: 64,
                    color: Theme.of(context).colorScheme.error,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Veri yüklenirken hata oluştu',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    snapshot.error.toString(),
                    style: Theme.of(context).textTheme.bodySmall,
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            );
          }

          final leaderboardData = snapshot.data ?? [];
          
          if (leaderboardData.isEmpty) {
            return const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.emoji_events_outlined,
                    size: 64,
                    color: Colors.grey,
                  ),
                  SizedBox(height: 16),
                  Text(
                    'Henüz kayıtlı skor bulunmuyor!',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w500,
                      color: Colors.grey,
                    ),
                  ),
                ],
              ),
            );
          }

          return Scrollbar(
            controller: PrimaryScrollController.of(context),
            child: SingleChildScrollView(
              primary: true,
              child: Column(
                children: [
                  Container(
                    padding: EdgeInsets.all(isSmallScreen ? 12 : 16),
                    child: Text(
                      'Liderlik Tablosu',
                      style: TextStyle(
                        fontSize: isSmallScreen ? 20 : 24,
                        fontWeight: FontWeight.bold,
                        color: Theme.of(context).colorScheme.primary,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  ListView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    padding: const EdgeInsets.all(8),
                    itemCount: leaderboardData.length,
                    itemBuilder: (context, index) {
                      final data = leaderboardData[index];
                      final username = data['nickname'] as String? ?? 'Anonim';
                      final rank = index + 1;
                      final isCurrentPlayerInTop10 =
                          rank <= 10 && username == currentPlayerNickname;

                      return LeaderboardItem(
                        username: username,
                        score: data['score'] as int? ?? 0,
                        avatarUrl: data['avatarUrl'] as String?,
                        rank: rank,
                        isCurrentPlayerInTop10: isCurrentPlayerInTop10,
                      );
                    },
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }


}
