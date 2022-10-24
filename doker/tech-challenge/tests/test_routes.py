from flask import Flask
from flask_wtf.csrf import CSRFProtect
import pytest

from src.handlers.routes import configure_routes

# initialize app
@pytest.fixture
def client():
    app = Flask(__name__)
    csrf = CSRFProtect()
    csrf.init_app(app)
    configure_routes(app)
    client = app.test_client()

    return client

    # test status route, should return 200
def test_status_route(client):

    url = '/status'

    response = client.get(url)
    assert response.get_data() == b'[{"status":"ok"}]\n'
    assert response.status_code == 200

    # test encoding function with letters
def test_encode_letter(client):
    app = Flask(__name__)
    csrf = CSRFProtect()
    csrf.init_app(app)
    configure_routes(app)
    client = app.test_client()
    url = '/AbcXyz'

    response = client.get(url)
    print(response)
    assert response.get_data() == b'{"encoded result":"FghCde","given string":"AbcXyz"}\n'
    assert response.status_code == 200

    #test encoding function with number
def test_encode_number(client):
    app = Flask(__name__)
    csrf = CSRFProtect()
    csrf.init_app(app)
    configure_routes(app)
    client = app.test_client()
    url = '/012789'

    response = client.get(url)
    print(response)
    assert response.get_data() == b'{"encoded result":"567234","given string":"012789"}\n'
    assert response.status_code == 200