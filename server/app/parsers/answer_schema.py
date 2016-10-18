from marshmallow import Schema, fields

class AnswerSchema(Schema):
    id = fields.Int()
    text = fields.Str()
    is_correct = fields.Bool()