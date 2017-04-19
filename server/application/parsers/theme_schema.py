from marshmallow import Schema, fields, post_load
from application.models import Theme
from sqlalchemy.orm.exc import NoResultFound

class ThemeSchema(Schema):
    id = fields.Int()
    name = fields.Str()
    image_name = fields.Str()
    
    @post_load
    def get_theme(self, data):
        t = Theme.query.filter(Theme.name == data['name']).one_or_none()
        return t