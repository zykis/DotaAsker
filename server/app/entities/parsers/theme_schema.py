from marshmallow import Schema, fields

class ThemeSchema(Schema):
    id = fields.Int()
    name = fields.Str()
    image_name = fields.Str()