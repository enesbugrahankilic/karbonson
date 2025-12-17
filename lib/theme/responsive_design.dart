// lib/theme/responsive_design.dart
// Modern responsive design utilities

import 'package:flutter/material.dart';
import 'design_system.dart';
import 'theme_colors.dart';

/// Modern responsive design utilities
class ResponsiveDesign {
  
  /// Screen breakpoints following Material Design 3
  static const double mobileBreakpoint = 600;
  static const double tabletBreakpoint = 1024;
  static const double desktopBreakpoint = 1440;
  
  /// Get current screen type
  static ScreenType getScreenType(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    
    if (screenWidth >= desktopBreakpoint) {
      return ScreenType.desktop;
    } else if (screenWidth >= tabletBreakpoint) {
      return ScreenType.tablet;
    } else {
      return ScreenType.mobile;
    }
  }
  
  /// Get responsive spacing based on screen size
  static double getResponsiveSpacing(BuildContext context, BaseSpacing spacing) {
    final screenType = getScreenType(context);
    
    switch (screenType) {
      case ScreenType.mobile:
        return _getMobileSpacing(spacing);
      case ScreenType.tablet:
        return _getTabletSpacing(spacing);
      case ScreenType.desktop:
        return _getDesktopSpacing(spacing);
    }
  }
  
  /// Get responsive font size
  static double getResponsiveFontSize(BuildContext context, BaseFontSize baseSize) {
    final screenType = getScreenType(context);
    
    switch (screenType) {
      case ScreenType.mobile:
        return _getMobileFontSize(baseSize);
      case ScreenType.tablet:
        return _getTabletFontSize(baseSize);
      case ScreenType.desktop:
        return _getDesktopFontSize(baseSize);
    }
  }
  
  /// Create responsive grid based on screen size
  static Widget responsiveGrid({
    required BuildContext context,
    required List<Widget> children,
    int mobileColumns = 1,
    int? tabletColumns,
    int? desktopColumns,
    double? mobileSpacing,
    double? tabletSpacing,
    double? desktopSpacing,
    EdgeInsets? mobilePadding,
    EdgeInsets? tabletPadding,
    EdgeInsets? desktopPadding,
  }) {
    final screenType = getScreenType(context);
    final columns = _getColumns(screenType, mobileColumns, tabletColumns, desktopColumns);
    final spacing = _getSpacing(screenType, mobileSpacing, tabletSpacing, desktopSpacing);
    final padding = _getPadding(screenType, mobilePadding, tabletPadding, desktopPadding);
    
    return Container(
      padding: padding,
      child: LayoutBuilder(
        builder: (context, constraints) {
          final itemWidth = (constraints.maxWidth - (spacing * (columns - 1))) / columns;
          
          return Wrap(
            spacing: spacing,
            runSpacing: spacing,
            children: children.map((child) {
              return SizedBox(
                width: itemWidth,
                child: child,
              );
            }).toList(),
          );
        },
      ),
    );
  }
  
  /// Create responsive card layout
  static Widget responsiveCard({
    required BuildContext context,
    required Widget child,
    VoidCallback? onTap,
    EdgeInsets? mobilePadding,
    EdgeInsets? tabletPadding,
    EdgeInsets? desktopPadding,
    double? mobileMargin,
    double? tabletMargin,
    double? desktopMargin,
  }) {
    final screenType = getScreenType(context);
    final padding = _getPadding(screenType, mobilePadding, tabletPadding, desktopPadding);
    final margin = _getMargin(screenType, mobileMargin, tabletMargin, desktopMargin);
    
    return Container(
      margin: EdgeInsets.all(margin),
      padding: padding,
      decoration: BoxDecoration(
        color: ThemeColors.getCardBackground(context),
        borderRadius: BorderRadius.circular(DesignSystem.radiusL),
        boxShadow: ThemeColors.getModernShadow(context, elevation: 1.0),
      ),
      child: child,
    );
  }
  
  /// Create responsive text that adapts to screen size
  static Widget responsiveText(
    BuildContext context, {
    required String text,
    BaseFontSize baseSize = BaseFontSize.body,
    TextAlign? textAlign,
    int? maxLines,
    TextOverflow? overflow,
    Color? color,
    FontWeight? fontWeight,
  }) {
    final fontSize = getResponsiveFontSize(context, baseSize);
    
    return Text(
      text,
      style: TextStyle(
        fontSize: fontSize,
        color: color ?? ThemeColors.getText(context),
        fontWeight: fontWeight,
        height: _getLineHeight(baseSize),
      ),
      textAlign: textAlign,
      maxLines: maxLines,
      overflow: overflow,
    );
  }
  
