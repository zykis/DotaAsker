from marshmallow import Schema, fields, post_load
from application.models import Theme
from sqlalchemy.orm.exc import NoResultFound

class ThemeSchema(Schema):
    id = fields.Int()
    name = fields.Str()
    image_name = fields.Str()
    
    @post_load
    def get_theme(self, data):
        try: 
            t = Theme.query.filter(Theme.name == data['name']).one()
        except NoResultFound:
            print ('Theme with name %s not found in Database' % data['name'])
        return t