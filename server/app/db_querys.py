from app import db
from app.models import User, Match, Question, Theme, Answer
from app import models
import json
import random
from models import MATCH_NOT_STARTED, MATCH_RUNNING

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
        questions = list()
        allQuestionOnTheme = models.Question.query.filter(theme == theme).all()
        if len(allQuestionOnTheme) < count:
            count = len(allQuestionOnTheme)
        mutableCount = count
        for i in range(0, mutableCount):
            question = allQuestionOnTheme.pop(random.randrange(0, mutableCount))
            questions.append(question)
            mutableCount -= 1
        return questions
