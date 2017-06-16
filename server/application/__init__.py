from flask import Flask
from flask_sqlalchemy import SQLAlchemy
from flask_mail import Mail
from werkzeug.contrib.fixers import ProxyFix
import logging
from logging.handlers import RotatingFileHandler

# logging.basicConfig(fle='dotaasker.log', level=logging.DEBUG)

app = Flask(__name__)
app.config.from_object('config')

handler = RotatingFileHandler('dotaasker.log', maxBytes=10000, backupCount=1)
handler.setLevel(logging.INFO)
app.logger.addHandler(handler)

app.wsgi_app = ProxyFix(app.wsgi_app)
db = SQLAlchemy(app)
mail = Mail(app)

from application import models, views

