// APPLE QUALITY DESIGN IMPLEMENTATION GUIDE
// Complete design system for premium iOS-inspired UI

## 📱 CORE PRINCIPLES

### 1. TYPOGRAPHY
- **Headlines**: Inter font, -1.5 to -0.5 letter spacing
- **Body**: Inter 15-16px, -0.24 to -0.32 letter spacing
- **Caption**: 12-13px, 0 to -0.08 letter spacing
- **Line Height**: 1.4-1.5 for optimal readability

### 2. SPACING (8pt baseline)
```dart
// Use consistent 8pt baseline
spacing2  = 2px   (micro spacing)
spacing4  = 4px   (tight spacing)
spacing8  = 8px   (standard spacing)
spacing16 = 16px  (container padding)
spacing24 = 24px  (section spacing)
spacing32 = 32px  (major spacing)
```

### 3. CORNER RADIUS
- **Small UI elements**: 4-8px
- **Cards/Buttons**: 12px (recommended)
- **Large containers**: 16-20px
- **Circles**: Use 9999 for perfect circles

### 4. SHADOWS (Subtle & Premium)
```dart
shadowSoft     // 2px blur, -4% opacity → Subtle touch states
shadowBase     // 8px blur, -6% opacity → Card default
shadowMedium   // 16px blur, -10% opacity → Elevated states
shadowLarge    // 32px blur, -15% opacity → Modals/Overlays
```

