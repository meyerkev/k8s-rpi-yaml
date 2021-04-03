#!/bin/sh

cd $(dirname $0)
cd ..

IMAGE_NAME=rockset

docker build -t ${IMAGE_NAME} .
docker tag ${IMAGE_NAME} meyerkev248/storage:${IMAGE_NAME}
docker push meyerkev248/storage:${IMAGE_NAME}
