from entity import *
from sqlalchemy import Table
from sqlalchemy import and_ ,or_
from sqlalchemy.orm import backref

# friends_table = Table('friends_t', Base.metadata,
#                             Column('from_id', Integer, ForeignKey('users.id', ondelete='CASCADE')),
#                             Column('to_id', Integer, ForeignKey('users.id', ondelete='CASCADE')),
#                             Column('confirmed', Boolean, default=False)
#                             )
class Friends(Base):
    __tablename__ = 'friends_t'
    from_id = Column(Integer, ForeignKey('users.id', ondelete='CASCADE'), primary_key=True)
    to_id = Column(Integer, ForeignKey('users.id', ondelete='CASCADE'), primary_key=True)
    confirmed = Column(Boolean, default=False)

    from_user = relationship('User', backref=backref('out_requests', lazy='dynamic'), primaryjoin='User.id == Friends.from_id')
    to_user = relationship('User', backref=backref('in_requests', lazy='dynamic'), primaryjoin='User.id == Friends.to_id')

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

    def sendRequest(self, aUser):
        f = Friends(confirmed=False, from_id=self.id, to_id=aUser.id)
        self.out_requests.append(f)
        aUser.in_requests.append(f)

    def isPending(self, aUser):
        return self.out_requests.filter(Friends.to_id==aUser.id, Friends.confirmed==False).count() > 0

    def isFriend(self, aUser):
        b2 = self.in_requests.filter(Friends.from_id==aUser.id, Friends.confirmed==True).count() > 0
        return b1 or b2

    def acceptRequest(self, aUser):
        if aUser.isPending(self):
            f = self.in_requests.filter(Friends.from_id==aUser.id).one()
            f.confirmed = True

    def removeFriend(self, aUser):
        if self.isFriend(aUser) == True:
            if self.out_requests.filter(Friends.to_id==aUser.id, Friends.confirmed==True).count() > 0:
                f = self.out_requests.filter(Friends.to_id==aUser.id, Friends.confirmed==True).one()
                self.out_requests.remove(f)
                aUser.in_requests.remove(f)
            elif self.in_requests.filter(Friends.from_id==aUser.id, Friends.confirmed==True).count() > 0:
                f = self.in_requests.filter(Friends.from_id==aUser.id, Friends.confirmed==True).one()
                self.in_requests.remove(f)
                aUser.out_requests.remove(f)

    def columnitems(self):
            clitemsDict = super(User, self).columnitems()
            listOfCurrentMatches = []
            listOfRecentMatches = []
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
        b1 = self.out_requests.filter(Friends.to_id==aUser.id, Friends.confirmed==True).count() > 0

