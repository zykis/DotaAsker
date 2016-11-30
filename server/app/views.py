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

@app.route('/questions', methods=['POST'])
def post_question():
    # [1] getting question
    scheme = QuestionSchema()
    question = scheme.loads(request.data).data
    
    # [2] create in db
    db.session.add(question)
    db.session.commit()
    
    # [2.1] check created question
    print(question.text)
    for a in question.answers:
        print a.text
    
    # [3] send reply to client
    resp = make_response(json.dumps({'status':'ok'}))
    resp.status_code = 200
    resp.mimetype = 'application/json'
    return resp

@app.route('/users/<int:id>', methods=['GET'])
def get_user(id):
    user = User.query.get(id)
    if not user:
        abort(400)
    schema = UserSchema(exclude=('matches', 'friends'))
    res = schema.dumps(user)
    if not res.errors:
        resp = make_response(res.data)
        resp.status_code = 200
        resp.mimetype = 'application/json'
        return resp
    else:
        # TODO: Sending server errors to client
        abort(500)


@app.route('/user', methods=['POST'])
def update_user():
    schema = UserSchema(exclude=('matches', 'friends'))
    user = schema.loads(request.data).data
    db.session.add(user)
    db.session.commit()

    resp = make_response()
    resp.status_code = 200
    resp.mimetype = 'application/json'
    return resp


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

@app.route('/userAnswers', methods=['POST'])
def post_userAnswer():
    # tricky one. We could expect empty userAnswers with answer_id = 0. If so, we just create them
    # If answer_id contains in data, we need to update existing ones
    uaDict = request.data
    schema = UserAnswerSchema()
    ua = schema.loads(uaDict)[0]
    db.session.add(ua)
    db.session.commit()

    # hmmmm...
    if ua.answer_id == 0:
        uaNew = UserAnswer.query.get(ua.id)
    else:
        uaNew = UserAnswer.query.filter(UserAnswer.user_id == ua.user_id, UserAnswer.round_id == ua.round_id, UserAnswer.answer_id == ua.answer_id).one()
    res = schema.dumps(uaNew)
    if not res.errors:
        resp = make_response(res.data)
        resp.mimetype = 'application/json'
        return resp
    else:
        # TODO: Sending server errors to client
        abort(500)

@app.route('/rounds', methods=['POST'])
def put_round():
    rDict = request.data
    schema = RoundSchema()
    r = schema.loads(rDict)[0]
    rNew = Round.query.get(r['id'])
    if r.get('next_move_user', False):
        rNew.next_move_user_id = r['next_move_user'].id
    if r.get('selected_theme', False):
        rNew.selected_theme_id = r['selected_theme']['id']
    db.session.add(rNew)
    db.session.commit()
    res = schema.dumps(rNew)
    if not res.errors:
        resp = make_response(res.data)
        resp.mimetype = 'application/json'
        return resp
    else:
        # TODO: Sending server errors to client
        abort(500)

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

@app.route('/finishMatch', methods=['POST'])
def finish_match():
    mData = request.data
    schema = MatchSchema()
    mDict = schema.loads(mData)[0]
    m = Match.query.get(mDict['id'])
    m = m.finish()
    res = schema.dumps(m)
    if not res.errors:
        resp = make_response(res.data)
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

@app.route('/MainViewController')
@auth.login_required
def get_main_view_controller():
    user = g.user
    schema = UserSchema()
    res = schema.dumps(user)
    if not res.errors:
        resp = make_response(res.data)
        resp.mimetype = 'application/json'
        return resp
    else:
        return jsonify(res.errors)


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
