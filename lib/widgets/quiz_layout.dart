// lib/widgets/quiz_layout.dart
// Quiz Layout Component - Unified layout for all quiz pages

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../theme/quiz_design_system.dart';
import '../theme/theme_colors.dart';

/// QuizLayout - Unified layout component for all quiz-related pages
/// Provides consistent header, content area, and action button placement
///
/// Usage:
/// ```dart
/// QuizLayout(
///   title: 'Quiz Oluştur',
///   subtitle: 'Ayarlarınızı seçip quize başlayın',
///   child: Column(children: [...]),
///   bottomAction: ElevatedButton(...),
/// )
/// ```
class QuizLayout extends StatefulWidget {
  final String title;
  final String? subtitle;
  final Widget child;
  final Widget? bottomAction;
  final bool showBackButton;
  final VoidCallback? onBackPressed;
  final List<Widget>? actions;
  final EdgeInsets padding;
  final bool scrollable;
  final Color? headerColor;
  final Widget? headerWidget;

  const QuizLayout({
    super.key,
    required this.title,
    this.subtitle,
    required this.child,
    this.bottomAction,
    this.showBackButton = true,
    this.onBackPressed,
    this.actions,
    this.padding = const EdgeInsets.all(QuizDesignSystem.spacingL),
    this.scrollable = true,
    this.headerColor,
    this.headerWidget,
  });

  @override
  State<QuizLayout> createState() => _QuizLayoutState();
}

class _QuizLayoutState extends State<QuizLayout> with TickerProviderStateMixin {
  late AnimationController _fadeController;
  late AnimationController _slideController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
    _fadeController = AnimationController(
      duration: QuizDesignSystem.animationPageTransition,
      vsync: this,
    );
    _slideController = AnimationController(
      duration: QuizDesignSystem.animationMedium,
      vsync: this,
    );

    _fadeAnimation = CurvedAnimation(
      parent: _fadeController,
      curve: Curves.easeOut,
    );
    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.1),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _slideController,
      curve: Curves.easeOutCubic,
    ));

    // Start animations
    _fadeController.forward();
    _slideController.forward();
  }

  @override
  void dispose() {
    _fadeController.dispose();
    _slideController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // No default app bar - we build our own gradient header
      extendBodyBehindAppBar: true,
      body: Column(
        children: [
          // Gradient Header
          _buildHeader(context),

          // Content Area
          Expanded(
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: QuizDesignSystem.getPageBackgroundGradient(context),
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                ),
              ),
              child: widget.scrollable
                  ? SingleChildScrollView(
                      physics: const BouncingScrollPhysics(
                        parent: AlwaysScrollableScrollPhysics(),
                      ),
                      child: _buildContent(),
                    )
                  : _buildContent(),
            ),
          ),

          // Bottom Action Button (if provided)
          if (widget.bottomAction != null)
            _buildBottomAction(),
        ],
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    final headerGradient = widget.headerColor != null
        ? [widget.headerColor!, widget.headerColor!]
        : QuizDesignSystem.getHeaderGradient(context);

    return Container(
      padding: EdgeInsets.only(
        top: MediaQuery.of(context).padding.top + QuizDesignSystem.spacingM,
        left: QuizDesignSystem.spacingL,
        right: QuizDesignSystem.spacingL,
        bottom: QuizDesignSystem.spacingXl,
      ),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: headerGradient,
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: SafeArea(
        bottom: false,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Top row with back button and actions
            Row(
              children: [
                // Back Button
                if (widget.showBackButton)
                  _buildBackButton(context),
                // Spacer
                if (widget.showBackButton)
                  SizedBox(width: QuizDesignSystem.spacingM),
                // Title
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        widget.title,
                        style: QuizDesignSystem.getHeadlineStyle(context),
                      ),
                      if (widget.subtitle != null) ...[
                        SizedBox(height: QuizDesignSystem.spacingXs),
                        Text(
                          widget.subtitle!,
                          style: QuizDesignSystem.getSubtitleStyle(context),
                        ),
                      ],
                    ],
                  ),
                ),
                // Custom actions
                if (widget.actions != null) ...widget.actions!,
              ],
            ),
            // Custom header widget (replaces default title area if provided)
            if (widget.headerWidget != null) ...[
              SizedBox(height: QuizDesignSystem.spacingM),
              widget.headerWidget!,
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildBackButton(BuildContext context) {
    // Determine if we should use light or dark colors based on header gradient
    final brightness = Theme.of(context).brightness;
    final isDarkTheme = brightness == Brightness.dark;
    final backgroundColor = isDarkTheme
        ? Colors.white.withValues(alpha: 0.15)
        : Colors.white.withValues(alpha: 0.3);
    final iconColor = isDarkTheme ? Colors.white : ThemeColors.getText(context);
    final textColor = isDarkTheme ? Colors.white : ThemeColors.getText(context);

    return Semantics(
      label: 'Geri git',
      button: true,
      child: GestureDetector(
        onTap: () {
          HapticFeedback.lightImpact();
          widget.onBackPressed?.call();
          if (Navigator.canPop(context)) {
            Navigator.pop(context);
          }
        },
        child: Container(
          width: 44,
          height: 44,
          decoration: BoxDecoration(
            color: backgroundColor,
            borderRadius: BorderRadius.circular(QuizDesignSystem.radiusM),
          ),
          child: Icon(
            Icons.arrow_back,
            color: iconColor,
            size: 24,
          ),
        ),
      ),
    );
  }

  Widget _buildContent() {
    return FadeTransition(
      opacity: _fadeAnimation,
      child: SlideTransition(
        position: _slideAnimation,
        child: Padding(
          padding: widget.padding,
          child: widget.child,
        ),
      ),
    );
  }

  Widget _buildBottomAction() {
    return SafeArea(
      top: false,
      left: true,
      right: true,
      bottom: true,
      minimum: EdgeInsets.all(QuizDesignSystem.spacingL),
      child: FadeTransition(
        opacity: _fadeAnimation,
        child: widget.bottomAction!,
      ),
    );
  }
}

