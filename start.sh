#!/bin/bash

if [ -z $1 ]; then
  echo "Usage: sh get-images.sh <version>";
  echo "version: latest | x.y.z | dev";
  echo;
  echo "The environment variables DOCKER_LOGIN and DOCKER_PASSWORD can be used to skip having to manually enter the quay.io login info every time."
exit 1;
fi;

EBMEDS_VERSION=${1:-latest}
ELK_VERSION=6.2.4

if [ -n "${DOCKER_LOGIN}" -a -n "${DOCKER_PASSWORD}" ]; then
  echo 'Logging into quay.io with provided DOCKER_LOGIN and DOCKER_PASSWORD...'
  docker login -u $DOCKER_LOGIN -p $DOCKER_PASSWORD quay.io;
else
  echo '#####################################################'
  echo '# Env variables DOCKER_LOGIN and/or DOCKER_PASSWORD #'
  echo '# not found.                                        #'
  echo '#                                                   #'
  echo '# Logging into quay.io. Give your provided          #'
  echo '# username (of the form "duodecim+yourname")        #'
  echo '# and password. If you do not have a username,      #'
  echo '# see https://ebmeds.github.io/docs/                #'
  echo '#####################################################'
  docker login quay.io
fi;

if [ $? -ne 0 ]; then
  echo "Something went wrong, EBMeDS startup aborted."
  exit 1;
fi

if [ "$(docker info --format '{{.Swarm.LocalNodeState}}')" = "inactive" ]; then
  docker swarm init
fi;

docker stack deploy --compose-file docker-compose.yml ebmeds