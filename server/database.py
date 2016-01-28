#! /usr/bin/env python
# -*- coding: utf-8 -*-

MATCHES_MAX_COUNT = 2


from sqlalchemy import Table, Column, Integer, String, Unicode, Binary, Float, Boolean, BINARY, DateTime
from sqlalchemy import ForeignKey
from sqlalchemy import update, delete
from sqlalchemy import create_engine
from sqlalchemy.orm import sessionmaker
from sqlalchemy import inspect
from sqlalchemy.orm import relationship
from sqlalchemy.orm import backref
import sqlalchemy_imageattach.stores.fs
from sqlalchemy_imageattach.entity import Image, image_attachment, ImageSet
from sqlalchemy_imageattach.context import store_context
from sqlalchemy.orm.exc import NoResultFound

from sqlalchemy import MetaData, exc
import logging
import sqlalchemy
import re

import datetime
import random
import json
import random
import os
from string import uppercase

# __project_folder__ = '/home/zykis/DAServer/src/' # ubuntu server
__project_folder__ = '/Users/artem/projects/DotaAsker/server/' # local machine
__questions_folder__ = os.path.join(__project_folder__, 'questions')

fs_store = sqlalchemy_imageattach.stores.fs.FileSystemStore(
            path=u'./question_images',
            base_url=u'http://localhost/'
)

_new_sa_ddl = sqlalchemy.__version__.startswith('0.7')
myDBEngine = create_engine('sqlite:///./mydb.db', echo=False)
# myDBEngine = create_engine("mysql://dotaAsker:stranger@localhost/dotaAsker"
                            # encoding='utf-8', echo=True)
Session = sessionmaker(bind=myDBEngine)
session = Session()



class User(Base):
    __tablename__ = 'users'
    id = Column(Integer, primary_key=True)
    username = Column(Unicode(50), unique=True, nullable=False)
    password = Column(String(50), nullable=False)
    email = Column(String(50), unique=False, nullable=True)
    rating = Column(Integer, nullable=False, default=4000)
    kda = Column(Float, nullable=True, default=1.0)
    gpm = Column(Integer, nullable=True, default=300)
    wallpapers_image_name = Column(String(50), nullable=False, default='wallpaper_default.jpg')
    avatar_image_name = Column(String(50), nullable=False, default='avatar_default.png')
    total_correct_answers = Column(Integer, nullable=True, default=0)
    total_incorrect_answers = Column(Integer, nullable=True, default=0)
    # relations
    matches = relationship('Match', secondary='users_matches')
    # friends = relationship('User', secondary='friends')
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
            session.commit()
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
            session.rollback()
            return clitemsDict

    def __repr__(self):
        return "User(id=%d, username=%s, rating=%d)" % (self.id, self.username, self.rating)

friends_table = Table('friends', Base.metadata,
                            Column('user_1_id', Integer, ForeignKey('users.id', ondelete='CASCADE')),
                            Column('user_2_id', Integer, ForeignKey('users.id', ondelete='CASCADE'))
                            )

friends_requests_table = Table('friends_requests', Base.metadata,
                            Column('user_from_id', Integer, ForeignKey('users.id', ondelete='CASCADE')),
                            Column('user_to_id', Integer, ForeignKey('users.id', ondelete='CASCADE'))
                            )

class Match(Base):
    __tablename__ = 'matches'
    id = Column(Integer, primary_key=True)
    # (0 - not started, 1 - match running, 2 - match finished, 3 - time elapsed)
    state = Column(Integer, nullable=True, default=0)
    initiator_id = Column(Integer, ForeignKey('users.id'), nullable=False)
    next_move_user_id = Column(Integer, ForeignKey('users.id'), nullable=True)
    winner_id = Column(Integer, ForeignKey('users.id'), default=0)
    # relations
    users = relationship('User', secondary='users_matches')
    rounds = relationship('Round')
    initiator = relationship('User', foreign_keys=[next_move_user_id])
    next_move_user = relationship('User', foreign_keys=[next_move_user_id])
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


