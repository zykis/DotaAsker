def run():
    from datetime import date, datetime

    tnow = datetime.now()
    print ('{}: starting saveDayMMR.py'.format(tnow.strftime('%Y-%m-%d %H:%M:%S')))

    t = date.today()
    strt = t.strftime("%Y-%m-%d")
    from application import db
    from application.models import User

    users_list = User.query.all()
    for u in users_list:
        result = db.engine.execute("INSERT OR REPLACE INTO user_date_mmr (user_id, date, mmr) VALUES ({}, '{}', {})".format(u.id, strt, u.mmr))
    print ('{}: ending saveDayMMR.py'.format(tnow.strftime('%Y-%m-%d %H:%M:%S')))

if __name__ == '__main__':
    import sys 
    sys.path.append('/home/zykis/DotaAsker/server/')
    sys.path.append('/home/zykis/DotaAsker/server/flask/lib/python2.7/site-packages/')
    
    sys.path.append('/home/artem/projects/DotaAsker/server/')
    sys.path.append('/home/artem/projects/DotaAsker/server/flask/lib/python2.7/site-packages/')
    run()
