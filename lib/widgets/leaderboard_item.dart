// lib/widgets/leaderboard_item.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../provides/language_provider.dart';
import '../services/app_localizations.dart';

class LeaderboardItem extends StatelessWidget {
  final String username;
  final int score;
  final String? avatarUrl;
  final int rank;
  final bool isCurrentPlayerInTop10;

  const LeaderboardItem({
    super.key,
    required this.username,
    required this.score,
    required this.avatarUrl,
    required this.rank,
    this.isCurrentPlayerInTop10 = false,
  });

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isSmallScreen = screenWidth < 360;
    
    // Rank medal color
    Color getRankColor() {
      switch (rank) {
        case 1:
          return Colors.amber; // Gold
        case 2:
          return Colors.grey; // Silver  
        case 3:
          return Colors.brown; // Bronze
        default:
          return Colors.blue; // Blue for others
      }
    }

    // Rank icon
    Widget getRankIcon() {
      if (rank <= 3) {
        return Icon(
          Icons.emoji_events,
          color: getRankColor(),
          size: isSmallScreen ? 24 : 28,
        );
      } else {
        return Container(
          width: isSmallScreen ? 28 : 32,
          height: isSmallScreen ? 28 : 32,
          decoration: BoxDecoration(
            color: getRankColor(),
            shape: BoxShape.circle,
          ),
          child: Center(
            child: Text(
              rank.toString(),
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: isSmallScreen ? 12 : 14,
              ),
            ),
          ),
        );
      }
    }

    return Container(
      margin: EdgeInsets.symmetric(
        horizontal: isSmallScreen ? 8 : 16,
        vertical: isSmallScreen ? 4 : 8,
      ),
      padding: EdgeInsets.all(isSmallScreen ? 12 : 16),
      decoration: BoxDecoration(
        color: isCurrentPlayerInTop10
            ? Theme.of(context).colorScheme.primaryContainer
            : Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isCurrentPlayerInTop10
              ? Theme.of(context).colorScheme.primary
              : Theme.of(context).colorScheme.outline.withValues(alpha: 0.2),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          // Rank
          getRankIcon(),
          
          const SizedBox(width: 16),
          
          // Avatar
          Container(
            width: isSmallScreen ? 40 : 48,
            height: isSmallScreen ? 40 : 48,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(
                color: getRankColor(),
                width: 2,
              ),
            ),
            child: CircleAvatar(
              radius: isSmallScreen ? 18 : 22,
              backgroundColor: Theme.of(context).colorScheme.primaryContainer,
              backgroundImage: avatarUrl != null
                  ? NetworkImage(avatarUrl!)
                  : const AssetImage('assets/avatars/default_avatar_1.svg') as ImageProvider,
              onBackgroundImageError: (exception, stackTrace) {
                // Fallback to default avatar if image fails to load
              },
              child: avatarUrl == null
                  ? Icon(
                      Icons.person,
                      color: Theme.of(context).colorScheme.primary,
                      size: isSmallScreen ? 20 : 24,
                    )
                  : null,
            ),
          ),
          
          const SizedBox(width: 16),
          
          // User info
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Username
                Text(
                  username,
                  style: TextStyle(
                    fontSize: isSmallScreen ? 16 : 18,
                    fontWeight: FontWeight.bold,
                    color: isCurrentPlayerInTop10
                        ? Theme.of(context).colorScheme.primary
                        : Theme.of(context).colorScheme.onSurface,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                
                const SizedBox(height: 4),
                
                // Score
                Row(
                  children: [
                    Icon(
                      Icons.star,
                      color: Colors.amber,
                      size: isSmallScreen ? 16 : 18,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      '$score puan',
                      style: TextStyle(
                        fontSize: isSmallScreen ? 14 : 16,
                        fontWeight: FontWeight.w500,
                        color: Theme.of(context).colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          
          // Position indicator for current player
          if (isCurrentPlayerInTop10) ...[
            const SizedBox(width: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.primary,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                "Sen",
                style: TextStyle(
                  color: Theme.of(context).colorScheme.onPrimary,
                  fontSize: isSmallScreen ? 10 : 12,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}
