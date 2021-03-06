from application.models import User
from application import app
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
    matches = fields.Nested('MatchSchema', many=True)
    friends = fields.Nested('UserSchema', many=True, exclude=('matches', 'friends'))

    @post_load
    def update_user(self, data):
        id = data.get('id', None)
        if id is not None:
            user = User.query.get(id)
        else:
            app.logger.critical("can't update user without id")
            return None

        avatar = data.get('avatar_image_name', None)
        if avatar is not None:
            user.avatar_image_name = avatar

        premium = data.get('premium', None)
        if premium is not None:
            user.premium = premium

        return user