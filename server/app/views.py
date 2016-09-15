from app import app
from app import db
from app.models import User
from flask import abort, request, g, jsonify, url_for
from flask_httpauth import HTTPBasicAuth
from db_querys import Database_queries

auth = HTTPBasicAuth()

@app.route('/users/<int:id>', methods=['GET'])
def get_user(id):
    user = User.query.get(id)
    if not user:
        abort(400)
    return jsonify({'user': user.tojson()})

@app.route('/generateTestData')
def generate_test_data():
    Database_queries.createTestData()
    return 'ok'

@app.route('/MainViewController/<int:id>')
def get_main_view_controller(id):
    user = User.query.get(int(id))
    friends = []
    matches = []
    for u in user.friends():
        friends.append(u.tojson())
    user.friends = friends
    for m in user.matches:
        players = m.users
        for p in players:
            if(p.id != user.id):
                opponent = p
                app.logger.critical('No opponent found for match: %s' % m.__repr__())
                assert opponent is not None
        m.opponent = opponent
        matches.append(m)
    user.matches = matches
    return jsonify(user = user.tojson())


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