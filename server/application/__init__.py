from flask import Flask
from flask_sqlalchemy import SQLAlchemy
from flask_mail import Mail
from werkzeug.contrib.fixers import ProxyFix
import logging  

logging.basicConfig(fle='dotaasker.log', level=logging.DEBUG)

app = Flask(__name__)
app.config.from_object('config')
app.wsgi_app = ProxyFix(app.wsgi_app)
db = SQLAlchemy(app)
mail = Mail(app)

from application import models, views

from apscheduler.schedulers.background import BackgroundScheduler, BlockingScheduler
from apscheduler.jobstores.memory import MemoryJobStore
from apscheduler.executors.pool import ThreadPoolExecutor, ProcessPoolExecutor
from apscheduler.triggers.cron import CronTrigger
from datetime import datetime
from pytz import utc

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

import application.management.commands.saveDayMMR
import application.management.commands.checkTimeElapsedMatches

scheduler = BackgroundScheduler(jobstores=jobstores, executors=executors, job_defaults=job_defaults, timezone=utc)
scheduler.add_job(application.management.commands.checkTimeElapsedMatches.checkTimeElapsedMatches, 'cron', minute='*/1')
scheduler.add_job(application.management.commands.saveDayMMR.saveDayMMR, 'cron', minute='*/1')
scheduler.start()
