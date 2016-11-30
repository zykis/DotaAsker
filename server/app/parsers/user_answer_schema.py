from marshmallow import Schema, fields, post_load
from app.models import UserAnswer
from app.parsers.user_schema import UserSchema
from app.parsers.answer_schema import AnswerSchema

class UserAnswerSchema(Schema):
    id = fields.Int()
    answer = fields.Nested(AnswerSchema)
    user = fields.Nested(UserSchema, exclude=('matches', 'friends'))
    round = fields.Nested('RoundSchema', only=('id'))
    sec_for_answer = fields.Int()

    @post_load
    def make_user_answer(self, data):
        if data['id'] == 0:
            ua = UserAnswer()

            roundDict = data['round']
            ua.round_id = roundDict['id']

            user = data['user']
            ua.user_id = user.id

            ua.answer_id = 0

            return ua
        else:
            ua = UserAnswer.query.get(data['id'])

            answerDict = data['answer']

            ua.answer_id = answerDict['id']
            ua.sec_for_answer = data['sec_for_answer']

            return ua