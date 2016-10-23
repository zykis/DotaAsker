from marshmallow import Schema, fields
from app.parsers.theme_schema import ThemeSchema
from app.parsers.question_schema import QuestionSchema
from app.parsers.user_answer_schema import UserAnswerSchema

class RoundSchema(Schema):
    id = fields.Int()
    next_move_user = fields.Nested('UserSchema', only=('id'))
    questions = fields.Nested(QuestionSchema, many=True)
    user_answers = fields.Nested(UserAnswerSchema, many=True)