from entity import *
from answer import Answer
from entities.theme import Theme
from entities.answer import Answer

from sqlalchemy_imageattach.entity import Image, image_attachment, ImageSet
from sqlalchemy_imageattach.context import store_context
from sqlalchemy.orm.exc import NoResultFound
import os



class Question(Base):
    __tablename__ = 'questions'
    id = Column(Integer, primary_key=True)
    theme_id = Column(Integer, ForeignKey('themes.id'))
    image_name = Column(String(50), nullable=True)
    text = Column(String(50), nullable=False)
    approved = Column(Boolean, default=1)
    # relations
    theme = relationship('Theme', foreign_keys=[theme_id])
    image = image_attachment('QuestionPicture')
    answers = relationship('Answer', cascade='all, delete-orphan')

    def addAnswer(self, answerText):
        answer = Answer()
        answer.question_id = self.id
        answer.text = answerText

    def setCorrectAnswer(self, correctAnswerText):
        for ans in self.answers:
            for txt in ans.text:
                if (txt == correctAnswerText):
                    self.correct_answer_id = ans.id
                    return
        answer = Answer()
        answer.question_id = self.id
        answer.text = correctAnswerText
        self.correct_answer_id = answer.id

    def columnitems(self):
        clmnItemsDict = super(Question, self).columnitems()
        # answers
        if len(self.answers) != 0:
            answer_list = list()
            for ans in self.answers:
                answer_list.append(ans.id)
            answers_dict = {"ANSWERS_IDS": answer_list}
            clmnItemsDict = dict(clmnItemsDict, **answers_dict)
        return clmnItemsDict

    def get_thumbnail(self, width=None, height=None):
        # image
        thumbnail = self.find_or_create_thumbnail(width=width, height=height)
        session.commit()
        blob = thumbnail.make_blob(store=fs_store)
        print('sizeof %s = ' % self.id + str(blob.__sizeof__()))
        return blob

    def find_or_create_thumbnail(self, width=None, height=None):
        assert width is not None or height is not None
        try:
            image = self.image.find_thumbnail(width=width, height=height)
        except NoResultFound:
            image = self.image.generate_thumbnail(width=width, height=height, store=fs_store)
        return image

class QuestionPicture(Base, Image):
    __tablename__ = 'question_picture'
    question_id = Column(Integer, ForeignKey('questions.id'), primary_key=True)
    question = relationship('Question')