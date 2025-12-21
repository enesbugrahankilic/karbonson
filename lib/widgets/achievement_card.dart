// lib/widgets/achievement_card.dart
// Achievement card widget for displaying achievements

import 'package:flutter/material.dart';
import '../models/achievement.dart';

class AchievementCard extends StatelessWidget {
  final Achievement achievement;
  final bool isUnlocked;

  const AchievementCard({
    super.key,
    required this.achievement,
    required this.isUnlocked,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8),
      elevation: isUnlocked ? 4 : 2,
      color: isUnlocked ? Colors.white : Colors.grey.shade100,
      child: ListTile(
        leading: Container(
          width: 50,
          height: 50,
          decoration: BoxDecoration(
            color: isUnlocked ? _getRarityColor() : Colors.grey.shade300,
            borderRadius: BorderRadius.circular(25),
          ),
          child: Center(
            child: Text(
              achievement.icon,
              style: const TextStyle(fontSize: 24),
            ),
          ),
        ),
        title: Text(
          achievement.title,
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: isUnlocked ? Colors.black : Colors.grey,
          ),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              achievement.description,
              style: TextStyle(
                color: isUnlocked ? Colors.black87 : Colors.grey,
              ),
            ),
            const SizedBox(height: 4),
            Row(
              children: [
                Icon(
                  Icons.star,
                  size: 16,
                  color: _getRarityColor(),
                ),
                const SizedBox(width: 4),
                Text(
                  '${achievement.points} puan',
                  style: TextStyle(
                    fontSize: 12,
                    color: isUnlocked ? Colors.black54 : Colors.grey,
                  ),
                ),
                const SizedBox(width: 8),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(
                    color: _getRarityColor().withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Text(
                    achievement.rarityName,
                    style: TextStyle(
                      fontSize: 10,
                      color: _getRarityColor(),
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
        trailing: isUnlocked
            ? const Icon(Icons.check_circle, color: Colors.green)
            : const Icon(Icons.lock, color: Colors.grey),
      ),
    );
  }

  Color _getRarityColor() {
    switch (achievement.rarity) {
      case AchievementRarity.common:
        return Colors.grey;
      case AchievementRarity.rare:
        return Colors.blue;
      case AchievementRarity.epic:
        return Colors.purple;
      case AchievementRarity.legendary:
        return Colors.orange;
    }
  }
}
