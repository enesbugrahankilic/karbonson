import 'package:flutter/material.dart';
import '../widgets/page_templates.dart';

class BoardGamePage extends StatefulWidget {
  final String? userNickname;
  final String? roomId;
  final String? playerId;

  const BoardGamePage({super.key, this.userNickname})
      : roomId = null,
        playerId = null;

  const BoardGamePage.multiplayer({
    super.key,
    required this.userNickname,
    required this.roomId,
    required this.playerId,
  });

  @override
  State<BoardGamePage> createState() => _BoardGamePageState();
}

class _BoardGamePageState extends State<BoardGamePage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: StandardAppBar(
        title: const Text('Tahta Oyunu'),
        onBackPressed: () => Navigator.pop(context),
      ),
      body: PageBody(
        scrollable: true,
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.games, size: 80, color: Colors.grey[400]),
                const SizedBox(height: 24),
                Text(
                  'Tahta Oyunu',
                  style: Theme.of(context).textTheme.headlineSmall,
                ),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Geri Dön'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
