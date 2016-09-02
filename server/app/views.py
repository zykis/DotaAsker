from app import app
from app import models, db
from app.models import User
from flask import abort, request, g, jsonify
from app import lm
from flask_login import login_user, url_for

@app.route('/')
@app.route('/index')
def index():
    return "Hello, World!"

@app.route('/users<int:user_id>', methods=['GET'])
def getUser(user_id):
    user = models.User.query.get(user_id)
    if not isinstance(user, models.User):
        abort(404)
    return user.tojson()

@app.route('/users', methods = ['POST'])
def new_user():
    username = request.json.get('username')
    password = request.json.get('password')
    if username is None or password is None:
        abort(400) # missing arguments
    if User.query.filter_by(username = username).first() is not None:
        abort(400) # existing user
    user = User(username = username)
    user.hash_password(password)
    db.session.add(user)
    db.session.commit()
    return jsonify({ 'username': user.username }), 201, {'Location': url_for('get_user', id = user.id, _external = True)}

@app.route('/login', methods=['GET', 'POST'])
def login():
    if request.method == 'POST':
        username = request.form.get('username')
        password = request.form.get('password')
        user = models.User.query.filter(models.User.username == username).one_or_none()
        if not isinstance(user, models.User):
            return jsonify(result='fail', reason='no such user')

        elif user.password == password:
            login_user(user)
            g.user = user
        else:
            return jsonify(result='fail', reason='wrong password for user: ' + username)

        return jsonify(result='success')

@lm.user_loader
def load_user(user_id):
    return models.User.query.get(int(user_id))