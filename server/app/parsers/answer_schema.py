from marshmallow import Schema, fields
from flask import g

class AnswerSchema(Schema):
    id = fields.Int()
    created_on = fields.DateTime()
    updated_on = fields.DateTime()
    text = fields.Str()
    is_correct = fields.Bool()
    
    def get_attribute(self, key, obj, default):
        if key == 'text':
            return g.locale + ": " + getattr(obj, key)
        else:
            return getattr(obj, key, default)