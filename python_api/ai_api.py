import json
from flask import Flask, request, jsonify
from flask_cors import CORS
import pandas as pd
import numpy as np
from sklearn.decomposition import TruncatedSVD
from scipy.sparse import csr_matrix
import uuid
from datetime import datetime

app = Flask(__name__)
CORS(app)

# Kullanıcı quiz geçmişi verileri (örnek veri)
user_quiz_data = {
    "user1": [
        {"quiz_id": "quiz1", "rating": 5, "timestamp": "2025-01-15T10:00:00"},
        {"quiz_id": "quiz2", "rating": 3, "timestamp": "2025-01-16T14:30:00"},
        {"quiz_id": "quiz3", "rating": 4, "timestamp": "2025-01-17T09:15:00"},
    ],
    "user2": [
        {"quiz_id": "quiz1", "rating": 4, "timestamp": "2025-01-15T11:20:00"},
        {"quiz_id": "quiz4", "rating": 5, "timestamp": "2025-01-16T16:45:00"},
        {"quiz_id": "quiz5", "rating": 3, "timestamp": "2025-01-17T13:10:00"},
    ],
    "user3": [
        {"quiz_id": "quiz2", "rating": 5, "timestamp": "2025-01-15T15:30:00"},
        {"quiz_id": "quiz3", "rating": 4, "timestamp": "2025-01-16T10:00:00"},
        {"quiz_id": "quiz6", "rating": 5, "timestamp": "2025-01-17T11:30:00"},
    ]
}

# Quiz meta verileri (örnek veri)
quiz_metadata = {
    "quiz1": {"title": "Türkiye Coğrafyası", "category": "Coğrafya", "difficulty": "Orta"},
    "quiz2": {"title": "Osmanlı Tarihi", "category": "Tarih", "zorluk": "Zor"},
    "quiz3": {"title": "Temel Matematik", "category": "Matematik", "difficulty": "Kolay"},
    "quiz4": {"title": "Dünya Başkentleri", "category": "Coğrafya", "difficulty": "Kolay"},
    "quiz5": {"title": "Antik Roma", "category": "Tarih", "difficulty": "Orta"},
    "quiz6": {"title": "Cebir", "category": "Matematik", "difficulty": "Zor"},
}

@app.route('/recommendations', methods=['GET'])
def get_recommendations():
    user_id = request.args.get('user_id')
    
    if not user_id:
        return jsonify({'error': 'User ID is required'}), 400
    
    # Kullanıcı verilerini al
    user_data = get_user_data(user_id)
    
    if not user_data:
        return jsonify({'recommendations': []}), 200
    
    # Matris ayrıştırma tabanlı öneri sistemi kullanarak öneriler hesapla
    recommendations = generate_recommendations(user_data)
    
    return jsonify({'recommendations': recommendations})

def get_user_data(user_id):
    # Kullanıcı quiz geçmişini al (örnek veri)
    if user_id in user_quiz_data:
        return user_quiz_data[user_id]
    
    # Kullanıcı verisi yoksa boş liste döndür
    return []

def generate_recommendations(user_data):
    # Matris ayrıştırma tabanlı öneri sistemi
    all_quizzes = set()
    all_users = set()
    
    for user, quizzes in user_quiz_data.items():
        all_users.add(user)
        for quiz in quizzes:
            all_quizzes.add(quiz["quiz_id"])
    
    # Kullanıcı-quiz matrisi oluştur
    user_index = {user: i for i, user in enumerate(all_users)}
    quiz_index = {quiz: i for i, quiz in enumerate(all_quizzes)}
    
    matrix = np.zeros((len(all_users), len(all_quizzes)))
    
    for user, quizzes in user_quiz_data.items():
        for quiz_data in quizzes:
            user_idx = user_index[user]
            quiz_idx = quiz_index[quiz_data["quiz_id"]]
            matrix[user_idx][quiz_idx] = quiz_data["rating"]
    
    # Matris ayrıştırma (SVD)
    svd = TruncatedSVD(n_components=min(5, min(matrix.shape) - 1), random_state=42)
    user_factors = svd.fit_transform(matrix)
    quiz_factors = svd.components_.T
    
    # Kullanıcı için öneriler hesapla
    user_id = list(all_users)[0]  # İlk kullanıcıyı örnek olarak al
    user_idx = user_index[user_id]
    
    # Kullanıcının henüz yapmadığı quizleri bul
    user_ratings = matrix[user_idx]
    not_rated_quizzes = [i for i, rating in enumerate(user_ratings) if rating == 0]
    
    # Öneri puanlarını hesapla
    recommendations = []
    for quiz_idx in not_rated_quizzes:
        # Kullanıcı faktörleri ile quiz faktörlerini çarp
        score = np.dot(user_factors[user_idx], quiz_factors[quiz_idx])
        
        # Quiz meta verilerini al
        quiz_id = list(all_quizzes)[quiz_idx]
        quiz_info = quiz_metadata.get(quiz_id, {})
        
        # Öneri oluştur
        recommendation = {
            "quizId": quiz_id,
            "quizTitle": quiz_info.get("title", "Bilinmeyen Quiz"),
            "category": quiz_info.get("category", "Genel"),
            "confidenceScore": float(score),
            "reason": "Based on your quiz history and similar user preferences"
        }
        
        recommendations.append(recommendation)
    
    # Güven puanına göre sırala
    recommendations.sort(key=lambda x: x["confidenceScore"], reverse=True)
    
    # İlk 3 öneriyi döndür
    return recommendations[:3]

@app.route('/analyze', methods=['GET'])
def analyze_user():
    user_id = request.args.get('user_id')
    
    if not user_id:
        return jsonify({'error': 'User ID is required'}), 400
    
    # Kullanıcı davranış analizi (örnek veri)
    analysis = {
        "userId": user_id,
        "preferredCategories": ["Coğrafya", "Tarih"],
        "avgScore": 4.2,
        "engagementLevel": "Yüksek",
        "timeSpent": "15 dakika",
        "lastActive": "2025-01-17T15:30:00",
        "recommendationsCount": 3,
        "socialInteractions": 5
    }
    
    return jsonify(analysis)

@app.route('/user_data', methods=['POST'])
def submit_user_data():
    user_data = request.get_json()
    
    if not user_data:
        return jsonify({'error': 'No data provided'}), 400
    
    # Kullanıcı verilerini işle (örnek)
    print(f"Received user data: {json.dumps(user_data, indent=2)}")
    
    # Başarı mesajı döndür
    return jsonify({'status': 'success', 'message': 'User data received'})

if __name__ == '__main__':
    app.run(host='0.0.0.0', port=5000, debug=True)
