from app import app
from app import db
from app.models import User
from flask import abort, request, g, jsonify, url_for, make_response
from flask_httpauth import HTTPBasicAuth
from db_querys import Database_queries
from app.entities.parsers.user_schema import UserSchema
from app.entities.parsers.match_schema import MatchSchema
from app.models import MATCH_FINISHED, MATCH_TIME_ELAPSED, Match

auth = HTTPBasicAuth()

@app.route('/users/<int:id>', methods=['GET'])
def get_user(id):
    user = User.query.get(id)
    if not user:
        abort(400)
    schema = UserSchema(exclude=('current_matches', 'recent_matches', 'friends'))
    res = schema.dumps(user)
    if not res.errors:
        return jsonify({'user' : res.data})
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
    user.current_matches = []
    user.recent_matches = []
    for m in user.matches:
        if m.state == MATCH_FINISHED or m.state == MATCH_TIME_ELAPSED:
            user.recent_matches.append(m)
        else:
            user.current_matches.append(m)
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