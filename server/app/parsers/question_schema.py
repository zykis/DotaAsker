from marshmallow import Schema, fields
from app.parsers.answer_schema import AnswerSchema
from app.parsers.theme_schema import ThemeSchema

class QuestionSchema(Schema):
    id = fields.Int()
    image_name = fields.Str()
    text = fields.Str()
    approved = fields.Bool()
    theme = fields.Nested(ThemeSchema)
    answers = fields.Nested(AnswerSchema, many=True)