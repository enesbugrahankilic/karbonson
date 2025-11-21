#!/bin/bash

# iOS Build Fix Script - Temizle ve Yeniden Inşa Et
# Amaç: x86_64 simulator için "-G" flag hatasını çözümle

set -e

echo "=========================================="
echo "iOS Build Fix Script Başlayıyor..."
echo "=========================================="
echo ""

PROJECT_DIR="/Users/omer/karbonson"
cd "$PROJECT_DIR"

# 1. Flutter temizliği
echo "📦 Flutter temizliğini yapıyorum..."
flutter clean
flutter pub get

# 2. CocoaPods temizliği ve yeniden kurulum
echo "🧹 iOS pod bağımlılıklarını temizliyorum..."
cd ios

# Eski Podfile.lock'u kaldır
if [ -f Podfile.lock ]; then
  rm -f Podfile.lock
  echo "  ✓ Podfile.lock silindi"
fi

# CocoaPods cache'i temizle
echo "  → pod cache temizleniyor..."
pod cache clean --all 2>/dev/null || true

# Podfile.lock'u yeniden oluştur
echo "🔄 Pod bağımlılıklarını yeniden kuruyorum..."
pod install --repo-update

# 3. Xcode DerivedData temizliği
echo "📁 Xcode DerivedData'yı temizliyorum..."
rm -rf ~/Library/Developer/Xcode/DerivedData/*
echo "  ✓ DerivedData silindi"

# 4. Build klasörleri temizliği
echo "🗑️  Build artefaktlarını temizliyorum..."
rm -rf build/
echo "  ✓ build/ silindi"

cd "$PROJECT_DIR"

echo ""
echo "=========================================="
echo "✅ Temizlik tamamlandı!"
echo "=========================================="
echo ""
echo "Sonraki adım:"
echo "  flutter run"
echo ""
