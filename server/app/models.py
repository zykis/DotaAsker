from app import db, app
from passlib.apps import custom_app_context as pwd_context
from itsdangerous import (TimedJSONWebSignatureSerializer
                          as Serializer, BadSignature, SignatureExpired)
import random


ROLE_USER = 0
ROLE_ADMIN = 1

QUESTIONS_IN_ROUND = 3
ROUNDS_IN_MATCH = 6
THEMES_COUNT = 3

MATCH_RUNNING = 0
MATCH_FINISHED = 1
MATCH_TIME_ELAPSED = 2

class Base(db.Model):
    __abstract__ = True
    created_on = db.Column(db.DateTime, default=db.func.now())
    updated_on = db.Column(db.DateTime, default=db.func.now(), onupdate=db.func.now())


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


class UserAnswer(Base):
    __tablename__ = 'user_answers'
    id = db.Column(db.Integer, primary_key=True)

    # relations
    # answer_id might be 0. The reason is, if the posted UserAnswer is timed out or we just have to
    # reserve UserAnswers, so the tricky persons couldn't see the question, then quit application
    # find an answer and put in a correct one.
    # if you've lost connection, during round... Well, you suck, man. Sorry.
    answer_id = db.Column(db.Integer, db.ForeignKey('answers.id', ondelete='CASCADE', onupdate='CASCADE'))
    answer = db.relationship('Answer', foreign_keys=[answer_id])

    round_id = db.Column(db.Integer, db.ForeignKey('rounds.id', ondelete='CASCADE', onupdate='CASCADE'))
    round = db.relationship('Round', foreign_keys=[round_id])

    user_id = db.Column(db.Integer, db.ForeignKey('users.id', ondelete='CASCADE', onupdate='CASCADE'))
    user = db.relationship('User', foreign_keys=[user_id])


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
    # TODO: divide matches onto: current_matches & recent_matches
    matches = db.relationship('Match', secondary='users_matches')

    def __init__(self, username = None, password = None, avatar_image_name = 'default_avatar', wallpapers_image_name = 'default_wallpapers', mmr = 4000):
        if username is not None:
            self.username = username
        if password is not None:
            self.hash_password(password)
        self.avatar_image_name = avatar_image_name
        self.wallpapers_image_name = wallpapers_image_name
        self.mmr = mmr

    def hash_password(self, password):
        self.password_hash = pwd_context.encrypt(password)

    def verify_password(self, password):
        return pwd_context.verify(password, self.password_hash)

    def generate_auth_token(self):
        s = Serializer(app.config['SECRET_KEY'])
        return s.dumps({ 'id': self.id })

    @staticmethod
    def verify_auth_token(token):
        s = Serializer(app.config['SECRET_KEY'])
        try:
            data = s.loads(token)
        except SignatureExpired:
            return None # valid token, but expired
        except BadSignature:
            return None # invalid token
        user = User.query.get(data['id'])
        return user

    def sendRequest(self, aUser):
        if aUser.isPending(self):
            self.acceptRequest(aUser)
            db.session.add(self)
            db.session.add(aUser)
        else:
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
            friend_list.append(User.query.get(friend.to_id))
        for friend in self.in_requests.filter(Friends.confirmed==True).all():
            friend_list.append(User.query.get(friend.from_id))
        return friend_list

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

    match_id = db.Column(db.Integer, db.ForeignKey('matches.id'))
    next_move_user_id = db.Column(db.Integer, db.ForeignKey('users.id'), default=0)
    selected_theme_id = db.Column(db.Integer, db.ForeignKey('themes.id'), default=0)
    # relations
    match = db.relationship('Match', backref='rounds')
    questions = db.relationship('Question', secondary='round_questions')
    user_answers = db.relationship('UserAnswer', cascade='all, delete-orphan')
    next_move_user = db.relationship('User')
    selected_theme = db.relationship('Theme')

    def __init__(self):
        themes = Theme.query.all()
        for t in themes:
            theme_questions = Question.query.filter(Question.theme == t).all()
            r_questions = []
            for x in range(0, 3):
                rand_q = random.choice(theme_questions)
                r_questions.append(rand_q)
                theme_questions.remove(rand_q)
            self.questions.extend(r_questions)


