# Eco Game Design System Guide

## Overview

The Eco Game Flutter application now features a comprehensive design system that ensures visual consistency, accessibility, and maintainability across the entire codebase. This document provides guidelines for implementing the design system.

## Key Components

### 1. Theme System (`lib/theme/`)

#### Theme Colors (`lib/theme/theme_colors.dart`)
- **Purpose**: Centralized color management for both light and dark themes
- **Key Features**:
  - Theme-aware color functions
  - High contrast support
  - Consistent color palette
  - Accessibility-compliant colors

#### App Theme (`lib/theme/app_theme.dart`)
- **Purpose**: Complete theme definitions with Material 3 support
- **Key Features**:
  - Light/Dark/High contrast themes
  - Custom text styles
  - Component themes (buttons, cards, etc.)
  - Accessibility helpers

#### Design System (`lib/theme/design_system.dart`)
- **Purpose**: Utility classes for consistent UI implementation
- **Key Features**:
  - Standard spacing and sizing
  - Pre-built component styles
  - Responsive design utilities
  - Accessibility wrappers
  - Error and loading state widgets

### 2. Enhanced Custom Components

#### Custom Form Fields (`lib/widgets/custom_form_field.dart`)
- **Features**:
  - Consistent input styling
  - Built-in validation
  - Theme-aware colors
  - Error handling
  - Accessibility support

#### Design System Utilities
```dart
// Using the design system for consistent styling
DesignSystem.card(
  context,
  child: Column(
    children: [
      Text('Title', style: DesignSystem.getTitleLarge(context)),
      Text('Content', style: DesignSystem.getBodyMedium(context)),
    ],
  ),
);

// Standard button styles
ElevatedButton(
  style: DesignSystem.getPrimaryButtonStyle(context),
  onPressed: () {},
  child: Text('Primary Action'),
);

// Input decoration
TextFormField(
  decoration: DesignSystem.getInputDecoration(
    context,
    labelText: 'Email',
    prefixIcon: Icon(Icons.email),
  ),
);
```

## Design Principles

### 1. Consistency
- All colors must use theme-aware functions
- Spacing follows the design system standard values
- Typography uses predefined text styles
- Component styling uses utility classes

### 2. Accessibility
- Minimum touch target size: 48px
- High contrast theme support
- Semantic labeling for screen readers
- Proper color contrast ratios (WCAG AA compliant)

### 3. Responsiveness
- Adaptive layouts for mobile, tablet, and desktop
- Flexible containers with max-width constraints
- Responsive grid systems
- Adaptive typography scaling

### 4. Theme Support
- Light theme (default)
- Dark theme
- High contrast theme (accessibility)
- Seamless theme switching

## Implementation Guidelines

### Color Usage

#### ✅ DO: Use Theme-Aware Colors
```dart
// Good: Using centralized theme colors
Container(
  color: ThemeColors.getPrimaryButtonColor(context),
  child: Text(
    'Button Text',
    style: TextStyle(
      color: ThemeColors.getText(context),
    ),
  ),
);
```

#### ❌ DON'T: Use Hardcoded Colors
```dart
// Bad: Hardcoded colors
Container(
  color: Color(0xFF4CAF50), // Hardcoded green
  child: Text(
    'Button Text',
    style: TextStyle(
      color: Colors.black87, // Hardcoded text color
    ),
  ),
);
```

### Typography Usage

#### ✅ DO: Use Predefined Text Styles
```dart
// Good: Using design system text styles
Text('Title', style: DesignSystem.getTitleLarge(context));
Text('Content', style: DesignSystem.getBodyMedium(context));
Text('Label', style: DesignSystem.getLabelLarge(context));
```

#### ❌ DON'T: Create Custom Text Styles
```dart
// Bad: Creating custom styles
Text('Title', style: TextStyle(
  fontSize: 24,
  fontWeight: FontWeight.bold,
  color: Color(0xFF2E7D32),
));
```

### Component Styling

#### ✅ DO: Use Design System Utilities
```dart
// Good: Using design system components
DesignSystem.card(
  context,
  child: Column(
    children: [
      Text('Card Title', style: DesignSystem.getTitleMedium(context)),
      // ... content
    ],
  ),
);
```

#### ❌ DON'T: Style Components Directly
```dart
// Bad: Direct component styling
Container(
  decoration: BoxDecoration(
    color: Colors.white,
    borderRadius: BorderRadius.circular(16),
    boxShadow: [
      BoxShadow(
        color: Colors.black.withOpacity(0.1),
        blurRadius: 4,
        offset: Offset(0, 2),
      ),
    ],
  ),
);
```

### Button Implementation

#### ✅ DO: Use Standard Button Styles
```dart
// Good: Using design system button styles
ElevatedButton(
  style: DesignSystem.getPrimaryButtonStyle(context),
  onPressed: onPressed,
  child: Text('Primary Action'),
);

TextButton(
  style: DesignSystem.getTextButtonStyle(context),
  onPressed: onPressed,
  child: Text('Secondary Action'),
);
```

