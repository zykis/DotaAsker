from flask import Flask
from flask_sqlalchemy import SQLAlchemy
from flask_mail import Mail
from werkzeug.contrib.fixers import ProxyFix
from flask_apscheduler import APScheduler
from from apscheduler.schedulers.blocking import BlockingScheduler
import logging  

logging.basicConfig(fle='dotaasker.log', level=logging.DEBUG)

def func3():
    print('func3 started')

app = Flask(__name__)
app.config.from_object('config')

sch = BlockingScheduler()
scheduler = APScheduler(scheduler=sch)
scheduler.init_app(app)
scheduler.start()

app.wsgi_app = ProxyFix(app.wsgi_app)
db = SQLAlchemy(app)
mail = Mail(app)

from application import models, views

