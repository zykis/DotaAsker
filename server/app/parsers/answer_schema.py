from marshmallow import Schema, fields

class AnswerSchema(Schema):
    id = fields.Int()
    created_on = fields.DateTime()
    updated_on = fields.DateTime()
    text = fields.Str()
    is_correct = fields.Bool()