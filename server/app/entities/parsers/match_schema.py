from app.models import Match
from marshmallow import Schema, fields
from app.entities.parsers.round_schema import RoundSchema
# from app.entities.parsers.user_parser import UserSchema

class MatchSchema(Schema):
    state = fields.Int()
    # TODO: RoundSchema
    rounds = fields.Nested('RoundSchema', many=True)
    winner = fields.Nested('UserSchema', exclude=('recent_matches', 'current_matches', 'friends'))
    users = fields.Nested('UserSchema', exclude=('recent_matches', 'current_matches', 'friends'), many=True)
    next_move_user = fields.Nested('UserSchema', exclude=('recent_matches', 'current_matches', 'friends'))
