// lib/theme/theme_colors.dart
import 'package:flutter/material.dart';

class ThemeColors {
  // Get theme-aware colors based on current brightness
  static Color getText(BuildContext context) {
    return Theme.of(context).brightness == Brightness.dark
        ? Colors.white
        : Colors.black;
  }

  static Color getSecondaryText(BuildContext context) {
    return Theme.of(context).brightness == Brightness.dark
        ? Colors.white.withOpacity( 0.8)
        : Colors.black.withOpacity( 0.7);
  }

  static Color getCardBackground(BuildContext context) {
    return Theme.of(context).brightness == Brightness.dark
        ? Colors.grey[800]!
        : Colors.white;
  }

  static Color getCardBackgroundLight(BuildContext context) {
    return Theme.of(context).brightness == Brightness.dark
        ? Colors.grey[700]!
        : Colors.grey[50]!;
  }

  static Color getContainerBackground(BuildContext context) {
    return Theme.of(context).brightness == Brightness.dark
        ? Colors.grey[900]!
        : Colors.white;
  }

  static Color getSurface(BuildContext context) {
    return Theme.of(context).brightness == Brightness.dark
        ? Colors.grey[900]!
        : Colors.grey[50]!;
  }

  static Color getInputBackground(BuildContext context) {
    return Theme.of(context).brightness == Brightness.dark
        ? Colors.grey[700]!
        : Colors.grey[50]!;
  }

  static Color getBorder(BuildContext context) {
    return Theme.of(context).brightness == Brightness.dark
        ? Colors.grey[600]!
        : Colors.grey[300]!;
  }

  static Color getShadow(BuildContext context) {
    return Theme.of(context).brightness == Brightness.dark
        ? Colors.black26
        : Colors.black.withOpacity( 0.1);
  }

  static List<Color> getGradientColors(BuildContext context) {
    if (Theme.of(context).brightness == Brightness.dark) {
      return [
        const Color(0xFF0F172A), // Modern dark slate
        const Color(0xFF1E293B), // Slate gray
        const Color(0xFF334155), // Lighter slate
        const Color(0xFF059669), // Emerald accent
      ];
    } else {
      return [
        const Color(0xFFF0F9FF), // Soft sky blue
        const Color(0xFFE0F2FE), // Light blue
        const Color(0xFFBBF7D0), // Soft green
        const Color(0xFF10B981), // Emerald green
      ];
    }
  }

  /// Modern gradient combinations for different app sections
  static List<Color> getPrimaryGradient(BuildContext context) {
    return Theme.of(context).brightness == Brightness.dark
        ? [
            const Color(0xFF1B5E20), // Dark green
            const Color(0xFF2E7D32), // Medium green
          ]
        : [
            const Color(0xFF4CAF50), // Primary green
            const Color(0xFF81C784), // Light green
          ];
  }

  static List<Color> getSecondaryGradient(BuildContext context) {
    return Theme.of(context).brightness == Brightness.dark
        ? [
            const Color(0xFF0277BD), // Dark blue
            const Color(0xFF0288D1), // Medium blue
          ]
        : [
            const Color(0xFF2196F3), // Primary blue
            const Color(0xFF64B5F6), // Light blue
          ];
  }

  static List<Color> getAccentGradient(BuildContext context) {
    return Theme.of(context).brightness == Brightness.dark
        ? [
            const Color(0xFF6A1B9A), // Dark purple
            const Color(0xFF8E24AA), // Medium purple
          ]
        : [
            const Color(0xFF9C27B0), // Primary purple
            const Color(0xFFBA68C8), // Light purple
          ];
  }

  static List<Color> getSurfaceGradient(BuildContext context) {
    return Theme.of(context).brightness == Brightness.dark
        ? [
            const Color(0xFF121212), // Dark surface
            const Color(0xFF1E1E1E), // Medium dark
          ]
        : [
            const Color(0xFFF8F9FA), // Light surface
            const Color(0xFFFFFFFF), // White
          ];
  }

  static Color getAppBarText(BuildContext context) {
    return Theme.of(context).brightness == Brightness.dark
        ? Colors.white
        : Colors.black;
  }

  static Color getAppBarIcon(BuildContext context) {
    return Theme.of(context).brightness == Brightness.dark
        ? Colors.white
        : Colors.black;
  }

  static Color getGreen(BuildContext context) {
    return const Color(0xFF4CAF50); // Green color for labels
  }

  static Color getGameBoardText(BuildContext context) {
    return Theme.of(context).brightness == Brightness.dark
        ? Colors.white
        : Colors.black;
  }

