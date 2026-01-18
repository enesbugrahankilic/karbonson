import 'package:flutter/material.dart';
import '../theme/theme_colors.dart';
import '../theme/design_system.dart';
import '../theme/app_theme.dart';
import '../theme/modern_ui_components.dart';
import '../theme/responsive_design.dart';
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
            child: ModernUI.animatedCard(
              context,
              animation: _fadeAnimation,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Enhanced Question section with gradient background
                  _buildQuestionSection(context),
                  SizedBox(height: ResponsiveDesign.getResponsiveSpacing(context, BaseSpacing.xl)),

                  // Modern Answer options with staggered animation
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
    // Get responsive values
    final screenType = ResponsiveDesign.getScreenType(context);
    final padding = ResponsiveDesign.getResponsiveSpacing(context, BaseSpacing.xl);
    final spacingM = ResponsiveDesign.getResponsiveSpacing(context, BaseSpacing.m);
    final spacingL = ResponsiveDesign.getResponsiveSpacing(context, BaseSpacing.l);
    final iconSize = _getResponsiveIconSize(screenType) * 1.2;
    final fontSize = _getResponsiveQuestionFontSize(screenType);

    return Container(
      padding: EdgeInsets.all(padding),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            ThemeColors.getPrimaryButtonColor(context).withValues(alpha:0.08),
            ThemeColors.getPrimaryButtonColor(context).withValues(alpha: 0.03),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(DesignSystem.radiusL),
        border: Border.all(
          color: ThemeColors.getPrimaryButtonColor(context).withValues(alpha: 0.15),
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: ThemeColors.getPrimaryButtonColor(context).withValues(alpha: 0.08),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
          BoxShadow(
            color: Colors.white.withValues(alpha: 0.1),
            blurRadius: 8,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: Column(
         mainAxisSize: MainAxisSize.min,
         children: [
           // Zorluk Seviyesi İndikatörü
           if (widget.difficulty != null) _buildDifficultyIndicator(context),

           SizedBox(height: spacingM),
           Icon(
             Icons.help_outline,
             color: ThemeColors.getPrimaryButtonColor(context),
             size: iconSize,
           ),
           SizedBox(height: spacingL),
           Text(
             widget.question,
             style: AppTheme.getGameQuestionStyle(context).copyWith(
               fontSize: fontSize,
               fontWeight: FontWeight.w600,
             ),
             textAlign: TextAlign.center,
             softWrap: true,
             maxLines: 10,
             overflow: TextOverflow.ellipsis,
           ),
           SizedBox(height: spacingM),
         ],
       ),
    );
  }

  Widget _buildDifficultyIndicator(BuildContext context) {
    final screenType = ResponsiveDesign.getScreenType(context);
    final indicatorSize = _getResponsiveIndicatorSize(screenType);
    final fontSize = _getResponsiveOptionFontSize(screenType);

    final difficultyConfig = _getDifficultyConfig(widget.difficulty!);

    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: ResponsiveDesign.getResponsiveSpacing(context, BaseSpacing.l),
        vertical: ResponsiveDesign.getResponsiveSpacing(context, BaseSpacing.s),
      ),
      decoration: BoxDecoration(
        color: difficultyConfig['color'] as Color,
        borderRadius: BorderRadius.circular(DesignSystem.radiusM),
        boxShadow: [
          BoxShadow(
            color: difficultyConfig['color'] as Color,
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
            size: indicatorSize * 0.7,
          ),
          SizedBox(width: ResponsiveDesign.getResponsiveSpacing(context, BaseSpacing.s)),
          Text(
            difficultyConfig['name'] as String,
            style: AppTheme.getGameOptionStyle(context).copyWith(
              color: Colors.white,
              fontSize: fontSize,
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

  double _getResponsiveIconSize(ScreenType screenType) {
    switch (screenType) {
      case ScreenType.mobile:
        return 28;
      case ScreenType.tablet:
        return 32;
      case ScreenType.desktop:
        return 36;
    }
  }

  double _getResponsiveQuestionFontSize(ScreenType screenType) {
    switch (screenType) {
      case ScreenType.mobile:
        return 22;
      case ScreenType.tablet:
        return 24;
      case ScreenType.desktop:
        return 26;
    }
  }

  Widget _buildOptionsSection(BuildContext context) {
    // Get responsive values
    final screenType = ResponsiveDesign.getScreenType(context);
    final spacingM = ResponsiveDesign.getResponsiveSpacing(context, BaseSpacing.m);
    final spacingL = ResponsiveDesign.getResponsiveSpacing(context, BaseSpacing.l);
    final verticalSpacing = spacingM; // Better spacing between options

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        SizedBox(height: spacingL),
        ...widget.options.asMap().entries.map((entry) {
          final index = entry.key;
          final option = entry.value;

          return TweenAnimationBuilder<double>(
            tween: Tween(begin: 0.0, end: 1.0),
            duration: Duration(milliseconds: _getAnimationDuration(screenType)),
            curve: Curves.easeOutBack,
            builder: (context, value, child) {
              return Transform.scale(
                scale: value,
                child: Padding(
                  padding: EdgeInsets.symmetric(
                    vertical: verticalSpacing, // Better vertical spacing
                  ),
                  child: _buildOptionButton(option, context, index),
                ),
              );
            },
          );
        }).toList(),
        SizedBox(height: spacingL),
      ],
    );
  }

  int _getAnimationDuration(ScreenType screenType) {
    switch (screenType) {
      case ScreenType.mobile:
        return 350;
      case ScreenType.tablet:
        return 400;
      case ScreenType.desktop:
        return 450;
    }
  }

  Widget _buildOptionButton(String option, BuildContext context, int index) {
    // Get responsive values
    final screenType = ResponsiveDesign.getScreenType(context);
    final spacingM = ResponsiveDesign.getResponsiveSpacing(context, BaseSpacing.m);
    final indicatorSize = _getResponsiveIndicatorSize(screenType);
    final iconSize = _getResponsiveIconSize(screenType);
    final fontSize = _getResponsiveOptionFontSize(screenType);
    final padding = _getResponsiveOptionPadding(screenType);
    
    return AnimatedContainer(
      duration: Duration(milliseconds: _getButtonAnimationDuration(screenType)),
      curve: Curves.easeInOut,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap:
              widget.isAnswered ? null : () => widget.onOptionSelected(option),
          borderRadius: BorderRadius.circular(DesignSystem.radiusM),
          child: Container(
            padding: padding, // Responsive padding for better text display
            decoration: _getOptionDecoration(option, context),
            child: Row(
              children: [
                // Option indicator with modern styling
                Container(
                  width: indicatorSize,
                  height: indicatorSize,
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
                SizedBox(width: spacingM),

                // Option text with enhanced styling
                Expanded(
                  child: Text(
                    option,
                    style: _getOptionTextStyle(option, context, fontSize),
                    textAlign: TextAlign.left,
                    softWrap: true,
                    maxLines: 5, // Limit lines to prevent overflow
                    overflow: TextOverflow.ellipsis, // Show ellipsis for long text
                  ),
                ),

                // Modern selection indicator
                if (widget.isAnswered && option == widget.correctAnswer)
                  Icon(
                    Icons.check_circle,
                    color: Colors.white,
                    size: iconSize,
                  )
                else if (widget.isAnswered &&
                    option == widget.selectedAnswer &&
                    widget.selectedAnswer != widget.correctAnswer)
                  Icon(
                    Icons.cancel,
                    color: Colors.white,
                    size: iconSize,
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  double _getResponsiveIndicatorSize(ScreenType screenType) {
    switch (screenType) {
      case ScreenType.mobile:
        return 28;
      case ScreenType.tablet:
        return 32;
      case ScreenType.desktop:
        return 36;
    }
  }

  double _getResponsiveOptionFontSize(ScreenType screenType) {
    switch (screenType) {
      case ScreenType.mobile:
        return 18;
      case ScreenType.tablet:
        return 20;
      case ScreenType.desktop:
        return 22;
    }
  }

  EdgeInsets _getResponsiveOptionPadding(ScreenType screenType) {
    switch (screenType) {
      case ScreenType.mobile:
        return EdgeInsets.all(DesignSystem.spacingL);
      case ScreenType.tablet:
        return EdgeInsets.all(DesignSystem.spacingL * 1.2);
      case ScreenType.desktop:
        return EdgeInsets.symmetric(
          horizontal: DesignSystem.spacingL * 1.2,
          vertical: DesignSystem.spacingM * 1.5,
        );
    }
  }

  int _getButtonAnimationDuration(ScreenType screenType) {
    switch (screenType) {
      case ScreenType.mobile:
        return 150;
      case ScreenType.tablet:
        return 200;
      case ScreenType.desktop:
        return 250;
    }
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
            ThemeColors.getSuccessColor(context).withValues(alpha: 0.8),
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
            color: ThemeColors.getSuccessColor(context).withValues(alpha: 0.3),
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
            ThemeColors.getErrorColor(context).withValues(alpha: 0.8),
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
            color: ThemeColors.getErrorColor(context).withValues(alpha: 0.3),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      );
    }

    // Other incorrect options - dimmed state
    return BoxDecoration(
      color: ThemeColors.getCardBackgroundLight(context).withValues(alpha: 0.6),
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
      return const Icon(
        Icons.check,
        color: Colors.white,
        size: 16,
      );
    }

    if (option == widget.selectedAnswer &&
        widget.selectedAnswer != widget.correctAnswer) {
      return const Icon(
        Icons.close,
        color: Colors.white,
        size: 16,
      );
    }

    return Center(
      child: Container(
        width: 8,
        height: 8,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: ThemeColors.getSecondaryText(context).withValues(alpha: 0.5),
        ),
      ),
    );
  }

  TextStyle _getOptionTextStyle(String option, BuildContext context, double fontSize) {
    final baseStyle = AppTheme.getGameOptionStyle(context).copyWith(
      fontSize: fontSize,
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
