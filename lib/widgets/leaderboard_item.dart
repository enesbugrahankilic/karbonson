import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';

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
    this.avatarUrl,
    required this.rank,
    required this.isCurrentPlayerInTop10,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: rank <= 3 ? 8 : 2,
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: ListTile(
        leading: _buildLeadingWidget(context),
        title: Text(
          username,
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: rank <= 3 ? FontWeight.bold : FontWeight.normal,
                color: isCurrentPlayerInTop10 
                  ? Theme.of(context).colorScheme.error 
                  : Theme.of(context).textTheme.titleMedium?.color,
              ),
        ),
        trailing: Text(
          score.toString(),
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                color: _getScoreColor(context),
                fontWeight: FontWeight.bold,
              ),
        ),
      ),
    );
  }

  Widget _buildLeadingWidget(BuildContext context) {
    if (rank <= 3) {
      return CircleAvatar(
        backgroundColor: _getRankColor(context),
        child: Text(
          rank.toString(),
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
      );
    }

    if (avatarUrl != null) {
      return CircleAvatar(
        backgroundImage: CachedNetworkImageProvider(avatarUrl!),
      );
    }

    return CircleAvatar(
      child: Text(
        username[0].toUpperCase(),
        style: const TextStyle(fontWeight: FontWeight.bold),
      ),
    );
  }

  Color _getRankColor(BuildContext context) {
    switch (rank) {
      case 1:
        return Theme.of(context).colorScheme.primary;
      case 2:
        return Theme.of(context).colorScheme.secondary;
      case 3:
        return Theme.of(context).colorScheme.tertiary;
      default:
        return Theme.of(context).colorScheme.primaryContainer;
    }
  }

  Color _getScoreColor(BuildContext context) {
    switch (rank) {
      case 1:
        return Theme.of(context).colorScheme.primary;
      case 2:
        return Theme.of(context).colorScheme.secondary;
      case 3:
        return Theme.of(context).colorScheme.tertiary;
      default:
        return Theme.of(context).textTheme.bodyLarge?.color ?? Colors.black87;
    }
  }
}