  static Color getDialogBackground(BuildContext context) {
    return Theme.of(context).brightness == Brightness.dark
        ? Colors.grey[800]!
        : Colors.white;
  }

  static Color getDialogContentBackground(BuildContext context) {
    return Theme.of(context).brightness == Brightness.dark
        ? Colors.grey[700]!
        : Colors.grey[50]!;
  }

  static Color getTitleText(BuildContext context) {
    return Theme.of(context).brightness == Brightness.dark
        ? Colors.white
        : Colors.black;
  }

  static Color getButtonBackground(BuildContext context) {
    return Theme.of(context).brightness == Brightness.dark
        ? Colors.grey[700]!
        : Colors.grey[100]!;
  }

  static Color getCardForeground(BuildContext context) {
    return Theme.of(context).brightness == Brightness.dark
        ? Colors.white
        : Colors.black;
  }

  static Color getIconColor(BuildContext context) {
    return Theme.of(context).brightness == Brightness.dark
        ? Colors.white.withOpacity( 0.8)
        : Colors.black.withOpacity( 0.7);
  }

  static Color getInputFieldBackground(BuildContext context) {
    return Theme.of(context).brightness == Brightness.dark
        ? Colors.grey[800]!
        : Colors.grey[50]!;
  }

  static Color getInputFieldBorder(BuildContext context) {
    return Theme.of(context).brightness == Brightness.dark
        ? Colors.grey[600]!
        : Colors.grey[300]!;
  }

  static Color getLogoutButtonBackground(BuildContext context) {
    return Theme.of(context).brightness == Brightness.dark
        ? Colors.red.shade700
        : Colors.black;
  }

  static Color getGameBoardTileText(BuildContext context) {
    return Colors.white; // White text on colored tiles for better visibility
  }

  static Color getGameBoardCardBackground(BuildContext context) {
    return Theme.of(context).brightness == Brightness.dark
        ? Colors.grey[800]!.withOpacity( 0.95)
        : Colors.white.withOpacity( 0.97);
  }

  static Color getGameBoardBackground(BuildContext context) {
    return Theme.of(context).brightness == Brightness.dark
        ? Colors.green.shade800.withOpacity( 0.3)
        : Colors.green.shade50;
  }

  static Color getPlayerInfoCardBackground(BuildContext context) {
    return Theme.of(context).brightness == Brightness.dark
        ? Colors.grey[800]!.withOpacity( 0.95)
        : Color.fromRGBO(255, 255, 255, 0.97);
  }

  static Color getStatsCardBackground(BuildContext context) {
    return Theme.of(context).brightness == Brightness.dark
        ? Colors.grey[800]!
        : Colors.white;
  }

  static Color getStatsCardText(BuildContext context) {
    return Theme.of(context).brightness == Brightness.dark
        ? Colors.white.withOpacity( 0.8)
        : Colors.black.withOpacity( 0.7);
  }

  static Color getHistoryCardBackground(BuildContext context) {
    return Theme.of(context).brightness == Brightness.dark
        ? Colors.grey[800]!.withOpacity( 0.9)
        : Colors.white.withOpacity( 0.9);
  }

  static Color getEmptyStateText(BuildContext context) {
    return Theme.of(context).brightness == Brightness.dark
        ? Colors.white.withOpacity( 0.8)
        : Colors.black.withOpacity( 0.6);
  }

  static Color getGameTimeText(BuildContext context) {
    return Theme.of(context).brightness == Brightness.dark
        ? Colors.white
        : Colors.black;
  }

  static Color getPlayerStatusText(BuildContext context) {
    return Theme.of(context).brightness == Brightness.dark
        ? Colors.white
        : Colors.black;
  }

  static Color getTurnIndicatorBackground(BuildContext context, bool isMyTurn) {
    return isMyTurn
        ? (Theme.of(context).brightness == Brightness.dark
            ? Colors.green.shade700
            : Colors.green.shade100)
        : (Theme.of(context).brightness == Brightness.dark
            ? Colors.grey.shade700
            : Colors.grey.shade200);
  }

  static Color getTurnIndicatorText(BuildContext context, bool isMyTurn) {
    return isMyTurn
        ? (Theme.of(context).brightness == Brightness.dark
            ? Colors.green.shade200
            : Colors.green.shade800)
        : (Theme.of(context).brightness == Brightness.dark
            ? Colors.grey.shade300
            : Colors.grey.shade700);
  }

  static Color getDiceAreaBackground(BuildContext context) {
    return Theme.of(context).brightness == Brightness.dark
        ? Colors.blueGrey.shade700
        : Colors.blueGrey.shade100;
  }

