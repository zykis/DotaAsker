from twisted.internet.protocol import Factory
from twisted.internet.protocol import Protocol
from twisted.internet import reactor
import json
from database import *

MATCHES_MAX_COUNT = 2


class FailedFormatException(Exception):
    def __init__(self, value):
        self.value = value

    def __str__(self):
        return repr(self.value)


class DotaProtocol(Protocol):
    myDB = Database()
    myDB.initTestData()

    def connectionMade(self):
        print "client connected"
        self.factory.clients.append(self)
        print "clients are: ", self.factory.clients

    def connectionLost(self, reason):
        print ("client disconnected: %s" % reason)
        self.factory.clients.remove(self)

    def writeJSONToClient(self, jsonData):
        # print 'writing to client:', data
        self.transport.write(jsonData + 'ENDMSG')

    def writeBinaryToClient(self, binaryData):
        self.transport.write(binaryData + 'ENDBINARY')

    def sendPlayerInfo(self, playerName):
        player = self.myDB.getPlayerByName(playerName)
        if player == None:
            strJSON = json.dumps(
                {'command': 'getPlayerInfo', 'result': 'failed', "reason": "no such user in database"},
                sort_keys=False)
        else:
            strJSON = json.dumps({"command": "getPlayerInfo", "result": "succeed", "player": player.tojson()},
                                 sort_keys=False)
        print(strJSON)
        self.writeJSONToClient(strJSON)

    # parsing data from JSON and accessing to Database and sending answers to Client
    def dataReceived(self, data):
        print(data)
        try:
            parsed_json = json.loads(data)
            print parsed_json

            #########USERANSWER
            #GET
            if(parsed_json['ENTITY'] == 'USERANSWER'):
                if(parsed_json['COMMAND'] == 'GET'):
                    id = parsed_json['ID']
                    if(id is None):
                        return
                        #get all userAnswers
                    else:
                        #get userAnswer with id
                        ua = self.myDB.getUserAnswer(id)
                        self.writeJSONToClient(ua.tojson())


            # SIGNING UP
            elif (parsed_json['command'] == 'signup'):
                user = self.myDB.getUserByName(parsed_json['username'])
                if (user == None):
                    new_user = User(username=parsed_json['username'], password=parsed_json['password'],
                                    email=parsed_json['email'],
                                    rating=4000, wallpaper_image_name='wallpaper_default',
                                    avatar_image_name='avatar_default')
                    b_success = self.myDB.addUser(new_user)
                    # now we need to know, if new_user will be added to database and send a corresponding answer to client
                    if (b_success == True):
                        jsonData = json.dumps({"command": "signup", "result": "succeed"}, sort_keys=False)
                        self.writeJSONToClient(jsonData)
                    else:
                        jsonData = json.dumps(
                            {"command": "signup", "result": "failed", "reason": "failed to add user to DB"},
                            sort_keys=False)
                        self.writeJSONToClient(jsonData)
                else:
                    jsonData = json.dumps(
                        {"command": "signup", "result": "failed", "reason": "user already registered"}, sort_keys=False)
                    self.writeJSONToClient(jsonData)

            # SIGNING IN
            elif (parsed_json['command'] == 'signin'):
                user = self.myDB.getUserByName(parsed_json['username'])
                if (user == None):
                    jsonData = json.dumps({"command": "signin", "result": "failed", "reason": "user doesn't exist"},
                                          sort_keys=False)
                    self.writeJSONToClient(jsonData)
                else:
                    if (parsed_json['password'] == user.password):
                        jsonData = json.dumps({"command": "signin", "result": "succeed"}, sort_keys=False)
                        self.writeJSONToClient(jsonData)
                        print(jsonData)
                    else:
                        jsonData = json.dumps({"command": "signin", "result": "failed", "reason": "wrong password"},
                                              sort_keys=False)
                        self.writeJSONToClient(jsonData)

            # SYNCHRONIZE QUESTIONS
            elif parsed_json['command'] == 'synchronize_questions':
                width = parsed_json['question_image_width']
                questions_IDs = parsed_json['questions_IDs']
                remove_questions_IDs = self.myDB.questionsIDsToRemove(questions_IDs)
                add_questions = list()
                _add_questions = self.myDB.questionsToAdd(questions_IDs)
                for q in _add_questions:
                    add_questions.append(q.full_columnitems(width=width))

                dictQuestions = {"remove_questions_IDs":remove_questions_IDs, "add_questions":add_questions}
                jsonData = json.dumps({"command": "synchronize_questions", "questions": dictQuestions})
                self.writeJSONToClient(jsonData)

            # FIND MATCH
            elif parsed_json["command"] == 'find_match':
                username = parsed_json['player_name']
                user = self.myDB.getUserByName(username)
                if None != user:
                    # unique, not started matches with distinct initiator
                    count = self.myDB.notStartedMatchesCountWithUniqueInitiator(user)
                    print("count = " + str(count))
                    if count >= MATCHES_MAX_COUNT:
                        # finding closest rating match
                        m = self.myDB.findMatchForUser(user)
                    else:
                        # creating new match
                        m = self.myDB.createNewMatchWithUser(user)
                    session.commit()

                else:
                    print('no such user: ' + username)


            # # GET USER INFO
            # elif (parsed_json['command'] == 'getUserInfo'):
            #     user = self.myDB.getUserByName(parsed_json['username'])
            #     if (user == None):
            #         jsonData = json.dumps(
            #             {"command": "getUserInfo", "result": "failed", "reason": "no such user in database"},
            #             sort_keys=False)
            #         self.writeJSONToClient(jsonData)
            #     else:
            #         strJSON = json.dumps({"command": "getUserInfo", "result": "succeed", "user": user.tojson()},
            #                              sort_keys=False)
            #         print(strJSON)
            #         self.writeJSONToClient(strJSON)
            #
            # # GET PLAYER_INFO
            # elif (parsed_json['command'] == 'getPlayerInfo'):
            #     self.sendPlayerInfo(parsed_json['username'])
            #
            # # POST USER ANSWER
            # elif (parsed_json['command'] == 'postUserAnswer'):
            #     print(parsed_json)
            #     userAnswer = UserAnswer()
            #     userAnswer = userAnswer.fromJSON(parsed_json['userAnswer'])
            #     self.myDB.addUserAnswer(userAnswer)
            #
            # # UPDATE ROUND
            # elif (parsed_json['command'] == 'update_round'):
            #     roundDict = parsed_json['round']
            #     roundID = roundDict['ID']
            #     roundThemeID = roundDict['theme']
            #     t = session.query(Theme).filter(Theme.id == roundThemeID).one()
            #     r = session.query(Round).filter(Round.id == roundID).one()
            #     r.theme = t
            #     # CLIENT (0-NOT_STARTED, 1-FINISHED, 2-TIME_ELAPSED, 3-PLAYER_ASWERING, 4-OPPONENT_ANSWERING, 5-PLAYER_REPLYING, 6-OPPONENT_REPLYING)
            #     # SERVER (0-NOT_STARTED, 1-FINISHED, 2-TIME_ELAPSED, 3-ASWERING, 4-REPLYING)
            #     if roundDict['round_state'] == 3 or roundDict['round_state'] == 4:
            #         r.state = 3
            #     elif roundDict['round_state'] == 5 or roundDict['round_state'] == 6:
            #         r.state = 4
            #     else:
            #         r.state = roundDict['round_state']
            #     roundQuestionsIDs = roundDict['questions']
            #     for i in roundQuestionsIDs:
            #         q = session.query(Question).filter(Question.id == i).one()
            #         r.questions.append(q)
            #     session.commit()
            #
            # # UPDATE MATCH
            # elif (parsed_json['command'] == 'update_match'):
            #     print(parsed_json)
            #     matchDict = parsed_json['match']
            #     matchID = matchDict['ID']
            #     winnerID = matchDict['winnerID']
            #     matchState = matchDict['state']
            #
            #     m = session.query(Match).filter(Match.id == matchID).one()
            #     m.state = matchState



            else:
                raise FailedFormatException("couldn't get command")

            # sending answer to client, that message recieved
            what_command = parsed_json['command']
            jsonData = json.dumps({"command": "command_recieved", "what_command": what_command}, sort_keys=False)
            self.writeJSONToClient(jsonData)

        except FailedFormatException as e:
            print "Clint-Server format error: ", e.value
        except ValueError as e:
            print e.args[0]


factory = Factory()
factory.clients = []
factory.protocol = DotaProtocol
print "listening at port 1536"
reactor.listenTCP(1536, factory)
reactor.run()
