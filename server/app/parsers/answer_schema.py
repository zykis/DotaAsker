from marshmallow import Schema, fields

class AnswerSchema(Schema):
    id = fields.Int()
    text = fields.Str()
    question_id = fields.Int()
    is_correct = fields.Bool()