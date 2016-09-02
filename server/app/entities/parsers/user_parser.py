from app.database import User

class UserParser:
    @classmethod
    def toJSON(self, user):
        if(user is None or not isinstance(user, User)):
            return None
        else:
            return user.tojson()

    @classmethod
    def fromJSON(self, userDict):
        user = User()
        user.id = userDict['ID']
        user.username = userDict['USERNAME']
        user.mmr = userDict['RATING']
        user.gpm = userDict['GPM']
        user.kda = userDict['KDA']
        user.avatar_image_name = userDict['AVATAR_IMAGE_NAME']
        user.wallpapers_image_name = userDict['WALLPAPERS_IMAGE_NAME']
        user.total_correct_answers = userDict['TOTAL_CORRECT_ANSWERS']
        user.total_incorrect_answers = userDict['TOTAL_INCORRECT_ANSWERS']
        return user