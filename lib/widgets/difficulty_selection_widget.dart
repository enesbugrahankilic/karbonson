// lib/widgets/difficulty_selection_widget.dart
import 'package:flutter/material.dart';
import '../models/question.dart';
import '../services/difficulty_recommendation_service.dart';
import '../theme/theme_colors.dart';
import '../theme/design_system.dart';

/// Gelişmiş zorluk seçimi widget'ı
class DifficultySelectionWidget extends StatefulWidget {
  final DifficultyLevel? initialDifficulty;
  final Function(DifficultyLevel) onDifficultySelected;
  final bool showRecommendation;
  final bool showStatistics;

  const DifficultySelectionWidget({
    super.key,
    this.initialDifficulty,
    required this.onDifficultySelected,
    this.showRecommendation = true,
    this.showStatistics = true,
  });

  @override
  State<DifficultySelectionWidget> createState() => _DifficultySelectionWidgetState();
}

class _DifficultySelectionWidgetState extends State<DifficultySelectionWidget> {
  late DifficultyLevel _selectedDifficulty;
  final DifficultyRecommendationService _recommendationService = DifficultyRecommendationService();
  
  Map<String, dynamic>? _userStats;
  Map<String, dynamic>? _recommendation;
  Map<String, dynamic>? _performanceTrend;
  Map<String, dynamic>? _weakAreas;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _selectedDifficulty = widget.initialDifficulty ?? DifficultyLevel.easy;
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    try {
      await _recommendationService.loadUserStats();
      
      setState(() {
        _userStats = _recommendationService.getProgressReport();
        _recommendation = {'recommended': _recommendationService.getRecommendedDifficulty()};
        _performanceTrend = _recommendationService.getPerformanceTrend();
        _weakAreas = _recommendationService.getWeakAreas();
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return DesignSystem.loadingIndicator(context, message: 'Veriler yükleniyor...');
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Başlık
        Text(
          'Zorluk Seviyesi Seçin',
          style: DesignSystem.getTitleLarge(context).copyWith(
            fontWeight: FontWeight.bold,
            color: ThemeColors.getTitleColor(context),
          ),
        ),
        const SizedBox(height: DesignSystem.spacingM),

        // Öneri Kartı
        if (widget.showRecommendation && _recommendation != null) _buildRecommendationCard(),
        
        // Zorluk seçimi kartları
        _buildDifficultyCards(),
        
        // İstatistikler
        if (widget.showStatistics) ...[
          const SizedBox(height: DesignSystem.spacingL),
          _buildStatisticsCard(),
        ],
      ],
    );
  }

