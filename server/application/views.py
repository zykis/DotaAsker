from application import app
from application import db
from application.models import User
from flask import abort, request, g, jsonify, url_for, make_response
from flask_httpauth import HTTPBasicAuth
from db_querys import Database_queries
from application.parsers.user_schema import UserSchema
from application.parsers.match_schema import MatchSchema
from application.parsers.user_answer_schema import UserAnswerSchema
from application.parsers.round_schema import RoundSchema
from application.parsers.question_schema import QuestionSchema
from application.models import Match, MATCH_RUNNING, MATCH_FINISHED, UserAnswer, Round, Question
from application import models
from marshmallow import pprint
from flask_mail import Message
import json
import random
import string
from application import mail
from sqlalchemy import desc

auth = HTTPBasicAuth()

@app.route('/', defaults={'path': ''})
@app.route('/<path:path>')
def catch_all(path):
    app.logger.debug("Client tried to connect to path: {}".format(path))
    return 'You want path: %s' % path

@app.route('/sendFriendRequest', methods=['POST'])
@auth.login_required
def sendFriendRequest():
    user_from = g.user
    rdata = request.json
    g.locale = request.headers['Accept-Language']
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
    g.locale = request.headers['Accept-Language']
    # [1] Getting all users, sorted by MMR. Descending order
    users = User.query.order_by(desc(User.mmr)).all()

    # [2] Getting index of our user in this array
    i = users.index(user)
    app.logger.info('Our user on {} place'.format(i))

    # [3] Fill dictionary, with 50 users higher and 49 users lower current one.
    firstIndex = max(i - 50, 0)
    lastIndex = min(i + 50, len(users))

    users_dict = dict()

    schema = UserSchema(exclude=('matches', 'friends'))
    for ind in range(firstIndex, lastIndex):
        user_dict = schema.dumps(users[ind]).data
        users_dict[ind + 1] = user_dict

    # [4] Also add 1-3 placed guys if not already presented
    resp_json = json.dumps(users_dict)
    resp = make_response(resp_json)
    resp.mimetype = 'application/json'
    return resp

@app.route('/surrend', methods=['POST'])
@auth.login_required
def surrend():
    surrender = g.user
    g.locale = request.headers['Accept-Language']
    match_id = request.json['match_id']
    match = Match.query.get(match_id)
    match.surrendMatch(loser=surrender)
    match_schema = MatchSchema()
    resp = make_response(match_schema.dumps(match))
    resp.status_code = 200
    resp.mimetype = 'application/json'
    return resp

@app.route('/questions', methods=['POST'])
def post_question():
    g.locale = request.headers['Accept-Language']
    # [1] getting question
    scheme = QuestionSchema()
    question = scheme.loads(request.data).data
    app.logger.info(question)
    app.logger.info(question.__repr__())
    
    # [2] create in db
    db.session.add(question)
    db.session.commit()
    
    # [2.1] check created question
    # app.logger.info("question submitted: {}".format(getattr(question, 'text_' + g.locale)))
    # for a in question.answers:
    #     app.logger.info("-{}".format(a))

    # [3] send reply to client
    resp = make_response()
    resp.status_code = 200
    resp.mimetype = 'application/json'
    return resp

#@app.route('/users/<int:id>', methods=['GET'])
#def get_user(id):
#    g.locale = request.headers['Accept-Language']
#    user = User.query.get(id)
#    if not user:
#        abort(400)
#    schema = UserSchema(exclude=('matches', 'friends'))
#    res = schema.dumps(user)
#    if not res.errors:
#        resp = make_response(res.data)
#        resp.status_code = 200
#        resp.mimetype = 'application/json'
#        return resp
#    else:
#        abort(500)


@app.route('/user', methods=['POST'])
def update_user():
    g.locale = request.headers['Accept-Language']
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
    g.locale = request.headers['Accept-Language']
    statistic = dict()
    q_res = db.engine.execute("SELECT * FROM user_date_mmr WHERE user_id = {}".format(id))
    for row in q_res:
        statistic[row['date']] = row['mmr']
    res = json.dumps(statistic)
    resp = make_response(res)
    resp.status_code = 200
    resp.mimetype = 'application/json'
    return resp

