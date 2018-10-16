#!/bin/bash

docker service rm ebmeds_api-gateway > /dev/null
echo "Stopping EBMEDS, waiting for log messages to be delivered..."
sleep 5 # give log messages a chance to be delivered
docker swarm leave -f > /dev/null