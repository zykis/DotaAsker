#!flask/bin/python
import os
import unittest

from config import basedir, questiondir
from application import app, db, models
from application.models import User, Theme, Match, Question, UserAnswer, MATCH_FINISHED, MATCH_RUNNING, MATCH_TIME_ELAPSED
from application.parsers.user_schema import UserSchema
from application.db_querys import Database_queries
from marshmallow import pprint

class TestCase(unittest.TestCase):
    def setUp(self):
        app.config['TESTING'] = True
        app.config['SERVER_NAME'] = "http://192.168.100.24:5000"
        app.config['SQLALCHEMY_DATABASE_URI'] = 'sqlite:///' + os.path.join(basedir, 'test.db')
        self.app_context = app.app_context()
        self.app_context.push()
        self.app = app.test_client()
        Database_queries.createTestData()

    def tearDown(self):
        db.session.remove()
        db.drop_all()
        self.app_context.pop()

    def testFriendShip(self):
        # john_user.sendRequest(peter_user)
        # john_user.sendRequest(jack_user)
        # jack_user.acceptRequest(john_user)

        john_user = models.User.query.get(1)
        peter_user = models.User.query.get(2)
        jack_user = models.User.query.get(3)

        assert not peter_user.isPending(john_user)
        assert john_user.isPending(peter_user)

        assert len(jack_user.friends()) == 1
        assert len(john_user.friends()) == 1

        assert len(peter_user.friends()) == 0
        app.logger.debug('testFriendShip - OK')

    def testFindMatch(self):
        peter_user = models.User.query.filter(User.username==u'Peter').one()
        assert isinstance(peter_user, User)

        # Found already existed match
        m = Database_queries.findMatchForUser(peter_user)
        assert isinstance(m, Match)
        print 'founded existed match: %s' % m.__repr__()

        # Create new match
        m1 = Database_queries.findMatchForUser(peter_user)
        db.session.add(m1)
        db.session.commit()
        print 'created new match: %s' % m1.__repr__()
        app.logger.debug('testFindMatch - OK')

    def testCascadeUserMatch(self):
        # user -> match
        firstUser = User(username=u'FirstUser', password='123')
        db.session.add(firstUser)
        db.session.commit()
        firstMatch = Match(initiator=firstUser)
        db.session.add(firstMatch)
        db.session.commit()
        assert len(firstUser.matches) == 1

        # cascade update
        firstUser.username = u'FirstUserUpdated'
        db.session.commit()
        assert firstMatch.users[0].username == u'FirstUserUpdated'

        # cascade delete
        db.session.delete(firstUser)
        db.session.commit()
        assert len(firstMatch.users) == 0
        db.session.delete(firstMatch)
        db.session.commit()

        # match -> user
        secondUser = User(username=u'SecondUser', password='123')
        db.session.add(secondUser)
        db.session.commit()
        secondMatch = Match(initiator=secondUser)
        db.session.add(secondMatch)
        db.session.commit()
        assert len(secondUser.matches) == 1

        # cascade update
        secondMatch.state = MATCH_TIME_ELAPSED
        db.session.commit()
        assert models.User.query.get(secondUser.id).matches[0].state == MATCH_TIME_ELAPSED

        # cascade delete
        db.session.delete(secondMatch)
        db.session.commit()
        assert len(secondUser.matches) == 0
        app.logger.debug('testCascadeUserMatch - OK')


    def testCascadeDeleteDB(self):
        u = User(username=u'FirstUser', password='123')
        db.session.add(u)
        db.session.commit()
        m = Match(initiator=u)
        db.session.add(m)
        db.session.commit()
        # assert models.Match.query.filter(Match.users.contains(u)).all().__len__() == 1
        app.logger.debug('Match %s' % m)
        models.User.query.filter(User.username==u'FirstUser').delete()
        db.session.commit()
        # assert models.User.query.filter(User.username==u'FirstUser').all().__len__() == 0
        app.logger.debug('testCascadeDeleteDB - OK')

    def testUsersList(self):
        user1 = models.User.query.get(1)
        user2 = models.User.query.get(2)
        user3 = models.User.query.get(3)
        user_list = list()
        user_list.append(user1)
        user_list.append(user2)
        assert user1 in user_list
        assert user3 not in user_list
        app.logger.debug('testUsersList - OK')

    def testQuestionsSynchronization(self):
        app.logger.debug('testQuestionSynchronization - OK')

    def testFinishMatch(self):
        app.logger.debug('testFinishMatch - OK')

    def testSerializeDeserialize(self):
        john = User.query.get(1) # getting John

        john.recent_matches = []
        john.current_matches = []
        john.waiting_matches = []
        for m in john.matches:
            if m.state == MATCH_FINISHED or m.state == MATCH_TIME_ELAPSED:
                john.recent_matches.append(m)
            else:
                if m.next_move_user().id == john.id:
                    john.current_matches.append(m)
                else:
                    john.waiting_matches.append(m)
        userSchema = UserSchema()
        dumped_john = userSchema.dumps(john)
        pprint(dumped_john.data)
        assert not dumped_john.errors
        app.logger.debug('testSerializeDeserialize - OK')

if __name__ == '__main__':
    unittest.main()