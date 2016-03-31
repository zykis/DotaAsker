from database import Useranswer

class UserAnswerParser:
    @classmethod
    def toJSON(self, userAnswer):
        if(userAnswer is None or not isinstance(userAnswer, Useranswer)):
            return None
        else:
            return userAnswer.tojson()

    @classmethod
    def fromJSON(self, userAnswerDict):
        ua = Useranswer()
        ua.answer_id = userAnswerDict['ANSWER_ID']
        ua.question_id = userAnswerDict['QUESTION_ID']
        ua.user_id = userAnswerDict['USER_ID']
        ua.round_id = userAnswerDict['ROUND_ID']