# ebmeds-docker
Create a minimal installation of EBMEDS using Docker Swarm in a one-node cluster.

## Quick start

```
# As a non-root user
git clone https://github.com/ebmeds/ebmeds-docker.git
cd ebmeds-docker
chmod -R 755 .

# You need the proper credentials here
DOCKER_LOGIN=duodecim+example DOCKER_PASSWORD=somePassword sh start.sh
```
## Detailed instructions
Please see the installation instructions at [](https://ebmeds.github.io/docs/installation/)

## Note
For a proper scaling EBMEDS installation, please use the Kubernetes deployment instructions at: https://github.com/ebmeds/ebmeds-kubernetes

# EBMEDS Docker Swarm

The services required to run the EBMEDS is described in the Docker compose file and can be deployed by Docker swarm. There are few things to take into account in order to run the EBMEDS docker through Docker swarm.

This guide assumed that the user has a minimum required version of Docker installed. The Docker compose file format version is `3.3` which needs the Docker Engine version `17.06.0` or higher to deploy. To check the Docker engine version, run:

    $ docker -v

Make sure you are included to the docker user group. Run:

     $ groups

This inputs a list that should include "docker". If you are not included, ask your sysadmin to add you to the group. If you were recently added, a relogin should do the trick. If you have root priviledges, you can add yourself with:

    $ sudo usermod -a -G docker $USER

Next thing to do is to increase the virtual memory address space to the recommended size. By default, the operating system limits on a `mmapfs` counts are likely to be too low, which may result out of memory exception in the Elasticsearch. To increase the limits, run the following command as root (in macOS you must `screen` into the Docker virtual machine in order to set this value):

    $ sudo sysctl -w vm.max_map_count=262144

This set the virtual memory address space value permanently and update the setting in `/etc/sysctl.conf`. To verify after rebooting, run:

    $ sysctl vm.max_map_count

Now, it's time to deploy the EBMEDS by Docker swarm for the first time if you have not yet done so. This step required you to log into the Quay Docker registry service provider where the built EBMEDS images are stored. To deploy the EBMEDS Docker, run:

    # Assuming that you are in the ebmeds-docker project root.
    # To deploy the latest development version, run:
    $ ./start.sh dev

    # To run the production version, run:
    $ ./start.sh

    # To run a specific version of EBMEDS build, e.g. version 2.3.10, run:
    $ ./start.sh 2.3.10

In some Linux distro, the Docker swarm has an issue with the created EBMEDS Docker volumes. This can be easily checked by examining the Logstash logs followingly:

    # To examine the Logstash logs
    $ docker service logs -f ebmeds_logstash

If the Logstash runner print out the following fatal error:

    An unexpected error occurred! {:error=>#<ArgumentError: Path "/usr/share/logstash/data/queue" must be a writable directory. It is not writable.>

Then, it means the deployed EBMEDS does not have right to write on created volumes that its services are mapped to. To fix this, check first where the volume is created followingly:

    $ docker volume inspect --format '{{ .Mountpoint }}' ebmeds_ebmeds-logstash-queue

This command reveals the Logstash volume path e.g.:

    /var/lib/docker/volumes/ebmeds_ebmeds-logstash-queue/_data

Assuming that the path, as mentioned earlier, is our Logstash volume path. Navigate to the `/var/lib/docker/volumes` and run the following command (in macOS, you must first `screen` into the Docker virtual machine, check Docker properties for its location):

    # Make sure you are in the right directory
    $ pwd
    /var/lib/docker/volumes
    # Gives read, write and execute rights to the EBMEDS volumes
    $ sudo chmod -R a+rwx ebmeds_ebmeds*

This gives recursively read, write, execute rights to the owner, group and other to all EBMEDS volumes. This concluded the deployment of the EBMEDS Docker swarm.

It's also worthy to mention that EBMEDS services, e.g. `api-gateway` and `clinical-datastore`, environment variables can be overridden in `config.env` configuration which resides in the project root. Some of the environment variables are global and shared between the EBMEDS Docker services. Such environment variables are e.g. `ELASTIC_APM_ACTIVE` and `EBMEDS_LOG_LEVEL`. Overriding the shared environment variable affect all the services that are using the shared variables.