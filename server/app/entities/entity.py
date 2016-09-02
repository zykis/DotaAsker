from sqlalchemy.ext.declarative import declarative_base as real_declarative_base
from sqlalchemy import Column
from sqlalchemy import DateTime
import datetime

# Let's make this a class decorator
declarative_base = lambda cls: real_declarative_base(cls=cls)

@declarative_base
class Base(object):
    creation_time = Column(DateTime)
    def columns(self):
        return [c.name for c in self.__table__.columns]

    def columnitems(self):
        columnsDict = dict()
        for c in self.columns():
            inst = getattr(self, c)
            if isinstance(inst, datetime.datetime):
                columnsDict = dict (dict([(c.upper(), inst.strftime('%Y-%m-%d %H:%M:%S.%f'))]), **columnsDict)
            else:
                columnsDict = dict (dict([(c.upper(), getattr(self, c))]), **columnsDict)
        return columnsDict

    def tojson(self):
        return self.columnitems()

    def __init__(self):
        self.creation_time = DateTime.now()