// ===========================================================================
// QUIZ LAYOUT BUILDER
// ===========================================================================

/// Builder function type for QuizLayout content
typedef QuizLayoutBuilder = Widget Function(
  BuildContext context,
  VoidCallback onStartQuiz,
);

/// Quick quiz layout for starting a quiz
class QuickQuizLayout extends StatelessWidget {
  final String title;
  final String subtitle;
  final VoidCallback onStartQuiz;
  final Widget? summaryCard;
  final List<Widget> options;
  final bool showStartButton;

  const QuickQuizLayout({
    super.key,
    required this.title,
    required this.subtitle,
    required this.onStartQuiz,
    this.summaryCard,
    required this.options,
    this.showStartButton = true,
  });

  @override
  Widget build(BuildContext context) {
    return QuizLayout(
      title: title,
      subtitle: subtitle,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Options list
          ...options,
          if (summaryCard != null) ...[
            SizedBox(height: QuizDesignSystem.spacingXl),
            summaryCard!,
          ],
        ],
      ),
      bottomAction: showStartButton
          ? _buildStartButton(context)
          : null,
    );
  }

  Widget _buildStartButton(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: QuizDesignSystem.buttonHeight,
      child: ElevatedButton.icon(
        onPressed: onStartQuiz,
        style: QuizDesignSystem.getPrimaryButtonStyle(context),
        icon: const Icon(Icons.play_arrow, size: 26),
        label: const Text(
          'Quiz Başlat',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }
}

// ===========================================================================
// QUIZ SETTINGS LAYOUT
// ===========================================================================

/// Specialized layout for quiz settings pages
class QuizSettingsLayout extends StatefulWidget {
  final String title;
  final String? subtitle;
  final List<Widget> sections;
  final VoidCallback onStartQuiz;
  final Map<String, dynamic> currentSettings;
  final bool showSummary;

  const QuizSettingsLayout({
    super.key,
    required this.title,
    this.subtitle,
    required this.sections,
    required this.onStartQuiz,
    required this.currentSettings,
    this.showSummary = true,
  });

  @override
  State<QuizSettingsLayout> createState() => _QuizSettingsLayoutState();
}

class _QuizSettingsLayoutState extends State<QuizSettingsLayout> {
  @override
  Widget build(BuildContext context) {
    return QuizLayout(
      title: widget.title,
      subtitle: widget.subtitle,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ...widget.sections,
          if (widget.showSummary) ...[
            SizedBox(height: QuizDesignSystem.spacingXl),
            _buildSummaryCard(context),
            SizedBox(height: QuizDesignSystem.spacingXl),
          ],
        ],
      ),
      bottomAction: _buildStartButton(context),
    );
  }

  Widget _buildSummaryCard(BuildContext context) {
    return _SummaryCard(settings: widget.currentSettings);
  }

  Widget _buildStartButton(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: QuizDesignSystem.buttonHeight,
      child: ElevatedButton.icon(
        onPressed: widget.onStartQuiz,
        style: QuizDesignSystem.getPrimaryButtonStyle(context),
        icon: const Icon(Icons.play_arrow, size: 26),
        label: const Text(
          'Quiz Başlat',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }
}

class _SummaryCard extends StatelessWidget {
  final Map<String, dynamic> settings;

  const _SummaryCard({required this.settings});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(QuizDesignSystem.spacingL),
      decoration: QuizDesignSystem.getSummaryCardDecoration(context),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(QuizDesignSystem.spacingS),
                decoration: BoxDecoration(
                  color: ThemeColors.getSuccessColor(context)
                      .withValues(alpha: 0.2),
                  borderRadius:
                      BorderRadius.circular(QuizDesignSystem.radiusM),
                ),
                child: Icon(
                  Icons.summarize,
                  color: ThemeColors.getSuccessColor(context),
                  size: QuizDesignSystem.iconSizeMedium,
                ),
              ),
              SizedBox(width: QuizDesignSystem.spacingM),
              Text(
                'Quiz Özeti',
                style: QuizDesignSystem.getSectionTitleStyle(context).copyWith(
                  color: ThemeColors.getSuccessColor(context),
                ),
              ),
            ],
          ),
          SizedBox(height: QuizDesignSystem.spacingL),
          // Settings rows
          ...settings.entries.map((entry) {
            return Padding(
              padding:
                  const EdgeInsets.only(bottom: QuizDesignSystem.spacingM),
              child: Row(
                children: [
                  SizedBox(width: QuizDesignSystem.spacingM),
                  Text(
                    '${entry.key}: ',
                    style: QuizDesignSystem.getSummaryLabelStyle(context),
                  ),
                  Expanded(
                    child: Text(
                      entry.value.toString(),
                      style: QuizDesignSystem.getSummaryValueStyle(context),
                    ),
                  ),
                ],
              ),
            );
          }),
          SizedBox(height: QuizDesignSystem.spacingM),
          // Ready indicator
          Container(
            padding: const EdgeInsets.all(QuizDesignSystem.spacingM),
            decoration: BoxDecoration(
              color:
                  ThemeColors.getPrimaryButtonColor(context).withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(QuizDesignSystem.radiusM),
              border: Border.all(
                color: ThemeColors.getPrimaryButtonColor(context)
                    .withValues(alpha: 0.3),
              ),
            ),
            child: Row(
              children: [
                Icon(
                  Icons.play_circle_fill,
                  color: ThemeColors.getPrimaryButtonColor(context),
                  size: QuizDesignSystem.iconSizeMedium,
                ),
                SizedBox(width: QuizDesignSystem.spacingM),
                Expanded(
                  child: Text(
                    'Hazır! Quiz\'i başlatabilirsiniz.',
                    style: QuizDesignSystem.getCardTitleStyle(context).copyWith(
                      color: ThemeColors.getPrimaryButtonColor(context),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

