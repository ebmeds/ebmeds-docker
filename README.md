# ebmeds-docker
Repo that gathers EBMeDS microservices as submodules and launches a Docker Swarm of them.

## Usage
```
# first-time checkout
$ npm install
$ git clone --recursive https://github.com/ebmeds/ebmeds-docker
# TODO: docker swarm commands here, use gulp
# Updates have happened in the submodules, e.g. in engine
$ git submodule update --recursive --remote
```

NOTE: DO NOT USE THIS REPO FOR COMMITTING CODE TO THE SUBMODULES. THIS IS FOR *DEPLOYMENT ONLY*.



