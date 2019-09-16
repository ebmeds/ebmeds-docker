#!/bin/bash

EBMEDS_VERSION=${1:-latest}
EBMEDS_MASTER_DATA_VERSION=${2:-latest}
ELK_VERSION=6.8.3

if [[ "$1" = "--help" ]]; then
  echo "Usage: sh start.sh [ebmeds-version] [master-data-version]";
  echo "ebmeds-version: latest | x.y.z | dev";
  echo "master-data-version: latest | x.y.z";
  echo;
  echo "The environment variables DOCKER_LOGIN and DOCKER_PASSWORD can be used to skip having to manually enter the quay.io login info every time."
exit 0;
fi;

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
  echo "Something went wrong, EBMEDS startup aborted."
  exit 1;
fi

if [ "$(docker info --format '{{.Swarm.LocalNodeState}}')" = "inactive" ]; then
  docker swarm init
fi;

echo "Attempting to set vm.max_map_count (Elasticsearch wants it)"
sysctl -w vm.max_map_count=262144

echo "Using EBMEDS_VERSION=${EBMEDS_VERSION}..."
echo "Using EBMEDS_MASTER_DATA_VERSION=${EBMEDS_MASTER_DATA_VERSION}..."
echo "Using ELK_VERSION=${ELK_VERSION}..."

EBMEDS_VERSION=${EBMEDS_VERSION} EBMEDS_MASTER_DATA_VERSION=${EBMEDS_MASTER_DATA_VERSION} \
ELK_VERSION=${ELK_VERSION} \
  docker stack deploy --with-registry-auth --compose-file docker-compose.yml ebmeds
