import cloudinary
import cloudinary.uploader
import cloudinary.api
import json
from application.models import Question, Answer, Theme, db
from application.parsers.question_schema import QuestionSchema
import os.path

def uploadQuestionFromPath(questionsPath, updateImages=False):
    cloudinary.config(cloud_name="dzixpee1a", api_key="497848972528918", api_secret="YCLF-_c_tnrdblryrMxH84DzcgE")
    # [1] parse JSON, retrieve questions
    print('parsing question.json...')
    with open(questionsPath + u'questions.json') as questionsFile:
        schema = QuestionSchema(many=True)
        questions_list = schema.loads(questionsFile.read())

        if questions_list.errors:
            print(questions_list.errors)
            return
    
        print('question.json parsed')
        for q in questions_list.data:
            # [2] check, if local images exists for all questions
            imageLocalPath = questionsPath + 'question_images/' + q.image_name
            exists = os.path.isfile(imageLocalPath)
            # [2.1] if not all images exists, exit
            if not exists:
                print('no local image file for question: {}', q.__repr__())
                continue      
        print("total question parsed: {}".format(len(questions_list.data)))
        for q in questions_list.data:
            imageLocalPath = questionsPath + 'question_images/' + q.image_name
            # [3] update/insert questions into DB
            db.session.add(q)
            # [4] for each question, update image at cloudinary.com
            if updateImages:
                cloudinary.uploader.upload(imageLocalPath, use_filename = True, unique_filename = False)

    db.session.commit()
    print("total question count: {}".format(len(Question.query.all())))
    print('questions updated')


if __name__ == '__main__':

    uploadQuestionFromPath('application/static/questions/') 
