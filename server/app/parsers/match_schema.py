from app.models import Match
from marshmallow import Schema, fields, post_load
from app.parsers.round_schema import RoundSchema

class MatchSchema(Schema):
    id = fields.Int()
    state = fields.Int()
    mmr_gain = fields.Int()
    updated_on = fields.DateTime()
    rounds = fields.Nested('RoundSchema', many=True, only=('id'))
    users = fields.Nested('UserSchema', many=True, only=('id'))
    
    @post_load
    def create_match(self, data):
        return Match(**data)
