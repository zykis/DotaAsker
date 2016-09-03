from app import app
from app import db
from app.models import User
from flask import abort, request, g, jsonify, url_for
from flask_httpauth import HTTPBasicAuth

auth = HTTPBasicAuth()

@app.route('/users/<int:id>', methods=['GET'])
def get_user(id):
    user = User.query.get(id)
    if not user:
        abort(400)
    return jsonify({'username': user.username})

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
            'message':'User with name %s is already exists' % username,
        })
        responce.status_code = 409
        return responce
    user = User(username = username, email=email)
    user.hash_password(password)
    db.session.add(user)
    db.session.commit()
    return jsonify({ 'username': user.username }), 201, {'Location': url_for('get_user', id = user.id, _external = True)}

@auth.verify_password
def verify_password(username_or_token, password):
    # first try to authenticate by token
    user = User.verify_auth_token(username_or_token)
    if not user:
        # try to authenticate with username/password
        user = User.query.filter_by(username = username_or_token).first()
        if not user or not user.verify_password(password):
            return False
    g.user = user
    return True

@app.route('/token')
@auth.login_required
def get_auth_token():
    token = g.user.generate_auth_token()
    return jsonify({ 'token': token.decode('ascii') })

@app.route('/login', methods=['GET', 'POST'])
def login():
    if request.method == 'POST':
        username = request.form.get('username')
        password = request.form.get('password')
        user = User.query.filter(User.username == username).one()
        if not isinstance(user, User):
            return jsonify(result='fail', reason='no such user')

        elif user.password == password:
            g.user = user
        else:
            return jsonify(result='fail', reason='wrong password for user: ' + username)

        return jsonify(result='success')