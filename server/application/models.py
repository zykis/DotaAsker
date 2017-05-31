from application import db, app
from sqlalchemy.sql import func
from passlib.apps import custom_app_context as pwd_context
from itsdangerous import (JSONWebSignatureSerializer
                          as Serializer, BadSignature, SignatureExpired)
import random
import math
from config import MMR_GAIN_MIN, MMR_GAIN_MAX, MMR_GAIN_STEP, MMR_CEIL, MMR_BOTTOM, MMR_MAX_DIFF_GAIN


ROLE_USER = 0
ROLE_ADMIN = 1

QUESTIONS_IN_ROUND = 3
ROUNDS_IN_MATCH = 6
THEMES_COUNT = 3

MATCH_RUNNING = 0
MATCH_FINISHED = 1

MATCH_FINISH_REASON_NONE = 0
MATCH_FINISH_REASON_NORMAL = 1
MATCH_FINISH_REASON_TIME_ELAPSED = 2
MATCH_FINISH_REASON_SURREND = 3

def mmrGain(winnerMMR = None, loserMMR = None):
    if (winnerMMR is None) or (loserMMR is None):
        app.logger.critical("trying to calculate mmr difference without winner or loser")
        return 0

    mmr_diff = winnerMMR - loserMMR
    k = min(mmr_diff / (float)(MMR_MAX_DIFF_GAIN),  1.0) # [ 0..1]
    k = max(mmr_diff / (float)(MMR_MAX_DIFF_GAIN), -1.0) # [-1..1]
    
    # 25 + 25 * [-1..1]
    mmr_gain = (MMR_GAIN_MAX / 2) - (MMR_GAIN_MAX / 2) * k
    d = mmr_gain % 5
    if d < (float)(MMR_GAIN_STEP / 2.0):
        mmr_gain -= d
    else:
        mmr_gain += d
    mmr_gain = round(mmr_gain)
    mmr_gain = int(mmr_gain)
        
    mmr_gain = max(mmr_gain, MMR_GAIN_MIN)
    mmr_gain = min(mmr_gain, MMR_GAIN_MAX)
    
    return mmr_gain

class Base(db.Model):
    __abstract__ = True
    created_on = db.Column(db.DateTime, default=func.now())
    updated_on = db.Column(db.DateTime, default=func.now(), onupdate=func.now())


class Answer(Base):
    __tablename__ = 'answers'
    id = db.Column(db.Integer, primary_key=True)
    question_id = db.Column(db.Integer, db.ForeignKey('questions.id'))
    text_en = db.Column(db.Unicode(50))
    text_ru = db.Column(db.Unicode(50))
    is_correct = db.Column(db.Boolean)
    # relations
    question = db.relationship('Question', foreign_keys=[question_id])


class Question(Base):
    __tablename__ = 'questions'
    id = db.Column(db.Integer, primary_key=True)
    theme_id = db.Column(db.Integer, db.ForeignKey('themes.id'))
    image_name = db.Column(db.String(50), nullable=True)
    text_en = db.Column(db.Unicode(50))
    text_ru = db.Column(db.Unicode(50))
    approved = db.Column(db.Boolean, default=True)
    # relations
    theme = db.relationship('Theme', foreign_keys=[theme_id])
    answers = db.relationship('Answer', cascade='all, delete-orphan')


