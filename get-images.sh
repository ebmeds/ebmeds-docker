#!/bin/bash

# usage: ./get-images.sh <version>
# default version: latest

DEFAULT_VERSION=latest
VERSION=${1:-$DEFAULT_VERSION}

echo '################################################'
echo '# Logging into quay.io. Give your provided'
echo '# username (of the form "duodecim+yourname")'
echo '# and password. If you do not have a username,'
echo '# see https://www.ebmeds.org/'
echo '################################################'

docker login quay.io

echo
echo "Downloading latest images, using version \"$VERSION\""
docker pull quay.io/duodecim/ebmeds-api-gateway:$VERSION
docker pull quay.io/duodecim/ebmeds-engine:$VERSION
docker pull quay.io/duodecim/ebmeds-coaching:$VERSION
docker pull quay.io/duodecim/ebmeds-auth:$VERSION
docker pull quay.io/duodecim/ebmeds-clinical-datastore:$VERSION
docker pull docker.elastic.co/elasticsearch/elasticsearch:5.3.2
docker pull docker.elastic.co/kibana/kibana:5.3.2
docker pull docker.elastic.co/logstash/logstash:5.3.2

echo
echo 'Tagging images'
docker tag quay.io/duodecim/ebmeds-api-gateway:$VERSION api-gateway
docker tag quay.io/duodecim/ebmeds-engine:$VERSION engine
docker tag quay.io/duodecim/ebmeds-coaching:$VERSION coaching
docker tag quay.io/duodecim/ebmeds-auth:$VERSION auth
docker tag quay.io/duodecim/ebmeds-clinical-datastore:$VERSION clinical-datastore
docker tag docker.elastic.co/elasticsearch/elasticsearch:5.3.2 elasticsearch
docker tag docker.elastic.co/kibana/kibana:5.3.2 kibana
docker tag docker.elastic.co/logstash/logstash:5.3.2 logstash


