#!/bin/bash

# iOS Firebase Build Fix Script
# This script thoroughly cleans and rebuilds the iOS project to resolve Firebase header issues

echo "🚀 Starting comprehensive iOS build fix..."

# Step 1: Clean Flutter build
echo "🧹 Cleaning Flutter build..."
flutter clean

# Step 2: Remove iOS build artifacts
echo "🗑️ Removing iOS build artifacts..."
cd ios
rm -rf build/
rm -rf Pods/
rm -rf .symlinks/
rm -f Podfile.lock
cd ..

# Step 3: Get Flutter dependencies
echo "📦 Getting Flutter dependencies..."
flutter pub get

# Step 4: Clean CocoaPods cache
echo "🧽 Cleaning CocoaPods cache..."
cd ios
pod cache clean --all --verbose

# Step 5: Update CocoaPods repository
echo "🔄 Updating CocoaPods repository..."
pod repo update

# Step 6: Install pods with verbose output
echo "📱 Installing pods..."
pod install --verbose

# Step 7: Return to project root
cd ..

echo "✅ iOS build fix complete!"
echo "🔄 You can now try running: flutter run"

# Show pod installation summary
echo "📊 Pod installation summary:"
cd ios
pod list
