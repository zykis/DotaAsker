from application.models import Match
from marshmallow import Schema, fields
from application.parsers.round_schema import RoundSchema

class MatchSchema(Schema):
    id = fields.Int()
    created_on = fields.DateTime()
    updated_on = fields.DateTime()
    state = fields.Int()
    finish_reason = fields.Int()
    mmr_gain = fields.Int()
    updated_on = fields.DateTime()
    rounds = fields.Nested('RoundSchema', many=True)
    users = fields.Nested('UserSchema', exclude=('matches', 'friends'), many=True)
    winner = fields.Nested('UserSchema', exclude=('matches', 'friends'))
