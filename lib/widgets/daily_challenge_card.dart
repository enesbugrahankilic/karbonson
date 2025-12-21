// lib/widgets/daily_challenge_card.dart
// Daily challenge card widget for displaying challenges

import 'package:flutter/material.dart';
import '../models/daily_challenge.dart';

class DailyChallengeCard extends StatelessWidget {
  final DailyChallenge challenge;

  const DailyChallengeCard({
    super.key,
    required this.challenge,
  });

  @override
  Widget build(BuildContext context) {
    final isCompleted = challenge.isCompleted;
    final isExpired = challenge.isExpired;

    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8),
      elevation: isCompleted ? 4 : 2,
      color: _getCardColor(),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    challenge.title,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: isExpired && !isCompleted
                          ? Colors.grey
                          : Colors.black,
                    ),
                  ),
                ),
                if (isCompleted)
                  const Icon(Icons.check_circle, color: Colors.green)
                else if (isExpired)
                  const Icon(Icons.timer_off, color: Colors.red)
                else
                  const Icon(Icons.access_time, color: Colors.orange),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              challenge.description,
              style: TextStyle(
                color: isExpired && !isCompleted
                    ? Colors.grey.shade600
                    : Colors.black87,
              ),
            ),
            const SizedBox(height: 12),
            LinearProgressIndicator(
              value: challenge.progressPercentage,
              backgroundColor: Colors.grey.shade300,
              valueColor: AlwaysStoppedAnimation<Color>(_getProgressColor()),
            ),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  '${challenge.currentValue}/${challenge.targetValue}',
                  style: TextStyle(
                    fontSize: 12,
                    color: isExpired && !isCompleted
                        ? Colors.grey
                        : Colors.black54,
                  ),
                ),
                Text(
                  '+${challenge.rewardPoints} puan',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: Colors.green,
                  ),
                ),
              ],
            ),
            if (isExpired && !isCompleted) ...[
              const SizedBox(height: 8),
              Text(
                'Süre doldu',
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.red,
                  fontStyle: FontStyle.italic,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Color _getCardColor() {
    if (challenge.isCompleted) {
      return Colors.green.shade50;
    } else if (challenge.isExpired) {
      return Colors.red.shade50;
    } else {
      return Colors.white;
    }
  }

  Color _getProgressColor() {
    if (challenge.isCompleted) {
      return Colors.green;
    } else if (challenge.isExpired) {
      return Colors.red;
    } else {
      return Colors.blue;
    }
  }
}
