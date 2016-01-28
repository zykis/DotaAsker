#! /usr/bin/env python
# -*- coding: utf-8 -*-



MATCHES_MAX_COUNT = 2
from entities.entity import *
from entities.theme import Theme
from entities.user_answer import Useranswer
from entities.answer import Answer
from entities.question import *
from entities.round import Round
from entities.match import Match
from entities.user import User

from sqlalchemy import Table
from sqlalchemy import update, delete
from sqlalchemy import create_engine
from sqlalchemy.orm import sessionmaker
from sqlalchemy import inspect
from sqlalchemy import MetaData, exc

import logging
import sqlalchemy
import re
import json
import random

import sqlalchemy_imageattach.stores.fs
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

friends_table = Table('friends', Base.metadata,
                            Column('user_1_id', Integer, ForeignKey('users.id', ondelete='CASCADE')),
                            Column('user_2_id', Integer, ForeignKey('users.id', ondelete='CASCADE'))
                            )

friends_requests_table = Table('friends_requests', Base.metadata,
                            Column('user_from_id', Integer, ForeignKey('users.id', ondelete='CASCADE')),
                            Column('user_to_id', Integer, ForeignKey('users.id', ondelete='CASCADE'))
                            )

users_matches_table = Table('users_matches', Base.metadata,
                            Column('user_id', Integer, ForeignKey('users.id')),
                            Column('match_id', Integer, ForeignKey('matches.id'))
                            )

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

    @classmethod
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

    @classmethod
    def update(self, entity):
        if entity is None:
            return None
        else:
            update(entity)
            entity = session.query(entity).filter(entity.id)
            return entity

    @classmethod
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

    @classmethod
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

    @classmethod
    def notStartedMatchesCountWithUniqueInitiator(self, finderUser):
        count = len(session.query(Match).filter(Match.state == 0, Match.initiator != finderUser).distinct(Match.initiator).all())
        print('notStartedMatchesCountWithUniqueInitiator = ' + str(count))
        return count

    @classmethod
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

    @classmethod
    def createNewMatchWithUser(self, user):
        m = Match(user)
        session.add(m)
        session.commit()
        return m

    @classmethod
    def getUserByName(self, username):
        users = session.query(User).filter(User.username == username)
        if users.count() == 0:
            return None
        else:
            return users.one()

    @classmethod
    def addUser(self, new_user):
        session.add(new_user)
        session.commit()
        insp = inspect(new_user)
        if insp.persistent or insp.detached:
            return True
        else:
            return False

    @classmethod
    def addUserAnswer(self, userAnswer):
        session.add(userAnswer)
        session.commit()

    @classmethod
    def questionsIDsToRemove(self, client_questions_IDs):
        quesitons_IDs_to_remove = list()
        for qID in client_questions_IDs:
            subq = session.query(Question).filter(Question.id == qID).filter(Question.approved == True)
            if not session.query(subq.exists()).scalar():
                quesitons_IDs_to_remove.append(qID)
        return quesitons_IDs_to_remove

    @classmethod
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

    @classmethod
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

    @classmethod
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
