###############################################################################
#
# The MIT License (MIT)
#
# Copyright (c) Tavendo GmbH
#
# Permission is hereby granted, free of charge, to any person obtaining a copy
# of this software and associated documentation files (the "Software"), to deal
# in the Software without restriction, including without limitation the rights
# to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
# copies of the Software, and to permit persons to whom the Software is
# furnished to do so, subject to the following conditions:
#
# The above copyright notice and this permission notice shall be included in
# all copies or substantial portions of the Software.
#
# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
# IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
# FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
# AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
# LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
# OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
# THE SOFTWARE.
#
###############################################################################

from autobahn.twisted.websocket import WebSocketServerFactory
from autobahn.twisted.websocket import WebSocketServerProtocol

from parsers.parser import *

get_class = lambda x: globals()[x]

class MyServerProtocol(WebSocketServerProtocol):

    def onConnect(self, request):
        print("Client connecting: {0}".format(request.peer))

    def onOpen(self):
        print("WebSocket connection open.")

    def onMessage(self, payload, isBinary):
        try:
            if isBinary:
                print("Binary message received: {0} bytes".format(len(payload)))
            else:
                print("Text message received: {0}".format(payload.decode('utf8')))
                dict = json.loads(payload.decode('utf8'))

                #################### SIGNIN ######################
                if(dict['COMMAND'] == 'SIGNIN'):
                    user = db.getUserByName(dict['USERNAME'])
                    if (user == None):
                        jsonData = json.dumps({"COMMAND": "SIGNIN", "RESULT": "FAILED", "REASON": "user doesn't exist"},
                                              sort_keys=False)
                        reply = jsonData
                    else:
                        if (dict['PASSWORD'] == user.password):
                            jsonData = json.dumps({"COMMAND": "SIGNIN", "RESULT": "SUCCEED"}, sort_keys=False)
                        else:
                            jsonData = json.dumps({"COMMAND": "SIGNIN", "RESULT": "FAILED", "REASON": "wrong password"},
                                                  sort_keys=False)
                        reply = jsonData

                #################### SINGUP ######################
                elif(dict['COMMAND'] == 'SIGNUP'):
                    user = db.getUserByName(dict['USERNAME'])
                    if (user == None):
                        new_user = User(username=dict['USERNAME'], password=dict['PASSWORD'],
                                        email=dict['EMAIL'],
                                        rating=4000, wallpaper_image_name='wallpaper_default',
                                        avatar_image_name='avatar_default')
                        b_success = self.myDB.addUser(new_user)
                        # now we need to know, if new_user will be added to database and send a corresponding answer to client
                        if (b_success == True):
                            jsonData = json.dumps({"COMMAND": "SIGNUP", "RESULT": "SUCCEED"}, sort_keys=True)
                            self.writeJSONToClient(jsonData)
                        else:
                            jsonData = json.dumps(
                                {"COMMAND": "SIGNUP", "RESULT": "FAILED", "REASON": "failed to add user to DB"},
                                sort_keys=True)
                            reply = jsonData
                    else:
                        jsonData = json.dumps(
                            {"COMMAND": "SIGNUP", "RESULT": "FAILED", "REASON": "user already registered"}, sort_keys=True)
                        reply = jsonData

                ###################### FIND MATCH ##################################
                elif (dict['COMMAND'] == 'FIND_MATCH'):
                        username = dict['PLAYER_NAME']
                        user = db.getUserByName(username)
                        if user is not None:
                            # unique, not started matches with distinct initiator
                            count = db.notStartedMatchesCountWithUniqueInitiator(user)
                            print("count = " + str(count))
                            if count >= MATCHES_MAX_COUNT:
                                # finding closest rating match
                                m = db.findMatchForUser(user)
                            else:
                                # creating new match
                                m = db.createNewMatchWithUser(user)
                            reply = json.dumps(m.tojson())

                        else:
                            reply = json.dumps({"COMMAND":"ERROR", "REASON":"NO MATCH FOUND"})

                ##################### GET_USER_BY_USERNAME ########################
                elif (dict['COMMAND'] == 'GET_USER_BY_USERNAME'):
                    user = db.getUserByName(dict['USERNAME'])
                    if user is not None:
                        reply = json.dumps(user.tojson())
                    else:
                        reply = json.dumps({"COMMAND":"ERROR", "REASON":"NO USER WITH USERNAME = {0}".format(dict['USERNAME'])})

                ##################### GET ########################
                elif(dict['COMMAND'] == 'GET'):
                    className = dict['ENTITY']
                    className = className.lower()
                    className = className.title()
                    cls = get_class(className)

                    if dict['ID'] is not None:
                        entity = db.get(cls, dict['ID'])
                    else:
                        entity = db.get(cls, None)

                    if isinstance(entity, list):
                        entityList = list()
                        for e in entity:
                            entityList.append(e.tojson())
                        reply = json.dumps(entityList)
                    else:
                        if entity is not None:
                            reply = json.dumps(entity.tojson())
                        else:
                            reply = json.dumps("NO SUCH ENTITY")

                ##################### UPDATE ########################
                elif(dict['COMMAND'] == 'UPDATE'):
                    className = dict['ENTITY']
                    className = className.lower()
                    className = className.title()
                    cls = get_class(className)
                    obj = Parser.fromJSON(dict['OBJECT'], cls)
                    #update in DB, return, encode and send
                    obj = db.update(obj)
                    encoded = Parser.toJSON(obj, cls)
                    reply = encoded

                self.sendMessage(reply.encode('utf8'), False)
        except ValueError as e:
            print e.args[0]

    def onClose(self, wasClean, code, reason):
        print("WebSocket connection closed: {0}".format(reason))


if __name__ == '__main__':

    import sys

    from twisted.python import log
    from twisted.internet import reactor

    log.startLogging(sys.stdout)

    factory = WebSocketServerFactory(u"ws://127.0.0.1:1536", debug=False)
    factory.protocol = MyServerProtocol
    # factory.setProtocolOptions(maxConnections=2)
    db = Database()
    reactor.listenTCP(1536, factory)
    reactor.run()