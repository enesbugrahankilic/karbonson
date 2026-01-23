# TODO_FIX_ALL_ERRORS.md
# Project Error Fix Plan - Zero Error Goal

## Analysis Summary
- **Errors**: 30+ critical errors (syntax, undefined identifiers, type errors)
- **Warnings**: 50+ warnings (unused code, fields, imports)
- **Infos**: 200+ info messages (deprecated APIs, style improvements)

## Critical Error Fixes

### 1. lib/pages/firebase_debug_page.dart
- [ ] Line 164-165: Remove stray `;` characters
- [ ] Fix dead code caused by syntax error

### 2. lib/pages/home_dashboard.dart  
- [ ] Line 394-408: Fix syntax errors in build method
- [ ] Add missing class member declarations (_userData, _userProgress, etc.)
- [ ] Fix undefined identifier errors

### 3. lib/pages/forgot_password_page_enhanced.dart
- [ ] Line 344: Fix argument_type_not_assignable error (String -> Widget)

### 4. lib/core/navigation/app_router_complete.dart
- [ ] Fix use_build_context_synchronously warnings (lines 765, 773)

### 5. lib/core/navigation/improved_app_router.dart
- [ ] Line 223: Fix await_only_futures (await on bool)

## Warning Fixes

### Unused Imports
- [ ] lib/core/navigation/app_navigation_shell.dart: Remove unused imports
- [ ] lib/extensions/user_data_carbon_extension.dart: Remove unused import

### Unused Fields
- [ ] lib/pages/achievement_page.dart: Remove unused fields
- [ ] lib/pages/email_otp_verification_page.dart: Remove unused fields
- [ ] lib/pages/comprehensive_two_factor_auth_setup_page.dart: Remove unused fields
- [ ] lib/pages/enhanced_two_factor_auth_setup_page.dart: Remove unused fields
- [ ] lib/pages/email_verification_redirect_page.dart: Remove unused fields
- [ ] lib/pages/friends_page.dart: Remove unused field

### Dead Code
- [ ] lib/pages/home_dashboard.dart: Remove dead code at line 395
- [ ] lib/pages/firebase_debug_page.dart: Remove dead code at line 164

## Deprecated API Fixes (withOpacity -> withValues)

### Priority Files
1. lib/core/navigation/bottom_navigation.dart (lines 82, 92)
2. lib/pages/achievements_gallery_page.dart (multiple lines)
3. lib/pages/email_verification_page.dart (multiple lines)
4. lib/pages/email_verification_redirect_page.dart (multiple lines)
5. lib/pages/enhanced_two_factor_auth_verification_page.dart (line 402)
6. lib/pages/firebase_debug_page.dart (multiple lines)
7. lib/pages/forgot_password_page.dart (multiple lines)
8. lib/pages/forgot_password_page_enhanced.dart (multiple lines)
9. lib/pages/friends_page.dart (line 236)
10. lib/pages/home_dashboard.dart (multiple lines)

## Style & Best Practice Fixes

### constant_identifier_names
- [ ] lib/models/reward_models.dart: Fix constant names (snake_case -> lowerCamelCase)

### avoid_types_as_parameter_names
- [ ] lib/models/carbon_footprint_data.dart: Rename 'sum' parameter

### unnecessary_to_list_in_spreads
- [ ] lib/pages/firebase_debug_page.dart: Remove unnecessary toList() calls

### sort_child_properties_last
- [ ] lib/pages/friends_page.dart: Reorder child property

### prefer_final_fields
- [ ] lib/core/navigation/app_navigation_shell.dart: Make fields final

### unnecessary_braces
- [ ] lib/models/carbon_footprint_data.dart: Remove unnecessary braces

### use_super_parameters
- [ ] lib/pages/carbon_footprint_page.dart: Use super parameter
- [ ] lib/pages/email_otp_verification_page.dart: Use super parameter

## Implementation Steps

1. **Phase 1**: Fix all critical errors (syntax, undefined identifiers)
2. **Phase 2**: Remove unused code and imports
3. **Phase 3**: Update deprecated APIs
4. **Phase 4**: Apply style improvements
5. **Phase 5**: Verify with `flutter analyze`

## Commands
```bash
# Check for errors
flutter analyze lib/

# Fix and re-analyze
flutter analyze lib/
```

## Status
- Created: 2024
- Last Updated: Current session
- Progress: TODO

