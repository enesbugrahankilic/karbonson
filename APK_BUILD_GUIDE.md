# Karbonson APK Build Guide

## Overview
This document provides a comprehensive guide for building the Karbonson Android APK for release distribution.

## Project Information
- **App Name**: CO² Yutakları
- **Package ID**: com.example.karbonson
- **Version**: 1.2.5 (Build 5)
- **Min SDK**: Android 21 (Android 5.0)
- **Target SDK**: Android 35

## Prerequisites

### System Requirements
- Flutter 3.38.3 or higher
- Dart 3.10.1 or higher
- Java 21 (JVM 21)
- Gradle 8.12
- Android Gradle Plugin 8.9.1
- Kotlin 2.1.0

### Development Environment
```bash
# Verify Flutter installation
flutter --version

# Verify Java version
java -version

# Verify Gradle version
gradle --version
```

## Build Configuration

### 1. Android Gradle Configuration
**File**: `android/app/build.gradle.kts`
- Release build type configured
- Minification and R8 enabled
- ProGuard rules for Firebase and dependencies

### 2. Gradle Wrapper
**File**: `android/gradle/wrapper/gradle-wrapper.properties`
- Distribution URL: gradle-8.12-all.zip

### 3. ProGuard Rules
**File**: `android/app/proguard-rules.pro`
- Firebase rules for Firestore, Auth, Storage
- Kotlin metadata rules
- Retrofit and Gson serialization rules

### 4. Launcher Icons
**File**: `assets/icon/karbon2.png`
- Configured in `pubspec.yaml`
- Generated for all screen densities

## Quick Build Commands

### Method 1: Using the Build Script
```bash
# Navigate to project directory
cd /Users/omer/karbonson

# Run the automated build script
./build_apk.sh
```

### Method 2: Manual Build
```bash
# Navigate to project directory
cd /Users/omer/karbonson

# Step 1: Get dependencies
flutter pub get

# Step 2: Generate launcher icons
flutter pub run flutter_launcher_icons:main

# Step 3: Clean previous builds
flutter clean

# Step 4: Get dependencies again
flutter pub get

# Step 5: Build APK (Release)
flutter build apk --release
```

### Method 3: Build with Verbose Output
```bash
flutter build apk --release --verbose
```

## Build Output

### APK Location
```
build/app/outputs/flutter-apk/app-release.apk
```

### APK Details
- **File Size**: ~50-80 MB (varies by device architecture)
- **APK Type**: Universal (supports all ABIs)
- **Optimization**: R8 minification enabled

### Signing
The APK is currently signed with the debug key for testing purposes. For production release, you need to:
1. Create a keystore file
2. Configure signing in `android/app/build.gradle.kts`
3. Use release keystore for signing

## Firebase Configuration

### Required Files
- `android/app/google-services.json` - Firebase configuration file
- Already configured in the project

### Firebase Services Used
- Firebase Authentication (Email, Phone, Biometric)
- Cloud Firestore
- Firebase Cloud Messaging
- Firebase Analytics
- Firebase Crashlytics
- Firebase Storage
- Firebase Dynamic Links

## Build Troubleshooting

### Common Issues

#### 1. Gradle Build Failures
```bash
# Solution: Clean and rebuild
flutter clean
flutter pub get
flutter build apk --release
```

#### 2. Java Version Mismatch
```bash
# Check Java version
java -version

# Set JAVA_HOME if needed
export JAVA_HOME=/path/to/jdk-21
```

#### 3. Android SDK Not Found
Ensure `local.properties` has correct SDK path:
```properties
sdk.dir=/Users/omer/Library/Android/sdk
```

#### 4. Firebase Configuration Errors
- Verify `google-services.json` is present
- Check package name matches configuration

### Build Error Resolution
If you encounter build errors:
1. Check `android/build/reports/problems/problems-report.html`
2. Review terminal output for specific error messages
3. Run `flutter doctor -v` to diagnose environment issues

## Release Build Configuration

### Current Configuration
- **Build Type**: Release
- **Minification**: Enabled (R8)
- **Shrinking Resources**: Enabled
- **Obfuscation**: Enabled

### Production Release Steps
1. Create a signing key keystore
2. Add signing configuration to `android/app/build.gradle.kts`
3. Store keystore credentials securely
4. Build release APK with signing
5. Test APK on multiple devices

## Testing the APK

### Install on Connected Device
```bash
# Install from file
adb install build/app/outputs/flutter-apk/app-release.apk

# Install with reinstall
adb install -r build/app/outputs/flutter-apk/app-release.apk
```

### Verify Installation
```bash
# List installed packages
adb shell pm list packages | grep karbonson

# Check APK info
adb shell dumpsys package com.example.karbonson
```

## Performance Optimization

### Build Speed Improvements
- Use `--no-tree-shake-icons` for faster builds
- Use `--split-per-abi` for smaller APKs per architecture
- Configure Gradle daemon for faster subsequent builds

### APK Size Reduction
The current configuration includes:
- R8 code shrinking
- Resource shrinking
- Unused resource removal
- DEX file optimization

## Additional Build Variants

### Debug APK (For Testing)
```bash
flutter build apk --debug
```

### Release APK (Signed for Distribution)
```bash
flutter build apk --release
```

### App Bundle (For Google Play)
```bash
flutter build appbundle
```

## Files Created/Modified

### New Files
- `build_apk.sh` - Automated build script
- `APK_BUILD_PLAN.md` - This guide

### Modified Files
- Launcher icons generated in `android/app/src/main/res/`

## Support

### Build Issues
- Check Flutter documentation: https://docs.flutter.dev/deployment/android
- Check Android Gradle Plugin docs: https://developer.android.com/studio/build

### Firebase Issues
- Firebase Console: https://console.firebase.google.com
- Firebase Documentation: https://firebase.google.com/docs/flutter/setup

## Summary

The Karbonson Android application is fully configured for APK generation. The project includes:

✅ Complete Gradle configuration with Java 21 and Gradle 8.12  
✅ Release build configuration with minification  
✅ ProGuard rules for Firebase and dependencies  
✅ Firebase services integration  
✅ Launcher icons configuration  
✅ All necessary Android permissions  
✅ Build automation script  

**To build the APK**: Run `./build_apk.sh` in the project directory.

