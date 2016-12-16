import cloudinary
import cloudinary.uploader
import cloudinary.api
import json
from app.models import Question, Answer, Theme, db

def uploadQuestionFromPath(questionsPath):
    with open(questionsPath + u'/questions.json') as questionsFile:
        questions_list = json.loads(questionsFile.read())
        Question.query.delete()
        for q in questions_list:
            theme = db.session.query(Theme).filter(Theme.name == q['theme']).one()
            question_obj = Question(text=q['text'],
                                    theme=theme,
                                    image_name=q['image_name'],
                                    approved=q['approved']
                                    )
            for ans in q['answers']:
                answ = Answer(question_id=question_obj.id, text=ans['text'], is_correct=ans['is_correct'])
                db.session.add(answ)
                question_obj.answers.append(answ)
            db.session.add(question_obj)
    db.session.commit()

if __name__ == '__main__':
    cloudinary.config(cloud_name="dzixpee1a", api_key="497848972528918", api_secret="YCLF-_c_tnrdblryrMxH84DzcgE")
    uploadQuestionFromPath('static/questions/')
# [1] parse JSON, retrieve questions
# [2] check, if images exists for all questions
	# [2.1] if not all images exists, exit
# [3] update/insert questions into DB
# [4] for each question, check if image already present in cloudinary.com
	# [4.1] if image present, update it
	# [4.2] else - create one
