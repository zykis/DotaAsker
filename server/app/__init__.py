from flask import Flask
from flask_sqlalchemy import SQLAlchemy
import logging

logging.basicConfig(level=logging.DEBUG)

app = Flask(__name__)
app.config.from_object('config')
db = SQLAlchemy(app)

from app import models, views