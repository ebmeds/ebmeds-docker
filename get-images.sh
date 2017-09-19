#!/bin/bash

echo '################################################'
echo '# Logging into quay.io. Give your provided'
echo '# username (of the form "duodecim+yourname")'
echo '# and password. If you do not have a username,'
echo '# see https://www.ebmeds.org/'
echo '################################################'

docker login quay.io

echo 'Downloading latest images'
docker pull quay.io/duodecim/ebmeds-api-gateway:latest
docker pull quay.io/duodecim/ebmeds-engine:latest
docker pull quay.io/duodecim/ebmeds-coaching:latest
docker pull quay.io/duodecim/ebmeds-auth:latest
docker pull docker.elastic.co/elasticsearch/elasticsearch:5.3.2
docker pull docker.elastic.co/kibana/kibana:5.3.2
docker pull docker.elastic.co/logstash/logstash:5.3.2

echo 'Tagging images'
docker tag quay.io/duodecim/ebmeds-api-gateway:latest api-gateway
docker tag quay.io/duodecim/ebmeds-engine:latest engine
docker tag quay.io/duodecim/ebmeds-coaching:latest coaching
docker tag quay.io/duodecim/ebmeds-auth:latest auth
docker tag docker.elastic.co/elasticsearch/elasticsearch:5.3.2 elasticsearch
docker tag docker.elastic.co/kibana/kibana:5.3.2 kibana
docker tag docker.elastic.co/logstash/logstash:5.3.2 logstash


