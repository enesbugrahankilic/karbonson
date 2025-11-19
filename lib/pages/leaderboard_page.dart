// lib/pages/leaderboard_page.dart (GÜNCELLENMİŞ KOD)

import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
 
import '../widgets/leaderboard_item.dart';
import 'login_page.dart';

class LeaderboardPage extends StatelessWidget {
  // YENİ: Oyuncunun takma adını almak için eklendi
  final String? currentPlayerNickname; 

  const LeaderboardPage({super.key, this.currentPlayerNickname});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Liderlik Tablosu'),
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
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('scores')
            .orderBy('highScore', descending: true)
            .limit(10)
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

          return ListView.builder(
            padding: const EdgeInsets.all(8),
            itemCount: snapshot.data!.docs.length,
            itemBuilder: (context, index) {
              final doc = snapshot.data!.docs[index];
              final data = doc.data() as Map<String, dynamic>;

              return LeaderboardItem(
                username: data['nickname'] as String? ?? 'Anonim',
                score: data['highScore'] as int? ?? 0,
                avatarUrl: data['avatarUrl'] as String?,
                rank: index + 1,
              );
            },
          );
        },
      ),
    );
  }
}