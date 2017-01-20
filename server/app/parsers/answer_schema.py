from marshmallow import Schema, fields, post_load

class AnswerSchema(Schema):
    id = fields.Int()
    text = fields.Str()
    is_correct = fields.Bool()
    
    def create_answer(self, data):
        return Answer(**data)