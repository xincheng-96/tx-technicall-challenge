from flask import Flask
from flask_wtf.csrf import CSRFProtect
from .handlers.routes import configure_routes

app = Flask(__name__)
csrf = CSRFProtect()
csrf.init_app(app)

configure_routes(app)

def main():
    app.run()

if __name__ == '__main__':
    main()