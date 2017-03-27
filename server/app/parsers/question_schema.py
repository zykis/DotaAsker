from marshmallow import Schema, fields, post_load
from app.parsers.answer_schema import AnswerSchema
from app.parsers.theme_schema import ThemeSchema
from app.models import Question, Theme, Answer
from app import db

class QuestionSchema(Schema):
    id = fields.Int()
    created_on = fields.DateTime()
    updated_on = fields.DateTime()
    image_name = fields.Str()
    text = fields.Str()
    approved = fields.Bool()
    theme = fields.Nested(ThemeSchema)
    answers = fields.Nested(AnswerSchema, many=True)
    
    @post_load
    def create_question(self, data):
        if data.get('id', None) is None or 0:
            question = Question()
            question.text = data['text']
            question.approved = data.get('approved', False)
            question.image_name = data.get('image_name', '')
            question.theme = data['theme']

            for aDict in data['answers']:
                a = Answer()
                a.text = aDict['text']
                a.is_correct = aDict['is_correct']
                question.answers.append(a)
                # chech if answer.question_id will fill after session.commit()
        else:
            question = Question.query.get(data['id'])
        return question