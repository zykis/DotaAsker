#!flask.bin/python
import os
basedir = os.path.abspath(os.path.dirname(__file__))
questiondir = os.path.join(basedir, 'app/static/questions')

SQLALCHEMY_DATABASE_URI = 'sqlite:///' + os.path.join(basedir, 'app.db')
SQLALCHEMY_MIGRATE_REPO = os.path.join(basedir, 'db_repository')
SQLALCHEMY_TRACK_MODIFICATIONS = True
SQLALCHEMY_ECHO=False
SECRET_KEY = 'sadlk21lkmsadhaaw'

QUESTIONS_IN_ROUND = 3
ROUNDS_IN_MATCH = 6
THEMES_COUNT = 3