  /// Create responsive app bar
  static PreferredSizeWidget responsiveAppBar({
    required BuildContext context,
    required String title,
    List<Widget>? actions,
    Widget? leading,
    bool centerTitle = false,
  }) {
    final screenType = getScreenType(context);
    final isMobile = screenType == ScreenType.mobile;
    
    return AppBar(
      leading: leading,
      title: responsiveText(
        context,
        text: title,
        baseSize: isMobile ? BaseFontSize.title : BaseFontSize.headline,
        fontWeight: FontWeight.w600,
      ),
      actions: actions,
      centerTitle: centerTitle || isMobile,
      backgroundColor: ThemeColors.getSurface(context),
      foregroundColor: ThemeColors.getAppBarText(context),
      elevation: DesignSystem.elevationS,
      shape: Border(
        bottom: BorderSide(
          color: ThemeColors.getBorder(context).withOpacity(0.1),
          width: 1,
        ),
      ),
    );
  }
  
  /// Create responsive button
  static Widget responsiveButton(
    BuildContext context, {
    required String text,
    required VoidCallback onPressed,
    IconData? icon,
    bool isLoading = false,
    BaseButtonSize baseSize = BaseButtonSize.medium,
  }) {
    final screenType = getScreenType(context);
    final buttonSize = _getButtonSize(screenType, baseSize);
    
    return ElevatedButton(
      onPressed: isLoading ? null : onPressed,
      style: ElevatedButton.styleFrom(
        padding: EdgeInsets.symmetric(
          horizontal: buttonSize.horizontalPadding,
          vertical: buttonSize.verticalPadding,
        ),
        minimumSize: Size(buttonSize.minWidth, buttonSize.height),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(DesignSystem.radiusM),
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) ...[
            Icon(icon, size: buttonSize.iconSize),
            const SizedBox(width: 8),
          ],
          Text(
            text,
            style: TextStyle(
              fontSize: buttonSize.fontSize,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
  
  // Private helper methods
  static double _getMobileSpacing(BaseSpacing spacing) {
    switch (spacing) {
      case BaseSpacing.xs:
        return DesignSystem.spacingXs;
      case BaseSpacing.s:
        return DesignSystem.spacingS;
      case BaseSpacing.m:
        return DesignSystem.spacingM;
      case BaseSpacing.l:
        return DesignSystem.spacingL;
      case BaseSpacing.xl:
        return DesignSystem.spacingXl;
    }
  }
  
  static double _getTabletSpacing(BaseSpacing spacing) {
    switch (spacing) {
      case BaseSpacing.xs:
        return DesignSystem.spacingXs * 1.5;
      case BaseSpacing.s:
        return DesignSystem.spacingS * 1.5;
      case BaseSpacing.m:
        return DesignSystem.spacingM * 1.5;
      case BaseSpacing.l:
        return DesignSystem.spacingL * 1.5;
      case BaseSpacing.xl:
        return DesignSystem.spacingXl * 1.5;
    }
  }
  
  static double _getDesktopSpacing(BaseSpacing spacing) {
    switch (spacing) {
      case BaseSpacing.xs:
        return DesignSystem.spacingXs * 2;
      case BaseSpacing.s:
        return DesignSystem.spacingS * 2;
      case BaseSpacing.m:
        return DesignSystem.spacingM * 2;
      case BaseSpacing.l:
        return DesignSystem.spacingL * 2;
      case BaseSpacing.xl:
        return DesignSystem.spacingXl * 2;
    }
  }
  
  static double _getMobileFontSize(BaseFontSize baseSize) {
    switch (baseSize) {
      case BaseFontSize.display:
        return 32;
      case BaseFontSize.headline:
        return 24;
      case BaseFontSize.title:
        return 20;
      case BaseFontSize.body:
        return 16;
      case BaseFontSize.label:
        return 14;
      case BaseFontSize.caption:
        return 12;
    }
  }
  
  static double _getTabletFontSize(BaseFontSize baseSize) {
    switch (baseSize) {
      case BaseFontSize.display:
        return 40;
      case BaseFontSize.headline:
        return 28;
      case BaseFontSize.title:
        return 22;
      case BaseFontSize.body:
        return 18;
      case BaseFontSize.label:
        return 16;
      case BaseFontSize.caption:
        return 14;
    }
  }
  
  static double _getDesktopFontSize(BaseFontSize baseSize) {
    switch (baseSize) {
      case BaseFontSize.display:
        return 48;
      case BaseFontSize.headline:
        return 32;
      case BaseFontSize.title:
        return 24;
      case BaseFontSize.body:
        return 18;
      case BaseFontSize.label:
        return 16;
      case BaseFontSize.caption:
        return 14;
    }
  }
  
  static double _getLineHeight(BaseFontSize baseSize) {
    switch (baseSize) {
      case BaseFontSize.display:
        return 1.2;
      case BaseFontSize.headline:
        return 1.3;
      case BaseFontSize.title:
        return 1.4;
      case BaseFontSize.body:
        return 1.5;
      case BaseFontSize.label:
        return 1.4;
      case BaseFontSize.caption:
        return 1.3;
    }
  }
  
  static int _getColumns(
    ScreenType screenType,
    int mobileColumns,
    int? tabletColumns,
    int? desktopColumns,
  ) {
    switch (screenType) {
      case ScreenType.mobile:
        return mobileColumns;
      case ScreenType.tablet:
        return tabletColumns ?? (mobileColumns * 2);
      case ScreenType.desktop:
        return desktopColumns ?? (mobileColumns * 3);
    }
  }
  
  static double _getSpacing(
    ScreenType screenType,
    double? mobileSpacing,
    double? tabletSpacing,
    double? desktopSpacing,
  ) {
    switch (screenType) {
      case ScreenType.mobile:
        return mobileSpacing ?? DesignSystem.spacingM;
      case ScreenType.tablet:
        return tabletSpacing ?? DesignSystem.spacingL;
      case ScreenType.desktop:
        return desktopSpacing ?? DesignSystem.spacingXl;
    }
  }
  
  static EdgeInsets _getPadding(
    ScreenType screenType,
    EdgeInsets? mobilePadding,
    EdgeInsets? tabletPadding,
    EdgeInsets? desktopPadding,
  ) {
    switch (screenType) {
      case ScreenType.mobile:
        return mobilePadding ?? const EdgeInsets.all(DesignSystem.spacingM);
      case ScreenType.tablet:
        return tabletPadding ?? const EdgeInsets.all(DesignSystem.spacingL);
      case ScreenType.desktop:
        return desktopPadding ?? const EdgeInsets.all(DesignSystem.spacingXl);
    }
  }
  
  static double _getMargin(
    ScreenType screenType,
    double? mobileMargin,
    double? tabletMargin,
    double? desktopMargin,
  ) {
    switch (screenType) {
      case ScreenType.mobile:
        return mobileMargin ?? DesignSystem.spacingM;
      case ScreenType.tablet:
        return tabletMargin ?? DesignSystem.spacingL;
      case ScreenType.desktop:
        return desktopMargin ?? DesignSystem.spacingXl;
    }
  }
  
  static ButtonSize _getButtonSize(ScreenType screenType, BaseButtonSize baseSize) {
    switch (screenType) {
      case ScreenType.mobile:
        return _getMobileButtonSize(baseSize);
      case ScreenType.tablet:
        return _getTabletButtonSize(baseSize);
      case ScreenType.desktop:
        return _getDesktopButtonSize(baseSize);
    }
  }
  
  static ButtonSize _getMobileButtonSize(BaseButtonSize baseSize) {
    switch (baseSize) {
      case BaseButtonSize.small:
        return ButtonSize(
          height: 36,
          minWidth: 80,
          horizontalPadding: 12,
          verticalPadding: 8,
          fontSize: 12,
          iconSize: 16,
        );
      case BaseButtonSize.medium:
        return ButtonSize(
          height: 44,
          minWidth: 120,
          horizontalPadding: 16,
          verticalPadding: 10,
          fontSize: 14,
          iconSize: 18,
        );
      case BaseButtonSize.large:
        return ButtonSize(
          height: 52,
          minWidth: 160,
          horizontalPadding: 24,
          verticalPadding: 14,
          fontSize: 16,
          iconSize: 20,
        );
    }
  }
  
  static ButtonSize _getTabletButtonSize(BaseButtonSize baseSize) {
    switch (baseSize) {
      case BaseButtonSize.small:
        return ButtonSize(
          height: 40,
          minWidth: 100,
          horizontalPadding: 16,
          verticalPadding: 10,
          fontSize: 14,
          iconSize: 18,
        );
      case BaseButtonSize.medium:
        return ButtonSize(
          height: 48,
          minWidth: 140,
          horizontalPadding: 20,
          verticalPadding: 12,
          fontSize: 16,
          iconSize: 20,
        );
      case BaseButtonSize.large:
        return ButtonSize(
          height: 56,
          minWidth: 180,
          horizontalPadding: 28,
          verticalPadding: 16,
          fontSize: 18,
          iconSize: 22,
        );
    }
  }
  
  static ButtonSize _getDesktopButtonSize(BaseButtonSize baseSize) {
    switch (baseSize) {
      case BaseButtonSize.small:
        return ButtonSize(
          height: 44,
          minWidth: 120,
          horizontalPadding: 20,
          verticalPadding: 12,
          fontSize: 14,
          iconSize: 18,
        );
      case BaseButtonSize.medium:
        return ButtonSize(
          height: 52,
          minWidth: 160,
          horizontalPadding: 24,
          verticalPadding: 14,
          fontSize: 16,
          iconSize: 20,
        );
      case BaseButtonSize.large:
        return ButtonSize(
          height: 60,
          minWidth: 200,
          horizontalPadding: 32,
          verticalPadding: 18,
          fontSize: 18,
          iconSize: 24,
        );
    }
  }
}

// Enums
enum ScreenType { mobile, tablet, desktop }

enum BaseSpacing { xs, s, m, l, xl }

enum BaseFontSize { display, headline, title, body, label, caption }

enum BaseButtonSize { small, medium, large }

// Data classes
class ButtonSize {
  final double height;
  final double minWidth;
  final double horizontalPadding;
  final double verticalPadding;
  final double fontSize;
  final double iconSize;

  const ButtonSize({
    required this.height,
    required this.minWidth,
    required this.horizontalPadding,
    required this.verticalPadding,
    required this.fontSize,
    required this.iconSize,
  });
}