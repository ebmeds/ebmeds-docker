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
