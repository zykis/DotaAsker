from application import db, app
from application.models import Match, MATCH_FINISHED, MATCH_RUNNING
from datetime import datetime
from config import MATCH_LIFETIME, MATCH_UPDATELIFE

def checkTimeElapsedMatches():
    app.logger.info("STARTED checkTimeElapsedMatches: {}".format(datetime.now()))
    match_list = Match.query.all()
    app.logger.debug('matches: {}'.format(match_list))
    for m in match_list:
        if m.state == MATCH_RUNNING:
            timeDiffInSec = datetime.now() - m.updated_on
            app.logger.debug('match {} last updated {} hours ago'.format(m.__repr__(), timeDiffInSec.total_seconds() / (60 * 60)))
            if MATCH_UPDATELIFE < timeDiffInSec.total_seconds():
                app.logger.debug('match {} elapsed'.format(m.__repr__()))
                # checkout winner
		m.elapseMatch()
		db.session.add(m)
		db.session.add(m.users)
    db.session.commit()

if __name__ == '__main__':
    checkTimeElapsedMatches()
