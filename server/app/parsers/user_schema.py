from app.models import User
from app import app
from marshmallow import Schema, fields, post_load


class UserSchema(Schema):
    id = fields.Int()
    created_on = fields.DateTime()
    updated_on = fields.DateTime()
    username = fields.Str()
    premium = fields.Boolean()
    mmr = fields.Int()
    gpm = fields.Float()
    kda = fields.Float()
    avatar_image_name = fields.Str()
    wallpapers_image_name = fields.Str()
    total_correct_answers = fields.Int()
    total_incorrect_answers = fields.Int()
    total_matches_won = fields.Int()
    total_matches_lost = fields.Int()
    total_time_for_answers = fields.Int()
    role = fields.Int()
    matches = fields.Nested('MatchSchema', many=True, only=('id'))
    friends = fields.Nested('UserSchema', many=True, only=('id'))

    @post_load
    def create_user(self, data):
        return User(**data)