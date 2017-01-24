#!flask.bin/python
import os
basedir = os.path.abspath(os.path.dirname(__file__))
questiondir = os.path.join(basedir, 'app/static/questions')

SQLALCHEMY_DATABASE_URI = 'sqlite:///' + os.path.join(basedir, 'app.db')
SQLALCHEMY_MIGRATE_REPO = os.path.join(basedir, 'db_repository')
SQLALCHEMY_TRACK_MODIFICATIONS = True
SQLALCHEMY_ECHO=False
SECRET_KEY = 'sadlk21lkmsadhaaw'
MATCH_LIFETIME = 2 * 24 * 60 * 60
MATCH_UPDATELIFE = 2 * 24 * 60 * 60

# Flask-Mail settings
MAIL_SERVER="smtp.gmail.com"
MAIL_PORT=465
MAIL_USE_TLS=False
MAIL_USE_SSL=True
MAIL_USERNAME="zykis39"
MAIL_PASSWORD="my_pwd"
DEFAULT_MAIL_SENDER='zykis39@gmail.com'