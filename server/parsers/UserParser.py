from database import User

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
        user.rating = userDict['RATING']
        user.gpm = userDict['GPM']
        user.kda = userDict['KDA']
        user.avatar_image_name = userDict['AVATART_IMAGE_NAME']
        user.wallpapers_image_name = user['WALLPAPERS_IMAGE_NAME']
        return user