from app.models import Match
from marshmallow import Schema, fields
from app.parsers.round_schema import RoundSchema

class MatchSchema(Schema):
    id = fields.Int()
    state = fields.Int()
    mmr_gain = fields.Int()
    rounds = fields.Nested('RoundSchema', many=True)
    users = fields.Nested('UserSchema', exclude=('matches', 'friends'), many=True)
