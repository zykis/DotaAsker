from app.models import User
from marshmallow import Schema, fields


class UserSchema(Schema):
    id = fields.Int()
    created_on = fields.DateTime()
    updated_on = fields.DateTime()
    username = fields.Str()
    mmr = fields.Int()
    gpm = fields.Float()
    kda = fields.Float()
    avatar_image_name = fields.Str()
    wallpapers_image_name = fields.Str()
    total_correct_answers = fields.Int()
    total_incorrect_answers = fields.Int()
    role = fields.Int()
    current_matches = fields.Nested('MatchSchema', many=True)
    waiting_matches = fields.Nested('MatchSchema', many=True)
    recent_matches = fields.Nested('MatchSchema', many=True)
    friends = fields.Nested('UserSchema', many=True, exclude=('current_matches','recent_matches', 'waiting_matches', 'friends'))
