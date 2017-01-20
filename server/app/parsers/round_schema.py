from marshmallow import Schema, fields, post_load
from app.parsers.theme_schema import ThemeSchema
from app.parsers.question_schema import QuestionSchema
from app.parsers.user_answer_schema import UserAnswerSchema
from app.models import Round

class RoundSchema(Schema):
    id = fields.Int()
    next_move_user = fields.Nested('UserSchema', only=('id'))
    questions = fields.Nested(QuestionSchema, many=True, only=('id'))
    user_answers = fields.Nested(UserAnswerSchema, many=True, only=('id'))
    selected_theme = fields.Nested(ThemeSchema)
    
    @post_load
    def create_round(self, data):
        return Round(**data)