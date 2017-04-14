from flask import Flask
from flask_sqlalchemy import SQLAlchemy
from flask_mail import Mail
from werkzeug.contrib.fixers import ProxyFix
from flask_apscheduler import APScheduler
import logging  

logging.basicConfig(fle='dotaasker.log', level=logging.DEBUG)

app = Flask(__name__)
app.config.from_object('config')
app.wsgi_app = ProxyFix(app.wsgi_app)
db = SQLAlchemy(app)
mail = Mail(app)
scheduler = APScheduler()
scheduler.api_enabled = True
scheduler.init_app(app)
scheduler.start()

from application import models, views

