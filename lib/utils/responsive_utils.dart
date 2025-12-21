// lib/utils/responsive_utils.dart
// Responsive design utilities for multi-device support

import 'package:flutter/material.dart';

/// Responsive design utilities for different screen sizes and orientations
class ResponsiveUtils {
  /// Breakpoints for different screen sizes
  static const double mobileBreakpoint = 600;
  static const double tabletBreakpoint = 1024;
  static const double desktopBreakpoint = 1440;

  /// Get current screen type based on width
  static ScreenType getScreenType(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;

    if (screenWidth < mobileBreakpoint) {
      return ScreenType.mobile;
    } else if (screenWidth < tabletBreakpoint) {
      return ScreenType.tablet;
    } else {
      return ScreenType.desktop;
    }
  }

  /// Check if screen is in landscape orientation
  static bool isLandscape(BuildContext context) {
    return MediaQuery.of(context).orientation == Orientation.landscape;
  }

  /// Check if screen is in portrait orientation
  static bool isPortrait(BuildContext context) {
    return MediaQuery.of(context).orientation == Orientation.portrait;
  }

  /// Get appropriate spacing based on screen size
  static double getSpacing(BuildContext context,
      {SpacingType type = SpacingType.medium}) {
    final screenType = getScreenType(context);
    final landscape = isLandscape(context);

    double multiplier = 1.0;

    // Adjust spacing based on screen type
    switch (screenType) {
      case ScreenType.mobile:
        multiplier = landscape ? 0.8 : 1.0;
        break;
      case ScreenType.tablet:
        multiplier = landscape ? 1.2 : 1.1;
        break;
      case ScreenType.desktop:
        multiplier = landscape ? 1.4 : 1.3;
        break;
    }

    // Base spacing values
    final spacingMap = {
      SpacingType.extraSmall: 4.0,
      SpacingType.small: 8.0,
      SpacingType.medium: 16.0,
      SpacingType.large: 24.0,
      SpacingType.extraLarge: 32.0,
      SpacingType.huge: 48.0,
    };

    return spacingMap[type]! * multiplier;
  }

  /// Get appropriate font size based on screen size
  static double getFontSize(
    BuildContext context,
    double baseSize, {
    FontSizeType type = FontSizeType.medium,
  }) {
    final screenType = getScreenType(context);
    final textScaler = MediaQuery.of(context).textScaler.scale(1.0);

    double multiplier = 1.0;

    // Adjust font size based on screen type and type
    switch (screenType) {
      case ScreenType.mobile:
        multiplier = type == FontSizeType.large
            ? 1.1
            : type == FontSizeType.small
                ? 0.9
                : 1.0;
        break;
      case ScreenType.tablet:
        multiplier = type == FontSizeType.large
            ? 1.2
            : type == FontSizeType.small
                ? 0.95
                : 1.1;
        break;
      case ScreenType.desktop:
        multiplier = type == FontSizeType.large
            ? 1.3
            : type == FontSizeType.small
                ? 1.0
                : 1.2;
        break;
    }

    return baseSize * multiplier * textScaler;
  }

  /// Create responsive layout based on screen size
  static Widget responsiveLayout({
    required BuildContext context,
    required Widget mobile,
    Widget? tablet,
    Widget? desktop,
    double? maxWidth,
  }) {
    final screenType = getScreenType(context);

    Widget child;
    if (screenType == ScreenType.desktop && desktop != null) {
      child = desktop;
    } else if (screenType == ScreenType.tablet && tablet != null) {
      child = tablet;
    } else {
      child = mobile;
    }

    if (maxWidth != null) {
      return Center(
        child: ConstrainedBox(
          constraints: BoxConstraints(maxWidth: maxWidth),
          child: child,
        ),
      );
    }

    return child;
  }

  /// Create responsive grid layout
  static Widget responsiveGrid({
    required BuildContext context,
    required int mobileColumns,
    required int tabletColumns,
    required int desktopColumns,
    required Widget Function(int index) itemBuilder,
    required int itemCount,
    double? maxWidth,
    EdgeInsets? padding,
    double? crossAxisSpacing,
    double? mainAxisSpacing,
  }) {
    final screenType = getScreenType(context);

    int columns;
    switch (screenType) {
      case ScreenType.mobile:
        columns = mobileColumns;
        break;
      case ScreenType.tablet:
        columns = tabletColumns;
        break;
      case ScreenType.desktop:
        columns = desktopColumns;
        break;
    }

    Widget grid = GridView.builder(
      padding: padding ?? EdgeInsets.all(getSpacing(context)),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: columns,
        crossAxisSpacing: crossAxisSpacing ?? getSpacing(context),
        mainAxisSpacing: mainAxisSpacing ?? getSpacing(context),
        childAspectRatio: 1.0,
      ),
      itemCount: itemCount,
      itemBuilder: (context, index) => itemBuilder(index),
    );

