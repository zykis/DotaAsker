from marshmallow import Schema, fields

class AnswerSchema(Schema):
    id = fields.Int()
    created_on = fields.DateTime()
    updated_on = fields.DateTime()
    text = fields.Str()
    is_correct = fields.Bool()
    
    def get_attribute(self, obj, key, default):
        if key == 'text':
            return g.locale + ": " + obj.get(key, default)
        else:
            return obj.get(key, default)