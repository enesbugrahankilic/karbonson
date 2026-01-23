// lib/widgets/premium_page_transition.dart
// Apple Quality Page Transitions - Smooth & Natural Animations

import 'package:flutter/material.dart';

/// Cupertino-style page route with smooth animations
class CupertinoStylePageRoute<T> extends PageRoute<T> {
  CupertinoStylePageRoute({
    required this.builder,
    RouteSettings? settings,
    bool maintainState = true,
    this.fullscreenDialog = false,
  }) : _maintainState = maintainState ?? true, super(settings: settings);

  final WidgetBuilder builder;
  final bool _maintainState;

  @override
  final bool fullscreenDialog;

  @override
  Duration get transitionDuration => const Duration(milliseconds: 400);

  @override
  Color? get barrierColor => null;

  @override
  String? get barrierLabel => null;

  @override
  bool get opaque => true;

  @override
  Widget buildPage(
    BuildContext context,
    Animation<double> animation,
    Animation<double> secondaryAnimation,
  ) {
    return builder(context);
  }

  @override
  Widget buildTransitions(
    BuildContext context,
    Animation<double> animation,
    Animation<double> secondaryAnimation,
    Widget child,
  ) {
    // Slide in from right animation
    const begin = Offset(1.0, 0.0);
    const end = Offset.zero;
    const curve = Curves.easeOutCubic;

    final tween = Tween(begin: begin, end: end).chain(
      CurveTween(curve: curve),
    );

    return SlideTransition(
      position: animation.drive(tween),
      child: FadeTransition(
        opacity: animation,
        child: child,
      ),
    );
  }

  @override
  bool get maintainState => _maintainState;
}

/// Pop transition with reverse animation
class PremiumPageRouteBuilder<T> extends PageRouteBuilder<T> {
  PremiumPageRouteBuilder({
    required WidgetBuilder pageBuilder,
    RouteSettings? settings,
    Curve transitionCurve = Curves.easeOutCubic,
    Duration transitionDuration = const Duration(milliseconds: 400),
  }) : super(
    settings: settings,
    transitionDuration: transitionDuration,
    pageBuilder: (context, animation, secondaryAnimation) {
      return pageBuilder(context);
    },
    transitionsBuilder: (
      context,
      animation,
      secondaryAnimation,
      child,
    ) {
      // Forward animation (entering page)
      final slideTween = Tween<Offset>(
        begin: const Offset(1.0, 0.0),
        end: Offset.zero,
      ).chain(CurveTween(curve: transitionCurve));

      final fadeTween = Tween<double>(begin: 0.0, end: 1.0)
          .chain(CurveTween(curve: transitionCurve));

      // Reverse animation (exiting page)
      final reverseSlide = Tween<Offset>(
        begin: Offset.zero,
        end: const Offset(-0.3, 0.0),
      ).chain(CurveTween(curve: Curves.easeInCubic));

      final reverseFade = Tween<double>(begin: 1.0, end: 0.9)
          .chain(CurveTween(curve: Curves.easeInCubic));

      return SlideTransition(
        position: animation.drive(slideTween),
        child: FadeTransition(
          opacity: animation.drive(fadeTween),
          child: SlideTransition(
            position: secondaryAnimation.drive(reverseSlide),
            child: FadeTransition(
              opacity: secondaryAnimation.drive(reverseFade),
              child: child,
            ),
          ),
        ),
      );
    },
  );
}

/// Shared axis transition (Google Material Design)
class SharedAxisPageRoute<T> extends PageRouteBuilder<T> {
  SharedAxisPageRoute({
    required WidgetBuilder pageBuilder,
    RouteSettings? settings,
  }) : super(
    settings: settings,
    transitionDuration: const Duration(milliseconds: 350),
    pageBuilder: (context, animation, secondaryAnimation) {
      return pageBuilder(context);
    },
    transitionsBuilder: (
      context,
      animation,
      secondaryAnimation,
      child,
    ) {
      final tween = Tween<double>(begin: 0.0, end: 1.0)
          .chain(CurveTween(curve: Curves.easeOutCubic));

      return ScaleTransition(
        scale: animation.drive(tween),
        child: FadeTransition(
          opacity: animation,
          child: child,
        ),
      );
    },
  );
}

/// Fade through transition (smooth fade)
class FadeThroughPageRoute<T> extends PageRouteBuilder<T> {
  FadeThroughPageRoute({
    required WidgetBuilder pageBuilder,
    RouteSettings? settings,
  }) : super(
    settings: settings,
    transitionDuration: const Duration(milliseconds: 300),
    pageBuilder: (context, animation, secondaryAnimation) {
      return pageBuilder(context);
    },
    transitionsBuilder: (
      context,
      animation,
      secondaryAnimation,
      child,
    ) {
      return FadeTransition(
        opacity: animation,
        child: child,
      );
    },
  );
}

/// Modal transition (bottom sheet style)
class ModalPageRoute<T> extends PageRouteBuilder<T> {
  ModalPageRoute({
    required WidgetBuilder pageBuilder,
    RouteSettings? settings,
  }) : super(
    settings: settings,
    opaque: false,
    barrierColor: Colors.black.withValues(alpha: 0.3),
    barrierDismissible: true,
    transitionDuration: const Duration(milliseconds: 350),
    pageBuilder: (context, animation, secondaryAnimation) {
      return pageBuilder(context);
    },
    transitionsBuilder: (
      context,
      animation,
      secondaryAnimation,
      child,
    ) {
      final slideTween = Tween<Offset>(
        begin: const Offset(0.0, 1.0),
        end: Offset.zero,
      ).chain(CurveTween(curve: Curves.easeOutCubic));

      return SlideTransition(
        position: animation.drive(slideTween),
        child: FadeTransition(
          opacity: animation,
          child: child,
        ),
      );
    },
  );
}
