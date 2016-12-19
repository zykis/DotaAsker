from marshmallow import Schema, fields, post_load
from app.models import Theme

class ThemeSchema(Schema):
    id = fields.Int()
    name = fields.Str()
    image_name = fields.Str()
    
    @post_load
    def get_theme(self, data):
        t = Theme.query.filter(Theme.name == data['name']).one()
        return t