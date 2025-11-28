// lib/theme/theme_colors.dart
import 'package:flutter/material.dart';

class ThemeColors {
  // Get theme-aware colors based on current brightness
  static Color getText(BuildContext context) {
    return Theme.of(context).brightness == Brightness.dark 
        ? Colors.white 
        : Colors.black87;
  }
  
  static Color getSecondaryText(BuildContext context) {
    return Theme.of(context).brightness == Brightness.dark 
        ? Colors.white70 
        : Colors.black54;
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
        : Colors.black.withValues(alpha: 0.1);
  }
  
  static List<Color> getGradientColors(BuildContext context) {
    if (Theme.of(context).brightness == Brightness.dark) {
      return [
        const Color(0xFF1a237e), // Dark blue
        const Color(0xFF2e7d32), // Dark green
      ];
    } else {
      return [
        const Color(0xFFe0f7fa), // Light blue
        const Color(0xFF4CAF50), // Green
      ];
    }
  }
  
  static Color getAppBarText(BuildContext context) {
    return Theme.of(context).brightness == Brightness.dark 
        ? Colors.white 
        : Colors.black87;
  }
  
  static Color getAppBarIcon(BuildContext context) {
    return Theme.of(context).brightness == Brightness.dark 
        ? Colors.white 
        : Colors.black87;
  }
  
  static Color getGreen(BuildContext context) {
    return const Color(0xFF4CAF50); // Green color for labels
  }
  
  static Color getGameBoardText(BuildContext context) {
    return Theme.of(context).brightness == Brightness.dark 
        ? Colors.white 
        : Colors.black87;
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
        : Colors.black87;
  }
  
  static Color getButtonBackground(BuildContext context) {
    return Theme.of(context).brightness == Brightness.dark 
        ? Colors.grey[700]! 
        : Colors.grey[100]!;
  }
  
  static Color getCardForeground(BuildContext context) {
    return Theme.of(context).brightness == Brightness.dark 
        ? Colors.white 
        : Colors.black87;
  }
  
  static Color getIconColor(BuildContext context) {
    return Theme.of(context).brightness == Brightness.dark 
        ? Colors.white70 
        : Colors.black54;
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
        ? Colors.grey[800]!.withValues(alpha: 0.95) 
        : Colors.white.withValues(alpha: 0.97);
  }
  
  static Color getGameBoardBackground(BuildContext context) {
    return Theme.of(context).brightness == Brightness.dark 
        ? Colors.green.shade800.withValues(alpha: 0.3) 
        : Colors.green.shade50;
  }
  
  static Color getPlayerInfoCardBackground(BuildContext context) {
    return Theme.of(context).brightness == Brightness.dark 
        ? Colors.grey[800]!.withValues(alpha: 0.95) 
        : Color.fromRGBO(255, 255, 255, 0.97);
  }
  
  static Color getStatsCardBackground(BuildContext context) {
    return Theme.of(context).brightness == Brightness.dark 
        ? Colors.grey[800]! 
        : Colors.white;
  }
  
  static Color getStatsCardText(BuildContext context) {
    return Theme.of(context).brightness == Brightness.dark 
        ? Colors.white70 
        : Colors.grey[600]!;
  }
  
  static Color getHistoryCardBackground(BuildContext context) {
    return Theme.of(context).brightness == Brightness.dark 
        ? Colors.grey[800]!.withValues(alpha: 0.9) 
        : Colors.white.withValues(alpha: 0.9);
  }
  
  static Color getEmptyStateText(BuildContext context) {
    return Theme.of(context).brightness == Brightness.dark 
        ? Colors.white70 
        : Colors.grey;
  }
  
  static Color getGameTimeText(BuildContext context) {
    return Theme.of(context).brightness == Brightness.dark 
        ? Colors.white 
        : Colors.black87;
  }
  
  static Color getPlayerStatusText(BuildContext context) {
    return Theme.of(context).brightness == Brightness.dark 
        ? Colors.white 
        : Colors.black;
  }
  
  static Color getTurnIndicatorBackground(BuildContext context, bool isMyTurn) {
    return isMyTurn 
        ? (Theme.of(context).brightness == Brightness.dark ? Colors.green.shade700 : Colors.green.shade100)
        : (Theme.of(context).brightness == Brightness.dark ? Colors.grey.shade700 : Colors.grey.shade200);
  }
  
  static Color getTurnIndicatorText(BuildContext context, bool isMyTurn) {
    return isMyTurn 
        ? (Theme.of(context).brightness == Brightness.dark ? Colors.green.shade200 : Colors.green.shade800)
        : (Theme.of(context).brightness == Brightness.dark ? Colors.grey.shade300 : Colors.grey.shade700);
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
}