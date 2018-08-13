# ebmeds-docker
Repo that gathers EBMeDS microservices, makes a Docker Swarm, configures and launches them.

## Quick start

```
# As a non-root user
git clone https://github.com/ebmeds/ebmeds-docker.git
cd ebmeds-docker
chmod -R 700 .
chmod -R 750 ./elasticsearch ./kibana ./logstash
chmod -R 770 ./data ./logstash/queue
chgrp -R 1000 ./elasticsearch ./data ./logstash ./kibana

# You need the proper credentials here
DOCKER_LOGIN=duodecim+example DOCKER_PASSWORD=somePassword sh start.sh
```

## Installation

### Install Docker
The installation instructions can be found on e.g. [Docker's site](https://www.docker.com). We support version 1.13+.

### Download this repository
Download the zip file from Github (the "Clone or download" button) or preferrably, if you have Git installed, run the command:

```
git clone https://github.com/ebmeds/ebmeds-docker.git
```

## Usage (Docker v1.13+)
For simply getting up and running with the latest stable version, do the following:

```
sh start.sh
# the username and password for the Docker registry will be asked of you,
# e.g. "duodecim+example" and "somepassword". The service takes a while to
# start, and is then usable on port 3001.
sh stop.sh
```

You can also specify a specific version with

```
sh start.sh 2.1.0
```

and you can skip having to enter your Docker registry username and password every time by defining the environment variables:

```
DOCKER_LOGIN=duodecim+example DOCKER_PASSWORD=somepassword sh start.sh
```

For more advanced usage, e.g. multi-node clusters, refer to the [Docker documentation](https://docs.docker.com/).


## Configuration

Per default the EBMeDS service `api-gateway` listens on port 3001 and is the only access point to the entire swarm. Environment variables can be set per service in the `<image-name>/config.env` file.

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