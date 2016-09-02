from flask import Flask
from flask_sqlalchemy import SQLAlchemy
from flask_login import LoginManager
import logging

logging.basicConfig(level=logging.DEBUG)

lm = LoginManager()
app = Flask(__name__)
lm.init_app(app)
app.config.from_object('config')
db = SQLAlchemy(app)

from app import models, views