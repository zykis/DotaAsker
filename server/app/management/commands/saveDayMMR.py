from app import db
from app.models import User
from datetime import date

def saveDayMMR():
    users_list = Users.query.all()
    today = date.today()
    for u in users_list:
        result = db.engine.execute("INSERT INTO user_date_mmr VALUES ({}, {}, {})".format(u.id, today, u.mmr))

if __name__ == '__main__':
    saveDayMMR()
