import 'package:flutter/material.dart';
import '../config/app_config.dart';
import '../theme/app_theme.dart';
import '../utils/responsive_utils.dart';
import 'loading_widgets.dart';
import 'error_widgets.dart';

/// Temel UI bileşenleri - uygulama genelinde kullanılan ortak widget'lar
class CommonWidgets {
  /// Standart uygulama başlığı
  static Widget appTitle({
    Key? key,
    String? title,
    TextStyle? style,
    TextAlign? textAlign,
    int? maxLines,
    TextOverflow? overflow,
  }) {
    return Text(
      title ?? AppConfig.appName,
      key: key,
      style: style ??
          AppTheme.headlineMedium.copyWith(
            color: AppTheme.colors.primary,
            fontWeight: FontWeight.bold,
          ),
      textAlign: textAlign,
      maxLines: maxLines,
      overflow: overflow,
    );
  }

  /// Standart alt başlık
  static Widget subtitle({
    Key? key,
    required String text,
    TextStyle? style,
    TextAlign? textAlign,
    int? maxLines,
  }) {
    return Text(
      text,
      key: key,
      style: style ??
          AppTheme.bodyMedium.copyWith(
            color: AppTheme.colors.onSurface.withOpacity( 0.7),
          ),
      textAlign: textAlign,
      maxLines: maxLines,
    );
  }

  /// Standart divizör çizgisi
  static Widget divider({
    Key? key,
    double? height,
    double? thickness,
    Color? color,
    EdgeInsetsGeometry? margin,
    EdgeInsetsGeometry? padding,
  }) {
    return Container(
      key: key,
      margin: margin,
      padding: padding,
      child: Divider(
        height: height,
        thickness: thickness,
        color: color ?? AppTheme.colors.outline.withOpacity( 0.2),
      ),
    );
  }

  /// Standart boşluk (spacer)
  static Widget spacer({
    Key? key,
    double? flex,
    double? height,
    double? width,
  }) {
    if (flex != null) {
      return Expanded(flex: flex.toInt(), child: Container());
    } else if (height != null || width != null) {
      return SizedBox(
        key: key,
        height: height,
        width: width,
      );
    }
    return SizedBox(key: key);
  }

