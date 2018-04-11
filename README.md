# ebmeds-docker
Repo that gathers EBMeDS microservices, makes a Docker Swarm, configures and launches them.

## Installation

### Install Docker
The installation instructions can be found on e.g. [Docker's site](https://www.docker.com). We support version 1.12+.

### Download this repository
Download the zip file from Github (the "Clone or download" button) or preferrably, if you have Git installed, run the command:

```
git clone https://github.com/ebmeds/ebmeds-docker.git
```

### Login to quay.io and pull the required images
The entire system is run in Docker, where each component has its own Docker container. The version of this container is also the same as the version of the contained component.

Get/update the images by running the shell script

```
sh get-images.sh
```

Which by default will ask you for your quay.io username and password. If you want to automate the process, the script also checks DOCKER_LOGIN and DOCKER_PASSWORD for the information, so e.g. this works:

```
DOCKER_LOGIN=duodecim+example DOCKER_PASSWORD=somepassword sh get-images.sh
```

By default the script gets the latest stable version of the software, to use a specific version give the version as an argument to the script:

```
sh get-images.sh 2.0.0
```

It is also possible to use the version `dev` which is the current unstable development version. This is not recommended.

## Usage (Docker v1.13+)
For simply getting up and running, after having run the `get-images.sh` script, do the following:

```
sh start.sh
# the service takes a while to start, and is then usable on port 3001
sh stop.sh
```

For more advanced usage, e.g. multi-node clusters, refer to the [Docker documentation](https://docs.docker.com/)

## Usage (Docker v1.12)
The oldest supported version of Docker does not have support for Docker Compose files when used together with Docker Swarm. Therefore the command `sh start.sh` will not work, and the `docker-compose.yml` file must be transformed into e.g. shell scripts that set up the services manually. For example, starting the `api-gateway` service manually can look something like this:

```
docker service create --name api-gateway -e LISTEN_PORT=3001 -e ENGINE_URL=http://engine:3002/dss.asp?mode=test --network ebmedsnet --publish 3001:3001 --replicas=3 --update-delay 10s --update-parallelism 1 api-gateway
```

Before this the swarm must be initialized and the network ebmedsnet created (in this example). Note that the environment variables used in this example are the ones found in `api-gateway/config.env`.

Please refer to the [Docker documentation](https://docs.docker.com/) to understand how to convert the `docker-compose.yml` file to command line commands.

## Configuration

Per default `api-gateway` listens on port 3001 and is the only access point to the entire swarm. Environment variables can be set per service in the `<image-name>/config.env` file.

## Data storage

The ELK stack used for logging needs to mount a few directories from the host into the containers. Some mount points are only read, i.e. do not need write permissions on the host file system, while others do.

### Read-only mount points

* `./logstash/config` and `./logstash/pipeline` contains the configuration for Logstash, the pipeline config being the more important one for customizing operation.
* `./kibana/config` holds the Kibana configuration. We run without X-Pack since it's a paid service (this goes for the whole ELK stack).

### Read-write mount points

* `./data` is where the Elasticsearch database will be stored.
* `./logstash/queue` is where logstash saves in-transit messages that are not yet saved to Elasticsearch

### File permissions

The file permission scheme can be confusing. Docker containers share the Linux kernel with the host operating system. The default user inside a Docker container is user ID 1000, so user ID 1000 on the host needs the proper read/write permissions on the mount points above. See e.g. [the Elasticsearch Docker documentation](https://www.elastic.co/guide/en/elasticsearch/reference/current/docker.html) for examples how to solve this in other ways.

## Advanced usage

There are many advanced features of Docker that can be used to make the service more failsafe. This mostly applies to how the data in the Elastic stack is stored and backed up. Please refer to the Elastic stack documentation for details on this.

## Verifying the installation

TODO