  static Color getDiceValueText(BuildContext context) {
    return Theme.of(context).brightness == Brightness.dark
        ? Colors.white
        : const Color(0xFF1E88E5);
  }

  // Consistent button colors for different actions
  static Color getPrimaryButtonColor(BuildContext context) {
    return const Color(0xFF4CAF50); // Green
  }

  static Color getSecondaryButtonColor(BuildContext context) {
    return const Color(0xFF2196F3); // Blue
  }

  static Color getAccentButtonColor(BuildContext context) {
    return const Color(0xFF9C27B0); // Purple
  }

  static Color getWarningButtonColor(BuildContext context) {
    return const Color(0xFFFF9800); // Orange
  }

  static Color getErrorButtonColor(BuildContext context) {
    return Theme.of(context).brightness == Brightness.dark
        ? Colors.red.shade700
        : const Color(0xFFF44336);
  }

  // Consistent text colors for different priorities
  static Color getTitleColor(BuildContext context) {
    return const Color(0xFF2E7D32); // Dark green for titles
  }

  static Color getSuccessColor(BuildContext context) {
    return const Color(0xFF4CAF50); // Green
  }

  static Color getWarningColor(BuildContext context) {
    return const Color(0xFFFF9800); // Orange
  }

  static Color getInfoColor(BuildContext context) {
    return const Color(0xFF2196F3); // Blue
  }

  static Color getErrorColor(BuildContext context) {
    return Theme.of(context).brightness == Brightness.dark
        ? Colors.red.shade300
        : const Color(0xFFF44336);
  }

  // Modern color utilities for enhanced design
  static Color getOverlayColor(BuildContext context) {
    return Theme.of(context).brightness == Brightness.dark
        ? Colors.black.withOpacity( 0.6)
        : Colors.black.withOpacity( 0.4);
  }

  static Color getGlassBackground(BuildContext context) {
    return Theme.of(context).brightness == Brightness.dark
        ? Colors.white.withOpacity( 0.05)
        : Colors.white.withOpacity( 0.8);
  }

  static Color getNeumorphismLight(BuildContext context) {
    return Theme.of(context).brightness == Brightness.dark
        ? Colors.grey.shade800
        : Colors.grey.shade100;
  }

  static Color getNeumorphismDark(BuildContext context) {
    return Theme.of(context).brightness == Brightness.dark
        ? Colors.grey.shade900
        : Colors.white;
  }

  // Success/Progress colors for game elements
  static Color getSuccessGradientStart(BuildContext context) {
    return const Color(0xFF4CAF50);
  }

  static Color getSuccessGradientEnd(BuildContext context) {
    return const Color(0xFF81C784);
  }

  static Color getWarningGradientStart(BuildContext context) {
    return const Color(0xFFFF9800);
  }

  static Color getWarningGradientEnd(BuildContext context) {
    return const Color(0xFFFFB74D);
  }

  static Color getErrorGradientStart(BuildContext context) {
    return const Color(0xFFF44336);
  }

  static Color getErrorGradientEnd(BuildContext context) {
    return const Color(0xFFEF5350);
  }

  // Interactive states
  static Color getInteractiveHover(BuildContext context) {
    return Theme.of(context).brightness == Brightness.dark
        ? Colors.white.withOpacity( 0.08)
        : Colors.black.withOpacity( 0.04);
  }

  static Color getInteractivePressed(BuildContext context) {
    return Theme.of(context).brightness == Brightness.dark
        ? Colors.white.withOpacity( 0.12)
        : Colors.black.withOpacity( 0.08);
  }

  static Color getFocusRing(BuildContext context) {
    return Theme.of(context).brightness == Brightness.dark
        ? const Color(0xFF64B5F6)
        : const Color(0xFF1976D2);
  }

  // Modern shadows and elevations
  static List<BoxShadow> getModernShadow(BuildContext context,
      {double elevation = 1.0}) {
    if (Theme.of(context).brightness == Brightness.dark) {
      return [
        BoxShadow(
          color: Colors.black.withOpacity( 0.3 * elevation),
          blurRadius: 8 * elevation,
          offset: Offset(0, 4 * elevation),
        ),
      ];
    } else {
      return [
        BoxShadow(
          color: Colors.black.withOpacity( 0.1 * elevation),
          blurRadius: 6 * elevation,
          offset: Offset(0, 2 * elevation),
        ),
        BoxShadow(
          color: Colors.black.withOpacity( 0.05 * elevation),
          blurRadius: 12 * elevation,
          offset: Offset(0, 8 * elevation),
        ),
      ];
    }
  }
}