class UserAnswer(Base):
    __tablename__ = 'user_answers'
    id = db.Column(db.Integer, primary_key=True)
    sec_for_answer = db.Column(db.Integer, default=30)

    # relations
    # answer_id might be 0. The reason is, if the posted UserAnswer is timed out or we just have to
    # reserve UserAnswers, so the tricky persons couldn't see the question, then quit application
    # find an answer and put in a correct one.
    # if you've lost connection, during round... Well, you suck, man. Sorry.

    question_id = db.Column(db.Integer, db.ForeignKey('questions.id'))
    question = db.relationship('Question', foreign_keys=[question_id])

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
    premium = db.Column(db.Boolean, default=False)
    email = db.Column(db.String(50), unique=False, nullable=True)
    mmr = db.Column(db.Integer, nullable=False, default=4000)
    kda = db.Column(db.Float, nullable=True, default=1.0)
    gpm = db.Column(db.Integer, nullable=True, default=300)
    wallpapers_image_name = db.Column(db.String(50), nullable=False, default='wallpaper_default.jpg')
    avatar_image_name = db.Column(db.String(50), nullable=False, default='avatar_default.png')
    total_correct_answers = db.Column(db.Integer, nullable=True, default=0)
    total_incorrect_answers = db.Column(db.Integer, nullable=True, default=0)
    total_matches_won = db.Column(db.Integer, default=0)
    total_matches_lost = db.Column(db.Integer, default=0)
    total_time_for_answers = db.Column(db.Integer, default=0)
    role = db.Column(db.SmallInteger, default=ROLE_USER)
    # relations
    # TODO: divide matches onto: current_matches & recent_matches
    matches = db.relationship('Match', secondary='users_matches')

    def __init__(self, username = None, password = None, avatar_image_name = None, wallpapers_image_name = None, mmr = None):
        if username is not None:
            self.username = username
        if password is not None:
            self.hash_password(password)
        if avatar_image_name is not None:
            self.avatar_image_name = avatar_image_name
        if wallpapers_image_name is not None:
            self.wallpapers_image_name = wallpapers_image_name
        if mmr is not None:
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
        return "User(id=%d, username=%s, rating=%d)" % (self.id, self.username.encode('utf-8'), self.mmr)

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
            theme_questions = Question.query.filter(Question.theme == t, Question.approved == True).all()
            r_questions = []
            for x in range(0, 3):
                rand_q = random.choice(theme_questions)
                r_questions.append(rand_q)
                theme_questions.remove(rand_q)
            self.questions.extend(r_questions)
        assert(len(self.questions) == 9), "Generated question count == {}".format(len(self.questions))


