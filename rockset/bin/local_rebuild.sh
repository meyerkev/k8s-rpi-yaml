#!/bin/sh

cd $(dirname $0)
cd ..

bin/build_image.sh

# `kubectl replace --force -f kconfig/` would also work.  
minikube kubectl -- delete deployment rockset
minikube kubectl -- apply -f kconfig/

# This runs forever, but without it running in some terminal, you can never connect to your service
minikube tunnel
