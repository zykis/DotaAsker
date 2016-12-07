from marshmallow import Schema, fields, post_load
from app.models import UserAnswer
from app.parsers.user_schema import UserSchema
from app.parsers.answer_schema import AnswerSchema
from app.parsers.question_schema import QuestionSchema

class UserAnswerSchema(Schema):
    id = fields.Int()
    question = fields.Nested(QuestionSchema)
    answer = fields.Nested(AnswerSchema)
    user = fields.Nested(UserSchema, exclude=('matches', 'friends'))
    round = fields.Nested('RoundSchema', only=('id', 'selected_theme'))
    sec_for_answer = fields.Int()

    @post_load
    def make_user_answer(self, data):
        if data['id'] == 0:
            ua = UserAnswer()

            roundDict = data['round']
            ua.round_id = roundDict['id']

            ua.question = data['question']

            user = data['user']
            ua.user_id = user.id

            answerDict = data['answer']
            ua.answer_id = answerDict['id']

            return ua
        else:
            ua = UserAnswer.query.get(data['id'])

            answerDict = data['answer']

            ua.question = data['question']

            ua.answer_id = answerDict['id']
            ua.sec_for_answer = data['sec_for_answer']

            return ua