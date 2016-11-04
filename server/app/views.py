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
from app.models import Match, MATCH_RUNNING, MATCH_FINISHED, MATCH_TIME_ELAPSED, UserAnswer, Round
from app import models
from marshmallow import pprint

auth = HTTPBasicAuth()

@app.route('/users/<int:id>', methods=['GET'])
def get_user(id):
    user = User.query.get(id)
    if not user:
        abort(400)
    schema = UserSchema(exclude=('matches', 'friends'))
    res = schema.dumps(user)
    if not res.errors:
        return jsonify({'user' : res.data})
    else:
        # TODO: Sending server errors to client
        abort(500)

@app.route('/userAnswers', methods=['POST'])
def post_userAnswer():
    uaDict = request.data
    schema = UserAnswerSchema()
    ua = schema.loads(uaDict)[0]
    db.session.add(ua)
    db.session.commit()
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
    rNew.next_move_user_id = r['next_move_user']['id']
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
            return False
    g.user = user
    return True


@app.route('/token')
@auth.login_required
def get_auth_token():
    token = g.user.generate_auth_token()
    return jsonify({ 'token': token.decode('ascii') })
