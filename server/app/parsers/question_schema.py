from marshmallow import Schema, fields, post_load
from app.parsers.answer_schema import AnswerSchema
from app.parsers.theme_schema import ThemeSchema
from app.models import Question, Theme
from app import db

class QuestionSchema(Schema):
    id = fields.Int()
    image_name = fields.Str()
    text = fields.Str()
    approved = fields.Bool()
    theme = fields.Nested(ThemeSchema)
    answers = fields.Nested(AnswerSchema, many=True)
    
@post_load
def create_question(self, data):
    question = Question()
    question.text = data['text']
    question.approved = False
    question.theme = Theme.query.get(1)
    
    db.session.add(question)
    db.session.commit()
    # how to get newly created question.ID?
    
    for aDict in data['answers']:
        a = Answer()
        a.text = aDict['text']
        a.is_correct = aDict['is_correct']    
        question.answers.append(a)
        # chech if answer.question_id will fill after session.commit()
    
    return question