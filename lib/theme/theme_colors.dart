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
        : Colors.black.withOpacity(0.1);
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
}