from flask import Flask
from flask_sqlalchemy import SQLAlchemy
from flask_script import Manager
from flask_mail import Mail
from werkzeug.contrib.fixers import ProxyFix
import logging

logging.basicConfig(fle='dotaasker.log', level=logging.DEBUG)

app = Flask(__name__)
app.config.from_object('config')
app.wsgi_app = ProxyFix(app.wsgi_app)
db = SQLAlchemy(app)
manager = Manager(app)
mail = Mail(app)

from app import models, views
