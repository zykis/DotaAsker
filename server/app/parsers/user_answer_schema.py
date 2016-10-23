from marshmallow import Schema, fields

class UserAnswerSchema(Schema):
    id = fields.Int()
    answer_id = fields.Int()
    user_id = fields.Int()
    round_id = fields.Int()