#### ❌ DON'T: Create Custom Button Styles
```dart
// Bad: Custom button styling
ElevatedButton(
  style: ElevatedButton.styleFrom(
    backgroundColor: Color(0xFF4CAF50),
    foregroundColor: Colors.white,
    padding: EdgeInsets.symmetric(horizontal: 32, vertical: 16),
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(12),
    ),
  ),
  onPressed: onPressed,
  child: Text('Primary Action'),
);
```

### Form Field Implementation

#### ✅ DO: Use Design System Input Decorations
```dart
// Good: Using design system input decoration
TextFormField(
  decoration: DesignSystem.getInputDecoration(
    context,
    labelText: 'Email',
    hintText: 'Enter your email',
    prefixIcon: Icon(Icons.email),
    validator: (value) {
      if (value?.isEmpty ?? true) {
        return 'Email is required';
      }
      return null;
    },
  ),
);
```

#### ❌ DON'T: Create Custom Input Decorations
```dart
// Bad: Custom input decoration
TextFormField(
  decoration: InputDecoration(
    labelText: 'Email',
    filled: true,
    fillColor: Colors.grey[50],
    border: OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
    ),
    focusedBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
      borderSide: BorderSide(color: Color(0xFF4CAF50), width: 2),
    ),
  ),
);
```

### Page Layout

#### ✅ DO: Use Design System Layout Utilities
```dart
// Good: Using design system page container
Container(
  decoration: DesignSystem.getPageContainerDecoration(context),
  child: DesignSystem.responsiveContainer(
    context,
    mobile: MobileLayout(),
    tablet: TabletLayout(),
    desktop: DesktopLayout(),
    maxWidth: 1200,
  ),
);
```

### Accessibility Implementation

#### ✅ DO: Use Semantic Wrappers
```dart
// Good: Using semantic wrappers for accessibility
DesignSystem.semantic(
  context,
  label: 'Submit button',
  hint: 'Tap to submit the form',
  child: ElevatedButton(
    style: DesignSystem.getPrimaryButtonStyle(context),
    onPressed: onSubmit,
    child: Text('Submit'),
  ),
);
```

#### ❌ DON'T: Skip Accessibility
```dart
// Bad: Missing accessibility labels
ElevatedButton(
  onPressed: onSubmit,
  child: Text('Submit'),
);
```

## Migration Guide

### For Existing Components

1. **Replace hardcoded colors** with theme-aware functions
2. **Replace custom text styles** with design system styles
3. **Replace custom component styling** with design system utilities
4. **Add semantic labels** for accessibility
5. **Test in all theme modes** (light, dark, high contrast)

### Step-by-Step Migration

#### Step 1: Update Color Usage
```dart
// Before
color: Color(0xFF4CAF50)

// After
color: ThemeColors.getPrimaryButtonColor(context)
```

#### Step 2: Update Text Styles
```dart
// Before
style: TextStyle(
  fontSize: 16,
  fontWeight: FontWeight.bold,
  color: Colors.black87,
)

// After
style: DesignSystem.getTitleMedium(context)
```

#### Step 3: Update Component Styling
```dart
// Before
Container(
  decoration: BoxDecoration(
    color: Colors.white,
    borderRadius: BorderRadius.circular(16),
    boxShadow: [...],
  ),
)

// After
DesignSystem.card(context, child: content)
```

#### Step 4: Add Accessibility
```dart
// Before
Widget build(context) {
  return SomeWidget();
}

// After
Widget build(context) {
  return DesignSystem.semantic(
    context,
    label: 'Widget description',
    child: SomeWidget(),
  );
}
```

## Testing Guidelines

### Theme Testing
- Test in light theme
- Test in dark theme
- Test in high contrast theme
- Verify color contrast ratios
- Check touch target sizes

### Accessibility Testing
- Test with screen readers
- Verify semantic labels
- Check focus indicators
- Test keyboard navigation
- Verify touch target accessibility

### Responsive Testing
- Test on mobile devices
- Test on tablets
- Test on desktop
- Verify layout adaptations
- Check text scaling

## Best Practices

### Performance
- Use const constructors where possible
- Leverage theme caching
- Minimize widget rebuilds
- Use efficient list builders

### Maintainability
- Follow the design system consistently
- Use semantic naming
- Document custom implementations
- Write comprehensive tests

### User Experience
- Provide clear visual feedback
- Use consistent interaction patterns
- Implement proper error handling
- Ensure smooth transitions

## Support and Resources

### Design System Files
- `lib/theme/theme_colors.dart` - Color definitions
- `lib/theme/app_theme.dart` - Theme configurations
- `lib/theme/design_system.dart` - Utility classes

### Example Implementations
- `lib/widgets/custom_form_field.dart` - Form field examples
- Look for existing pages using design system patterns

### Getting Help
- Check this documentation first
- Review existing implementations
- Test with the design system utilities
- Validate against accessibility guidelines

## Future Enhancements

The design system is designed to be extensible. Future enhancements may include:
- Additional component variants
- Advanced animation utilities
- Enhanced responsive breakpoints
- Improved accessibility features
- Performance optimizations

---

**Last Updated**: 2025-11-27  
**Version**: 1.0  
**Status**: Implemented and Tested