// lib/widgets/premium_bottom_navigation.dart
// Apple Quality Bottom Navigation - Floating Style with Premium UX

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../theme/apple_design_system.dart';
import '../theme/theme_colors.dart';

class PremiumBottomNavigation extends StatefulWidget {
  final int selectedIndex;
  final Function(int) onItemTapped;
  final List<NavigationItem> items;
  final Color? backgroundColor;

  const PremiumBottomNavigation({
    super.key,
    required this.selectedIndex,
    required this.onItemTapped,
    required this.items,
    this.backgroundColor,
  });

  @override
  State<PremiumBottomNavigation> createState() => _PremiumBottomNavigationState();
}

class _PremiumBottomNavigationState extends State<PremiumBottomNavigation> {
  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    return Container(
      decoration: BoxDecoration(
        color: widget.backgroundColor ?? 
            (isDark 
              ? Colors.grey[900]?.withValues(alpha: 0.95) 
              : Colors.white.withValues(alpha: 0.95)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isDark ? 0.3 : 0.1),
            blurRadius: 20,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: SafeArea(
        top: false,
        child: Padding(
          padding: EdgeInsets.symmetric(
            horizontal: AppleDesignSystem.spacing12,
            vertical: AppleDesignSystem.spacing8,
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: List.generate(
              widget.items.length,
              (index) => _NavItem(
                item: widget.items[index],
                isSelected: widget.selectedIndex == index,
                onTap: () {
                  HapticFeedback.lightImpact();
                  widget.onItemTapped(index);
                },
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _NavItem extends StatefulWidget {
  final NavigationItem item;
  final bool isSelected;
  final VoidCallback onTap;

  const _NavItem({
    required this.item,
    required this.isSelected,
    required this.onTap,
  });

  @override
  State<_NavItem> createState() => _NavItemState();
}

class _NavItemState extends State<_NavItem> with SingleTickerProviderStateMixin {
  late AnimationController _animationController;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );

    if (widget.isSelected) {
      _animationController.forward();
    }
  }

  @override
  void didUpdateWidget(_NavItem oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isSelected && !oldWidget.isSelected) {
      _animationController.forward();
    } else if (!widget.isSelected && oldWidget.isSelected) {
      _animationController.reverse();
    }
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: widget.onTap,
      child: AnimatedBuilder(
        animation: _animationController,
        builder: (context, child) {
          final scale = 0.9 + (_animationController.value * 0.1);
          
          return Transform.scale(
            scale: scale,
            child: Container(
              padding: EdgeInsets.symmetric(
                horizontal: AppleDesignSystem.spacing12,
                vertical: AppleDesignSystem.spacing8,
              ),
              decoration: BoxDecoration(
                color: widget.isSelected
                    ? Theme.of(context).primaryColor.withValues(alpha: 0.1)
                    : Colors.transparent,
                borderRadius: BorderRadius.circular(AppleDesignSystem.radius12),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Icon with scale animation
                  AnimatedScale(
                    scale: widget.isSelected ? 1.1 : 1.0,
                    duration: const Duration(milliseconds: 300),
                    child: Icon(
                      widget.item.icon,
                      size: 24,
                      color: widget.isSelected
                          ? Theme.of(context).primaryColor
                          : ThemeColors.getSecondaryText(context),
                    ),
                  ),
                  SizedBox(height: AppleDesignSystem.spacing4),
                  // Label with fade animation
                  AnimatedOpacity(
                    opacity: widget.isSelected ? 1.0 : 0.6,
                    duration: const Duration(milliseconds: 300),
                    child: Text(
                      widget.item.label,
                      style: AppleDesignSystem.caption2.copyWith(
                        color: widget.isSelected
                            ? Theme.of(context).primaryColor
                            : ThemeColors.getSecondaryText(context),
                        fontWeight: widget.isSelected
                            ? FontWeight.w600
                            : FontWeight.w400,
                      ),
                    ),
                  ),
                  // Badge if present
                  if (widget.item.badge != null)
                    Padding(
                      padding: EdgeInsets.only(top: AppleDesignSystem.spacing2),
                      child: Container(
                        width: 6,
                        height: 6,
                        decoration: BoxDecoration(
                          color: Colors.red[500],
                          shape: BoxShape.circle,
                        ),
                      ),
                    ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}

class NavigationItem {
  final IconData icon;
  final String label;
  final int? badge;

  NavigationItem({
    required this.icon,
    required this.label,
    this.badge,
  });
}