    if (maxWidth != null) {
      return Center(
        child: ConstrainedBox(
          constraints: BoxConstraints(maxWidth: maxWidth),
          child: grid,
        ),
      );
    }

    return grid;
  }

  /// Create responsive list layout
  static Widget responsiveList({
    required BuildContext context,
    required Widget Function(int index) itemBuilder,
    required int itemCount,
    double? maxWidth,
    EdgeInsets? padding,
    double? separatorHeight,
    Widget? header,
    Widget? footer,
  }) {
    Widget list = ListView.separated(
      padding: padding ?? EdgeInsets.all(getSpacing(context)),
      itemCount: itemCount,
      separatorBuilder: (context, index) => SizedBox(
        height: separatorHeight ?? getSpacing(context, type: SpacingType.small),
      ),
      itemBuilder: (context, index) => itemBuilder(index),
    );

    if (header != null || footer != null) {
      list = Column(
        children: [
          if (header != null) header,
          Expanded(child: list),
          if (footer != null) footer,
        ],
      );
    }

    if (maxWidth != null) {
      return Center(
        child: ConstrainedBox(
          constraints: BoxConstraints(maxWidth: maxWidth),
          child: list,
        ),
      );
    }

    return list;
  }

  /// Create responsive card layout
  static Widget responsiveCard({
    required BuildContext context,
    required Widget child,
    double? maxWidth,
    EdgeInsets? margin,
    EdgeInsets? padding,
    VoidCallback? onTap,
  }) {
    final screenType = getScreenType(context);

    // Adjust card properties based on screen type
    final cardMargin = margin ??
        EdgeInsets.symmetric(
          horizontal: getSpacing(context, type: SpacingType.medium),
          vertical: getSpacing(context, type: SpacingType.small),
        );

    final cardPadding = padding ??
        EdgeInsets.all(
          getSpacing(context, type: SpacingType.medium) *
              (screenType == ScreenType.mobile ? 1.0 : 1.2),
        );

    Widget card = Card(
      margin: cardMargin,
      child: Padding(
        padding: cardPadding,
        child: child,
      ),
    );

    if (onTap != null) {
      card = InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: card,
      );
    }

    if (maxWidth != null) {
      card = Center(
        child: ConstrainedBox(
          constraints: BoxConstraints(maxWidth: maxWidth),
          child: card,
        ),
      );
    }

    return card;
  }

  /// Create responsive button layout
  static Widget responsiveButton({
    required BuildContext context,
    required VoidCallback onPressed,
    required Widget child,
    double? maxWidth,
    EdgeInsets? padding,
    double? height,
  }) {
    final buttonHeight =
        height ?? getSpacing(context, type: SpacingType.extraLarge);
    final buttonPadding = padding ??
        EdgeInsets.symmetric(
          horizontal: getSpacing(context, type: SpacingType.large),
          vertical: getSpacing(context, type: SpacingType.small),
        );

    Widget button = SizedBox(
      height: buttonHeight,
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          padding: buttonPadding,
          minimumSize: Size(double.infinity, buttonHeight),
        ),
        child: child,
      ),
    );

    if (maxWidth != null) {
      button = Center(
        child: ConstrainedBox(
          constraints: BoxConstraints(maxWidth: maxWidth),
          child: button,
        ),
      );
    }

    return button;
  }

  /// Get appropriate app bar height based on screen size
  static double getAppBarHeight(BuildContext context) {
    final screenType = getScreenType(context);
    final landscape = isLandscape(context);

    switch (screenType) {
      case ScreenType.mobile:
        return landscape ? 56.0 : kToolbarHeight;
      case ScreenType.tablet:
        return landscape ? 64.0 : kToolbarHeight + 8;
      case ScreenType.desktop:
        return landscape ? 72.0 : kToolbarHeight + 16;
    }
  }

  /// Get appropriate bottom navigation bar height
  static double getBottomNavBarHeight(BuildContext context) {
    final screenType = getScreenType(context);

    switch (screenType) {
      case ScreenType.mobile:
        return kBottomNavigationBarHeight;
      case ScreenType.tablet:
        return kBottomNavigationBarHeight + 8;
      case ScreenType.desktop:
        return kBottomNavigationBarHeight + 16;
    }
  }

  /// Create responsive navigation rail
  static Widget responsiveNavigationRail({
    required BuildContext context,
    required int selectedIndex,
    required List<NavigationRailDestination> destinations,
    required ValueChanged<int> onDestinationSelected,
    Widget? leading,
    Widget? trailing,
    double? groupAlignment,
  }) {
    final screenType = getScreenType(context);

    if (screenType == ScreenType.mobile) {
      // Return empty on mobile - should use bottom navigation instead
      return const SizedBox.shrink();
    }

    return NavigationRail(
      selectedIndex: selectedIndex,
      onDestinationSelected: onDestinationSelected,
      destinations: destinations,
      leading: leading,
      trailing: trailing,
      groupAlignment: groupAlignment ?? -1.0,
      labelType: screenType == ScreenType.desktop
          ? NavigationRailLabelType.none
          : NavigationRailLabelType.all,
    );
  }

  /// Create responsive floating action button
  static Widget responsiveFAB({
    required BuildContext context,
    required VoidCallback onPressed,
    required Widget child,
    String? tooltip,
    FloatingActionButtonLocation? location,
  }) {
    final screenType = getScreenType(context);

    // Hide FAB on desktop - use different interaction pattern
    if (screenType == ScreenType.desktop) {
      return const SizedBox.shrink();
    }

    return FloatingActionButton(
      onPressed: onPressed,
      tooltip: tooltip,
      child: child,
    );
  }

  /// Create responsive dialog
  static Widget responsiveDialog({
    required BuildContext context,
    required Widget child,
    double? maxWidth,
    EdgeInsets? padding,
  }) {
    final screenType = getScreenType(context);
    final screenSize = MediaQuery.of(context).size;

    double dialogMaxWidth;
    if (maxWidth != null) {
      dialogMaxWidth = maxWidth;
    } else {
      switch (screenType) {
        case ScreenType.mobile:
          dialogMaxWidth = screenSize.width * 0.9;
          break;
        case ScreenType.tablet:
          dialogMaxWidth = screenSize.width * 0.7;
          break;
        case ScreenType.desktop:
          dialogMaxWidth = screenSize.width * 0.5;
          break;
      }
    }

    return ConstrainedBox(
      constraints: BoxConstraints(maxWidth: dialogMaxWidth),
      child: Padding(
        padding: padding ??
            EdgeInsets.all(getSpacing(context, type: SpacingType.large)),
        child: child,
      ),
    );
  }

  /// Create responsive game board layout
  static Widget responsiveGameBoard({
    required BuildContext context,
    required Widget boardWidget,
    required Widget infoPanel,
    double? maxWidth,
  }) {
    final screenType = getScreenType(context);
    final landscape = isLandscape(context);

    if (screenType == ScreenType.mobile ||
        (screenType == ScreenType.tablet && !landscape)) {
      // Stack layout for mobile/portrait
      return responsiveLayout(
        context: context,
        mobile: Column(
          children: [
            Expanded(child: boardWidget),
            SizedBox(height: getSpacing(context)),
            infoPanel,
          ],
        ),
        maxWidth: maxWidth,
      );
    } else {
      // Side-by-side layout for tablet landscape/desktop
      return responsiveLayout(
        context: context,
        mobile: Column(
          children: [
            Expanded(child: boardWidget),
            SizedBox(height: getSpacing(context)),
            infoPanel,
          ],
        ),
        tablet: Row(
          children: [
            Expanded(flex: 3, child: boardWidget),
            SizedBox(width: getSpacing(context)),
            Expanded(flex: 2, child: infoPanel),
          ],
        ),
        desktop: Row(
          children: [
            Expanded(flex: 4, child: boardWidget),
            SizedBox(width: getSpacing(context)),
            Expanded(flex: 2, child: infoPanel),
          ],
        ),
        maxWidth: maxWidth,
      );
    }
  }

  /// Check if device is in safe area
  static EdgeInsets getSafeArea(BuildContext context) {
    return MediaQuery.of(context).padding;
  }

  /// Get device pixel ratio for scaling
  static double getDevicePixelRatio(BuildContext context) {
    return MediaQuery.of(context).devicePixelRatio;
  }

  /// Create responsive breakpoint widget
  static Widget responsiveBreakpoint({
    required BuildContext context,
    required Widget Function(BuildContext context) builder,
    double? minWidth,
    double? maxWidth,
  }) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final width = constraints.maxWidth;

        if ((minWidth == null || width >= minWidth) &&
            (maxWidth == null || width <= maxWidth)) {
          return builder(context);
        }

        return const SizedBox.shrink();
      },
    );
  }
}

/// Screen types for responsive design
enum ScreenType {
  mobile,
  tablet,
  desktop,
}

/// Spacing types for responsive spacing
enum SpacingType {
  extraSmall,
  small,
  medium,
  large,
  extraLarge,
  huge,
}

/// Font size types for responsive typography
enum FontSizeType {
  small,
  medium,
  large,
}