  Widget _buildRecommendationCard() {
    final recommendedDifficulty = _recommendation!['recommended'] as DifficultyLevel;
    
    return DesignSystem.glassCard(
      context,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.lightbulb_outline,
                color: ThemeColors.getPrimaryButtonColor(context),
                size: 24,
              ),
              const SizedBox(width: DesignSystem.spacingS),
              Text(
                'Öneri',
                style: DesignSystem.getTitleMedium(context).copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: DesignSystem.spacingS),
          Text(
            'Size önerilen zorluk seviyesi: ${recommendedDifficulty.displayName}',
            style: DesignSystem.getBodyMedium(context),
          ),
          if (_performanceTrend != null) ...[
            const SizedBox(height: DesignSystem.spacingS),
            _buildTrendMessage(),
          ],
        ],
      ),
    );
  }

  Widget _buildTrendMessage() {
    final trend = _performanceTrend!['trend'] as String;
    final message = _performanceTrend!['message'] as String;
    final recentAccuracy = _performanceTrend!['recentAccuracy'] as String;

    IconData trendIcon;
    Color trendColor;

    switch (trend) {
      case 'improving':
        trendIcon = Icons.trending_up;
        trendColor = Colors.green;
        break;
      case 'declining':
        trendIcon = Icons.trending_down;
        trendColor = Colors.red;
        break;
      case 'stable':
        trendIcon = Icons.trending_flat;
        trendColor = Colors.orange;
        break;
      default:
        trendIcon = Icons.help_outline;
        trendColor = Colors.grey;
    }

    return Container(
      padding: const EdgeInsets.all(DesignSystem.spacingS),
      decoration: BoxDecoration(
        color: trendColor.withOpacity(0.1),
        borderRadius: BorderRadius.circular(DesignSystem.radiusS),
        border: Border.all(color: trendColor.withOpacity(0.3)),
      ),
      child: Row(
        children: [
          Icon(trendIcon, color: trendColor, size: 20),
          const SizedBox(width: DesignSystem.spacingS),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  message,
                  style: DesignSystem.getBodySmall(context).copyWith(
                    color: trendColor,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Text(
                  'Son doğruluk oranı: %$recentAccuracy',
                  style: DesignSystem.getBodySmall(context).copyWith(
                    color: trendColor.withOpacity(0.8),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDifficultyCards() {
    return Column(
      children: DifficultyLevel.values.map((difficulty) {
        final isSelected = _selectedDifficulty == difficulty;
        final stats = _userStats?[difficulty.toString()] as Map<String, dynamic>?;
        
        return Container(
          margin: const EdgeInsets.only(bottom: DesignSystem.spacingS),
          child: DesignSystem.glassCard(
            context,
            child: InkWell(
              onTap: () {
                setState(() => _selectedDifficulty = difficulty);
                widget.onDifficultySelected(difficulty);
              },
              borderRadius: BorderRadius.circular(DesignSystem.radiusS),
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(DesignSystem.radiusS),
                  border: Border.all(
                    color: isSelected 
                      ? ThemeColors.getPrimaryButtonColor(context)
                      : Colors.transparent,
                    width: 2,
                  ),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(DesignSystem.spacingM),
                  child: Row(
                    children: [
                      // Zorluk ikonu
                      Container(
                        width: 48,
                        height: 48,
                        decoration: BoxDecoration(
                          color: _getDifficultyColor(difficulty).withOpacity(0.2),
                          borderRadius: BorderRadius.circular(DesignSystem.radiusS),
                        ),
                        child: Icon(
                          _getDifficultyIcon(difficulty),
                          color: _getDifficultyColor(difficulty),
                          size: 24,
                        ),
                      ),
                      const SizedBox(width: DesignSystem.spacingM),
                      
                      // Zorluk bilgileri
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              difficulty.displayName,
                              style: DesignSystem.getTitleMedium(context).copyWith(
                                fontWeight: FontWeight.bold,
                                color: _getDifficultyColor(difficulty),
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              _getDifficultyDescription(difficulty),
                              style: DesignSystem.getBodySmall(context).copyWith(
                                color: ThemeColors.getText(context).withOpacity(0.7),
                              ),
                            ),
                            if (stats != null && stats.isNotEmpty) ...[
                              const SizedBox(height: 4),
                              _buildStatsRow(stats),
                            ],
                          ],
                        ),
                      ),
                      
                      // Seçim göstergesi
                      if (isSelected)
                        Icon(
                          Icons.check_circle,
                          color: ThemeColors.getPrimaryButtonColor(context),
                          size: 24,
                        ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildStatsRow(Map<String, dynamic> stats) {
    final totalQuizzes = stats['totalQuizzes'] as int;
    final averageAccuracy = stats['averageAccuracy'] as String;
    
    if (totalQuizzes == 0) {
      return Text(
        'Henüz oynanmadı',
        style: DesignSystem.getBodySmall(context).copyWith(
          color: ThemeColors.getText(context).withOpacity(0.5),
        ),
      );
    }

    return Row(
      children: [
        Icon(
          Icons.bar_chart,
          size: 16,
          color: ThemeColors.getText(context).withOpacity(0.6),
        ),
        const SizedBox(width: 4),
        Text(
          '$totalQuizzes quiz • %$averageAccuracy doğruluk',
          style: DesignSystem.getBodySmall(context).copyWith(
            color: ThemeColors.getText(context).withOpacity(0.7),
          ),
        ),
      ],
    );
  }

  Widget _buildStatisticsCard() {
    if (_weakAreas == null) return const SizedBox.shrink();

    final weakAreas = _weakAreas!['weakAreas'] as List<String>;
    final recommendation = _weakAreas!['recommendation'] as String;

    return DesignSystem.glassCard(
      context,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.analytics_outlined,
                color: ThemeColors.getPrimaryButtonColor(context),
                size: 24,
              ),
              const SizedBox(width: DesignSystem.spacingS),
              Text(
                'Performans Analizi',
                style: DesignSystem.getTitleMedium(context).copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: DesignSystem.spacingS),
          Text(
            recommendation,
            style: DesignSystem.getBodyMedium(context),
          ),
          if (weakAreas.isNotEmpty) ...[
            const SizedBox(height: DesignSystem.spacingS),
            Text(
              'Zayıf konular: ${weakAreas.join(', ')}',
              style: DesignSystem.getBodySmall(context).copyWith(
                color: Colors.orange,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ],
      ),
    );
  }

  Color _getDifficultyColor(DifficultyLevel difficulty) {
    switch (difficulty) {
      case DifficultyLevel.easy:
        return Colors.green;
      case DifficultyLevel.medium:
        return Colors.orange;
      case DifficultyLevel.hard:
        return Colors.red;
    }
  }

  IconData _getDifficultyIcon(DifficultyLevel difficulty) {
    switch (difficulty) {
      case DifficultyLevel.easy:
        return Icons.sentiment_very_satisfied;
      case DifficultyLevel.medium:
        return Icons.sentiment_neutral;
      case DifficultyLevel.hard:
        return Icons.sentiment_very_dissatisfied;
    }
  }

  String _getDifficultyDescription(DifficultyLevel difficulty) {
    switch (difficulty) {
      case DifficultyLevel.easy:
        return 'Temel bilgiler • Hızlı tamamlama';
      case DifficultyLevel.medium:
        return 'Orta düzey • Dengeli zorluk';
      case DifficultyLevel.hard:
        return 'Uzman seviye • Derin bilgi';
    }
  }
}

/// Basit zorluk seçici widget'ı
class SimpleDifficultySelector extends StatelessWidget {
  final DifficultyLevel? selectedDifficulty;
  final Function(DifficultyLevel) onSelected;
  final bool showLabels;

  const SimpleDifficultySelector({
    super.key,
    this.selectedDifficulty,
    required this.onSelected,
    this.showLabels = true,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: DifficultyLevel.values.map((difficulty) {
        final isSelected = selectedDifficulty == difficulty;
        
        return Expanded(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4),
            child: ElevatedButton(
              onPressed: () => onSelected(difficulty),
              style: ElevatedButton.styleFrom(
                backgroundColor: isSelected
                  ? _getDifficultyColor(difficulty)
                  : Colors.grey.withOpacity(0.2),
                foregroundColor: isSelected ? Colors.white : _getDifficultyColor(difficulty),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                  side: BorderSide(
                    color: _getDifficultyColor(difficulty),
                    width: isSelected ? 0 : 1,
                  ),
                ),
                padding: const EdgeInsets.symmetric(vertical: 12),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(_getDifficultyIcon(difficulty), size: 20),
                  if (showLabels) ...[
                    const SizedBox(height: 4),
                    Text(
                      difficulty.displayName,
                      style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
                    ),
                  ],
                ],
              ),
            ),
          ),
        );
      }).toList(),
    );
  }

  Color _getDifficultyColor(DifficultyLevel difficulty) {
    switch (difficulty) {
      case DifficultyLevel.easy:
        return Colors.green;
      case DifficultyLevel.medium:
        return Colors.orange;
      case DifficultyLevel.hard:
        return Colors.red;
    }
  }

  IconData _getDifficultyIcon(DifficultyLevel difficulty) {
    switch (difficulty) {
      case DifficultyLevel.easy:
        return Icons.sentiment_very_satisfied;
      case DifficultyLevel.medium:
        return Icons.sentiment_neutral;
      case DifficultyLevel.hard:
        return Icons.sentiment_very_dissatisfied;
    }
  }
}
