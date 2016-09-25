from marshmallow import Schema, fields

class UserAnswerSchema(Schema):
    answer_id = fields.Int()
    user_id = fields.Int()
    question_id = fields.Int()