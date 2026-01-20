# Quick Menu Vertical Scroll Fix Plan

## Problem
- Quick menu currently scrolls horizontally (left to right)
- User wants it to scroll vertically (top to bottom / aşağı doğru)

## Changes Required

### 1. QuickMenuWidget - _buildScrollableMenu() method
- [x] Change `scrollDirection: Axis.horizontal` to `Axis.vertical`
- [x] Adjust height calculations for vertical layout
- [x] Update padding for vertical spacing

### 2. QuickMenuGrid - scroll direction
- [x] Change `scrollDirection: Axis.horizontal` to `Axis.vertical` in SingleChildScrollView
- [x] Adjust spacing logic for vertical layout

## Files to Modify
- `/Users/omer/karbonson/lib/widgets/quick_menu_widget.dart`

## Testing Steps
- [x] Run app and verify vertical scroll works
- [x] Check all menu items are accessible
- [x] Verify scrollbar appears correctly

## Completed Changes
- ✅ Changed QuickMenuWidget scroll direction to vertical
- ✅ Changed QuickMenuGrid scroll direction to vertical
- ✅ Updated padding and spacing for vertical layout
- ✅ Flutter analyze passed with no errors

