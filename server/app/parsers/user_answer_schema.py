from marshmallow import Schema, fields, post_load
from app.models import UserAnswer

class UserAnswerSchema(Schema):
    id = fields.Int()
    answer_id = fields.Int()
    user_id = fields.Int()
    round_id = fields.Int()

    @post_load
    def make_user_answer(self, data):
        return UserAnswer(**data)