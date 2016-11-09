from flask import Flask
from flask_sqlalchemy import SQLAlchemy
from flask_script import Manager
from flask_mail import Mail
import logging

logging.basicConfig(level=logging.DEBUG)

app = Flask(__name__)
app.config.from_object('config')
db = SQLAlchemy(app)
manager = Manager(app)
mail = Mail(app)

from app import models, views
