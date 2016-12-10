if __name__ == '__main__':
    import sys 
    sys.path.append('/Users/artem/projects/DotaAsker/server/')
from app import app
from app.models import Match, MATCH_FINISHED, MATCH_RUNNING, MATCH_TIME_ELAPSED
from datetime import datetime
from config import MATCH_LIFETIME, MATCH_UPDATELIFE

def checkTimeElapsedMatches():
    match_list = Match.query.all()
    app.logger.debug('matches: {}'.format(match_list))
    for m in match_list:
        if m.state == MATCH_RUNNING:
            timeDiffInSec = datetime.now() - m.updated_on
            app.logger.debug('match {} last updated {} hours ago'.format(m.__repr__(), timeDiffInSec.total_seconds() / (60 * 60)))
            if MATCH_UPDATELIFE < timeDiffInSec.total_seconds():
                app.logger.debug('match {} elapsed'.format(m.__repr__()))
                 # checkout winner

if __name__ == '__main__':
    checkTimeElapsedMatches()