class Match(Base):
    __tablename__ = 'matches'
    id = db.Column(db.Integer, primary_key=True)
    state = db.Column(db.Integer, default = MATCH_RUNNING)
    finish_reason = db.Column(db.Integer, default = MATCH_FINISH_REASON_NONE)
    mmr_gain = db.Column(db.Integer, default = 0)
    winner_id = db.Column(db.Integer, db.ForeignKey('users.id'), default = 0)
    hidden = db.Column(db.Boolean, default = 0) # if recent match hidden on client side by user
    # relations
    users = db.relationship('User', secondary='users_matches')
    winner = db.relationship('User', foreign_keys=[winner_id])

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
        winner = None
        for u in self.users:
            if u is not surrender:
                winner = u

        if winner is None:
            app.logger.info('user surrending to no one')

        
        loserMMR = loser.mmr
        if winner is None:
            winnerMMR = loserMMR
        else:
            winnerMMR = winner.mmr
            
        mmr_gain = mmrGain(winnerMMR = winnerMMR, loserMMR = loserMMR)
        self.mmr_gain = mmr_gain
        self.state = MATCH_FINISHED
        self.finish_reason = MATCH_FINISH_REASON_SURREND
        self.winner = winner
        
        # winner is None, if surrending just started match
        if winner is not None:
            winner.mmr += mmr_gain
            winner.total_matches_won += 1
            db.session.add(winner)
            
        surrender.mmr -= mmr_gain
        surrender.total_matches_lost += 1

        db.session.add(self)
        db.session.add(surrender)
        db.session.commit()

    def elapseMatch(self):
        if len(self.users) < 2:
            app.logger.debug("skip match {} with no opponent found yet".format(self.__repr__()))
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
            loser = self.next_move_user()
            for u in self.users:
                if u is not next_move_user:
                    winner = u

            if winner is None:
                app.logger.debug('no winner or loser for timeelapsed match')
                return
            elif loser is None:
                app.logger.critical('match elapsed, with finding no opponent for user {}'.format(winner.__repr__()))
                return

            # [1] MATCH STATE
            self.state = MATCH_FINISHED
            self.finish_reason = MATCH_FINISH_REASON_TIME_ELAPSED

            # [3] Calculate mmr gaining
            mmr_gain = mmrGain(winnerMMR = winner.mmr, loserMMR = loser.mmr)
            self.mmr_gain = mmr_gain

            # [4] decrease mmr of loser
            next_move_user.mmr -= mmr_gain

            # [5] increase mmr of winner
            winner.mmr += mmr_gain

            # [6] change total correct and incorrect answers
            for r in self.rounds:
                for ua in r.user_answers:
                    if ua.user == winner:
                        winner.total_time_for_answers += ua.sec_for_answer
                        if ua.answer.is_correct:
                            winner.total_correct_answers += 1
                        else:
                            winner.total_incorrect_answers += 1
                    elif ua.user == loser:
                        loser.total_time_for_answers += ua.sec_for_answer
                        if ua.answer.is_correct:
                            loser.total_correct_answers += 1
                        else:
                            loser.total_incorrect_answers += 1

            # [7] change total matches
            loser.total_matches_lost += 1
            winner.total_matches_won += 1

            # [7.1] gpm // - 30 GPM per second
            total_w = winner.total_correct_answers + winner.total_incorrect_answers
	    if total_w != 0:
                winner.gpm = ((winner.total_correct_answers + winner.total_incorrect_answers) * 1000 - float(winner.total_time_for_answers * 30)) / (winner.total_correct_answers + winner.total_incorrect_answers)

            total_l = loser.total_correct_answers + loser.total_incorrect_answers
            if total_l != 0:
                loser.gpm = ((loser.total_correct_answers + loser.total_incorrect_answers) * 1000 - float(loser.total_time_for_answers * 30)) / (loser.total_correct_answers + loser.total_incorrect_answers)

            # [8] calculating users KDA
            if winner.total_incorrect_answers != 0:
                winner.kda = winner.total_correct_answers / float(winner.total_incorrect_answers)
	    if loser.total_incorrect_answers != 0:
                loser.kda = loser.total_correct_answers / float(loser.total_incorrect_answers)

            # [9] updating it
            app.logger.debug('Updating users and match stats')
            self.winner = winner
            db.session.add(winner)
            db.session.add(loser)
            db.session.add(self)
            db.session.commit()
            app.logger.info('Stats updated successfully')
            
    

    def finish(self):
        # [1] match state become MATCH_FINISHED
        if (self.state != MATCH_RUNNING):
            app.logger.critical('Trying to finish not running match')
            return
        self.state = MATCH_FINISHED
        self.finish_reason = MATCH_FINISH_REASON_NORMAL

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
                if ua.user == user1:
                    user1.total_time_for_answers += ua.sec_for_answer
                elif ua.user == user2:
                    user2.total_time_for_answers += ua.sec_for_answer
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

	# [3.1] setup winner
	self.winner = winner

        # [4] calculate mmr gaining
        mmr_gain = mmrGain(winnerMMR = winner.mmr, loserMMR = loser.mmr)
        self.mmr_gain = mmr_gain

        # [5] decrease mmr of loser
        loser.mmr -= mmr_gain

        # [6] increase mmr of winner
        winner.mmr += mmr_gain

        # [7] changing total correct and incorrect answers for users
        user1.total_correct_answers += user1CorrectAnswers
        user1.total_incorrect_answers += 18 - user1CorrectAnswers
        user2.total_correct_answers += user2CorrectAnswers
        user2.total_incorrect_answers += 18 - user2CorrectAnswers

        # [7.1] total matches
        winner.total_matches_won += 1
        loser.total_matches_lost += 1

        # [7.2] gpm // - 30 GPM per second
        user1.gpm = ((user1.total_correct_answers + user1.total_incorrect_answers) * 1000 - float(user1.total_time_for_answers * 30)) / (user1.total_correct_answers + user1.total_incorrect_answers)
        user2.gpm = ((user2.total_correct_answers + user2.total_incorrect_answers) * 1000 - float(user2.total_time_for_answers * 30)) / (user2.total_correct_answers + user2.total_incorrect_answers)

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

user_date_mmr_table = db.Table('user_date_mmr', db.Model.metadata,
                               db.Column('user_id', db.Integer, db.ForeignKey('users.id', ondelete='CASCADE', onupdate='CASCADE'), primary_key=True),
                               db.Column('date', db.String, primary_key=True),
                               db.Column('mmr', db.Integer)
                               )
