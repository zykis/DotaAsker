from app.models import User
from app.entities.parsers.match_schema import MatchSchema
from marshmallow import Schema, fields, pre_load
from app.models import MATCH_FINISHED, MATCH_TIME_ELAPSED

class UserSchema(Schema):
    id = fields.Int()
    created_on = fields.DateTime()
    updated_on = fields.DateTime()
    username = fields.Str()
    mmr = fields.Int()
    gpm = fields.Int()
    kda = fields.Int()
    avatar_image_name = fields.Str()
    wallpapers_image_name = fields.Str()
    total_correct_answers = fields.Int()
    total_incorrect_answers = fields.Int()
    role = fields.Int()
    current_matches = fields.Nested('MatchSchema', many = True)
    recent_matches = fields.Nested('MatchSchema', many=True)
    friends = fields.Nested('UserSchema', many=True, exclude=('current_matches','recent_matches', 'friends'))
