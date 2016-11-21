from marshmallow import Schema, fields, post_load
from app.parsers.answer_schema import AnswerSchema
from app.parsers.theme_schema import ThemeSchema
from app.models import Question, Theme

class QuestionSchema(Schema):
    id = fields.Int()
    image_name = fields.Str()
    text = fields.Str()
    approved = fields.Bool()
    theme = fields.Nested(ThemeSchema)
    answers = fields.Nested(AnswerSchema, many=True)
    
@post_load
    def create_question(self, data):
        question = Qustion()
        question.text = data['text']
        question.approved = false
        question.theme = Theme.query.get(1)
        for a in data['answers']:
            # parse answer?
            question.answers.append(a)
        return question