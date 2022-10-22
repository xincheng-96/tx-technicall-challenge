from flask import Flask
import json
import pytest

from doker.handlers.routes import configure_routes

@pytest.fixture
def client():
    app = Flask(__name__)
    configure_routes(app)
    client = app.test_client()

    return client

def test_status_route(client):

    url = '/status'

    response = client.get(url)
    assert response.get_data() == b'[{"status":"ok"}]\n'
    assert response.status_code == 200

def test_encode_string(client):
    app = Flask(__name__)
    configure_routes(app)
    client = app.test_client()
    url = '/AbcXyz'

    response = client.get(url)
    print(response)
    assert response.get_data() == b'FghCde'
    assert response.status_code == 200

def test_encode_number(client):
    app = Flask(__name__)
    configure_routes(app)
    client = app.test_client()
    url = '/012789'

    response = client.get(url)
    print(response)
    assert response.get_data() == b'567234'
    assert response.status_code == 200