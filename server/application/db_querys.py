from application import db
from application.models import User, Match, Question, Theme, Answer, UserAnswer, MATCH_RUNNING, MATCH_FINISHED
from application import models
import json
import random
from config import questiondir
from sqlalchemy import func
from synchronize_questions import uploadQuestionFromPath
from datetime import date, datetime, timedelta

class Database_queries:

    @classmethod
    def findMatchForUser(self, user):
        # finding not started matches
        if not isinstance(user, User):
            raise TypeError

        # not_started_matches = models.Match.query.join(Match.users).group_by(Match.id).join(Match.users).having(func.count(Match.users) == 1).all()
        sql = "SELECT matches.id as matches_id FROM matches join users_matches on users_matches.match_id = matches.id group by matches.id having count(users_matches.match_id) = 1 and users_matches.user_id != {}".format(user.id)
        not_started_matches_sql = db.engine.execute(sql)
        not_started_matches = []
        for row in not_started_matches_sql:
            m = Match.query.get(row[0])
            if m.state == MATCH_RUNNING:
                # Ignore matches, when we have to wait other players
                # We need to start right away *thumbs up*
                if m.next_move_user() is None:
                    not_started_matches.append(m)
                elif m.next_move_user().id == user.id:
                    not_started_matches.append(m)

        # if not match exists
        if len(not_started_matches) == 0:
            m = Match(initiator=user)
            db.session.add(m)
            db.session.commit()
            return m

        # get users in this matches
        users_in_matches_list = []
        for m in not_started_matches:
            if m.users[0] not in users_in_matches_list:
                users_in_matches_list.append(m.users[0])

        # sort by mmr
        users_in_matches_list.sort(key=lambda user: user.mmr)

        # find user with minimal difference between user.rating and u.rating
        proper_user = users_in_matches_list[0]
        min_diff = abs(user.mmr - users_in_matches_list[0].mmr)
        for u in users_in_matches_list:
            if abs(u.mmr - user.mmr) < min_diff:
                proper_user = u

        # get not started matches of proper_user and sort them by creation time
        proper_matches = []
        for m in not_started_matches:
            if m.users[0].id == proper_user.id:
                proper_matches.append(m)

        # sorting by creation time. Oldest - first
        proper_matches.sort(key=lambda match: match.created_on)

        # add self to this match
        proper_matches[0].setOpponent(user)
        db.session.commit()

        # return the oldest match
        return proper_matches[0]

    @classmethod
    def questionsIDsToRemove(self, client_questions_IDs):
        quesitons_IDs_to_remove = list()
        for qID in client_questions_IDs:
            subq = db.session.query(Question).filter(Question.id == qID).filter(Question.approved == True)
            if not db.session.query(subq.exists()).scalar():
                quesitons_IDs_to_remove.append(qID)
        return quesitons_IDs_to_remove

    @classmethod
    def questionsToAdd(self, client_questions_IDs):
        questions_to_add = list()
        db_questions = db.session.query(Question).filter(Question.approved == True).all()
        for q in db_questions:
            need_to_add = True
            for client_Q_ID in client_questions_IDs:
                if q.id == client_Q_ID:
                    need_to_add = False
            if need_to_add == True:
                questions_to_add.append(q)
        return questions_to_add

    @classmethod
    def generateTestMMR(cls):
        users = User.query.all()
        today = date.today()
        for u in users:
            for i in range(0, 10):
                past_day = today - timedelta(days=i)
                multiplier = random.randint(1, 3)
                sign = random.randint(1,10) % 2
                if sign == 1:
                    mmr = 4000 + multiplier * 25
                else:
                    mmr = 4000 - multiplier * 25
                db.engine.execute("INSERT OR REPLACE INTO user_date_mmr (user_id, date, mmr) VALUES ({}, '{}', {})".format(u.id, past_day.strftime("%Y-%m-%d"), mmr))

    @classmethod
    def createTestData(cls):
        db.drop_all()
        db.create_all()
        ############################################# create Users
        john_user = User(username=u'John', password=u'123', avatar_image_name='avatar_axe.png', wallpapers_image_name='wallpaper_antimage_1.jpg', mmr=4125)
        peter_user = User(username=u'Peter', password=u'123', avatar_image_name='avatar_nature_prophet.png', wallpapers_image_name='wallpaper_bloodseeker_1.jpg', mmr=3940)
        jack_user = User(username=u'Jack', password=u'123', avatar_image_name='avatar_tinker.png', wallpapers_image_name='wallpaper_bloodseeker_1.jpg', mmr=3870)

        # add Users to session
        db.session.add(john_user)
        db.session.add(peter_user)
        db.session.add(jack_user)
        db.session.commit()
        
        Database_queries.generateTestMMR()

        ############################################### adding friends
        # john_user.sendRequest(peter_user)
        # john_user.sendRequest(jack_user)
        # jack_user.acceptRequest(john_user)

        # ############################################# making themes
        heroes_items_theme = Theme(name=u'heroes / items',
                           image_name=u'theme_heroes_items.png')
        tournaments_theme = Theme(name=u'tournaments',
                                  image_name=u'theme_tournaments.png')
        mechanics_theme = Theme(name=u'mechanics',
                                image_name=u'theme_mechanics.png')
        # add to session
        db.session.add(heroes_items_theme)
        db.session.add(tournaments_theme)
        db.session.add(mechanics_theme)
        db.session.commit()

        # upload questions
        uploadQuestionFromPath(questiondir + '/', updateImages=False)

        ############################################## create Match
        first_match = Match(initiator=john_user)
        second_match = Match(initiator=peter_user)

        # add users to match
        first_match.setOpponent(peter_user)
        second_match.setOpponent(john_user)
        third_match = Match(initiator=peter_user)
        third_match.setOpponent(john_user)
        fourth_match = Match(initiator=john_user)
        fifth_match = Match(initiator=jack_user)


        # [1] FINISHED
        for r in first_match.rounds:
            r_theme = random.choice(Theme.query.all())
            r.selected_theme = r_theme
            for quest in r.questions:
                if quest.theme == r_theme:
                    user_answer = UserAnswer()
                    user_answer.round = r
                    user_answer.question = quest
                    user_answer.user = first_match.users[0]
                    user_answer.answer = random.choice(quest.answers)
                    user_answer.sec_for_answer = random.uniform(5, 25)
                    db.session.add(user_answer)

                    user2_answer = UserAnswer()
                    user2_answer.round = r
                    user2_answer.question = quest
                    user2_answer.user = first_match.users[1]
                    user2_answer.answer = random.choice(quest.answers)
                    user2_answer.sec_for_answer = random.uniform(5, 25)
                    db.session.add(user2_answer)
        first_match.finish()
        # [!1]

        # [2] RUNNING
        for r in second_match.rounds[0:5]:
            r_theme = random.choice(Theme.query.all())
            r.selected_theme = r_theme
            for quest in r.questions:
                if quest.theme == r_theme:
                    user_answer = UserAnswer()
                    user_answer.round = r
                    user_answer.question = quest
                    user_answer.user = second_match.users[0]
                    user_answer.answer = random.choice(quest.answers)
                    user_answer.sec_for_answer = random.uniform(5, 25)
                    db.session.add(user_answer)

                    user2_answer = UserAnswer()
                    user2_answer.round = r
                    user2_answer.question = quest
                    user2_answer.user = second_match.users[1]
                    user2_answer.answer = random.choice(quest.answers)
                    user2_answer.sec_for_answer = random.uniform(5, 25)
                    db.session.add(user2_answer)
        # [!2]

        # [3] TIME_ELAPSED
        for r in third_match.rounds[0:3]:
            r_theme = random.choice(Theme.query.all())
            r.selected_theme = r_theme
            for quest in r.questions:
                if quest.theme == r_theme:
                    user_answer = UserAnswer()
                    user_answer.round = r
                    user_answer.question = quest
                    user_answer.user = third_match.users[0]
                    user_answer.question = quest
                    user_answer.answer = random.choice(quest.answers)
                    user_answer.sec_for_answer = random.uniform(5, 25)
                    db.session.add(user_answer)

                    user2_answer = UserAnswer()
                    user2_answer.round = r
                    user2_answer.question = quest
                    user2_answer.user = third_match.users[1]
                    user2_answer.question = quest
                    user2_answer.answer = random.choice(quest.answers)
                    user2_answer.sec_for_answer = random.uniform(5, 25)
                    db.session.add(user2_answer)
        third_match.elapseMatch()
        # [!3]

        # [4] NOT_STARTED


        # add match to session
        db.session.add(first_match)
        db.session.add(second_match)
        db.session.add(third_match)
        db.session.add(fourth_match)
        db.session.add(fifth_match)
        db.session.commit()
