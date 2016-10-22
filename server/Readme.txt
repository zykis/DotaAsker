cd ~/projects
git clone http://github.com/zykis/DotaAsker
cd ~/projects/DotaAsker/server
virtualenv flask
flask/bin/pip install Flask \
flask/bin/pip install flask-sqlalchemy \
flask/bin/pip install passlib \
flask/bin/pip install flask-httpauth \
flask/bin/pip install marshmallow \
flask/bin/pip install pytest