@app.route('/userAnswers', methods=['POST'])
def create_userAnswer():
    g.locale = request.headers['Accept-Language']
    uaDict = request.data
    schema = UserAnswerSchema()
    ua = schema.loads(uaDict)[0]
    app.logger.info("parsed useranswerID: {}, questionID: {}".format(ua.id, ua.question_id))
    # check if there is still space in round for userAnswer of this user
    userAnswersCount = len(UserAnswer.query.filter(UserAnswer.user_id == ua.user_id, UserAnswer.round_id == ua.round_id).all())
    if userAnswersCount >= 3:
        app.logger.critical("stack overflow for userAnswers in round: {} for user: {}".format(ua.round.__repr__(), ua.user.__repr__()))
        abort(505)
    # reset localy created ID. Server should autoincrement it
    ua.id = None
    db.session.add(ua)
    db.session.commit()

    # getting created UserAnswer with proper id
    uaNew = UserAnswer.query.filter(UserAnswer.user_id == ua.user_id, UserAnswer.round_id == ua.round_id, UserAnswer.question_id == ua.question_id).one_or_none()
    if uaNew is None:
        abort(410) # Gone
    app.logger.info("commited useranswerID: {}, questionID: {}".format(uaNew.id, uaNew.question_id))

    # check if round is over
    round = uaNew.round
    app.logger.debug("userAnswers count = {}".format(len(round.user_answers)))

    if len(round.user_answers) == 3:

        # change next_move_user
        u1 = round.next_move_user
        u2 = None
        for u in round.match.users:
            if u is not u1:
                u2 = u
        if not isinstance(u2, User):
            app.logger.debug("user for match is undefined yet")
        else:
            app.logger.debug("next move user changed to {}".format(u2.username.encode('utf-8')))

        round.next_move_user = u2
        round.match.updated_on = db.func.now()

        db.session.add(round)
        db.session.add(round.match)
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
        # TODO: Sending server errors to client
        abort(500)

@app.route('/rounds', methods=['POST'])
def put_round():
    g.locale = request.headers['Accept-Language']
    rDict = request.data
    schema = RoundSchema()
    r = schema.loads(rDict)[0]
    rNew = Round.query.get(r['id'])
    if rNew == None:
        resp = make_response(json.dumps({'reason':'no round to update with id: {} in database'.format(r['id'])}))
        resp.status_code = 410 # Gone
        resp.mimetype = 'application/json'
        return resp
    if r.get('next_move_user', False):
        rNew.next_move_user_id = r['next_move_user'].id
    if r.get('selected_theme', False):
        rNew.selected_theme_id = r['selected_theme'].id
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
    g.locale = request.headers['Accept-Language']
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
    g.locale = request.headers['Accept-Language']
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


@app.route('/createTestData')
def generate_test_data():
    g.locale = request.headers['Accept-Language']
    Database_queries.createTestData()
    return 'ok'


@app.route('/forgotPassword', methods=['POST'])
def send_new_password():
    g.locale = request.headers['Accept-Language']
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
    g.locale = request.headers['Accept-Language']
    g.locale = request.headers['Accept-Language']
    user = g.user
    schema = UserSchema()
    # schema.context['request'] = request
    res = schema.dumps(user)
    if not res.errors:
        resp = make_response(res.data)
        resp.mimetype = 'application/json'
        return resp
    else:
        return jsonify(res.errors)


@app.route('/users', methods = ['POST'])
def new_user():
    g.locale = request.headers['Accept-Language']
    username = request.json.get('username', None)
    password = request.json.get('password', None)
    email = request.json.get('email', None)
    # app.logger.debug("Signging up with username: {} password: {}".format(username.decode('utf-8'), password.decode('utf-8')))
    if (username is None) or (password is None):
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
    data = json.dumps
    resp = make_response()
    resp.status_code = 200
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
    g.locale = request.headers['Accept-Language']
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
