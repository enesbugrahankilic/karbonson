#!/usr/bin/env python3
"""
Sample questions adder for KarbonSon quiz system
"""

import json
import requests

# Sample questions data
sample_questions = [
    {
        "id": "q1",
        "text": "Dünya'nın en büyük okyanusu hangisidir?",
        "options": [
            {"text": "Pasifik Okyanusu", "score": 10, "feedback": "Doğru! Pasifik Okyanusu dünyanın en büyük okyanusudur."},
            {"text": "Atlas Okyanusu", "score": 0, "feedback": "Yanlış. Atlas Okyanusu ikinci büyük okyanustur."},
            {"text": "Hint Okyanusu", "score": 0, "feedback": "Yanlış. Hint Okyanusu üçüncü büyük okyanustur."},
            {"text": "Arktik Okyanusu", "score": 0, "feedback": "Yanlış. Arktik Okyanusu en küçük okyanustur."}
        ],
        "category": "Coğrafya",
        "difficulty": "easy",
        "timeLimit": 30,
        "explanation": "Pasifik Okyanusu, dünya yüzeyinin yaklaşık %46'sını kaplar ve en büyük okyanustur.",
        "tags": ["okyanus", "coğrafya", "dünya"]
    },
    {
        "id": "q2",
        "text": "Fotosentez sırasında bitkiler hangi gazı alır?",
        "options": [
            {"text": "Karbondioksit", "score": 10, "feedback": "Doğru! Bitkiler fotosentez sırasında karbondioksiti alır."},
            {"text": "Oksijen", "score": 0, "feedback": "Yanlış. Oksijen fotosentez sonucu üretilir."},
            {"text": "Azot", "score": 0, "feedback": "Yanlış. Azot atmosferin büyük kısmını oluşturur ama fotosentezde kullanılmaz."},
            {"text": "Hidrojen", "score": 0, "feedback": "Yanlış. Hidrojen suda bulunur."}
        ],
        "category": "Biyoloji",
        "difficulty": "medium",
        "timeLimit": 25,
        "explanation": "Fotosentez: 6CO₂ + 6H₂O + ışık → C₆H₁₂O₆ + 6O₂",
        "tags": ["fotosentez", "bitki", "biyoloji"]
    },
    {
        "id": "q3",
        "text": "İlk Türk cumhurbaşkanı kimdir?",
        "options": [
            {"text": "Mustafa Kemal Atatürk", "score": 10, "feedback": "Doğru! Mustafa Kemal Atatürk Türkiye Cumhuriyeti'nin ilk cumhurbaşkanıdır."},
            {"text": "İsmet İnönü", "score": 0, "feedback": "Yanlış. İsmet İnönü ikinci cumhurbaşkanıdır."},
            {"text": "Celal Bayar", "score": 0, "feedback": "Yanlış. Celal Bayar üçüncü cumhurbaşkanıdır."},
            {"text": "Adnan Menderes", "score": 0, "feedback": "Yanlış. Adnan Menderes dokuzuncu cumhurbaşkanıdır."}
        ],
        "category": "Tarih",
        "difficulty": "easy",
        "timeLimit": 20,
        "explanation": "Mustafa Kemal Atatürk, 29 Ekim 1923'te Türkiye Cumhuriyeti'nin ilk cumhurbaşkanı olarak seçilmiştir.",
        "tags": ["atatürk", "türkiye", "cumhuriyet", "tarih"]
    },
    {
        "id": "q4",
        "text": "Hangi element periyodik tabloda 'He' sembolü ile gösterilir?",
        "options": [
            {"text": "Helyum", "score": 10, "feedback": "Doğru! He sembolü helyumu temsil eder."},
            {"text": "Hidrojen", "score": 0, "feedback": "Yanlış. Hidrojen 'H' sembolü ile gösterilir."},
            {"text": "Helyum-3", "score": 0, "feedback": "Yanlış. Helyum-3 helyumun izotopudur ama sembol aynıdır."},
            {"text": "Hafniyum", "score": 0, "feedback": "Yanlış. Hafniyum 'Hf' sembolü ile gösterilir."}
        ],
        "category": "Kimya",
        "difficulty": "medium",
        "timeLimit": 30,
        "explanation": "Helyum (He), atom numarası 2 olan soy gazdır ve periyodik tablonun 18. grubundadır.",
        "tags": ["kimya", "element", "periyodik tablo"]
    },
    {
        "id": "q5",
        "text": "Güneş sistemimizde kaç gezegen vardır?",
        "options": [
            {"text": "8", "score": 10, "feedback": "Doğru! Güneş sisteminde 8 gezegen vardır."},
            {"text": "9", "score": 0, "feedback": "Yanlış. Plüton artık cüce gezegen olarak sınıflandırılıyor."},
            {"text": "7", "score": 0, "feedback": "Yanlış. Güneş sisteminde 8 gezegen vardır."},
            {"text": "10", "score": 0, "feedback": "Yanlış. Güneş sisteminde 8 gezegen vardır."}
        ],
        "category": "Astronomi",
        "difficulty": "easy",
        "timeLimit": 15,
        "explanation": "Güneş sistemindeki 8 gezegen: Merkür, Venüs, Dünya, Mars, Jüpiter, Satürn, Uranüs ve Neptün.",
        "tags": ["gezegen", "güneş sistemi", "astronomi"]
    },
    {
        "id": "q6",
        "text": "İnsanın kalbinin kaç odacığı vardır?",
        "options": [
            {"text": "4", "score": 10, "feedback": "Doğru! Kalbin 4 odacığı vardır: 2 kulakçık ve 2 karıncık."},
            {"text": "2", "score": 0, "feedback": "Yanlış. Kalbin 4 odacığı vardır."},
            {"text": "3", "score": 0, "feedback": "Yanlış. Kalbin 4 odacığı vardır."},
            {"text": "6", "score": 0, "feedback": "Yanlış. Kalbin 4 odacığı vardır."}
        ],
        "category": "Biyoloji",
        "difficulty": "medium",
        "timeLimit": 25,
        "explanation": "İnsan kalbi 4 odacıklıdır: sağ kulakçık, sağ karıncık, sol kulakçık ve sol karıncık.",
        "tags": ["kalp", "biyoloji", "anatomi"]
    },
    {
        "id": "q7",
        "text": "Hangi matematiksel sabit yaklaşık olarak 3.14159 değerine eşittir?",
        "options": [
            {"text": "π (Pi)", "score": 10, "feedback": "Doğru! π (Pi) sayısı yaklaşık 3.14159'dur."},
            {"text": "e (Euler sayısı)", "score": 0, "feedback": "Yanlış. e yaklaşık 2.71828'dir."},
            {"text": "φ (Altın oran)", "score": 0, "feedback": "Yanlış. φ yaklaşık 1.618'dir."},
            {"text": "γ (Euler-Mascheroni sabiti)", "score": 0, "feedback": "Yanlış. γ yaklaşık 0.577'dir."}
        ],
        "category": "Matematik",
        "difficulty": "easy",
        "timeLimit": 20,
        "explanation": "π (Pi) sayısı, bir dairenin çevresinin çapına oranıdır ve yaklaşık 3.14159 değerindedir.",
        "tags": ["matematik", "pi", "geometri"]
    },
    {
        "id": "q8",
        "text": "İlk dünya savaşı hangi yıllar arasında gerçekleşmiştir?",
        "options": [
            {"text": "1914-1918", "score": 10, "feedback": "Doğru! I. Dünya Savaşı 1914-1918 yılları arasında gerçekleşmiştir."},
            {"text": "1912-1916", "score": 0, "feedback": "Yanlış. Savaş 1914'te başlamıştır."},
            {"text": "1916-1920", "score": 0, "feedback": "Yanlış. Savaş 1918'de bitmiştir."},
            {"text": "1910-1914", "score": 0, "feedback": "Yanlış. Savaş 1914'te başlamıştır."}
        ],
        "category": "Tarih",
        "difficulty": "medium",
        "timeLimit": 30,
        "explanation": "I. Dünya Savaşı, 28 Temmuz 1914'te Avusturya-Macaristan'ın Sırbistan'a savaş ilan etmesiyle başlamış ve 11 Kasım 1918'de ateşkesle sona ermiştir.",
        "tags": ["tarih", "dünya savaşı", "1914-1918"]
    },
    {
        "id": "q9",
        "text": "Hangi programlama dili 'Python' olarak adlandırılmıştır?",
        "options": [
            {"text": "Yılan türünden esinlenerek", "score": 10, "feedback": "Doğru! Python adı, Monty Python komedi grubu ve yılan türünden esinlenmiştir."},
            {"text": "Yazar Guido van Rossum'un adı", "score": 0, "feedback": "Yanlış. Guido van Rossum Python'ı yaratmıştır ama dilin adı ondan gelmez."},
            {"text": "Bir matematik terimi", "score": 0, "feedback": "Yanlış. Python programlama dilidir."},
            {"text": "Bir şehir adı", "score": 0, "feedback": "Yanlış. Python bir programlama dilidir."}
        ],
        "category": "Bilgisayar",
        "difficulty": "hard",
        "timeLimit": 35,
        "explanation": "Python programlama dili, 1991'de Guido van Rossum tarafından yaratılmıştır. Adı, Monty Python komedi grubundan ve yılan türünden esinlenmiştir.",
        "tags": ["python", "programlama", "bilgisayar"]
    },
    {
        "id": "q10",
        "text": "DNA'nın açılımı nedir?",
        "options": [
            {"text": "Deoksiribonükleik Asit", "score": 10, "feedback": "Doğru! DNA, Deoksiribonükleik Asit'in kısaltmasıdır."},
            {"text": "Deoksiriboz Nükleik Asit", "score": 0, "feedback": "Yanlış. Doğru açılım Deoksiribonükleik Asit'tir."},
            {"text": "Dinamik Nükleer Asit", "score": 0, "feedback": "Yanlış. DNA kalıtım materyalidir."},
            {"text": "Dijital Nöral Ağ", "score": 0, "feedback": "Yanlış. DNA biyolojik bir moleküldür."}
        ],
        "category": "Biyoloji",
        "difficulty": "easy",
        "timeLimit": 25,
        "explanation": "DNA (Deoksiribonükleik Asit), canlı organizmaların genetik bilgisini taşıyan moleküldür.",
        "tags": ["dna", "biyoloji", "genetik"]
    }
]

