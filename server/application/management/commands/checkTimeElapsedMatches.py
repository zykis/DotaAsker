def run():
    from datetime import datetime
    t = datetime.now()
    print ('{}: starting checkTimeElapsedMatches.py'.format(t.strftime('%Y-%m-%d %H:%M:%S')))
    from application import db
    from application.models import Match, MATCH_FINISHED, MATCH_RUNNING
    from config import MATCH_LIFETIME, MATCH_UPDATELIFE

    match_list = Match.query.all()
    for m in match_list:
        if m.state == MATCH_RUNNING:
            timeDiffInSec = datetime.now() - m.updated_on
            if MATCH_UPDATELIFE < timeDiffInSec.total_seconds():
                print('match {} elapsed. Last updated {} hours ago.'.format(m.__repr__(), timeDiffInSec.total_seconds() / (60 * 60)))
                # checkout winner
                m.elapseMatch()
    t = datetime.now()
    print ('{}: ending checkTimeElapsedMatches.py'.format(t.strftime('%Y-%m-%d %H:%M:%S')))

if __name__ == '__main__':
    import sys 
    sys.path.append('/home/zykis/DotaAsker/server/')
    sys.path.append('/home/zykis/DotaAsker/server/flask/lib/python2.7/site-packages/')
    
    sys.path.append('/home/artem/projects/DotaAsker/server/')
    sys.path.append('/home/artem/projects/DotaAsker/server/flask/lib/python2.7/site-packages/')
    run()
