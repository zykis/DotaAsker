from marshmallow import Schema, fields
from app.entities.parsers.answer_schema import AnswerSchema

class QuestionSchema(Schema):
    id = fields.Int()
    image_name = fields.Str()
    text = fields.Str()
    approved = fields.Bool()
    answers = fields.Nested(AnswerSchema, many=True)