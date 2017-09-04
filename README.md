# ebmeds-docker
Repo that gathers EBMeDS microservices, makes a Docker Swarm, configures and launches them.

## Installation

### Install Docker
The installation instructions can be found on e.g. (Docker's site)[https://www.docker.com]. We support version 1.12+.

### Install Node.js (optional)
You will need Node.js to run the `npm` commands below. You can also run docker commands manually, removing the need for Node.

### Download this repository
Download the zip file from Github (the "Clone or download" button) or if you have Git installed, run the command:

```
git clone https://github.com/ebmeds/ebmeds-docker.git
```

### Login to quay.io and pull the required images
The built Docker images are stored in a repository on quay.io. Vendor organizations are provided with a login username and password. Developers with access to the EBMeDS Github repos can build the images locally. The images are tagged with the git branch name, i.e. the development version is tagged `dev` and the stable version `master` (and as a special case, also `latest`).

```
docker login -u="duodecim+exampleorg" -p="examplepassword" quay.io
docker pull quay.io/duodecim/ebmeds-api-gateway:latest
docker pull quay.io/duodecim/ebmeds-engine:latest
docker pull quay.io/duodecim/ebmeds-coaching:latest
docker pull docker.elastic.co/elasticsearch/elasticsearch:5.3.2
docker pull docker.elastic.co/kibana/kibana:5.3.2
docker pull docker.elastic.co/kibana/logstash:5.3.2
```

The images can be tagged for convenience:

```
docker pull quay.io/duodecim/ebmeds-api-gateway:latest api-gateway
docker pull quay.io/duodecim/ebmeds-engine:latest engine
docker pull quay.io/duodecim/ebmeds-coaching:latest coaching
docker pull docker.elastic.co/elasticsearch/elasticsearch:5.3.2 elasticsearch
docker pull docker.elastic.co/kibana/kibana:5.3.2 kibana
docker pull docker.elastic.co/kibana/logstash:5.3.2 logstash
```

## Usage (Docker v1.13+)
Assuming that the Docker images `engine` and `api-gateway` etc are already built and available on the machine (build them yourself or see above).

```
# In the directory this README is in:
$ npm run docker:init    # init Docker Swarm if not already running.
$ npm run docker:start
```

The `init` command gives an ID number that other nodes can use to join the cluster using `docker swarm join` (see the Docker documentation).

To stop:
```
$ npm run docker:stop     # stop the services
$ npm run docker:deinit   # stop the swarm, not needed in most cases
```

## Usage (Docker v1.12)
The oldest supported version of Docker does not have support for Docker Compose files when used together with Docker Swarm. Therefore the command `npm run docker:start` will not work, and the `docker-compose.yml` file must be transformed into e.g. shell scripts that sets up the services manually. For example, starting the `api-gateway` service manually can look something like this:

```
docker service create --name api-gateway -e LISTEN_PORT=3001 -e ENGINE_URL=http://engine:3002/dss.asp?mode=test --network ebmedsnet --publish 3001:3001 --replicas=3 --update-delay 10s --update-parallelism 1 api-gateway
```

Before this the swarm must be initialized and the network ebmedsnet created (in this example). Note that the environment variables used in this example are the ones found in `api-gateway/config.env`.

## Configuration

Per default `api-gateway` listens on port 3001 and is the only access point to the entire swarm. Environment variables can be set per service in the `<image-name>/config.env` file.

The ELK stack used for logging needs to mount a few directories from the host into the containers:

* `./data` is where the Elasticsearch database will be stored.
* `./logstash/config` and `./logstash/pipeline` contains the configuration for Logstash, the pipeline config being the more important one for customizing operation.
* `./kibana/config` holds the Kibana configuration. We run without X-Pack since it's a paid service (this goes for the whole ELK stack).

## Advanced usage

There are many advanced features of Docker that can be used to make the service more failsafe. This mostly applies to how the data in the ELK stack is stored and backed up. Please refer to the ELK documentation for details on this.

## Verifying the installation

TODO