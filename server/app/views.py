from app import app
from app import db
from app.models import User
from flask import abort, request, g, jsonify, url_for, make_response
from flask_httpauth import HTTPBasicAuth
from db_querys import Database_queries
from app.parsers.user_schema import UserSchema
from app.parsers.match_schema import MatchSchema
from app.parsers.user_answer_schema import UserAnswerSchema
from app.parsers.round_schema import RoundSchema
from app.parsers.question_schema import QuestionSchema
from app.models import Match, MATCH_RUNNING, MATCH_FINISHED, MATCH_TIME_ELAPSED, UserAnswer, Round, Question
from app import models
from marshmallow import pprint
from flask_mail import Message
import json
import random
import string
from app import mail
from sqlalchemy import desc

auth = HTTPBasicAuth()

# --------------------------------------------------------------
# USERS
# --------------------------------------------------------------
@app.route('/users/<int:id>', methods=['GET'])
def get_user(id):
    user = User.query.get(id)
    if not user:
        abort(400)
    schema = UserSchema()
    res = schema.dumps(user)
    if not res.errors:
        resp = make_response(res.data)
        resp.status_code = 200
        resp.mimetype = 'application/json'
        return resp
    else:
        abort(500)
        
@app.route('/users', methods = ['POST'])
def new_user():
    username = request.json.get('username')
    password = request.json.get('password')
    email = request.json.get('email')
    if username is None or password is None:
        abort(400) # missing arguments
    if User.query.filter_by(username = username).first() is not None:
        responce = jsonify({
            'status':409,
            'message':'User with name %s is already exists' % username
        })
        responce.status_code = 409
        return responce
    user = User(username = username)
    if email is not None:
        user.email = email
    user.hash_password(password)
    db.session.add(user)
    db.session.commit()
    return jsonify({ 'username': user.username }), 201, {'Location': url_for('get_user', id = user.id, _external = True)}

@app.route('/users', methods=['PUT'])
def put_user():
    schema = UserSchema(exclude=('matches', 'friends'))
    user = schema.loads(request.data).data
    db.session.add(user)
    db.session.commit()

    resp = make_response()
    resp.status_code = 200
    resp.mimetype = 'application/json'
    return resp


# --------------------------------------------------------------
# MATCHES
# --------------------------------------------------------------
@app.route('/matches', methods=['POST'])
def put_match():
    mData = request.data
    schema = MatchSchema()
    mDict = schema.loads(mData)[0]
    m = Match.query.get(mDict['id'])
    m.state = mDict['state']
    db.session.add(m)
    db.session.commit()
    res = schema.dumps(m)
    if not res.errors:
        resp = make_response(res.data)
        resp.mimetype = 'application/json'
        return resp
    else:
        # TODO: Sending server errors to client
        abort(500)        
        
        
# --------------------------------------------------------------
# ROUNDS
# --------------------------------------------------------------   
@app.route('/rounds/<int:id>', methods=['GET'])
def get_round(id):
    round = Round.query.get(id)
    if not round:
        abort(400)
    schema = RoundSchema()
    res = schema.dumps(round)
    if not res.errors:
        resp = make_response(res.data)
        resp.status_code = 200
        resp.mimetype = 'application/json'
        return resp
    else:
        abort(500)
        
@app.route('/rounds', methods=['PUT'])
def put_round():
    # [1] getting round
    schema = RoundAnswerSchema()
    round = schema.loads(request.data).data
    
    # [2] update in db
    db.session.add(round)
    db.session.commit()
    
    # [3] send reply to client
    resp = make_response(json.dumps({'status':'ok'}))
    resp.status_code = 200
    resp.mimetype = 'application/json'
    return resp


# --------------------------------------------------------------
# USER_ANSWERS
# --------------------------------------------------------------
@app.route('/user_answers/<int:id>', methods=['GET'])
def get_user_answer(id):
    userAnswer = UserAnswer.query.get(id)
    if not userAnswer:
        abort(400)
    schema = UserAnswerSchema()
    res = schema.dumps(userAnswer)
    if not res.errors:
        resp = make_response(res.data)
        resp.status_code = 200
        resp.mimetype = 'application/json'
        return resp
    else:
        abort(500)

