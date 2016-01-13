from database import UserAnswer

class UserAnswerParser:
    @classmethod
    def toJSON(self, userAnswer, id):
        if(userAnswer is None or not isinstance(userAnswer, UserAnswer)):
            return {'COMMAND':'ERROR', 'REASON':'NO USERANSWER WITH ID = {0}'.format(id)}
        else:
            return userAnswer.tojson()