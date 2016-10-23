from app.models import Match
from marshmallow import Schema, fields
from app.parsers.round_schema import RoundSchema

class MatchSchema(Schema):
    id = fields.Int()
    state = fields.Int()
    finished = fields.Bool()
    rounds = fields.Nested('RoundSchema', many=True)
    users = fields.Nested('UserSchema', exclude=('recent_matches', 'current_matches', 'friends'), many=True)
