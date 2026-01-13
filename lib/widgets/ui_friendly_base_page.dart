// lib/widgets/ui_friendly_base_page.dart
// UI-friendly base page with consistent styling and animations

import 'package:flutter/material.dart';

/// UI Friendly Page Enum for different page types
enum PageType {
  auth,      // Authentication pages
  main,      // Main app pages
  modal,     // Modal pages
  detail,    // Detail pages
}

/// UI-friendly base page with consistent design patterns
class UIFriendlyBasePage extends StatefulWidget {
  final Widget body;
  final String? title;
  final List<Widget>? appBarActions;
  final Widget? floatingActionButton;
  final FloatingActionButtonLocation? fabLocation;
  final PreferredSizeWidget? bottomNavigationBar;
  final Widget? drawer;
  final Widget? endDrawer;
  final PageType pageType;
  final bool showAppBar;
  final bool showBackButton;
  final VoidCallback? onBackPressed;
  final Color? backgroundColor;
  final Animation<double>? pageAnimation;
  final IndexedWidgetBuilder? sliverAppBar;
  final Widget? header;
  final bool scrollable;
  final ScrollController? scrollController;
  final EdgeInsets? bodyPadding;

  const UIFriendlyBasePage({
    Key? key,
    required this.body,
    this.title,
    this.appBarActions,
    this.floatingActionButton,
    this.fabLocation,
    this.bottomNavigationBar,
    this.drawer,
    this.endDrawer,
    this.pageType = PageType.main,
    this.showAppBar = true,
    this.showBackButton = true,
    this.onBackPressed,
    this.backgroundColor,
    this.pageAnimation,
    this.sliverAppBar,
    this.header,
    this.scrollable = true,
    this.scrollController,
    this.bodyPadding = const EdgeInsets.all(16.0),
  }) : super(key: key);

  @override
  State<UIFriendlyBasePage> createState() => _UIFriendlyBasePageState();
}

class _UIFriendlyBasePageState extends State<UIFriendlyBasePage>
    with SingleTickerProviderStateMixin {
  late AnimationController _fadeController;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();

    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _fadeController, curve: Curves.easeInOut),
    );

    _fadeController.forward();
  }

  @override
  void dispose() {
    _fadeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: _fadeAnimation,
      child: Scaffold(
        appBar: widget.showAppBar ? _buildAppBar() : null,
        body: _buildBody(),
        floatingActionButton: widget.floatingActionButton,
        floatingActionButtonLocation: widget.fabLocation,
        bottomNavigationBar: widget.bottomNavigationBar,
        drawer: widget.drawer,
        endDrawer: widget.endDrawer,
        backgroundColor: widget.backgroundColor ?? Colors.white,
      ),
    );
  }

  /// Build AppBar based on page type
  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      title: widget.title != null
          ? Text(
              widget.title!,
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            )
          : null,
      centerTitle: true,
      elevation: 0,
      backgroundColor: _getAppBarColor(),
      leading: widget.showBackButton
          ? _buildBackButton()
          : null,
      actions: widget.appBarActions,
    );
  }

  /// Build back button with animation
  Widget _buildBackButton() {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () {
            if (widget.onBackPressed != null) {
              widget.onBackPressed!();
            } else {
              Navigator.of(context).pop();
            }
          },
          borderRadius: BorderRadius.circular(8),
          child: const Icon(Icons.arrow_back_ios_new),
        ),
      ),
    );
  }

  /// Get AppBar color based on page type
  Color _getAppBarColor() {
    return switch (widget.pageType) {
      PageType.auth => Colors.white,
      PageType.modal => Colors.white,
      PageType.main => Theme.of(context).primaryColor,
      PageType.detail => Colors.white,
    };
  }

  /// Build body with scrollable option
  Widget _buildBody() {
    final contentWidget = Padding(
      padding: widget.bodyPadding ?? EdgeInsets.zero,
      child: widget.body,
    );

    if (!widget.scrollable) {
      return contentWidget;
    }

    return SingleChildScrollView(
      controller: widget.scrollController,
      physics: const BouncingScrollPhysics(),
      child: contentWidget,
    );
  }
}

/// Safe area wrapper for better spacing
class SafePageBody extends StatelessWidget {
  final Widget child;
  final EdgeInsets? padding;

  const SafePageBody({
    Key? key,
    required this.child,
    this.padding,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: padding ?? const EdgeInsets.all(16.0),
        child: child,
      ),
    );
  }
}

/// Responsive page builder
class ResponsivePage extends StatelessWidget {
  final Widget mobileBody;
  final Widget? tabletBody;
  final Widget? desktopBody;
  final String? title;
  final List<Widget>? appBarActions;

  const ResponsivePage({
    Key? key,
    required this.mobileBody,
    this.tabletBody,
    this.desktopBody,
    this.title,
    this.appBarActions,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;

    Widget body;
    if (screenWidth < 600) {
      body = mobileBody;
    } else if (screenWidth < 1024) {
      body = tabletBody ?? mobileBody;
    } else {
      body = desktopBody ?? tabletBody ?? mobileBody;
    }

    return UIFriendlyBasePage(
      title: title,
      appBarActions: appBarActions,
      body: body,
    );
  }
}

/// Loading page state
class LoadingPage extends StatelessWidget {
  final String? message;
  final Color? color;

  const LoadingPage({
    Key? key,
    this.message,
    this.color,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return UIFriendlyBasePage(
      showAppBar: false,
      scrollable: false,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation(
                color ?? Theme.of(context).primaryColor,
              ),
            ),
            if (message != null) ...[
              const SizedBox(height: 16),
              Text(
                message!,
                style: Theme.of(context).textTheme.bodyMedium,
                textAlign: TextAlign.center,
              ),
            ],
          ],
        ),
      ),
    );
  }
}

/// Error page state
class ErrorPage extends StatelessWidget {
  final String title;
  final String message;
  final String? buttonText;
  final VoidCallback? onRetry;
  final IconData icon;

  const ErrorPage({
    Key? key,
    required this.title,
    required this.message,
    this.buttonText,
    this.onRetry,
    this.icon = Icons.error_outline,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return UIFriendlyBasePage(
      showAppBar: false,
      scrollable: false,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              size: 64,
              color: Colors.red,
            ),
            const SizedBox(height: 24),
            Text(
              title,
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 12),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 32),
              child: Text(
                message,
                style: Theme.of(context).textTheme.bodyMedium,
                textAlign: TextAlign.center,
              ),
            ),
            if (onRetry != null) ...[
              const SizedBox(height: 32),
              ElevatedButton.icon(
                onPressed: onRetry,
                icon: const Icon(Icons.refresh),
                label: Text(buttonText ?? 'Tekrar Dene'),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

/// Empty state page
class EmptyPage extends StatelessWidget {
  final String title;
  final String message;
  final IconData icon;
  final String? actionText;
  final VoidCallback? onAction;

  const EmptyPage({
    Key? key,
    required this.title,
    required this.message,
    this.icon = Icons.inbox,
    this.actionText,
    this.onAction,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return UIFriendlyBasePage(
      showAppBar: false,
      scrollable: false,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              size: 64,
              color: Colors.grey,
            ),
            const SizedBox(height: 24),
            Text(
              title,
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 12),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 32),
              child: Text(
                message,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: Colors.grey,
                ),
                textAlign: TextAlign.center,
              ),
            ),
            if (onAction != null && actionText != null) ...[
              const SizedBox(height: 32),
              ElevatedButton(
                onPressed: onAction,
                child: Text(actionText!),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
