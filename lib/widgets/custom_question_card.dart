import 'package:flutter/material.dart';
import '../theme/theme_colors.dart';
import '../theme/design_system.dart';
import '../theme/app_theme.dart';
import '../models/question.dart';

class CustomQuestionCard extends StatefulWidget {
  final String question;
  final List<String> options;
  final Function(String) onOptionSelected;
  final bool isAnswered;
  final String selectedAnswer;
  final String correctAnswer;
  final DifficultyLevel? difficulty;

  const CustomQuestionCard({
    super.key,
    required this.question,
    required this.options,
    required this.onOptionSelected,
    required this.isAnswered,
    required this.selectedAnswer,
    required this.correctAnswer,
    this.difficulty,
  });

  @override
  State<CustomQuestionCard> createState() => _CustomQuestionCardState();
}

class _CustomQuestionCardState extends State<CustomQuestionCard>
    with TickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _slideAnimation;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );

    _slideAnimation = Tween<double>(
      begin: 50.0,
      end: 0.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeOutCubic,
    ));

    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeIn,
    ));

    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _animationController,
      builder: (context, child) {
        return Transform.translate(
          offset: Offset(0, _slideAnimation.value),
          child: Opacity(
            opacity: _fadeAnimation.value,
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    ThemeColors.getGlassBackground(context),
                    ThemeColors.getGlassBackground(context).withOpacity(0.95),
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(DesignSystem.radiusL),
                border: Border.all(
                  color: Theme.of(context).brightness == Brightness.dark
                      ? Colors.white.withOpacity(0.1)
                      : Colors.white.withOpacity(0.3),
                  width: 1,
                ),
                boxShadow: [
                  BoxShadow(
                    color: ThemeColors.getPrimaryButtonColor(context).withOpacity(0.1),
                    blurRadius: 16,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  _buildQuestionSection(context),
                  Container(
                    margin: const EdgeInsets.symmetric(horizontal: DesignSystem.spacingL),
                    height: 1,
                    color: ThemeColors.getBorder(context).withOpacity(0.2),
                  ),
                  _buildOptionsSection(context),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildQuestionSection(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(DesignSystem.spacingXl),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            ThemeColors.getPrimaryButtonColor(context).withOpacity(0.08),
            ThemeColors.getPrimaryButtonColor(context).withOpacity(0.03),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(DesignSystem.radiusL),
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (widget.difficulty != null) _buildDifficultyIndicator(context),
          const SizedBox(height: DesignSystem.spacingL),
          Icon(
            Icons.help_outline,
            color: ThemeColors.getPrimaryButtonColor(context),
            size: 40,
          ),
          const SizedBox(height: DesignSystem.spacingL),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(
              horizontal: DesignSystem.spacingM,
              vertical: DesignSystem.spacingS,
            ),
            child: Text(
              widget.question,
              style: AppTheme.getGameQuestionStyle(context).copyWith(
                fontSize: 20,
                fontWeight: FontWeight.w600,
                height: 1.4,
              ),
              textAlign: TextAlign.center,
              softWrap: true,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDifficultyIndicator(BuildContext context) {
    final difficultyConfig = _getDifficultyConfig(widget.difficulty!);

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: DesignSystem.spacingL,
        vertical: DesignSystem.spacingM,
      ),
      decoration: BoxDecoration(
        color: difficultyConfig['color'] as Color,
        borderRadius: BorderRadius.circular(DesignSystem.radiusM),
        boxShadow: [
          BoxShadow(
            color: (difficultyConfig['color'] as Color).withOpacity(0.4),
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            difficultyConfig['icon'] as IconData,
            color: Colors.white,
            size: 24,
          ),
          const SizedBox(width: DesignSystem.spacingM),
          Text(
            difficultyConfig['name'] as String,
            style: AppTheme.getGameOptionStyle(context).copyWith(
              color: Colors.white,
              fontSize: 16,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Map<String, dynamic> _getDifficultyConfig(DifficultyLevel difficulty) {
    switch (difficulty) {
      case DifficultyLevel.easy:
        return {
          'name': 'Kolay',
          'color': Colors.green.shade400,
          'icon': Icons.sentiment_very_satisfied,
        };
      case DifficultyLevel.medium:
        return {
          'name': 'Orta',
          'color': Colors.orange.shade400,
          'icon': Icons.sentiment_neutral,
        };
      case DifficultyLevel.hard:
        return {
          'name': 'Zor',
          'color': Colors.red.shade400,
          'icon': Icons.sentiment_very_dissatisfied,
        };
      default:
        return {
          'name': 'Bilinmiyor',
          'color': Colors.grey.shade400,
          'icon': Icons.help,
        };
    }
  }

  Widget _buildOptionsSection(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(DesignSystem.spacingL),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: widget.options.asMap().entries.map((entry) {
          final index = entry.key;
          final option = entry.value;

          return TweenAnimationBuilder<double>(
            tween: Tween(begin: 0.0, end: 1.0),
            duration: Duration(milliseconds: 300 + (index * 50)),
            curve: Curves.easeOutBack,
            builder: (context, value, child) {
              return Transform.scale(
                scale: value,
                child: Padding(
                  padding: const EdgeInsets.only(bottom: DesignSystem.spacingL),
                  child: _buildOptionButton(option, context, index),
                ),
              );
            },
          );
        }).toList(),
      ),
    );
  }

  Widget _buildOptionButton(String option, BuildContext context, int index) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 150),
      curve: Curves.easeInOut,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: widget.isAnswered ? null : () => widget.onOptionSelected(option),
          borderRadius: BorderRadius.circular(DesignSystem.radiusM),
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(
              horizontal: DesignSystem.spacingXl,
              vertical: DesignSystem.spacingL,
            ),
            decoration: _getOptionDecoration(option, context),
            child: Row(
              children: [
                Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: _getIndicatorColor(option, context),
                    border: Border.all(
                      color: _getIndicatorBorderColor(option, context),
                      width: 2,
                    ),
                  ),
                  child: _buildOptionIndicator(option, context),
                ),
                const SizedBox(width: DesignSystem.spacingM),
                Expanded(
                  child: Text(
                    option,
                    style: _getOptionTextStyle(option, context),
                    textAlign: TextAlign.left,
                    softWrap: true,
                  ),
                ),
                if (widget.isAnswered && option == widget.correctAnswer)
                  Icon(Icons.check_circle, color: Colors.white, size: 24)
                else if (widget.isAnswered &&
                    option == widget.selectedAnswer &&
                    widget.selectedAnswer != widget.correctAnswer)
                  Icon(Icons.cancel, color: Colors.white, size: 24),
              ],
            ),
          ),
        ),
      ),
    );
  }

  BoxDecoration _getOptionDecoration(String option, BuildContext context) {
    if (!widget.isAnswered) {
      return BoxDecoration(
        color: ThemeColors.getCardBackground(context),
        borderRadius: BorderRadius.circular(DesignSystem.radiusM),
        border: Border.all(
          color: ThemeColors.getBorder(context),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: ThemeColors.getShadow(context),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      );
    }

    if (option == widget.correctAnswer) {
      return BoxDecoration(
        gradient: LinearGradient(
          colors: [
            ThemeColors.getSuccessColor(context),
            ThemeColors.getSuccessColor(context).withOpacity(0.8),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(DesignSystem.radiusM),
        border: Border.all(
          color: ThemeColors.getSuccessColor(context),
          width: 2,
        ),
        boxShadow: [
          BoxShadow(
            color: ThemeColors.getSuccessColor(context).withOpacity(0.3),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      );
    }

    if (option == widget.selectedAnswer &&
        widget.selectedAnswer != widget.correctAnswer) {
      return BoxDecoration(
        gradient: LinearGradient(
          colors: [
            ThemeColors.getErrorColor(context),
            ThemeColors.getErrorColor(context).withOpacity(0.8),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(DesignSystem.radiusM),
        border: Border.all(
          color: ThemeColors.getErrorColor(context),
          width: 2,
        ),
        boxShadow: [
          BoxShadow(
            color: ThemeColors.getErrorColor(context).withOpacity(0.3),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      );
    }

    return BoxDecoration(
      color: ThemeColors.getCardBackgroundLight(context).withOpacity(0.6),
      borderRadius: BorderRadius.circular(DesignSystem.radiusM),
      border: Border.all(
        color: ThemeColors.getBorder(context),
        width: 1,
      ),
    );
  }

  Color _getIndicatorColor(String option, BuildContext context) {
    if (!widget.isAnswered) {
      return ThemeColors.getCardBackground(context);
    }

    if (option == widget.correctAnswer) {
      return Colors.white;
    }

    if (option == widget.selectedAnswer &&
        widget.selectedAnswer != widget.correctAnswer) {
      return Colors.white;
    }

    return ThemeColors.getCardBackgroundLight(context);
  }

  Color _getIndicatorBorderColor(String option, BuildContext context) {
    if (!widget.isAnswered) {
      return ThemeColors.getBorder(context);
    }

    if (option == widget.correctAnswer ||
        (option == widget.selectedAnswer &&
            widget.selectedAnswer != widget.correctAnswer)) {
      return Colors.transparent;
    }

    return ThemeColors.getBorder(context);
  }

  Widget _buildOptionIndicator(String option, BuildContext context) {
    if (!widget.isAnswered) {
      return Center(
        child: Container(
          width: 8,
          height: 8,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: ThemeColors.getSecondaryText(context),
          ),
        ),
      );
    }

    if (option == widget.correctAnswer) {
      return const Icon(Icons.check, color: Colors.white, size: 18);
    }

    if (option == widget.selectedAnswer &&
        widget.selectedAnswer != widget.correctAnswer) {
      return const Icon(Icons.close, color: Colors.white, size: 18);
    }

    return Center(
      child: Container(
        width: 8,
        height: 8,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: ThemeColors.getSecondaryText(context).withOpacity(0.5),
        ),
      ),
    );
  }

  TextStyle _getOptionTextStyle(String option, BuildContext context) {
    final baseStyle = AppTheme.getGameOptionStyle(context).copyWith(
      fontSize: 16,
      height: 1.3,
    );

    if (!widget.isAnswered) {
      return baseStyle;
    }

    if (option == widget.correctAnswer ||
        (option == widget.selectedAnswer &&
            widget.selectedAnswer != widget.correctAnswer)) {
      return baseStyle.copyWith(
        color: Colors.white,
        fontWeight: FontWeight.w600,
      );
    }

    return baseStyle.copyWith(
      color: ThemeColors.getSecondaryText(context),
    );
  }
}

