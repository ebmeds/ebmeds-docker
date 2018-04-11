#!/bin/bash

docker service rm ebmeds_api-gateway
sleep 5 # give log messages a chance to be delivered
docker swarm leave -f