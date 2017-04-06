# ebmeds-docker
Repo that gathers EBMeDS microservices, makes a Docker Swarm, configures and launches them.

## Usage
We assume that the Docker images `engine` and `api-gateway` are already built and available on the machine. And that docker works!

```
$ npm run docker:init    # init docker swarm if not already running
$ npm run docker:start
```

To stop:
```
$ npm run docker:stop     # stop the services
$ npm run docker:deinit   # stop the swarm, not needed in most cases 
```

Per default `api-gateway` listens on port 3001 and `engine` on 3002. Environment variables can be set per service in the `config` directory.
