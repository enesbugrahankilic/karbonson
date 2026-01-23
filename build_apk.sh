#!/bin/bash

# APK Build Script for Karbonson
# This script automates the APK generation process

set -e

echo "🚀 Starting APK Build Process for Karbonson"
echo "============================================"

# Step 1: Get dependencies
echo "📦 Step 1: Fetching Flutter dependencies..."
flutter pub get

# Step 2: Generate launcher icons
echo "🎨 Step 2: Generating launcher icons..."
flutter pub run flutter_launcher_icons:main

# Step 3: Clean build
echo "🧹 Step 3: Cleaning previous build artifacts..."
flutter clean

# Step 4: Get dependencies again after clean
echo "📦 Step 4: Fetching dependencies after clean..."
flutter pub get

# Step 5: Build APK
echo "🏗️ Step 5: Building APK (Release mode)..."
flutter build apk --release

# Step 6: Verify output
echo "✅ Step 6: Verifying APK output..."
if [ -f "build/app/outputs/flutter-apk/app-release.apk" ]; then
    echo "🎉 APK Build Successful!"
    echo "📱 APK Location: build/app/outputs/flutter-apk/app-release.apk"
    echo "📊 APK Size: $(ls -lh build/app/outputs/flutter-apk/app-release.apk | awk '{print $5}')"
else
    echo "❌ APK Build Failed - File not found"
    exit 1
fi

echo "============================================"
echo "✨ APK Build Complete!"

