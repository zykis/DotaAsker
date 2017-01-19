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
        ua = UserAnswer()

        round = data['round']
        ua.round_id = round['id']

        question = data['question']
        ua.question_id = question.id

        user = data['user']
        ua.user_id = user.id

        answer = data['answer']
        ua.answer_id = answer['id']

        return ua