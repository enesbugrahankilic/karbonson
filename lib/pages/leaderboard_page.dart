// lib/pages/leaderboard_page.dart (GÜNCELLENMİŞ KOD)

import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:provider/provider.dart';
 
import '../widgets/leaderboard_item.dart';
import '../widgets/home_button.dart';
import 'login_page.dart';
import '../services/app_localizations.dart';
import '../provides/language_provider.dart';

class LeaderboardPage extends StatelessWidget {
  // YENİ: Oyuncunun takma adını almak için eklendi
  final String? currentPlayerNickname; 

  const LeaderboardPage({super.key, this.currentPlayerNickname});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: const HomeButton(),
        title: Consumer<LanguageProvider>(
          builder: (context, languageProvider, child) {
            return Text(AppLocalizations.leaderboard);
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
      body: Scrollbar(
        child: StreamBuilder<QuerySnapshot>(
          stream: FirebaseFirestore.instance
              .collection('users')
              .where('score', isGreaterThan: 0)
              .orderBy('score', descending: true)
              .snapshots(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }

            if (snapshot.hasError) {
              return Center(child: Text('Hata: ${snapshot.error}'));
            }

            if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
              return const Center(child: Text('Henüz kayıtlı skor bulunmuyor!'));
            }

            return SingleChildScrollView(
              child: Column(
                children: [
                  Container(
                    padding: const EdgeInsets.all(16),
                    child: Text(
                      'Liderlik Tablosu',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Theme.of(context).colorScheme.primary,
                      ),
                    ),
                  ),
                  ListView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    padding: const EdgeInsets.all(8),
                    itemCount: snapshot.data!.docs.length,
                    itemBuilder: (context, index) {
                      final doc = snapshot.data!.docs[index];
                      final data = doc.data() as Map<String, dynamic>;
                      final username = data['nickname'] as String? ?? 'Anonim';
                      final rank = index + 1;
                      final isCurrentPlayerInTop10 = rank <= 10 && username == currentPlayerNickname;

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
            );
          },
        ),
      ),
    );
  }
}