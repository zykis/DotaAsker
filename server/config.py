#!flask.bin/python
import os

basedir = os.path.abspath(os.path.dirname(__file__))
questiondir = os.path.join(basedir, 'application/static/questions')

HOST = '192.168.100.24'
debug = True
Debug = True
DEBUG = True

SQLALCHEMY_DATABASE_URI = 'sqlite:///' + os.path.join(basedir, 'app.db')
SQLALCHEMY_MIGRATE_REPO = os.path.join(basedir, 'db_repository')
SQLALCHEMY_TRACK_MODIFICATIONS = True
SQLALCHEMY_ECHO=False
SECRET_KEY = 'sadlk21lkmsadhaaw'
MATCH_LIFETIME = 2 * 24 * 60 * 60
MATCH_UPDATELIFE = 2 * 24 * 60 * 60

# Flask-APScheduler
JOBS = [
    {
        'id': 'check_elapsed',
        'func': 'application.management.commands.checkTimeElapsedMatches:run',
        'trigger': 'cron',
        'minute': '*/1'
    },
    {
        'id': 'save_mmr',
        'func': 'application.management.commands.saveDayMMR:run',
        'trigger': 'cron',
        'minute': '*/1'
    },
    {
        'id': 'func_3',
        'func': 'application:func3',
        'trigger': 'cron',
        'second': '*/5'
    }
]

# Flask-Mail settings
MAIL_SERVER="smtp.gmail.com"
MAIL_PORT=465
MAIL_USE_TLS=False
MAIL_USE_SSL=True
MAIL_USERNAME="zykis39"
MAIL_PASSWORD="my_pwd"
DEFAULT_MAIL_SENDER='zykis39@gmail.com'

# MMR
MMR_GAIN_MIN = 5
MMR_GAIN_MAX = 50
MMR_GAIN_STEP = 5

MMR_CEIL = 8000
MMR_BOTTOM = 2000