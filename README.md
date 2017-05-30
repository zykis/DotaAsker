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

# install dependencies
pip install -r requirements.txt
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

#### Run tests
```sh
# start virtual environment
cd DotaAsker/server
source flask/bin/activate
# run tests
./tests.py
```

### Deploy
```sh
# TODO
```

[![N|Solid](https://pp.userapi.com/c637621/v637621025/3fb06/BYHGuUxR7D0.jpg)]
[![N|Solid](https://pp.userapi.com/c637621/v637621025/3fb10/U7e4eBSKY0I.jpg)]
[![N|Solid](https://pp.userapi.com/c637621/v637621025/3fb1a/QZHBS70erMM.jpg)]
[![N|Solid](https://pp.userapi.com/c637621/v637621025/3fb24/WN2h35hjtH4.jpg)]
[![N|Solid](https://pp.userapi.com/c637621/v637621025/4068b/rmvwaM7Y3Ys.jpg)]
