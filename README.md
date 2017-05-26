# DotaQuiz
[![N|Solid](http://i.imgur.com/PRajQSy.png)](https://ibb.co/jbi0TF)

### Description
> Dota Quiz - an opportunity to increase your skill level in Dota-2, by collecting knowledge about internal game mechanics and stats.
Find an opponent, answer questions, increase your fundamentials and as a result, your in-game MMR.

### Build
#### Server
```sh
# install python and python package manager
sudo apt-get install python python-pip

# install virtual environment manager
pip install virtualenv 

# create virtual environment
cd DotaAsker/server/ 
virtualenv flask 

# start virtual environment
source flask/bin/activate
```
#### Client
```sh
# install dependencies
pod install --verbose
```

### Usage
#### Run local server
```sh
# start virtual environment
cd DotaAsker/server
source flask/bin/activate
# start server
./runLocalTestServer.py
```

### Run tests
```sh
# start virtual environment
cd DotaAsker/server
source flask/bin/activate
# run tests
./tests.py
```