@app.route('/user_answers', methods=['POST'])
def post_user_answer():
    uaDict = request.data
    schema = UserAnswerSchema()
    ua = schema.loads(uaDict)[0]
    # check if there is still space in round for userAnswer of this user
    userAnswersCount = len(UserAnswer.query.filter(UserAnswer.user_id == ua.user_id, UserAnswer.round_id == ua.round_id).all())
    if userAnswersCount >= 3:
        app.logger.critical("stack overflow for userAnswers in round: {} for user: {}".format(ua.round.__repr__(), ua.user.__repr__()))
        return
    # reset localy created ID. Server should autoincrement it
    ua.id = None
    db.session.add(ua)
    db.session.commit()

    # getting created UserAnswer with proper id
    uaNew = UserAnswer.query.filter(UserAnswer.user_id == ua.user_id, UserAnswer.round_id == ua.round_id, UserAnswer.question_id == ua.question_id).one()

    # check if round is over
    round = uaNew.round
    if len(round.user_answers) == 3:

        # change next_move_user
        u1 = round.next_move_user
        u2 = None
        for u in round.match.users:
            if u is not u1:
                u2 = u
        if not isinstance(u2, User):
            # app.logger.critical("can't find next move user for match: {}".format(round.match))
            app.logger.info("user for match is undefined yet")
        round.next_move_user = u2
        db.session.add(round)
        db.session.commit()

    elif len(round.user_answers) == 6:
        # check if match is over
        ua_count = 0
        for r in round.match.rounds:
            ua_count += len(r.user_answers)
        if ua_count == 36:
            round.match.finish()
            db.session.add(round.match)
            db.session.commit()

    res = schema.dumps(uaNew)
    if not res.errors:
        resp = make_response(res.data)
        resp.mimetype = 'application/json'
        return resp
    else:
        abort(500)
        
@app.route('/user_answers', methods=['PUT'])
def put_user_answer():
    # [1] getting userAnswer
    schema = UserAnswerSchema()
    userAnswer = schema.loads(request.data).data
    
    # [2] create in db
    db.session.add(userAnswer)
    db.session.commit()
    
    # [3] send reply to client
    resp = make_response(json.dumps({'status':'ok'}))
    resp.status_code = 200
    resp.mimetype = 'application/json'
    return resp


# --------------------------------------------------------------
# QUESTIONS
# --------------------------------------------------------------
@app.route('/questions/<int:id>', methods=['GET'])
def get_question(id):
    question = Question.query.get(id)
    if not question:
        abort(400)
    schema = QuestionSchema()
    res = schema.dumps(question)
    if not res.errors:
        resp = make_response(res.data)
        resp.status_code = 200
        resp.mimetype = 'application/json'
        return resp
    else:
        abort(500)
        
@app.route('/questions', methods=['POST', 'PUT'])
def put_question():
    # [1] getting question
    scheme = QuestionSchema()
    question = scheme.loads(request.data).data
    
    # [2] create in db
    db.session.add(question)
    db.session.commit()
    
    # [3] send reply to client
    resp = make_response(json.dumps({'status':'ok'}))
    resp.status_code = 200
    resp.mimetype = 'application/json'
    return resp


# --------------------------------------------------------------
# ANSWERS
# --------------------------------------------------------------
@app.route('/answers/<int:id>', methods=['GET'])
def get_answer(id):
    answer = Answer.query.get(id)
    if not answer:
        abort(400)
    schema = AnswerSchema()
    res = schema.dumps(answer)
    if not res.errors:
        resp = make_response(res.data)
        resp.status_code = 200
        resp.mimetype = 'application/json'
        return resp
    else:
        abort(500)
        
@app.route('/answers', methods=['POST', 'PUT'])
def post_question():
    schema = AnswerSchema()
    answer = schema.loads(request.data).data
    
    db.session.add(answer)
    db.session.commit()
    
    resp = make_response(json.dumps({'status':'ok'}))
    resp.status_code = 200
    resp.mimetype = 'application/json'
    return resp


# --------------------------------------------------------------
# THEMES
# --------------------------------------------------------------
@app.route('/theme/<int:id>', methods=['GET'])
def get_theme(id):
    theme = Theme.query.get(id)
    if not theme:
        abort(400)
        
    schema = ThemeSchema()
    res = schema.dumps(theme)
    
    if not res.errors:
        resp = make_response(res.data)
        resp.status_code = 200
        resp.mimetype = 'application/json'
        return resp
    else:
        abort(500)
        
@app.route('/theme', methods=['POST', 'PUT'])
def post_theme():
    schema = ThemeSchema()
    theme = schema.loads(request.data).data
    
    db.session.add(theme)
    db.session.commit()
    
    resp = make_response(json.dumps({'status':'ok'}))
    resp.status_code = 200
    resp.mimetype = 'application/json'
    return resp

        
# --------------------------------------------------------------
# CUSTOM
# --------------------------------------------------------------
@app.route('/statistic/<int:id>', methods=['GET'])
def get_statistic(id):
    user = User.query.get(id)
    recent_matches = []
    for m in user.matches:
        if m.state is not MATCH_RUNNING:
            recent_matches.append(m)
    user.matches = recent_matches

    if not user:
        abort(400)
    schema = UserSchema() # only recent matches
    res = schema.dumps(user)
    if not res.errors:
        resp = make_response(res.data)
        resp.status_code = 200
        resp.mimetype = 'application/json'
        return resp
    else:
        # TODO: Sending server errors to client
        abort(500)


@app.route('/generateTestData')
def generate_test_data():
    Database_queries.createTestData()
    return 'ok'


