// lib/widgets/quiz_card.dart
// Quiz Card Component - Reusable card for quiz selections

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../theme/quiz_design_system.dart';
import '../theme/theme_colors.dart';

/// QuizCard - A reusable card component for quiz selections
/// Supports selection state, icons, colors, and animations
///
/// Usage:
/// ```dart
/// QuizCard(
///   isSelected: true,
///   color: Colors.green,
///   icon: Icons.star,
///   title: 'Kolay',
///   subtitle: 'Temel çevre bilgisi',
///   trailing: Text('1x Puan'),
///   onTap: () => setState(() => _selected = 'easy'),
/// )
/// ```
class QuizCard extends StatefulWidget {
  final bool isSelected;
  final Color color;
  final IconData icon;
  final String title;
  final String subtitle;
  final Widget? trailing;
  final VoidCallback onTap;
  final EdgeInsets padding;
  final bool showShadow;

  const QuizCard({
    super.key,
    required this.isSelected,
    required this.color,
    required this.icon,
    required this.title,
    required this.subtitle,
    this.trailing,
    required this.onTap,
    this.padding = const EdgeInsets.all(QuizDesignSystem.spacingL),
    this.showShadow = true,
  });

  @override
  State<QuizCard> createState() => _QuizCardState();
}

class _QuizCardState extends State<QuizCard> with TickerProviderStateMixin {
  late AnimationController _scaleController;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _scaleController = AnimationController(
      duration: QuizDesignSystem.animationMedium,
      vsync: this,
    );
    _scaleAnimation = Tween<double>(begin: 1.0, end: 0.98).animate(
      CurvedAnimation(parent: _scaleController, curve: Curves.easeOut),
    );
  }

  @override
  void didUpdateWidget(QuizCard oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.isSelected != widget.isSelected) {
      if (widget.isSelected) {
        _scaleController.forward();
      } else {
        _scaleController.reverse();
      }
    }
  }

  @override
  void dispose() {
    _scaleController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _scaleAnimation,
      builder: (context, child) {
        return Transform.scale(
          scale: _scaleAnimation.value,
          child: child,
        );
      },
      child: _buildCard(),
    );
  }

  Widget _buildCard() {
    return GestureDetector(
      onTap: () {
        HapticFeedback.lightImpact();
        widget.onTap();
      },
      child: Semantics(
        label: '${widget.title} seçimi',
        hint: widget.subtitle,
        button: true,
        child: Container(
          padding: widget.padding,
          decoration: widget.isSelected
              ? QuizDesignSystem.getSelectedCardDecoration(
                  context,
                  color: widget.color,
                )
              : QuizDesignSystem.getUnselectedCardDecoration(context),
          child: Row(
            children: [
              _buildIcon(),
              const SizedBox(width: QuizDesignSystem.spacingL),
              Expanded(child: _buildContent()),
              if (widget.trailing != null) ...[
                const SizedBox(width: QuizDesignSystem.spacingM),
                widget.trailing!,
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildIcon() {
    return Container(
      padding: const EdgeInsets.all(QuizDesignSystem.iconContainerPadding),
      decoration: BoxDecoration(
        color: widget.isSelected
            ? Colors.white.withValues(alpha: 0.25)
            : widget.color.withValues(alpha: 0.2),
        shape: BoxShape.circle,
      ),
      child: Icon(
        widget.icon,
        color: widget.isSelected ? Colors.white : widget.color,
        size: QuizDesignSystem.iconSizeLarge,
      ),
    );
  }

  Widget _buildContent() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          widget.title,
          style: TextStyle(
            color: widget.isSelected ? Colors.white : null,
            fontWeight: FontWeight.bold,
            fontSize: 18,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          widget.subtitle,
          style: TextStyle(
            color: widget.isSelected
                ? Colors.white.withValues(alpha: 0.9)
                : null,
            fontSize: 13,
          ),
        ),
      ],
    );
  }
}

// ===========================================================================
// HORIZONTAL QUIZ CARD
// ===========================================================================

/// HorizontalQuizCard - A compact card for horizontal scrolling lists
/// Used for category selection with icon, name, and question count
class HorizontalQuizCard extends StatefulWidget {
  final bool isSelected;
  final Color color;
  final IconData icon;
  final String title;
  final int questionCount;
  final VoidCallback onTap;

  const HorizontalQuizCard({
    super.key,
    required this.isSelected,
    required this.color,
    required this.icon,
    required this.title,
    required this.questionCount,
    required this.onTap,
  });

  @override
  State<HorizontalQuizCard> createState() => _HorizontalQuizCardState();
}

class _HorizontalQuizCardState extends State<HorizontalQuizCard> {
  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isTablet = screenWidth > 600;
    final width = isTablet ? 140.0 : 120.0;

    return Semantics(
      label: '${widget.title} kategorisi',
      hint: '${widget.questionCount} soru',
      button: true,
      child: GestureDetector(
        onTap: () {
          HapticFeedback.lightImpact();
          widget.onTap();
        },
        child: AnimatedContainer(
          duration: QuizDesignSystem.animationMedium,
          width: width,
          margin: const EdgeInsets.only(right: QuizDesignSystem.spacingM),
          decoration: widget.isSelected
              ? QuizDesignSystem.getSelectedCardDecoration(
                  context,
                  color: widget.color,
                )
              : QuizDesignSystem.getUnselectedCardDecoration(context),
          child: Padding(
            padding: const EdgeInsets.all(QuizDesignSystem.spacingM),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: widget.isSelected
                        ? Colors.white.withValues(alpha: 0.25)
                        : widget.color.withValues(alpha: 0.2),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    widget.icon,
                    color: widget.isSelected ? Colors.white : widget.color,
                    size: 28,
                  ),
                ),
                const SizedBox(height: QuizDesignSystem.spacingS),
                Expanded(
                  child: Text(
                    widget.title,
                    style: TextStyle(
                      color: widget.isSelected ? Colors.white : null,
                      fontWeight: FontWeight.bold,
                      fontSize: 13,
                    ),
                    textAlign: TextAlign.center,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '$widget.questionCount soru',
                  style: TextStyle(
                    color: widget.isSelected
                        ? Colors.white.withValues(alpha: 0.8)
                        : Colors.white60,
                    fontSize: 11,
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// ===========================================================================
// RADIO QUIZ CARD
// ===========================================================================

/// RadioQuizCard - A card with radio button for option selection
/// Used for question count, difficulty, and language selection
class RadioQuizCard extends StatefulWidget {
  final bool isSelected;
  final Color color;
  final String value;
  final String label;
  final String? description;
  final String? timeInfo;
  final ValueChanged<String?>? onChanged;
  final String groupValue;

  const RadioQuizCard({
    super.key,
    required this.isSelected,
    required this.color,
    required this.value,
    required this.label,
    this.description,
    this.timeInfo,
    this.onChanged,
    required this.groupValue,
  });

  @override
  State<RadioQuizCard> createState() => _RadioQuizCardState();
}

class _RadioQuizCardState extends State<RadioQuizCard> {
  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: '${widget.value} seçimi',
      hint: '${widget.label} - ${widget.timeInfo ?? ""}',
      button: true,
      child: GestureDetector(
        onTap: () {
          if (widget.onChanged != null) {
            HapticFeedback.lightImpact();
            widget.onChanged!(widget.value);
          }
        },
        child: AnimatedContainer(
          duration: QuizDesignSystem.animationMedium,
          margin: const EdgeInsets.only(bottom: QuizDesignSystem.spacingM),
          decoration: widget.isSelected
              ? QuizDesignSystem.getSelectedCardDecoration(
                  context,
                  color: widget.color,
                )
              : QuizDesignSystem.getUnselectedCardDecoration(context),
          child: Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: QuizDesignSystem.spacingL,
              vertical: QuizDesignSystem.spacingM,
            ),
            child: Row(
              children: [
                Radio<String>(
                  value: widget.value,
                  groupValue: widget.groupValue,
                  onChanged: widget.onChanged,
                  activeColor: Colors.white,
                  fillColor: WidgetStateProperty.resolveWith<Color>(
                    (states) {
                      return widget.isSelected ? Colors.white : widget.color;
                    },
                  ),
                ),
                const SizedBox(width: QuizDesignSystem.spacingM),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Text(
                            widget.value,
                            style: TextStyle(
                              color: widget.isSelected ? Colors.white : widget.color,
                              fontWeight: FontWeight.bold,
                              fontSize: 24,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Text(
                            widget.label,
                            style: TextStyle(
                              color: widget.isSelected ? Colors.white : null,
                              fontWeight: FontWeight.w500,
                              fontSize: 18,
                            ),
                          ),
                        ],
                      ),
                      if (widget.description != null) ...[
                        const SizedBox(height: 4),
                        Text(
                          widget.description!,
                          style: TextStyle(
                            color: widget.isSelected
                                ? Colors.white.withValues(alpha: 0.9)
                                : Colors.white70,
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
                if (widget.timeInfo != null) _buildTimeBadge(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTimeBadge() {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: QuizDesignSystem.spacingM,
        vertical: QuizDesignSystem.spacingS,
      ),
      decoration: BoxDecoration(
        color: widget.isSelected
            ? Colors.white.withValues(alpha: 0.2)
            : widget.color.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(QuizDesignSystem.radiusM),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.timer,
            color: widget.isSelected ? Colors.white : widget.color,
            size: 18,
          ),
          const SizedBox(width: 6),
          Text(
            widget.timeInfo!,
            style: TextStyle(
              color: widget.isSelected ? Colors.white : widget.color,
              fontWeight: FontWeight.w600,
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }
}

