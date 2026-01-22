// lib/widgets/page_templates.dart
// Sayfa şablonları - Tüm sayfalar için consistent design

import 'package:flutter/material.dart';
import '../theme/theme_colors.dart';
import '../theme/design_system.dart';

/// Standart sayfa AppBar'ı
class StandardAppBar extends StatelessWidget implements PreferredSizeWidget {
  final Widget title;
  final VoidCallback? onBackPressed;
  final List<Widget>? actions;
  final bool showBackButton;
  final Color? backgroundColor;
  final PreferredSizeWidget? bottom;

  const StandardAppBar({
    Key? key,
    required this.title,
    this.onBackPressed,
    this.actions,
    this.showBackButton = true,
    this.backgroundColor,
    this.bottom,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return AppBar(
      leading: showBackButton
          ? IconButton(
              icon: const Icon(Icons.arrow_back),
              onPressed: onBackPressed ?? () => Navigator.pop(context),
            )
          : null,
      title: title,
      backgroundColor: backgroundColor ?? ThemeColors.getCardBackground(context),
      elevation: 1,
      actions: actions,
      centerTitle: false,
      bottom: bottom,
    );
  }

  @override
  Size get preferredSize => bottom == null
      ? const Size.fromHeight(kToolbarHeight)
      : Size.fromHeight(kToolbarHeight + bottom!.preferredSize.height);
}

/// Responsive page body
class PageBody extends StatelessWidget {
  final Widget child;
  final bool scrollable;
  final EdgeInsets padding;
  final Color? backgroundColor;
  final double maxWidth;

  const PageBody({
    Key? key,
    required this.child,
    this.scrollable = true,
    this.padding = const EdgeInsets.all(16.0),
    this.backgroundColor,
    this.maxWidth = 1200.0,
  }) : super(key: key);

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
              physics: const BouncingScrollPhysics(),
              child: content,
            )
          : content,
    );
  }
}

/// Standart list item
class StandardListItem extends StatelessWidget {
  final String title;
  final String? subtitle;
  final Widget? leading;
  final Widget? trailing;
  final VoidCallback? onTap;
  final Color? backgroundColor;

  const StandardListItem({
    Key? key,
    required this.title,
    this.subtitle,
    this.leading,
    this.trailing,
    this.onTap,
    this.backgroundColor,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 4.0),
      decoration: BoxDecoration(
        color: backgroundColor ?? ThemeColors.getCardBackground(context),
        borderRadius: BorderRadius.circular(8),
      ),
      child: ListTile(
        leading: leading,
        title: Text(
          title,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        subtitle: subtitle != null
            ? Text(
                subtitle!,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              )
            : null,
        trailing: trailing,
        onTap: onTap,
        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      ),
    );
  }
}

/// Standart section header
class SectionHeader extends StatelessWidget {
  final String title;
  final Widget? action;

  const SectionHeader({
    Key? key,
    required this.title,
    this.action,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            title,
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
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
    Key? key,
    required this.buttons,
    this.direction = Axis.horizontal,
    this.mainAxisAlignment = MainAxisAlignment.spaceEvenly,
  }) : super(key: key);

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
    Key? key,
    required this.title,
    required this.value,
    this.icon,
    this.color,
    this.onTap,
  }) : super(key: key);

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
    Key? key,
    required this.child,
    this.minWidth = 150,
  }) : super(key: key);

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
