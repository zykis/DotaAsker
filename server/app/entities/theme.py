from entity import *

class Theme(Base):
    __tablename__ = 'themes'
    id = Column(Integer, primary_key=True)
    name = Column(String(50), nullable=False)
    image_name = Column(String(50), nullable=True)
