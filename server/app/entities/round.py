from entity import *
import random

class Round(Base):
    __tablename__ = 'rounds'
    id = Column(Integer, primary_key=True)
    # SERVER (0-NOT_STARTED, 1-FINISHED, 2-TIME_ELAPSED, 3-ASWERING, 4-REPLYING)
    # CLIENT (0-NOT_STARTED, 1-FINISHED, 2-TIME_ELAPSED, 3-PLAYER_ASWERING, 4-OPPONENT_ANSWERING, 5-PLAYER_REPLYING, 6-OPPONENT_REPLYING)
    state = Column(Integer, nullable=False, default=0)
    match_id = Column(Integer, ForeignKey('matches.id'))
    theme_id = Column(Integer, ForeignKey('themes.id'), nullable=True)
    # relations
    match = relationship('Match')
    theme = relationship('Theme')

    questions = relationship('Question', secondary='round_questions')
    user_answers = relationship('Useranswer', cascade='all, delete-orphan')

    def __init__(self):
        self.state = 0
        self.theme_id = random.randrange(1, 3)

    def columnitems(self):
        # parent
        clmnItemsDict = super(Round, self).columnitems()
        # next move user id
        next_move_user_dict = {"NEXT_MOVE_USER_ID": self.match.next_move_user_id}

        # questions
        questions_list = list()
        for q in self.questions:
            questions_list.append(q.id)
        questions_dict = {'QUESTIONS_IDS': questions_list}
        # answers
        answers_list = list()
        for a in self.user_answers:
            answers_list.append(a.id)
        answers_dict = {"ANSWERS_IDS": answers_list}
        # common
        clmnItemsDict = dict(clmnItemsDict, **next_move_user_dict)
        clmnItemsDict = dict(clmnItemsDict, **questions_dict)
        clmnItemsDict = dict(clmnItemsDict, **answers_dict)
        return clmnItemsDict
