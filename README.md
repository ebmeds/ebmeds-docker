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

The ELK stack used for logging needs to mount a few directories from the host into the containers:

* `./data` is where the Elasticsearch database will be stored.
* `./logstash/config` and `./logstash/pipeline` contains the configuration for Logstash, the pipeline config being the more important one for customizing operation.
* `./kibana/config` holds the Kibana configuration. We run without X-Pack since it's a paid service (this goes for the whole ELK stack).
