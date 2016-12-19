import cloudinary
import cloudinary.uploader
import cloudinary.api
import json
from app.models import Question, Answer, Theme, db
from app.parser.question_schema import QuestionSchema
import os.path

def uploadQuestionFromPath(questionsPath):
    # [1] parse JSON, retrieve questions
    with open(questionsPath + u'/questions.json') as questionsFile:
        schema = QuestionSchema(many=True)
        questions_list = schema.loads(questionsFile.read())
        
        for q in questions_list:
            # [2] check, if local images exists for all questions
            imageLocalPath = questionsPath + '/question_images/' + fname
            exists = os.path.isfile(imageLocalPath)
            # [2.1] if not all images exists, exit
            if not exists:
                app.logger.debug('no local image file for question: {}', q.__repr()__)
                return        
        for q in questions_list:
            imageLocalPath = questionsPath + '/question_images/' + fname
            # [3] update/insert questions into DB
            db.session.add(q)
            # [4] for each question, update image at cloudinary.com
            cloudinary.uploader.upload(imageLocalPath)
            
    db.session.commit()

if __name__ == '__main__':
    cloudinary.config(cloud_name="dzixpee1a", api_key="497848972528918", api_secret="YCLF-_c_tnrdblryrMxH84DzcgE")
    uploadQuestionFromPath('static/questions/')


	


