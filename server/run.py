#!flask/bin/python
from app import app
<<<<<<< HEAD

if __name__ == '__main__':
    app.run()
=======
app.run(debug = True, host=app.config['HOST'])
>>>>>>> access data through realm
