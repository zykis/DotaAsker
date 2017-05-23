# DotaAsker

# 1. Client
# 1.1 Getting repository

  pod install --verbose

# 2. Server
# 2.1 install python and pip

  sudo apt-get install python python-pip

# 2.2 install & activate virtual environment

  pip install virtualenv 
  cd DotaAsker/server/
  virtualenv flask
  source flask/bin/activate
  
# 2.3 install python depencies

  pip install -r requirements.txt
  
# 2.4 run server

  ./run.py
  
# 2.5 example
  127.0.0.1:5000/users/1