class Match(Base):
    __tablename__ = 'matches'
    id = db.Column(db.Integer, primary_key=True)
    state = db.Column(db.Integer, default=0)
    # relations
    users = db.relationship('User', secondary='users_matches')

    def __init__(self, initiator):
        for i in range(0, ROUNDS_IN_MATCH):
            round_tmp = Round()
            self.rounds.append(round_tmp)
        self.setPlayer(initiator)

    def setPlayer(self, initiator):
        if not initiator in self.users:
            self.users.append(initiator)
        for i in range(0, ROUNDS_IN_MATCH):
            if i % 2 == 0:
                self.rounds[i].next_move_user = initiator

    def setOpponent(self, opponent):
        if not opponent in self.users:
            self.users.append(opponent)
        for r in self.rounds:
            if r.next_move_user is None:
                r.next_move_user = opponent

    def next_move_user(self):
        if self.state != MATCH_RUNNING:
            return self.rounds[5].next_move_user
        else:
            i = 0
            for r in self.rounds:
                if len(r.user_answers) == 6:
                    i += 1
                if i >= 6:
                    i -= 1
            return self.rounds[i].next_move_user

    def surrendMatch(self, surrender = None):
        if surrender is None:
            app.logger.critical('some1 trying to surrend')
            return
        self.state = MATCH_FINISHED
        winner = None
        for u in self.users:
            if u is not surrender:
                winner = u

        if winner is None:
            app.logger.critical("can't find winner for surrended match")
            return

        surrender.mmr -= 25
        winner.mmr += 25
        db.session.add(self)
        db.session.add(surrender)
        db.session.add(winner)
        db.session.commit()


    def elapseMatch(self):
        next_move_user = self.next_move_user()
        if self.state != MATCH_RUNNING:
            app.logger.critical('trying to elapse not running match: {}'.format(self.__repr__()))
            return
        elif next_move_user is None:
            app.logger.critical('inactive user for match: {} is undefined'.format(self.__repr__()))
            return
        else:
            # nextMoveUser LOST cause didn't answer or reply
            app.logger.debug('user {} losing match due to inactive'.format(next_move_user.__repr__()))
            winner = None
            for u in self.users:
                if u is not next_move_user:
                    winner = u

            if winner is None:
                app.logger.critical('no winner for timeelapsed match')
                return

            next_move_user.mmr -= 25
            winner += 25
            self.state = MATCH_TIME_ELAPSED
            db.session.add(self)
            db.session.add(next_move_user)
            db.session.add(winner)
            db.session.commit()

    def finish(self):
        # [1] match state become MATCH_FINISHED
        if (self.state != MATCH_RUNNING):
            app.logger.critical('Trying to finish not running match')
            return
        self.state = MATCH_FINISHED

        # [2] checking if all users post their asnwers
        userAnswersCount = 0
        for r in self.rounds:
            userAnswersCount += len(r.user_answers)
        if userAnswersCount < 6 * 6:
            app.logger.critical('Trying to finish match with only {} userAnswers'.format(userAnswersCount))
            return

        # [3] getting user with more correct answers
        if (len(self.users) < 2):
            app.logger('Trying to finish match with, that contains {} users'.format(len(self.users)))
            return
        user1 = self.users[0]
        user2 = self.users[1]
        user1CorrectAnswers = 0
        user2CorrectAnswers = 0
        for r in self.rounds:
            for ua in r.user_answers:
                if ua.user == user1 and (ua.answer is not None):
                    if  ua.answer.is_correct:
                        user1CorrectAnswers += 1
                elif ua.user == user2 and (ua.answer is not None):
                    if ua.answer.is_correct:
                        user2CorrectAnswers += 1
        if user1CorrectAnswers > user2CorrectAnswers:
            winner = user1
            loser = user2
        elif user2CorrectAnswers > user1CorrectAnswers:
            winner = user2
            loser = user1
        else:
            # draw
            app.logger.debug('draw in match: {}'.format(self.__repr__()))
            db.session.add(self)
            db.session.commit()
            return self

        # [4] calculate mmr gaining
        mmr_gain = 25

        # [5] decrease mmr of loser
        loser.mmr -= 25

        # [6] increase mmr of winner
        winner.mmr += 25

        # [7] changing total correct and incorrect answers for users
        user1.total_correct_answers += user1CorrectAnswers
        user1.total_incorrect_answers += 18 - user1CorrectAnswers
        user2.total_correct_answers += user2CorrectAnswers
        user2.total_incorrect_answers += 18 - user2CorrectAnswers

        # [8] calculating users KDA
        user1.kda = user1.total_correct_answers / float(user1.total_incorrect_answers)
        user2.kda = user2.total_correct_answers / float(user2.total_incorrect_answers)

        # [9] updating it
        app.logger.debug('Updating users and match stats')
        db.session.add(user1)
        db.session.add(user2)
        db.session.add(self)
        db.session.commit()
        app.logger.info('Stats updated successfully')

        return self
        # [10] GMP ?!? depends on how quick user answering
        pass

    def __repr__(self):
        return "Match(id=%d, creation time=%s, users=%s)" % (self.id, self.created_on, self.users)



users_matches_table = db.Table('users_matches', db.Model.metadata,
                            db.Column('user_id', db.Integer, db.ForeignKey('users.id', ondelete='CASCADE', onupdate='CASCADE')),
                            db.Column('match_id', db.Integer, db.ForeignKey('matches.id', ondelete='CASCADE', onupdate='cascade'))
                            )

round_questions_table = db.Table('round_questions', db.Model.metadata,
                              db.Column('round_id', db.Integer, db.ForeignKey('rounds.id', ondelete='CASCADE', onupdate='CASCADE')),
                              db.Column('question_id', db.Integer, db.ForeignKey('questions.id', ondelete='CASCADE', onupdate='CASCADE'))
                              )
