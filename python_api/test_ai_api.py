import pytest
import json
from ai_api import app

@pytest.fixture
def client():
    app.config['TESTING'] = True
    with app.test_client() as client:
        yield client

def test_recommendations_endpoint(client):
    # Test that the recommendations endpoint returns the expected response
    response = client.get('/recommendations?user_id=user1')
    assert response.status_code == 200
    
    data = json.loads(response.data)
    assert 'recommendations' in data
    assert isinstance(data['recommendations'], list)

def test_analyze_endpoint(client):
    # Test that the analyze endpoint returns the expected response
    response = client.get('/analyze?user_id=user1')
    assert response.status_code == 200
    
    data = json.loads(response.data)
    assert 'userId' in data
    assert 'preferredCategories' in data
    assert 'engagementLevel' in data

def test_user_data_endpoint(client):
    # Test that the user_data endpoint accepts and processes data
    test_data = {
        "userId": "test_user",
        "quizHistory": [
            {"quizId": "quiz1", "rating": 5},
            {"quizId": "quiz2", "rating": 4}
        ]
    }
    
    response = client.post('/user_data', 
                           json=test_data,
                           content_type='application/json')
    assert response.status_code == 200
    
    data = json.loads(response.data)
    assert 'status' in data
    assert data['status'] == 'success'