@app.route('/forgotPassword', methods=['POST'])
def send_new_password():
    username_or_email_dict = request.data
    username_or_email = json.loads(username_or_email_dict)['username_or_email']
    app.logger.info('{} forgot his password'.format(username_or_email))

    # if it's email, we'll try to find user with it
    if '@' not in username_or_email:
        user = User.query.filter(User.username==username_or_email).one_or_none()
    else:
        user = User.query.filter(User.email==username_or_email).one_or_none()


    if user is None:
        app.logger.info('{}: no such username or e-mail'.format(username_or_email))
        resp = make_response(json.dumps({'reason':'no such username or e-mail'}))
        resp.status_code = 400
        resp.mimetype = 'application/json'
        return resp

    email = user.email

    if email is None:
        app.logger.info('{} doesn\'t have an e-mail'.format(user.username))
        resp = make_response(json.dumps({'reason':'user have no email'}))
        resp.status_code = 400
        resp.mimetype = 'application/json'
        return resp

    newPassword = ''.join(random.SystemRandom().choice(string.ascii_uppercase + string.ascii_lowercase + string.digits) for _ in range(6))
    user.hash_password(newPassword)

    db.session.add(user)
    db.session.commit()

    app.logger.info('password generated: {}'.format(newPassword))

    msg = Message("DotaAsker",
                  sender="zykis39@gmail.com",
                  recipients=[email])
    msg.body = "Dear, {}. Your new password is: {}".format(user.username, newPassword)
    mail.send(msg)
    app.logger.debug('message with new password has sent to: {}'.format(email))

    resp = make_response(json.dumps({'status':'ok'}))
    resp.status_code = 200
    resp.mimetype = 'application/json'
    return resp


@app.route('/sendFriendRequest', methods=['POST'])
@auth.login_required
def sendFriendRequest():
    user_from = g.user
    rdata = request.json
    user_to_id = rdata['to_id']
    user_to = User.query.get(user_to_id)
    if user_from.isFriend(user_to) or user_from.isPending(user_to):
        resp = make_response(json.dumps({'result':'ok'}))
        resp.status_code = 200
        resp.mimetype = 'application/json'
        app.logger.debug('user already in friend list')
        return resp
    else:
        user_from.sendRequest(user_to)
        db.session.commit()
        resp = make_response(json.dumps({'result':'ok'}))
        resp.status_code = 200
        resp.mimetype = 'application/json'
        return resp

@app.route('/top100')
@auth.login_required
def top100():
    user = g.user
    # [1] Getting all users, sorted by MMR. Descending order
    users = User.query.order_by(desc(User.mmr)).all()

    # [2] Getting index of our user in this array
    i = users.index(user)
    app.logger.info('Our user on {} place'.format(i))

    # [3] Fill dictionary, with 50 users higher and 49 users lower current one.
    firstIndex = max(i - 50, 0)
    lastIndex = min(i + 50, len(users))

    users_dict = dict()

    for ind in range(firstIndex, lastIndex):
        schema = UserSchema(exclude=('matches', 'friends'))
        user_dict = schema.dumps(users[ind]).data
        users_dict.__setitem__(ind + 1, user_dict)

    # [4] Also add 1-3 placed guys if not already presented
    resp_json = json.dumps(users_dict)
    resp = make_response(resp_json)
    resp.mimetype = 'application/json'
    return resp

@app.route('/surrend', methods=['POST'])
@auth.login_required
def surrend():
    surrender = g.user
    match_id = request.json['match_id']
    match = Match.query.get(match_id)
    match.surrendMatch(surrender = surrender)
    resp = make_response(json.dumps({'status':'ok'}))
    resp.status_code = 200
    resp.mimetype = 'application/json'
    return resp

@auth.error_handler
def auth_error():
    responce = jsonify({
            'status':409,
            'message':'Wrong username or password'
        })
    responce.status_code = 409
    return responce



@app.route('/findMatch', methods = ['GET'])
@auth.login_required
def find_match():
    m = Database_queries.findMatchForUser(g.user)
    if isinstance(m, Match):
        m_schema = MatchSchema()
        res = m_schema.dumps(m)
        resp = make_response(res.data)

        resp.mimetype = 'application/json'
        return resp
    else:
        abort(404)


@auth.verify_password
def verify_password(username_or_token, password):
    # first try to authenticate by token
    user = User.verify_auth_token(username_or_token)
    if not user:
        # try to authenticate with username/password
        unicodeUsername = username_or_token.decode('utf-8')
        user = User.query.filter_by(username = unicodeUsername).first()
        if not user or not user.verify_password(password):
            app.logger.info('user authorize error')
            return False
    g.user = user
    app.logger.info('user authorized successfully')
    return True


@app.route('/token')
@auth.login_required
def get_auth_token():
    token = g.user.generate_auth_token()
    return jsonify({ 'token': token.decode('ascii') })
