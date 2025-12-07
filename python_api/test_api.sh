#!/bin/bash

# AI API Test Script
# Bu script, AI API endpoint'lerini test etmek için kullanılabilir

API_BASE_URL="http://localhost:5000"

echo "AI API Test Script Başlatılıyor..."
echo "======================================"

# Test 1: Öneriler endpoint'ini test et
echo -e "\n1. Öneriler Endpoint Testi:"
echo "GET $API_BASE_URL/recommendations?user_id=user1"
curl -s -w "\nHTTP Status: %{http_code}\n" "$API_BASE_URL/recommendations?user_id=user1" | python3 -m json.tool

# Test 2: Analiz endpoint'ini test et
echo -e "\n2. Analiz Endpoint Testi:"
echo "GET $API_BASE_URL/analyze?user_id=user1"
curl -s -w "\nHTTP Status: %{http_code}\n" "$API_BASE_URL/analyze?user_id=user1" | python3 -m json.tool

# Test 3: Kullanıcı verisi gönderimi test et
echo -e "\n3. Kullanıcı Verisi Gönderimi Testi:"
echo "POST $API_BASE_URL/user_data"
curl -s -w "\nHTTP Status: %{http_code}\n" -X POST "$API_BASE_URL/user_data" \
  -H "Content-Type: application/json" \
  -d '{"userId": "test_user", "quizHistory": [{"quizId": "quiz1", "rating": 5}]}' | python3 -m json.tool

echo -e "\nTest tamamlandı."

# Test script'ini doğrudan çalıştırmak için:
# bash test_api.sh
# veya
# ./test_api.sh