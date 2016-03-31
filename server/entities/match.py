from entity import *
from round import Round

class Match(Base):
    __tablename__ = 'matches'
    id = Column(Integer, primary_key=True)
    # (0 - not started, 1 - match running, 2 - match finished, 3 - time elapsed)
    state = Column(Integer, nullable=True, default=0)
    winner_id = Column(Integer, ForeignKey('users.id'), default=0)
    # relations
    users = relationship('User', secondary='users_matches')
    rounds = relationship('Round')
    winner = relationship('User', foreign_keys=[winner_id])

    def __init__(self, user_initiator):
        # need to find out, if user exists already
        self.state = 0 #state = NOT_STARTED
        self.creation_time = datetime.datetime.now()
        self.initiator_id = user_initiator.id
        self.next_move_user_id = self.initiator_id
        self.winner_id = 0
        self.users.append(user_initiator)
        for i in range(0, 6):
            round_tmp = Round()
            self.rounds.append(round_tmp)
        self.rounds[0].state = 3 # answering

    def __repr__(self):
        return "Match(id=%d, state=%d, initiator=%r, creation time=%s)" % (self.id, self.state, self.initiator, self.creation_time)

    def columnitems(self):
        clmnItemsDict = super(Match, self).columnitems()
        # rounds
        listRounds = list()
        for round in self.rounds:
            listRounds.append(round.id)
        roundsDict = {'ROUNDS_IDS': listRounds}
        # users
        users_list = list()
        for u in self.users:
            users_list.append(u.id)
        users_dict = {"USERS_IDS": users_list}
        # common
        clmnItemsDict = dict(clmnItemsDict.items() + users_dict.items())
        clmnItemsDict = dict(clmnItemsDict.items() + roundsDict.items())

        return clmnItemsDict
