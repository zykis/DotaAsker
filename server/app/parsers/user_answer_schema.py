from marshmallow import Schema, fields, post_load
from app.models import UserAnswer
from app.parsers.user_schema import UserSchema
from app.parsers.answer_schema import AnswerSchema
from app.parsers.question_schema import QuestionSchema

class UserAnswerSchema(Schema):
    id = fields.Int()
    sec_for_answer = fields.Int()
    question = fields.Nested(QuestionSchema, only=('id'))
    answer = fields.Nested(AnswerSchema, only=('id'))
    user = fields.Nested(UserSchema, only=('id'))
    round = fields.Nested('RoundSchema', only=('id'))

    @post_load
    def make_user_answer(self, data):
        return UserAnswer(**data)