users_matches_table = Table('users_matches', Base.metadata,
                            Column('user_id', Integer, ForeignKey('users.id')),
                            Column('match_id', Integer, ForeignKey('matches.id'))
                            )


class Round(Base):
    __tablename__ = 'rounds'
    id = Column(Integer, primary_key=True)
    # SERVER (0-NOT_STARTED, 1-FINISHED, 2-TIME_ELAPSED, 3-ASWERING, 4-REPLYING)
    # CLIENT (0-NOT_STARTED, 1-FINISHED, 2-TIME_ELAPSED, 3-PLAYER_ASWERING, 4-OPPONENT_ANSWERING, 5-PLAYER_REPLYING, 6-OPPONENT_REPLYING)
    state = Column(Integer, nullable=False, default=0)
    match_id = Column(Integer, ForeignKey('matches.id'))
    theme_id = Column(Integer, ForeignKey('themes.id'), nullable=True)
    # relations
    match = relationship('Match')
    theme = relationship('Theme')

    questions = relationship('Question', secondary='round_questions')
    user_answers = relationship('Useranswer', cascade='all, delete-orphan')

    def __init__(self):
        self.state = 0
        self.theme_id = random.randrange(1, 3)

    def columnitems(self):
        # parent
        clmnItemsDict = super(Round, self).columnitems()
        # next move user id
        next_move_user_dict = {"NEXT_MOVE_USER_ID": self.match.next_move_user.id}

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


class Theme(Base):
    __tablename__ = 'themes'
    id = Column(Integer, primary_key=True)
    name = Column(String(50), nullable=False)
    image_name = Column(String(50), nullable=True)


class Question(Base):
    __tablename__ = 'questions'
    id = Column(Integer, primary_key=True)
    theme_id = Column(Integer, ForeignKey('themes.id'))
    image_name = Column(String(50), nullable=True)
    text = Column(String(50), nullable=False)
    approved = Column(Boolean, default=1)
    # relations
    theme = relationship('Theme', foreign_keys=[theme_id])
    image = image_attachment('QuestionPicture')
    answers = relationship('Answer', cascade='all, delete-orphan')

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

    def get_thumbnail(self, width=None, height=None):
        # image
        thumbnail = self.find_or_create_thumbnail(width=width, height=height)
        session.commit()
        blob = thumbnail.make_blob(store=fs_store)
        print('sizeof %s = ' % self.id + str(blob.__sizeof__()))
        return blob

    def find_or_create_thumbnail(self, width=None, height=None):
        assert width is not None or height is not None
        try:
            image = self.image.find_thumbnail(width=width, height=height)
        except NoResultFound:
            image = self.image.generate_thumbnail(width=width, height=height, store=fs_store)
        return image


class QuestionPicture(Base, Image):
    __tablename__ = 'question_picture'
    question_id = Column(Integer, ForeignKey('questions.id'), primary_key=True)
    question = relationship('Question')

class Answer(Base):
    __tablename__ = 'answers'
    id = Column(Integer, primary_key=True)
    question_id = Column(Integer, ForeignKey('questions.id'))
    text = Column(String(50))
    is_correct = Column(Boolean)
    # relations
    question = relationship('Question', foreign_keys=[question_id])


class Useranswer(Base):
    __tablename__ = 'user_answers'
    id = Column(Integer, primary_key=True)
    answer_id = Column(Integer, ForeignKey('answers.id'))
    # relations
    round_id = Column(Integer, ForeignKey('rounds.id'))
    round = relationship('Round', foreign_keys=[round_id])

    user_id = Column(Integer, ForeignKey('users.id'))
    user = relationship('User', foreign_keys=[user_id])

    question_id = Column(Integer, ForeignKey('questions.id'))
    question = relationship('Question', foreign_keys=[question_id])

# asossiated table in many-to-many relashionships (Round <--> Question)
round_questions_table = Table('round_questions', Base.metadata,
                              Column('round_id', Integer, ForeignKey('rounds.id')),
                              Column('question_id', Integer, ForeignKey('questions.id'))
                              )

