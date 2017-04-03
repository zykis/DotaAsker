from marshmallow import Schema, fields, post_load
from app.parsers.answer_schema import AnswerSchema
from app.parsers.theme_schema import ThemeSchema
from app.models import Question, Theme, Answer
from app import db
from flask import g

class QuestionSchema(Schema):
    id = fields.Int()
    created_on = fields.DateTime()
    updated_on = fields.DateTime()
    image_name = fields.Str()
    text = fields.Str()
    approved = fields.Bool()
    theme = fields.Nested(ThemeSchema)
    answers = fields.Nested(AnswerSchema, many=True, exclude=('text_en', 'text_ru'))
    
    @post_load
    def create_question(self, data):
        if (data.get('id', None) is None) or (data.get('id') == 0):
            question = Question()
            question.text_en = data.get('text_en', '')
            question.text_ru = data.get('text_ru', '')
            question.approved = data.get('approved', False)
            question.image_name = data.get('image_name', '')
            question.theme = data.get('theme', None)

            for aDict in data.get('answers'):
                a = Answer()
                a.text = aDict.get('text')
                a.is_correct = aDict.get('is_correct')
                question.answers.append(a)
                # chech if answer.question_id will fill after session.commit()
        else:
            question = Question.query.get(data['id'])
        return question
    
    def get_attribute(self, key, obj, default):
        if key == 'text':
            return getattr(obj, key + '_' + g.locale)
        else:
            return getattr(obj, key, default)