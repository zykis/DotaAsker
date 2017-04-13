from marshmallow import Schema, fields, post_load
from appplication.parsers.theme_schema import ThemeSchema
from appplication.parsers.question_schema import QuestionSchema
from appplication.parsers.user_answer_schema import UserAnswerSchema
from appplication.models import Round

class RoundSchema(Schema):
    id = fields.Int()
    created_on = fields.DateTime()
    updated_on = fields.DateTime()
    next_move_user = fields.Nested('UserSchema', exclude=('matches', 'friends'))
    questions = fields.Nested(QuestionSchema, many=True, exclude=('text_en', 'text_ru'))
    user_answers = fields.Nested(UserAnswerSchema, many=True)
    selected_theme = fields.Nested(ThemeSchema)