class Database:
    def __init__(self):
        self.create_and_upgrade(engine=myDBEngine, metadata=Base.metadata)
        # Base.metadata.drop_all(myDBEngine)
        # Base.metadata.create_all(myDBEngine)
        # self.initTestData()
    def get(self, className, id):
        if id is None:
            entity = session.query(className)
        else:
            entity = session.query(className).filter(className.id == id)
        if entity.count() == 0:
            return None
        else:
            if id is None:
                return entity.all()
            else:
                return entity.one()

    def update(self, entity):
        if entity is None:
            return None
        else:
            update(entity)
            entity = session.query(entity).filter(entity.id)
            return entity

    def delete(self, className, id):
        if id is None:
            entity = session.query(className)
        else:
            entity = session.query(className).filter(className.id == id)
        if entity.count() == 0:
            return None
        else:
            if id is None:
                return entity.all()
            else:
                return entity.one()

    def create_and_upgrade(self, engine, metadata):
        db_metadata = MetaData()
        db_metadata.bind = engine

        for model_table in metadata.sorted_tables:
            try:
                db_table = Table(model_table.name, db_metadata, autoload=True)
            except exc.NoSuchTableError:
                logging.info('Creating table %s' % model_table.name)
                model_table.create(bind=engine)
            else:
                ddl_c = engine.dialect.ddl_compiler(engine.dialect, None)
                logging.debug('Table %s already exists. Checking for missing columns' % model_table.name)

                model_columns = set()
                for c in model_table.columns:
                    model_columns.add(c.name)

                db_columns = set()
                for c in db_table.columns:
                    db_columns.add(c.name)

                to_create = model_columns - db_columns
                to_remove = db_columns - model_columns
                to_check = db_columns.intersection(model_columns)

                for c in to_create:
                    model_column = getattr(model_table.c, c)
                    logging.info('Adding column %s.%s' % (model_table.name, model_column.name))
                    assert not model_column.constraints, \
                        'Arrrgh! I cannot automatically add columns with constraints to the database'\
                            'Please consider fixing me if you care!'
                    model_col_spec = ddl_c.get_column_specification(model_column)
                    sql = 'ALTER TABLE %s ADD %s' % (model_table.name, model_col_spec)
                    engine.execute(sql)

                # It's difficult to reliably determine if the model has changed
                # a column definition. E.g. the default precision of columns
                # is None, which means the database decides. Therefore when I look at the model
                # it may give the SQL for the column as INTEGER but when I look at the database
                # I have a definite precision, therefore the returned type is INTEGER(11)

                for c in to_check:
                    model_column = model_table.c[c]
                    db_column = db_table.c[c]
                    x =  model_column == db_column

                    logging.debug('Checking column %s.%s' % (model_table.name, model_column.name))
                    model_col_spec = ddl_c.get_column_specification(model_column)
                    db_col_spec = ddl_c.get_column_specification(db_column)

                    model_col_spec = re.sub('[(][\d ,]+[)]', '', model_col_spec)
                    db_col_spec = re.sub('[(][\d ,]+[)]', '', db_col_spec)
                    db_col_spec = db_col_spec.replace('DECIMAL', 'NUMERIC')
                    db_col_spec = db_col_spec.replace('TINYINT', 'BOOL')

                    if model_col_spec != db_col_spec:
                        logging.warning('Column %s.%s has specification %r in the model but %r in the database' %
                                           (model_table.name, model_column.name, model_col_spec, db_col_spec))

                    if model_column.constraints or db_column.constraints:
                        # TODO, check constraints
                        logging.debug('Column constraints not checked. I am too dumb')

                for c in to_remove:
                    model_column = getattr(db_table.c, c)
                    logging.warning('Column %s.%s in the database is not in the model' % (model_table.name, model_column.name))


    def notStartedMatchesCountWithUniqueInitiator(self, finderUser):
        count = len(session.query(Match).filter(Match.state == 0, Match.initiator != finderUser).distinct(Match.initiator).all())
        print('notStartedMatchesCountWithUniqueInitiator = ' + str(count))
        return count

    def findMatchForUser(self, user):
        # finding not started matches
        users_in_matches_list = list()
        not_started_matches = session.query(Match).filter(Match.state == 0, Match.initiator != user).all()
        # get users in this matches
        print("not started matches: " + str(not_started_matches))
        for m in not_started_matches:
            if not users_in_matches_list.__contains__(m.initiator):
                users_in_matches_list.append(m.initiator)

        # sort by rating
        users_in_matches_list.sort(key=lambda user: user.rating)
        if len(users_in_matches_list) == 0:
            print("No users found for match")
            return

        print('count = ' + str(len(users_in_matches_list)))
        for u in users_in_matches_list:
            print(u)

        # find user with minimal difference between user.rating and u.rating
        proper_user = users_in_matches_list[0]
        min_diff = abs(user.rating - users_in_matches_list[0].rating)
        for u in users_in_matches_list:
            if abs(u.rating - user.rating) < min_diff:
                proper_user = u
        print("proper user: %s" % proper_user)

        # get not started matches of proper_user and sort them by creation time
        proper_matches = session.query(Match).filter(Match.initiator == proper_user, Match.state == 0).all()
        proper_matches.sort(key=lambda match: match.creation_time)
        for m in proper_matches:
            print("%r" % (m))

        # add self to this match
        proper_matches[0].users.append(user)
        # starting match
        proper_matches[0].state = 1

        # return the oldest match
        return proper_matches[0]

    def createNewMatchWithUser(self, user):
        m = Match(user)
        session.add(m)
        session.commit()
        return m

    def getUserByName(self, username):
        users = session.query(User).filter(User.username == username)
        if users.count() == 0:
            return None
        else:
            return users.one()

    def addUser(self, new_user):
        session.add(new_user)
        session.commit()
        insp = inspect(new_user)
        if insp.persistent or insp.detached:
            return True
        else:
            return False

    def addUserAnswer(self, userAnswer):
        session.add(userAnswer)
        session.commit()

    def questionsIDsToRemove(self, client_questions_IDs):
        quesitons_IDs_to_remove = list()
        for qID in client_questions_IDs:
            subq = session.query(Question).filter(Question.id == qID).filter(Question.approved == True)
            if not session.query(subq.exists()).scalar():
                quesitons_IDs_to_remove.append(qID)
        return quesitons_IDs_to_remove

    def questionsToAdd(self, client_questions_IDs):
        questions_to_add = list()
        db_questions = session.query(Question).filter(Question.approved == True).all()
        for q in db_questions:
            need_to_add = True
            for client_Q_ID in client_questions_IDs:
                if q.id == client_Q_ID:
                    need_to_add = False
            if need_to_add == True:
                questions_to_add.append(q)
        return questions_to_add

    def uploadQuestionFromPath(self, questionsPath):
        with open(questionsPath + u'/questions.txt') as questionsLoreFile:
            print(u'\nQuestions:')
            questions_list = json.loads(questionsLoreFile.read())
            for q in questions_list:
                print('question: ' + q['question'])
                print('theme: ' + q['theme'])
                print('answers:')
                i = 1
                for ans in q['answers']:
                    print('-' + ans)
                    if i == q['correct_answer_index']:
                        print(' ^ is CORRECT')
                    i += 1
                print('image path: ' + questionsPath + '/' + q['image'] + '\n')

                theme = session.query(Theme).filter(Theme.name == q['theme']).one()
                q_answers = q['answers']
                question_obj = Question(text=q['question'],
                                        theme=theme,
                                        )
                i = 1;
                for ans in q['answers']:
                    answ = Answer(question_id=question_obj.id, text=ans)
                    if i == q['correct_answer_index']:
                        answ.is_correct = True
                    else:
                        answ.is_correct = False
                    i += 1
                    session.add(answ)
                    question_obj.answers.append(answ)

                with store_context(fs_store):
                    with open(questionsPath + '/question_images/' + q['image']) as imageFile:
                        question_obj.image.from_file(imageFile, fs_store)

                session.add(question_obj)
        session.commit()

    def initTestData(self):
        ############################################## setup connection
        # database = Database()

        # ############################################# making themes
        lore_theme = Theme(name=u'lore',
                           image_name=u'theme_lore.png')
        tournaments_theme = Theme(name=u'tournaments',
                                  image_name=u'theme_tournaments.png')
        mechanics_theme = Theme(name=u'mechanics',
                                image_name=u'theme_mechanics.png')
        # add to session
        session.add(lore_theme)
        session.add(tournaments_theme)
        session.add(mechanics_theme)
        session.commit()

        ############################################# create Users
        john_user = User(username=u'John', password=u'1', avatar_image_name='avatar_axe.png', wallpapers_image_name='wallpaper_antimage_1.jpg', rating=4125)
        peter_user = User(username=u'Peter', password=u'1', avatar_image_name='avatar_nature_prophet.png', wallpapers_image_name='wallpaper_bloodseeker_1.jpg', rating=3940)
        jack_user = User(username=u'Jack', password=u'1', avatar_image_name='avatar_tinker.png', wallpapers_image_name='wallpaper_bloodseeker_1.jpg', rating=3870)

        # add Users to session
        session.add(john_user)
        session.add(peter_user)
        session.add(jack_user)
        session.commit()

        # upload questions
        self.uploadQuestionFromPath(__questions_folder__)

        # create some questions
        lore_questions_list = session.query(Question).filter(Question.theme == lore_theme).all()
        tournaments_question_list = session.query(Question).filter(Question.theme == tournaments_theme).all()
        mechanics_question_list = session.query(Question).filter(Question.theme == mechanics_theme).all()

        ############################################## create Match
        first_match = Match(john_user)
        second_match = Match(peter_user)

        # add users to match
        first_match.users.append(peter_user)
        second_match.users.append(john_user)

        # add questions to match's rounds
        for r in first_match.rounds:
            rand = random.randrange(1,3)
            if rand == 1:
                r.questions = lore_questions_list
                r.theme = lore_theme
            elif rand == 2:
                r.questions = mechanics_question_list
                r.theme = mechanics_theme
            elif rand == 3:
                r.questions = lore_questions_list
                r.theme = lore_theme

            for quest in r.questions:
                    user_answer = Useranswer()
                    user_answer.round = r
                    user_answer.user = first_match.users[0]
                    user_answer.question = quest
                    user_answer.answer_id = random.randrange(quest.answers[0].id, quest.answers[len(quest.answers) - 1].id)
                    session.add(user_answer)

                    user2_answer = Useranswer()
                    user2_answer.round = r
                    user2_answer.user = first_match.users[1]
                    user2_answer.question = quest
                    user2_answer.answer_id = random.randrange(quest.answers[0].id, quest.answers[len(quest.answers) - 1].id)
                    session.add(user2_answer)
            r.state = 1

        for r in second_match.rounds:
            rand = random.randrange(1, 3)
            if rand == 1:
                r.questions = lore_questions_list
                r.theme = lore_theme
            elif rand == 2:
                r.questions = mechanics_question_list
                r.theme = mechanics_theme
            elif rand == 3:
                r.questions = lore_questions_list
                r.theme = lore_theme

            for quest in r.questions:
                        user_answer = Useranswer()
                        user_answer.round = r
                        user_answer.user = second_match.users[0]
                        user_answer.question = quest
                        user_answer.answer_id = random.randrange(quest.answers[0].id, quest.answers[len(quest.answers) - 1].id)
                        session.add(user_answer)

                        user2_answer = Useranswer()
                        user2_answer.round = r
                        user2_answer.user = second_match.users[1]
                        user2_answer.question = quest
                        user2_answer.answer_id = random.randrange(quest.answers[0].id, quest.answers[len(quest.answers) - 1].id)
                        session.add(user2_answer)
            r.state = 1
        session.commit()

        first_match.state = 1
        second_match.state = 1

        third_match = Match(peter_user)
        fourth_match = Match(peter_user)
        fifth_match = Match(jack_user)

        # add match to session
        session.add(first_match)
        session.add(second_match)
        session.add(third_match)
        session.add(fourth_match)
        session.add(fifth_match)
        session.commit()
