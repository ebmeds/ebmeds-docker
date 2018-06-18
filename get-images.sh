#!/bin/bash

if [ -z $1 ]; then
echo "Usage: sh get-images.sh <version>";
echo "version: latest | x.y.z | dev";
echo "\nThe environment variables DOCKER_LOGIN and DOCKER_PASSWORD can be used to skip having to manually enter the quay.io login info every time."
exit 1;
fi;

VERSION=${1}
ELK_VERSION=6.2.3

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

if [ $? -ne 0 ]; then exit 1; fi

echo
echo "Downloading images, using version \"$VERSION\""
docker pull quay.io/duodecim/ebmeds-api-gateway:$VERSION
docker pull quay.io/duodecim/ebmeds-engine:$VERSION
docker pull quay.io/duodecim/ebmeds-coaching:$VERSION
docker pull quay.io/duodecim/ebmeds-auth:$VERSION
docker pull quay.io/duodecim/ebmeds-clinical-datastore:$VERSION
docker pull quay.io/duodecim/ebmeds-format-converter:$VERSION
docker pull quay.io/duodecim/ebmeds-qmui:$VERSION
docker pull docker.elastic.co/elasticsearch/elasticsearch:$ELK_VERSION
docker pull docker.elastic.co/kibana/kibana:$ELK_VERSION
docker pull docker.elastic.co/logstash/logstash:$ELK_VERSION

echo
echo 'Tagging images'
docker tag quay.io/duodecim/ebmeds-api-gateway:$VERSION api-gateway
docker tag quay.io/duodecim/ebmeds-engine:$VERSION engine
docker tag quay.io/duodecim/ebmeds-coaching:$VERSION coaching
docker tag quay.io/duodecim/ebmeds-auth:$VERSION auth
docker tag quay.io/duodecim/ebmeds-clinical-datastore:$VERSION clinical-datastore
docker tag quay.io/duodecim/ebmeds-format-converter:$VERSION format-converter
docker tag quay.io/duodecim/ebmeds-qmui:$VERSION qmui
docker tag docker.elastic.co/elasticsearch/elasticsearch:$ELK_VERSION elasticsearch
docker tag docker.elastic.co/kibana/kibana:$ELK_VERSION kibana
docker tag docker.elastic.co/logstash/logstash:$ELK_VERSION logstash


