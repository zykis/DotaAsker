def run():
    from application import db
    from application.models import Match, MATCH_FINISHED, MATCH_RUNNING
    from datetime import datetime
    from config import MATCH_LIFETIME, MATCH_UPDATELIFE

    print("STARTED checkTimeElapsedMatches: {}".format(datetime.now()))
    match_list = Match.query.all()
    print('matches: {}'.format(match_list))
    for m in match_list:
        if m.state == MATCH_RUNNING:
            timeDiffInSec = datetime.now() - m.updated_on
            print('match {} last updated {} hours ago'.format(m.__repr__(), timeDiffInSec.total_seconds() / (60 * 60)))
            if MATCH_UPDATELIFE < timeDiffInSec.total_seconds():
                print('match {} elapsed'.format(m.__repr__()))
                # checkout winner
                m.elapseMatch()

if __name__ == '__main__':
    import sys 
    sys.path.append('/home/zykis/DotaAsker/server/')
    run()
