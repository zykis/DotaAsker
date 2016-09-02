from app import db
from config import ROUNDS_IN_MATCH
import datetime
from passlib.apps import custom_app_context as pwd_context

ROLE_USER = 0
ROLE_ADMIN = 1

ROUND_NOT_STARTED = 0
ROUND_FINISHED = 1
ROUND_TIME_ELAPSED = 2
ROUND_ANSWERING = 3
ROUND_REPLYING = 4

MATCH_NOT_STARTED = 0
MATCH_RUNNING = 1
MATCH_FINISHED = 2
MATCH_TIME_ELAPSED = 3

class Base(db.Model):
    __abstract__ = True
    created_on = db.Column(db.DateTime, default=db.func.now())
    updated_on = db.Column(db.DateTime, default=db.func.now(), onupdate=db.func.now())
    def columns(self):
        return [c.name for c in self.__table__.columns]

    def columnitems(self):
        columnsDict = dict()
        for c in self.columns():
            inst = getattr(self, c)
            if isinstance(inst, datetime.datetime):
                columnsDict = dict (dict([(c.upper(), inst.strftime('%Y-%m-%d %H:%M:%S.%f'))]), **columnsDict)
            else:
                columnsDict = dict (dict([(c.upper(), getattr(self, c))]), **columnsDict)
        return columnsDict

    def tojson(self):
        return self.columnitems()

class Answer(Base):
    __tablename__ = 'answers'
    id = db.Column(db.Integer, primary_key=True)
    question_id = db.Column(db.Integer, db.ForeignKey('questions.id'))
    text = db.Column(db.String(50))
    is_correct = db.Column(db.Boolean)
    # relations
    question = db.relationship('Question', foreign_keys=[question_id])

class Question(Base):
    __tablename__ = 'questions'
    id = db.Column(db.Integer, primary_key=True)
    theme_id = db.Column(db.Integer, db.ForeignKey('themes.id'))
    image_name = db.Column(db.String(50), nullable=True)
    text = db.Column(db.String(50), nullable=False)
    approved = db.Column(db.Boolean, default=True)
    # relations
    theme = db.relationship('Theme', foreign_keys=[theme_id])
    answers = db.relationship('Answer', cascade='all, delete-orphan')

    def addAnswer(self, answerText):
        answer = Answer()
        answer.question_id = self.id
        answer.text = answerText

    def setCorrectAnswer(self, correctAnswerText):
        for ans in self.answers:
            for txt in ans.text:
                if (txt == correctAnswerText):
                    self.correct_answer_id = ans.id
                    return
        answer = Answer()
        answer.question_id = self.id
        answer.text = correctAnswerText
        self.correct_answer_id = answer.id

    def columnitems(self):
        clmnItemsDict = super(Question, self).columnitems()
        # answers
        if len(self.answers) != 0:
            answer_list = list()
            for ans in self.answers:
                answer_list.append(ans.id)
            answers_dict = {"ANSWERS_IDS": answer_list}
            clmnItemsDict = dict(clmnItemsDict, **answers_dict)
        return clmnItemsDict

class Useranswer(Base):
    __tablename__ = 'user_answers'
    id = db.Column(db.Integer, primary_key=True)

    # relations
    answer_id = db.Column(db.Integer, db.ForeignKey('answers.id', ondelete='CASCADE', onupdate='CASCADE'))
    answer = db.relationship('Answer', foreign_keys=[answer_id])

    round_id = db.Column(db.Integer, db.ForeignKey('rounds.id', ondelete='CASCADE', onupdate='CASCADE'))
    round = db.relationship('Round', foreign_keys=[round_id])

    user_id = db.Column(db.Integer, db.ForeignKey('users.id', ondelete='CASCADE', onupdate='CASCADE'))
    user = db.relationship('User', foreign_keys=[user_id])

    question_id = db.Column(db.Integer, db.ForeignKey('questions.id', ondelete='CASCADE', onupdate='CASCADE'))
    question = db.relationship('Question', foreign_keys=[question_id])

class Friends(Base):
    __tablename__ = 'friends_t'
    from_id = db.Column(db.Integer, db.ForeignKey('users.id', ondelete='CASCADE', onupdate='CASCADE'), primary_key=True)
    to_id = db.Column(db.Integer, db.ForeignKey('users.id', ondelete='CASCADE', onupdate='CASCADE'), primary_key=True)
    confirmed = db.Column(db.Boolean, default=False)

    from_user = db.relationship('User', backref=db.backref('out_requests', lazy='dynamic'), primaryjoin='User.id == Friends.from_id')
    to_user = db.relationship('User', backref=db.backref('in_requests', lazy='dynamic'), primaryjoin='User.id == Friends.to_id')

