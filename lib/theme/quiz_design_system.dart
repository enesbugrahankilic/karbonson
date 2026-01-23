// lib/theme/quiz_design_system.dart
// Quiz Design System - Modern, Colorful, Theme-Aware Design Components

import 'package:flutter/material.dart';
import 'theme_colors.dart';

/// Quiz Design System - Consistent UI for all quiz-related pages
/// Built on the Quiz Oluştur page design with theme-aware colors
class QuizDesignSystem {
  // ===========================================================================
  // CONSTANTS
  // ===========================================================================

  // Standard spacing values
  static const double spacingXs = 4.0;
  static const double spacingS = 8.0;
  static const double spacingM = 16.0;
  static const double spacingL = 24.0;
  static const double spacingXl = 32.0;
  static const double spacingXxl = 48.0;

  // Standard border radius values
  static const double radiusS = 8.0;
  static const double radiusM = 12.0;
  static const double radiusL = 16.0;
  static const double radiusXl = 24.0;
  static const double radiusFull = 999.0;

  // Standard elevation values
  static const double elevationS = 2.0;
  static const double elevationM = 4.0;
  static const double elevationL = 8.0;

  // Button heights
  static const double buttonHeight = 56.0;
  static const double buttonHeightSmall = 48.0;

  // Card dimensions
  static const double cardMinHeight = 80.0;
  static const double cardPadding = 16.0;

  // ===========================================================================
  // GRADIENT COLORS (Theme-Aware)
  // ===========================================================================

  /// Primary gradient - Green tones (same for light and dark)
  static List<Color> getPrimaryGradient(BuildContext context) {
    return Theme.of(context).brightness == Brightness.dark
        ? [
            const Color(0xFF2E7D32),    // Dark green
            const Color(0xFF388E3C),    // Medium green
          ]
        : [
            const Color(0xFF4CAF50),    // Primary green
            const Color(0xFF66BB6A),    // Light green
          ];
  }

  /// Secondary gradient - Blue tones
  static List<Color> getSecondaryGradient(BuildContext context) {
    return Theme.of(context).brightness == Brightness.dark
        ? [
            const Color(0xFF1565C0),    // Dark blue
            const Color(0xFF1976D2),    // Medium blue
          ]
        : [
            const Color(0xFF2196F3),    // Primary blue
            const Color(0xFF42A5F5),    // Light blue
          ];
  }

  /// Accent gradient - Purple tones
  static List<Color> getAccentGradient(BuildContext context) {
    return Theme.of(context).brightness == Brightness.dark
        ? [
            const Color(0xFF6A1B9A),    // Dark purple
            const Color(0xFF7B1FA2),    // Medium purple
          ]
        : [
            const Color(0xFF9C27B0),    // Primary purple
            const Color(0xFFAB47BC),    // Light purple
          ];
  }

  /// Turquoise accent gradient
  static List<Color> getTurquoiseGradient(BuildContext context) {
    return Theme.of(context).brightness == Brightness.dark
        ? [
            const Color(0xFF00897B),    // Dark teal
            const Color(0xFF009688),    // Medium teal
          ]
        : [
            const Color(0xFF26A69A),    // Primary teal
            const Color(0xFF4DB6AC),    // Light teal
          ];
  }

  /// Orange/Warning gradient
  static List<Color> getWarningGradient(BuildContext context) {
    return Theme.of(context).brightness == Brightness.dark
        ? [
            const Color(0xFFE65100),    // Dark orange
            const Color(0xFFF57C00),    // Medium orange
          ]
        : [
            const Color(0xFFFF9800),    // Primary orange
            const Color(0xFFFFB74D),    // Light orange
          ];
  }

  /// Error gradient
  static List<Color> getErrorGradient(BuildContext context) {
    return Theme.of(context).brightness == Brightness.dark
        ? [
            const Color(0xFFC62828),    // Dark red
            const Color(0xFFD32F2F),    // Medium red
          ]
        : [
            const Color(0xFFF44336),    // Primary red
            const Color(0xFFEF5350),    // Light red
          ];
  }

  /// Page background gradient - Soft colors
  static List<Color> getPageBackgroundGradient(BuildContext context) {
    return Theme.of(context).brightness == Brightness.dark
        ? [
            const Color(0xFF0F172A),    // Dark slate
            const Color(0xFF1E293B),    // Slate
            const Color(0xFF334155),    // Light slate
            const Color(0xFF059669),    // Emerald accent
          ]
        : [
            const Color(0xFFF0FDF4),    // Soft mint
            const Color(0xFFDCFCE7),    // Light green
            const Color(0xFFBBF7D0),    // Pastel green
            const Color(0xFF4ADE80),    // Vibrant green
          ];
  }

