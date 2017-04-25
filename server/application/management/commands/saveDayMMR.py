def run():
    from datetime import date, datetime
    print("STARTED saveDayMMR: {}".format(datetime.now()))
    t = date.today()
    strt = t.strftime("%Y-%m-%d")
    print(strt)
    from application import db
    from application.models import User

    users_list = User.query.all()
    for u in users_list:
        result = db.engine.execute("INSERT OR REPLACE INTO user_date_mmr (user_id, date, mmr) VALUES ({}, '{}', {})".format(u.id, strt, u.mmr))

if __name__ == '__main__':
    import sys 
    sys.path.append('/home/zykis/DotaAsker/server/')
    run()
