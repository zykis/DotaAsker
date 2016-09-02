import json

from app.database import *
from user_answer_parser import *
from user_parser import *


class Parser:
    @classmethod
    def fromJSON(self, jsonDict, cls):
        if cls is Useranswer:
            decoded = UserAnswerParser.fromJSON(jsonDict)
        elif cls is User:
            decoded = UserParser.fromJSON(jsonDict)
        return decoded

    @classmethod
    def toJSON(self, obj, cls):
        if isinstance(obj, Useranswer):
            obj = UserAnswerParser.toJSON(obj)
        elif isinstance(obj, User):
            obj = UserParser.toJSON(obj)
        json.dumps(obj)
        return obj