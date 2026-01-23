#!/bin/bash
# Quick Error Fix Script for Karbonson Flutter Project
# This script identifies and fixes common Flutter analysis errors

set -e

echo "=== Karbonson Flutter Error Fix Script ==="
echo ""

# Change to project directory
cd /Users/omer/karbonson

# Create a list of files that need fixing
echo "Phase 1: Fixing critical errors..."

# Fix 1: withOpacity -> withValues migration
echo "Fixing deprecated withOpacity calls..."
find lib -name "*.dart" -type f -exec sed -i '' 's/\.withOpacity(/\.withValues(alpha: /g' {} \;

# Fix 2: Remove unnecessary toList() in spreads
echo "Fixing unnecessary toList() in spreads..."
find lib -name "*.dart" -type f -exec sed -i '' 's/\[\.\.\.([a-zA-Z_]*\.toList())\]/[... \1]/g' {} \;

# Fix 3: Use super parameters for key
echo "Adding super parameters for key..."
find lib -name "*.dart" -type f -exec sed -i '' 's/const \([A-Z][a-zA-Z]*\)({super\.key}/\1({super.key/g' {} \;

echo ""
echo "=== Running Flutter analyze ==="
flutter analyze lib/

echo ""
echo "=== Error Fix Complete ==="
