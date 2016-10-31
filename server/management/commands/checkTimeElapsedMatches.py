from app import app
from app.models import Match, MATCH_FINISHED, MATCH_RUNNING, MATCH_TIME_ELAPSED
from datetime import datetime
from config import MATCH_LIFETIME, MATCH_UPDATELIFE

def checkTimeElapsedMatches():
    match_list = Match.query.all()
    for m in match_list:
        if m.state == MATCH_RUNNING:
             timeDiffInSec = datetime.now() - m.updated_on
             if MATCH_UPDATELIFE < timDiffInSec:
                 m.state = TIME_ELAPSED
                 # checkout winner