  /// Header gradient - Colorful for page headers
  static List<Color> getHeaderGradient(BuildContext context) {
    return Theme.of(context).brightness == Brightness.dark
        ? [
            const Color(0xFF1B5E20),    // Dark green
            const Color(0xFF2E7D32),    // Medium green
            const Color(0xFF388E3C),    // Light green
          ]
        : [
            const Color(0xFF43A047),    // Green
            const Color(0xFF66BB6A),    // Light green
            const Color(0xFF81C784),    // Pale green
          ];
  }

  // ===========================================================================
  // CARD DECORATIONS
  // ===========================================================================

  /// Quiz card decoration - Selected state
  static BoxDecoration getSelectedCardDecoration(
    BuildContext context, {
    required Color color,
    double borderRadius = radiusL,
  }) {
    return BoxDecoration(
      gradient: LinearGradient(
        colors: [
          color.withValues(alpha: 0.9),
          color.withValues(alpha: 0.7),
        ],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      ),
      borderRadius: BorderRadius.circular(borderRadius),
      border: Border.all(
        color: color,
        width: 2.5,
      ),
      boxShadow: [
        BoxShadow(
          color: color.withValues(alpha: 0.4),
          blurRadius: 12,
          offset: const Offset(0, 6),
        ),
      ],
    );
  }

  /// Quiz card decoration - Unselected state
  static BoxDecoration getUnselectedCardDecoration(
    BuildContext context, {
    double opacity = 0.08,
    double borderRadius = radiusL,
  }) {
    return BoxDecoration(
      color: Colors.white.withValues(alpha: opacity),
      borderRadius: BorderRadius.circular(borderRadius),
      border: Border.all(
        color: Colors.white.withValues(alpha: 0.15),
        width: 1,
      ),
    );
  }

