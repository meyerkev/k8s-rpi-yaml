#!/bin/bash

docker login
kubectl create secret generic regcred --from-file=.dockerconfigjson=$HOME/.docker/config.json
