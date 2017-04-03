from marshmallow import Schema, fields
from flask import g

class AnswerSchema(Schema):
    id = fields.Int()
    created_on = fields.DateTime()
    updated_on = fields.DateTime()
    text = fields.Str()
    text_en = fields.Str()
    text_ru = fields.Str()
    is_correct = fields.Bool()
    
    def get_attribute(self, key, obj, default):
        if key == 'text':
            return getattr(obj, key + '_' + g.locale)
        else:
            return getattr(obj, key, default)