def add_questions():
    """Add sample questions to the database"""
    try:
        url = "http://localhost:5001/add_questions"
        response = requests.post(url, json=sample_questions, headers={'Content-Type': 'application/json'})

        if response.status_code == 200:
            result = response.json()
            print(f"✅ Success: {result['message']}")
            print(f"Added {len(result['questions'])} questions")
            for q in result['questions'][:3]:  # Show first 3
                print(f"  - {q['text'][:50]}...")
        else:
            print(f"❌ Error: {response.status_code}")
            print(response.text)

    except Exception as e:
        print(f"❌ Failed to add questions: {e}")

def check_questions():
    """Check existing questions in database"""
    try:
        url = "http://localhost:5001/get_questions"
        response = requests.get(url)

        if response.status_code == 200:
            result = response.json()
            print(f"📊 Database has {result['count']} questions")
            if result['count'] > 0:
                print("Sample questions:")
                for q in result['questions'][:3]:  # Show first 3
                    print(f"  - {q.get('text', 'No text')[:50]}...")
        else:
            print(f"❌ Error checking questions: {response.status_code}")
            print(response.text)

    except Exception as e:
        print(f"❌ Failed to check questions: {e}")

if __name__ == "__main__":
    print("🔍 Checking existing questions...")
    check_questions()

    print("\n📝 Adding sample questions...")
    add_questions()

    print("\n🔍 Verifying questions were added...")
    check_questions()