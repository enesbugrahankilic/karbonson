// lib/widgets/daily_task_card.dart
// Gelişmiş Günlük Görev Kartı Widget'ı

import 'package:flutter/material.dart';
import '../models/daily_challenge.dart';

class DailyTaskCard extends StatefulWidget {
  final DailyChallenge challenge;
  final VoidCallback? onTap;
  final VoidCallback? onStart;
  final bool showDetails;

  const DailyTaskCard({
    super.key,
    required this.challenge,
    this.onTap,
    this.onStart,
    this.showDetails = true,
  });

  @override
  State<DailyTaskCard> createState() => _DailyTaskCardState();
}

class _DailyTaskCardState extends State<DailyTaskCard> {
  bool _isExpanded = false;

  @override
  Widget build(BuildContext context) {
    final challenge = widget.challenge;
    final isCompleted = challenge.isCompleted;
    final isExpired = challenge.isExpired;

    // Renk belirleme
    Color cardColor;
    Color borderColor;
    Color progressColor;

    if (isCompleted) {
      cardColor = Colors.green.shade50;
      borderColor = Colors.green.shade300;
      progressColor = Colors.green;
    } else if (isExpired) {
      cardColor = Colors.red.shade50;
      borderColor = Colors.red.shade300;
      progressColor = Colors.red;
    } else {
      cardColor = _getDifficultyColor(challenge.difficulty).withValues(alpha: 0.1);
      borderColor = _getDifficultyColor(challenge.difficulty);
      progressColor = _getDifficultyColor(challenge.difficulty);
    }

    return Card(
      elevation: isCompleted ? 2 : 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: borderColor, width: 2),
      ),
      color: cardColor,
      margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
      child: InkWell(
        onTap: widget.onTap,
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Üst satır: İkon ve başlık
              Row(
                children: [
                  // Görev ikonu
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: isCompleted
                          ? Colors.green.withValues(alpha: 0.2)
                          : borderColor.withValues(alpha: 0.2),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      challenge.icon ?? _getDefaultIcon(challenge.type),
                      style: const TextStyle(fontSize: 28),
                    ),
                  ),
                  const SizedBox(width: 12),
                  // Başlık ve tür
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          challenge.title,
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: isCompleted
                                ? Colors.green.shade800
                                : isExpired
                                    ? Colors.red.shade800
                                    : Colors.black87,
                            decoration: isCompleted
                                ? TextDecoration.lineThrough
                                : null,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            _buildTypeChip(challenge.type),
                            const SizedBox(width: 8),
                            _buildDifficultyBadge(challenge.difficulty),
                          ],
                        ),
                      ],
                    ),
                  ),
                  // Durum ikonu
                  _buildStatusIcon(isCompleted, isExpired),
                ],
              ),
              const SizedBox(height: 12),
              // Açıklama
              Text(
                challenge.description,
                style: TextStyle(
                  fontSize: 14,
                  color: isCompleted
                      ? Colors.green.shade700
                      : isExpired
                          ? Colors.red.shade700
                          : Colors.grey.shade700,
                ),
              ),
              const SizedBox(height: 12),
              // İlerleme çubuğu
              _buildProgressBar(
                currentValue: challenge.currentValue,
                targetValue: challenge.targetValue,
                progressColor: progressColor,
                isCompleted: isCompleted,
                isExpired: isExpired,
              ),
              const SizedBox(height: 8),
              // İlerleme metni ve ödül
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    '${challenge.currentValue}/${challenge.targetValue} tamamlandı',
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                      color: isCompleted
                          ? Colors.green.shade700
                          : Colors.grey.shade600,
                    ),
                  ),
                  _buildRewardBadge(challenge.rewardPoints, challenge.rewardType),
                ],
              ),
              // Detaylar (genişletilebilir)
              if (widget.showDetails && _isExpanded)
                _buildDetailsSection(challenge),
              // Genişlet/daralt butonu
              if (widget.showDetails && !isCompleted && !isExpired)
                TextButton.icon(
                  onPressed: () {
                    setState(() {
                      _isExpanded = !_isExpanded;
                    });
                  },
                  icon: Icon(
                    _isExpanded ? Icons.expand_less : Icons.expand_more,
                    color: borderColor,
                  ),
                  label: Text(
                    _isExpanded ? 'Daha az göster' : 'Daha fazla göster',
                    style: TextStyle(color: borderColor),
                  ),
                ),
              // Başlat butonu
              if (widget.onStart != null && !isCompleted && !isExpired)
                const SizedBox(height: 8),
              if (widget.onStart != null && !isCompleted && !isExpired)
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: widget.onStart,
                    icon: const Icon(Icons.play_arrow),
                    label: const Text('Görevi Başlat'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: borderColor,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  /// Zorluk rengini getir
  Color _getDifficultyColor(ChallengeDifficulty difficulty) {
    switch (difficulty) {
      case ChallengeDifficulty.easy:
        return Colors.green;
      case ChallengeDifficulty.medium:
        return Colors.orange;
      case ChallengeDifficulty.hard:
        return Colors.red;
      case ChallengeDifficulty.expert:
        return Colors.purple;
    }
  }

  /// Varsayılan ikonu getir
  String _getDefaultIcon(ChallengeType type) {
    switch (type) {
      case ChallengeType.quiz:
        return '🧠';
      case ChallengeType.duel:
        return '⚔️';
      case ChallengeType.multiplayer:
        return '🤝';
      case ChallengeType.social:
        return '👥';
      case ChallengeType.friendship:
        return '👫';
      case ChallengeType.streak:
        return '🔥';
      case ChallengeType.special:
        return '⭐';
      case ChallengeType.weekly:
        return '📅';
      case ChallengeType.seasonal:
        return '🌍';
      case ChallengeType.energy:
        return '⚡';
      case ChallengeType.water:
        return '💧';
      case ChallengeType.recycling:
        return '♻️';
      case ChallengeType.forest:
        return '🌲';
      case ChallengeType.climate:
        return '🌡️';
      case ChallengeType.transportation:
        return '🚲';
      case ChallengeType.biodiversity:
        return '🦋';
      case ChallengeType.consumption:
        return '🛒';
      case ChallengeType.boardGame:
        return '🎲';
    }
  }

  /// Tür chipi oluştur
  Widget _buildTypeChip(ChallengeType type) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: _getTypeColor(type).withValues(alpha: 0.2),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        widget.challenge.typeName,
        style: TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w500,
          color: _getTypeColor(type),
        ),
      ),
    );
  }

  /// Tür rengini getir
  Color _getTypeColor(ChallengeType type) {
    switch (type) {
      case ChallengeType.quiz:
        return Colors.blue;
      case ChallengeType.duel:
        return Colors.red;
      case ChallengeType.multiplayer:
        return Colors.purple;
      case ChallengeType.social:
      case ChallengeType.friendship:
        return Colors.pink;
      case ChallengeType.streak:
        return Colors.orange;
      case ChallengeType.special:
        return Colors.amber;
      case ChallengeType.weekly:
        return Colors.indigo;
      case ChallengeType.seasonal:
        return Colors.teal;
      case ChallengeType.energy:
        return Colors.yellow.shade700;
      case ChallengeType.water:
        return Colors.cyan;
      case ChallengeType.recycling:
        return Colors.green;
      case ChallengeType.forest:
        return Colors.brown;
      case ChallengeType.climate:
        return Colors.blueGrey;
      case ChallengeType.transportation:
        return Colors.blue;
      case ChallengeType.biodiversity:
        return Colors.lightGreen;
      case ChallengeType.consumption:
        return Colors.deepOrange;
      case ChallengeType.boardGame:
        return Colors.deepPurple;
    }
  }

  /// Zorluk rozeti oluştur
  Widget _buildDifficultyBadge(ChallengeDifficulty difficulty) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: _getDifficultyColor(difficulty).withValues(alpha: 0.2),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        widget.challenge.difficultyName,
        style: TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w500,
          color: _getDifficultyColor(difficulty),
        ),
      ),
    );
  }

  /// Durum ikonu oluştur
  Widget _buildStatusIcon(bool isCompleted, bool isExpired) {
    IconData icon;
    Color color;

    if (isCompleted) {
      icon = Icons.check_circle;
      color = Colors.green;
    } else if (isExpired) {
      icon = Icons.cancel;
      color = Colors.red;
    } else {
      icon = Icons.access_time;
      color = Colors.orange;
    }

    return Icon(
      icon,
      color: color,
      size: 28,
    );
  }

  /// İlerleme çubuğu oluştur
  Widget _buildProgressBar({
    required int currentValue,
    required int targetValue,
    required Color progressColor,
    required bool isCompleted,
    required bool isExpired,
  }) {
    final progress = (currentValue / targetValue).clamp(0.0, 1.0);

    return Stack(
      children: [
        Container(
          height: 12,
          decoration: BoxDecoration(
            color: Colors.grey.shade200,
            borderRadius: BorderRadius.circular(6),
          ),
        ),
        AnimatedContainer(
          duration: const Duration(milliseconds: 500),
          curve: Curves.easeInOut,
          height: 12,
          width: MediaQuery.of(context).size.width * progress,
          decoration: BoxDecoration(
            color: isCompleted
                ? Colors.green
                : isExpired
                    ? Colors.red.shade300
                    : progressColor,
            borderRadius: BorderRadius.circular(6),
          ),
        ),
      ],
    );
  }

  /// Ödül rozeti oluştur
  Widget _buildRewardBadge(int points, RewardType rewardType) {
    IconData icon;
    String label;

    switch (rewardType) {
      case RewardType.points:
        icon = Icons.stars;
        label = '+$points puan';
        break;
      case RewardType.avatar:
        icon = Icons.face;
        label = 'Avatar';
        break;
      case RewardType.theme:
        icon = Icons.palette;
        label = 'Tema';
        break;
      case RewardType.feature:
        icon = Icons.lock_open;
        label = 'Özellik';
        break;
    }

    return Row(
      children: [
        Icon(icon, color: Colors.amber, size: 18),
        const SizedBox(width: 4),
        Text(
          label,
          style: const TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: Colors.amber,
          ),
        ),
      ],
    );
  }

  /// Detay bölümü oluştur
  Widget _buildDetailsSection(DailyChallenge challenge) {
    return Container(
      margin: const EdgeInsets.only(top: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.5),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Süre bilgisi
          Row(
            children: [
              const Icon(Icons.timer, size: 16, color: Colors.grey),
              const SizedBox(width: 8),
              Text(
                'Tahmini süre: ~${_getEstimatedTime(challenge.type)} dk',
                style: const TextStyle(fontSize: 13, color: Colors.grey),
              ),
            ],
          ),
          const SizedBox(height: 8),
          // Çevresel etki
          Row(
            children: [
              const Icon(Icons.eco, size: 16, color: Colors.green),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  _getEnvironmentalImpact(challenge.type),
                  style: const TextStyle(fontSize: 13, color: Colors.green),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          // İpuçları
          if (_getTips(challenge.type).isNotEmpty)
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Row(
                  children: [
                    Icon(Icons.lightbulb, size: 16, color: Colors.amber),
                    SizedBox(width: 8),
                    Text(
                      'İpuçları:',
                      style:
                          TextStyle(fontSize: 13, fontWeight: FontWeight.w500),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                ..._getTips(challenge.type).map(
                  (tip) => Padding(
                    padding: const EdgeInsets.only(left: 24, bottom: 4),
                    child: Text(
                      '• $tip',
                      style: const TextStyle(fontSize: 12, color: Colors.grey),
                    ),
                  ),
                ),
              ],
            ),
          // Süre dolumu
          if (!challenge.isExpired && !challenge.isCompleted)
            Padding(
              padding: const EdgeInsets.only(top: 8),
              child: Row(
                children: [
                  const Icon(Icons.schedule, size: 16, color: Colors.orange),
                  const SizedBox(width: 8),
                  Text(
                    'Süre dolumu: ${_getRemainingTime(challenge.expiresAt)}',
                    style: const TextStyle(fontSize: 12, color: Colors.orange),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }

  /// Tahmini süreyi getir
  int _getEstimatedTime(ChallengeType type) {
    switch (type) {
      case ChallengeType.quiz:
        return 5;
      case ChallengeType.duel:
        return 3;
      case ChallengeType.multiplayer:
        return 10;
      case ChallengeType.social:
      case ChallengeType.friendship:
        return 2;
      case ChallengeType.streak:
        return 1;
      case ChallengeType.special:
        return 5;
      case ChallengeType.weekly:
        return 30;
      case ChallengeType.seasonal:
        return 15;
      case ChallengeType.energy:
        return 5;
      case ChallengeType.water:
        return 5;
      case ChallengeType.recycling:
        return 5;
      case ChallengeType.forest:
        return 5;
      case ChallengeType.climate:
        return 6;
      case ChallengeType.transportation:
        return 6;
      case ChallengeType.biodiversity:
        return 8;
      case ChallengeType.consumption:
        return 6;
      case ChallengeType.boardGame:
        return 15;
    }
  }

  /// Çevresel etki metnini getir
  String _getEnvironmentalImpact(ChallengeType type) {
    switch (type) {
      case ChallengeType.quiz:
        return 'Öğrendiğin bilgiler çevre dostu kararlar almanı sağlar';
      case ChallengeType.duel:
        return 'Rekabetçi öğrenme, bilgiyi pekiştirir';
      case ChallengeType.multiplayer:
        return 'Takım çalışması ile daha etkili öğrenme';
      case ChallengeType.social:
      case ChallengeType.friendship:
        return 'Birlikte öğrenmek daha etkilidir';
      case ChallengeType.streak:
        return 'Düzenli öğrenme alışkanlığı kazanırsın';
      case ChallengeType.special:
        return 'Özel ödüller kazanırsın';
      case ChallengeType.weekly:
        return 'Kapsamlı çevre eğitimi';
      case ChallengeType.seasonal:
        return 'Mevsimsel ödüller ve başarımlar';
      case ChallengeType.energy:
        return 'Enerji tasarrufu, karbon ayak izini azaltır';
      case ChallengeType.water:
        return 'Su kıtlığına karşı farkındalık yaratırsın';
      case ChallengeType.recycling:
        return 'Atık miktarını azaltır, kaynakları korursun';
      case ChallengeType.forest:
        return 'Ormanları koruma bilinci kazanırsın';
      case ChallengeType.climate:
        return 'İklim değişikliğini anlar, çözümler üretirsin';
      case ChallengeType.transportation:
        return 'Düşük karbonlu ulaşım tercihleri';
      case ChallengeType.biodiversity:
        return 'Türlerin korunmasına katkıda bulunursun';
      case ChallengeType.consumption:
        return 'Sürdürülebilir tüketim alışkanlıkları';
      case ChallengeType.boardGame:
        return 'Stratejik düşünme ve takım çalışması';
    }
  }

  /// İpuçlarını getir
  List<String> _getTips(ChallengeType type) {
    switch (type) {
      case ChallengeType.quiz:
        return [
          'Hangi konuda iyisin?',
          'Doğru cevaplar için düşünmeden cevapla',
          'Zor konulara meydan oku'
        ];
      case ChallengeType.duel:
        return [
          'Hızlı düşün',
          'Rakibin zayıf olduğu konuyu seç',
          'Güçlü konularında düello teklif et'
        ];
      case ChallengeType.multiplayer:
        return [
          'Takım arkadaşlarınla koordine ol',
          'Herkesin güçlü yanlarını kullan'
        ];
      case ChallengeType.social:
      case ChallengeType.friendship:
        return [
          'Arkadaşlarını davet et',
          'Profilini sosyal medyada paylaş',
          'QR kod ile arkadaş ekle'
        ];
      case ChallengeType.streak:
        return [
          'Her gün quiz çöz',
          'Hatırlatma kullan',
          'Komşularınla yarış'
        ];
      case ChallengeType.energy:
        return [
          'LED ampul kullanımı hakkında bilgi edin',
          'Güneş enerjisi quizlerini dene'
        ];
      case ChallengeType.water:
        return [
          'Duş süreni kısaltma hakkında bilgi edin',
          'Yağmur suyu toplama sistemlerini öğren'
        ];
      case ChallengeType.recycling:
        return [
          'Plastik, kağıt ve cam ayrıştırmayı öğren',
          'E-atık geri dönüşümü hakkında bilgi edin'
        ];
      case ChallengeType.forest:
        return [
          'Ağaçların önemini öğren',
          'Orman yangınlarını önleme yollarını keşfet'
        ];
      case ChallengeType.climate:
        return [
          'Sera gazlarının etkilerini öğren',
          'Paris Anlaşması hakkında bilgi edin'
        ];
      case ChallengeType.transportation:
        return [
          'Bisiklet ve yürüyüşün faydalarını öğren',
          'Toplu taşıma kullanımı hakkında bilgi edin'
        ];
      case ChallengeType.biodiversity:
        return [
          'Nesli tehlike altındaki türleri öğren',
          'Habitat koruma hakkında bilgi edin'
        ];
      case ChallengeType.consumption:
        return [
          'Sürdürülebilir ürünler tercih et',
          'Geri dönüşümlü ambalajları araştır'
        ];
      case ChallengeType.special:
        return [
          'Özel görevler için ipuçlarını takip et',
          'Zamanında tamamla'
        ];
      case ChallengeType.weekly:
        return [
          'Haftanın başında başla',
          'Her gün düzenli çöz'
        ];
      case ChallengeType.seasonal:
        return [
          'Mevsimsel etkinliklere katıl',
          'Özel ödüller kazan'
        ];
      case ChallengeType.boardGame:
        return [
          'Stratejik düşün',
          'Rakiplerini analiz et'
        ];
    }
  }

  /// Kalan süreyi getir
  String _getRemainingTime(DateTime expiresAt) {
    final now = DateTime.now();
    final difference = expiresAt.difference(now);

    if (difference.inHours > 24) {
      return '${difference.inDays} gün';
    } else if (difference.inHours > 0) {
      return '${difference.inHours} saat';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes} dakika';
    } else {
      return 'Süre doldu';
    }
  }
}

