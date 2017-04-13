from flask import Flask
from flask_sqlalchemy import SQLAlchemy
from flask_script import Manager
from flask_mail import Mail
from werkzeug.contrib.fixers import ProxyFix
import logging  

from apscheduler.schedulers.background import BackgroundScheduler, BlockingScheduler
from apscheduler.jobstores.memory import MemoryJobStore
from apscheduler.executors.pool import ThreadPoolExecutor, ProcessPoolExecutor
from apscheduler.triggers.date import DateTrigger
from datetime import datetime

logging.basicConfig(fle='dotaasker.log', level=logging.DEBUG)

app = Flask(__name__)
app.config.from_object('config')
app.wsgi_app = ProxyFix(app.wsgi_app)
db = SQLAlchemy(app)
manager = Manager(app)
mail = Mail(app)

from app import models, views

jobstores = {
    'default': MemoryJobStore(),
}
executors = {
    'default': ThreadPoolExecutor(1),
}
job_defaults = {
    'coalesce': False,
    'max_instances': 2
}

everyDay = datetime(hour=23, minute=30)
trigger = DateTrigger(run_date=everyDay, timezone=utc)

import app.management.commands.saveDayMMR
import app.management.commands.checkTimeElapsedMatches
scheduler.add_job(app.management.commands.checkTimeElapsedMatches.checkTimeElapsedMatches, trigger=trigger)
scheduler.add_job(app.management.commands.saveDayMMR.saveDayMMR, trigger=trigger)

scheduler = BackgroundScheduler(jobstores=jobstores, executors=executors, job_defaults=job_defaults, timezone=utc)
scheduler.start()