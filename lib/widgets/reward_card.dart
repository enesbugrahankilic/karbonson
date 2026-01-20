// lib/widgets/reward_card.dart
// Modern Reward Card - Glassmorphism, Animations, Theme Integration

import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import '../theme/theme_colors.dart';
import '../models/reward_item.dart';
import '../models/user_progress.dart';

/// Modern Reward Card with glassmorphism effects and animations
class ModernRewardCard extends StatefulWidget {
  final RewardItem rewardItem;
  final bool isUnlocked;
  final bool isSelected;
  final VoidCallback? onTap;
  final VoidCallback? onUse;
  final UserProgress? userProgress;
  final bool showProgress;
  final bool compactMode;

  const ModernRewardCard({
    super.key,
    required this.rewardItem,
    this.isUnlocked = false,
    this.isSelected = false,
    this.onTap,
    this.onUse,
    this.userProgress,
    this.showProgress = true,
    this.compactMode = false,
  });

  @override
  State<ModernRewardCard> createState() => _ModernRewardCardState();
}

class _ModernRewardCardState extends State<ModernRewardCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _scaleController;
  late Animation<double> _scaleAnimation;
  bool _isPressed = false;

  @override
  void initState() {
    super.initState();
    _scaleController = AnimationController(
      duration: const Duration(milliseconds: 200),
      vsync: this,
    );
    _scaleAnimation = Tween<double>(begin: 1.0, end: 0.95).animate(
      CurvedAnimation(parent: _scaleController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _scaleController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final rarityColor = _getRarityColor();
    final gradientColors = _getGradientColors(rarityColor);
    final unlockProgress = widget.rewardItem.getUnlockProgress(widget.userProgress);

    return AnimatedBuilder(
      animation: _scaleAnimation,
      builder: (context, child) {
        return Transform.scale(
          scale: _scaleAnimation.value,
          child: child,
        );
      },
      child: GestureDetector(
        onTapDown: (_) {
          _scaleController.forward();
          setState(() => _isPressed = true);
        },
        onTapUp: (_) {
          _scaleController.reverse();
          setState(() => _isPressed = false);
        },
        onTapCancel: () {
          _scaleController.reverse();
          setState(() => _isPressed = false);
        },
        onTap: widget.onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOutCubic,
          margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            gradient: widget.isUnlocked
                ? LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: gradientColors,
                  )
                : null,
            boxShadow: widget.isUnlocked
                ? [
                    BoxShadow(
                      color: rarityColor.withOpacity(0.3),
                      blurRadius: 20,
                      spreadRadius: 2,
                      offset: const Offset(0, 8),
                    ),
                    BoxShadow(
                      color: rarityColor.withOpacity(0.1),
                      blurRadius: 40,
                      spreadRadius: 5,
                      offset: const Offset(0, 16),
                    ),
                  ]
                : ThemeColors.getModernShadow(context, elevation: 0.5),
            border: Border.all(
              color: widget.isSelected
                  ? rarityColor
                  : widget.isUnlocked
                      ? rarityColor.withOpacity(0.5)
                      : Colors.transparent,
              width: widget.isSelected ? 3 : widget.isUnlocked ? 1.5 : 0,
            ),
          ),
          child: _buildCardContent(rarityColor, unlockProgress),
        ),
      ),
    );
  }

  Widget _buildCardContent(Color rarityColor, RewardUnlockProgress progress) {
    if (widget.compactMode) {
      return _buildCompactContent(rarityColor);
    }

    return ClipRRect(
      borderRadius: BorderRadius.circular(20),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: widget.isUnlocked
              ? Colors.white.withOpacity(0.1)
              : ThemeColors.getCardBackground(context),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildHeader(rarityColor),
            const SizedBox(height: 12),
            _buildDescription(),
            if (widget.showProgress) ...[
              const SizedBox(height: 12),
              _buildProgressSection(progress, rarityColor),
            ],
            if (widget.isUnlocked && widget.onUse != null) ...[
              const SizedBox(height: 12),
              _buildActionButton(rarityColor),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(Color rarityColor) {
    return Row(
      children: [
        _buildRewardIcon(rarityColor),
        const SizedBox(width: 14),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      widget.rewardItem.name,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: widget.isUnlocked
                                ? Colors.white
                                : ThemeColors.getCardForeground(context),
                          ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 4),
              _buildRarityAndTypeBadge(rarityColor),
            ],
          ),
        ),
        if (widget.isUnlocked) _buildUnlockedBadge() else _buildLockStatus(),
      ],
    );
  }

  Widget _buildRewardIcon(Color rarityColor) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      width: 56,
      height: 56,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: widget.isUnlocked
              ? [
                  rarityColor.withOpacity(0.3),
                  rarityColor.withOpacity(0.1),
                ]
              : [Colors.grey[300]!, Colors.grey[200]!],
        ),
        border: Border.all(
          color: rarityColor,
          width: 2,
        ),
        boxShadow: widget.isUnlocked
            ? [
                BoxShadow(
                  color: rarityColor.withOpacity(0.5),
                  blurRadius: 15,
                  spreadRadius: 2,
                ),
              ]
            : null,
      ),
      child: Center(
        child: Text(
          widget.rewardItem.icon,
          style: const TextStyle(fontSize: 28),
        ),
      ),
    );
  }

  Widget _buildRarityAndTypeBadge(Color rarityColor) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
          decoration: BoxDecoration(
            color: rarityColor,
            borderRadius: BorderRadius.circular(10),
          ),
          child: Text(
            widget.rewardItem.rarityName,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 10,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        const SizedBox(width: 8),
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              _getTypeIcon(),
              size: 14,
              color: widget.isUnlocked
                  ? Colors.white.withOpacity(0.8)
                  : Colors.grey[600],
            ),
            const SizedBox(width: 4),
            Text(
              widget.rewardItem.typeName,
              style: TextStyle(
                fontSize: 12,
                color: widget.isUnlocked
                    ? Colors.white.withOpacity(0.8)
                    : Colors.grey[600],
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildUnlockedBadge() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: Colors.green.withOpacity(0.2),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.green.withOpacity(0.5)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: const [
          Icon(Icons.check_circle, color: Colors.green, size: 16),
          SizedBox(width: 4),
          Text(
            'Açıldı',
            style: TextStyle(
              color: Colors.green,
              fontSize: 11,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLockStatus() {
    final progress = widget.rewardItem.getUnlockProgress(widget.userProgress);
    Color statusColor;
    IconData statusIcon;
    String statusText;

    switch (progress.status) {
      case RewardUnlockStatus.unlocked:
        statusColor = Colors.green;
        statusIcon = Icons.check_circle;
        statusText = 'Açık';
        break;
      case RewardUnlockStatus.available:
        statusColor = Colors.blue;
        statusIcon = Icons.star;
        statusText = 'Alınabilir!';
        break;
      case RewardUnlockStatus.inProgress:
        statusColor = Colors.orange;
        statusIcon = Icons.hourglass_empty;
        statusText = progress.statusMessage;
        break;
      case RewardUnlockStatus.locked:
        statusColor = Colors.red;
        statusIcon = Icons.lock;
        statusText = 'Kilitlede';
        break;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: statusColor.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: statusColor.withOpacity(0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(statusIcon, size: 12, color: statusColor),
          const SizedBox(width: 4),
          Text(
            statusText,
            style: TextStyle(
              color: statusColor,
              fontSize: 10,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDescription() {
    return Text(
      widget.rewardItem.description,
      style: Theme.of(context).textTheme.bodySmall?.copyWith(
            color: widget.isUnlocked
                ? Colors.white.withOpacity(0.85)
                : Colors.grey[600],
          ),
      maxLines: 2,
      overflow: TextOverflow.ellipsis,
    );
  }

  Widget _buildProgressSection(
      RewardUnlockProgress progress, Color rarityColor) {
    final progressColor = _getProgressColor(progress.status);

    return AnimatedContainer(
      duration: const Duration(milliseconds: 500),
      curve: Curves.easeOutCubic,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: (widget.isUnlocked
                ? Colors.black.withOpacity(0.1)
                : ThemeColors.getCardBackgroundLight(context))
            .withOpacity(0.5),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                progress.requirementDescription,
                style: TextStyle(
                  fontSize: 11,
                  color: widget.isUnlocked
                      ? Colors.white.withOpacity(0.8)
                      : Colors.grey[600],
                ),
              ),
              Text(
                '${progress.currentValue}/${progress.requiredValue}',
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.bold,
                  color: progressColor,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          ClipRRect(
            borderRadius: BorderRadius.circular(6),
            child: LinearProgressIndicator(
              value: progress.progressPercentage.clamp(0.0, 1.0),
              backgroundColor:
                  widget.isUnlocked ? Colors.white.withOpacity(0.2) : Colors.grey[300],
              valueColor: AlwaysStoppedAnimation<Color>(
                progress.status == RewardUnlockStatus.locked
                    ? Colors.grey[400]!
                    : progressColor,
              ),
              minHeight: 6,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButton(Color color) {
    String buttonText;
    VoidCallback onPressed;
    Color buttonColor;

    switch (widget.rewardItem.type) {
      case RewardItemType.avatar:
        buttonText = widget.isSelected ? 'Seçili' : 'Kullan';
        onPressed = widget.isSelected ? () {} : (widget.onUse ?? () {});
        buttonColor = widget.isSelected ? Colors.grey : color;
        break;
      case RewardItemType.theme:
        buttonText = widget.isSelected ? 'Aktif' : 'Uygula';
        onPressed = widget.isSelected ? () {} : (widget.onUse ?? () {});
        buttonColor = widget.isSelected ? Colors.grey : color;
        break;
      case RewardItemType.feature:
        buttonText = 'Etkinleştir';
        onPressed = widget.onUse ?? () {};
        buttonColor = color;
        break;
    }

    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: buttonColor,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(vertical: 12),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          elevation: widget.isUnlocked ? 4 : 0,
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(buttonText.contains('Seçili') || buttonText.contains('Aktif')
                ? Icons.check
                : Icons.play_arrow),
            const SizedBox(width: 8),
            Text(
              buttonText,
              style: const TextStyle(
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCompactContent(Color rarityColor) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(20),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: widget.isUnlocked
                ? _getGradientColors(rarityColor)
                : [Colors.transparent, Colors.transparent],
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: rarityColor.withOpacity(0.2),
                border: Border.all(color: rarityColor, width: 2),
              ),
              child: Center(
                child: Text(
                  widget.rewardItem.icon,
                  style: const TextStyle(fontSize: 24),
                ),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              widget.rewardItem.name,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.bold,
                color: widget.isUnlocked
                    ? Colors.white
                    : ThemeColors.getCardForeground(context),
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 4),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
              decoration: BoxDecoration(
                color: rarityColor,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                widget.rewardItem.rarityName,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 8,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Color _getRarityColor() {
    switch (widget.rewardItem.rarity) {
      case RewardItemRarity.common:
        return const Color(0xFF8B8B8B);
      case RewardItemRarity.rare:
        return const Color(0xFF4A90E2);
      case RewardItemRarity.epic:
        return const Color(0xFF9B59B6);
      case RewardItemRarity.legendary:
        return const Color(0xFFF39C12);
    }
  }

  List<Color> _getGradientColors(Color baseColor) {
    return [
      baseColor.withOpacity(0.3),
      baseColor.withOpacity(0.1),
      baseColor.withOpacity(0.05),
    ];
  }

  Color _getProgressColor(RewardUnlockStatus status) {
    switch (status) {
      case RewardUnlockStatus.unlocked:
        return Colors.green;
      case RewardUnlockStatus.available:
        return Colors.blue;
      case RewardUnlockStatus.inProgress:
        return Colors.orange;
      case RewardUnlockStatus.locked:
        return Colors.red;
    }
  }

  IconData _getTypeIcon() {
    switch (widget.rewardItem.type) {
      case RewardItemType.avatar:
        return Icons.person;
      case RewardItemType.theme:
        return Icons.palette;
      case RewardItemType.feature:
        return Icons.star;
    }
  }
}

/// Filter chip for reward filtering
class RewardFilterChip extends StatefulWidget {
  final String label;
  final IconData icon;
  final bool isSelected;
  final VoidCallback onTap;
  final Color? activeColor;

  const RewardFilterChip({
    super.key,
    required this.label,
    required this.icon,
    required this.isSelected,
    required this.onTap,
    this.activeColor,
  });

  @override
  State<RewardFilterChip> createState() => _RewardFilterChipState();
}

class _RewardFilterChipState extends State<RewardFilterChip>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 200),
      vsync: this,
    );
    _scaleAnimation = Tween<double>(begin: 1.0, end: 0.9).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
  }

  @override
  void didUpdateWidget(RewardFilterChip oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.isSelected != widget.isSelected) {
      if (widget.isSelected) {
        _controller.forward();
      } else {
        _controller.reverse();
      }
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final color = widget.activeColor ?? Theme.of(context).primaryColor;

    return AnimatedBuilder(
      animation: _scaleAnimation,
      builder: (context, child) {
        return Transform.scale(
          scale: _scaleAnimation.value,
          child: child,
        );
      },
      child: GestureDetector(
        onTap: () {
          _controller
            ..reset()
            ..forward();
          Future.delayed(const Duration(milliseconds: 100), () {
            _controller.reverse();
          });
          widget.onTap();
        },
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
          decoration: BoxDecoration(
            color: widget.isSelected
                ? color
                : (Theme.of(context).brightness == Brightness.dark
                    ? Colors.grey[800]
                    : Colors.grey[200]),
            borderRadius: BorderRadius.circular(20),
            border: widget.isSelected
                ? null
                : Border.all(
                    color: Theme.of(context).brightness == Brightness.dark
                        ? Colors.grey[700]!
                        : Colors.grey[300]!,
                  ),
            boxShadow: widget.isSelected
                ? [
                    BoxShadow(
                      color: color.withOpacity(0.4),
                      blurRadius: 10,
                      spreadRadius: 1,
                      offset: const Offset(0, 4),
                    ),
                  ]
                : null,
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                widget.icon,
                size: 16,
                color: widget.isSelected
                    ? Colors.white
                    : (Theme.of(context).brightness == Brightness.dark
                        ? Colors.white70
                        : Colors.grey[600]),
              ),
              const SizedBox(width: 6),
              Text(
                widget.label,
                style: TextStyle(
                  color: widget.isSelected
                      ? Colors.white
                      : (Theme.of(context).brightness == Brightness.dark
                          ? Colors.white
                          : Colors.grey[700]),
                  fontWeight:
                      widget.isSelected ? FontWeight.bold : FontWeight.normal,
                  fontSize: 13,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Point wallet display widget
class PointWalletCard extends StatelessWidget {
  final int points;
  final int streakDays;
  final VoidCallback? onTap;

  const PointWalletCard({
    super.key,
    required this.points,
    this.streakDays = 0,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          gradient: const LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Color(0xFFFFD700),
              Color(0xFFFFA500),
            ],
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.amber.withOpacity(0.4),
              blurRadius: 20,
              spreadRadius: 3,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            color: Colors.black.withOpacity(0.1),
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.white.withOpacity(0.2),
                ),
                child: const Icon(
                  Icons.diamond,
                  color: Colors.white,
                  size: 28,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Karbon Puanı',
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.9),
                        fontSize: 14,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(
                          _formatNumber(points),
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 32,
                            fontWeight: FontWeight.bold,
                            height: 1,
                          ),
                        ),
                        const SizedBox(width: 6),
                        Padding(
                          padding: const EdgeInsets.only(bottom: 4),
                          child: Text(
                            'KP',
                            style: TextStyle(
                              color: Colors.white.withOpacity(0.8),
                              fontSize: 16,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              if (streakDays > 0)
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(
                        Icons.local_fire_department,
                        color: Colors.white,
                        size: 20,
                      ),
                      const SizedBox(width: 6),
                      Text(
                        '$streakDays gün',
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  String _formatNumber(int number) {
    if (number >= 1000000) {
      return '${(number / 1000000).toStringAsFixed(1)}M';
    } else if (number >= 1000) {
      return '${(number / 1000).toStringAsFixed(1)}K';
    }
    return number.toString();
  }
}

/// Empty state widget for rewards
class RewardEmptyState extends StatelessWidget {
  final String title;
  final String subtitle;
  final IconData icon;

  const RewardEmptyState({
    super.key,
    required this.title,
    required this.subtitle,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.grey[200],
            ),
            child: Icon(
              icon,
              size: 64,
              color: Colors.grey[400],
            ),
          ),
          const SizedBox(height: 20),
          Text(
            title,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: Colors.grey[700],
            ),
          ),
          const SizedBox(height: 8),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 32),
            child: Text(
              subtitle,
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[500],
              ),
              textAlign: TextAlign.center,
            ),
          ),
        ],
      ),
    );
  }
}

/// Shimmer loading effect for reward cards
class RewardCardShimmer extends StatelessWidget {
  const RewardCardShimmer({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: ThemeColors.getCardBackground(context),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 56,
                height: 56,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.grey[300],
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      width: double.infinity,
                      height: 16,
                      decoration: BoxDecoration(
                        color: Colors.grey[300],
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Container(
                      width: 100,
                      height: 12,
                      decoration: BoxDecoration(
                        color: Colors.grey[300],
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Container(
            width: double.infinity,
            height: 12,
            decoration: BoxDecoration(
              color: Colors.grey[300],
              borderRadius: BorderRadius.circular(4),
            ),
          ),
          const SizedBox(height: 8),
          Container(
            width: 150,
            height: 12,
            decoration: BoxDecoration(
              color: Colors.grey[300],
              borderRadius: BorderRadius.circular(4),
            ),
          ),
        ],
      ),
    );
  }
}

/// Legacy RewardCard for backward compatibility
class RewardCard extends StatelessWidget {
  final RewardItem rewardItem;
  final bool isUnlocked;
  final bool isSelected;
  final VoidCallback? onTap;
  final VoidCallback? onUse;
  final UserProgress? userProgress;

  const RewardCard({
    super.key,
    required this.rewardItem,
    this.isUnlocked = false,
    this.isSelected = false,
    this.onTap,
    this.onUse,
    this.userProgress,
  });

  @override
  Widget build(BuildContext context) {
    return ModernRewardCard(
      rewardItem: rewardItem,
      isUnlocked: isUnlocked,
      isSelected: isSelected,
      onTap: onTap,
      onUse: onUse,
      userProgress: userProgress,
    );
  }
}

/// Reward inventory summary widget
class RewardInventorySummary extends StatelessWidget {
  final int totalAvatars;
  final int totalThemes;
  final int totalFeatures;
  final int unlockedAvatars;
  final int unlockedThemes;
  final int unlockedFeatures;

  const RewardInventorySummary({
    super.key,
    required this.totalAvatars,
    required this.totalThemes,
    required this.totalFeatures,
    required this.unlockedAvatars,
    required this.unlockedThemes,
    required this.unlockedFeatures,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.all(16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Ödül Envanteri',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: _buildStatCard(
                    context,
                    'Avatarlar',
                    unlockedAvatars,
                    totalAvatars,
                    Icons.person,
                    Colors.blue,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildStatCard(
                    context,
                    'Temalar',
                    unlockedThemes,
                    totalThemes,
                    Icons.palette,
                    Colors.purple,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildStatCard(
                    context,
                    'Özellikler',
                    unlockedFeatures,
                    totalFeatures,
                    Icons.star,
                    Colors.orange,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatCard(
    BuildContext context,
    String label,
    int unlocked,
    int total,
    IconData icon,
    Color color,
  ) {
    final percentage = total > 0 ? (unlocked / total) : 0.0;
    
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: color.withOpacity(0.3),
          width: 1,
        ),
      ),
      child: Column(
        children: [
          Icon(
            icon,
            color: color,
            size: 24,
          ),
          const SizedBox(height: 8),
          Text(
            '$unlocked/$total',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: color,
                ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: Colors.grey[600],
                ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),
          LinearProgressIndicator(
            value: percentage,
            backgroundColor: Colors.grey[300],
            valueColor: AlwaysStoppedAnimation<Color>(color),
            minHeight: 4,
          ),
        ],
      ),
    );
  }
}

/// Reward list widget
class RewardList extends StatelessWidget {
  final List<RewardItem> rewardItems;
  final RewardItemType? filterType;
  final Function(RewardItem)? onRewardTap;
  final Function(RewardItem)? onRewardUse;

  const RewardList({
    super.key,
    required this.rewardItems,
    this.filterType,
    this.onRewardTap,
    this.onRewardUse,
  });

  @override
  Widget build(BuildContext context) {
    final filteredItems = filterType != null
        ? rewardItems.where((item) => item.type == filterType).toList()
        : rewardItems;

    if (filteredItems.isEmpty) {
      return RewardEmptyState(
        title: 'Ödül bulunamadı',
        subtitle: 'Bu kategoride ödül yok',
        icon: Icons.card_giftcard,
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.symmetric(vertical: 8),
      itemCount: filteredItems.length,
      itemBuilder: (context, index) {
        final reward = filteredItems[index];
        return ModernRewardCard(
          rewardItem: reward,
          isUnlocked: reward.isUnlocked,
          onTap: () => onRewardTap?.call(reward),
          onUse: () => onRewardUse?.call(reward),
        );
      },
    );
  }
}

/// Reward type filter
class RewardTypeFilter extends StatelessWidget {
  final RewardItemType? selectedType;
  final Function(RewardItemType?) onTypeSelected;

  const RewardTypeFilter({
    super.key,
    this.selectedType,
    required this.onTypeSelected,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 60,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: ListView(
        scrollDirection: Axis.horizontal,
        children: [
          _buildTypeChip(
            context,
            null,
            'Tümü',
            Icons.all_inclusive,
          ),
          const SizedBox(width: 8),
          _buildTypeChip(
            context,
            RewardItemType.avatar,
            'Avatar',
            Icons.person,
          ),
          const SizedBox(width: 8),
          _buildTypeChip(
            context,
            RewardItemType.theme,
            'Tema',
            Icons.palette,
          ),
          const SizedBox(width: 8),
          _buildTypeChip(
            context,
            RewardItemType.feature,
            'Özellik',
            Icons.star,
          ),
        ],
      ),
    );
  }

  Widget _buildTypeChip(
    BuildContext context,
    RewardItemType? type,
    String label,
    IconData icon,
  ) {
    final isSelected = selectedType == type;
    
    return RewardFilterChip(
      label: label,
      icon: icon,
      isSelected: isSelected,
      onTap: () {
        onTypeSelected(isSelected ? null : type);
      },
    );
  }
}

