from marshmallow import Schema, fields
from app.entities.parsers.theme_schema import ThemeSchema
from app.entities.parsers.question_schema import QuestionSchema
from app.entities.parsers.user_answer_schema import UserAnswerSchema

class RoundSchema(Schema):
    state = fields.Int()
    theme = fields.Nested(ThemeSchema)
    questions = fields.Nested(QuestionSchema, many=True)
    user_answers = fields.Nested(UserAnswerSchema, many=True)