  /// Standart padding container
  static Widget padding({
    Key? key,
    required Widget child,
    EdgeInsetsGeometry? padding,
    EdgeInsetsGeometry? margin,
    Color? backgroundColor,
    double? borderRadius,
    List<BoxShadow>? boxShadow,
    BoxBorder? border,
    double? width,
    double? height,
  }) {
    return Container(
      key: key,
      width: width,
      height: height,
      margin: margin,
      padding: padding ?? const EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(borderRadius ?? 8),
        border: border,
        boxShadow: boxShadow,
      ),
      child: child,
    );
  }

  /// İkon ile birlikte metin gösteren widget
  static Widget iconText({
    Key? key,
    required IconData icon,
    required String text,
    IconSize iconSize = IconSize.medium,
    Color? iconColor,
    TextStyle? textStyle,
    MainAxisAlignment mainAxisAlignment = MainAxisAlignment.start,
    CrossAxisAlignment crossAxisAlignment = CrossAxisAlignment.center,
    double? spacing,
  }) {
    return Row(
      key: key,
      mainAxisAlignment: mainAxisAlignment,
      crossAxisAlignment: crossAxisAlignment,
      children: [
        Icon(
          icon,
          size: _getIconSize(iconSize),
          color: iconColor ?? AppTheme.colors.primary,
        ),
        SizedBox(width: spacing ?? 8),
        Expanded(
          child: Text(
            text,
            style: textStyle ?? AppTheme.bodyMedium,
          ),
        ),
      ],
    );
  }

  /// Durum gösteren badge/pill widget
  static Widget statusBadge({
    Key? key,
    required String text,
    required BadgeStatus status,
    TextStyle? textStyle,
    EdgeInsetsGeometry? padding,
    double? borderRadius,
  }) {
    Color backgroundColor;
    Color textColor;
    IconData? icon;

    switch (status) {
      case BadgeStatus.success:
        backgroundColor = Colors.green.shade100;
        textColor = Colors.green.shade800;
        icon = Icons.check_circle;
        break;
      case BadgeStatus.warning:
        backgroundColor = Colors.amber.shade100;
        textColor = Colors.amber.shade800;
        icon = Icons.warning;
        break;
      case BadgeStatus.error:
        backgroundColor = Colors.red.shade100;
        textColor = Colors.red.shade800;
        icon = Icons.error;
        break;
      case BadgeStatus.info:
        backgroundColor = Colors.blue.shade100;
        textColor = Colors.blue.shade800;
        icon = Icons.info;
        break;
      default:
        backgroundColor = Colors.grey.shade100;
        textColor = Colors.grey.shade800;
    }

    return Container(
      key: key,
      padding: padding ?? EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(borderRadius ?? 16),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) ...[
            Icon(
              icon,
              size: 16,
              color: textColor,
            ),
            SizedBox(width: 4),
          ],
          Text(
            text,
            style: (textStyle ?? AppTheme.bodySmall).copyWith(
              color: textColor,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  /// Standart card widget
  static Widget card({
    Key? key,
    required Widget child,
    EdgeInsetsGeometry? padding,
    EdgeInsetsGeometry? margin,
    Color? backgroundColor,
    double? elevation,
    double? borderRadius,
    List<BoxShadow>? boxShadow,
    BoxBorder? border,
  }) {
    return Card(
      key: key,
      elevation: elevation ?? 2,
      color: backgroundColor,
      margin: margin,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(borderRadius ?? 12),
        side: border == null
            ? BorderSide.none
            : (border as Border).top,
      ),
      child: Container(
        padding: padding ?? EdgeInsets.all(16),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(borderRadius ?? 12),
          boxShadow: boxShadow,
        ),
        child: child,
      ),
    );
  }

  /// Standart list tile
  static Widget listTile({
    Key? key,
    Widget? leading,
    required Widget title,
    Widget? subtitle,
    Widget? trailing,
    VoidCallback? onTap,
    bool? dense,
    EdgeInsetsGeometry? contentPadding,
  }) {
    return ListTile(
      key: key,
      leading: leading,
      title: title,
      subtitle: subtitle,
      trailing: trailing,
      onTap: onTap,
      dense: dense ?? false,
      contentPadding: contentPadding,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
      ),
    );
  }

  /// Fade animation wrapper
  static Widget fadeIn({
    Key? key,
    required Widget child,
    Duration duration = const Duration(milliseconds: 300),
    Duration? delay,
    AnimationController? controller,
  }) {
    return AnimatedBuilder(
      animation: controller ?? _defaultController,
      builder: (context, child) {
        return FadeTransition(
          opacity: controller?.view ?? _defaultController.animation,
          child: child,
        );
      },
      child: child,
    );
  }

  /// Slide animation wrapper
  static Widget slideIn({
    Key? key,
    required Widget child,
    Duration duration = const Duration(milliseconds: 300),
    SlideDirection direction = SlideDirection.up,
    double offset = 50.0,
  }) {
    return AnimatedBuilder(
      animation: _defaultController,
      builder: (context, child) {
        Offset beginOffset = _getSlideOffset(direction, offset);
        return SlideTransition(
          position: Tween<Offset>(
            begin: beginOffset,
            end: Offset.zero,
          ).animate(_defaultController.animation),
          child: child,
        );
      },
      child: child,
    );
  }

  /// Size transition wrapper
  static Widget sizeTransition({
    Key? key,
    required Widget child,
    Duration duration = const Duration(milliseconds: 200),
  }) {
    return AnimatedBuilder(
      animation: _defaultController,
      builder: (context, child) {
        return SizeTransition(
          sizeFactor: _defaultController.animation,
          child: child,
        );
      },
      child: child,
    );
  }

  /// Inkwell wrapper for touch feedback
  static Widget touchFeedback({
    Key? key,
    required Widget child,
    VoidCallback? onTap,
    BorderRadius? borderRadius,
    Color? splashColor,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        key: key,
        onTap: onTap,
        borderRadius: borderRadius ?? BorderRadius.circular(8),
        splashColor: splashColor ?? AppTheme.colors.primary.withOpacity( 0.1),
        child: child,
      ),
    );
  }

  /// Hero animation wrapper
  static Widget hero({
    Key? key,
    required String tag,
    required Widget child,
    HeroFlightShuttleBuilder? flightShuttleBuilder,
    Duration? placeholderDuration,
  }) {
    return Hero(
      key: key,
      tag: tag,
      flightShuttleBuilder: flightShuttleBuilder,
      placeholderBuilder: (context, animation, child) {
        return SizedBox(
          child: child,
        );
      },
      child: child,
    );
  }

  /// Custom scroll view wrapper
  static Widget scrollView({
    Key? key,
    required Widget child,
    ScrollController? controller,
    ScrollPhysics? physics,
    EdgeInsetsGeometry? padding,
    bool primary = true,
    bool shrinkWrap = false,
  }) {
    return CustomScrollView(
      key: key,
      controller: controller,
      physics: physics ?? const BouncingScrollPhysics(),
      primary: primary,
      shrinkWrap: shrinkWrap,
      slivers: [
        if (padding != null) SliverPadding(padding: padding),
        SliverToBoxAdapter(child: child),
      ],
    );
  }

  /// Scroll to top button
  static Widget scrollToTopButton({
    Key? key,
    required ScrollController controller,
    VoidCallback? onPressed,
  }) {
    return ValueListenableBuilder<bool>(
      valueListenable: _scrollToTopVisible,
      builder: (context, isVisible, child) {
        if (!isVisible) return SizedBox.shrink();

        return Positioned(
          bottom: 16,
          right: 16,
          child: FloatingActionButton(
            key: key,
            onPressed: onPressed ?? () {
              controller.animateTo(
                0,
                duration: Duration(milliseconds: 300),
                curve: Curves.easeOut,
              );
            },
            child: Icon(Icons.keyboard_arrow_up),
            backgroundColor: AppTheme.colors.primary,
            foregroundColor: AppTheme.colors.onPrimary,
          ),
        );
      },
    );
  }

  /// Utility methods
  static double _getIconSize(IconSize size) {
    switch (size) {
      case IconSize.small:
        return 16;
      case IconSize.medium:
        return 24;
      case IconSize.large:
        return 32;
      case IconSize.extraLarge:
        return 48;
    }
  }

  static Offset _getSlideOffset(SlideDirection direction, double offset) {
    switch (direction) {
      case SlideDirection.up:
        return Offset(0, offset);
      case SlideDirection.down:
        return Offset(0, -offset);
      case SlideDirection.left:
        return Offset(offset, 0);
      case SlideDirection.right:
        return Offset(-offset, 0);
    }
  }
}

/// İkon boyutları
enum IconSize {
  small(16),
  medium(24),
  large(32),
  extraLarge(48);

  const IconSize(this.size);
  final double size;
}

/// Badge durumları
enum BadgeStatus {
  success,
  warning,
  error,
  info,
}

/// Animasyon yönleri
enum SlideDirection {
  up,
  down,
  left,
  right,
}

/// Varsayılan animasyon controller
class _DefaultController extends ChangeNotifier {
  late AnimationController _controller;
  late Animation<double> _animation;

  AnimationController get controller => _controller;
  Animation<double> get animation => _animation;

  void initialize(TickerProvider vsync) {
    _controller = AnimationController(
      duration: Duration(milliseconds: 300),
      vsync: vsync,
    );
    _animation = CurvedAnimation(
      parent: _controller,
      curve: Curves.easeInOut,
    );
  }

  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void start() {
    _controller.forward();
  }

  void reverse() {
    _controller.reverse();
  }
}

/// Scroll to top görünürlük state'i
final ValueNotifier<bool> _scrollToTopVisible = ValueNotifier<bool>(false);

/// Varsayılan animasyon controller
final _DefaultController _defaultController = _DefaultController();