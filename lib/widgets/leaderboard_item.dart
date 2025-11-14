import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';

class LeaderboardItem extends StatelessWidget {
  final String username;
  final int score;
  final String? avatarUrl;
  final int rank;

  const LeaderboardItem({
    Key? key,
    required this.username,
    required this.score,
    this.avatarUrl,
    required this.rank,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: rank <= 3 ? 8 : 2,
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: ListTile(
        leading: _buildLeadingWidget(),
        title: Text(
          username,
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: rank <= 3 ? FontWeight.bold : FontWeight.normal,
              ),
        ),
        trailing: Text(
          score.toString(),
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                color: _getScoreColor(),
                fontWeight: FontWeight.bold,
              ),
        ),
      ),
    );
  }

  Widget _buildLeadingWidget() {
    if (rank <= 3) {
      return CircleAvatar(
        backgroundColor: _getRankColor(),
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

  Color _getRankColor() {
    switch (rank) {
      case 1:
        return Colors.amber;
      case 2:
        return Colors.grey[400]!;
      case 3:
        return Colors.brown[300]!;
      default:
        return Colors.blue;
    }
  }

  Color _getScoreColor() {
    switch (rank) {
      case 1:
        return Colors.amber;
      case 2:
        return Colors.grey[600]!;
      case 3:
        return Colors.brown;
      default:
        return Colors.black87;
    }
  }
}