  /// Glass card decoration
  static BoxDecoration getGlassCardDecoration(
    BuildContext context, {
    double borderRadius = radiusL,
  }) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return BoxDecoration(
      color: isDark
          ? Colors.white.withValues(alpha: 0.05)
          : Colors.white.withValues(alpha: 0.85),
      borderRadius: BorderRadius.circular(borderRadius),
      border: Border.all(
        color: isDark
            ? Colors.white.withValues(alpha: 0.1)
            : Colors.white.withValues(alpha: 0.5),
        width: 1,
      ),
      boxShadow: [
        BoxShadow(
          color: Colors.black.withValues(alpha: isDark ? 0.3 : 0.08),
          blurRadius: 12,
          offset: const Offset(0, 4),
        ),
      ],
    );
  }

  /// Summary card decoration
  static BoxDecoration getSummaryCardDecoration(BuildContext context) {
    final successColor = ThemeColors.getSuccessColor(context);
    return BoxDecoration(
      gradient: LinearGradient(
        colors: [
          successColor.withValues(alpha: 0.15),
          successColor.withValues(alpha: 0.05),
        ],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      ),
      borderRadius: BorderRadius.circular(radiusL),
      border: Border.all(
        color: successColor.withValues(alpha: 0.3),
        width: 1.5,
      ),
      boxShadow: [
        BoxShadow(
          color: successColor.withValues(alpha: 0.2),
          blurRadius: 20,
          offset: const Offset(0, 8),
        ),
      ],
    );
  }

  // ===========================================================================
  // BUTTON STYLES
  // ===========================================================================

  /// Primary button style - Green gradient
  static ButtonStyle getPrimaryButtonStyle(BuildContext context) {
    final primaryColor = ThemeColors.getPrimaryButtonColor(context);

    return ElevatedButton.styleFrom(
      backgroundColor: primaryColor,
      foregroundColor: Colors.white,
      padding: const EdgeInsets.symmetric(
        horizontal: spacingXl,
        vertical: spacingM,
      ),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(radiusM),
      ),
      elevation: elevationS,
      shadowColor: primaryColor.withValues(alpha: 0.3),
      minimumSize: const Size.fromHeight(buttonHeight),
      textStyle: const TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.w600,
        letterSpacing: 0.5,
      ),
    ).copyWith(
      backgroundColor: WidgetStateProperty.resolveWith<Color?>((states) {
        if (states.contains(WidgetState.disabled)) {
          return Theme.of(context).brightness == Brightness.dark
              ? Colors.grey.shade700
              : Colors.grey.shade300;
        }
        if (states.contains(WidgetState.pressed)) {
          return Color.alphaBlend(
              Colors.black.withValues(alpha: 0.1), primaryColor);
        }
        return primaryColor;
      }),
    );
  }

  /// Secondary button style - Blue gradient
  static ButtonStyle getSecondaryButtonStyle(BuildContext context) {
    final secondaryColor = ThemeColors.getSecondaryButtonColor(context);

    return ElevatedButton.styleFrom(
      backgroundColor: secondaryColor,
      foregroundColor: Colors.white,
      padding: const EdgeInsets.symmetric(
        horizontal: spacingXl,
        vertical: spacingM,
      ),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(radiusM),
      ),
      elevation: elevationS,
      minimumSize: const Size.fromHeight(buttonHeight),
      textStyle: const TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.w600,
        letterSpacing: 0.5,
      ),
    );
  }

  /// Accent button style - Purple gradient
  static ButtonStyle getAccentButtonStyle(BuildContext context) {
    final accentColor = ThemeColors.getAccentButtonColor(context);

    return ElevatedButton.styleFrom(
      backgroundColor: accentColor,
      foregroundColor: Colors.white,
      padding: const EdgeInsets.symmetric(
        horizontal: spacingXl,
        vertical: spacingM,
      ),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(radiusM),
      ),
      elevation: elevationS,
      minimumSize: const Size.fromHeight(buttonHeight),
      textStyle: const TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.w600,
        letterSpacing: 0.5,
      ),
    );
  }

  /// Large primary button with icon
  static ButtonStyle getLargePrimaryButtonStyle(BuildContext context) {
    return getPrimaryButtonStyle(context).copyWith(
      minimumSize: const WidgetStatePropertyAll(
        Size.fromHeight(buttonHeight),
      ),
    );
  }

  // ===========================================================================
  // TEXT STYLES
  // ===========================================================================

  /// Headline style for page titles
  static TextStyle getHeadlineStyle(BuildContext context) {
    return Theme.of(context).textTheme.headlineMedium?.copyWith(
          color: Colors.white,
          fontWeight: FontWeight.bold,
        ) ??
        const TextStyle(
          fontSize: 28,
          fontWeight: FontWeight.bold,
          color: Colors.white,
        );
  }

  /// Subtitle style
  static TextStyle getSubtitleStyle(BuildContext context) {
    return Theme.of(context).textTheme.bodyMedium?.copyWith(
          color: Colors.white70,
        ) ??
        const TextStyle(
          fontSize: 14,
          color: Colors.white70,
        );
  }

  /// Section title style
  static TextStyle getSectionTitleStyle(BuildContext context) {
    return Theme.of(context).textTheme.titleLarge?.copyWith(
          color: Colors.white,
          fontWeight: FontWeight.bold,
        ) ??
        const TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.bold,
          color: Colors.white,
        );
  }

  /// Card title style
  static TextStyle getCardTitleStyle(BuildContext context) {
    return Theme.of(context).textTheme.titleMedium?.copyWith(
          fontWeight: FontWeight.bold,
        ) ??
        const TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.bold,
        );
  }

  /// Card subtitle/description style
  static TextStyle getCardSubtitleStyle(BuildContext context) {
    return Theme.of(context).textTheme.bodyMedium?.copyWith(
          color: Colors.white70,
        ) ??
        const TextStyle(
          fontSize: 14,
          color: Colors.white70,
        );
  }

  /// Summary label style
  static TextStyle getSummaryLabelStyle(BuildContext context) {
    return const TextStyle(
      color: Colors.white70,
      fontSize: 14,
    );
  }

  /// Summary value style
  static TextStyle getSummaryValueStyle(BuildContext context) {
    return const TextStyle(
      color: Colors.white,
      fontWeight: FontWeight.bold,
      fontSize: 15,
    );
  }

  // ===========================================================================
  // ICON STYLES
  // ===========================================================================

  /// Large icon size for cards
  static const double iconSizeLarge = 32.0;

  /// Medium icon size
  static const double iconSizeMedium = 24.0;

  /// Small icon size
  static const double iconSizeSmall = 20.0;

  /// Icon container padding
  static const double iconContainerPadding = 12.0;

  // ===========================================================================
  // ANIMATION DURATIONS
  // ===========================================================================

  static const Duration animationFast = Duration(milliseconds: 200);
  static const Duration animationMedium = Duration(milliseconds: 300);
  static const Duration animationSlow = Duration(milliseconds: 500);
  static const Duration animationPageTransition = Duration(milliseconds: 400);
}

// ===========================================================================

// QUIZ CATEGORY COLORS
// Color constants for quiz categories
//
class QuizCategoryColors {
  static const Color all = Colors.purple;
  static const Color energy = Colors.orange;
  static const Color water = Colors.blue;
  static const Color forest = Colors.green;
  static const Color recycling = Colors.teal;
  static const Color transportation = Colors.indigo;
  static const Color consumption = Colors.pink;
}

// ===========================================================================
//
// QUIZ DIFFICULTY COLORS
// Color constants for difficulty levels
//
class QuizDifficultyColors {
  static const Color easy = Colors.green;
  static const Color medium = Colors.orange;
  static const Color hard = Colors.red;
}

// ===========================================================================
//
// QUESTION COUNT COLORS
// Color constants for question count options
//
class QuestionCountColors {
  static const Color quick = Colors.cyan;
  static const Color standard = Colors.blue;
  static const Color comprehensive = Colors.purple;
  static const Color long = Colors.deepPurple;
  static const Color full = Colors.pink;
}

// ===========================================================================
//
// LANGUAGE COLORS
// Color constants for language options
//
class LanguageColors {
  static const Color turkish = Colors.red;
  static const Color english = Colors.blue;
}

