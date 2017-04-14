def saveDayMMR():
    from application import db, app
    from application.models import User
    from datetime import date, datetime

    print("STARTED saveDayMMR: {}".format(datetime.now()))
    app.logger.info("STARTED saveDayMMR: {}".format(datetime.now()))
    users_list = User.query.all()
    t = date.today()
    strt = t.strftime("%Y-%m-%d")
    print(strt)

    for u in users_list:
        result = db.engine.execute("REPLACE INTO user_date_mmr (user_id, date, mmr) VALUES ({}, '{}', {})".format(u.id, strt, u.mmr))

if __name__ == '__main__':
    import sys 
    sys.path.append('/home/zykis/DotaAsker/server/')
    saveDayMMR()
