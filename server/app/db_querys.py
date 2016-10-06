from app import db
from app.models import User, Match, Question, Theme, Answer, UserAnswer
from app import models
import json
import random
from models import MATCH_NOT_STARTED, MATCH_RUNNING, MATCH_TIME_ELAPSED, MATCH_FINISHED, ROUNDS_IN_MATCH, ROUND_ANSWERING, ROUND_FINISHED, ROUND_TIME_ELAPSED
from config import QUESTIONS_IN_ROUND, THEMES_COUNT, questiondir

class Database_queries:
    @classmethod
    def notStartedMatchesCountWithUniqueInitiator(self, finderUser):
        count = len(db.session.query(Match).filter(Match.state == MATCH_NOT_STARTED, Match.next_move_user_id != finderUser.id).distinct(Match.next_move_user_id).all())
        print('notStartedMatchesCountWithUniqueInitiator = ' + str(count))
        return count

    @classmethod
    def findMatchForUser(self, user):
        # finding not started matches
        if not isinstance(user, User):
            raise TypeError

        not_started_matches = models.Match.query.filter(Match.state == MATCH_NOT_STARTED).all()
        if len(not_started_matches)==0:
            m = Match(initiator=user)
            db.session.add(m)
            db.session.commit()
            return m

        for m in not_started_matches:
            if user in m.users:
                not_started_matches.remove(m)

        # get users in this matches
        users_in_matches_list = list()
        for m in not_started_matches:
            u = models.User.query.get(m.next_move_user_id)
            if not users_in_matches_list.__contains__(u):
                users_in_matches_list.append(u)

        # sort by mmr
        users_in_matches_list.sort(key=lambda user: user.mmr)
        if len(users_in_matches_list) == 0:
            m = Match(initiator=user)
            db.session.add(m)
            db.session.commit()
            return m

        # find user with minimal difference between user.rating and u.rating
        proper_user = users_in_matches_list[0]
        min_diff = abs(user.mmr - users_in_matches_list[0].mmr)
        for u in users_in_matches_list:
            if abs(u.mmr - user.mmr) < min_diff:
                proper_user = u

        # get not started matches of proper_user and sort them by creation time
        proper_matches = models.Match.query.filter(Match.next_move_user_id == proper_user.id, Match.state == MATCH_NOT_STARTED).all()
        if len(proper_matches)==0:
            m = Match(initiator=user)
            db.session.commit()
            return m

        proper_matches.sort(key=lambda match: match.created_on)

        # add self to this match
        proper_matches[0].users.append(user)
        # starting match
        proper_matches[0].state = MATCH_RUNNING

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
    def uploadQuestionFromPath(self, questionsPath):
        with open(questionsPath + u'/questions.txt') as questionsLoreFile:
            questions_list = json.loads(questionsLoreFile.read())
            for q in questions_list:
                theme = db.session.query(Theme).filter(Theme.name == q['theme']).one()
                question_obj = Question(text=q['question'],
                                        theme=theme,
                                        image_name=q['image']
                                        )
                i = 1;
                for ans in q['answers']:
                    answ = Answer(question_id=question_obj.id, text=ans)
                    if i == q['correct_answer_index']:
                        answ.is_correct = True
                    else:
                        answ.is_correct = False
                    i += 1
                    db.session.add(answ)
                    question_obj.answers.append(answ)
                db.session.add(question_obj)
        db.session.commit()

    @classmethod
    def generateThemes(cls, count = 3):
        themes = list()
        all_themes = db.session.query(Theme).all()
        if len(all_themes) < count:
            count = len(all_themes)
        mutableCount = count
        for i in range(0, mutableCount):
            theme = all_themes.pop(random.randrange(0, mutableCount))
            themes.append(theme)
            mutableCount -= 1
        return themes

    @classmethod
    def generateQuestionsOnTheme(cls, theme, count = 3):
        questions = []
        allQuestionOnTheme = models.Question.query.filter(theme == theme).all()
        if len(allQuestionOnTheme) < count:
            count = len(allQuestionOnTheme)
        mutableCount = count
        for i in range(0, mutableCount):
            question = allQuestionOnTheme.pop(random.randrange(0, mutableCount))
            questions.append(question)
            mutableCount -= 1
        return questions

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

        ############################################### adding friends
        john_user.sendRequest(peter_user)
        john_user.sendRequest(jack_user)
        jack_user.acceptRequest(john_user)

        # ############################################# making themes
        lore_theme = Theme(name=u'lore',
                           image_name=u'theme_lore.png')
        tournaments_theme = Theme(name=u'tournaments',
                                  image_name=u'theme_tournaments.png')
        mechanics_theme = Theme(name=u'mechanics',
                                image_name=u'theme_mechanics.png')
        # add to session
        db.session.add(lore_theme)
        db.session.add(tournaments_theme)
        db.session.add(mechanics_theme)
        db.session.commit()

        # upload questions
        Database_queries.uploadQuestionFromPath(questiondir)

        ############################################## create Match
        first_match = Match(initiator=john_user)
        second_match = Match(initiator=peter_user)

        # add users to match
        first_match.users.append(peter_user)
        second_match.users.append(john_user)
        third_match = Match(initiator=peter_user)
        third_match.users.append(john_user)
        fourth_match = Match(initiator=john_user)


        # [1] FINISHED
        themes = Database_queries.generateThemes(count=THEMES_COUNT)
        # add questions to match's rounds
        for r in first_match.rounds:
            r.selected_theme = random.choice(themes)
            r.questions = Database_queries.generateQuestionsOnTheme(theme=r.selected_theme, count=QUESTIONS_IN_ROUND)
            for quest in r.questions:
                    user_answer = UserAnswer()
                    user_answer.round = r
                    user_answer.user = first_match.users[0]
                    user_answer.question = quest
                    user_answer.answer_id = random.choice(quest.answers).id
                    db.session.add(user_answer)

                    user2_answer = UserAnswer()
                    user2_answer.round = r
                    user2_answer.user = first_match.users[1]
                    user2_answer.question = quest
                    user2_answer.answer_id = random.choice(quest.answers).id
                    db.session.add(user2_answer)
            r.state = ROUND_FINISHED
        first_match.state = MATCH_FINISHED
        # [!1]

        # sleep(1)

        # [2] RUNNING
        themes = Database_queries.generateThemes(count=THEMES_COUNT)
        for r in second_match.rounds[0:2]:
            r.selected_theme = random.choice(themes)
            r.questions = Database_queries.generateQuestionsOnTheme(theme=r.selected_theme, count=QUESTIONS_IN_ROUND)

            for quest in r.questions:
                        user_answer = UserAnswer()
                        user_answer.round = r
                        user_answer.user = second_match.users[0]
                        user_answer.question = quest
                        user_answer.answer_id = random.choice(quest.answers).id
                        db.session.add(user_answer)

                        user2_answer = UserAnswer()
                        user2_answer.round = r
                        user2_answer.user = second_match.users[1]
                        user2_answer.question = quest
                        user2_answer.answer_id = random.choice(quest.answers).id
                        db.session.add(user2_answer)
            r.state = ROUND_FINISHED
        second_match.state = MATCH_RUNNING
        # [!2]

        # sleep(1)

        # [3] TIME_ELAPSED
        themes = Database_queries.generateThemes(count=THEMES_COUNT)
        r = third_match.rounds[0]
        r.selected_theme = random.choice(themes)
        r.questions = Database_queries.generateQuestionsOnTheme(theme=r.selected_theme, count=QUESTIONS_IN_ROUND)

        for quest in r.questions[0:2]:
                    user_answer = UserAnswer()
                    user_answer.round = r
                    user_answer.user = third_match.users[0]
                    user_answer.question = quest
                    user_answer.answer_id = random.choice(quest.answers).id
                    db.session.add(user_answer)

                    user2_answer = UserAnswer()
                    user2_answer.round = r
                    user2_answer.user = third_match.users[1]
                    user2_answer.question = quest
                    user2_answer.answer_id = random.choice(quest.answers).id
                    db.session.add(user2_answer)
        r.state = ROUND_TIME_ELAPSED
        for r in third_match.rounds[1:]:
            r.state = ROUND_TIME_ELAPSED
        third_match.state = MATCH_TIME_ELAPSED
        # [!3]

        # [4] NOT_STARTED
        for r in fourth_match.rounds:
            r_questions = []
            for t in themes:
                t_questions = Database_queries.generateQuestionsOnTheme(t, 3)
                r_questions.extend(t_questions)
            r.questions.extend(r_questions)


        # add match to session
        db.session.add(first_match)
        db.session.add(second_match)
        db.session.add(third_match)
        db.session.add(fourth_match)
        db.session.commit()