class User(Base):
    __tablename__ = 'users'
    id = db.Column(db.Integer, primary_key=True)
    username = db.Column(db.Unicode(50), unique=True, nullable=False)
    password_hash = db.Column(db.String(128))
    email = db.Column(db.String(50), unique=False, nullable=True)
    mmr = db.Column(db.Integer, nullable=False, default=4000)
    kda = db.Column(db.Float, nullable=True, default=1.0)
    gpm = db.Column(db.Integer, nullable=True, default=300)
    wallpapers_image_name = db.Column(db.String(50), nullable=False, default='wallpaper_default.jpg')
    avatar_image_name = db.Column(db.String(50), nullable=False, default='avatar_default.png')
    total_correct_answers = db.Column(db.Integer, nullable=True, default=0)
    total_incorrect_answers = db.Column(db.Integer, nullable=True, default=0)
    role = db.Column(db.SmallInteger, default=ROLE_USER)
    # relations
    matches = db.relationship('Match', secondary='users_matches')

    def hash_password(self, password):
        self.password_hash = pwd_context.encrypt(password)

    def verify_password(self, password):
        return pwd_context.verify(password, self.password_hash)

    def sendRequest(self, aUser):
        f = Friends(confirmed=False, from_id=self.id, to_id=aUser.id)
        db.session.add(f)

    def isPending(self, aUser):
        return self.out_requests.filter(Friends.to_id==aUser.id, Friends.confirmed==False).count() > 0

    def isFriend(self, aUser):
        b1 = self.out_requests.filter(Friends.to_id==aUser.id, Friends.confirmed==True).count() > 0
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
                Friends.query.filter(Friends.to_id==f.to_id, Friends.from_id==f.from_id).delete(synchronize_session=False)
            elif self.in_requests.filter(Friends.from_id==aUser.id, Friends.confirmed==True).count() > 0:
                f = self.in_requests.filter(Friends.from_id==aUser.id, Friends.confirmed==True).one()
                Friends.query.filter(Friends.to_id==f.to_id, Friends.from_id==f.from_id).delete(synchronize_session=False)
            else:
                print self.username + ' has no friend with username = ' + aUser.username

    def friends(self):
        friend_list = list()
        for friend in self.out_requests.filter(Friends.confirmed==True).all():
            friend_list.append(friend)
        for friend in self.in_requests.filter(Friends.confirmed==True).all():
            friend_list.append(friend)
        return friend_list

    def columnitems(self):
            clitemsDict = super(User, self).columnitems()
            listOfCurrentMatches = []
            listOfRecentMatches = []
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
            return clitemsDict

    def __repr__(self):
        return "User(id=%d, username=%s, rating=%d)" % (self.id, self.username, self.mmr)

    def __iter__(self):
        return self

    def __eq__(self, other):
        return self.id == other.id

    def is_authenticated(self):
        return True

    def is_active(self):
        return True

    def is_anonimous(self):
        return False

    def get_id(self):
        str = unicode(self.id)
        return str

class Theme(Base):
    __tablename__ = 'themes'
    id = db.Column(db.Integer, primary_key=True)
    name = db.Column(db.String(50), nullable=False)
    image_name = db.Column(db.String(50), nullable=True)


class Round(Base):
    __tablename__ = 'rounds'
    id = db.Column(db.Integer, primary_key=True)
    state = db.Column(db.Integer, default=ROUND_NOT_STARTED)
    match_id = db.Column(db.Integer, db.ForeignKey('matches.id'))
    theme_id = db.Column(db.Integer, db.ForeignKey('themes.id'), nullable=True)
    # relations
    match = db.relationship('Match', backref='rounds')
    theme = db.relationship('Theme')

    questions = db.relationship('Question', secondary='round_questions')
    user_answers = db.relationship('Useranswer', cascade='all, delete-orphan')

    def columnitems(self):
        # parent
        clmnItemsDict = super(Round, self).columnitems()
        # next move user id
        next_move_user_dict = {"NEXT_MOVE_USER_ID": self.match.next_move_user_id}

        # questions
        questions_list = list()
        for q in self.questions:
            questions_list.append(q.id)
        questions_dict = {'QUESTIONS_IDS': questions_list}
        # answers
        answers_list = list()
        for a in self.user_answers:
            answers_list.append(a.id)
        answers_dict = {"ANSWERS_IDS": answers_list}
        # common
        clmnItemsDict = dict(clmnItemsDict, **next_move_user_dict)
        clmnItemsDict = dict(clmnItemsDict, **questions_dict)
        clmnItemsDict = dict(clmnItemsDict, **answers_dict)
        return clmnItemsDict

class Match(Base):
    __tablename__ = 'matches'
    id = db.Column(db.Integer, primary_key=True)
    state = db.Column(db.Integer, nullable=True, default=MATCH_NOT_STARTED)
    winner_id = db.Column(db.Integer, db.ForeignKey('users.id'), nullable=True, default=0)
    next_move_user_id = db.Column(db.Integer, default=0)
    # relations
    users = db.relationship('User', secondary='users_matches')
    winner = db.relationship('User', foreign_keys=[winner_id])

    def __init__(self, initiator):
        # need to find out, if user exists already
        self.next_move_user_id = initiator.id
        initiator.matches.append(self)
        # self.users.append(initiator)
        for i in range(0, ROUNDS_IN_MATCH):
            round_tmp = Round()
            self.rounds.append(round_tmp)
        self.rounds[0].state = 3 # answering

    def __repr__(self):
        return "Match(id=%d, state=%d, next_move_user_id=%r, creation time=%s)" % (self.id, self.state, self.next_move_user_id, self.created_on)

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

    def finish(self, winner):
        pass

users_matches_table = db.Table('users_matches', db.Model.metadata,
                            db.Column('user_id', db.Integer, db.ForeignKey('users.id', ondelete='CASCADE', onupdate='CASCADE')),
                            db.Column('match_id', db.Integer, db.ForeignKey('matches.id', ondelete='CASCADE', onupdate='cascade'))
                            )

round_questions_table = db.Table('round_questions', db.Model.metadata,
                              db.Column('round_id', db.Integer, db.ForeignKey('rounds.id', ondelete='CASCADE', onupdate='CASCADE')),
                              db.Column('question_id', db.Integer, db.ForeignKey('questions.id', ondelete='CASCADE', onupdate='CASCADE'))
                              )