from database import Match, Database

class MatchParser:
    @classmethod
    def toJSON(self, match):
        if(match is None or not isinstance(match, Match)):
            return None
        else:
            return match.tojson()

    @classmethod
    def fromJSON(self, matchDict):
        m = Match()
        m.id = matchDict['ID']
        m.state = matchDict['STATE']
        users = dict()
        for u in matchDict['USERS_ID']:
            m.users.append(Database.get('User'))