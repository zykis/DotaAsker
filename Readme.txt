cd ~/projects
git clone http://github.com/zykis/DotaAsker

# server
cd ~/projects/DotaAsker/server
virtualenv flask
flask/bin/pip install Flask \
flask/bin/pip install flask-sqlalchemy \
flask/bin/pip install passlib \
flask/bin/pip install flask-httpauth \
flask/bin/pip install marshmallow \
flask/bin/pip install pytest \
flask/bin/pip install Flask-Script \
flask/bin/pip install sqlalchemy-migrate \
flask/bin/pip install Flask-Mail

# client
cd ~/projects/DotaAsker/client
pod install
# disabling XCode 8 debug gurbage
# In Product>>Scheme>>Edit Scheme...>>Run add the following environment variable: Name:OS_ACTIVITY_MODE, Value: disable
