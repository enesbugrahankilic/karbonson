// Apple Quality Page Templates - Premium & Refined Design System

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../theme/theme_colors.dart';
import '../theme/design_system.dart';
import '../theme/apple_design_system.dart';

/// Premium AppBar - Apple Quality Header
class StandardAppBar extends StatelessWidget implements PreferredSizeWidget {
  final Widget title;
  final VoidCallback? onBackPressed;
  final List<Widget>? actions;
  final bool showBackButton;
  final Color? backgroundColor;
  final PreferredSizeWidget? bottom;
  final double elevation;

  const StandardAppBar({
    super.key,
    required this.title,
    this.onBackPressed,
    this.actions,
    this.showBackButton = true,
    this.backgroundColor,
    this.bottom,
    this.elevation = 0.5,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    return AppBar(
      leading: showBackButton
          ? IconButton(
              icon: Icon(
                Icons.arrow_back_ios_rounded,
                size: 20,
                color: ThemeColors.getText(context),
              ),
              onPressed: () {
                HapticFeedback.lightImpact();
                onBackPressed?.call();
                if (Navigator.canPop(context)) {
                  Navigator.pop(context);
                }
              },
              splashRadius: 24,
            )
          : null,
      title: DefaultTextStyle(
        style: AppleDesignSystem.title2.copyWith(
          color: ThemeColors.getText(context),
        ),
        child: title,
      ),
      backgroundColor: backgroundColor ?? ThemeColors.getCardBackground(context),
      elevation: elevation,
      shadowColor: isDark ? Colors.black26 : Colors.black12,
      actions: actions,
      centerTitle: false,
      bottom: bottom,
      surfaceTintColor: Colors.transparent,
    );
  }

  @override
  Size get preferredSize => bottom == null
      ? const Size.fromHeight(kToolbarHeight)
      : Size.fromHeight(kToolbarHeight + bottom!.preferredSize.height);
}

/// Premium Page Body - Responsive & Smooth
class PageBody extends StatelessWidget {
  final Widget child;
  final bool scrollable;
  final EdgeInsets padding;
  final Color? backgroundColor;
  final double maxWidth;
  final ScrollPhysics? scrollPhysics;

  const PageBody({
    super.key,
    required this.child,
    this.scrollable = true,
    this.padding = const EdgeInsets.all(16.0),
    this.backgroundColor,
    this.maxWidth = 1200.0,
    this.scrollPhysics,
  });

  @override
  Widget build(BuildContext context) {
    final content = Center(
      child: ConstrainedBox(
        constraints: BoxConstraints(maxWidth: maxWidth),
        child: Padding(
          padding: padding,
          child: child,
        ),
      ),
    );

    return Container(
      color: backgroundColor ?? ThemeColors.getBackground(context),
      child: scrollable
          ? SingleChildScrollView(
              physics: scrollPhysics ?? const BouncingScrollPhysics(
                parent: AlwaysScrollableScrollPhysics(),
              ),
              child: content,
            )
          : content,
    );
  }
}

/// Premium List Item - Apple Style with Haptic Feedback
class StandardListItem extends StatefulWidget {
  final String title;
  final String? subtitle;
  final Widget? leading;
  final Widget? trailing;
  final VoidCallback? onTap;
  final Color? backgroundColor;
  final EdgeInsets padding;
  final bool showDivider;

  const StandardListItem({
    super.key,
    required this.title,
    this.subtitle,
    this.leading,
    this.trailing,
    this.onTap,
    this.backgroundColor,
    this.padding = const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
    this.showDivider = true,
  });

