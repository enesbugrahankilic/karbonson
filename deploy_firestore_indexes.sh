#!/bin/bash

# Firebase Firestore Index Deployment Script
# Bu script Firestore composite index'lerini deploy eder

echo "🚀 Firebase Firestore Index Deployment başlatılıyor..."

# Firebase CLI kontrolü
if ! command -v firebase &> /dev/null; then
    echo "❌ Firebase CLI bulunamadı!"
    echo "📦 Firebase CLI kurulumu için: npm install -g firebase-tools"
    exit 1
fi

# Login kontrolü
firebase projects:list &> /dev/null
if [ $? -ne 0 ]; then
    echo "🔐 Firebase login gerekli..."
    firebase login
fi

echo "📊 Firestore index'leri deploy ediliyor..."
firebase deploy --only firestore:indexes

if [ $? -eq 0 ]; then
    echo "✅ Firestore index'leri başarıyla deploy edildi!"
    echo "⏳ Index'lerin aktif olması 2-5 dakika sürebilir..."
    echo "🔗 Durumu kontrol etmek için: https://console.firebase.google.com/project/karbon2-c39e7/firestore/indexes"
else
    echo "❌ Index deployment başarısız!"
    echo "🔧 Manuel olarak Firebase Console'dan oluşturabilirsiniz:"
    echo "   https://console.firebase.google.com/v1/r/project/karbon2-c39e7/firestore/indexes"
fi

echo ""
echo "📝 Index oluşturma detayları:"
echo "   Collection: game_rooms"
echo "   Fields: isActive (ASC), status (ASC), createdAt (DESC)"
echo ""
echo "🔗 Firebase Console: https://console.firebase.google.com/project/karbon2-c39e7/firestore/indexes"