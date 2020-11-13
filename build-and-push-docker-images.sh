#!/bin/bash

cd $(dirname "$0")

pushd k8-reverse-proxy/stable-src/nginx
docker build -t elastisys/reverse-proxy-nginx:0.0.1 .
docker push elastisys/reverse-proxy-nginx:0.0.1
popd

pushd k8-reverse-proxy/stable-src/squid
docker build -t elastisys/reverse-proxy-squid:0.0.1 .
docker push elastisys/reverse-proxy-squid:0.0.1
popd
