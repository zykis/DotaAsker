from entity import *

class Useranswer(Base):
    __tablename__ = 'user_answers'
    id = Column(Integer, primary_key=True)
    answer_id = Column(Integer, ForeignKey('answers.id'))
    # relations
    round_id = Column(Integer, ForeignKey('rounds.id'))
    round = relationship('Round', foreign_keys=[round_id])

    user_id = Column(Integer, ForeignKey('users.id'))
    user = relationship('User', foreign_keys=[user_id])

    question_id = Column(Integer, ForeignKey('questions.id'))
    question = relationship('Question', foreign_keys=[question_id])