  @override
  State<StandardListItem> createState() => _StandardListItemState();
}

class _StandardListItemState extends State<StandardListItem>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 200),
      vsync: this,
    );
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        GestureDetector(
          onTapDown: (_) {
            _animationController.forward();
            HapticFeedback.lightImpact();
          },
          onTapCancel: () {
            _animationController.reverse();
          },
          onTap: () {
            _animationController.reverse();
            widget.onTap?.call();
          },
          child: ScaleTransition(
            scale: Tween<double>(begin: 1.0, end: 0.98)
                .animate(_animationController),
            child: Container(
              color: widget.backgroundColor ?? Colors.transparent,
              padding: widget.padding,
              child: Row(
                children: [
                  if (widget.leading != null)
                    Padding(
                      padding: const EdgeInsets.only(right: 12),
                      child: widget.leading!,
                    ),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          widget.title,
                          style: AppleDesignSystem.body1.copyWith(
                            color: ThemeColors.getSecondaryText(context),
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        if (widget.subtitle != null) ...[
                          SizedBox(height: AppleDesignSystem.spacing4),
                          Text(
                            widget.subtitle!,
                            style: AppleDesignSystem.caption1.copyWith(
                              color: ThemeColors.getSecondaryText(context),
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                  if (widget.trailing != null)
                    Padding(
                      padding: const EdgeInsets.only(left: 12),
                      child: widget.trailing!,
                    ),
                ],
              ),
            ),
          ),
        ),
        if (widget.showDivider)
          Padding(
            padding: EdgeInsets.symmetric(
              horizontal: AppleDesignSystem.spacing16,
            ),
            child: AppleDesignSystem.smoothDivider(),
          ),
      ],
    );
  }
}

/// Premium Section Header - Apple Style
class SectionHeader extends StatelessWidget {
  final String title;
  final Widget? action;
  final EdgeInsets padding;

  const SectionHeader({
    super.key,
    required this.title,
    this.action,
    this.padding = const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: padding,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            title,
            style: AppleDesignSystem.title2.copyWith(
              color: ThemeColors.getText(context),
              fontWeight: FontWeight.w600,
            ),
          ),
          if (action != null) action!,
        ],
      ),
    );
  }
}

/// Wide button group
class ButtonGroup extends StatelessWidget {
  final List<({String label, VoidCallback onTap, Color? color})> buttons;
  final Axis direction;
  final MainAxisAlignment mainAxisAlignment;

  const ButtonGroup({
    super.key,
    required this.buttons,
    this.direction = Axis.horizontal,
    this.mainAxisAlignment = MainAxisAlignment.spaceEvenly,
  });

  @override
  Widget build(BuildContext context) {
    final children = buttons
        .map(
          (btn) => Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 4.0),
              child: ElevatedButton(
                onPressed: btn.onTap,
                style: ElevatedButton.styleFrom(
                  backgroundColor: btn.color,
                  padding: const EdgeInsets.symmetric(vertical: 12),
                ),
                child: Text(btn.label),
              ),
            ),
          ),
        )
        .toList();

    return direction == Axis.horizontal
        ? Row(
            mainAxisAlignment: mainAxisAlignment,
            children: children,
          )
        : Column(
            mainAxisAlignment: mainAxisAlignment,
            children: [
              for (int i = 0; i < children.length; i++) ...[
                if (i > 0) const SizedBox(height: 8),
                children[i],
              ],
            ],
          );
  }
}

/// Wide info card
class InfoCard extends StatelessWidget {
  final String title;
  final String value;
  final IconData? icon;
  final Color? color;
  final VoidCallback? onTap;

  const InfoCard({
    super.key,
    required this.title,
    required this.value,
    this.icon,
    this.color,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Card(
        color: ThemeColors.getCardBackground(context),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  if (icon != null) ...[
                    Icon(icon, color: color ?? Colors.blue),
                    const SizedBox(width: 8),
                  ],
                  Expanded(
                    child: Text(
                      title,
                      style: Theme.of(context).textTheme.bodyMedium,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                value,
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: color,
                    ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Responsive grid item
class ResponsiveGridItem extends StatelessWidget {
  final Widget child;
  final double minWidth;

  const ResponsiveGridItem({
    super.key,
    required this.child,
    this.minWidth = 150,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: child,
      ),
    );
  }
}

