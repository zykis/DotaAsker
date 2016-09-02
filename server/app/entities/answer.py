from entity import *

class Answer(Base):
    __tablename__ = 'answers'
    id = Column(Integer, primary_key=True)
    question_id = Column(Integer, ForeignKey('questions.id'))
    text = Column(String(50))
    is_correct = Column(Boolean)
    # relations
    question = relationship('Question', foreign_keys=[question_id])