### 5. COLORS
- **Dark Mode**: Use true black (#000000) with white overlay
- **Light Mode**: Use white with subtle gray (#F9F9F9)
- **Primary Color**: Brand color with 0.1 opacity for backgrounds
- **Text Colors**:
  - Primary: 100% opacity
  - Secondary: 60% opacity
  - Tertiary: 45% opacity
  - Disabled: 30% opacity

### 6. HAPTIC FEEDBACK
```dart
HapticFeedback.lightImpact()      // Light taps (list items, toggles)
HapticFeedback.mediumImpact()     // Medium taps (double-tap, important actions)
HapticFeedback.heavyImpact()      // Heavy taps (errors, critical actions)
HapticFeedback.selectionClick()   // Selection feedback (tab switches)
```

### 7. ANIMATIONS
- **Page Transitions**: 300-400ms with Curves.easeOutCubic
- **UI Interactions**: 200-300ms with easing curves
- **Micro-interactions**: 100-200ms for instant feedback
- **Never**: Use linear curves or static transitions

### 8. BUTTONS
**Premium Button**:
- 52px height minimum
- 16px horizontal padding
- 12px vertical padding
- 12px border radius
- No elevation (modern flat design)
- Haptic feedback on press

**States**:
- Normal: Full opacity
- Pressed: 90% opacity (scale 0.98)
- Disabled: 50% opacity, no interaction

### 9. CARDS
- Use shadowBase for default state
- 16px padding standard
- 12px border radius
- Scale to 0.97 on tap
- Light haptic feedback on tap

### 10. BOTTOM NAVIGATION
- 56px height
- Floating style (optional margin bottom)
- Scale icon 1.0-1.1 on selection
- Fade label in/out
- Single tap: Switch tab
- Double tap: Pop to root
- Haptic feedback on each tap

### 11. LIST ITEMS
- No borders by default
- Subtle divider line instead
- 16px icon-text spacing
- Scale 0.98 on tap
- Light haptic feedback

### 12. MODALS & BOTTOM SHEETS
- Slide from bottom with fade
- Semi-transparent overlay (0.3 opacity)
- Rounded top corners (20px)
- Safe area padding
- Dismiss on overlay tap

### 13. FOCUS & ACCESSIBILITY
- Minimum 44x44pt touch targets
- High contrast text (4.5:1 for AA)
- Clear visual focus indicators
- Support VoiceOver & TalkBack
- Screen reader labels

### 14. PERFORMANCE
- 60 FPS animations (16.67ms per frame)
- No frame drops on navigation
- Lazy load heavy content
- Cache network images
- Optimize build method

## 🎨 IMPLEMENTATION CHECKLIST

### For Each Page:
- [ ] Use StandardAppBar (premium header)
- [ ] Wrap body with PageBody (responsive container)
- [ ] Apply AppleDesignSystem spacing/colors
- [ ] Add haptic feedback to interactive elements
- [ ] Use smooth page transitions
- [ ] Test dark mode appearance
- [ ] Verify accessibility (contrast, touch targets)
- [ ] Check performance (no janky animations)

### For New Components:
- [ ] Use AppleDesignSystem.premiumCard()
- [ ] Apply shadowBase by default
- [ ] Add haptic feedback to interactions
- [ ] Use rounded corners (12px standard)
- [ ] Support light/dark mode
- [ ] Test on both iOS and Android
- [ ] Optimize rebuild/repaints

### For Bottom Navigation:
- [ ] Use PremiumBottomNavigation widget
- [ ] 5 tabs maximum (Home, Quiz, Duel, Social, Profile)
- [ ] Double-tap to root behavior
- [ ] Smooth tab switching animation
- [ ] Independent navigation stacks per tab
- [ ] Haptic feedback on selection

## 📊 COLOR PALETTE

**Light Mode**:
- Background: #FFFFFF
- Surface: #F9F9F9
- Primary: Brand color (dynamic)
- Text Primary: #000000
- Text Secondary: #666666 (60% opacity)
- Text Tertiary: #999999 (45% opacity)
- Divider: #E5E5E5

**Dark Mode**:
- Background: #000000 (or #1A1A1A)
- Surface: #1F1F1F
- Primary: Brand color (light variant)
- Text Primary: #FFFFFF
- Text Secondary: #CCCCCC (60% opacity)
- Text Tertiary: #999999 (45% opacity)
- Divider: #333333

## 🚀 QUICK REFERENCE

```dart
// Premium card
AppleDesignSystem.premiumCard(
  context: context,
  child: YourWidget(),
  onTap: () => print('Tapped!'),
);

// Premium button
ElevatedButton(
  onPressed: () => HapticFeedback.mediumImpact(),
  style: AppleDesignSystem.premiumButtonStyle(context),
  child: Text('Action'),
);

// List item
StandardListItem(
  title: 'Option',
  subtitle: 'Description',
  onTap: () => print('Tapped!'),
);

// Premium card list
PremiumListCard(
  title: 'Item',
  trailing: Icon(Icons.chevron_right),
  onTap: () => print('Tapped!'),
);

// Smooth page transition
Navigator.push(
  context,
  CupertinoStylePageRoute(builder: (_) => NextPage()),
);

// Haptic feedback
HapticFeedback.lightImpact();
HapticFeedback.selectionClick();
```

## ✅ VERIFICATION CHECKLIST

Before shipping:
- [ ] All pages use StandardAppBar + PageBody
- [ ] All interactive elements have haptic feedback
- [ ] All transitions are smooth (no jank)
- [ ] Dark mode works perfectly
- [ ] Accessibility contrast passed (4.5:1+)
- [ ] Touch targets minimum 44x44pt
- [ ] No layout overflow/jitter
- [ ] Loading states are visible
- [ ] Error states are clear
- [ ] Empty states look good
- [ ] Tested on iOS and Android
- [ ] Performance: 60 FPS consistent

## 🎯 NEXT STEPS

1. ✅ Applied to MainNavigationShell
2. ✅ Applied to page_templates.dart
3. 🔄 Apply to remaining pages (gradual rollout)
4. 🔄 Update color system to match brand
5. 🔄 Fine-tune animations per page
6. 🔄 Add loading & error state designs
7. 🔄 Test on real devices
8. 🔄 Performance profiling & optimization

---

**Version**: 1.0  
**Last Updated**: January 22, 2026  
**Status**: Production Ready
