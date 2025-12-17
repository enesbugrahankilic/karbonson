import 'package:flutter/material.dart';
import 'package:animations/animations.dart' show PageTransitionSwitcher, SharedAxisTransition, SharedAxisTransitionType;
import '../theme/theme_colors.dart';
import '../theme/design_system.dart';
import '../theme/app_theme.dart';
import '../theme/modern_ui_components.dart';

class CustomQuestionCard extends StatefulWidget {
  final String question;
  final List<String> options;
  final Function(String) onOptionSelected;
  final bool isAnswered;
  final String selectedAnswer;
  final String correctAnswer;

  const CustomQuestionCard({
    super.key,
    required this.question,
    required this.options,
    required this.onOptionSelected,
    required this.isAnswered,
    required this.selectedAnswer,
    required this.correctAnswer,
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
    return PageTransitionSwitcher(
      transitionBuilder: (
        Widget child,
        Animation<double> primaryAnimation,
        Animation<double> secondaryAnimation,
      ) {
        return SharedAxisTransition(
          animation: primaryAnimation,
          secondaryAnimation: secondaryAnimation,
          transitionType: SharedAxisTransitionType.horizontal,
          child: child,
        );
      },
      child: AnimatedBuilder(
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
                    const SizedBox(height: DesignSystem.spacingXl),
                    
                    // Modern Answer options with staggered animation
                    _buildOptionsSection(context),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildQuestionSection(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(DesignSystem.spacingL),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            ThemeColors.getPrimaryButtonColor(context).withOpacity(0.1),
            ThemeColors.getPrimaryButtonColor(context).withOpacity(0.05),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(DesignSystem.radiusL),
        border: Border.all(
          color: ThemeColors.getPrimaryButtonColor(context).withOpacity(0.2),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: ThemeColors.getPrimaryButtonColor(context).withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          Icon(
            Icons.help_outline,
            color: ThemeColors.getPrimaryButtonColor(context),
            size: 32,
          ),
          const SizedBox(height: DesignSystem.spacingM),
          Text(
            widget.question,
            style: AppTheme.getGameQuestionStyle(context).copyWith(
              fontSize: AppTheme.getAccessibleFontSize(context, 20),
              height: 1.4,
              fontWeight: FontWeight.w600,
            ),
            textAlign: TextAlign.center,
            maxLines: null,
          ),
        ],
      ),
    );
  }

  Widget _buildOptionsSection(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: widget.options.asMap().entries.map((entry) {
        final index = entry.key;
        final option = entry.value;
        final delay = Duration(milliseconds: 100 * index);
        
        return TweenAnimationBuilder<double>(
          tween: Tween(begin: 0.0, end: 1.0),
          duration: const Duration(milliseconds: 400),
          curve: Curves.easeOutBack,
          builder: (context, value, child) {
            return Transform.scale(
              scale: value,
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  vertical: DesignSystem.spacingS / 2,
                ),
                child: _buildOptionButton(option, context, index),
              ),
            );
          },
        );
      }).toList(),
    );
  }

  Widget _buildOptionButton(String option, BuildContext context, int index) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      curve: Curves.easeInOut,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: widget.isAnswered ? null : () => widget.onOptionSelected(option),
          borderRadius: BorderRadius.circular(DesignSystem.radiusM),
          child: Container(
            padding: const EdgeInsets.all(DesignSystem.spacingM),
            decoration: _getOptionDecoration(option, context),
            child: Row(
              children: [
                // Option indicator with modern styling
                Container(
                  width: 32,
                  height: 32,
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
                
                // Option text with enhanced styling
                Expanded(
                  child: Text(
                    option,
                    style: _getOptionTextStyle(option, context),
                    textAlign: TextAlign.left,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                
                // Modern selection indicator
                if (widget.isAnswered && option == widget.correctAnswer)
                  Icon(
                    Icons.check_circle,
                    color: Colors.white,
                    size: 20,
                  )
                else if (widget.isAnswered && option == widget.selectedAnswer && widget.selectedAnswer != widget.correctAnswer)
                  Icon(
                    Icons.cancel,
                    color: Colors.white,
                    size: 20,
                  ),
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

    if (option == widget.selectedAnswer && widget.selectedAnswer != widget.correctAnswer) {
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

    // Other incorrect options - dimmed state
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

    if (option == widget.selectedAnswer && widget.selectedAnswer != widget.correctAnswer) {
      return Colors.white;
    }

    return ThemeColors.getCardBackgroundLight(context);
  }

  Color _getIndicatorBorderColor(String option, BuildContext context) {
    if (!widget.isAnswered) {
      return ThemeColors.getBorder(context);
    }

    if (option == widget.correctAnswer || 
        (option == widget.selectedAnswer && widget.selectedAnswer != widget.correctAnswer)) {
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

    if (option == widget.selectedAnswer && widget.selectedAnswer != widget.correctAnswer) {
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
          color: ThemeColors.getSecondaryText(context).withOpacity(0.5),
        ),
      ),
    );
  }

  TextStyle _getOptionTextStyle(String option, BuildContext context) {
    final baseStyle = AppTheme.getGameOptionStyle(context).copyWith(
      fontSize: AppTheme.getAccessibleFontSize(context, 16),
      height: 1.3,
    );

    if (!widget.isAnswered) {
      return baseStyle;
    }

    if (option == widget.correctAnswer || 
        (option == widget.selectedAnswer && widget.selectedAnswer != widget.correctAnswer)) {
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