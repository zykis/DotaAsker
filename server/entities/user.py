from entity import *

class User(Base):
    __tablename__ = 'users'
    id = Column(Integer, primary_key=True)
    username = Column(Unicode(50), unique=True, nullable=False)
    password = Column(String(50), nullable=False)
    email = Column(String(50), unique=False, nullable=True)
    mmr = Column(Integer, nullable=False, default=4000)
    kda = Column(Float, nullable=True, default=1.0)
    gpm = Column(Integer, nullable=True, default=300)
    wallpapers_image_name = Column(String(50), nullable=False, default='wallpaper_default.jpg')
    avatar_image_name = Column(String(50), nullable=False, default='avatar_default.png')
    total_correct_answers = Column(Integer, nullable=True, default=0)
    total_incorrect_answers = Column(Integer, nullable=True, default=0)
    # relations
    matches = relationship('Match', secondary='users_matches')
    friends = relationship('User', secondary='friends')
    # income_friend_requests = relationship('User', secondary = 'friends_requests')

    # def sendFriendRequest(self, user):
    #     query = session.query(User).filter(User.id == user.id)
    #     isExists = session.query(query.exists())
    #     if isExists:
    #         #sending request

    def columnitems(self):
            clitemsDict = super(User, self).columnitems()
            listOfCurrentMatches = []
            listOfRecentMatches = []
            currentMatchesDict = dict()
            recentMatchesDict = dict()
            # session.commit()
            for match in self.matches:
                # here we convert our Match server representation to client Representation
                # need to change state of the rounds and Matches appropriately
                if match.state == 2 or match.state == 3:
                    listOfRecentMatches.append(match.id)
                else:
                    listOfCurrentMatches.append(match.id)

            currentMatchesDict = {"CURRENT_MATCHES_IDS": listOfCurrentMatches}
            recentMatchesDict = {"RECENT_MATCHES_IDS": listOfRecentMatches}
            clitemsDict = dict(clitemsDict, **currentMatchesDict)
            clitemsDict = dict(clitemsDict, **recentMatchesDict)
            # session.rollback()
            return clitemsDict

    def __repr__(self):
        return "User(id=%d, username=%s, rating=%d)" % (self.id, self.username, self.mmr)
