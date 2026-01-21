// lib/widgets/responsive_page_wrapper.dart
// Tüm sayfalar için unified template - Geri butonu, responsive, scrollable

import 'package:flutter/material.dart';
import '../theme/theme_colors.dart';

/// Tüm sayfalar için base wrapper - Geri butonu, responsive, scrollable
class ResponsivePageWrapper extends StatelessWidget {
  final String title;
  final Widget body;
  final List<Widget>? actions;
  final VoidCallback? onBackPressed;
  final bool showBackButton;
  final PreferredSizeWidget? appBar;
  final FloatingActionButton? floatingActionButton;
  final Color? backgroundColor;
  final bool scrollable;
  final EdgeInsets bodyPadding;
  final double maxWidth;

  const ResponsivePageWrapper({
    Key? key,
    required this.title,
    required this.body,
    this.actions,
    this.onBackPressed,
    this.showBackButton = true,
    this.appBar,
    this.floatingActionButton,
    this.backgroundColor,
    this.scrollable = true,
    this.bodyPadding = const EdgeInsets.all(16.0),
    this.maxWidth = 1200.0,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        if (onBackPressed != null) {
          onBackPressed!();
        } else {
          Navigator.pop(context);
        }
        return false;
      },
      child: Scaffold(
        backgroundColor: backgroundColor ?? ThemeColors.getBackground(context),
        appBar: appBar ??
            _buildDefaultAppBar(
              context,
              title,
              showBackButton,
              onBackPressed,
              actions,
            ),
        body: SafeArea(
          child: Center(
            child: ConstrainedBox(
              constraints: BoxConstraints(maxWidth: maxWidth),
              child: scrollable
                  ? SingleChildScrollView(
                      physics: const BouncingScrollPhysics(),
                      child: Padding(
                        padding: bodyPadding,
                        child: body,
                      ),
                    )
                  : Padding(
                      padding: bodyPadding,
                      child: body,
                    ),
            ),
          ),
        ),
        floatingActionButton: floatingActionButton,
      ),
    );
  }

  static PreferredSizeWidget _buildDefaultAppBar(
    BuildContext context,
    String title,
    bool showBackButton,
    VoidCallback? onBackPressed,
    List<Widget>? actions,
  ) {
    return AppBar(
      leading: showBackButton
          ? IconButton(
              icon: Icon(
                Icons.arrow_back,
                color: ThemeColors.getText(context),
              ),
              onPressed: onBackPressed ?? () => Navigator.pop(context),
            )
          : null,
      title: Text(
        title,
        style: TextStyle(
          color: ThemeColors.getText(context),
          fontWeight: FontWeight.w600,
        ),
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
      ),
      backgroundColor: ThemeColors.getCardBackground(context),
      elevation: 1,
      actions: actions,
      centerTitle: false,
    );
  }
}

/// Responsive grid wrapper - Flexible width widgets
class ResponsiveGrid extends StatelessWidget {
  final List<Widget> children;
  final int minColumns;
  final double horizontalSpacing;
  final double verticalSpacing;

  const ResponsiveGrid({
    Key? key,
    required this.children,
    this.minColumns = 1,
    this.horizontalSpacing = 16.0,
    this.verticalSpacing = 16.0,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    int columns = minColumns;

    if (screenWidth > 1200) {
      columns = 4;
    } else if (screenWidth > 800) {
      columns = 3;
    } else if (screenWidth > 600) {
      columns = 2;
    } else {
      columns = 1;
    }

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: columns,
        crossAxisSpacing: horizontalSpacing,
        mainAxisSpacing: verticalSpacing,
      ),
      itemCount: children.length,
      itemBuilder: (context, index) => children[index],
    );
  }
}

/// Section card - Consistent styling
class SectionCard extends StatelessWidget {
  final String? title;
  final Widget child;
  final Color? backgroundColor;
  final EdgeInsets padding;
  final VoidCallback? onTap;

  const SectionCard({
    Key? key,
    this.title,
    required this.child,
    this.backgroundColor,
    this.padding = const EdgeInsets.all(16.0),
    this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Card(
        color: backgroundColor ?? ThemeColors.getCardBackground(context),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        elevation: 2,
        child: Padding(
          padding: padding,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (title != null) ...[
                Text(
                  title!,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 12),
              ],
              child,
            ],
          ),
        ),
      ),
    );
  }
}
